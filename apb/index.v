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
reg [31:0] pwdata_store;
reg [31:0] [31:0] data;
reg [1:0] state;

reg [1:0] next_state;

    localparam IDLE  = 2'b00;
    localparam SETUP = 2'b01;
    localparam ACCESS  = 2'b10;


always @(*) begin

case(state)
next_state = state;
IDLE: begin
  
    if(psel) begin
      next_state=SETUP;
    end

end
SETUP: begin
  

if(penable) begin
    next_state=ACCESS;
end

end

ACCESS: begin
  
if(pwrite) begin
  pwdata_store=pwdata;
end
else if(!pwrite)begin
  prdata=data[paddr];
end
if (pready)
        next_state = IDLE;   // or SETUP if another transfer
    else
        next_state = ACCESS;

end


endcase


end

always @(posedge pclk) begin
    
    if(!presetn) begin
      state<=IDLE;

    end 
    else begin
      
        state<=next_state;


    end



end




endmodule