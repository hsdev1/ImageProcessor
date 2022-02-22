`timescale 1ns/1ps
`define WIDTH 640
`define HEIGHT 480

module tb_ImageProcessing 
#(parameter INPUT_FILE = "input_rgb.raw",
  parameter OUTPUT_FILE = "output_rgb.raw")
();
	integer file_in, file_out, i, writeSize=0;
	reg clk;
	reg rst;
	reg [7:0] inputR;
	reg [7:0] inputG;
	reg [7:0] inputB;
	reg inputDataValid;
	wire outputDataValid;
	wire [7:0] outputR;
	wire [7:0] outputG;
	wire [7:0] outputB;
	
ImageProcessing tb_R(clk, rst, inputDataValid, inputR, outputDataValid, outputR);
ImageProcessing tb_G(clk, rst, inputDataValid, inputG, outputDataValid, outputG);
ImageProcessing tb_B(clk, rst, inputDataValid, inputB, outputDataValid, outputB);
	
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
	$fscanf(file_in, "%c", inputR);
	$fscanf(file_in, "%c", inputG);
	$fscanf(file_in, "%c", inputB);
	inputDataValid<=1;
end
		@(posedge clk);
		inputDataValid<=0;
		$fclose(file_in);
	end
	
	always @(posedge clk) begin
if(outputDataValid) begin
	$fwrite(file_out,"%c",outputR); //wirte 1 byte pixel data
	$fwrite(file_out,"%c",outputG);
	$fwrite(file_out,"%c",outputB);
	writeSize = writeSize + 1;
end
		//done
		if(writeSize == `WIDTH * `HEIGHT) begin
			$fclose(file_out);
			$stop; //stop tb
		end
	end

endmodule
