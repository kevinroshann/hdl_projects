`timescale 1ns/1ps  // Switched to 1ns/1ps for a standard 100MHz clock cycle simulation length

module tb_axi;

    // Clock and Reset
    reg aclk;
    reg aresetn;

    // Write Address Channel
    reg [31:0] awaddr;
    reg awvalid;
    wire awready;

    // Write Data Channel
    reg [31:0] wdata;
    reg [3:0] wstrb;
    reg wvalid;
    wire wready;

    // Read Address Channel
    reg [31:0] araddr;
    reg arvalid;
    wire arready;

    // Read Data Channel
    wire [31:0] rdata;
    wire [1:0] rresp;
    wire rvalid;
    reg rready;

    // Write Response Channel
    wire [1:0] bresp;
    wire bvalid;
    reg bready;

    // Device Under Test (DUT)
    axi dut (
        .aclk(aclk),
        .aresetn(aresetn),
        .awaddr(awaddr),
        .awvalid(awvalid),
        .awready(awready),
        .wdata(wdata),
        .wstrb(wstrb),
        .wvalid(wvalid),
        .wready(wready),
        .araddr(araddr),
        .arvalid(arvalid),
        .arready(arready),
        .rdata(rdata),
        .rresp(rresp),
        .rvalid(rvalid),
        .rready(rready),
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready)
    );

    // 100MHz Clock Generation (Period = 10ns)
    always begin
        #5 aclk = ~aclk;
    end 

    initial begin
        // --- 1. Initialize Inputs ---
        aclk    = 1'b0;
        aresetn = 1'b0;
        awaddr  = 32'h0;
        awvalid = 1'b0;
        wdata   = 32'h0;
        wstrb   = 4'hf;
        wvalid  = 1'b0;
        araddr  = 32'h0;
        arvalid = 1'b0;
        rready  = 1'b0;
        bready  = 1'b0;
        
        // Hold reset for 5 clock cycles
        #50;
        aresetn = 1'b1;
        #20; // Wait 2 cycles

        // --- 2. Perform a Write Transaction ---
        // Let's write the value 32'hDEADBEEF to memory address 32'h0000_0008 (Word Index 2)
        @(posedge aclk);
        awaddr  = 32'h0000_0008; 
        wdata   = 32'hDEADBEEF;
        awvalid = 1'b1;
        wvalid  = 1'b1;
        bready  = 1'b1; // Ready to receive response

        // Wait until slave accepts address and data
        @(posedge aclk);
        while (!awready || !wready) begin
            @(posedge aclk);
        end
        
        // Deassert write valids right after the handshake
        awvalid = 1'b0;
        wvalid  = 1'b0;

        // Wait for Write Response handshake (BVALID)
        while (!bvalid) begin
            @(posedge aclk);
        end
        #10; // Hold bready for one more cycle
        bready = 1'b0;

        #40; // Idle delay between transactions

        // --- 3. Perform a Read Transaction ---
        // Let's read back from the same memory address 32'h0000_0008
        @(posedge aclk);
        araddr  = 32'h0000_0008;
        arvalid = 1'b1;
        rready  = 1'b1; // Master is ready to receive data

        // Wait for Read Address handshake
        @(posedge aclk);
        while (!arready) begin
            @(posedge aclk);
        end
        arvalid = 1'b0; // Deassert address valid

        // Wait for Read Data to become valid
        while (!rvalid) begin
            @(posedge aclk);
        end
        // At this point, rdata should equal 32'hDEADBEEF!
        
        @(posedge aclk);
        rready = 1'b0; // Finish transaction

        // --- 4. End Simulation ---
        #200;
        $display("Simulation finished successfully!");
        $finish;
    end
initial begin
    $dumpfile("simulation_waves.vcd"); // 1. Name the output VCD file
    $dumpvars(0, tb_axi);               // 2. Dump ALL signals under tb_top
  end

endmodule