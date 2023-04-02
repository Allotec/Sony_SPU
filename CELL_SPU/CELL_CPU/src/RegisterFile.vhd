library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;


entity RegisterFile is 
    port(
        --Inputs
        clock : in std_logic;

        --Odd addresses
        addressAO : in std_logic_vector(6 downto 0);
        addressBO : in std_logic_vector(6 downto 0);
        addressTO : in std_logic_vector(6 downto 0);

        --Even addresses
        addressAE : in std_logic_vector(6 downto 0);
        addressBE : in std_logic_vector(6 downto 0);
        addressTE : in std_logic_vector(6 downto 0);

        --Even Port writing
        regWriteE : in std_logic;
        regDataE : in std_logic_vector(const.WIDTH - 1 downto 0);
        regAddressE : in std_logic_vector(6 downto 0);

        --Odd Port writing
        regWriteO : in std_logic;
        regDataO : in std_logic_vector(const.WIDTH - 1 downto 0);
        regAddressO : in std_logic_vector(6 downto 0);

        --Outputs
        --Odd Outputs
        valueAO : out std_logic_vector(const.WIDTH - 1 downto 0);
        valueBO : out std_logic_vector(const.WIDTH - 1 downto 0);
        valueCO : out std_logic_vector(const.WIDTH - 1 downto 0);

        --Even Outputs
        valueAE : out std_logic_vector(const.WIDTH - 1 downto 0);
        valueBE : out std_logic_vector(const.WIDTH - 1 downto 0);
        valueCE : out std_logic_vector(const.WIDTH - 1 downto 0)

    );
end RegisterFile;



architecture behavioral of RegisterFile is
    type registers is array (0 to 127) of std_logic_vector(const.WIDTH - 1 downto 0);
    signal regFile : registers;

begin		
    read : process(clock)
        begin
            if(rising_edge(clock)) then
                --Writing to address A odd with bypass
                if(addressAO = regAddressE and regWriteE = '1') then
                    valueAO <= regDataE;
                elsif(addressAO = regAddressO and regWriteO = '1') then
                    valueAO <= regDataO;
                else
                    valueAO <= regFile(to_integer(unsigned(addressAO)));
                end if;

                --Writing to address B odd with bypass
                if(addressBO = regAddressE and regWriteE = '1') then
                    valueBO <= regDataE;
                elsif(addressBO = regAddressO and regWriteO = '1') then
                    valueBO <= regDataO;
                else
                    valueBO <= regFile(to_integer(unsigned(addressBO)));
                end if;

                --Writing to address T odd with bypass
                if(addressTO = regAddressE and regWriteE = '1') then
                    valueCO <= regDataE;
                elsif(addressTO = regAddressO and regWriteO = '1') then
                    valueCO <= regDataO;
                else
                    valueCO <= regFile(to_integer(unsigned(addressTO)));
                end if;

                --Writing to address A even with bypass
                if(addressAE = regAddressE and regWriteE = '1') then
                    valueAE <= regDataE;
                elsif(addressAE = regAddressO and regWriteO = '1') then
                    valueAE <= regDataO;
                else
                    valueAE <= regFile(to_integer(unsigned(addressAE)));
                end if;

                --Writing to address B even with bypass
                if(addressBE = regAddressE and regWriteE = '1') then
                    valueBE <= regDataE;
                elsif(addressBE = regAddressO and regWriteO = '1') then
                    valueBE <= regDataO;
                else
                    valueBE <= regFile(to_integer(unsigned(addressBE)));
                end if;

                --Writing to address T even with bypass
                if(addressTE = regAddressE and regWriteE = '1') then
                    valueCE <= regDataE;
                elsif(addressTE = regAddressO and regWriteO = '1') then
                    valueCE <= regDataO;
                else
                    valueCE <= regFile(to_integer(unsigned(addressTE)));
                end if;
                
            end if;
    end process;

    write : process(clock)
        begin
            if(rising_edge(clock)) then
                --Write to the register from the even port
                if(regWriteE = '1') then
                    regFile(to_integer(unsigned(regAddressE))) <= regDataE;
                end if;

                --Write to the register from the odd port
                if(regWriteO = '1') then
                    regFile(to_integer(unsigned(regAddressO))) <= regDataO;
                end if;
            end if;
    end process;
end behavioral;