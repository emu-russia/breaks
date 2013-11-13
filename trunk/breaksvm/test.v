// Тестовая программа на Verilog

module test;

    parameter DUMMY = 1;
    input CLK;
    wire a, b, c;
    reg MYREG;

    always @ (CLK)
        MYREG = MYREG ^ 1;
    end

endmodule
