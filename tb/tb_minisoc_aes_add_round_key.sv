
module tb_minisoc_aes_add_round_key;

    logic [127:0] state_i;
    logic [127:0] round_key_i;
    logic [127:0] state_o;

    minisoc_aes_add_round_key dut (
        .state_i     (state_i),
        .round_key_i (round_key_i),
        .state_o     (state_o)
    );

    task automatic check(
        input logic [127:0] state,
        input logic [127:0] key,
        input logic [127:0] expected
    );
        state_i     = state;
        round_key_i = key;

        #1
        if (state_o !== expected) begin
            $display("ERRO: AddRoundKey");
            $display("Esperado: %032h", expected);
            $display("Obtido:   %032h", state_o);
            $fatal(1, "Falha no teste");
        end
    endtask

    initial begin

        // Teste 1: XOR com zero
        check(128'h0, 128'h0, 128'h0);

        // Teste 2: Valores iguais
        check(
            128'hffffffffffffffffffffffffffffffff,
            128'hffffffffffffffffffffffffffffffff,
            128'h00000000000000000000000000000000
        );

        // Teste 3: Valores diferentes
        check(
            128'h00112233445566778899aabbccddeeff,
            128'h000102030405060708090a0b0c0d0e0f,
            128'h00102030405060708090a0b0c0d0e0f0
        );

        $display("PASS: AddRoundKey - 3 testes validados");
        $finish;

    end

endmodule
