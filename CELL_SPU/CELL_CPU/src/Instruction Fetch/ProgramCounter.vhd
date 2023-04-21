library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity ProgramCounter is
    port(
        --Control signals
        clock : in std_logic;
        pcWrite : in std_logic;	
		stall : in std_logic;
	    branchStall : in std_logic;
	    isAbsolute : in std_logic;

        --Data Values
        count : out std_logic_vector(7 downto 0);
        pcWriteValue : in std_logic_vector(7 downto 0)

    );
end ProgramCounter;


architecture behavioral of ProgramCounter is 
    begin
        readAndWrite : process(clock)
        variable countVal : integer range 0 to 2**8;
        
        begin
            if(rising_edge(clock)) then 
                --Writing to the program counter
                if(pcWrite = '1') then
                    --If the value is absolute, then we just set the count to the value
                    if(isAbsolute = '1') then
                        count <= pcWriteValue;
                        countVal := to_integer(unsigned(pcWriteValue));
                    --If the value is relative, then we add the value to the current count
                    else
                        countVal := countVal + to_integer(signed(pcWriteValue));
                        count <= std_logic_vector(to_unsigned(countVal, 8));
                    end if;
                else
                    count <= std_logic_vector(to_unsigned(countVal, 8));
                end if;				  
				
				--If not stalled count as normal
                if(stall = '0' and branchStall = '0') then
                    if(countVal = 2**8) then 	 
                        countVal := 0;	  
                    else					  
                        countVal := countVal + 2;
                    end if;
                --If stalled then do not change the count
                else 
                    countVal := countVal;
                end if;

            end if;
        end process;

end behavioral;

