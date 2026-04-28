\\`timescale 1ns/1ps

module tb_project;

  reg  [7:0] ui_in;
  reg [7:0] uio_in;
  reg ena;
  reg rst_n;
  reg clk;
  reg [31:0] seed;

  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
  

  tt_um_ashergitscrazy dut (
      .ui_in(ui_in),
      .uo_out(uo_out),
      .uio_in(uio_in),
      .uio_out(uio_out),
      .uio_oe(uio_oe),
      .rst_n(rst_n),
      .ena(ena),
      .clk(clk)


  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_project);
  end

  initial begin
    ena = 1;
    ui_in = 8'b00000000;
    uio_in = 8'b00000000;
    
    rst_n = 0;
    #20;
    rst_n = 1;
    #60;

    $display("Directed testing");
    ui_in = 8'b00011001;
    #60;

    ui_in = 8'b00000010;
    #60;

    ui_in = 8'b00000100;
    #60;

    ui_in = 8'b11111111;
    #60;

    $display("Random testing");
    for(integer i = 0; i < 10; i+=1) begin
      ui_in = {$random(seed)} % 256;
      #60;
    end
    $finish;
  end

endmodule