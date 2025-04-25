module radix2_fft_4point (
    input wire clk,
    input wire rst,
    input wire valid_in,
    input wire signed [7:0] real_in,
    input wire signed [7:0] imag_in,
    output reg valid_out,
    output reg signed [9:0] real_out,
    output reg signed [9:0] imag_out
);
    reg [1:0] input_count;
    reg [1:0] output_count;
    reg collecting;
    reg calculating;
    reg outputting;
    reg signed [7:0] x_real [0:3];
    reg signed [7:0] x_imag [0:3];
    reg signed [9:0] y_real [0:3];
    reg signed [9:0] y_imag [0:3];
    reg process_trigger;
 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            input_count <= 0;
            output_count <= 0;
            collecting <= 1;
            calculating <= 0;
            outputting <= 0;
            valid_out <= 0;
            process_trigger <= 0;
            real_out <= 0;
            imag_out <= 0;
        end
        else begin
            process_trigger <= 0;
            valid_out <= 0;

            if (collecting && valid_in) begin
                x_real[input_count] <= real_in;
                x_imag[input_count] <= imag_in;
                
                if (input_count == 2'b11) begin
                    collecting <= 0;
                    calculating <= 1;
                    process_trigger <= 1;
                    input_count <= 0;
                end else begin
                    input_count <= input_count + 1;
                end
            end

            if (calculating && process_trigger) begin
                
                // FFT[0] = (x[0] + x[2]) + (x[1] + x[3])
                y_real[0] <= (x_real[0] + x_real[2]) + (x_real[1] + x_real[3]);
                y_imag[0] <= (x_imag[0] + x_imag[2]) + (x_imag[1] + x_imag[3]);
                
                // FFT[1] = (x[0] - x[2]) + j(x[3] - x[1])
                y_real[1] <= (x_real[0] - x_real[2]) + (x_imag[1] - x_imag[3]);
                y_imag[1] <= (x_imag[0] - x_imag[2]) - (x_real[1] - x_real[3]);
                
                // FFT[2] = (x[0] + x[2]) - (x[1] + x[3])
                y_real[2] <= (x_real[0] + x_real[2]) - (x_real[1] + x_real[3]);
                y_imag[2] <= (x_imag[0] + x_imag[2]) - (x_imag[1] + x_imag[3]);
                
                // FFT[3] = (x[0] - x[2]) - j(x[3] - x[1])
                y_real[3] <= (x_real[0] - x_real[2]) - (x_imag[1] - x_imag[3]);
                y_imag[3] <= (x_imag[0] - x_imag[2]) + (x_real[1] - x_real[3]);
                
                calculating <= 0;
                outputting <= 1;
            end

            if (outputting) begin
                valid_out <= 1;
                real_out <= y_real[output_count];
                imag_out <= y_imag[output_count];
                
                if (output_count == 2'b11) begin
                    outputting <= 0;
                    collecting <= 1;
                    output_count <= 0;
                end else begin
                    output_count <= output_count + 1;
                end
            end
        end
    end
endmodule

`timescale 1ns / 1ps
module radix2_fft_4point_tb;
    reg clk = 0;
    reg rst = 0;
    reg valid_in = 0;
    reg signed [7:0] real_in = 0;
    reg signed [7:0] imag_in = 0;
    wire valid_out;
    wire signed [9:0] real_out;
    wire signed [9:0] imag_out;
    
    radix2_fft_4point dut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .real_in(real_in),
        .imag_in(imag_in),
        .valid_out(valid_out),
        .real_out(real_out),
        .imag_out(imag_out)
    );

    always #5 clk = ~clk;

    initial begin
        rst = 1;
        #20 rst = 0;
        #10;

        valid_in = 1;
        real_in = 8'd2; imag_in = 8'd0; #10;
        real_in = 8'd0; imag_in = 8'd0; #10;
        real_in = 8'd1; imag_in = 8'd0; #10;
        real_in = 8'd6; imag_in = 8'd0; #10;
        valid_in = 0;
        #50;

        rst = 1;
        #20 rst = 0;
        #10;

        valid_in = 1;
        real_in = 8'd1; imag_in = 8'd8; #10;
        real_in = 8'd1; imag_in = -8'd8; #10;
        real_in = -8'd1; imag_in = 8'd8; #10;
        real_in = -8'd1; imag_in = -8'd8; #10;
        valid_in = 0;
        #50;$finish;
    end

    initial begin
        $monitor("Time=%0t: valid_out=%b, real_out=%d, imag_out=%d", 
                 $time, valid_out, real_out, imag_out);
    end

    initial begin
        $dumpfile("fft_tb.vcd");
        $dumpvars(0, radix2_fft_4point_tb);
    end
endmodule