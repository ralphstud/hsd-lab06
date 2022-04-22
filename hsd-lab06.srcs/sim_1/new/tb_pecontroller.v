`timescale 1ns / 1ps

module tb_pecontroller();

    //for PE_CONTROLLER
    reg INIT;
    reg CLK;
    reg RST;
    reg [31:0] MAT [15:0];
    reg [31:0] VEC [15:0];
    reg [31:0] RDDATA;
    wire [31:0] WRDATA;
    wire [3:0] ADDR;
    wire DONE;

    //for test

    integer i;

    initial begin
        CLK <= 1;
        INIT <= 0;
        RST <= 0;
        #10;
        INIT <= 1;
        MAT[0] = 32'h00000000;
        MAT[1] = 32'h3f800000;
        MAT[2] = 32'h40000000; 
        MAT[3] = 32'h40400000; 
        MAT[4] = 32'h40800000;
        MAT[5] = 32'h40a00000;
        MAT[6] = 32'h40c00000;
        MAT[7] = 32'h40e00000;
        MAT[8] = 32'h41000000;
        MAT[9] = 32'h41100000;
        MAT[10] = 32'h41200000;
        MAT[11] = 32'h41300000;
        MAT[12] = 32'h41400000;
        MAT[13] = 32'h41500000;
        MAT[14] = 32'h41600000;
        MAT[15] = 32'h41700000;
        VEC[0] = 32'h3f800000; 
        VEC[1] = 32'h40000000;
        VEC[2] = 32'h40400000; 
        VEC[3] = 32'h40800000; 
        VEC[4] = 32'h40a00000;
        VEC[5] = 32'h40c00000;
        VEC[6] = 32'h40e00000;
        VEC[7] = 32'h41000000;
        VEC[8] = 32'h41100000;
        VEC[9] = 32'h41200000;
        VEC[10] = 32'h41300000;
        VEC[11] = 32'h41400000;
        VEC[12] = 32'h41500000;
        VEC[13] = 32'h41600000;
        VEC[14] = 32'h41700000;
        VEC[15] = 32'h41800000;
        for (i = 0; i < 16; i = i + 1) begin
            RDDATA <= MAT[i];
            #10;
            RDDATA <= VEC[i];
        end
    end
    
    always #5 CLK = ~CLK;

    my_controller #(8,4) CTRL (
        .start(INIT),
        .done(DONE),
        .aclk(CLK),
        .aresetn(RST),
        .rdaddr(ADDR),
        .rddata(RDDATA),
        .wrdata(WRDATA)
    );

endmodule