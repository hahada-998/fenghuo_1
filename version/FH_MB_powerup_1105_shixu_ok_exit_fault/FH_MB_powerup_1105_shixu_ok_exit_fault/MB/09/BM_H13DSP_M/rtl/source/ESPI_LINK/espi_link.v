module espi_link(
input      ESPI_CLK,
input      ESPI_RST,
input      ESPI_CS1,
input      ESPI_IO_IN,
output     ESPI_IO_OUT,
//output     ALERT1,
output   reg[15:0]    pch_addr,
output   reg[7:0]     pch_smbus_wdata,
input    [7:0]        pch_smbus_rdata,
output   reg          pch_smbus_wdata_en, //20220315
output   [7:0]        debug_flag,
output   [7:0]        debug_flag1,
output   [63:0]       debug_flag2
);
localparam            IDLE                 = 8'h00;
localparam            OPCODE               = 8'h01;
localparam            GET_STATUS           = 8'h02;
localparam            GET_CONFIGURATION    = 8'h03;
localparam            SET_CONFIGURATION    = 8'h04;
localparam            ADDR_RD              = 8'h05;
localparam            DATA_RD              = 8'h06;
localparam            DATA_WR              = 8'h07;
localparam            RESP_WAIT            = 8'h08;
localparam            RESP_ACCEPT          = 8'h09;
localparam            STS                  = 8'h0a;
localparam            CRC_1                = 8'h0b;
localparam            CRC_2                = 8'h0c;
localparam            TAR                  = 8'h0d;
localparam            CRC_ERR              = 8'h0e;
localparam            GET_VWIRE            = 8'h0f;
localparam            VWIRE_DATA_WR        = 8'h10;
localparam            VWIRE_LENGTH         = 8'h11;
localparam            PUT_VWIRE            = 8'h12;
localparam            VWIRE_DATA_RD        = 8'h13;
localparam            PUT_OOB              = 8'h14;
localparam            GET_OOB              = 8'h15;
localparam            OOB_MSG              = 8'h16;
localparam            OOB_TAG              = 8'h17;
localparam            OOB_LENGTH           = 8'h18;
localparam            OOB_DATA_RD          = 8'h19;
localparam            OOB_DATA_WR          = 8'h1a;
localparam            PUT_IORD_SHORT       = 8'h1b;
localparam            PUT_IOWR_SHORT       = 8'h1c;
localparam            SHORT_WR             = 8'h1d;
localparam            SHORT_RD             = 8'h1e;
reg      [3:0]        clk_cnt;//for state transfer  
reg                   trans_cnt1;
reg      [2:0]        trans_cnt2,trans_cnt3,trans_cnt4;
reg      [3:0]        trans_cnt5,trans_cnt6;
reg                   st_trans_en,addr_trans_en,data_trans_en,sts_trans_en,tar_trans_en,vwire_wr_trans_en,vwire_rd_trans_en,oob_data_trans_en,io_wr_trans_en,io_rd_trans_en,send_start;//flag of state
reg                   get_status_en,get_config_en,set_config_en,get_vwire_en,put_vwire_en,get_oob_en,put_oob_en,put_iowr_short_en,put_iord_short_en;
reg      [7:0]        current_state,next_state;
reg      [7:0]        data_byte_in,data_byte_out;//8 bit data of 8 clk buff
reg      [7:0]        crc_check;   //CRC check result
reg                   crc_enable;
//reg      [1:0]        io_mode;  // 00:single io mode; 01:dual io mode;    10:reservd;  11:quad io mode
reg      [15:0]       io_addr;
reg      [7:0]        pch_addr_buff;
reg      [31:0]       io_data_in,io_data_out;
reg      [31:0]       io_data_out_buff;
reg      [63:0]       state_save;
reg      [7:0]        vwire_length,oob_data_length,oob_data_length_buff,vwire_length_buff;


