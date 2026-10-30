
module minisoc_aes_sub_bytes (
    input  logic [127:0] state_i,
    output logic [127:0] state_o
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_sbox

            minisoc_aes_sbox u_sbox (
                .data_i (state_i[127 - 8*i -: 8]),
                .data_o (state_o[127 - 8*i -: 8])
            );

        end
    endgenerate

endmodule
