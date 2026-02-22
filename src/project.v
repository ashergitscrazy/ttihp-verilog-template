/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_ashergitscrazy (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  parameter IDLE = 2'b00;
  parameter RUN = 2'b01;
  parameter DONE = 2'b10;


  reg [1:0] state, next_state;

  reg [9:0] remainder, remainder_next;
  reg [7:0] root, root_next;
  reg [1:0] counter, counter_next;

  reg [4:0] test_num;
  
  always @(posedge clk) begin

    if (!rst_n) begin
      state <= IDLE;
      remainder <= 0;
      root <= 0;
      counter <= 0;
    end else begin
      state <= next_state;
      remainder <= remainder_next;
      root <= root_next;
      counter <= counter_next;
    end

  end

  assign uo_out = root;

  always @(*) begin

    next_state = state;
    remainder_next = remainder;
    root_next = root;
    counter_next = counter;

    case(state)

      IDLE: begin
        if (ena) begin
          remainder_next = 0;
          root_next = ui_in;
          counter_next = 0;
          next_state = RUN;
        end
      end

      RUN: begin
        // This changes remainder to be remainder with leading digit pair of input appended
        remainder_next = (remainder << 2) | root[7:6];
        // Prepares 2R + 1, this multiplies root by 2 and changes LSB to 1
        test_num = (root << 1) | 1;

        // Condition: remainder - test_num is non-negative, so subtraction is allowed
        if (remainder_next >= test_num) begin
            remainder_next = remainder_next - test_num;
            root = (root << 1) | 1;
        end
        
        // Result would be negative, so multiplying root by 2 again
        else begin
          root = (root << 1);
        end
        
        root_next = root << 2;

        counter_next = counter + 1;
        if (counter == 3) next_state = DONE;
      end

      DONE: begin
        next_state = IDLE;
      end
      

    endcase

  end

  wire _unused = &{uio_in, uio_out, uio_oe, 1'b0};

endmodule
