module spi(

input clk,
input mosi,
output miso,
input cs


);
reg [7:0] miso_data=8'b10000001;
reg [7:0] mosi_data;

reg [3:0] index=4'd7;


assign miso=cs?1'b0:miso_data[index];
always @(posedge clk) begin
    
    if(cs) begin
      //pass
        index<=4'd7;

    end
    else begin

      mosi_data[index]<=mosi;
if (index == 3'd0) begin
            index <= 3'd7; // Wrap around after the LSB is processed
        end 
        else begin
            index <= index - 1'b1; // Decrement index
        end
    end


end 


endmodule