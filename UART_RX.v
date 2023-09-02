///////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////      UART_RX Module      /////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

module UART_RX #(parameter DATA_WIDTH = 8)(
    input   wire                        CLK,
    input   wire                        RST,
    input   wire                        RX_IN,
    input   wire    [4:0]               Prescale,
    input   wire                        PAR_EN,
    input   wire                        PAR_TYP,
    output  wire                        data_valid,
    output  wire    [DATA_WIDTH-1:0]    P_DATA
);


// Internal signals declartions
wire    enable, dat_samp_en, par_chk_en, strt_chk_en, stp_chk_en, deser_en; // Blocks Enables
wire    par_err, strt_glitch, stp_err; // Blocks Feedback
wire    sampled_bit; 
wire    [3:0]   bit_cnt;
wire    [4:0]   edge_cnt;



// Modules Instantiation
edge_bit_counter edge_cnt_unit (
    .edge_bit_counter_clk(CLK),
    .edge_bit_counter_rst(RST),
    .PAR_EN(PAR_EN),
    .enable(enable),
    .Prescale(Prescale),
    .bit_cnt(bit_cnt),
    .edge_cnt(edge_cnt)
);


data_sampling data_samp_unit (
    .data_sampling_clk(CLK),
    .data_sampling_rst(RST),
    .RX_IN(RX_IN),
    .dat_samp_en(dat_samp_en),
    .edge_cnt(edge_cnt),
    .Prescale(Prescale),
    .sampled_bit(sampled_bit)
);


strt_check strt_chk_unit (
    .strt_check_clk(CLK),
    .strt_check_rst(RST),
    .strt_chk_en(strt_chk_en),
    .sampled_bit(sampled_bit),
    .strt_glitch(strt_glitch)
);


parity_check #(.DATA_WIDTH(DATA_WIDTH)) 
parity_chk_unit (
    .parity_check_clk(CLK),
    .parity_check_rst(RST),
    .PAR_TYP(PAR_TYP),
    .par_chk_en(par_chk_en),
    .sampled_bit(sampled_bit),
    .P_DATA(P_DATA),
    .par_err(par_err)
);


stop_check stop_chk_unit (
    .stop_check_clk(CLK),
    .stop_check_rst(RST),
    .stp_chk_en(stp_chk_en),
    .sampled_bit(sampled_bit),
    .stp_err(stp_err)
);


deserializer #(.DATA_WIDTH(DATA_WIDTH)) 
deser_unit (
    .deserializer_clk(CLK),
    .deserializer_rst(RST),
    .deser_en(deser_en),
    .sampled_bit(sampled_bit),
    .edge_cnt(edge_cnt),
    .bit_cnt(bit_cnt),
    .Prescale(Prescale),
    .P_DATA(P_DATA)
);

FSM fsm_unit(
    .FSM_CLK(CLK),
    .FSM_RST(RST),
    .PAR_EN(PAR_EN),
    .RX_IN(RX_IN),
    .edge_cnt(edge_cnt),
    .bit_cnt(bit_cnt),
    .par_err(par_err),
    .strt_glitch(strt_glitch),
    .stp_err(stp_err),
    .Prescale(Prescale),
    .enable(enable),
    .dat_samp_en(dat_samp_en),
    .strt_chk_en(strt_chk_en),
    .par_chk_en(par_chk_en),
    .stp_chk_en(stp_chk_en),
    .data_valid(data_valid),
    .deser_en(deser_en)
);

endmodule