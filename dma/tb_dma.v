`timescale 1ns / 1ps

module tb_dma;

    reg clk = 0;
    always #(5.0) clk = ~clk;

    reg rst_n = 1'b0;


    // ---- Shared DUT input signals (reg) ----
    reg [3:0] addr_destination;
    reg [3:0] addr_source;
    reg [2:0] length;
    reg [31:0] read_data;
    reg read_gnt;

    reg start;
    reg write_gnt;

    // ---- Shared DUT output signals (wire) ----

    reg [31:0] memread [0:31];
        reg [31:0] memwrite [0:31];
integer i=0;
    initial begin
        for(i=0;i<32;i++) begin
                 memread[i] = 32'hDEADBEEF;
          memwrite[i]=32'b0;
        end
    end

    




    wire done;
    wire read;
    wire [3:0] read_addr;
    wire write;
    wire [3:0] write_addr;
    wire [31:0] write_data;

    // ---- DUT: dma (u_dma) ----
    dma u_dma (
        .clk(clk),
        .resetn(rst_n),
        .addr_source(addr_source),
        .addr_destination(addr_destination),
        .length(length),
        .start(start),
        .read(read),
        .read_gnt(read_gnt),
        .read_addr(read_addr),
        .read_data(read_data),
        .write(write),
        .write_gnt(write_gnt),
        .write_addr(write_addr),
        .write_data(write_data),
        .done(done)
    );
initial begin
    start = 0;
    read_gnt = 0;
    write_gnt = 0;
    read_data = 0;
end
    initial begin
        $dumpfile("simulation");
        $dumpvars(0, tb_dma);
    end

always @(posedge clk) begin

    read_gnt <= 0;

    if(read) begin
        read_data <= memread[read_addr];
        read_gnt <= 1;
    end

end
always @(posedge clk) begin
    write_gnt <= 0;

    if(write) begin
        memwrite[write_addr] <= write_data;
        write_gnt <= 1;
    end
end

    initial begin

        #(100) rst_n = 1'b1;
        length=7;
        addr_source=0;
        addr_destination=8;

@(posedge clk);
start = 1;

@(posedge clk);
start = 0;

wait(done);

$display("DMA finished");

for(i=0;i<32;i=i+1)
    $display("%0d -> %h", i, memwrite[i]);

#20;
$finish;
    end
always @(posedge clk) begin
    #1;
    $display("T=%0t state=%0d read=%b write=%b src=%0d dst=%0d len=%0d",
             $time,
             u_dma.state,
             read,
             write,
             u_dma.reg_addr_source,
             u_dma.reg_addr_destination,
             u_dma.reg_length);
end
endmodule
