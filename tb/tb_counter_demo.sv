`timescale 1ns/1ps
module tb_counter_demo;
    logic clk_i = 1'b0;
    logic rst_ni = 1'b0;
    logic en_i = 1'b0;
    logic [3:0] count_o;

    counter_demo dut (.*);
    always #5 clk_i = ~clk_i;

    initial begin
        $dumpfile("build/counter_demo.vcd");
        $dumpvars(0, tb_counter_demo);
        repeat (2) @(negedge clk_i);
        rst_ni = 1'b1;
        en_i = 1'b1;
        repeat (4) @(negedge clk_i);
        if (count_o !== 4'd4) $fatal(1, "Falha contador: esperado 4, recebido %0d", count_o);
        en_i = 1'b0;
        repeat (2) @(negedge clk_i);
        if (count_o !== 4'd4) $fatal(1, "Falha enable: contador mudou");
        rst_ni = 1'b0;
        #1;
        if (count_o !== 4'd0) $fatal(1, "Falha reset: esperado zero");
        $display("PASS: reset, contagem e enable validados.");
        $finish;
    end
endmodule
