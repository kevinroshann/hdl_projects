module ahb(

input hclk,
input hresetn,

input hsel,
input [31:0] haddr,
input [1:0] htrans,
input [2:0] hsize,
input [31:0] hwdata,
input hready,
input hwrite,

output reg[31:0] hrdata,
output reg hreadyout,
output reg hresp

);

reg [31:0] mem[0:255];

//these registers are because of pipelineing
reg [31:0] addr_reg;
reg        write_reg;
reg [2:0]  size_reg;
reg        valid_reg;


always @(posedge hclk or negedge hresetn) begin
    
    if(!hresetn) begin
        
        //reset
        hrdata<=32'b0;
        hreadyout<=1;
        hresp<=0;

        addr_reg<=32'b0;
        write_reg<=0;
        size_reg<=3'b0;
        valid_reg<=0;

    end
    else begin
      if(valid_reg) begin
            
            if(write_reg) begin //write
              mem[addr_reg[9:2]]<=hwdata;


            end
            else begin //read
              
                hrdata<=mem[addr_reg[9:2]];

            end


        end




  
    if(hsel&&hready&&htrans[1]) begin
      addr_reg<=haddr;
        write_reg<=hwrite;
        size_reg<=hsize;
        valid_reg<=1'b1;
        
        
    end
    else begin
      valid_reg<=1'b0;
        //ignore

    end 
hreadyout <= 1'b1;
        hresp     <= 1'b0;
end
end


endmodule