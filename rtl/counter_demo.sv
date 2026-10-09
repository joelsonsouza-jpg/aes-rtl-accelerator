// Exemplo DIDATICO para validar o ambiente. NAO e o nucleo AES.
`timescale 1ns/1ps
module counter_demo (
    input  logic       clk_i,
    input  logic       rst_ni,
    input  logic       en_i,
    output logic [3:0] count_o
);
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            count_o <= 4'd0;
        else if (en_i)
            count_o <= count_o + 4'd1;
    end
endmodule
