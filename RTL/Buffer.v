`timescale 1ns / 1ps
`define WIDTH 640

module Buffer(
input   clk, //clock
input   rst, //reset
input [7:0] inputData, //input data
input   writeSignal, //write signal
output reg [23:0] outputData, //output data
input readSignal //read Signal
);

reg [7:0] mem [`WIDTH-1:0]; //line buffer memory: 1bytes regs * WIDTH
reg [11:0] writePos; //write position: ceil(lg(WIDTH))
reg [11:0] readPos; //read position: ceil(lg(WIDTH))

always @(posedge clk) begin
	if(rst) begin
		writePos <= 0; //set pos to 0
		readPos <= 0; //set pos to 0
	end
	else begin
		if(writeSignal) begin
			mem[writePos] <= inputData; //store data
			if(writePos == `WIDTH-1)
				writePos <= 0;
			else
				writePos <= writePos + 1; //increase pos
		end
		if(readSignal) begin
			if(readPos == `WIDTH-1)
				readPos <= 0;
			else
				readPos <= readPos + 1; //increase pos
		end
	end
end

//output with zero-padding
always @(*) begin
	if(readPos == 0) 
		outputData <= {8'b0,mem[readPos],mem[readPos+1]};
	else if(readPos == `WIDTH-1)
		outputData <= {mem[readPos-1],mem[readPos],8'b0};
	else
		outputData <= {mem[readPos-1],mem[readPos],mem[readPos+1]};
end
endmodule
