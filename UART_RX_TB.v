//  Define Time Scale
`timescale 1ns/1ps


///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////     UART_RX Test_Bench     ////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
module UART_RX_TB();

// parameters
parameter   PRESCALE        = 8;
parameter   CLK_PERIOD_TX   = 80; // 80 ns == 12.5 MHz
parameter   CLK_PERIOD_RX   = CLK_PERIOD_TX / PRESCALE; // 10 ns == 100 MHz
parameter   DATA_WIDTH_TB   = 8;
parameter   WITH_PARITY     = 1'b1;
parameter   WITHOUT_PARITY  = 1'b0;
parameter   EVEN_parity     = 1'b0;
parameter   ODD_parity      = 1'b1;
parameter   START_BIT       = 1'b0;
parameter   STOP_BIT        = 1'b1;

//  DUT Signals
reg                             RX_IN_TB;
reg     [4:0]                   Prescale_TB;
reg                             PAR_EN_TB;
reg                             PAR_TYP_TB;
reg                             CLK_TB;
reg                             RST_TB;
wire                            data_valid_TB;
wire    [DATA_WIDTH_TB-1:0]     P_DATA_TB;
reg                             CLK_TX_TB;  // Clock for simulation view only




///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////     Initial     ////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

// Initial Block
initial 
begin

    // System Functions
        $dumpfile("UART_RX_DUMP.vcd") ;       
        $dumpvars;

    // Initialization
        initialize();
        CLK_TX_TB = 'b0;

    // Reset
        reset();

    // Test Cases

        // 1- Test a frame with even parity
            recieve_data_with_parity('b0_1010_0101_0_1,WITH_PARITY,EVEN_parity);
            check_out_data('b1010_0101);
            #(5*CLK_PERIOD_TX)    
        
        // 2- Test a frame with odd parity
            recieve_data_with_parity('b0_1010_0101_1_1,WITH_PARITY,ODD_parity);
            check_out_data('b1010_0101);
            #(5*CLK_PERIOD_TX)    
        
        // 3- Test a frame without parity
            recieve_data_without_parity('b0_1010_0011_1,WITHOUT_PARITY);
            check_out_data('b1100_0101);
            #(5*CLK_PERIOD_TX) 
        
        // 4- Test a frame with a parity error
            recieve_data_with_parity('b0_1011_0001_1_1,WITH_PARITY,EVEN_parity);
            check_out_data('b1000_1101);
            #(5*CLK_PERIOD_TX)

        // 5- Test a start glitch 
            Prescale_TB     = 7;
            RX_IN_TB = 1'b0; 
            #(4*CLK_PERIOD_RX);
            RX_IN_TB = 1'b1;
            #(5*CLK_PERIOD_TX)
        
        // 6- Test a frame with a stop bit error 
            recieve_data_without_parity('b0_1010_0011_0,WITHOUT_PARITY);
            check_out_data('b1100_0101);
            #(5*CLK_PERIOD_TX)

        // 7- Test reciving two consecutive frames
            recieve_data_with_parity('b0_1010_0101_0_1,WITH_PARITY,EVEN_parity);
            check_out_data('b1010_0101);
            recieve_data_without_parity('b0_1010_0011_1,WITHOUT_PARITY);
            check_out_data('b1100_0101);

    reset();
    #(20*CLK_PERIOD_RX)
    
    $stop;
end

///////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////     Tasks     ////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

// Initialization
task initialize ;
 begin
    CLK_TB  = 'b0;
    RST_TB  = 'b1;
 end
endtask

// Reset technique
task reset;
begin
    RST_TB =  'b1;
  #(CLK_PERIOD_RX)
    RST_TB  = 'b0;
  #(CLK_PERIOD_RX)
    RST_TB  = 'b1;
  #(CLK_PERIOD_RX);

end
endtask

// Recieving Data with parity
task recieve_data_with_parity;
input   [DATA_WIDTH_TB+2:0] recieved_frame;
input                       PAR_EN_send;
input                       PAR_TYP_send;
    
integer j;

begin
    PAR_EN_TB       = PAR_EN_send;       
    PAR_TYP_TB      = PAR_TYP_send; 
    Prescale_TB     = 7;

    for(j=DATA_WIDTH_TB+2; j >= 0; j=j-1)
        begin
            RX_IN_TB = recieved_frame[j]; 
            #(CLK_PERIOD_TX);
        end
    RX_IN_TB = 1'b1;
end
endtask

// Recieving Data without parity
task recieve_data_without_parity;
input   [DATA_WIDTH_TB+1:0] recieved_frame;
input                       PAR_EN_send;

integer i;

begin
    PAR_EN_TB       = PAR_EN_send;       
    Prescale_TB     = 7;

    for(i=DATA_WIDTH_TB+1; i >= 0; i=i-1)
        begin
            RX_IN_TB = recieved_frame[i];
            #(CLK_PERIOD_TX);
        end
    RX_IN_TB = 1'b1;
end
endtask


// Check the output data
task check_out_data;
input  reg     [DATA_WIDTH_TB-1:0]      expected_output;

begin
        if(P_DATA_TB == expected_output && data_valid_TB) 
            $display("Test Case is succeeded");
        else
            $display("Test Case is failed, Send That Frame Again");  
end

endtask


    



///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////     Clock     /////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
// CLocks generation
always #(CLK_PERIOD_RX/2.0)  CLK_TB = ~CLK_TB ;

always #(CLK_PERIOD_TX/2.0)  CLK_TX_TB = ~CLK_TX_TB ;

///////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////     DUT     /////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
// DUT instantiation
UART_RX #(.DATA_WIDTH(DATA_WIDTH_TB)) DUT (
    .RX_IN(RX_IN_TB),
    .Prescale(Prescale_TB),
    .PAR_EN(PAR_EN_TB),
    .PAR_TYP(PAR_TYP_TB),
    .CLK(CLK_TB),
    .RST(RST_TB),
    .data_valid(data_valid_TB),
    .P_DATA(P_DATA_TB)
);




endmodule