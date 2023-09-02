module edge_bit_counter(
    input   wire            edge_bit_counter_clk,
    input   wire            edge_bit_counter_rst,
    input   wire            PAR_EN,
    input   wire            enable,
    input   wire    [4:0]   Prescale,   // Prescale 8, 16, 32
    output  reg     [3:0]   bit_cnt,    // no of bits in the frame is 10, 11
    output  reg     [4:0]   edge_cnt    // for each prescale count 8, 16, 32 edges
);


always @(posedge edge_bit_counter_clk or negedge edge_bit_counter_rst)
begin
    if(!edge_bit_counter_rst)
        begin
            bit_cnt     <= 'b0;
            edge_cnt    <= 'b0;
        end
    else if(enable)
        begin
            edge_cnt <= edge_cnt + 'b1;
            if(edge_cnt == Prescale)      
                begin
                    bit_cnt <= bit_cnt + 'b1;
                    edge_cnt <= 'b0;
                end
        end
    else
        begin
            bit_cnt     <= 'b0;
            edge_cnt    <= 'b0;
        end  
end


endmodule