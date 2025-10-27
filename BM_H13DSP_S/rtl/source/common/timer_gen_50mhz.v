

module timer_gen(
  input      clk,               // main clock (50MHz)
  input      reset,             // reset

  output reg t40ns,             //      40ns
  output reg t80ns,             //      80ns
  output reg t160ns,            //     160ns
  output reg t1us,              //       1us
  output reg t2us,              //       2us
  output reg t16us,             //      16us
  output reg t32us,             //      32us
  output reg t128us,            //     128us
  output reg t512us,            //     512us
  output reg t1ms,              //   1.024ms
  output reg t2ms,              //   2.048ms
  output reg t16ms,             //  16.384ms
  output reg t32ms,             //  32.768ms
  output reg t64ms,             //  65.536ms
  output reg t128ms,            // 131.072ms
  output reg t256ms,            // 262.144ms
  output reg t512ms,            // 524.288ms
  output reg t1s,               //   1.049s

  output reg clk_0p5hz,			//0.5Hz
  output reg clk_1hz,           // 1Hz
  output reg clk_2p5hz,         // 2.5Hz
  output reg clk_4hz,           // 4Hz
  output reg clk_16khz,         // 16KHz
  output reg clk_6m25,          //6.25MHz
  output clk_16m6			//16.6MHz
 
);

  reg [2:0] cnt20ns;
  always@(posedge clk or posedge reset)
  begin
    if (reset)
      cnt20ns <= 3'b000;
    else if (cnt20ns==3'b111)
      cnt20ns <= 3'b000;
    else
      cnt20ns <= cnt20ns + 1'b1;
  end

  always@(posedge clk or posedge reset)
  begin
    if (reset) begin
      t40ns  <= 1'b0;
      t80ns  <= 1'b0;
      t160ns <= 1'b0;
    end
    else begin
      if ( cnt20ns[0]  ) t40ns  <= 1'b1; else t40ns  <= 1'b0;
      if (&cnt20ns[1:0]) t80ns  <= 1'b1; else t80ns  <= 1'b0;
      if (&cnt20ns[2:0]) t160ns <= 1'b1; else t160ns <= 1'b0;
    end
  end

  reg   [5:0] nsec_tmr;
  reg   [4:0] usec_tmr;
  reg  [14:0] sec_tmr ;
  reg         t32us_e ;
  wire        t64ms_tick;
  reg   [2:0] t200ms_tmr;

//------------------------------------------------------------------------------
// Generate the timebase reference
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    nsec_tmr <=  6'b0;
    usec_tmr <=  5'b0;
    sec_tmr  <= 15'b0;
  end
  else
  begin
    nsec_tmr <= (nsec_tmr!=6'd49) ? nsec_tmr + 1'b1 : 6'd0;      // counts to 1us
    usec_tmr <= (nsec_tmr==6'd49) ? usec_tmr + 1'b1 : usec_tmr;  // counts 1us, 2^5=32us
    sec_tmr  <= (t32us_e)         ? sec_tmr  + 1'b1 : sec_tmr;   // counts to 32us*2^15=1.048576s
  end
end

always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    t1us    <= 1'b0;
    t2us    <= 1'b0;
    t16us   <= 1'b0;
    t32us_e <= 1'b0;
    t32us   <= 1'b0;
    t128us  <= 1'b0;
    t512us  <= 1'b0;
    t1ms    <= 1'b0;
    t2ms    <= 1'b0;
    t16ms   <= 1'b0;
    t32ms   <= 1'b0;
    t64ms   <= 1'b0;
    t128ms  <= 1'b0;
    t256ms  <= 1'b0;
    t512ms  <= 1'b0;
    t1s     <= 1'b0;
  end
  else
  begin
    t1us    <= (nsec_tmr      ==6'd49);
    t2us    <= (nsec_tmr      ==6'd49) & ( usec_tmr[0]);
    t16us   <= (nsec_tmr      ==6'd49) & (&usec_tmr[3:0]);
    t32us_e <= (nsec_tmr      ==6'd48) & (&usec_tmr[4:0]);  // 1-clk early to t32us
    t32us   <= t32us_e;
    t128us  <= t32us_e & (&sec_tmr[1:0]);   //     128us  =32*4
    t512us  <= t32us_e & (&sec_tmr[3:0]);   //     512us  =32*16
    t1ms    <= t32us_e & (&sec_tmr[4:0]);   //   1.024ms  =32*32
    t2ms    <= t32us_e & (&sec_tmr[5:0]);   //   2.048ms  =32*64
    t16ms   <= t32us_e & (&sec_tmr[8:0]);   //  16.384ms  =32*512
    t32ms   <= t32us_e & (&sec_tmr[9:0]);   //  32.768ms  =32*1024
    t64ms   <= t32us_e & (&sec_tmr[10:0]);  //  65.536ms  =32*2048
    t128ms  <= t32us_e & (&sec_tmr[11:0]);  // 131.072ms  =32*4096
    t256ms  <= t32us_e & (&sec_tmr[12:0]);  // 262.144ms  =32*8192
    t512ms  <= t32us_e & (&sec_tmr[13:0]);  // 524.288ms  =32*16384
    t1s     <= t32us_e & (&sec_tmr[14:0]);  //   1.049s   =32*32768
  end
end


//------------------------------------------------------------------------------
// 50% duty cycle clocks
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    clk_0p5hz <= 1'b0;
    clk_1hz   <= 1'b0;
    clk_4hz   <= 1'b0;
    clk_16khz <= 1'b0;
    clk_6m25  <= 1'b0;
  end
  else
  begin
    clk_0p5hz <= (t1s	) ? ~clk_0p5hz : clk_0p5hz;
    clk_1hz   <= (t512ms) ? ~clk_1hz   : clk_1hz;
    clk_4hz   <= (t128ms) ? ~clk_4hz   : clk_4hz;
    clk_16khz <= (t32us)  ? ~clk_16khz : clk_16khz;
    clk_6m25  <= (t80ns)  ? ~clk_6m25  : clk_6m25;
  end
end





//clk_16m6 is clk/3 Hz = 16.6MHz
/*************************************************/
// clk         = |-|_|-|_|-|_|-|_
// clk_16m6_q1 = |--|____|--|____
// clk_16m6_q2 = _|--|____|--|____
// clk_16m6	   = |---|___|---|___|---|___|---|
/*************************************************/
reg clk_16m6_q1;
reg clk_16m6_q2;                
reg [1:0] clk_16m6_q1_count;
reg [1:0] clk_16m6_q2_count;

assign clk_16m6	=	clk_16m6_q1|clk_16m6_q2;  

always @ (posedge clk or posedge reset) // |--|____|--|____
begin
    if (reset)
    begin
      clk_16m6_q1		<=	1'b0;
      clk_16m6_q1_count	<=	2'b00;
	end
    else if(clk_16m6_q1_count==1'b0)
    begin
       clk_16m6_q1			<=	~clk_16m6_q1;
       clk_16m6_q1_count	<=	clk_16m6_q1_count+1'b1;
    end
    else if(clk_16m6_q1_count==1'b1)
    begin
       clk_16m6_q1 			<= 	~clk_16m6_q1;
       clk_16m6_q1_count	<=	clk_16m6_q1_count+1'b1;
     end
       else 
         begin
         clk_16m6_q1_count<=2'b00;
         end
end
       
always @ (negedge clk or posedge reset)//_|--|____|--|____
begin 
    if (reset)
    begin
      clk_16m6_q2		<=	1'b0;
      clk_16m6_q2_count	<=	2'b00;
	end
    else if(clk_16m6_q2_count==1'b0)
    begin
		clk_16m6_q2			<=	~clk_16m6_q2;
		clk_16m6_q2_count	<=	clk_16m6_q2_count+1'b1;
    end
    else if(clk_16m6_q2_count==1'b1)
    begin
		clk_16m6_q2			<=	~clk_16m6_q2;
		clk_16m6_q2_count	<=	clk_16m6_q2_count+1'b1;
	end
	else 
		begin
		clk_16m6_q2_count	<=	2'b00;
		end
end
      









// Generate 2.5Hz clock. This is not a multiple of any of the ticks so need some
// special handling by generating a 200ms. This occurs every 3 t64ms tick.
assign t64ms_tick = t32us_e & (&sec_tmr[10:0]);

always@(posedge clk or posedge reset)
begin
  if (reset)
  begin
    t200ms_tmr <= 3'b001;
    clk_2p5hz  <= 1'b0;
  end
  else
  begin
    t200ms_tmr <= (t64ms_tick) ? {t200ms_tmr[1:0], t200ms_tmr[2]} : t200ms_tmr;
    clk_2p5hz  <= (t64ms_tick && t200ms_tmr[2]) ? ~clk_2p5hz : clk_2p5hz;
  end
end

endmodule