assign  ESPI_IO_OUT = (~ESPI_CS1) ? data_byte_out[7] : 1'bz;   //single IO mode data out 
assign  debug_flag  = current_state;//(5'b0,get_status_en,get_config_en,set_config_en);
assign  debug_flag1 = {5'b0,get_status_en,get_config_en,set_config_en};
assign  debug_flag2 = state_save;

always @ (posedge ESPI_CLK or negedge ESPI_RST) begin
    if (!ESPI_RST) begin
	    state_save[7:0]  <= IDLE;
		state_save[63:8] <= 56'b0;
    end
	else if (current_state != state_save[7:0])
        state_save  <= {state_save[55:0],current_state};
end

always @ (posedge ESPI_CLK or negedge ESPI_RST or posedge ESPI_CS1) begin
    if (!ESPI_RST || ESPI_CS1) begin
	    current_state  <= IDLE;
    end
	else begin
	    current_state  <= next_state;
	end
end

always @ (posedge ESPI_CLK or negedge ESPI_RST or posedge ESPI_CS1) begin
    data_byte_in[7:0]  <= {data_byte_in[6:0],ESPI_IO_IN};   //data read for 8 bit
    if (!ESPI_RST) begin
	    pch_addr           <= 16'h0000;
	    data_byte_in       <= 8'h00;
	    pch_smbus_wdata    <= 8'h00;
	    pch_smbus_wdata_en <= 1'b0; //20220315
	end
	else if (ESPI_CS1) begin
	    data_byte_in         <= 8'h00;
	    io_addr              <= 16'h0000;
	    // pch_addr_buff        <= 8'h00;
	    oob_data_length_buff <= 8'h00;
	    vwire_length_buff    <= 8'h00; 
	end
	else if (st_trans_en && (current_state == ADDR_RD))
	    io_addr  <= {io_addr[7:0],data_byte_in[7:0]};    //date read for 16 bit of address
	else if (st_trans_en && (current_state == DATA_RD))   
	    io_data_in[31:0]  <= {io_data_in[23:0],data_byte_in[7:0]};  //date read for 32 bit of set config data
    else if (st_trans_en && (current_state == SHORT_RD)) begin
	    if(io_addr == 16'h1500) pch_addr[7:0] <= data_byte_in[7:0];
	    else if(io_addr == 16'h1501) pch_addr[15:8] <= data_byte_in[7:0];
	    else if(io_addr == 16'h1502) begin pch_smbus_wdata_en <= 1'b1; pch_smbus_wdata[7:0] <= data_byte_in[7:0];end //20220315
end
/*    else if (st_trans_en && (current_state == SHORT_RD))
       pch_addr_buff  <= data_byte_in[7:0]; */
	else if (st_trans_en && (current_state == OOB_LENGTH))  //data write for 16 bit of state
	    oob_data_length_buff <= data_byte_in[7:0];
    else if (st_trans_en && (current_state == VWIRE_LENGTH))  //data write for 16 bit of state
        vwire_length_buff    <= data_byte_in[7:0];
	else pch_smbus_wdata_en  <= 1'b0; // 20220315
end

always @ (negedge ESPI_CLK or negedge ESPI_RST or posedge ESPI_CS1) begin   //why negedge ESPI_CLK   20230207
    data_byte_out   <= {data_byte_out[6:0],1'b1};    //data write for  8 bit
    if(!ESPI_RST || ESPI_CS1) begin
	    data_byte_out <= 8'hff; 
	    io_data_out   <= 32'hffffffff;
	end
    else if (send_start) begin
	    data_byte_out     <= io_data_out_buff[31:24];
	    io_data_out[31:8] <= io_data_out_buff[23:0];
    end
	else if (st_trans_en && (next_state == DATA_WR)) begin  //data write for 32 bit of get config data
        data_byte_out     <= io_data_out[31:24];
        io_data_out       <= {io_data_out[23:0],8'hff};
    end
	else if (st_trans_en && (next_state == STS)) begin   //data write for 16 bit of state
	    data_byte_out     <= io_data_out[31:24];
	    io_data_out       <= {io_data_out[23:0],8'hff};
	end
end	
	
	
always @ (posedge ESPI_CLK or negedge ESPI_RST or posedge ESPI_CS1) begin	
	if(!ESPI_RST || ESPI_CS1) begin
	    clk_cnt       <= 4'b0000;
		st_trans_en   <= 1'b0;
	    tar_trans_en  <= 1'b0;
	    trans_cnt1    <= 1'b0;
	    trans_cnt2    <= 1'b0;
		data_trans_en <= 1'b0;
		trans_cnt3    <= 3'b000;
	    trans_cnt4    <= 3'b000;
		trans_cnt5    <= 3'b000;
		trans_cnt6    <= 3'b000;
		vwire_wr_trans_en  <= 1'b0;
	    vwire_rd_trans_en  <= 1'b0;
		oob_data_trans_en  <= 1'b0;
		addr_trans_en      <= 1'b0;
		sts_trans_en       <= 1'b0;
		io_wr_trans_en     <= 1'b0;
		io_rd_trans_en     <= 1'b0;
	end
	else if ((next_state == TAR) && (clk_cnt == 4'b0001)) begin
	    tar_trans_en <= 1'b1;
		clk_cnt      <= 4'b0000;
	end
	else if (clk_cnt == 4'b0111) begin
	    st_trans_en  <= 1'b1;
		clk_cnt      <= 4'b0000;
	    if((current_state == DATA_RD) || (current_state == DATA_WR)) begin
		    if (trans_cnt2 == 3'b011) begin
			    data_trans_en <= 1'b1;
				trans_cnt2    <= 3'b000;
			end
			else begin
			    trans_cnt2    <= trans_cnt2 + 1'b1;
				data_trans_en <= 1'b0;
			end
        end
		else if (current_state == VWIRE_DATA_WR) begin
		    if(trans_cnt4 == 3'b010) begin
			    vwire_wr_trans_en  <= 1'b1;
				trans_cnt4         <= 3'b000;
			end
		    else begin
			    trans_cnt4         <= trans_cnt4 + 1'b1;
				vwire_wr_trans_en  <= 1'b0;
		    end
		end
		else if (current_state == VWIRE_DATA_RD) begin
		if(trans_cnt5 == ((vwire_length_buff+1)*2-1)) begin
		    vwire_rd_trans_en      <= 1'b1;  
            trans_cnt5             <= 3'b000;
		end
		else begin
		    trans_cnt5             <= trans_cnt5 + 1'b1;
			vwire_rd_trans_en      <= 1'b0;
		end
		end
		else if (current_state == OOB_MSG) begin
		if(trans_cnt6 == (oob_data_length-1)) begin
		    oob_data_trans_en      <= 1'b1;
			trans_cnt6             <= 3'b000;
		end
		else begin
		    trans_cnt6             <= trans_cnt6 + 1'b1;
			oob_data_trans_en      <= 1'b0;
		end
		end
		else if (current_state == ADDR_RD) begin
		if(trans_cnt1 == 1'b1) begin
		    addr_trans_en         <= 1'b1;  
			trans_cnt1            <= 1'b0; 
		end
		else begin
		    trans_cnt1            <= trans_cnt1 + 1'b1;
			addr_trans_en         <= 1'b0; 
		end
		end
		else if (current_state == STS) begin
		if(trans_cnt3 == 3'b001) begin
		    sts_trans_en          <= 1'b1;
			trans_cnt3            <= 3'b000;
	    end
		else begin
		    trans_cnt3            <= trans_cnt3 + 1'b1;
		    sts_trans_en          <= 1'b0;
		end
		end
		else if (current_state == SHORT_WR)
		    io_wr_trans_en        <= 1'b1;
		else if (current_state == SHORT_RD)
		    io_rd_trans_en        <= 1'b1;
	end
	else begin
	    clk_cnt        <= clk_cnt + 1'b1;
		st_trans_en    <= 1'b0;
		tar_trans_en   <= 1'b0;
		io_rd_trans_en <= 1'b0;
		io_wr_trans_en <= 1'b0;
	end
end	
always @ (*) begin		
    next_state = current_state;
	send_start = 1'b0;
	crc_enable = 1'b0;
	crc_check  = 1'b1;
	io_data_out_buff = 32'hffffffff;
	case(current_state)
	    IDLE:begin
		    crc_enable = 1'b0;
			crc_check  = 1'b1;
			io_data_out_buff = 32'hffffffff;
			if(!ESPI_CS1)
			    next_state = OPCODE;
			end
		OPCODE:begin
		    io_data_out_buff[31:24] = 8'hff;
		    if(st_trans_en) begin
			    if(data_byte_in == 8'h21) begin
				    next_state = GET_CONFIGURATION;
				end
				else if(data_byte_in == 8'h22) begin
				    next_state = SET_CONFIGURATION;
				end
				else if(data_byte_in == 8'h25) begin
				    next_state = GET_STATUS;
				end
				else if(data_byte_in == 8'h05) begin
				    next_state = GET_VWIRE;
				end
				else if(data_byte_in == 8'h04) begin
				    next_state = PUT_VWIRE;
				end
				else if(data_byte_in == 8'h06) begin
				    next_state = PUT_OOB;
				end
				else if(data_byte_in == 8'h07) begin
				    next_state = GET_OOB;
				end
				else if(data_byte_in == 8'h44) begin
				    next_state = PUT_IOWR_SHORT;
				end			
				else if(data_byte_in == 8'h40) begin
				    next_state = PUT_IORD_SHORT;
				end
				else next_state = IDLE;
			end 
		end
		GET_CONFIGURATION:begin
		    next_state = ADDR_RD;
			io_data_out_buff[31:24] = 8'hff;
		end
		SET_CONFIGURATION:begin
		    next_state = ADDR_RD;
			io_data_out_buff[31:24] = 8'hff;
		end
        GET_STATUS:begin
		    next_state = CRC_1;
			io_data_out_buff[31:24] = 8'hff;
		end
		GET_VWIRE:begin
		    next_state = CRC_1;
			io_data_out_buff[31:24] = 8'hff;
		end
		PUT_VWIRE:begin
		    next_state = VWIRE_LENGTH;
			io_data_out_buff[31:24] = 8'hff;
		end	
		PUT_OOB:begin
		    next_state = OOB_TAG;
			io_data_out_buff[31:24] = 8'hff;
		end	
		GET_OOB:begin
		    next_state = OOB_TAG;
			io_data_out_buff[31:24] = 8'hff;
		end	
		OOB_TAG:begin
		    if(st_trans_en) begin
		        next_state = OOB_LENGTH;
			    io_data_out_buff[31:24] = 8'hff;
		    end	
		end
		OOB_LENGTH: begin
		    if(st_trans_en) begin
			    if(put_oob_en) begin
				    next_state = OOB_MSG;
					io_data_out_buff[31:24] = 8'hff;
				end 
				else if(get_oob_en) begin
				    next_state = CRC_1;  
		            io_data_out_buff[31:24] = 8'hff;
				end
			end 
		end 
		OOB_MSG: begin
		    if(oob_data_trans_en) begin
			    if(put_oob_en) begin
				    next_state = CRC_1;
					io_data_out_buff[31:24] = 8'hff;
				end
				else if (get_oob_en) begin
				    next_state = STS;
					io_data_out_buff[31:16] = 16'h0403;
				end
			end 
		end
		VWIRE_LENGTH: begin
		    if(st_trans_en) begin
			    next_state = VWIRE_DATA_RD;
				io_data_out_buff[31:24] = 8'hff;
			end
		end 
		VWIRE_DATA_RD: begin
		    if(vwire_rd_trans_en) begin
			    next_state = CRC_1;
				io_data_out_buff[31:24] = 8'hff;
			end
		end 
		
		PUT_IOWR_SHORT:begin
		    next_state = ADDR_RD;
		    io_data_out_buff[31:24] = 8'hff;
		end
		PUT_IORD_SHORT:begin
		    next_state = ADDR_RD;
		    io_data_out_buff[31:24] = 8'hff;
		end
		ADDR_RD: begin
		    io_data_out_buff[31:24] = 8'hff;
			if(addr_trans_en) begin
			    if(get_config_en | put_iord_short_en) begin
				    next_state = CRC_1;
				end
				else if(set_config_en) begin
				    next_state = DATA_RD;
				end
				else if (put_iowr_short_en) begin
				    next_state = SHORT_RD;
				end
			end
		end
		DATA_RD: begin
		    io_data_out_buff[31:24] = 8'hff;
			if(data_trans_en) begin
			    next_state = CRC_1;
			end
		end
		SHORT_RD:begin
		    io_data_out_buff[31:24] = 8'hff;
			if(io_rd_trans_en) begin
			    next_state = CRC_1;
/* 				if(io_addr == 16'h1500) pch_addr[7:0] = pch_addr_buff[7:0];
				else if(io_addr == 16'h1501) pch_addr[15:8] = pch_addr_buff[7:0];
				else if(io_addr == 16'h1502) pch_smbus_wdata[7:0] = pch_addr_buff[7:0];
				 */
		    end
		end
		CRC_1:begin
		    io_data_out_buff[31:24] = 8'hff;
			if(st_trans_en && (!crc_enable)) begin
			    next_state = TAR;
			end
			else if (st_trans_en && crc_enable) begin
			    if(data_byte_in == crc_check) begin
				    next_state = TAR;
				end
				else begin
				    next_state = CRC_ERR; 
				end
			end
		end
		TAR: begin
		    if(tar_trans_en) begin
			    next_state = RESP_WAIT;
			    io_data_out_buff[31:24] = 8'h0f;
				send_start = 1'b1;
			end 
		end
		RESP_WAIT:begin
		    if(st_trans_en) begin
			    next_state = RESP_ACCEPT;
				io_data_out_buff[31:24] = 8'h08;
				send_start = 1'b1;
			end
		end
		RESP_ACCEPT:begin
		    if(st_trans_en) begin
		        if(get_config_en) begin
				    next_state = DATA_WR;
					if(io_addr == 16'h0008) io_data_out_buff = 32'h0f000010;//32'h0f000c03;
					if(io_addr == 16'h0010) io_data_out_buff = 32'h13110000;//32'h0f000c03;
					if(io_addr == 16'h0020) io_data_out_buff = 32'h03000700;//32'h03070700;
					if(io_addr == 16'h0030) io_data_out_buff = 32'h13010000;
					if(io_addr == 16'h0040) io_data_out_buff = 32'h0c110000;
					send_start = 1'b1;
				end
				else if(set_config_en || get_status_en) begin
				    next_state = STS;
			        if(io_addr == 16'h0010)
					    io_data_out_buff[31:16] = 16'h0703;
					else if(io_addr == 16'h0020)
					    io_data_out_buff[31:16] = 16'h4401;
					else 
					    io_data_out_buff[31:16] = 16'h0c01;
					send_start = 1'b1;
				end
				else if (put_vwire_en) begin
				    next_state = STS;
					io_data_out_buff[31:16] = 16'h0703;
					send_start = 1'b1;
				end
	    		else if (put_iowr_short_en) begin
	    			next_state = STS;
	    			io_data_out_buff[31:16] = 16'h0703;
	    			send_start = 1'b1;
	    		end
	    		else if (put_iord_short_en) begin
	    			next_state = SHORT_WR;
	    		    io_data_out_buff[31:24] = pch_smbus_rdata[7:0];
	    			send_start = 1'b1;
	    		end 
	    		
	    		else if (get_vwire_en) begin
	    		    next_state = VWIRE_DATA_WR;
	    			io_data_out_buff[31:8] = 24'h000599;
	    			send_start = 1'b1;
	    		end 
	    		else if (put_oob_en) begin
	    		    next_state = STS;
	    		    io_data_out_buff[31:16] = 16'h0403;
	    			send_start = 1'b1;
	    		end
	    		else if (get_oob_en) begin
	    		    next_state = OOB_MSG;
	    		    io_data_out_buff[31:8] = 24'h000599;//debug
	    			send_start = 1'b1;
	    		end
	    	end
	    end
		VWIRE_DATA_WR:begin
		    if(vwire_wr_trans_en) begin
			    next_state = STS;
			    io_data_out_buff[31:16] = 16'h0401;
				send_start = 1'b1;
			end 
		end
		SHORT_WR: begin
		    if(io_wr_trans_en) begin
			    next_state = STS; 
			    io_data_out_buff[31:16] = 16'h0703;
				send_start = 1'b1;
			end 
		end
		DATA_WR:begin
		    if(data_trans_en) begin
			    next_state = STS; 
		        io_data_out_buff[31:16] = 16'h0401;
				send_start = 1'b1;
			end 
		end
		
		STS:begin
		    if(sts_trans_en) begin
			    next_state = CRC_2;
		        io_data_out_buff[31:24] = 8'hff;
				send_start = 1'b1;
			end
		end
		CRC_2: begin
		    if(st_trans_en && (!crc_enable)) begin
			    next_state = IDLE;
			end
            else if(st_trans_en && crc_enable) begin	
			    if(data_byte_in == crc_check) begin
				    next_state = IDLE;
				end
				else begin
				    next_state = CRC_ERR;
				end
			end
		end
		default: begin
            next_state = IDLE;
		end
	endcase
end
always @ (posedge ESPI_CLK or negedge ESPI_RST or posedge ESPI_CS1) begin	
	if(!ESPI_RST || ESPI_CS1) begin
	    get_status_en     <= 1'b0;
		get_config_en     <= 1'b0;
		set_config_en     <= 1'b0;
        get_vwire_en      <= 1'b0;
        put_vwire_en      <= 1'b0;
		get_oob_en        <= 1'b0;
		put_oob_en        <= 1'b0;
		put_iowr_short_en <= 1'b0;
		put_iord_short_en <= 1'b0;
		vwire_length      <= 8'h00;
		oob_data_length   <= 8'h00;
	end
    else begin
    case(current_state)
        IDLE:begin
            get_status_en     <= 1'b0;
            get_config_en     <= 1'b0;
            set_config_en     <= 1'b0;
            get_vwire_en      <= 1'b0;
            put_vwire_en      <= 1'b0;
            get_oob_en        <= 1'b0;
            put_oob_en        <= 1'b0;
            put_iowr_short_en <= 1'b0;
            put_iord_short_en <= 1'b0;
			vwire_length      <= 8'h00;
			oob_data_length   <= 8'h00;	
		end
        OPCODE: begin
        end
        GET_CONFIGURATION: begin
		    get_config_en     <= 1'b1;
		end
		SET_CONFIGURATION: begin
		    set_config_en     <= 1'b1;
		end
		GET_STATUS: begin
		    get_status_en     <= 1'b1;
		end
		GET_VWIRE: begin
		    get_vwire_en      <= 1'b1;
		end
		PUT_VWIRE: begin
		    put_vwire_en      <= 1'b1;
		end
		PUT_OOB: begin
		    put_oob_en        <= 1'b1;
		end
		GET_OOB: begin
		    get_oob_en        <= 1'b1;
		end
		OOB_TAG: begin
		end
		OOB_LENGTH: begin
		    oob_data_length   <= oob_data_length_buff;
		end
		OOB_MSG: begin
		end
		VWIRE_LENGTH: begin
		    vwire_length      <= vwire_length_buff;
		end
		VWIRE_DATA_RD: begin
		end
		
		PUT_IOWR_SHORT: begin
		    put_iowr_short_en <= 1'b1;
		end
		PUT_IORD_SHORT: begin
		    put_iord_short_en <= 1'b1;
		end
		ADDR_RD: begin
		end
		DATA_RD: begin
		end
		SHORT_RD: begin
/* 		
		    if(io_addr == 16'h1500) pch_addr[7:0] <= pch_addr_buff[7:0];
			else if(io_addr == 16'h1501) pch_addr[15:8] <= pch_addr_buff[7:0];
			else if(io_addr == 16'h1502) pch_smbus_wdata[7:0] <= pch_addr_buff[7:0];
		 */
		end
		CRC_1: begin
		end
		TAR: begin
		end
		RESP_WAIT: begin
		end
		RESP_ACCEPT: begin
		end
		VWIRE_DATA_WR: begin
		end
		SHORT_WR: begin
		end
		DATA_WR: begin
		end
		STS: begin
		end
		CRC_2:begin
		end
		default: begin
		
		end
	endcase
	end
end
endmodule