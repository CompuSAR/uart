`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Some Assembly Required
// Engineer: Shachar Shemesh
// 
// Create Date: 05/06/2022 03:51:06 AM
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


module uart_send#(
    parameter DataBits = 8,
    parameter StopBits = 1,
    parameter ClockDivider = 8
)
(
    input clock,
    input [DataBits-1:0] data_in,
    input data_in_ready,

    output out_bit,
    output logic receive_ready
);

localparam StartBits = 1;
localparam ShiftRegisterSize = StartBits + DataBits + StartBits;

logic [$clog2(ClockDivider-1)-1:0] div_counter = ClockDivider-1;
logic [$clog2(ShiftRegisterSize)-1:0] fill_level = 0;

logic [ShiftRegisterSize-1:0]shift_register = { ShiftRegisterSize{1'b1} };

assign out_bit = shift_register[0];
assign receive_ready = fill_level<=1 && div_counter==ClockDivider-1;

always_ff@(posedge clock)
begin
    if( div_counter==ClockDivider-1 ) begin
        if( fill_level<=1 ) begin
            shift_down();
            if( data_in_ready ) begin
                shift_register <= { {StopBits{1'b1}}, data_in, {StartBits{1'b0}} };

                fill_level <= ShiftRegisterSize;
                div_counter <= 0;
            end
        end else begin
            shift_down();
            div_counter <= 0;
        end
    end else begin
        if( fill_level!=0 )
            div_counter <= div_counter+1;
    end

    if( fill_level==0 && !data_in_ready )
        div_counter <= ClockDivider-1;
end

task shift_down();
    if( fill_level!=0 ) begin
        shift_register <= { 1'b1, shift_register[ShiftRegisterSize-1 : 1] };
        fill_level <= fill_level-1;
    end
endtask

endmodule
