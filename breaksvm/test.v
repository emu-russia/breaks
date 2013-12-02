// Тестовая программа на Verilog

// Пока мы модули не используем, будем считать что мы уже внутри модуля.
module (bla,bla,bla) test;

    parameter DUMMY = 1, NBIT = 4+4;
    input CLK;
    output dout;

    wire a, b, c;
    wire [7:0] ___busa;
    wire [0:9] busb;
    reg [=NBIT-1:2] dout [12];      ///  пока только так выражения вычисляются, нужно переделать evaluate() немного.

    reg [0:3] MYREG2;

    always @ (CLK)
        MYREG2 = MYREG2 + 1;        // бинарный плюс
        MYREG2 = -MYREG2;       // унарный минус
    end

endmodule


module test2;

    parameter DUMMY = 2, ZBIT=33-11;

endmodule

module bla;
endmodule

