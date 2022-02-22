`timescale 1ns/1ps
`define WIDTH 640
`define HEIGHT 480

module tb_ImageProcessing 
#(parameter INPUT_FILE = "input.raw",
  parameter OUTPUT_FILE = "output.raw")
();
	integer file_in, file_out, i, writeSize=0;
	reg clk;
	reg rst;
	reg [7:0] inputData;
	reg inputDataValid;
	wire outputDataValid;
	wire [7:0] outputData;
	
	ImageProcessing tb_IP(clk, rst, inputDataValid, inputData, outputDataValid, outputData);
	
	initial begin
		clk = 0;
		forever begin
			#5 clk = ~clk;
		end
	end
	
	initial begin 
		rst = 1;
		inputDataValid = 0;
		#10;
		rst = 0;
		#10;
		file_in = $fopen(INPUT_FILE, "rb");	//read binary
		file_out = $fopen(OUTPUT_FILE, "wb"); //write binary
		for(i=0; i<`WIDTH*`HEIGHT; i=i+1) begin
			@(posedge clk);
			$fscanf(file_in, "%c", inputData); //read 1 byte pixel data
			inputDataValid<=1;
		end
		@(posedge clk);
		inputDataValid<=0;
		$fclose(file_in);
	end
	
	always @(posedge clk) begin
		if(outputDataValid) begin
			$fwrite(file_out,"%c",outputData); //wirte 1 byte pixel data
			writeSize = writeSize + 1;
		end
		//done
		if(writeSize == `WIDTH * `HEIGHT) begin
			$fclose(file_out);
			$stop; //stop tb
		end
	end

endmodule
