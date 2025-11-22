module pwrbtn
(
  input		ipoweronoff,			//negedge triger;
  input		iforcepowerdown5p1s,	//0=20ms pulse,1=5.1s pulse;
  output	opowerbtn, 				//output pwrbtn to cpu

  input		iClk_50M,
  input		iRst_n//,
//  input		iSlpS4_n
);

// `include "pkg.vh"
parameter   HIGH  = 1'b1;      
parameter   LOW   = 1'b0;  
parameter   T_5S_50M     =  32'd250_000_000;
parameter   T_20MS_50M   =  32'd1_000_000;	


reg rpoweronoff;
reg rpoweronoff_negedge;

wire wPoweronoffdelay20ms;
wire wPoweronoffdelay5p1s;
wire wPoweronoffdelay;

/*///check s4 change////////////
reg S4_s0;
reg S4_s1;
wire S4_change;
always @ (posedge iClk_2M or negedge iRst_n)
	begin
		if ( !iRst_n)
			begin
				S4_s0 	<= LOW;	
				S4_s1 	<= LOW;	
			end
		else 
			begin
				S4_s0 	<= iSlpS4_n;
				S4_s1 	<= S4_s0;
			end
	end
assign S4_change = (S4_s1 != S4_s0) ? 1'b1:1'b0;
//////////////////////////////////////////////////*/

always @ (posedge iClk_50M or negedge iRst_n)
	begin
		if ( !iRst_n)
			begin
				rpoweronoff 	<= HIGH;	
			end
		else 
			begin
				rpoweronoff 	<= ipoweronoff;

			end
	end

always @( posedge iClk_50M or negedge iRst_n  ) 
	begin 
		if  (!iRst_n | ipoweronoff)  
			begin
				rpoweronoff_negedge		<= LOW;
			end

		else begin
				rpoweronoff_negedge		<= (rpoweronoff && !ipoweronoff) ? 1'b1: rpoweronoff_negedge;

		end 
	end 

//delay for 20ms  from rpoweronoff_negedge 
genCntr #(  .MAX_COUNT(T_20MS_50M)  ) pwrbtn_count_20ms  //  
	(
	.oCntDone       (  wPoweronoffdelay20ms  ),           // This is high when MAX_COUNT is reached   
	
	.iClk           (iClk_50M), 
	.iRst_n         (iRst_n),		               
	.iCntEn         (rpoweronoff_negedge),	                  
	.iCntRst_n      (rpoweronoff_negedge),
	.oCntr          ( /*empty*/   )
	);
//delay for 5S  from rpoweronoff_negedge 
genCntr #(  .MAX_COUNT(T_5S_50M)  ) pwrbtn_count_5p1s  //  
	(
	.oCntDone       (  wPoweronoffdelay5p1s  ),           // This is high when MAX_COUNT is reached   
	
	.iClk           (iClk_50M), 
	.iRst_n         (iRst_n),		               
	.iCntEn         (rpoweronoff_negedge),	                  
	.iCntRst_n      (rpoweronoff_negedge),
	.oCntr          ( /*empty*/   )
	);

assign wPoweronoffdelay = iforcepowerdown5p1s ? wPoweronoffdelay5p1s : wPoweronoffdelay20ms;

assign opowerbtn = (ipoweronoff | wPoweronoffdelay) ? 1'b1:1'b0;


endmodule
