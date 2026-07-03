`timescale 1ps/1ps
module ahb_tb;


ahb dut(

.hclk(hclk),
.hresetn( hresetn),

.hsel( hsel),
.haddr(haddr),
.htrans(htrans),
.hsize(hsize),
.hwdata(hwdata),
.hready(hready),
.hwrite(hwrite),

.hrdata(hrdata),
.hreadyout(hreadyout),
.hresp(hresp)

);
reg [31:0] read_data;
task write;
input [31:0] addr;
input [31:0] data;
begin

    // Address phase
    @(negedge hclk);
    hsel   = 1;
    haddr  = addr;
    hwrite = 1;
    htrans = 2'b10;
    hsize  = 3'b010;

    // Data phase
    @(posedge hclk);
    hwdata = data;

    // Finish
    @(posedge hclk);
    hsel   = 0;
    htrans = 2'b00;
hwrite = 0;
end
endtask

task read;
    input [31:0] addr;
    output [31:0] data_output;
    begin

@(posedge hclk);
    hsel   = 1;
    haddr  = addr;
    hwrite = 0;
    htrans = 2'b10;
    hsize  = 3'b010;

@(posedge hclk);
#1
data_output = hrdata;

    // Finish
    @(posedge hclk);
    hsel   = 0;
    htrans = 2'b00;
        
    end
endtask
reg hclk;
reg hresetn;

reg hsel;
reg [31:0] haddr;
reg [1:0] htrans;
reg [2:0] hsize;
reg [31:0] hwdata;
reg hready;
reg hwrite;

wire [31:0] hrdata;
wire hreadyout;
wire  hresp;

always begin
    #50;
    hclk=~hclk;
end
initial begin

    hclk=1'b0;


 hsel=1'b0;
haddr=32'b0;
 htrans=2'b0;
hsize=3'b0;
hwdata=32'b0;
hready=1'b1;
 hwrite=1'b0;
    hresetn=1'b0;
    #500;
    hresetn=1'b1;

       write(
32'd4,
32'hDEADBEEF

       );


        read(
32'd4,
read_data        );

    #100;

$display("Read Data = %h",read_data);

   
$finish;
end

initial begin
  $monitor(
"t=%0t HADDR=%h HWRITE=%b HWDATA=%h HRDATA=%h READ_DATA=%h",
$time,haddr,hwrite,hwdata,hrdata,read_data
);
end 
initial begin
    $dumpfile("simulation_waves.vcd"); // 1. Name the output VCD file
    $dumpvars(0, ahb_tb);               // 2. Dump ALL signals under tb_top
  end


endmodule