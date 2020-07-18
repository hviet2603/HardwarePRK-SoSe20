library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

library work;
use work.ArmTypes.all;
use work.ArmArithInstructionCtrl;

library ARM_SIM_LIB;
use ARM_SIM_LIB.ArmArithInstructionCtrl;
use ARM_SIM_LIB.ArmTypes.all;
use ARM_SIM_LIB.ArmCoarseInstructionDecoder;

entity ArmArithInstructionCtrl_tb is
end entity;

architecture bench of ArmArithInstructionCtrl_tb is
        signal AIC_DECODED_VECTOR                             : std_logic_vector(15 downto 0);                              
        signal AIC_INSTRUCTION                                : std_logic_vector(31 downto 0);                          
        signal AIC_IF_IAR_INC,       AIC_IF_IAR_INC_REF       : std_logic;                         
        signal AIC_ID_R_PORT_A_ADDR, AIC_ID_R_PORT_A_ADDR_REF : std_logic_vector(3 downto 0);                               
        signal AIC_ID_R_PORT_B_ADDR, AIC_ID_R_PORT_B_ADDR_REF : std_logic_vector(3 downto 0);                               
        signal AIC_ID_R_PORT_C_ADDR, AIC_ID_R_PORT_C_ADDR_REF : std_logic_vector(3 downto 0);                               
        signal AIC_ID_REGS_USED,     AIC_ID_REGS_USED_REF     : std_logic_vector(2 downto 0);                           
        signal AIC_ID_IMMEDIATE,     AIC_ID_IMMEDIATE_REF     : std_logic_vector(31 downto 0);                           
        signal AIC_ID_OPB_MUX_CTRL,  AIC_ID_OPB_MUX_CTRL_REF  : std_logic;                              
        signal AIC_EX_ALU_CTRL,      AIC_EX_ALU_CTRL_REF      : std_logic_vector(3 downto 0);                          
        signal AIC_MEM_RES_REG_EN,   AIC_MEM_RES_REG_EN_REF   : std_logic;                             
        signal AIC_MEM_CC_REG_EN,    AIC_MEM_CC_REG_EN_REF    : std_logic;                            
        signal AIC_WB_RES_REG_EN,    AIC_WB_RES_REG_EN_REF    : std_logic;                            
        signal AIC_WB_CC_REG_EN,     AIC_WB_CC_REG_EN_REF     : std_logic;                           
        signal AIC_WB_W_PORT_A_ADDR, AIC_WB_W_PORT_A_ADDR_REF : std_logic_vector(3 downto 0);                               
        signal AIC_WB_W_PORT_A_EN,   AIC_WB_W_PORT_A_EN_REF   : std_logic;                             
        signal AIC_WB_IAR_MUX_CTRL,  AIC_WB_IAR_MUX_CTRL_REF  : std_logic;                              
        signal AIC_WB_IAR_LOAD,      AIC_WB_IAR_LOAD_REF      : std_logic;                          
        signal AIC_WB_PSR_EN,        AIC_WB_PSR_EN_REF        : std_logic;                        
        signal AIC_WB_PSR_SET_CC,    AIC_WB_PSR_SET_CC_REF    : std_logic;                            
        signal AIC_WB_PSR_ER,        AIC_WB_PSR_ER_REF        : std_logic;                        
        signal AIC_DELAY,            AIC_DELAY_REF            : std_logic_vector(1 downto 0);                    
        signal AIC_ARM_NEXT_STATE                             : work.ArmTypes.ARM_STATE_TYPE;
        signal AIC_ARM_NEXT_STATE_REF                         : ARM_SIM_LIB.ArmTypes.ARM_STATE_TYPE;    
        
        type INSTR_TESTCASES_CODE_TYPE is array (1 to 28) of string(1 to 25);
        constant INSTR_TESTCASES_CODE  : INSTR_TESTCASES_CODE_TYPE := (
            "add    r0, r1, r2, lsl #2",
            "add    r3, r4, r5, lsl r6",
            "add    r7, r8, #16       ",
            "add    r15, r9, r10      ",
            "sub    r0, r1, r2, lsl #2",
            "sub    r3, r4, r5, lsl r6",
            "sub    r7, r8, #16       ",
            "sub    r15, r9, r10      ",
            "mov    r0, r1, lsl #2    ",
            "mvn    r3, r4, lsl r6    ",
            "orr    r7, r8, #16       ",
            "and    r15, r9, r10      ",
            "adds   r0, r1, r2, lsl #2",
            "adds   r3, r4, r5, lsl r6",
            "adds   r7, r8, #16       ",
            "adds   r15, r9, r10      ",
            "subs   r0, r1, r2, lsl #2",
            "subs   r3, r4, r5, lsl r6",
            "subs   r7, r8, #16       ",
            "subs   pc, lr            ",
            "cmp    r0, r1, lsl #2    ",
            "cmn    r3, r4, lsl r6    ",
            "tst    r7, #16           ",
            "teq    r15, r10          ",
            "cmp    r7, #16           ",
            "cmn    r15, r11          ",
            "tst    r0, r1, lsl #2    ",
            "teq    r3, r4, lsl r6    "
        );
        
        type INSTR_TESTCASES_TYPE is array (1 to 28) of std_logic_vector(31 downto 0);
        constant INSTR_TESTCASES  : INSTR_TESTCASES_TYPE := (
            x"e0810102", x"e0843615", x"e2887010", x"e089f00a",
            x"e0410102", x"e0443615", x"e2487010", x"e049f00a",
            x"e1a00101", x"e1e03614", x"e3887010", x"e009f00a",
            x"e0910102", x"e0943615", x"e2987010", x"e099f00a",
            x"e0510102", x"e0543615", x"e2587010", x"e05ff00e",
            x"e1500101", x"e1730614", x"e3170010", x"e13f000a",
            x"e3570010", x"e17f000b", x"e1100101", x"e1330614"
        );
