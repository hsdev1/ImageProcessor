`timescale 1ns / 1ps

module ImageProcessing (
input clk,
input rst,
input inputValid,
input [7:0] inputData,
output outputValid,
output [7:0] outputData
);
	wire [71:0] pixelData; //before process
	wire pixelValid;
	
	MemoryControl mcu(clk, rst, inputValid, inputData, pixelValid, pixelData); 
	Filter filter(clk, pixelData, pixelValid, outputData, outputValid);

endmodule

