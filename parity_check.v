module parity_check #(parameter DATA_WIDTH = 8) (
    input   wire                        parity_check_clk,
    input   wire                        parity_check_rst,
    input   wire                        PAR_TYP,
    input   wire                        par_chk_en,
    input   wire                        sampled_bit,
    input   wire    [DATA_WIDTH-1:0]    P_DATA,
    output  wire                        par_err
);

reg calculated_parity;
reg recieved_parity;


assign  par_err = ~(calculated_parity == recieved_parity);


always @(posedge parity_check_clk or negedge parity_check_rst) 
begin
    if(!parity_check_rst)
        begin
            calculated_parity <= 'b0;
            recieved_parity <= 'b0;
        end
    else if (par_chk_en)
        begin
            recieved_parity <= sampled_bit;
            if(PAR_TYP) // odd parity
                begin
                    calculated_parity <= ~(^P_DATA);
                end
            else if(!PAR_TYP) // even parity
                begin
                    calculated_parity <= ^P_DATA;
                end
        end
    else
        begin
            calculated_parity <= calculated_parity;
            recieved_parity <= recieved_parity;
        end
end

// wire    calculated_parity;
// assign  calculated_parity = PAR_TYP ? ~^P_DATA : ^P_DATA;
// assign  par_err = (par_chk_en)? ~(calculated_parity == sampled_bit) : 1'b0;
// it may cause a combinational loops


endmodule