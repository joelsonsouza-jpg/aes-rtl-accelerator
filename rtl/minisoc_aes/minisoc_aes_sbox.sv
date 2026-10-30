
module minisoc_aes_sbox (
    input  logic [7:0] data_i,
    output logic [7:0] data_o
);

    logic [127:0] sbox_row;

    always_comb begin
        case (data_i[7:4])
            4'h0: sbox_row = 128'h637c777bf26b6fc53001672bfed7ab76;
            4'h1: sbox_row = 128'hca82c97dfa5947f0add4a2af9ca472c0;
            4'h2: sbox_row = 128'hb7fd9326363ff7cc34a5e5f171d83115;
            4'h3: sbox_row = 128'h04c723c31896059a071280e2eb27b275;
            4'h4: sbox_row = 128'h09832c1a1b6e5aa0523bd6b329e32f84;
            4'h5: sbox_row = 128'h53d100ed20fcb15b6acbbe394a4c58cf;
            4'h6: sbox_row = 128'hd0efaafb434d338545f9027f503c9fa8;
            4'h7: sbox_row = 128'h51a3408f929d38f5bcb6da2110fff3d2;
            4'h8: sbox_row = 128'hcd0c13ec5f974417c4a77e3d645d1973;
            4'h9: sbox_row = 128'h60814fdc222a908846eeb814de5e0bdb;
            4'ha: sbox_row = 128'he0323a0a4906245cc2d3ac629195e479;
            4'hb: sbox_row = 128'he7c8376d8dd54ea96c56f4ea657aae08;
            4'hc: sbox_row = 128'hba78252e1ca6b4c6e8dd741f4bbd8b8a;
            4'hd: sbox_row = 128'h703eb5664803f60e613557b986c11d9e;
            4'he: sbox_row = 128'he1f8981169d98e949b1e87e9ce5528df;
            4'hf: sbox_row = 128'h8ca1890dbfe6426841992d0fb054bb16;
            default: sbox_row = 128'h0;
        endcase
    end

    assign data_o = sbox_row[127 - (8 * data_i[3:0]) -: 8];

endmodule
