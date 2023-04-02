library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity LocalStore is 
    port(
        --Inputs
        clk: in std_logic;
        valMem : in std_logic_vector(const.WIDTH - 1 downto 0);
        regWrite : in std_logic;
        rt : in std_logic_vector(6 downto 0);
        address : in std_logic_vector(const.WIDTH - 1 downto 0);

        --Outputs
        regWriteOut : out std_logic;
        rtOut : out std_logic_vector(6 downto 0);
        resultOut : out std_logic_vector(const.WIDTH - 1 downto 0) 
    );
end LocalStore;

--On the rising edge of every clock read in the the bottom 18 bits of the address for the memory
--The memory is is 2^15 8 bit words
--The 19th bit of the address is either 0 for read and 1 for write
--If its a write set the regWriteOut to 0 and the rtOut to the rt input
--If its a read set the regWriteOut to regWrite and the rtOut to the rt input
architecture Behavioral of LocalStore is
	type memory is array (0 to 2**18 - 1) of std_logic_vector(const.BYTE_SIZE - 1 downto 0);
	signal mem : memory;

    --Given a std_logic_vector return the unsigned integer representation
    function intU (v : std_logic_vector) return integer is
    begin
        return to_integer(unsigned(v));
    end function;

    begin						   
		LocalStorage : process(clk)
		variable readWriteBit : std_logic := address(19);
        variable address : std_logic_vector(17 downto 0) := address(17 downto 0);
        begin																	
            if rising_edge(clk) then
                --Read
                if readWriteBit = '0' then
                    regWriteOut <= regWrite;
                    rtOut <= rt;
					
					for i in 0 to const.BYTES - 1 loop
            			resultOut(i * const.BYTE_SIZE + const.BYTE_SIZE - 1 downto i * const.BYTE_SIZE) <= mem(intU(address) + i);
        			end loop;
                --Write
                elsif readWriteBit = '1' then
                    regWriteOut <= '0';
                    rtOut <= rt;
                    resultOut <= (others => '0');  
					
                    for i in 0 to const.BYTES - 1 loop
            			mem(intU(address) + i) <= valMem(i * const.BYTE_SIZE + const.BYTE_SIZE - 1 downto i * const.BYTE_SIZE);
        			end loop;
                --Do Nothing
                else
                    regWriteOut <= '0';
                    rtOut <= (others => '0');
                    resultOut <= (others => '0');
                end if;
            end if;
        end process;
end Behavioral;

