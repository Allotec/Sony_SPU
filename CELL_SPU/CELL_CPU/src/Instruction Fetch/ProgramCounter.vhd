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

        --Data Values
        count : out std_logic_vector(7 downto 0);
        pcWriteValue : in std_logic_vector(7 downto 0)

    );
end ProgramCounter;


architecture behavioral of ProgramCounter is 
    begin
        readAndWrite : process(clock)
        variable countVal : integer range 0 to 2**8 - 1;
        
        begin
            if(rising_edge(clock)) then 
                if(pcWrite = '1') then
                    count <= pcWriteValue;
                    countVal := to_integer(unsigned(pcWriteValue));
                else
                    count <= std_logic_vector(to_unsigned(countVal, 8));
                end if;				  
				
				
                if(stall = '0') then
                    if(countVal = 2**8 - 1) then 	 
                        countVal := 0;	  
                    else					  
                        countVal := countVal + 2;
                    end if;
                else 
                    countVal := countVal;
                end if;

            end if;
        end process;

end behavioral;

