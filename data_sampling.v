module data_sampling (
    input   wire            data_sampling_clk,
    input   wire            data_sampling_rst,
    input   wire            RX_IN,
    input   wire            dat_samp_en,
    input   wire    [4:0]   edge_cnt,
    input   wire    [4:0]   Prescale, //8 or 16 or 32
    output  reg             sampled_bit
);

wire    [3:0]       middle_sample;  //calculate the middle sample for each prescale 8->4, 16->8, 32->16
reg     [2:0]       samples_reg;    //save the 3 samples of the recieved bits
reg                 sampling_done;  //flag to start calculating the majority


assign middle_sample = (Prescale >> 1);

always @(posedge data_sampling_clk or negedge data_sampling_rst) 
begin
    if(!data_sampling_rst)
        begin
            samples_reg     <= 'b0;
            sampling_done   <= 'b0;
            sampled_bit     <= 'b0;        
        end
    else if(dat_samp_en && !sampling_done)
        begin
            if(edge_cnt == middle_sample - 1'b1) // 1st sample
                begin
                    samples_reg[0] <= RX_IN;
                end
            else if (edge_cnt == middle_sample) // 2nd sample
                begin
                    samples_reg[1] <= RX_IN;
                end
            else if(edge_cnt == middle_sample + 1'b1) // 3rd sample
                begin
                    samples_reg[2] <= RX_IN;
                    sampling_done <= 1'b1;
                end
        end
    else if(dat_samp_en && sampling_done)
        begin
            // using k-map
            sampled_bit <= (samples_reg[1]&samples_reg[2]) | (samples_reg[0]&samples_reg[2]) | (samples_reg[0]&samples_reg[1]);
            sampling_done <= 'b0;
        end
    else
        begin
            sampling_done <= 'b0;
        end


end





endmodule