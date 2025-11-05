module mb_scpld_xregs(
  input            clk   ,
  input            rst   ,
  input      [7:0] i2c_addr    ,
  output reg [7:0] i2c_rdata   ,
  input      [7:0] i2c_wdata   ,
  input            i2c_wdata_en, 
   
  output reg   [7:0] bmc_i2c_data0,
  output reg   [7:0] bmc_i2c_data1,
  output reg   [7:0] bmc_i2c_data2,
  output reg   [7:0] bmc_i2c_data3, 
  output reg   [7:0] bmc_i2c_data4,
  output reg   [7:0] bmc_i2c_data5

);


  always@(posedge clk or posedge rst)
  begin
    if (rst) begin
	  bmc_i2c_data0      <= 8'h00;
      bmc_i2c_data1      <= 8'h01;
      bmc_i2c_data2      <= 8'h02;
      bmc_i2c_data3      <= 8'h03;
      bmc_i2c_data4      <= 8'h04;
      bmc_i2c_data5      <= 8'h05;
    end
    else if (i2c_wdata_en) begin
      case (i2c_addr)
        8'h00: bmc_i2c_data0      <= i2c_wdata;
        8'h01: bmc_i2c_data1      <= i2c_wdata;
        8'h02: bmc_i2c_data2      <= i2c_wdata;
        8'h03: bmc_i2c_data3      <= i2c_wdata;
        8'h04: bmc_i2c_data4      <= i2c_wdata;
        8'h05: bmc_i2c_data5      <= i2c_wdata;

      endcase
    end
end	
     
  always@(*)
  begin
    case(i2c_addr)
      8'h00  : i2c_rdata = bmc_i2c_data0;
      8'h01  : i2c_rdata = bmc_i2c_data1;
      8'h02  : i2c_rdata = bmc_i2c_data2;
      8'h03  : i2c_rdata = bmc_i2c_data3;
      8'h04  : i2c_rdata = bmc_i2c_data4;
      8'h05  : i2c_rdata = bmc_i2c_data5;

    endcase
  end
 
endmodule

