`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Some Assembly Required
// Engineer: Shachar Shemesh
// 
// Create Date: 05/15/2022 10:32:03 AM
// Design Name: uart
// Module Name: uart_recv
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


module uart_recv#(
    parameter DataBits = 8,
    parameter StopBits = 1,
    parameter ClockDivider = 8
)(
    input clock,
    input input_bit,

    output logic[DataBits-1:0] data_out,
    output logic data_ready,
    output logic break_received,
    output logic error
);

localparam StartBits = 1;
localparam ShiftRegisterSize = StartBits + DataBits + StopBits;

logic [$clog2(ClockDivider-1)-1:0] div_counter;
logic [$clog2(ShiftRegisterSize)-1:0] fill_level = 0;

logic [ShiftRegisterSize-1:0]shift_register = { ShiftRegisterSize{1'b1} };

logic input_bit_latched;

enum { Idle, Receiving, Done } state = Idle;

always_comb begin
    data_out = shift_register[StopBits+DataBits-1 : StopBits];

    data_ready = 0;
    break_received = 0;
    error = 0;

    if( state==Done ) begin
        if( shift_register[ShiftRegisterSize-1 : ShiftRegisterSize-StopBits] == { StopBits{ 1'b1 } } &&
            shift_register[StartBits-1 : 0] == { StartBits{ 1'b0 } } )
        begin
            data_ready = 1;
        end else if( shift_register == { ShiftRegisterSize{ 1'b0 } } ) begin
            break_received = 1;
        end else
            error = 1;
    end else begin
    end
end

always_ff@(posedge clock)
begin
    input_bit_latched <= input_bit;

    if( state==Idle ) begin
        if( input_bit_latched==0 ) begin
            state <= Receiving;
            fill_level <= 0;
            div_counter <= ClockDivider/2;
        end
    end else if( state==Receiving ) begin
        if( div_counter == ClockDivider-1 ) begin
            div_counter <= 0;
            shift_in();
        end else begin
            div_counter <= div_counter+1;
        end
    end else if( state==Done ) begin
        state <= Idle;
    end
end

task shift_in();
    shift_register <= { input_bit_latched, shift_register[ShiftRegisterSize-1 : 1] };
    fill_level <= fill_level+1;

    if( fill_level==ShiftRegisterSize-1 )
        state = Done;
endtask

endmodule
