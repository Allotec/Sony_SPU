library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity ForwardingUnit is 
    port(
        --Inputs
        clock: in std_logic;

        --Current addresses being processed to check against the stored values
        --Even pipe
        addressAE : in std_logic_vector(6 downto 0);
        addressBE : in std_logic_vector(6 downto 0);
        addressCE : in std_logic_vector(6 downto 0);

        --Odd pipe
        addressAO : in std_logic_vector(6 downto 0);
        addressBO : in std_logic_vector(6 downto 0);
        addressCO : in std_logic_vector(6 downto 0);

        --Values from each pipe to be stored for a certain number of clock cycles
        --From the even pipe
        --From pipe 0 hold onto the values for 1 clock cycle
        resultSPIMA : in std_logic_vector(const.WIDTH - 1 downto 0);
        rtSPIMA : in std_logic_vector(6 downto 0);
        regWriteSPIMA : in std_logic;
        
        --From pipe 1 hold onto the values for 2 clock cycles
        resultSPFP : in std_logic_vector(const.WIDTH - 1 downto 0);
        rtSPFP : in std_logic_vector(6 downto 0);
        regWriteSPFP : in std_logic;
        
        --From pipe 2 hold onto the values for 5 clock cycles
        resultB : in std_logic_vector(const.WIDTH - 1 downto 0);
        rtB : in std_logic_vector(6 downto 0);
        regWriteB : in std_logic;
        
        --From pipe 3 hold onto the values for 5 clock cycles
        resultSF2 : in std_logic_vector(const.WIDTH - 1 downto 0);
        rtSF2 : in std_logic_vector(6 downto 0);
        regWriteSF2 : in std_logic;
        
        --From pipe 4 hold onto the values for 6 clock cycles
        resultSF1 : in std_logic_vector(const.WIDTH - 1 downto 0);
        rtSF1 : in std_logic_vector(6 downto 0);
        regWriteSF1 : in std_logic;

        --From the odd pipe
        --From pipe 5 hold onto the values for 2 clock cycle
        resultLS : in std_logic_vector(const.WIDTH - 1 downto 0);
        rtLS : in std_logic_vector(6 downto 0);
        regWriteLS : in std_logic;

        --From pipe 6 hold onto the values for 5 clock cycles
        resultP : in std_logic_vector(const.WIDTH - 1 downto 0);
        rtP : in std_logic_vector(6 downto 0);
        regWriteP : in std_logic;

        --Outputs
        --To the even pipe ALU port decoder
        valueAE : out std_logic_vector(const.WIDTH - 1 downto 0);
        forwardAE : out std_logic;
        valueBE : out std_logic_vector(const.WIDTH - 1 downto 0);
        forwardBE : out std_logic;
        valueCE : out std_logic_vector(const.WIDTH - 1 downto 0);
        forwardCE : out std_logic;

        --To the odd pipe ALU port decoder
        valueAO : out std_logic_vector(const.WIDTH - 1 downto 0);
        forwardAO : out std_logic;
        valueBO : out std_logic_vector(const.WIDTH - 1 downto 0);
        forwardBO : out std_logic;
        valueCO : out std_logic_vector(const.WIDTH - 1 downto 0);
        forwardCO : out std_logic
    );
end ForwardingUnit;

