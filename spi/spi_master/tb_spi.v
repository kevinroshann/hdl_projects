`timescale 1ns / 1ps

module tb_spi;

    reg clk = 0;
    always #(41.7) clk = ~clk; // ~12MHz clock


    reg resetn = 1'b0; 
    reg start = 1'b0;
    reg miso = 1'b0;
    wire done;

    wire csn;
    wire mosi;
    wire sclk;
    
    reg [7:0] mosi_data;
    
    integer i = 9; 
    reg s = 1'b0;

    spi dut (
        .clk(clk),
        .resetn(resetn),
        .sclk(sclk),
        .csn(csn),
        .miso(miso),
        .mosi(mosi),
        .start(start),
        .done(done)
    );

    initial begin
        $dumpfile("tb_spi.vcd");
        $dumpvars(0, tb_spi);
        

        $monitor("Time = %0d | csn = %b | mosi_bit = %b | captured_data = %b| done = %b| index=%d| s=%d| i=%d", clk, csn, mosi, mosi_data, done,dut.index,s,i);
    end

    initial begin
        #(100); 
        resetn = 1'b1;
        start = 1'b1;   
        
        @(posedge sclk);
        #3;
        start = 1'b0;  
        s = 1'b1;     
        @(posedge done);
        #3;
        s = 1'b0;     
        
        #(100);        
        $display("Simulation Finished! Final Captured MOSI Data = %h", mosi_data);
        $finish;
    end


    always @(posedge sclk) begin
        if (s == 1) begin
           mosi_data[i]=mosi;
           i=i-1;
        end
    end

endmodule
