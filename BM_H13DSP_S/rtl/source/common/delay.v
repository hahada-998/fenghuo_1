

//`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
//          Delay
//////////////////////////////////////////////////////////////////////////////////
module delay # //% Parameterizable Delay Module
(
                                //% Total count
    parameter                   COUNT  =   1
)
(
                                //% Clock Input
    input                   iClk,
                                //% Asynchronous Reset Input
    input                   iRst,
                                //% Start Delay Input Signal
    input                   iStart,
                                //% Clear Count signal 
    input                   iClrCnt,
                                //% Done Flag Output
    output                  oDone
);

   
localparam TOTAL_BITS = clog2(COUNT);

reg                     rDone;
reg [(TOTAL_BITS-1):0]  rCount;

always @(posedge iClk or negedge iRst)
begin
	if (~iRst) begin						//Reset
		rDone   <=   1'b0;					//Done flag
		rCount  <=   {TOTAL_BITS{1'b0}};	//Counter
	end
	else begin
		if(~iStart || iClrCnt) begin		//If iStart is LOW or iClrCnt is HIGH, output goes low as well
			rDone	<= 1'b0;
			rCount	<= {TOTAL_BITS{1'b0}};
		end
		else if (COUNT-1 > rCount) begin	//Output set as high when counter reaches expected value
			rDone	<= 1'b0;
			rCount	<= rCount + 1'b1;
		end
		else begin							//Output low and counter increases if no conditions were met
			rDone	<= 1'b1;
			rCount	<= rCount;
		end
	end
end

assign oDone = rDone;
//base 2 logarithm, run in precompile stage
function integer clog2;
input integer value;
begin
   value = (value > 1) ? value-1 : 1;            //this avoids clog returning 0, which would cause issues 
   for (clog2=0; value>0; clog2=clog2+1)
     value = value>>1;
end

endfunction

endmodule
