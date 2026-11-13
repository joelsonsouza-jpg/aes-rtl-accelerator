
module tb_minisoc_aes_dp;

    timeunit 1ns;
    timeprecision 1ps;

    logic clk;
    logic rst_n;
    logic start_i;
    logic decrypt_i;

    logic [127:0] data_i;
    logic [127:0] key_i;
    logic [127:0] data_o;

    logic busy_o;
    logic done_o;

    // Datapath AES-128
    minisoc_aes_dp dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .start_i   (start_i),
        .decrypt_i (decrypt_i),
        .data_i    (data_i),
        .key_i     (key_i),
        .data_o    (data_o),
        .busy_o    (busy_o),
        .done_o    (done_o)
    );

    // Clock de periodo 10 ns
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Executa uma operacao AES-128
    task automatic run_test (
        input string test_name,
        input logic [127:0] test_key,
        input logic [127:0] test_data,
        input logic [127:0] expected,
        input logic decrypt
    );

        int cycles;

        begin

            // Aplica os dados na borda de descida
            @(negedge clk) begin
                key_i     = test_key;
                data_i    = test_data;
                decrypt_i = decrypt;
                start_i   = 1'b1;
            end

            // Desativa o comando de inicio
            @(negedge clk) start_i = 1'b0;

            cycles = 0;

            // Aguarda a conclusao da operacao
            while (done_o !== 1'b1) begin

                @(negedge clk) cycles++;

                if (cycles >= 20)
                    $fatal(1,
                        "FAIL: Timeout - %s",
                        test_name);

            end

            // Compara o resultado obtido
            if (data_o !== expected) begin

                $display("Teste:    %s", test_name);
                $display("Obtido:   %032h", data_o);
                $display("Esperado: %032h", expected);

                $fatal(1, "FAIL: AES-128");

            end

            $display("PASS: %s", test_name);

        end

    endtask

    initial begin

        rst_n     = 1'b0;
        start_i   = 1'b0;
        decrypt_i = 1'b0;
        data_i    = '0;
        key_i     = '0;

        // Mantem o reset durante dois ciclos
        @(negedge clk) rst_n = 1'b0;
        @(negedge clk) rst_n = 1'b1;

        // ======================================
        // FIPS 197 - Apendice C.1
        // ======================================

        run_test(
            "AES-128 Encrypt - FIPS 197 C.1",
            128'h000102030405060708090a0b0c0d0e0f,
            128'h00112233445566778899aabbccddeeff,
            128'h69c4e0d86a7b0430d8cdb78070b4c55a,
            1'b0
        );

        run_test(
            "AES-128 Decrypt - FIPS 197 C.1",
            128'h000102030405060708090a0b0c0d0e0f,
            128'h69c4e0d86a7b0430d8cdb78070b4c55a,
            128'h00112233445566778899aabbccddeeff,
            1'b1
        );

        // ======================================
        // FIPS 197 - Apendice B
        // ======================================

        run_test(
            "AES-128 Encrypt - FIPS 197 B",
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h3243f6a8885a308d313198a2e0370734,
            128'h3925841d02dc09fbdc118597196a0b32,
            1'b0
        );

        run_test(
            "AES-128 Decrypt - FIPS 197 B",
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h3925841d02dc09fbdc118597196a0b32,
            128'h3243f6a8885a308d313198a2e0370734,
            1'b1
        );

        $display("PASS: Todos os testes da Semana 4");

        $finish;

    end

endmodule
