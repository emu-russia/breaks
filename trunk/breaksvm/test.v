// Тестовая программа на Verilog

// Пока мы модули не используем, будем считать что мы уже внутри модуля.
//module test;

    // проверка многосимвольных операций.


 ! != !==

 = == ===

 & && = &x
 
 | || = |x

 ^ ^~ =^x =^~x

 ~ ~^ ~| ~& =~^x =~|x =~^x
    

    parameter DUMMY = 1, NBIT = 4;
    input CLK;

    wire a, b, c;
    wire [7:0] ___busa;
    wire [0:9] busb;
    wand vectored [7:0] andbus;
    reg [NBIT-1:0] dout;
    trireg [7:0] treg;

    reg MYREG2;

    always @ (CLK)
        MYREG2 = MYREG2 + 1;        // бинарный плюс
        MYREG2 = -MYREG2;       // унарный минус
    end

//endmodule
