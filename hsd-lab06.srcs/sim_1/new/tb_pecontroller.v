`timescale 1ns / 1ps

module tb_pecontroller #(
	parameter L_RAM_SIZE = 6
);
	reg clk;
	reg aresetn;
	reg [31:0] globalbuff[31:0];
	wire [L_RAM_SIZE-1:0] rdaddr;
	wire [31:0] rddata;
	wire [31:0] dout;
	wire done;
    
	reg start;
    
	initial begin
    	globalbuff[0] <= 32'h00000000;
    	globalbuff[1] <= 32'h3f800000;
    	globalbuff[2] <= 32'h40000000;
    	globalbuff[3] <= 32'h40400000;
    	globalbuff[4] <= 32'h40800000;
    	globalbuff[5] <= 32'h40a00000;
    	globalbuff[6] <= 32'h40c00000;
    	globalbuff[7] <= 32'h40e00000;
    	globalbuff[8] <= 32'h41000000;
    	globalbuff[9] <= 32'h41100000;
    	globalbuff[10]<= 32'h41200000;
    	globalbuff[11]<= 32'h41300000;
    	globalbuff[12]<= 32'h41400000;
    	globalbuff[13]<= 32'h41500000;
    	globalbuff[14]<= 32'h41600000;
    	globalbuff[15]<= 32'h41700000;
   	 
    	globalbuff[16] <= 32'h3f800000;
    	globalbuff[17] <= 32'h40000000;
    	globalbuff[18] <= 32'h40400000;
    	globalbuff[19] <= 32'h40800000;
    	globalbuff[20] <= 32'h40a00000;
    	globalbuff[21] <= 32'h40c00000;
    	globalbuff[22] <= 32'h40e00000;
    	globalbuff[23] <= 32'h41000000;
    	globalbuff[24] <= 32'h41100000;
    	globalbuff[25] <= 32'h41200000;
    	globalbuff[26] <= 32'h41300000;
    	globalbuff[27] <= 32'h41400000;
    	globalbuff[28] <= 32'h41500000;
    	globalbuff[29] <= 32'h41600000;
    	globalbuff[30] <= 32'h41700000;
    	globalbuff[31] <= 32'h41800000;
   	 
    	clk <= 0;
    	aresetn <= 1;
    	#8;
    	aresetn <= 0;
    	#20;
    	aresetn <= 1;
    	start <= 1;
    	#10;
    	start <= 0;    
	end
    
	assign rddata = globalbuff[rdaddr];
    
	my_controller MPC(
    	.clk(clk),
    	.rst(~aresetn),
    	.start(start),
    	.rddata(rddata),
    	.rdaddr(rdaddr),
    	.done(done),
    	.out(dout)
	);
    
	always #5 clk = ~clk;
    
endmodule


