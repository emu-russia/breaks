// Тестовая программа на Verilog

module or_latch;

    input a, b;
    output out;

    wire a, b;
    reg out;

    always @* begin
        out = a | b;
    end

endmodule

module test;

    input CLK;
    output a, b;
    reg a, b;

    always @ (CLK) begin
        a = CLK;
        b = 1; 
    end

endmodule

