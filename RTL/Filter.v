`timescale 1ns / 1ps

//FILTER_MODE: 0 None, 1 Blur, 2 Sharpen, 3 Edge Detection

module Filter
#(
parameter BRIGHTNESS = 0,
parameter FILTER_MODE = 3,
parameter THRESHOLD = 40
)
(
input clk,
input [71:0] inputData,
input inputValid,
output reg [7:0] outputData,
output reg outputValid
);
    
integer i; 
reg signed [7:0] kernel [0:3][8:0];
reg signed [20:0] mulData [8:0];
reg signed [20:0] sum;
reg mulDataValid;
reg sumValid;
reg signed [20:0] processedData;
reg processedValid;


initial begin
	kernel[0][0] = 0; kernel[1][0] = 1; kernel[2][0] = 0; kernel[3][0] = -1;
	kernel[0][1] = 0; kernel[1][1] = 1; kernel[2][1] = -1; kernel[3][1] = -1;
	kernel[0][2] = 0; kernel[1][2] = 1; kernel[2][2] = 0; kernel[3][2] = -1;
	kernel[0][3] = 0; kernel[1][3] = 1; kernel[2][3] = -1; kernel[3][3] = -1;
	kernel[0][4] = 1; kernel[1][4] = 1; kernel[2][4] = 5; kernel[3][4] = 8;
	kernel[0][5] = 0; kernel[1][5] = 1; kernel[2][5] = -1; kernel[3][5] = -1;
	kernel[0][6] = 0; kernel[1][6] = 1; kernel[2][6] = 0; kernel[3][6] = -1;
	kernel[0][7] = 0; kernel[1][7] = 1; kernel[2][7] = -1; kernel[3][7] = -1;
	kernel[0][8] = 0; kernel[1][8] = 1; kernel[2][8] = 0; kernel[3][8] = -1;
end    

always @(*) begin
	sum = 0;
	for(i=0;i<9;i=i+1) begin
		sum = sum + kernel[FILTER_MODE][i]*$signed({1'b0,inputData[i*8+:8]});
	end
	if(FILTER_MODE == 1) //for blur
		processedData <= sum / 9 + BRIGHTNESS; 
	else if(FILTER_MODE == 3) begin//for Edge Detection
		if(sum > THRESHOLD)
			processedData <= 255;
		else
			processedData <= 0;
	end
	else
		processedData <= sum + BRIGHTNESS;
	processedValid <= inputValid;
end

always @(posedge clk)
begin
	if(processedData > 255)
		outputData <= 255;
	else if(processedData < 0)
		outputData <= 0;
	else
		outputData <= processedData;
	outputValid <= processedValid;
end
    
endmodule

