module my_controller#(
    parameter VECTOR_SIZE = 4,
    parameter L_RAM_SIZE = 6
)
(
    input start,
    output done,
    input aclk,
    input aresetn,
    output [L_RAM_SIZE-1:0] rdaddr,
    input [31:0] rddata,
    output reg [31:0] wrdata
);

    wire [31:0] ain;
    wire [31:0] din;
    wire valid;
    wire dvalid;
    wire [31:0] dout;
    wire [L_RAM_SIZE-1:0] addr;
    wire we_global;
    wire we_local;

    // Global buffer
    reg [31:0] gdout;
    (* ram_style = "block" *)
    reg [31:0] globalmem [0:2**VECTOR_SIZE - 1];

    always @(posedge aclk)
        if (we_global)
            globalmem[addr] <= rddata;
        else
            gdout <= globalmem[addr];

    // FSM
    wire load_done;
    wire calc_done;
    wire done_done;

    reg [3:0] curr_state, next_state;

    localparam S_IDLE = 4'd0;
    localparam S_LOAD = 4'd1;
    localparam S_CALC = 4'd2;
    localparam S_DONE = 4'd3;

    always @(posedge aclk)
        if (!aresetn)
            next_state <= S_IDLE;
        else
            case (next_state)
                S_IDLE: next_state <= (start)? S_LOAD : S_IDLE;
                S_LOAD: next_state <= (load_done)? S_CALC : S_LOAD;
                S_CALC: next_state <= (calc_done)? S_DONE : S_CALC;
                S_DONE: next_state <= (done_done)? S_IDLE : S_DONE;
                default: next_state <= S_IDLE;
            endcase
 
    always @(posedge aclk)
        if (!aresetn)
            curr_state <= S_IDLE;
        else
            curr_state <= next_state;

    // COUNTER
    reg [VECTOR_SIZE+1:0] counter;
    wire counter_load_init = (curr_state == S_IDLE) && (next_state == S_LOAD);
    wire counter_en = (next_state == S_LOAD) || dvalid || (next_state == S_DONE);

    localparam N_LOAD = 2**(VECTOR_SIZE+2) - 1;
    localparam N_CALC = 2**VECTOR_SIZE - 1;
    localparam N_DONE = 5 - 1;

    // Counter behavior
    always @(posedge aclk)
        if (!aresetn)
            counter <= 'd0;
        else if (counter_load_init)
            counter <= N_LOAD;
        else if (load_done)
            counter <= N_CALC;
        else if (calc_done)
            counter <= N_DONE;
        else if (counter_en)
            counter <= counter - 1;

    // WE signal assignment
    assign we_local = (curr_state == S_LOAD && counter[L_RAM_SIZE-1])? 'd1 : 'd0;
    assign we_global = (curr_state == S_LOAD && next_state == S_LOAD && !counter[L_RAM_SIZE-1])? 'd1 : 'd0;

    // Drop the bits after VECTOR_SIZE'th position so that both global & local buffer get the same addr value
    assign rdaddr = (next_state == S_LOAD)? {{(L_RAM_SIZE-VECTOR_SIZE){'b0}}, counter[VECTOR_SIZE-1:0]} : 'd0;
    assign addr = (next_state == S_CALC)? counter : rdaddr;

    // Pass the data from global buffer to ain & rddata to din
    assign ain = (next_state == S_CALC)? globalmem[addr] : 'd0;
    assign din = (curr_state == S_LOAD)? rddata: 'd0;

    // valid signal assignment
    assign valid = ((curr_state == S_LOAD && next_state == S_CALC) || dvalid);

    // State done signals
    assign load_done = curr_state == S_LOAD && counter == 'd0;
    assign calc_done = curr_state == S_CALC && counter == 'd0 && dvalid;
    assign done_done = curr_state == S_DONE && counter == 'd0;

    // Final done signal
    assign done = next_state == S_DONE;

    // Pass the calculation result when the state is S_DONE
    always @(posedge aclk)
        if (!aresetn)
            wrdata <= 'd0;
        else if (calc_done)
            wrdata <= dout;
        else
            wrdata <= wrdata;

    my_pe #(
        .L_RAM_SIZE(L_RAM_SIZE)
    ) MP (
        .aclk(aclk),
        .aresetn(aresetn && (state != S_DONE)),
        .ain(ain),
        .din(din),
        .addr(addr),
        .we(we_local),
        .valid(valid),
        .dvalid(dvalid),
        .dout(dout)
    );

endmodule