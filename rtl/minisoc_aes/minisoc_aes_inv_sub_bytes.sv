
module minisoc_aes_inv_sub_bytes (
    input  logic [127:0] state_i,
    output logic [127:0] state_o
);

    // S-box inversa da FIPS 197
    function automatic logic [7:0] inv_sbox (
        input logic [7:0] data
    );
        logic [127:0] sbox_row;

        case (data[7:4])
            4'h0: sbox_row = 128'h52096ad53036a538bf40a39e81f3d7fb;
            4'h1: sbox_row = 128'h7ce339829b2fff87348e4344c4dee9cb;
            4'h2: sbox_row = 128'h547b9432a6c2233dee4c950b42fac34e;
            4'h3: sbox_row = 128'h082ea16628d924b2765ba2496d8bd125;
            4'h4: sbox_row = 128'h72f8f66486689816d4a45ccc5d65b692;
            4'h5: sbox_row = 128'h6c704850fdedb9da5e154657a78d9d84;
            4'h6: sbox_row = 128'h90d8ab008cbcd30af7e45805b8b34506;
            4'h7: sbox_row = 128'hd02c1e8fca3f0f02c1afbd0301138a6b;
            4'h8: sbox_row = 128'h3a9111414f67dcea97f2cfcef0b4e673;
            4'h9: sbox_row = 128'h96ac7422e7ad3585e2f937e81c75df6e;
            4'ha: sbox_row = 128'h47f11a711d29c5896fb7620eaa18be1b;
            4'hb: sbox_row = 128'hfc563e4bc6d279209adbc0fe78cd5af4;
            4'hc: sbox_row = 128'h1fdda8338807c731b11210592780ec5f;
            4'hd: sbox_row = 128'h60517fa919b54a0d2de57a9f93c99cef;
            4'he: sbox_row = 128'ha0e03b4dae2af5b0c8ebbb3c83539961;
            4'hf: sbox_row = 128'h172b047eba77d626e169146355210c7d;
            default: sbox_row = 128'h0;
        endcase

        inv_sbox = sbox_row[127 - (8 * data[3:0]) -: 8];

    endfunction

    // Aplica a S-box inversa aos 16 bytes em paralelo
    for (genvar i = 0; i < 16; i++) begin : gen_inv_sub
        assign state_o[127 - 8*i -: 8] =
            inv_sbox(state_i[127 - 8*i -: 8]);
    end

endmodule
