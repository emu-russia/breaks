// Тестовая программа на Verilog

module test;

    parameter DUMMY = 1, NBIT = 4;
    input CLK;

    wire a, b, c;
    wire [7:0] busa;
    wire [0:9] busb;
    wand vectored [7:0] andbus;
    reg [NBIT-1:0] dout;
    trireg [7:0] treg;

    reg MYREG;

    always @ (CLK)
        MYREG = MYREG ^ 1;
    end

endmodule
