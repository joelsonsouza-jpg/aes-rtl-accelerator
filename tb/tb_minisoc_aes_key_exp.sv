
module tb_minisoc_aes_key_exp;

    timeunit 1ns;
    timeprecision 1ps;

    logic [127:0] key_i;
    logic [1407:0] round_keys_o;
    logic [1407:0] expected_keys;

    // Modulo de expansao de chave
    minisoc_aes_key_exp dut (
        .key_i        (key_i),
        .round_keys_o (round_keys_o)
    );

    initial begin

        // FIPS 197 - Apendice C.1
        key_i = 128'h000102030405060708090a0b0c0d0e0f;

        // Onze chaves de rodada esperadas
        expected_keys = {
            128'h000102030405060708090a0b0c0d0e0f,
            128'hd6aa74fdd2af72fadaa678f1d6ab76fe,
            128'hb692cf0b643dbdf1be9bc5006830b3fe,
            128'hb6ff744ed2c2c9bf6c590cbf0469bf41,
            128'h47f7f7bc95353e03f96c32bcfd058dfd,
            128'h3caaa3e8a99f9deb50f3af57adf622aa,
            128'h5e390f7df7a69296a7553dc10aa31f6b,
            128'h14f9701ae35fe28c440adf4d4ea9c026,
            128'h47438735a41c65b9e016baf4aebf7ad2,
            128'h549932d1f08557681093ed9cbe2c974e,
            128'h13111d7fe3944a17f307a78b4d2b30c5
        };

        // Verificacao das 11 chaves
        #1
        for (int r = 0; r < 11; r++) begin

            if (round_keys_o[1407 - 128*r -: 128] !==
                expected_keys[1407 - 128*r -: 128]) begin

                $display("Rodada %0d", r);

                $display("Obtido:   %032h",
                    round_keys_o[1407 - 128*r -: 128]);

                $display("Esperado: %032h",
                    expected_keys[1407 - 128*r -: 128]);

                $fatal(1, "FAIL: Key Expansion");

            end

        end

        $display("PASS: Key Expansion AES-128 - 11 round keys");

        // FIPS 197 - Apendice B
        key_i = 128'h2b7e151628aed2a6abf7158809cf4f3c;

        // Verificacao da chave inicial
        #1
        if (round_keys_o[1407 -: 128] !==
            128'h2b7e151628aed2a6abf7158809cf4f3c)
            $fatal(1, "FAIL: chave inicial - Apendice B");

        // Verificacao da ultima chave
        if (round_keys_o[127:0] !==
            128'hd014f9a8c9ee2589e13f0cc8b6630ca6)
            $fatal(1, "FAIL: chave final - Apendice B");

        $display("PASS: Key Expansion - Apendice B");

        $display("PASS: Testes da expansao de chave");

        $finish;

    end

endmodule
