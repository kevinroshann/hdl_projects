`timescale 1ns/1ps

module tb_apb;

    // Inputs to DUT (Driven by Testbench -> Must be reg)
    reg         pclk;
    reg         presetn;
    reg         psel;
    reg         penable;
    reg         pwrite;
    reg  [31:0] pwdata;
    reg  [31:0] paddr;

    // Outputs from DUT (Observed by Testbench -> Must be wire)
    wire [31:0] prdata;
    wire        pready;

    // Instantiate the Device Under Test (DUT)
    apb dut (
        .pclk(pclk),
        .presetn(presetn),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .paddr(paddr)
    );

    // Clock Generation (100ns period -> 10 MHz clock)
    always begin
        #50;
        pclk = ~pclk;
    end

    // Stimulus Generation
    initial begin
    
        pclk    = 0;
        presetn = 0;
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        pwdata  = 32'd0;
        paddr   = 32'd0;

        // Reset Sequence
        #500;
        presetn = 1; // Release reset
        #200;        // Wait a couple cycles

       
        @(posedge pclk);
        #(1);
        paddr  = 32'h04;          // Address 4
        pwdata = 32'hDEADBEEF;    // Data to write
        pwrite = 1'b1;            // It's a write
        psel   = 1'b1;            // Assert PSEL -> Enters SETUP State

        @(posedge pclk);
        #(1);
        penable = 1'b1;           // Assert PENABLE -> Enters ACCESS State

        @(posedge pclk);          // Wait for clock edge where pready=1 completes transfer
       #(3);
        psel    = 1'b0;           // De-assert signals
        penable = 1'b0;
        pwrite  = 1'b0;

        #300; // IDLE gap

        @(posedge pclk);
      #(1);
        paddr  = 32'h04;          // Read from same Address 4
        pwrite = 1'b0;            // It's a read
        psel   = 1'b1;            // Enters SETUP State
        
        @(posedge pclk);
        #(1);
        penable = 1'b1;           // Enters ACCESS State

        @(posedge pclk);
        #(1);
        psel    = 1'b0;           // Complete transfer
        penable = 1'b0;

        #1000;
        $display("Simulation Finished Successfully.");
        $finish; // Added missing semicolon
    end

    // Monitor Output
    initial begin
        $monitor("Time: %0t | pclk: %b | presetn: %b | psel: %b | penable: %b | pwrite: %b | paddr: %h | pwdata: %h | prdata: %h | pready: %b", 
                 $time, pclk, presetn, psel, penable, pwrite, paddr, pwdata, prdata, pready);
    end
  initial begin
    $dumpfile("simulation_waves.vcd"); // 1. Name the output VCD file
    $dumpvars(0, tb_apb);               // 2. Dump ALL signals under tb_top
  end
endmodule