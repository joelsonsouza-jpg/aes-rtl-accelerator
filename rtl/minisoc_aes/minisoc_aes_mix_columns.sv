
module minisoc_aes_mix_columns (
    input  logic [127:0] state_i,
    output logic [127:0] state_o
);

    // Multiplicacao por 02 no campo GF(2^8)
    function automatic logic [7:0] xtime(
        input logic [7:0] x
    );
        xtime = {x[6:0], 1'b0} ^
                (x[7] ? 8'h1b : 8'h00);
    endfunction

    // Processa as quatro colunas em paralelo
    for (genvar c = 0; c < 4; c++) begin : gen_columns

        logic [7:0] a0, a1, a2, a3;

        // Quatro bytes da coluna
        assign {a0, a1, a2, a3} =
            state_i[127 - 32*c -: 32];

        // Transformacao MixColumns
        assign state_o[127 - 32*c -: 32] = {
            xtime(a0) ^ (xtime(a1) ^ a1) ^ a2 ^ a3,
            a0 ^ xtime(a1) ^ (xtime(a2) ^ a2) ^ a3,
            a0 ^ a1 ^ xtime(a2) ^ (xtime(a3) ^ a3),
            (xtime(a0) ^ a0) ^ a1 ^ a2 ^ xtime(a3)
        };

    end

endmodule
