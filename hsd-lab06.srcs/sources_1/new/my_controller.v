`timescale 1ns / 1ps

module my_controller#(
	parameter L_RAM_SIZE = 6
	)
	(
	input clk,
	input rst,
	input start,
	input [31:0] rddata,
	output [L_RAM_SIZE-1:0] rdaddr,
	output done,
	output [31:0] out
	);
    
	reg [1:0] present_state, next_state;
	reg [5:0] countL;
	reg [8:0] countC;
	reg [2:0] count5;
	reg counter_rstL;
	reg counter_rstC;
	reg counter_rst5;
	reg pe_en;
	reg rdvalid;
	wire [31:0] ain;
	wire [31:0] bin;
	wire [L_RAM_SIZE-1:0] addr;
	wire valid;
	wire dvalid;
	wire [31:0] dout;
	reg [31:0] globalbuff [31:0];
       
	localparam S_IDLE = 4'd0, S_LOAD = 4'd1, S_CALC = 4'd2, S_DONE = 4'd3;
	
	always @(posedge clk)
	   if (present_state == S_LOAD) globalbuff[addr] <= rddata;
    
	always @(posedge clk or posedge counter_rstL)
    	if (counter_rstL) countL <= 0;
    	else countL <= countL +1;
	always @(posedge clk or posedge counter_rstC)
    	if (counter_rstC) countC <= 0;
    	else if (dvalid == 1) countC <= countC; 
        else countC <= countC +1;   	 
	always @(posedge clk or posedge counter_rst5)
    	if (counter_rst5) count5 <= 0;
    	else count5 <= count5 +1;
    	
    //part 1: initialize state, update present_state
	always @(posedge clk or posedge rst) begin
    	if (rst) present_state <= S_IDLE;
    	else present_state <= next_state;
	end
    //part 2: determine next state
	always @(*) 
    	case(present_state)
        	S_IDLE: if (start) next_state = S_LOAD; else next_state = present_state;
        	S_LOAD: if (countL == 32) next_state = S_CALC; else next_state = present_state;
        	S_CALC: if (countC == 256) next_state = S_DONE; else next_state = present_state;
        	S_DONE: if (count5 == 4) next_state = S_IDLE; else next_state = present_state;
        	//default: next_state = S_IDLE;
    	endcase
    //part 3: evaluate
	always @(*) begin
    	case (present_state)
        	S_CALC: counter_rstC = 0;
        	default: counter_rstC = 1;
    	endcase
	end
    
	always @(*) begin
    	case (present_state)
        	S_LOAD: counter_rstL = 0;
        	default: counter_rstL = 1;
    	endcase
	end
    
	always @(*) begin
    	case (present_state)
        	S_DONE: counter_rst5 = 0;
        	default: counter_rst5 = 1;
    	endcase
	end
    
	always @(*) begin
    	case (present_state)
        	S_IDLE: pe_en = 0;
        	default: pe_en = 1;
    	endcase
	end
	
	always @(posedge clk)
	   if (rst) rdvalid <= 0;
	   else rdvalid <= dvalid;
    
	assign rdaddr = (next_state == S_LOAD)? countL : 'd0;
	assign addr = (next_state == S_CALC)? (countC >> 4) : rdaddr;
    
	assign ain = (next_state == S_CALC)? globalbuff[addr] : 'd0;
	assign bin = (next_state == S_CALC)? globalbuff[addr+16] : 'd0;
	
	assign valid = ((present_state == S_LOAD && next_state == S_CALC) || rdvalid);
	assign done =  next_state == S_DONE;
	
	assign out = done? dout : 'd0;
	
	my_pe #(
    	.L_RAM_SIZE(L_RAM_SIZE)
	) u_pe (
    	.aclk(clk),
    	.aresetn(~rst && (present_state != S_DONE)),
    	.ain(ain),
    	.bin(bin),
    	.valid(valid),
    	.dvalid(dvalid),
    	.dout(dout)
	);
    
endmodule

