/* =============================================================================================================
模块功能：通过 I2C 接口与外部设备（如 Flash 存储器）通信的模块. 
         它支持 Wishbone 总线协议. 用于主控与 I2C 外设之间的数据传输和配置更新. 
===============================================================================================================*/
`timescale 1 ns / 1 ps
module I2C_UPDATE (
    input  wire        wb_clk_i,        // Wishbone 时钟信号
    input  wire        wb_rst_i,        // Wishbone 复位信号，高电平有效
    input  wire        wb_cyc_i,        // Wishbone 总线周期信号
    input  wire        wb_stb_i,        // Wishbone 选通信号
    input  wire        wb_we_i,         // Wishbone 写使能信号，高电平表示写操作
    input  wire [7:0]  wb_adr_i,        // Wishbone 地址信号
    input  wire [7:0]  wb_dat_i,        // Wishbone 数据输入信号
    output wire [7:0]  wb_dat_o,        // Wishbone 数据输出信号
    output wire        wb_ack_o,        // Wishbone 应答信号，表示操作完成
    inout  wire        i2c1_scl,        // I2C 时钟信号
    inout  wire        i2c1_sda,        // I2C 数据信号
    output wire        i2c1_irqo,       // I2C 中断信号
    output wire        wbc_ufm_irq      // UFM 中断信号
);
// 内部信号定义
wire scuba_vhi;                     // 高电平信号
wire scuba_vlo;                     // 低电平信号
wire i2c1_sdaoen;                   // I2C 数据线输出使能信号
wire i2c1_sdao;                     // I2C 数据线输出信号
wire i2c1_scloen;                   // I2C 时钟线输出使能信号
wire i2c1_sclo;                     // I2C 时钟线输出信号
wire i2c1_sdai;                     // I2C 数据线输入信号
wire i2c1_scli;                     // I2C 时钟线输入信号

/*--------------------------------------------------------------------------------------------------------------------
使用原语生成高电平和低电平
模块作用 使能闪存模块
---------------------------------------------------------------------------------------------------------------------*/
VHI scuba_vhi_inst (.Z(scuba_vhi)); // 高电平生成器
VLO scuba_vlo_inst (.Z(scuba_vlo)); // 低电平生成器

/*--------------------------------------------------------------------------------------------------------------------
BB缓冲器模块
模块作用
1、双向信号驱动
I2C的SDA和SCL信号是双向的，既可以作为输入，也可以作为输出。
BB模块通过I（输入信号）、O（输出信号）、T（三态控制信号）和 B（双向信号）实现双向通信。

信号隔离
BB 模块可以根据三态控制信号 T 的状态，将信号驱动到总线上，或者将总线上的信号读取到内部逻辑中，从而实现信号的隔离。

I2C 接口支持
在 I2C 协议中，SDA 和 SCL 是开漏（open-drain）信号，BB 模块通过三态逻辑支持这种特性。
---------------------------------------------------------------------------------------------------------------------*/
BB BB1_sda (
    .I(i2c1_sdao),      // I: 内部逻辑输出信号，当 T 为高时，I 的值会驱动到 B
    .T(i2c1_sdaoen),    // T: 三态控制信号，高电平表示输出使能，低电平表示输入（高阻态）
    .O(i2c1_sdai),      // O: 内部逻辑输入信号，从 B 读取的值
    .B(i2c1_sda)        // B: 双向信号，与外部设备连接
);

BB BB1_scl (
    .I(i2c1_sclo), 
    .T(i2c1_scloen), 
    .O(i2c1_scli), 
    .B(i2c1_scl)
);

defparam EFBInst_0.UFM_INIT_FILE_FORMAT = "HEX" ;
defparam EFBInst_0.UFM_INIT_FILE_NAME = "NONE" ;
defparam EFBInst_0.UFM_INIT_ALL_ZEROS = "ENABLED" ;
defparam EFBInst_0.UFM_INIT_START_PAGE = 2045 ;
defparam EFBInst_0.UFM_INIT_PAGES = 1 ;
defparam EFBInst_0.DEV_DENSITY = "6900L" ;
defparam EFBInst_0.EFB_UFM = "ENABLED" ;
defparam EFBInst_0.TC_ICAPTURE = "DISABLED" ;
defparam EFBInst_0.TC_OVERFLOW = "DISABLED" ;
defparam EFBInst_0.TC_ICR_INT = "OFF" ;
defparam EFBInst_0.TC_OCR_INT = "OFF" ;
defparam EFBInst_0.TC_OV_INT = "OFF" ;
defparam EFBInst_0.TC_TOP_SEL = "OFF" ;
defparam EFBInst_0.TC_RESETN = "ENABLED" ;
defparam EFBInst_0.TC_OC_MODE = "TOGGLE" ;
defparam EFBInst_0.TC_OCR_SET = 32767 ;
defparam EFBInst_0.TC_TOP_SET = 65535 ;
defparam EFBInst_0.GSR = "ENABLED" ;
defparam EFBInst_0.TC_CCLK_SEL = 1 ;
defparam EFBInst_0.TC_MODE = "CTCM" ;
defparam EFBInst_0.TC_SCLK_SEL = "PCLOCK" ;
defparam EFBInst_0.EFB_TC_PORTMODE = "WB" ;
defparam EFBInst_0.EFB_TC = "DISABLED" ;
defparam EFBInst_0.SPI_WAKEUP = "DISABLED" ;
defparam EFBInst_0.SPI_INTR_RXOVR = "DISABLED" ;
defparam EFBInst_0.SPI_INTR_TXOVR = "DISABLED" ;
defparam EFBInst_0.SPI_INTR_RXRDY = "DISABLED" ;
defparam EFBInst_0.SPI_INTR_TXRDY = "DISABLED" ;
defparam EFBInst_0.SPI_SLAVE_HANDSHAKE = "DISABLED" ;
defparam EFBInst_0.SPI_PHASE_ADJ = "DISABLED" ;
defparam EFBInst_0.SPI_CLK_INV = "DISABLED" ;
defparam EFBInst_0.SPI_LSB_FIRST = "DISABLED" ;
defparam EFBInst_0.SPI_CLK_DIVIDER = 1 ;
defparam EFBInst_0.SPI_MODE = "MASTER" ;
defparam EFBInst_0.EFB_SPI = "DISABLED" ;
defparam EFBInst_0.I2C2_WAKEUP = "DISABLED" ;
defparam EFBInst_0.I2C2_GEN_CALL = "DISABLED" ;
defparam EFBInst_0.I2C2_CLK_DIVIDER = 1 ;
defparam EFBInst_0.I2C2_BUS_PERF = "100kHz" ;
defparam EFBInst_0.I2C2_SLAVE_ADDR = "0b1000001" ;
defparam EFBInst_0.I2C2_ADDRESSING = "7BIT" ;
defparam EFBInst_0.EFB_I2C2 = "DISABLED" ;
defparam EFBInst_0.I2C1_WAKEUP = "DISABLED" ;
defparam EFBInst_0.I2C1_GEN_CALL = "DISABLED" ;
defparam EFBInst_0.I2C1_CLK_DIVIDER = 11 ;
defparam EFBInst_0.I2C1_BUS_PERF = "100kHz" ;
defparam EFBInst_0.I2C1_SLAVE_ADDR = "0b1000001" ;
defparam EFBInst_0.I2C1_ADDRESSING = "7BIT" ;
defparam EFBInst_0.EFB_I2C1 = "ENABLED" ;
defparam EFBInst_0.EFB_WB_CLK_FREQ = "4.3" ;


/*--------------------------------------------------------------------------------------------------------------------
EFB模块: Embedded Function Block嵌入式功能块
功能：
1. 提供I2C、SPI、计时器、用户闪存（UFM）等功能。
2. 支持Wishbone总线协议，用于与主控通信。
3. 当前配置中，启用了I2C1接口，其他接口（如SPI、I2C2、计时器）未启用。
---------------------------------------------------------------------------------------------------------------------*/
EFB EFBInst_0 (
    // Wishbone接口，用于与主控通信
    .WBCLKI(wb_clk_i),          // Wishbone 时钟输入
    .WBRSTI(wb_rst_i),          // Wishbone 复位输入
    .WBCYCI(wb_cyc_i),          // Wishbone 总线周期信号
    .WBSTBI(wb_stb_i),          // Wishbone 选通信号
    .WBWEI (wb_we_i),           // Wishbone 写使能信号
    // 地址线8bit
    .WBADRI7(wb_adr_i[7]),      // Wishbone 地址信号位7
    .WBADRI6(wb_adr_i[6]),      // Wishbone 地址信号位6
    .WBADRI5(wb_adr_i[5]),      // Wishbone 地址信号位5
    .WBADRI4(wb_adr_i[4]),      // Wishbone 地址信号位4
    .WBADRI3(wb_adr_i[3]),      // Wishbone 地址信号位3
    .WBADRI2(wb_adr_i[2]),      // Wishbone 地址信号位2
    .WBADRI1(wb_adr_i[1]),      // Wishbone 地址信号位1
    .WBADRI0(wb_adr_i[0]),      // Wishbone 地址信号位0
    // 数据线8bit
    .WBDATI7(wb_dat_i[7]),      // Wishbone 数据输入位7
    .WBDATI6(wb_dat_i[6]),      // Wishbone 数据输入位6
    .WBDATI5(wb_dat_i[5]),      // Wishbone 数据输入位5
    .WBDATI4(wb_dat_i[4]),      // Wishbone 数据输入位4
    .WBDATI3(wb_dat_i[3]),      // Wishbone 数据输入位3
    .WBDATI2(wb_dat_i[2]),      // Wishbone 数据输入位2
    .WBDATI1(wb_dat_i[1]),      // Wishbone 数据输入位1
    .WBDATI0(wb_dat_i[0]),      // Wishbone 数据输入位0
    // 数据线8bit
    .WBDATO7(wb_dat_o[7]),      // Wishbone 数据输出位7
    .WBDATO6(wb_dat_o[6]),      // Wishbone 数据输出位6
    .WBDATO5(wb_dat_o[5]),      // Wishbone 数据输出位5
    .WBDATO4(wb_dat_o[4]),      // Wishbone 数据输出位4
    .WBDATO3(wb_dat_o[3]),      // Wishbone 数据输出位3
    .WBDATO2(wb_dat_o[2]),      // Wishbone 数据输出位2
    .WBDATO1(wb_dat_o[1]),      // Wishbone 数据输出位1
    .WBDATO0(wb_dat_o[0]),      // Wishbone 数据输出位0
    .WBACKO(wb_ack_o),          // Wishbone 应答信号

    // I2C1接口（启用）
    .I2C1SCLI(i2c1_scli),       // I2C1 时钟线输入
    .I2C1SDAI(i2c1_sdai),       // I2C1 数据线输入
    .I2C1SCLO(i2c1_sclo),       // I2C1 时钟线输出
    .I2C1SCLOEN(i2c1_scloen),   // I2C1 时钟线输出使能
    .I2C1SDAO(i2c1_sdao),       // I2C1 数据线输出
    .I2C1SDAOEN(i2c1_sdaoen),   // I2C1 数据线输出使能
    .I2C1IRQO(i2c1_irqo),       // I2C1 中断信号输出

    // I2C2接口（未启用，信号固定为低电平）
    .I2C2SCLI(scuba_vlo),       // I2C2 时钟线输入（未使用）
    .I2C2SDAI(scuba_vlo),       // I2C2 数据线输入（未使用）
    .I2C2SCLO(),                // I2C2 时钟线输出（未使用）
    .I2C2SCLOEN(),              // I2C2 时钟线输出使能（未使用）
    .I2C2SDAO(),                // I2C2 数据线输出（未使用）
    .I2C2SDAOEN(),              // I2C2 数据线输出使能（未使用）
    .I2C2IRQO(),                // I2C2 中断信号输出（未使用）

    // SPI接口（未启用，信号固定为低电平）
    .SPISCKI(scuba_vlo),        // SPI 时钟输入（未使用）
    .SPIMISOI(scuba_vlo),       // SPI MISO 输入（未使用）
    .SPIMOSII(scuba_vlo),       // SPI MOSI 输入（未使用）
    .SPISCSN(scuba_vlo),        // SPI 片选信号（未使用）
    .SPISCKO(),                 // SPI 时钟输出（未使用）
    .SPISCKEN(),                // SPI 时钟输出使能（未使用）
    .SPIMISOO(),                // SPI MISO 输出（未使用）
    .SPIMISOEN(),               // SPI MISO 输出使能（未使用）
    .SPIMOSIO(),                // SPI MOSI 输出（未使用）
    .SPIMOSIEN(),               // SPI MOSI 输出使能（未使用）
    .SPIMCSN7(),                // SPI 片选信号位7（未使用）
    .SPIMCSN6(),                // SPI 片选信号位6（未使用）
    .SPIMCSN5(),                // SPI 片选信号位5（未使用）
    .SPIMCSN4(),                // SPI 片选信号位4（未使用）
    .SPIMCSN3(),                // SPI 片选信号位3（未使用）
    .SPIMCSN2(),                // SPI 片选信号位2（未使用）
    .SPIMCSN1(),                // SPI 片选信号位1（未使用）
    .SPIMCSN0(),                // SPI 片选信号位0（未使用）
    .SPICSNEN(),                // SPI 片选信号使能（未使用）
    .SPIIRQO(),                 // SPI 中断信号输出（未使用）

    // 计时器接口（未启用，信号固定为低电平）
    .TCCLKI(scuba_vlo),         // 计时器时钟输入（未使用）
    .TCRSTN(scuba_vlo),         // 计时器复位信号（未使用）
    .TCIC(scuba_vlo),           // 计时器输入捕获信号（未使用）
    .TCINT(),                   // 计时器中断信号输出（未使用）
    .TCOC(),                    // 计时器输出比较信号（未使用）

    // 用户闪存接口（启用）
    .UFMSN(scuba_vhi),          // 用户闪存信号（高电平）
    .WBCUFMIRQ(wbc_ufm_irq),    // 用户闪存中断信号输出

    // 其他未使用接口
    .CFGWAKE(),                 // 配置唤醒信号（未使用）
    .CFGSTDBY()                 // 配置待机信号（未使用）
);
endmodule
