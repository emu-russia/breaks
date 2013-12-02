// Тестовая программа на Verilog

// Пока мы модули не используем, будем считать что мы уже внутри модуля.
module (bla,bla,bla) test;

    parameter DUMMY = 1, NBIT = 4+4;
    input CLK;
    output dout;

    wire a, b, c;
    wire [7:0] ___busa;
    wire [0:9] busb;
    reg [NBIT-1:0] dout;

    reg MYREG2;

    always @ (CLK)
        dout2 = dout2 + 1;        // бинарный плюс
        dout2 = -dout;       // унарный минус
    end

endmodule


module test2;

    parameter DUMMY = 2, DUMMY = 55, ZBIT=33-11;

endmodule

module bla;
endmodule

