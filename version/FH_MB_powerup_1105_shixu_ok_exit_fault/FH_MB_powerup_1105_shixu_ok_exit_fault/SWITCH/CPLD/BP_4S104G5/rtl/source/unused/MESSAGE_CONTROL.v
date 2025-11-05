
//---------------------------------------------------------------------------
//-----                                                                 -----
//-----                 ENTITY DECLARATION                              -----
//-----                                                                 -----
//---------------------------------------------------------------------------

module MESSAGE_CONTROL (
	//Inputs
	input reset_n,			//Active loew reset signal
	input clk,			//External Crystal Oscillator clock
	input sw,			//External momentary switch used to freeze output
	//Outputs
	output reg normal_operation	//Communicate to user logic the normal operation

);

//----------------------------------------------------------------------------
//                                                                          --
//                       ARCHITECTURE DEFINITION                            --
//                                                                          --
//----------------------------------------------------------------------------
//------------------------------
// INTERNAL SIGNAL DECLARATIONS: 
//------------------------------
// parameters (constants)

// wires (assigns)


// regs (always)
// Register declaration
reg switch_detect;		//Detect the falling edge of the switch
reg resume_normal;		//Resume normal operation after certain delay
reg [7:0] cnt;			//Counter used to delay the normal operation
reg sw_reg;			//Use to register the Async Switch SW
reg sw_reg_d;			//Delayed version of this switch SW


//Cnt register
always @ (posedge clk or negedge reset_n) begin
   if  (reset_n == 1'b0) begin
      cnt  <= 0; 
   end
   else if(!resume_normal) cnt <= cnt + 1'b1; 		//Start counting as soon as reset is released
   else		           cnt <= cnt;
end

//Resume normal operation (Used to delay the normal operation)
always @ (posedge clk or negedge reset_n) begin
    if  (reset_n == 1'b0) begin
      resume_normal  <= 0; 
    end
    else if(cnt == 8'b1000_0111) resume_normal <= 1'b1; 
    else 			 resume_normal <= resume_normal;
end 

// sw_reg ---> registering the Switch
always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)	sw_reg <= 1'b0; 
    else 			sw_reg <= sw;
end 

//Delayed version of the sw_reg
always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)	sw_reg_d <= 1'b0; 
    else 			sw_reg_d <= sw_reg;
end   

//Switch Detect Register 
always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)	switch_detect <= 1'b0; 
    else if(~sw_reg & sw_reg_d) switch_detect <= 1'b1; 			//Detecting falling edge of switch 
    else 			switch_detect <= switch_detect;
end 

/********  Switch to enable/disable the Normal Operation mode, can be controlled by an on board master (Microcontroller/Program)  ******/
//Normal Operation signal
always @ (posedge clk or negedge reset_n) begin
    if  (reset_n == 1'b0) begin
       normal_operation <= 1'b0;
    end
    else if(switch_detect) 	normal_operation <= 1'b0; 		//Capture the falling edge of switch to hold value
    else if(resume_normal) 	normal_operation <= 1'b1;		//Resume normal operation
    else 			normal_operation <= normal_operation;
end

endmodule 
