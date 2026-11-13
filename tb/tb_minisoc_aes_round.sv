
module tb_minisoc_aes_round;

    timeunit 1ns;
    timeprecision 1ps;

    logic [127:0] state_i;
    logic [127:0] mix_o;
    logic [127:0] round_key_i;
    logic [127:0] add_o;
    logic [127:0] inv_shift_o;
    logic [127:0] inv_sub_o;
    logic [127:0] inv_mix_o;

    // Sinais para teste exaustivo de SubBytes/InvSubBytes
    logic [127:0] test_sub_i;
    logic [127:0] test_sub_o;
    logic [127:0] test_inv_sub_o;

    // Transformacao MixColumns
    minisoc_aes_mix_columns u_mix (
        .state_i (state_i),
        .state_o (mix_o)
    );

    // Transformacao AddRoundKey
    minisoc_aes_add_round_key u_add (
        .state_i     (mix_o),
        .round_key_i (round_key_i),
        .state_o     (add_o)
    );

    // Transformacao InvShiftRows
    minisoc_aes_inv_shift_rows u_inv_shift (
        .state_i (state_i),
        .state_o (inv_shift_o)
    );

    // Transformacao InvSubBytes
    minisoc_aes_inv_sub_bytes u_inv_sub (
        .state_i (inv_shift_o),
        .state_o (inv_sub_o)
    );

    // Transformacao InvMixColumns
    minisoc_aes_inv_mix_columns u_inv_mix (
        .state_i (mix_o),
        .state_o (inv_mix_o)
    );

    // SubBytes para teste de reversibilidade
    minisoc_aes_sub_bytes u_sub_test (
        .state_i (test_sub_i),
        .state_o (test_sub_o)
    );

    // InvSubBytes aplicado a saida de SubBytes
    minisoc_aes_inv_sub_bytes u_inv_sub_test (
        .state_i (test_sub_o),
        .state_o (test_inv_sub_o)
    );

    initial begin

        // Rodada 1 - FIPS 197, Apendice B
        state_i = 128'hd4bf5d30e0b452aeb84111f11e2798e5;
        round_key_i = 128'ha0fafe1788542cb123a339392a6c7605;
        test_sub_i = 128'h0;

        #1
        if (mix_o !== 128'h046681e5e0cb199a48f8d37a2806264c)
            $fatal(1, "FAIL: MixColumns - rodada 1");

        $display("PASS: MixColumns - rodada 1");

        if (inv_mix_o !== state_i)
            $fatal(1, "FAIL: InvMixColumns - rodada 1");

        $display("PASS: InvMixColumns - rodada 1");

        if (inv_shift_o !== 128'hd42711aee0bf98f1b8b45de51e415230)
            $fatal(1, "FAIL: InvShiftRows - rodada 1");

        $display("PASS: InvShiftRows - rodada 1");

        if (inv_sub_o !== 128'h193de3bea0f4e22b9ac68d2ae9f84808)
            $fatal(1, "FAIL: InvSubBytes - rodada 1");

        $display("PASS: InvSubBytes - rodada 1");

        if (add_o !== 128'ha49c7ff2689f352b6b5bea43026a5049)
            $fatal(1, "FAIL: AddRoundKey - rodada 1");

        $display("PASS: AddRoundKey - rodada 1");

        // Teste adicional: estado nulo
        state_i = 128'h0;
        round_key_i = 128'h0;

        #1
        if (mix_o !== 128'h0 ||
            inv_mix_o !== 128'h0 ||
            add_o !== 128'h0)
            $fatal(1, "FAIL: teste com estado nulo");

        $display("PASS: teste com estado nulo");

        // Teste exaustivo de reversibilidade da S-box
        for (int i = 0; i < 256; i++) begin

            test_sub_i = {16{8'(i)}};

            #1
            if (test_inv_sub_o !== test_sub_i)
                $fatal(1,
                    "FAIL: InvSubBytes - byte %02h",
                    8'(i));

        end
        $display("PASS: InvSubBytes - 256 valores verificados");


        // Teste adicional de reversibilidade do MixColumns
        for (int i = 0; i < 256; i++) begin

            // Gera 16 bytes com valores variados
            for (int b = 0; b < 16; b++) begin
                state_i[127 - 8*b -: 8] =
                    8'(i + 17*b + 3*b*b);
            end

            #1
            if (inv_mix_o !== state_i)
                $fatal(1,
                    "FAIL: InvMixColumns - padrao %0d",
                    i);

        end

        $display("PASS: InvMixColumns - 256 padroes verificados");




        $display("PASS: Testes iniciais da Semana 3");

        $finish;

    end

endmodule
