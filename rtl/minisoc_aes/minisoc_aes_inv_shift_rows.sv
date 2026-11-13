
module minisoc_aes_inv_shift_rows (
    input  logic [127:0] state_i,
    output logic [127:0] state_o
);

    // Deslocamento inverso das linhas do estado AES
    assign state_o = {
        state_i[127:120],
        state_i[23:16],
        state_i[47:40],
        state_i[71:64],

        state_i[95:88],
        state_i[119:112],
        state_i[15:8],
        state_i[39:32],

        state_i[63:56],
        state_i[87:80],
        state_i[111:104],
        state_i[7:0],

        state_i[31:24],
        state_i[55:48],
        state_i[79:72],
        state_i[103:96]
    };

endmodule
