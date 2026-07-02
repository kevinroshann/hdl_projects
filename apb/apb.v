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

reg [31:0] memory [0:31] ;
reg [1:0] state;

reg [1:0] next_state;

    localparam IDLE  = 2'b00;
    localparam SETUP = 2'b01;
    localparam ACCESS  = 2'b10;

integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        memory[i] = 32'd0;
    end
    memory[4]=32'd4;
end

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
if (psel) begin
                    next_state = ACCESS; 
                end else begin
                    next_state = IDLE;
                end
end

ACCESS: begin
if (psel && penable) begin
                    pready = 1'b1; 
                    
                    if (!pwrite) begin
                        prdata = memory[paddr[4:0]]; 
                    end
                    

                    if (pready) begin
                        if (!psel) 
                            next_state = IDLE;
                        else 
                            next_state = SETUP; 
                    end
                end else begin
                    next_state = IDLE; 
                end

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

       
    end
end

always @(*) begin
     if (state == ACCESS  && pwrite && psel && penable)
            memory[paddr[4:0]] <= pwdata;
end

endmodule