`timescale 1ns / 1ps

module tb_spi;

    reg clk = 0;
    always #(5.0) clk = ~clk; // 100MHz clock

    // ---- Shared DUT input signals ----
    reg done = 1'b0;
    reg cs;
    reg mosi = 1'b0;          // Initialized to prevent X propagation
    reg [7:0] miso_data;

    // ---- Shared DUT output signals ----
    wire miso;

    // ---- DUT: spi ----
    spi dut (
        .clk(clk),
        .mosi(mosi),
        .miso(miso),
        .cs(cs)
    );

    initial begin
        $dumpfile("tb_spi.vcd");
        $dumpvars(0, tb_spi);
    end

    initial begin
        cs = 1'b1;            // Start with CS high (idle)
        #100;
        cs = 1'b0;            // Activate SPI transmission
        
        $monitor("time=%t | mosi=%d | miso=%b | cs=%d | index=%d |tb_index=%d|  captured_miso=%b", 
                 $time, mosi, miso, cs, dut.index,tb_index, miso_data);
    end

    // Finish simulation gracefully when done goes high
    always @(posedge done) begin
        #10; 
        $display("Simulation finished successfully. Captured MISO: %h", miso_data);
        $finish;
    end

    // Testbench data capture logic
    reg [3:0] tb_index = 4'd7; // Start at MSB (7)
    
always @(negedge clk) begin
        if (!cs) begin
            miso_data[tb_index] <= miso; // Safely sample stable MISO line
            
            if (tb_index == 3'd0) begin
                done <= 1'b1;            // Signal completion after LSB (bit 0) is sampled
            end else begin
                tb_index <= tb_index - 1'b1;
            end
        end
        else begin
            tb_index <= 3'd7;            // Reset index if CS pulled high
        end
    end
endmodule