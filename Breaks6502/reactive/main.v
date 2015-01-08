
module a (a_out, value);

input value;
output wire a_out;

reg a_reg;
assign a_out = a_reg;

always @(*) begin
    a_reg = value;
end

endmodule

module b (b_out, value);

input value;
output wire b_out;

reg b_reg;
assign b_out = b_reg;

always @(*) begin
    b_reg = value;
end

endmodule

module TestBench ;

    reg b_out;
    wire a_out, wb_out;
    
    LATCH AInst (a_out, b_out);
    LATCH BInst (wb_out, a_out);

    always #1 b_out <= ~b_out;

endmodule