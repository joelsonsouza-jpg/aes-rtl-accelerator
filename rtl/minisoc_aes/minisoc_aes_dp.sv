
module minisoc_aes_dp (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start_i,
    input  logic         decrypt_i,
    input  logic [127:0] data_i,
    input  logic [127:0] key_i,

    output logic [127:0] data_o,
    output logic         busy_o,
    output logic         done_o
);

    // Estados da maquina de controle
    typedef enum logic [1:0] {
        ST_IDLE,
        ST_INIT,
        ST_ROUND,
        ST_DONE
    } fsm_t;

    fsm_t fsm_r;

    logic [127:0] state_r;
    logic [1407:0] round_keys_wire;
    logic [1407:0] round_keys_r;
    logic [127:0] round_key;

    logic [3:0] round_r;
    logic decrypt_r;

    // Sinais da cifragem
    logic [127:0] enc_sub;
    logic [127:0] enc_shift;
    logic [127:0] enc_mix;
    logic [127:0] enc_add;

    // Sinais da decifragem
    logic [127:0] dec_shift;
    logic [127:0] dec_sub;
    logic [127:0] dec_add;
    logic [127:0] dec_mix;

    logic [127:0] round_result;

    // Expansao combinacional da chave
    minisoc_aes_key_exp u_key_exp (
        .key_i        (key_i),
        .round_keys_o (round_keys_wire)
    );

    // Seleciona K0 a K10
    assign round_key =
        round_keys_r[1407 - 128*round_r -: 128];

    // ==========================================
    // Caminho de cifragem
    // ==========================================

    minisoc_aes_sub_bytes u_enc_sub (
        .state_i (state_r),
        .state_o (enc_sub)
    );

    minisoc_aes_shift_rows u_enc_shift (
        .state_i (enc_sub),
        .state_o (enc_shift)
    );

    minisoc_aes_mix_columns u_enc_mix (
        .state_i (enc_shift),
        .state_o (enc_mix)
    );

    minisoc_aes_add_round_key u_enc_add (
        .state_i (
            (round_r == 4'd10) ? enc_shift : enc_mix
        ),
        .round_key_i (round_key),
        .state_o     (enc_add)
    );

    // ==========================================
    // Caminho de decifragem
    // ==========================================

    minisoc_aes_inv_shift_rows u_dec_shift (
        .state_i (state_r),
        .state_o (dec_shift)
    );

    minisoc_aes_inv_sub_bytes u_dec_sub (
        .state_i (dec_shift),
        .state_o (dec_sub)
    );

    minisoc_aes_add_round_key u_dec_add (
        .state_i     (dec_sub),
        .round_key_i (round_key),
        .state_o     (dec_add)
    );

    minisoc_aes_inv_mix_columns u_dec_mix (
        .state_i (dec_add),
        .state_o (dec_mix)
    );

    // Ultima rodada nao aplica MixColumns
    // nem InvMixColumns
    assign round_result = decrypt_r
        ? ((round_r == 4'd0) ? dec_add : dec_mix)
        : enc_add;

    // ==========================================
    // Controle sequencial
    // ==========================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            fsm_r        <= ST_IDLE;
            state_r      <= '0;
            round_keys_r <= '0;
            round_r      <= '0;
            decrypt_r    <= 1'b0;
            data_o       <= '0;
        end
        else begin

            case (fsm_r)

                ST_IDLE: begin
                    if (start_i) begin
                        state_r      <= data_i;
                        round_keys_r <= round_keys_wire;
                        decrypt_r    <= decrypt_i;

                        round_r <= decrypt_i
                            ? 4'd9 : 4'd1;

                        fsm_r <= ST_INIT;
                    end
                end

                ST_INIT: begin

                    // Cifragem: XOR com K0
                    // Decifragem: XOR com K10
                    state_r <= state_r ^
                        (decrypt_r
                            ? round_keys_r[127:0]
                            : round_keys_r[1407:1280]);

                    fsm_r <= ST_ROUND;

                end

                ST_ROUND: begin

                    state_r <= round_result;

                    if ((!decrypt_r && round_r == 4'd10) ||
                        ( decrypt_r && round_r == 4'd0)) begin

                        data_o <= round_result;
                        fsm_r  <= ST_DONE;

                    end
                    else begin

                        round_r <= decrypt_r
                            ? round_r - 4'd1
                            : round_r + 4'd1;

                    end

                end

                ST_DONE: begin
                    fsm_r <= ST_IDLE;
                end

                default: begin
                    fsm_r <= ST_IDLE;
                end

            endcase

        end

    end

    // Indicadores da operacao
    assign busy_o =
        (fsm_r == ST_INIT) ||
        (fsm_r == ST_ROUND);

    assign done_o = (fsm_r == ST_DONE);

endmodule
