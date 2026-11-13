
module minisoc_aes_key_exp (
    input  logic [127:0]  key_i,
    output logic [1407:0] round_keys_o
);

    // 44 palavras de 32 bits para AES-128
    logic [31:0] w [0:43];

    // Constantes de rodada
    function automatic logic [7:0] rcon(input int round);

        case (round)
            1:  rcon = 8'h01;
            2:  rcon = 8'h02;
            3:  rcon = 8'h04;
            4:  rcon = 8'h08;
            5:  rcon = 8'h10;
            6:  rcon = 8'h20;
            7:  rcon = 8'h40;
            8:  rcon = 8'h80;
            9:  rcon = 8'h1b;
            10: rcon = 8'h36;
            default: rcon = 8'h00;
        endcase

    endfunction

    // As primeiras quatro palavras formam a chave original
    assign w[0] = key_i[127:96];
    assign w[1] = key_i[95:64];
    assign w[2] = key_i[63:32];
    assign w[3] = key_i[31:0];

    // Geracao das dez chaves seguintes
    for (genvar r = 1; r <= 10; r++) begin : gen_rounds

        logic [31:0] sub_rot;

        // RotWord + SubWord
        minisoc_aes_sbox u_sbox0 (
            .data_i (w[4*r-1][23:16]),
            .data_o (sub_rot[31:24])
        );

        minisoc_aes_sbox u_sbox1 (
            .data_i (w[4*r-1][15:8]),
            .data_o (sub_rot[23:16])
        );

        minisoc_aes_sbox u_sbox2 (
            .data_i (w[4*r-1][7:0]),
            .data_o (sub_rot[15:8])
        );

        minisoc_aes_sbox u_sbox3 (
            .data_i (w[4*r-1][31:24]),
            .data_o (sub_rot[7:0])
        );

        // Primeira palavra da rodada
        assign w[4*r] =
            w[4*r-4] ^ sub_rot ^ {rcon(r), 24'h000000};

        // Demais palavras da rodada
        assign w[4*r+1] = w[4*r-3] ^ w[4*r];
        assign w[4*r+2] = w[4*r-2] ^ w[4*r+1];
        assign w[4*r+3] = w[4*r-1] ^ w[4*r+2];

    end

    // Organizacao das 11 chaves em um barramento
    for (genvar k = 0; k < 11; k++) begin : gen_keys

        assign round_keys_o[1407 - 128*k -: 128] = {
            w[4*k],
            w[4*k+1],
            w[4*k+2],
            w[4*k+3]
        };

    end

endmodule
