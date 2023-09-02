# UART Receiver
A parameterized Uart Receiver can deal with the data width as a parameter and a variable prescale.\
Implement the Uart hierarchically using separate modules: 
- FSM (Mealy)
- deserializer
- edge_bit_counter 
- data_sampler
- start_check
- parity_check
- stop_check
  
Use a prescale = 8, transmitter clock frequency 12.5 MHz and receiver clock frequency 100 MHz for testing.
