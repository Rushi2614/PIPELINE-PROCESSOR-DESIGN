module tb_PipelinedProcessor;
    reg clk;
    PipelinedProcessor uut (.clk(clk));

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns clock
    end

    initial begin
        #100 $finish;
    end
endmodule
