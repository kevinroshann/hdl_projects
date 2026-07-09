module dma(

    input clk,
    input resetn,

    input  [3:0] addr_source,
    input  [3:0] addr_destination,
    input  [2:0] length,
    input        start,

    output       read,
    input        read_gnt,
    output [3:0] read_addr,
    input  [31:0] read_data,

    output       write,
    input        write_gnt,
    output [3:0] write_addr,
    output [31:0] write_data,

    output       done

);

reg [2:0] reg_length;
reg [3:0] reg_addr_source;
reg [3:0] reg_addr_destination;

reg [31:0] reg_read_data;
reg [31:0] reg_write_data;

reg [1:0] state;
reg [1:0] next_state;

localparam IDLE   = 2'b00;
localparam READ   = 2'b01;
localparam WRITE  = 2'b10;
localparam FINISH = 2'b11;

// Outputs
assign read       = (state == READ);
assign write      = (state == WRITE);
assign done       = (state == FINISH);

assign read_addr  = reg_addr_source;
assign write_addr = reg_addr_destination;
assign write_data = reg_write_data;


always @(*) begin

    next_state = state;

    case(state)

        IDLE: begin
            if(start)
                next_state = READ;
        end

        READ: begin
            if(read_gnt)
                next_state = WRITE;
        end

        WRITE: begin
            if(write_gnt) begin
                if(reg_length == 1)
                    next_state = FINISH;
                else
                    next_state = READ;
            end
        end

        FINISH: begin
            next_state = IDLE;
        end

        default:
            next_state = IDLE;

    endcase
end


always @(posedge clk or negedge resetn) begin

    if(!resetn) begin

        state <= IDLE;

        reg_length <= 3'd0;
        reg_addr_source <= 4'd0;
        reg_addr_destination <= 4'd0;

        reg_read_data <= 32'd0;
        reg_write_data <= 32'd0;

    end
    else begin

        state <= next_state;


        if(state == IDLE && start) begin

            reg_length           <= length;
            reg_addr_source      <= addr_source;
            reg_addr_destination <= addr_destination;

        end

        if(state == READ && read_gnt) begin

            reg_read_data <= read_data;

        end


        if(state == WRITE && write_gnt) begin

            reg_write_data <= reg_read_data;

            reg_length <= reg_length - 1;

            reg_addr_source <= reg_addr_source + 4;
            reg_addr_destination <= reg_addr_destination + 4;

        end

    end

end

endmodule