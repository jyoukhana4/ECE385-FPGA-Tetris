`timescale 1ns / 1ps
//-------------------------------------------------------------------------
//    randomizer_7bag.sv                                                --
//    John Youkhana                                                     --
//    05-08-2025                                                        --
//
//    A stand-alone 7-bag randomizer for Tetris pieces.
//    Uses an LFSR for source of randomness and a Fisher-Yates shuffle
//    to permute a 7-element bag of tetromino IDs (2..8).
//-------------------------------------------------------------------------
/*
module Randomizer (
    input  logic        clk,         // main clock (e.g. frame_clk)
    input  logic        reset,       // active-high reset
    input  logic        next,        // pulse high to draw next piece
    output logic [2:0]  piece_id     // 2=O,3=I,4=S,5=Z,6=L,7=J,8=T
);

  logic [15:0] lfsr;
  logic [3:0] raw_value;

  // LFSR with maximal-length polynomial
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      lfsr <= 16'hACE1;
    end else if (next) begin
      lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
    end
  end

  // Output generation with guaranteed 0-5 range
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      piece_id <= 3'd0;
    end else if (next) begin
      // Combine bits from different positions
      raw_value <= lfsr[3:0] ^ lfsr[7:4] ^ lfsr[11:8];
      
      // Modulo 6 implementation without division
      if (raw_value >= 6) begin
        piece_id <= raw_value - 6;
      end else begin
        piece_id <= raw_value;
      end
    end
  end

endmodule*/