begin

    uut : entity work.ArmArithInstructionCtrl(behave)
    port map (
        AIC_DECODED_VECTOR   => AIC_DECODED_VECTOR,
        AIC_INSTRUCTION      => AIC_INSTRUCTION,
        AIC_IF_IAR_INC       => AIC_IF_IAR_INC,
        AIC_ID_R_PORT_A_ADDR => AIC_ID_R_PORT_A_ADDR,
        AIC_ID_R_PORT_B_ADDR => AIC_ID_R_PORT_B_ADDR,
        AIC_ID_R_PORT_C_ADDR => AIC_ID_R_PORT_C_ADDR,
        AIC_ID_REGS_USED     => AIC_ID_REGS_USED,
        AIC_ID_IMMEDIATE     => AIC_ID_IMMEDIATE,
        AIC_ID_OPB_MUX_CTRL  => AIC_ID_OPB_MUX_CTRL,
        AIC_EX_ALU_CTRL      => AIC_EX_ALU_CTRL,
        AIC_MEM_RES_REG_EN   => AIC_MEM_RES_REG_EN,
        AIC_MEM_CC_REG_EN    => AIC_MEM_CC_REG_EN,
        AIC_WB_RES_REG_EN    => AIC_WB_RES_REG_EN,
        AIC_WB_CC_REG_EN     => AIC_WB_CC_REG_EN,
        AIC_WB_W_PORT_A_ADDR => AIC_WB_W_PORT_A_ADDR,
        AIC_WB_W_PORT_A_EN   => AIC_WB_W_PORT_A_EN,
        AIC_WB_IAR_MUX_CTRL  => AIC_WB_IAR_MUX_CTRL,
        AIC_WB_IAR_LOAD      => AIC_WB_IAR_LOAD,
        AIC_WB_PSR_EN        => AIC_WB_PSR_EN,
        AIC_WB_PSR_SET_CC    => AIC_WB_PSR_SET_CC,
        AIC_WB_PSR_ER        => AIC_WB_PSR_ER,
        AIC_DELAY            => AIC_DELAY,
        AIC_ARM_NEXT_STATE   => AIC_ARM_NEXT_STATE
    );
    
    decoder : entity ARM_SIM_LIB.ArmCoarseInstructionDecoder(behave)
    port map (
        CID_INSTRUCTION    => AIC_INSTRUCTION,
        CID_DECODED_VECTOR => AIC_DECODED_VECTOR
    );

    ref : entity ARM_SIM_LIB.ArmArithInstructionCtrl(behave)
    port map (
        AIC_DECODED_VECTOR   => AIC_DECODED_VECTOR,  
        AIC_INSTRUCTION      => AIC_INSTRUCTION,  
        AIC_IF_IAR_INC       => AIC_IF_IAR_INC_REF,
        AIC_ID_R_PORT_A_ADDR => AIC_ID_R_PORT_A_ADDR_REF,  
        AIC_ID_R_PORT_B_ADDR => AIC_ID_R_PORT_B_ADDR_REF,  
        AIC_ID_R_PORT_C_ADDR => AIC_ID_R_PORT_C_ADDR_REF,  
        AIC_ID_REGS_USED     => AIC_ID_REGS_USED_REF,  
        AIC_ID_IMMEDIATE     => AIC_ID_IMMEDIATE_REF,  
        AIC_ID_OPB_MUX_CTRL  => AIC_ID_OPB_MUX_CTRL_REF,
        AIC_EX_ALU_CTRL      => AIC_EX_ALU_CTRL_REF,  
        AIC_MEM_RES_REG_EN   => AIC_MEM_RES_REG_EN_REF,
        AIC_MEM_CC_REG_EN    => AIC_MEM_CC_REG_EN_REF,
        AIC_WB_RES_REG_EN    => AIC_WB_RES_REG_EN_REF,
        AIC_WB_CC_REG_EN     => AIC_WB_CC_REG_EN_REF,
        AIC_WB_W_PORT_A_ADDR => AIC_WB_W_PORT_A_ADDR_REF,  
        AIC_WB_W_PORT_A_EN   => AIC_WB_W_PORT_A_EN_REF,
        AIC_WB_IAR_MUX_CTRL  => AIC_WB_IAR_MUX_CTRL_REF,
        AIC_WB_IAR_LOAD      => AIC_WB_IAR_LOAD_REF,
        AIC_WB_PSR_EN        => AIC_WB_PSR_EN_REF,
        AIC_WB_PSR_SET_CC    => AIC_WB_PSR_SET_CC_REF,
        AIC_WB_PSR_ER        => AIC_WB_PSR_ER_REF,
        AIC_DELAY            => AIC_DELAY_REF,
        AIC_ARM_NEXT_STATE   => AIC_ARM_NEXT_STATE_REF
    );

    tb : process
        variable l : line;
        variable total_errors    : integer := 0;
        variable testcase_errors : integer := 0;
        variable testcase_error  : boolean := false;
    begin
        for i in INSTR_TESTCASES'range loop
            write(l, string'("------------------- Testcase " & integer'image(i) & " / " & integer'image(INSTR_TESTCASES'length) & ": -------------------"));
            writeline(OUTPUT, l);
            write(l, string'("  Instruktion: " & INSTR_TESTCASES_CODE(i)));
            writeline(OUTPUT, l);
            write(l, string'("  binaer:      "));
            write(l, INSTR_TESTCASES(i));
            writeline(OUTPUT, l);
            write(l, string'("  Zeit:        " & time'image(now)));
            writeline(OUTPUT, l);
            writeline(OUTPUT, l);
            
            testcase_error := false;
            
            AIC_INSTRUCTION <= INSTR_TESTCASES(i);
            wait for 10 ns;
            
            if AIC_IF_IAR_INC        /= AIC_IF_IAR_INC_REF       then write(l, string'("  AIC_IF_IAR_INC      fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_ID_R_PORT_A_ADDR  /= AIC_ID_R_PORT_A_ADDR_REF then write(l, string'("  AIC_ID_R_PORT_A_ADD fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_ID_R_PORT_B_ADDR  /= AIC_ID_R_PORT_B_ADDR_REF then write(l, string'("  AIC_ID_R_PORT_B_ADD fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_ID_R_PORT_C_ADDR  /= AIC_ID_R_PORT_C_ADDR_REF then write(l, string'("  AIC_ID_R_PORT_C_ADD fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_ID_REGS_USED      /= AIC_ID_REGS_USED_REF     then write(l, string'("  AIC_ID_REGS_USED    fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_ID_IMMEDIATE      /= AIC_ID_IMMEDIATE_REF     then write(l, string'("  AIC_ID_IMMEDIATE    fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_ID_OPB_MUX_CTRL   /= AIC_ID_OPB_MUX_CTRL_REF  then write(l, string'("  AIC_ID_OPB_MUX_CTRL fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_EX_ALU_CTRL       /= AIC_EX_ALU_CTRL_REF      then write(l, string'("  AIC_EX_ALU_CTRL     fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_MEM_RES_REG_EN    /= AIC_MEM_RES_REG_EN_REF   then write(l, string'("  AIC_MEM_RES_REG_EN  fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_MEM_CC_REG_EN     /= AIC_MEM_CC_REG_EN_REF    then write(l, string'("  AIC_MEM_CC_REG_EN   fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_RES_REG_EN     /= AIC_WB_RES_REG_EN_REF    then write(l, string'("  AIC_WB_RES_REG_EN   fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_CC_REG_EN      /= AIC_WB_CC_REG_EN_REF     then write(l, string'("  AIC_WB_CC_REG_EN    fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_W_PORT_A_ADDR  /= AIC_WB_W_PORT_A_ADDR_REF then write(l, string'("  AIC_WB_W_PORT_A_ADD fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_W_PORT_A_EN    /= AIC_WB_W_PORT_A_EN_REF   then write(l, string'("  AIC_WB_W_PORT_A_EN  fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_IAR_MUX_CTRL   /= AIC_WB_IAR_MUX_CTRL_REF  then write(l, string'("  AIC_WB_IAR_MUX_CTRL fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_IAR_LOAD       /= AIC_WB_IAR_LOAD_REF      then write(l, string'("  AIC_WB_IAR_LOAD     fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_PSR_EN         /= AIC_WB_PSR_EN_REF        then write(l, string'("  AIC_WB_PSR_EN       fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_PSR_SET_CC     /= AIC_WB_PSR_SET_CC_REF    then write(l, string'("  AIC_WB_PSR_SET_CC   fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_WB_PSR_ER         /= AIC_WB_PSR_ER_REF        then write(l, string'("  AIC_WB_PSR_ER       fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if AIC_DELAY             /= AIC_DELAY_REF            then write(l, string'("  AIC_DELAY           fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            if work.ArmTypes.ARM_STATE_TYPE'image(AIC_ARM_NEXT_STATE) /= ARM_SIM_LIB.ArmTypes.ARM_STATE_TYPE'image(AIC_ARM_NEXT_STATE_REF) then write(l, string'("  AIC_ARM_NEXT_STATE  fehlerhaft! ")); writeline(OUTPUT, l); testcase_error := true; total_errors := total_errors + 1; end if;
            
            writeline(OUTPUT, l);    

            if testcase_error then
                testcase_errors := testcase_errors + 1;
            end if;
        end loop;
        
        write(l, string'("------------------------ Ergebnis: ----------------------"));
        writeline(OUTPUT, l);
        write(l, "Erfolgreiche Testcases: " & integer'image(INSTR_TESTCASES'length - testcase_errors) & " / " & integer'image(INSTR_TESTCASES'length));
        writeline(OUTPUT, l);
        write(l, "Fehlerhafte Signale:    " & integer'image(total_errors));
        writeline(OUTPUT,l);
        writeline(OUTPUT,l);
        report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure;
        wait;
    end process;

end architecture;

