module strt_check (
    input   wire    strt_check_clk,
    input   wire    strt_check_rst,
    input   wire    strt_chk_en,
    input   wire    sampled_bit,
    output  wire    strt_glitch
);

reg recieved_start; // store the sampled bit (start bit) in an internal register

assign  strt_glitch = recieved_start; //if the recieved bit after sampling was 1 (then it was just a glitch = 1) 

always @(posedge strt_check_clk or negedge strt_check_rst) 
begin
    if(!strt_check_rst)
        begin
            recieved_start <= 'b0;
        end
    else if(strt_chk_en)
        begin
            recieved_start <= sampled_bit;
        end
    else
        begin
            recieved_start <= recieved_start;
        end
end


// assign  strt_glitch = (strt_chk_en)? sampled_bit : 1'b0;
// it may cause a combinational loops


endmodule