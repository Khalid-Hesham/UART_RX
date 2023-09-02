module deserializer #(parameter DATA_WIDTH = 8)(
    input   wire                        deserializer_clk,
    input   wire                        deserializer_rst,
    input   wire                        deser_en,
    input   wire                        sampled_bit,
    input   wire    [4:0]               edge_cnt,
    input   wire    [3:0]               bit_cnt,
    input   wire    [4:0]               Prescale,
    output  wire    [DATA_WIDTH-1:0]    P_DATA
);

reg     [DATA_WIDTH-1:0]    deser_reg;

assign P_DATA = deser_reg;

always @(posedge deserializer_clk or negedge deserializer_rst) 
begin
    if(!deserializer_rst)
        begin
            deser_reg <= 'b0;
        end
    else if (deser_en && bit_cnt != 'd10)
        begin
            if(edge_cnt == Prescale - 1)
                begin
                    deser_reg [bit_cnt - 1] <= sampled_bit;
                end
        end    
end


endmodule