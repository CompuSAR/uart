`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Some Assembly Required
// Engineer: Shachar Shemesh
// 
// Create Date: 05/06/2022 08:52:52 AM
// Design Name: uart
// Module Name: uart_send
// Project Name: CompuSAR
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top();

logic clock;

logic [7:0]data;
logic data_ready;

logic uart_out;
logic uart_ready;


uart_send#(.ClockDivider(10))
    uart(.clock(clock), .data_in(data), .data_in_ready(data_ready), .out_bit(uart_out), .receive_ready(uart_ready));

initial begin
    clock = 0;
    forever begin
        #20 clock = 1'b1;
        #20 clock = 1'b0;
    end
end

int index = 0;
string str="Hello\015\n";
logic restart_strobe;

initial begin
    forever begin
        @(posedge clock) restart_strobe = 1;
        @(posedge clock) restart_strobe = 0;
        #1000000 ;
    end
end

always_ff@(posedge clock)
begin
    if( restart_strobe ) begin
        index = 0;
        data_ready = 1;
    end

    data = str[index];
    if( uart_ready ) begin
        if( index<str.len() )
            index++;
        else
            data_ready = 0;
    end
end

endmodule