architecture Behavioral of ForwardingUnit is 
    type valueParameters is record
        result : std_logic_vector(const.WIDTH - 1 downto 0);
        rt : std_logic_vector(6 downto 0);
        regWrite : std_logic;
    end record;

    type valueParametersArray is array(natural range <>) of valueParameters;

    --Procedure that takes in an array of valueParameters and shifts all the values to the right by 1
    procedure ShiftRight(arr: inout valueParametersArray) is
        begin
            if arr'length = 1 then
                return;
            end if;

            for i in arr'length - 1 to 1 loop
                arr(i) := arr(i - 1);
            end loop;
    end procedure;

    procedure ForwardingLogic(
    signal inputAddress: in std_logic_vector(6 downto 0);
    signal outputValue: out std_logic_vector(const.WIDTH - 1 downto 0);
    signal outputForwardFlag: out std_logic;
    constant arrays: in valueParametersArray
    ) is
    begin
        outputForwardFlag <= '0';
        for i in arrays'range loop
            if arrays(i).regWrite = '1' and inputAddress = arrays(i).rt then
                outputValue <= arrays(i).result;
                outputForwardFlag <= '1';
                exit;
            end if;
        end loop;
    end procedure;

    begin
        forward : process(clock)
        
        --Arrays to hold the values from each pipe for a certain number of clock cycles		 
        variable arraySPIMA : valueParametersArray(0 to 0) := (others => (regWrite => '0', rt => "0000000", result => (others => '0')));
        variable arraySPFP : valueParametersArray(0 to 1) := (others => (regWrite => '0', rt => "0000000", result => (others => '0')));
        variable arrayB : valueParametersArray(0 to 4) := (others => (regWrite => '0', rt => "0000000", result => (others => '0')));
        variable arraySF2 : valueParametersArray(0 to 4) := (others => (regWrite => '0', rt => "0000000", result => (others => '0')));
        variable arraySF1 : valueParametersArray(0 to 5) := (others => (regWrite => '0', rt => "0000000", result => (others => '0')));
        variable arrayLS : valueParametersArray(0 to 1) := (others => (regWrite => '0', rt => "0000000", result => (others => '0')));
        variable arrayP : valueParametersArray(0 to 4) := (others => (regWrite => '0', rt => "0000000", result => (others => '0')));
            begin
                if(rising_edge(clock)) then
                    --Set all the forward flag values to 0
                    forwardAE <= '0';
                    forwardBE <= '0';
                    forwardCE <= '0';
                    forwardAO <= '0';
                    forwardBO <= '0';
                    forwardCO <= '0';
                    --Shift all the arrays to the right by 1
                    ShiftRight(arraySPIMA);
                    ShiftRight(arraySPFP);
                    ShiftRight(arrayB);
                    ShiftRight(arraySF2);
                    ShiftRight(arraySF1);
                    ShiftRight(arrayLS);
                    ShiftRight(arrayP);

                    --Read in the values from each port and place them in the bottom of each array
                    arraySPIMA(0).result := resultSPIMA;
                    arraySPIMA(0).rt := rtSPIMA;
                    arraySPIMA(0).regWrite := regWriteSPIMA;

                    arraySPFP(0).result := resultSPFP;
                    arraySPFP(0).rt := rtSPFP;
                    arraySPFP(0).regWrite := regWriteSPFP;

                    arrayB(0).result := resultB;
                    arrayB(0).rt := rtB;
                    arrayB(0).regWrite := regWriteB;

                    arraySF2(0).result := resultSF2;
                    arraySF2(0).rt := rtSF2;
                    arraySF2(0).regWrite := regWriteSF2;

                    arraySF1(0).result := resultSF1;
                    arraySF1(0).rt := rtSF1;
                    arraySF1(0).regWrite := regWriteSF1;

                    arrayLS(0).result := resultLS;
                    arrayLS(0).rt := rtLS;
                    arrayLS(0).regWrite := regWriteLS;

                    arrayP(0).result := resultP;
                    arrayP(0).rt := rtP;
                    arrayP(0).regWrite := regWriteP;

                    --Check if the address matches any of the stored values
                    --If there is a match, forward the value to the ALU port decoder
                    --Check the address currently being loaded into the even port decoder
                    ForwardingLogic(addressAE, valueAE, forwardAE, arraySPIMA);
                    ForwardingLogic(addressBE, valueBE, forwardBE, arraySPIMA);
                    ForwardingLogic(addressCE, valueCE, forwardCE, arraySPIMA);

                    ForwardingLogic(addressAE, valueAE, forwardAE, arraySPFP);
                    ForwardingLogic(addressBE, valueBE, forwardBE, arraySPFP);
                    ForwardingLogic(addressCE, valueCE, forwardCE, arraySPFP);

                    ForwardingLogic(addressAE, valueAE, forwardAE, arrayB);
                    ForwardingLogic(addressBE, valueBE, forwardBE, arrayB);
                    ForwardingLogic(addressCE, valueCE, forwardCE, arrayB);

                    ForwardingLogic(addressAE, valueAE, forwardAE, arraySF2);
                    ForwardingLogic(addressBE, valueBE, forwardBE, arraySF2);
                    ForwardingLogic(addressCE, valueCE, forwardCE, arraySF2);

                    ForwardingLogic(addressAE, valueAE, forwardAE, arraySF1);
                    ForwardingLogic(addressBE, valueBE, forwardBE, arraySF1);
                    ForwardingLogic(addressCE, valueCE, forwardCE, arraySF1);

                    ForwardingLogic(addressAE, valueAE, forwardAE, arrayLS);
                    ForwardingLogic(addressBE, valueBE, forwardBE, arrayLS);
                    ForwardingLogic(addressCE, valueCE, forwardCE, arrayLS);

                    ForwardingLogic(addressAE, valueAE, forwardAE, arrayP);
                    ForwardingLogic(addressBE, valueBE, forwardBE, arrayP);
                    ForwardingLogic(addressCE, valueCE, forwardCE, arrayP);

                    --Check the address currently being loaded into the odd port decoder
                    ForwardingLogic(addressAO, valueAO, forwardAO, arraySPIMA);
                    ForwardingLogic(addressBO, valueBO, forwardBO, arraySPIMA);
                    ForwardingLogic(addressCO, valueCO, forwardCO, arraySPIMA);

                    ForwardingLogic(addressAO, valueAO, forwardAO, arraySPFP);
                    ForwardingLogic(addressBO, valueBO, forwardBO, arraySPFP);
                    ForwardingLogic(addressCO, valueCO, forwardCO, arraySPFP);

                    ForwardingLogic(addressAO, valueAO, forwardAO, arrayB);
                    ForwardingLogic(addressBO, valueBO, forwardBO, arrayB);
                    ForwardingLogic(addressCO, valueCO, forwardCO, arrayB);

                    ForwardingLogic(addressAO, valueAO, forwardAO, arraySF2);
                    ForwardingLogic(addressBO, valueBO, forwardBO, arraySF2);
                    ForwardingLogic(addressCO, valueCO, forwardCO, arraySF2);

                    ForwardingLogic(addressAO, valueAO, forwardAO, arraySF1);
                    ForwardingLogic(addressBO, valueBO, forwardBO, arraySF1);
                    ForwardingLogic(addressCO, valueCO, forwardCO, arraySF1);

                    ForwardingLogic(addressAO, valueAO, forwardAO, arrayLS);
                    ForwardingLogic(addressBO, valueBO, forwardBO, arrayLS);
                    ForwardingLogic(addressCO, valueCO, forwardCO, arrayLS);

                    ForwardingLogic(addressAO, valueAO, forwardAO, arrayP);
                    ForwardingLogic(addressBO, valueBO, forwardBO, arrayP);
                    ForwardingLogic(addressCO, valueCO, forwardCO, arrayP);
            end if;
        end process;

end Behavioral;
