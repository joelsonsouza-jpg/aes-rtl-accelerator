`timescale 1ns/1ps
module tb_minisoc_aes_transform;


    logic [7:0]   sbox_in;
    logic [7:0]   sbox_out;
    logic [127:0] state_in;
    logic [127:0] sub_out;
    logic [127:0] shift_out;

    minisoc_aes_sbox dut_sbox (
        .data_i(sbox_in),
        .data_o(sbox_out)
    );

    minisoc_aes_sub_bytes dut_sub_bytes (
        .state_i(state_in),
        .state_o(sub_out)
    );

    minisoc_aes_shift_rows dut_shift_rows (
        .state_i(sub_out),
        .state_o(shift_out)
    );

    function automatic [7:0] gf_mul(
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

    function automatic [7:0] ref_sbox(
        input logic [7:0] value
    );
        logic [7:0] inv;

        if (value == 8'h00) begin
            inv = 8'h00;
        end else begin
            inv = 8'h01;

            for (int k = 0; k < 254; k++)
                inv = gf_mul(inv, value);
        end

        return inv
             ^ {inv[6:0], inv[7]}
             ^ {inv[5:0], inv[7:6]}
             ^ {inv[4:0], inv[7:5]}
             ^ {inv[3:0], inv[7:4]}
             ^ 8'h63;
    endfunction

    task automatic check_round(
        input int round_num,
        input logic [127:0] expected_start,
        input logic [127:0] expected_sub,
        input logic [127:0] expected_shift
    );
        state_in = expected_start;
         #1

        if (sub_out !== expected_sub) begin
            $display("ERRO: SubBytes rodada %0d", round_num);
            $display("Esperado: %032h", expected_sub);
            $display("Obtido:   %032h", sub_out);
            $fatal(1, "Falha em SubBytes");
        end

        if (shift_out !== expected_shift) begin
            $display("ERRO: ShiftRows rodada %0d", round_num);
            $display("Esperado: %032h", expected_shift);
            $display("Obtido:   %032h", shift_out);
            $fatal(1, "Falha em ShiftRows");
        end

        $display("PASS: SubBytes e ShiftRows - rodada %0d",
                 round_num);
    endtask

    initial begin
        sbox_in = 8'h00;
        state_in = 128'h0;

        for (int i = 0; i < 256; i++) begin
            sbox_in = 8'(i);

            #1
            if (sbox_out !== ref_sbox(sbox_in)) begin
                $display("ERRO: S-box na entrada %02h", sbox_in);
                $display("Esperado: %02h", ref_sbox(sbox_in));
                $display("Obtido:   %02h", sbox_out);
                $fatal(1, "Falha na S-box");
            end
        end

        $display("PASS: S-box - 256 entradas verificadas");

        check_round(
            1,
            128'h193de3bea0f4e22b9ac68d2ae9f84808,
            128'hd42711aee0bf98f1b8b45de51e415230,
            128'hd4bf5d30e0b452aeb84111f11e2798e5
        );

        check_round(
            10,
            128'heb40f21e592e38848ba113e71bc342d2,
            128'he9098972cb31075f3d327d94af2e2cb5,
            128'he9317db5cb322c723d2e895faf090794
        );

        $display("PASS: Todos os testes AES da Semana 2");
        $finish;
    end

endmodule
