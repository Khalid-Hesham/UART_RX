module stop_check (
    input   wire    stop_check_clk,
    input   wire    stop_check_rst,
    input   wire    stp_chk_en,
    input   wire    sampled_bit,
    output  wire    stp_err
);

reg recieved_stop;  // store the sampled bit (stop bit) in an internal register

assign  stp_err = ~recieved_stop; //if the recieved bit after sampling was 1 then it was a stop bit with no error (stp_err = 0) 



always @(posedge stop_check_clk or negedge stop_check_rst) 
begin
    if(!stop_check_rst)
        begin
            recieved_stop <= 'b0;
        end
    else if(stp_chk_en)
        begin
            recieved_stop <= sampled_bit;
        end   
    else
        begin
            recieved_stop <= recieved_stop;
        end 
end



// assign  stp_err = (stp_chk_en)? ~sampled_bit : 1'b0;
// it may cause a combinational loops


endmodule