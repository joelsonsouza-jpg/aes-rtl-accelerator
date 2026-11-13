
module minisoc_aes_inv_mix_columns (
    input  logic [127:0] state_i,
    output logic [127:0] state_o
);

    // Multiplicacao no campo finito GF(2^8)
    function automatic logic [7:0] gf_mul (
        input logic [7:0] a,
        input logic [7:0] b
    );
        logic [7:0] p;
        logic [7:0] x;
        logic [7:0] y;

        p = 8'h00;
        x = a;
        y = b;

        for (int k = 0; k < 8; k++) begin
            if (y[0])
                p = p ^ x;

            x = x[7] ? (x << 1) ^ 8'h1b : (x << 1);
            y = y >> 1;
        end

        return p;
    endfunction

    // Processamento das quatro colunas em paralelo
    for (genvar c = 0; c < 4; c++) begin : gen_columns

        logic [7:0] a0, a1, a2, a3;

        assign {a0, a1, a2, a3} =
            state_i[127 - 32*c -: 32];

        assign state_o[127 - 32*c -: 32] = {
            gf_mul(a0, 8'h0e) ^ gf_mul(a1, 8'h0b) ^
            gf_mul(a2, 8'h0d) ^ gf_mul(a3, 8'h09),

            gf_mul(a0, 8'h09) ^ gf_mul(a1, 8'h0e) ^
            gf_mul(a2, 8'h0b) ^ gf_mul(a3, 8'h0d),

            gf_mul(a0, 8'h0d) ^ gf_mul(a1, 8'h09) ^
            gf_mul(a2, 8'h0e) ^ gf_mul(a3, 8'h0b),

            gf_mul(a0, 8'h0b) ^ gf_mul(a1, 8'h0d) ^
            gf_mul(a2, 8'h09) ^ gf_mul(a3, 8'h0e)
        };

    end

endmodule
