module FSM (
input   wire            FSM_CLK,
input   wire            FSM_RST,
input   wire            PAR_EN,
input   wire            RX_IN,
input   wire    [4:0]   edge_cnt,
input   wire    [3:0]   bit_cnt,
input   wire            par_err,
input   wire            strt_glitch,
input   wire            stp_err,
input   wire    [4:0]   Prescale, // ??
output  reg             enable,
output  reg             dat_samp_en,
output  reg             strt_chk_en,
output  reg             par_chk_en,
output  reg             stp_chk_en,
output  reg             data_valid,
output  reg             deser_en
);

// States Defination 
localparam  IDLE            = 'b000;
localparam  START_CHECK     = 'b001;
localparam  DATA_CHECK      = 'b010;
localparam  PARITY_CHECK    = 'b011;
localparam  STOP_CHECK      = 'b100;

// States Variables
reg     [2:0]   Current_State , Next_State;


// Current state logic
always @(posedge FSM_CLK or negedge FSM_RST) 
begin
    if(!FSM_RST)
        begin
            Current_State <= Current_State; 
        end
    else
        begin
            Current_State <= Next_State;
        end
end


//  Next state logic
always @(*)
begin
    case (Current_State)
        IDLE: 
            begin
                if(!RX_IN)
                    begin 
                        Next_State = START_CHECK;
                    end
                else
                    begin   
                        Next_State = Current_State;
                    end
            end 
        START_CHECK:
            begin
                if(edge_cnt == Prescale)
                    begin
                        if(strt_glitch)
                            Next_State = IDLE;
                        else
                            Next_State = DATA_CHECK;
                    end
                else
                    begin   
                        Next_State = Current_State;
                    end                    
            end
        DATA_CHECK:
            begin
                if(bit_cnt == 9)
                    begin
                        if(PAR_EN)
                            Next_State = PARITY_CHECK;
                        else
                            Next_State = STOP_CHECK;
                    end
                else
                    begin
                        Next_State = DATA_CHECK;
                    end
            end
        PARITY_CHECK:
            begin
                if(edge_cnt == Prescale)
                    begin
                        Next_State = STOP_CHECK;
                    end
                else
                    begin
                        Next_State = Current_State;
                    end
            end
        STOP_CHECK:
            begin
                if(edge_cnt == Prescale)
                    begin
                        Next_State = START_CHECK;
                    end
                else
                    begin
                        Next_State = Current_State;
                    end
            end
        default:
            begin
                Next_State = IDLE;
            end
    endcase
end


// Output logic
always @(*)
begin
        enable      = 1'b0;
        dat_samp_en = 1'b0;
        strt_chk_en = 1'b0;
        par_chk_en  = 1'b0;
        stp_chk_en  = 1'b0;
        deser_en    = 1'b0;
        data_valid  = 1'b0;

    case(Current_State)
    IDLE    : begin
                enable      = 1'b0;
                dat_samp_en = 1'b0;
                strt_chk_en = 1'b0;
                par_chk_en  = 1'b0;
                stp_chk_en  = 1'b0;
                deser_en    = 1'b0;
                data_valid  = 1'b0;
                end
    START_CHECK   : begin
                enable      = 1'b1;
                dat_samp_en = 1'b1;
                strt_chk_en = 1'b1;
                par_chk_en  = 1'b0;
                stp_chk_en  = 1'b0;
                deser_en    = 1'b0;
                data_valid  = 1'b0;
                end	
    DATA_CHECK    : begin
                enable      = 1'b1;
                dat_samp_en = 1'b1;
                strt_chk_en = 1'b0;
                par_chk_en  = 1'b0;
                stp_chk_en  = 1'b0;                
                deser_en    = 1'b1;
                data_valid  = 1'b0;
                end
    PARITY_CHECK  : begin
                enable      = 1'b1;
                dat_samp_en = 1'b1;
                strt_chk_en = 1'b0;
                par_chk_en  = 1'b1;
                stp_chk_en  = 1'b0;                
                deser_en    = 1'b0;
                data_valid  = 1'b0;
                end
    STOP_CHECK    : begin
                enable      = 1'b1;
                dat_samp_en = 1'b1;
                strt_chk_en = 1'b0;
                par_chk_en  = 1'b0;
                stp_chk_en  = 1'b1;                
                deser_en    = 1'b0;
                    if(edge_cnt == Prescale)
                        begin
                            if(par_err || stp_err)
                                begin
                                    data_valid  = 1'b0;
                                    enable = 1'b0;
                                end
                            else
                                begin
                                    data_valid  = 1'b1;
                                    enable = 1'b0;
                                end
                        end
                end

    default : begin
                enable      = 1'b0;
                dat_samp_en = 1'b0;
                strt_chk_en = 1'b0;
                par_chk_en  = 1'b0;
                stp_chk_en  = 1'b0;                
                deser_en    = 1'b0;
                data_valid  = 1'b0;
                end			  
    endcase
end	






endmodule