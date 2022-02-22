`timescale 1ns / 1ps
`define WIDTH 640

module MemoryControl
(
input clk,
input rst,
input inputValid,
input [7:0] inputData,
output outputValid,
output reg [71:0] outputData
);
reg [11:0] writeCounter; //write counter: ceil(lg(WIDTH))
reg [1:0] currentWriteBuffer; //Current write line buffer, 3 line buffers, need 2 bits to point
reg [2:0] bufferDataValid; 
reg [1:0] currentReadBuffer; //current read line buffer
wire [23:0] buffer0Data; //line buffer 0 data 3bytes
wire [23:0] buffer1Data; //line buffer 1 data 3bytes
wire [23:0] buffer2Data; //line buffer 2 data 3bytes

reg [11:0] readCounter; //read counter: ceil(lg(WIDTH))
reg readSignal;
reg [12:0] startCounter; //start when startCounter>WIDTH*3

assign outputValid = readSignal;

Buffer buffer0(clk, rst, inputData, bufferDataValid[0], buffer0Data, readSignal);
Buffer buffer1(clk, rst, inputData, bufferDataValid[1], buffer1Data, readSignal);  
Buffer buffer2(clk, rst, inputData, bufferDataValid[2], buffer2Data, readSignal);


//readSignal
always @(posedge clk) begin
	//reset
	if(rst) begin
		readSignal <= 1'b0;
	end
	else begin
		//stored more than WIDTH*3; start read
		if(startCounter > `WIDTH*3) begin
			readSignal <= 1'b1;
		end
	end
end



always @(posedge clk) begin
	//reset
	if(rst)
		startCounter <= 0;
	else begin
		if(inputValid & !readSignal) //input is valid, but no read yet
			startCounter <= startCounter + 1;
	end
end

//writeCounter
always @(posedge clk) begin
	if(rst)
		writeCounter <= 0;
	else begin
		if(inputValid) begin
			if(writeCounter == `WIDTH-1)
				writeCounter <= 0;
			else
				writeCounter <= writeCounter + 1;
		end
	end
end

//currentWriteBuffer
always @(posedge clk) begin
	if(rst)
		currentWriteBuffer <= 0;
	else begin
		if(writeCounter == `WIDTH-1 & inputValid) begin
			if(currentWriteBuffer==2)
				currentWriteBuffer <= 0;
			else
				currentWriteBuffer <= currentWriteBuffer + 1;
		end
	end
end


//bufferDataValid
always @(*) begin
	bufferDataValid = 3'b0;
	bufferDataValid[currentWriteBuffer] = inputValid;
end


//readCounter
always @(posedge clk) begin
	if(rst)
		readCounter <= 0;
	else begin
		if(readSignal) begin
			if(readCounter == `WIDTH-1)
				readCounter <= 0;
			else
				readCounter <= readCounter + 1;
		end
	end
end


//currentReadBuffer
always @(posedge clk) begin
	if(rst) begin
		currentReadBuffer <= 0;
	end
	else begin
		if(readCounter == `WIDTH-1 & readSignal) begin
			if(currentReadBuffer==2) begin
				currentReadBuffer<=0;
			end
			else begin
				currentReadBuffer <= currentReadBuffer + 1;
			end
		end
	end
end

//outputData
always @(*) begin
	case(currentReadBuffer)
	0: begin
		outputData <= {buffer1Data, buffer2Data, buffer0Data};
	end
	1: begin
		outputData <= {buffer2Data, buffer0Data, buffer1Data};
	end
	2: begin
		outputData <= {buffer0Data, buffer1Data, buffer2Data};
	end
	endcase
end

endmodule
