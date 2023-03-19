library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity ALU is 
  port(
    -- Inputs operands
    ra : in std_logic_vector(const.WIDTH - 1 downto 0);
    rb : in std_logic_vector(const.WIDTH - 1 downto 0);
    rc : in std_logic_vector(const.WIDTH - 1 downto 0);
    op : in std_logic_vector(6 downto 0);

    -- Outputs with status flags
    result : out std_logic_vector(const.WIDTH - 1 downto 0);
    zero : out std_logic;
    carry : out std_logic
  );
end ALU;

architecture Behavioral of ALU is
  --Given a std_logic_vector return the unsigned integer representation
  function intU (v : std_logic_vector) return integer is
  begin
      return to_integer(unsigned(v));
  end function;

  --Given a std__logic_vector return the signed integer representation
  function intS (v : std_logic_vector) return integer is 
  begin
    return to_integer(signed(v));
  end function;

  --Shift right arithmetic a std_logic_vector by an integer amount
  function shift_right_arithmetic(a : std_logic_vector; n : integer) return std_logic_vector is
    variable shifted : std_logic_vector(a'length-1 downto 0);
  begin
    shifted := std_logic_vector(shift_right(unsigned(a), n));
    if a(a'high) = '1' then
        shifted(a'length downto a'length - n + 1) := (others => '1');
    end if;
    return shifted;
  end function;

  --Given a std_logic_vector return an unsigned integer representating the amount of ones in the vector
  function countOnes (v : std_logic_vector) return integer is
    variable count : integer := 0;
  begin
    for i in v'range loop
      if v(i) = '1' then
        count := count + 1;
      end if;
    end loop;
    return count;
  end function;

  --Given a std_logic_vector and a bit sign extend the bit to the end of the vector
  function signExtend (v : std_logic_vector; bit : integer) return std_logic_vector is
    variable sign : std_logic := v(bit);
    variable extended : std_logic_vector(v'length-1 downto 0);
  begin
    extended := v;
    extended(v'length downto bit + 1) := (others => sign);
    return extended;
  end function;

  --Given a word size and a word number return the index
  function topBit (wordSize : integer; wordNum : integer) return integer is
  begin
    return wordSize * wordNum + (wordSize - 1);
  end function;

  begin 							  
    compute : process (ra, rb, rc, op)
	  variable wordTemp : std_logic_vector(const.WORDSIZE - 1 downto 0) := (others => '0');
    variable halfWordTemp : std_logic_vector(const.HALF_WORDSIZE - 1 downto 0) := (others => '0');
      begin
        --Add Word (a) overflows and carried not detected
        --For each word in the 128 operands add them together
        --a result, ra, rb
        if(intU(op) = 0) then
          for i in 0 to const.WORDS - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
            std_logic_vector(
              to_signed(
                intS(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) + 
                intS(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))
              ,
                const.WORDSIZE
              )
            );
          end loop;
        --Add Extended (addx) 
        --For each word slot add ra and rb as well as the top bit of rt also clear the bottom 30 bits
        --addx result, ra, rb
        elsif(intU(op) = 1) then
          for i in 0 to const.WORDS - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
              std_logic_vector(
                to_signed(
                  intS(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) + 
                  intS(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) + 
                  intU(rc(topBit(const.WORDSIZE, i) downto topBit(const.WORDSIZE, i)))
                  , 
                    const.WORDSIZE
                  )
                );
          end loop;

          --Clear the bottom 30 bits
          --Should assert if the bit width is greater than 30
          assert const.WIDTH >= 30 report "The bit width is less than 30 addx wont work" severity error;
          result(29 downto 0) <= (others => '0');

        --Add immediate (ai)
        --The signed 10 bit value in rb (should be sign extended already) is added to value in each word slot of ra
        --ai result, ra, rb
        elsif(intU(op) = 2) then 
          for i in 0 to const.WORDS - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
              std_logic_vector(
                to_signed(
                  intS(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) + 
                  intS(rb(const.WORDSIZE - 1 downto 0))
                  , 
                    const.WORDSIZE
                  )
                );
          end loop;
        --And (And) 
        --Logical And the values in ra and rb
        --and result, ra, rb
        elsif(intU(op) = 3) then
          for i in 0 to const.WORDS - 1 loop 
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
              ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) and
              rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i);
          end loop;
        --And Byte rbediate (andbi)
        --The byte value in the i10 field rb is anded with ra
        --andbi result, ra, rb
        elsif(intU(op) = 4) then
          for i in 0 to const.BYTES - 1 loop
            result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <= 
              ra(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) and
              rb(const.BYTE_SIZE - 1 downto 0);
          end loop;
        --And with Complement (andc)
        --Logical And the values in ra and the complement of rb
        --andc result, ra, rb
        elsif(intU(op) = 5) then
          for i in 0 to const.WORDS - 1 loop 
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
              ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) and
              (not rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i));
          end loop;
        --Borrow Generate (bg)
        --For each word if unsigned rb >= unsigned ra then result = 1 else 0
        --bg result, ra, rb
        elsif(intU(op) = 6) then
          for i in 0 to const.WORDS - 1 loop
            if(intU(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) >=
               intU(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(1, const.WORDSIZE));
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(0, const.WORDSIZE));
            end if;
          end loop;
        --Compare Equal Word (ceq)
        --For each word if ra = rb then result = 2^WORDSIZE - 1 else 0
        --ceq result, ra, rb
        elsif(intU(op) = 7) then
          for i in 0 to const.WORDS - 1 loop
            if(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) =
               rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(2**const.WORDSIZE - 1, const.WORDSIZE));
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(0, const.WORDSIZE));
            end if;
          end loop;
        --Compare Equal Byte (ceqb)
        --For each byte if ra = rb then result = 2^BYTE_SIZE - 1 else 0
        --ceqb result, ra, rb
        elsif(intU(op) = 8) then
          for i in 0 to const.BYTES - 1 loop
            if(ra(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) =
               rb(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i)) then
              result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <=
                std_logic_vector(to_unsigned(2**const.BYTE_SIZE - 1, const.BYTE_SIZE));
            else
              result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <=
                std_logic_vector(to_unsigned(0, const.BYTE_SIZE));
            end if;
          end loop;
        --Compare Equal Byte immediate (ceqbi)
        --For each byte if ra = rb then result = 2^BYTE_SIZE - 1 else 0
        --TODO It says I10 2:9 so the value should be sliced before coming in
        --ceqbi result, ra, rb
        elsif(intU(op) = 9) then
          for i in 0 to const.BYTES - 1 loop
            if(ra(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) =
               rb(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i)) then
              result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <=
                std_logic_vector(to_unsigned(2**const.BYTE_SIZE - 1, const.BYTE_SIZE));
            else
              result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <=
                std_logic_vector(to_unsigned(0, const.BYTE_SIZE));
            end if;
          end loop;
        --Compare Equal Word immediate (ceqi)
        --For each word if ra = rb then result = 2^WORDSIZE - 1 else 0 I10 should be sign extended
        --ceqi result, ra, rb
        elsif(intU(op) = 10) then
          for i in 0 to const.WORDS - 1 loop
            if(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) =
               rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(2**const.WORDSIZE - 1, const.WORDSIZE));
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(0, const.WORDSIZE));
            end if;
          end loop;
        --Carry Generate (cg)
        --For each word if ra + rb generates a carry place it in the result word slot as a 1 else 0
        --cg result, ra, rb
        elsif(intU(op) = 11) then 
          for i in 0 to const.WORDS - 1 loop
            if(intU(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) + 
      				intU(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) > 
			      	(2**const.WORDSIZE - 1)) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(1, const.WORDSIZE));
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(0, const.WORDSIZE));
            end if;
          end loop;
        --Compare Greater Than Byte (cgtb)
        --For each byte if ra > rb place a 1 in the result byte slot else 0
        --cgtb result, ra, rb
        elsif(intU(op) = 12) then 
          for i in 0 to const.BYTES - 1 loop
            if(intS(ra(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i)) > 
            intS(rb(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i))) then
              result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <=
                std_logic_vector(to_unsigned(2**const.BYTE_SIZE - 1, const.BYTE_SIZE));
            else
              result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <=
                std_logic_vector(to_unsigned(0, const.BYTE_SIZE));
            end if;
          end loop;
        --Compare Greater Than Byte immediate (cgtbi)
        --For each byte if ra > rb place a 1 in the result byte slot else 0 (rb <- I10 2:9)
        --cgtbi result, ra, rb
        elsif(intU(op) = 13) then 
          for i in 0 to const.BYTES - 1 loop
            if(intS(ra(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i)) > 
            intS(rb(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i))) then
              result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <=
                std_logic_vector(to_unsigned(2**const.BYTE_SIZE - 1, const.BYTE_SIZE));
            else
              result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <=
                std_logic_vector(to_unsigned(0, const.BYTE_SIZE));
            end if;
          end loop;
        --Compare Greater than Word immediate (cgti)
        --For each word if ra > rb place a 2^WORDSIZE in the result word slot else 0 
        --cgti result, ra, rb
        elsif(intU(op) = 14) then 
          for i in 0 to const.WORDS - 1 loop
            if(intS(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) > 
            intS(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(2**const.WORDSIZE - 1, const.WORDSIZE));
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(0, const.WORDSIZE));
            end if;
          end loop;
        --Compare Logical Greater Than Word (clgt)
        --For each word if ra > rb place a 2^WORDSIZE in the result word slot else 0
        --clgt result, ra, rb
        elsif(intU(op) = 15) then 
          for i in 0 to const.WORDS - 1 loop
            if(intU(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) > 
            intU(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(2**const.WORDSIZE - 1, const.WORDSIZE));
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(0, const.WORDSIZE));
            end if;
          end loop;
        --Compare Logical Greater Then Word Immediate (clgti)
        --For each word if ra > imm place a 2^WORDSIZE in the result word slot else 0 (I10 is sign extended)
        --clgti result, ra, imm
        elsif(intU(op) = 16) then 
          for i in 0 to const.WORDS - 1 loop
            if(intU(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) > 
            intU(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(2**const.WORDSIZE - 1, const.WORDSIZE));
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(0, const.WORDSIZE));
            end if;
          end loop;
        --Compare Logical Greater Than Byte (clgtb)
        --For each byte if ra > rb place a 2^8 in the result byte slot else 0
        --clgtb result, ra, rb
        elsif(intU(op) = 17) then 
          for i in 0 to const.BYTES - 1 loop
            if(intU(ra(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i)) > 
            intU(rb(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i))) then
              result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <=
                std_logic_vector(to_unsigned(2**const.BYTE_SIZE - 1, const.BYTE_SIZE));
            else
              result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <=
                std_logic_vector(to_unsigned(0, const.BYTE_SIZE));
            end if;
          end loop;
        --Compare Logical Greater Than Byte Immediate (clgtbi)
        --For each byte if ra > imm place a 2^8 in the result byte slot else 0
        --clgtbi result, ra, imm
        elsif(intU(op) = 18) then 
          for i in 0 to const.BYTES - 1 loop
            if(intU(ra(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i)) > 
            intU(rb(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i))) then
              result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <=
                std_logic_vector(to_unsigned(2**const.BYTE_SIZE - 1, const.BYTE_SIZE));
            else
              result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <=
                std_logic_vector(to_unsigned(0, const.BYTE_SIZE));
            end if;
          end loop;
        --Equivalent (eqv)
        --For each word slot if ra = rb place a 1 in the result word slot else 0
        --TODO The data sheet says theres a not for rb but idk if that makes sense
        --eqv result, ra, rb
        elsif(intU(op) = 19) then 
          for i in 0 to const.WORDS - 1 loop
            if(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) = 
            rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(1, const.WORDSIZE));
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                std_logic_vector(to_unsigned(0, const.WORDSIZE));
            end if;
          end loop;
        --Immediate Load Word (il)
        --Load the immediate value into each word slot the imm should be sign extended from 16 bits to 32
        --il result, imm (in rb)
        elsif(intU(op) = 20) then
          for i in 0 to const.WORDS - 1 loop
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                rb(const.WORDSIZE - 1 downto 0);
            end loop;
        --Immediate Load Address (ila)
        --Load the address of the immediate value into each word slot the imm should be zero extended to 32
        --ila result, imm (in rb)
        elsif(intU(op) = 21) then
          for i in 0 to const.WORDS - 1 loop
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                rb(const.WORDSIZE - 1 downto 0);
            end loop;
        --Immediate Load Halfword (ilh)
        --Load the immediate value into each halfword slot the imm should be sign extended from 16 bits to 32
        --ilh result, imm (in rb)
        elsif(intU(op) = 22) then
          for i in 0 to const.HALF_WORDS - 1 loop
            result(topBit(const.HALF_WORDSIZE, i) downto const.HALF_WORDSIZE * i) <=
              rb(const.HALF_WORDSIZE - 1 downto 0);
          end loop;
        --Nand (nand)
        --Nand the two operands and store the result in the result output
        --nand result, ra, rb
        elsif(intU(op) = 23) then
          result <= not (ra and rb);
        --Nor (nor)
        --Nor the two operands and store the result in the result output
        --nor result, ra, rb
        elsif(intU(op) = 24) then
          result <= not (ra or rb);
        --Or (or)
        --Or the two operands and store the result in the result output
        --or result, ra, rb
        elsif(intU(op) = 25) then
          result <= ra or rb;
        --Or with Compliment (orc)
        --Compliment rb then OR the two operands and store the result in the result output
        --orc result, ra, rb
        elsif(intU(op) = 26) then
          result <= ra or not rb;
        --Or Word immediate (ori)
        --OR the immediate value with ra and store the result (immediate is sign extended 10 bits to 32)
        --ori result, ra, imm
        elsif(intU(op) = 27) then
          for i in 0 to const.WORDS - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
              ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) or
              rb(const.WORDSIZE - 1 downto 0);
          end loop;
        --Or Across (orx)
        --The four word slots of ra are ORed together and stored in the result 
        --orx rt, ra
        elsif(intU(op) = 28) then
          result <= std_logic_vector(to_unsigned(0, const.WIDTH));
          for i in 0 to const.WORDS - 1 loop
            wordTemp := wordTemp or ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i);
          end loop;

          result <= std_logic_vector(to_unsigned(0, const.WIDTH));
          result(const.WORDSIZE - 1 downto 0) <= wordTemp;
        --Subtract from Word (sf)
        --Subtract ra from rb and store the result in the result output
        --sf result, ra, rb
        elsif(intU(op) = 29) then
          for i in 0 to const.WORDS - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
              std_logic_vector(
                to_signed(  
                  intS(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) - 
                  intS(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))
                , 
                const.WORDSIZE
                )
              );
          end loop;
        --Subtract from Word Immediate (sfi)
        --Subtract ra from rb (imm) the I10 value should be sign extended to WORDSIZE
        --sfi result, ra, rb
        elsif(intU(op) = 30) then
          for i in 0 to const.WORDS - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
              std_logic_vector(
                to_signed(  
                  intS(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) - 
                  intS(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))
                , 
                const.WORDSIZE
                )
              );
          end loop;       
        --Subtract from Extended (sfx)
        --Subtract ra from rb and add the top bit from each word then clear the bottom 30 bits
        --sfx result, ra, rb
        elsif(intU(op) = 31) then
          for i in 0 to const.WORDS - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
              std_logic_vector(
                to_signed(
                  intS(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) + 
                  intS(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) + 
                  intU(rc(topBit(const.WORDSIZE, i) downto topBit(const.WORDSIZE, i)))
                  , 
                    const.WORDSIZE
                  )
                );
          end loop;
          
          assert const.WIDTH >= 30 report "The bit width is less than 30 sfx wont work" severity error;
          result(29 downto 0) <= (others => '0');
        --Exclusive Or (xor)
        --Xor ra and rb
        --xor result, ra, rb
        elsif(intU(op) = 32) then
          result <= ra xor rb;
        --Exclusive Or Byte Immediate (xorbi)
        --Xor ra and the immediate value which should be in the bottom 8 bits of rb
        --xorbi result, ra, rb
        elsif(intU(op) = 33) then
          for i in 0 to const.BYTES - 1 loop
            result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <= 
              ra(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) xor
              rb(const.BYTE_SIZE - 1 downto 0);
          end loop;
        --Exclusive Or Word Immediate (xori)
        --Xor ra and the immediate value which should be signed extended from 10 to 32 bits
        --xori result, ra, imm
        elsif(intU(op) = 34) then
          for i in 0 to const.WORDS - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
              ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) xor
              rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i);
          end loop;
        --Extend Sign Byte Halfword 
        --For each Half word in ra sign extend the bottom byte to const.HALF_WORDSIZE bits
        --TODO Review this one and the next two for bugs
        --xsbh result, ra
        elsif(intU(op) = 35) then
          for i in 0 to const.HALF_WORDS - 1 loop
            --If the top bit of the byte is 1 then the rest of the bits should be 1
            if(intU(ra(topBit(const.BYTE_SIZE, i * 2) downto topBit(const.BYTE_SIZE, i * 2))) = 1) then
              result(topBit(const.HALF_WORDSIZE, i) downto topBit(const.BYTE_SIZE, i * 2)) <= 
                (others => '1');
            else
              result(topBit(const.HALF_WORDSIZE, i) downto topBit(const.BYTE_SIZE, i * 2)) <= 
                (others => '0');
            end if;
          end loop;
        --Extend Sign HalfWord to Word (xshw)
        --For each word in ra sign extend the bottom half word to const.WORDSIZE bits
        --xshw result, ra
        elsif(intU(op) = 36) then
          for i in 0 to const.WORDS - 1 loop
            --If the top bit of the half word is 1 then the rest of the bits should be 1
            if(intU(ra(topBit(const.HALF_WORDSIZE, i * 2) downto topBit(const.HALF_WORDSIZE, i * 2))) = 1) then
              result(topBit(const.WORDSIZE, i) downto topBit(const.HALF_WORDSIZE, i * 2)) <= 
                (others => '1');
            else
              result(topBit(const.WORDSIZE, i) downto topBit(const.HALF_WORDSIZE, i * 2)) <= 
                (others => '0');
            end if;
          end loop;
        --Extend SIgn Word to DoubleWord (xswd)
        --For each double word in ra sign extend the bottom word to const.DOUBLE_WORDSIZE bits
        --xswd result, ra
        elsif(intU(op) = 37) then
          for i in 0 to const.DOUBLE_WORDS - 1 loop
            --If the top bit of the word is 1 then the rest of the bits should be 1
            if(intU(ra(topBit(const.WORDSIZE, i * 2) downto topBit(const.WORDSIZE, i * 2))) = 1) then
              result(topBit(const.DOUBLE_WORDSIZE, i) downto topBit(const.WORDSIZE, i * 2)) <= 
                (others => '1');
            else
              result(topBit(const.DOUBLE_WORDSIZE, i) downto topBit(const.WORDSIZE, i * 2)) <= 
                (others => '0');
            end if;
          end loop;
        --TODO check all the rotate instructions for the correct shift amount it wants mod stuff
        --Rotate Word (rot)
        --For each word in ra rotate the bits by the number of bits specified in rb
        --rot result, ra, rb
        elsif(intU(op) = 38) then
          for i in 0 to const.WORDS - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
              std_logic_vector(
                rotate_left(
                  unsigned(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))
                  ,
                  intU(rb(const.WORDSIZE - 1 downto 0))
                )
              );
          end loop;
        --Rotate Word Immediate (roti)
        --For each word in ra rotate the bits by the number of bits specified in imm sign extend I7 to 32 bits
        --roti result, ra, imm
        elsif(intU(op) = 39) then
          for i in 0 to const.WORDS - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
              std_logic_vector(
                rotate_left(
                  unsigned(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))
                  ,
                  intU(rb(const.WORDSIZE - 1 downto 0))
                )
              );
          end loop;
        --Rotate and Mask Word (rotm)
        --For each word shift the bits by the integer in rb if its greater than 32 clear it
        --rotm result, ra, rb
        elsif(intU(op) = 40) then 
          for i in 0 to const.WORDS - 1 loop
            if(intU(rb(const.WORDSIZE - 1 downto 0)) < 32) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
                std_logic_vector(
                  shift_right(
                    unsigned(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))
                    ,
                    intU(rb(const.WORDSIZE - 1 downto 0))
                  )
                );
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
                std_logic_vector(to_unsigned(0, const.WORDSIZE));
            end if;
          end loop;
        --Rotate and Mask Word Immediate (rotmi)
        --Same as rotm but the shift amount in i7 should be sign extended to 32
        --rotmi result, ra, i7
        elsif(intU(op) = 41) then 
          for i in 0 to const.WORDS - 1 loop
            if(intU(rb(const.WORDSIZE - 1 downto 0)) < 32) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
                std_logic_vector(
                  shift_right(
                    unsigned(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))
                    ,
                    intU(rb(const.WORDSIZE - 1 downto 0))
                  )
                );
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
                std_logic_vector(to_unsigned(0, const.WORDSIZE));
            end if;
          end loop;

        --Rotate and mask Algebraic Word (rotmai)
        --Shift right algebraic word ra by rb bits and store the result in result
        --rotmai result, ra, rb
        elsif(intU(op) = 42) then 
          for i in 0 to const.WORDS - 1 loop
            if(intU(rb(const.WORDSIZE - 1 downto 0)) < 32) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
                  shift_right_arithmetic(
                    ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)
                    ,
                    intU(rb(const.WORDSIZE - 1 downto 0))
                  );
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
               std_logic_vector(to_unsigned(0, const.WORDSIZE));
            end if;
          end loop;

        --Shift Left Word (shl)
        --ra is shifted left according to bits 26 to 31 of rb if the count is greater than 31 its zero
        --shl result, ra, rb
        elsif(intU(op) = 43) then 
          for i in 0 to const.WORDS - 1 loop
            if(intU(rb(topBit(const.WORDSIZE, i) downto topBit(const.WORDSIZE, i) - 5)) < 32) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
                std_logic_vector(
                  shift_left(
                    unsigned(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))
                    ,
                    intU(rb(topBit(const.WORDSIZE, i) downto topBit(const.WORDSIZE, i) - 5))
                  )
                );
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
               std_logic_vector(to_unsigned(0, const.WORDSIZE));
            end if;
          end loop;

        --Shift Left Word Immediate (shli)
        --ra is shifted to the left by the iimedaite bit 12 to 17 which are in the bottom 6 bits of rb
        --shli result, ra, value
        elsif(intU(op) = 44) then 
          for i in 0 to const.WORDS - 1 loop
            if(intU(rb(5 downto 0)) < 32) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
                std_logic_vector(
                  shift_left(
                    unsigned(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))
                    ,
                    intU(rb(5 downto 0))
                  )
                );
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <= 
               std_logic_vector(to_unsigned(0, const.WORDSIZE));
            end if;
          end loop;

        --Absolute Differences of Bytes (absdb)
        --For each byte subtract them and make them positive if they are negative
        --absd result, ra, rb
        elsif(intU(op) = 45) then 
          for i in 0 to const.BYTES - 1 loop
            if(intS(rb(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i)) > 
            intS(ra(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i))) then
              result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <= 
              std_logic_vector(
                abs(
                  signed(rb(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i)) - 
                  signed(ra(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i))
                )
              );
            else
            result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <= 
              std_logic_vector(
                abs(
                  signed(ra(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i)) - 
                  signed(rb(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i))
                )
              );
            end if;
          end loop;

        --Average Bytes (avgb)
        --For each byte ra is added to rb plus 1 and the result is right shifted by 1
        --avgb rt, ra, rb
        elsif(intU(op) = 46) then 
          for i in 0 to const.BYTES - 1 loop
            result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <= 
              std_logic_vector(
                (
                signed(ra(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i)) + 
                signed(rb(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i)) + 1
                ) / 2
              );
          end loop;

        --Count Ones in Bytes (cntb)
        --For each byte in ra count the number of ones and store the result in rt
        --cntb rt, ra
        elsif(intU(op) = 47) then 
          for i in 0 to const.BYTES - 1 loop
            result(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i) <= 
              std_logic_vector(
                to_unsigned(
                  countOnes(
                   ra(topBit(const.BYTE_SIZE, i) downto const.BYTE_SIZE * i)
                  )
                ,
                const.BYTE_SIZE
                )
              );
          end loop;

        --Sum Bytes into Halfwords (sumb)
        --For each word slot in result add the four bytes in rb and store in the halfword of rt then switch to ra
        --sumb rt, ra, rb
        elsif(intU(op) = 48) then 
          for i in 0 to const.HALF_WORDS - 1 loop
            halfWordTemp := (others => '0');

            if(i mod 2 = 0) then 
              for j in 0 to (const.WORDSIZE / const.BYTE_SIZE) - 1 loop
                halfWordTemp :=
                  std_logic_vector(
                    (
                    unsigned(rb(topBit(const.BYTE_SIZE, j) downto const.BYTE_SIZE * j)) +
                    unsigned(halfWordTemp)
                    )
                  );
              end loop;
            else
              for j in 0 to (const.WORDSIZE / const.BYTE_SIZE) - 1 loop
                halfWordTemp :=
                  std_logic_vector(
                    (
                    unsigned(ra(topBit(const.BYTE_SIZE, j) downto const.BYTE_SIZE * j)) +
                    unsigned(halfWordTemp)
                    )
                  );
              end loop;
            end if;

            result(topBit(const.HALF_WORDS, i) downto const.HALF_WORDS * i) <= halfWordTemp;
          end loop;

        --Branch Relative (br) 
        --Add two zeros at the bottom 
        --br ra
        elsif(intU(op) = 49) then 
          result <= std_logic_vector(
              shift_left(
                unsigned(ra)
                ,
                2
              )
            );

        --Branch Absolute (bra)
        --Add two zeros at the bottom
        --bra ra
        elsif(intU(op) = 50) then 
          result <= std_logic_vector(
              shift_left(
                unsigned(ra)
                ,
                2
              )
            );

        --Branch if Not Zero Word (brnz)
        --TODO Examine if the bottom word slot of ra is not zero if so branch also add two zeros at the bottom
        --brnz rt, ra
        elsif(intU(op) = 51) then
           result <= std_logic_vector(
              shift_left(
                unsigned(ra)
                ,
                2
              )
            );

        --Branch if Zero Word (brz)
        --TODO Examine if the bottom word slot of ra is zero if so branch also add two zeros at the bottom
        --brz rt, ra
        elsif(intU(op) = 52) then
           result <= std_logic_vector(
              shift_left(
                unsigned(ra)
                ,
                2
              )
            );
        
        --Rotate Quadword by Bytes (rotqby)
        --The bottom 4 bits of the prefered slot of rb byte is used to rotate ra to the left
        --rotqby rt, ra, rb
        elsif(intU(op) = 53) then
          result <= 
            std_logic_vector(
              shift_left(
                unsigned(ra(const.QUAD_WORDSIZE - 1downto 0))
                ,
                intU(rb(const.WORDSIZE - 1 downto const.WORDSIZE - const.BYTE_SIZE))
              )
            );

        --Rotate Quadword by Bytes Immediate (rotqbyi)
        --The bottom 4 bits of the prefered slot of rb byte is used to rotate ra to the left I7 right 4 bits
        --rotqbyi
        elsif(intU(op) = 54) then
          result <= 
            std_logic_vector(
              shift_left(
                unsigned(ra(const.QUAD_WORDSIZE - 1 downto 0))
                ,
                intU(rb(const.WORDSIZE - 1 downto const.WORDSIZE - const.BYTE_SIZE))
              )
            );
        
        --Rotate and Mask Quadword by Bytes (rotqmby)
        --Using the prefered word slot of rb mod 32 shift ra if < 16 shift right else rt = 0
        --rotqmby rt, ra, rb
        elsif(intU(op) = 55) then
          if(intU(rb(topBit(const.WORDSIZE, 0) downto 0)) mod 32 < 16) then
            result <=
              std_logic_vector(
                shift_right(
                  unsigned(ra)
                  ,
                  intU(rb(topBit(const.WORDSIZE, 0) downto 0)) mod 32  
                 )
              );
          else 
            result <= (others => '0');
          end if;

        --Rotate and Mask Quadword by Bytes Immediate (rotqmbyi)
        --Using the prefered word slot of rb mod 32 shift ra if < 16 shift right else rt = 0
        --rotqmbyi rt, ra, rb
        elsif(intU(op) = 56) then
          if(intU(rb(topBit(const.WORDSIZE, 0) downto 0)) mod 32 < 16) then
            result <=
              std_logic_vector(
                shift_right(
                  unsigned(ra) 
                  ,
                   intU(rb(topBit(const.WORDSIZE, 0) downto 0)) mod 32  
                )
              );
          else 
            result <= (others => '0');
          end if;

        --Shift Left Quadwords by Bytes (shlqby)
        --Using the prefered word slot of rb mod 32 shift ra if < 16 shift left else rt = 0
        --shlqby rt, ra, rb
        elsif(intU(op) = 57) then
          if(intU(rb(topBit(const.WORDSIZE, 0) downto topBit(const.WORDSIZE, 0) - 4)) mod 32 < 16) then
            result <=
              std_logic_vector(
                shift_left(
                 unsigned(ra) 
                 ,
                 intU(rb(topBit(const.WORDSIZE, 0) downto topBit(const.WORDSIZE, 0) - 4)) mod 32
                )
              );
          else 
            result <= (others => '0');
          end if;

        --Shift Left Quadwords by Bytes Immediate (shlqbyi)
        --Using the prefered word slot of rb mod 32 shift ra if < 16 shift left else rt = 0
        --shlqbyi rt, ra, rb
        elsif(intU(op) = 58) then
          if(intU(rb(topBit(const.WORDSIZE, 0) downto topBit(const.WORDSIZE, 0) - 4)) mod 32 < 16) then
            result <=
              std_logic_vector(
                shift_left(
                  unsigned(ra) 
                  ,
                  intU(rb(topBit(const.WORDSIZE, 0) downto topBit(const.WORDSIZE, 0) - 4)) mod 32  
                )
              );
          else 
            result <= (others => '0');
          end if;

        --Load Quadword a-form (lqa)
        --Add two zeros to the end of the address
        --lqa rt, ra
        elsif(intU(op) = 59) then
           result <= std_logic_vector(
              shift_left(
                unsigned(ra)
                ,
                2
              )
            );
        --Load Quadword x-form (lqx)
        --Add two zeros to the end of the address
        --lqx rt, symbol
        elsif(intU(op) = 60) then
          result <= std_logic_vector(
              shift_left(
                unsigned(ra)
                ,
                2
              )
            );

        --Store Quadword a-form (stqa)
        --Add two zeros to the end of the address
        --stqa rt, symbol
        elsif(intU(op) = 61) then
          result <= std_logic_vector(
              shift_left(
                unsigned(ra)
                ,
                2
              )
            );

        --Store Quadword x-form (stqx)
        --Add two zeros to the end of the address
        --stqx rt, symbol
        elsif(intU(op) = 62) then
          result <= std_logic_vector(
              shift_left(
                unsigned(ra)
                ,
                2
              )
            );

        --Floating add (fa)
        --Add two floating point numbers and store the result
        --fm rt, ra, rb
        elsif(intU(op) = 63) then
          for i in 0 to const.WORDSIZE - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
              std_logic_vector(
                to_float(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) +
                to_float(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))
              );
          end loop;
		
        --Floating Multiply (fm)
        --Multiply two floating point numbers and store the result
        --fm rt, ra, rb
        elsif(intU(op) = 64) then
          for i in 0 to const.WORDSIZE - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
              std_logic_vector(
                to_float(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) *
                to_float(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))
              );
          end loop;

        --Floating Multiply and Add (fma)
        --Multiply two floating point numbers and add a third then store the result
        --fma result, ra, rb, rc
        elsif(intU(op) = 65) then
          for i in 0 to const.WORDSIZE - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
              std_logic_vector(
                to_float(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) *
                to_float(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) +
                to_float(rc(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))
              );
          end loop;

        --Floating Multiply and Subtract (fms)
        --Multiply two floating point numbers and subtract a third then store the result
        --fms result, ra, rb, rc
        elsif(intU(op) = 66) then
          for i in 0 to const.WORDSIZE - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
              std_logic_vector(
                to_float(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) *
                to_float(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) -
                to_float(rc(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))
              );
          end loop;

        --Floating Subtract (fs)
        --Subtract two floating point numbers
        --fs ra, rb
        elsif(intU(op) = 67) then
          for i in 0 to const.WORDSIZE - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
              std_logic_vector(
                to_float(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) -
                to_float(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) 
              );
          end loop;

        --Floating Compare Equal (fceq)
        --If equal the word slot is set to all ones else all zeros
        --fceq rt, ra, rb
        elsif(intU(op) = 68) then
          for i in 0 to const.WORDSIZE - 1 loop
            if(to_float(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) =
               to_float(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                (others => '1');
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                (others => '0');
            end if;
          end loop;

        --Floating Compare Greater Than (fcgt)
        --If ra > rb the word slot is set to all zeros else all ones
        --fcgt rt, ra, rb
        elsif(intU(op) = 69) then
          for i in 0 to const.WORDSIZE - 1 loop
            if(to_float(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) >
               to_float(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i))) then
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                (others => '1');
            else
              result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
                (others => '0');
            end if;
          end loop;
        
        --Multiply (mpy)
        --The upper 16 bits of each word are multiplied and stored in the word slot
        --mpy rt, ra, rb
        elsif(intU(op) = 70) then 
          for i in 0 to const.WORDSIZE - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
              std_logic_vector(
                signed(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i - (const.HALF_WORDSIZE - 1))) * 
                signed(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i - (const.HALF_WORDSIZE - 1)))
              );
          end loop;

        --Multiply and Add (mpya)
        --The upper 16 bits of each word are multiplied and stored in the word slot and added with rc word
        --mpya rt, ra, rb, rc
        elsif(intU(op) = 71) then 
          for i in 0 to const.WORDSIZE - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
              std_logic_vector(
                signed(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i - (const.HALF_WORDSIZE - 1))) * 
                signed(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i - (const.HALF_WORDSIZE - 1))) +
                signed(rc(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) 
              );
          end loop;

        --Multiply Immediate (mpyi)
        --Multiply each word in ra by rb i10 should be signed extended to 32 bits
        --mpyi rt, ra, rb
        elsif(intU(op) = 72) then
          for i in 0 to const.WORDSIZE - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
              std_logic_vector(
                signed(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i)) *
                signed(rb(const.WORDSIZE - 1 downto 0))
              );
          end loop;

        --Multiply and Shift Right (mpys)
        --Multiply the upper bits of each word and then sign extend to 32 bits
        --mpys rt, ra, rb
        elsif(intU(op) = 73) then
          for i in 0 to const.WORDSIZE - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
            signExtend(
              std_logic_vector(
                signed(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i - (const.HALF_WORDSIZE - 1))) *
                signed(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i - (const.HALF_WORDSIZE - 1)))
              )
              ,
              const.HALF_WORDSIZE
            );
          end loop;

        --Multiply Unsigned (mpyu)
        --Multiply the upper bits of each word and then sign extend to 32 bits
        --mpyu rt, ra, rb
        elsif(intU(op) = 74) then
          for i in 0 to const.WORDSIZE - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
              std_logic_vector(
                unsigned(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i - (const.HALF_WORDSIZE - 1))) *
                unsigned(rb(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i - (const.HALF_WORDSIZE - 1)))
              );
          end loop;

        --Multiply Unsigned Immediate (mpyui)
        --Multiply the upper bits of each word and then sign extend I10 from 10 to 16 bits and placed in bottom
        --mpyui rt, ra, rb
        elsif(intU(op) = 75) then
          for i in 0 to const.WORDSIZE - 1 loop
            result(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i) <=
              std_logic_vector(
                unsigned(ra(topBit(const.WORDSIZE, i) downto const.WORDSIZE * i - (const.HALF_WORDSIZE - 1))) *
                unsigned(rb(topBit(const.WORDSIZE, 0) downto 0))
              );
          end loop;

        --No Operation Execute (lnop)
        --lnop
        elsif(intU(op) = 76) then
          result <= (others => '0');

        --No Operation (nop)
        --nop
        elsif(intU(op) = 77) then
          result <= (others => '0');

        --Stop and Signal (stop)
        --stop
        elsif(intU(op) = 78) then
          result <= (others => '0');
        else
          assert false report "Invalid operation" severity error;
        end if;

    end process compute;
end Behavioral;

