module axi(

    input wire aclk,
    input wire aresetn,

    input [31:0] awaddr,
    input awvalid,
    output awready,

    input [31:0] wdata,
    input [3:0] wstrb,
    input wvalid,
    output wready,

    input [31:0] araddr,
    input arvalid,
    output arready,

    output reg [31:0] rdata,
    output [1:0] rresp,
    output rvalid,
    input rready,

    output [1:0] bresp,
    output bvalid,
    input bready



);


reg [31:0] mem [0:255];


assign rresp=2'b00;


reg reg_awready;
reg reg_wready;

reg reg_arready;
reg reg_rvalid;

assign arready=reg_arready;
assign rvalid=reg_rvalid;



assign wready=reg_wready;
assign awready=reg_awready;

reg [1:0] reg_bresp;
reg reg_bvalid;

assign bresp  = reg_bresp;
assign bvalid = reg_bvalid;


always @(posedge aclk or negedge aresetn) begin
    if(!aresetn) begin
        reg_awready <= 1'b0;
        reg_wready  <= 1'b0;
        reg_bvalid  <= 1'b0;
        reg_bresp   <= 2'b00;
    end
    else begin
        // 1. Accept Write Address & Data
        if(!reg_awready && awvalid && wvalid) begin
            reg_wready      <= 1'b1;
            reg_awready     <= 1'b1;
            mem[awaddr[6:2]]<= wdata;
            
            // Trigger the write response
            reg_bvalid      <= 1'b1;
            reg_bresp       <= 2'b00; // OKAY
        end
        else begin
            reg_awready     <= 1'b0;
            reg_wready      <= 1'b0;
        end
        
        // 2. Clear Write Response when Master acknowledges it
        if(reg_bvalid && bready) begin
            reg_bvalid      <= 1'b0;
        end
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        reg_arready <= 1'b0;
        reg_rvalid  <= 1'b0;
        rdata       <= 32'b0;
    end else begin
        // 1. Address Handshake & Data Fetch
        if (!reg_arready && arvalid) begin
            reg_arready <= 1'b1;
            reg_rvalid  <= 1'b1;
            rdata       <= mem[araddr[6:2]]; // Fetch data immediately
        end else begin
            reg_arready <= 1'b0; // Clear arready after 1 cycle
        end

        // 2. Data Handshake Completion
        if (reg_rvalid && rready) begin
            reg_rvalid  <= 1'b0; // Master took the data, clear valid
        end
    end
end




endmodule