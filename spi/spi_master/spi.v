module spi(
input clk,
input resetn,
output wire sclk,
output csn,
input miso,
output mosi,
input start,
output done

);

// reg reg_sclk=1'b0;
reg reg_csn;
reg [7:0] mosi_data=8'hBC;
reg [7:0] miso_data;
reg mosi_send_data;
reg reg_done;
assign done=reg_done;

assign mosi = mosi_send_data;

assign sclk=clk;
assign csn=reg_csn;

parameter [1:0] IDLE=0;
parameter [1:0] START=1;
parameter [1:0] SENDING=2;
parameter [1:0] STOP=3;

reg [1:0] state=IDLE;
reg [1:0] next_state=IDLE;

reg [3:0] index;

always @(*) begin
    next_state=state;
    case(state) 

IDLE: begin
  if(start) begin
    next_state=START;
  end


end

START: begin
  

next_state=SENDING;

end

SENDING: begin
next_state=SENDING;
      if(index==4'b0000)begin
      next_state=STOP;
    end


end

STOP: begin
  next_state=IDLE;

end


    default: begin
      next_state=state;
    end


    endcase



end


// always @(posedge clk) begin
//     reg_sclk=~reg_sclk;
// end
always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
        state <= IDLE;
        reg_csn <= 1'b1;
        index <= 4'b1000;
        reg_done<=1'b0;
    end
    else begin

        state <= next_state; 


        case(state)
            IDLE: begin
                reg_csn <= 1'b1;
                reg_done<=1'b0;
            end

            START: begin
                index <= 4'b1000;
                reg_csn <= 1'b0;
            end
            
            SENDING: begin
                index <= index - 1;

                mosi_send_data <= mosi_data[index - 1]; 
                miso_data[index - 1] <= miso;
            end
            
            STOP: begin
                reg_csn <= 1'b1; 
                reg_done<=1'b1;
            end
        endcase
    end
end



endmodule