module my_pe #(
    parameter L_RAM_SIZE = 6
)
(
    // clk/reset
    input aclk,
    input aresetn,
    // port A
    input [31:0] ain,
    // port B
    input [31:0] din,
    // input [L_RAM_SIZE-1:0] addr,
    // integrated valid signal
    input valid,
    // computation result
    output dvalid,
    output [31:0] dout
);

    reg [31:0] Psum;
    wire [31:0] result;

    assign dout = result;
    floating_point_myfusedmult UUT(
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_a_tvalid(valid),
        .s_axis_b_tvalid(valid),
        .s_axis_c_tvalid(valid),
        .s_axis_a_tdata(ain),
        .s_axis_b_tdata(din),
        .s_axis_c_tdata(Psum),
        .m_axis_result_tvalid(dvalid),
        .m_axis_result_tdata(result)
    );

    always @(posedge valid) begin
        Psum = result;
    end

    always @(negedge aresetn) begin
        if (!aresetn) Psum = 0;
    end

endmodule