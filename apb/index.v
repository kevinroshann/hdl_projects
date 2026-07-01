module apb(

input pclk,
input presetn,
input psel,
input penable,
input pwrite,
input [31:0] pwdata,
output reg [31:0] prdata,
output reg pready,
input [31:0] paddr

);

reg [31:0] memory [0:31];
reg [1:0] state;

reg [1:0] next_state;

    localparam IDLE  = 2'b00;
    localparam SETUP = 2'b01;
    localparam ACCESS  = 2'b10;


always @(*) begin
next_state = state;
    prdata = 32'd0;
    pready = 1'b0;
case(state)

IDLE: begin
  
    if(psel) begin
      next_state=SETUP;
    end

end
SETUP: begin
    if (psel && penable)
        next_state = ACCESS;
    else if (!psel)
        next_state = IDLE;

end

ACCESS: begin
if (psel && penable) begin
    pready = 1'b1;

    if (!pwrite)
        prdata = memory[paddr[4:0]];
end
   if (!psel)
        next_state = IDLE;
    else
        next_state = SETUP;

end
default: begin
    next_state = IDLE;
end

endcase


end

always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;

        if (state == ACCESS && pready && pwrite)
            memory[paddr[4:0]] <= pwdata;
    end
end



endmodule