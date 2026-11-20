
/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 *
 * 4-bit ALU for Tiny Tapeout SKY130
 *
 * Operations:
 * 000 - ADD
 * 001 - SUB
 * 010 - AND
 * 011 - OR
 * 100 - XOR
 * 101 - NOT
 * 110 - SHIFT LEFT
 * 111 - SHIFT RIGHT
 */

`default_nettype none

module tt_um_alu4 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,

    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // ============================================
    // INPUT MAPPING
    // ============================================

    wire [3:0] A;
    wire [3:0] B;
    wire [2:0] OP;

    assign A  = ui_in[3:0];
    assign B  = ui_in[7:4];
    assign OP = uio_in[2:0];

    // ============================================
    // INTERNAL SIGNALS
    // ============================================

    reg [3:0] Y;
    reg CARRY;
    reg OVERFLOW;

    reg [4:0] temp;

    wire ZERO;

    // ============================================
    // ALU OPERATIONS
    // ============================================

    always @(*) begin

        // Default values
        Y        = 4'b0000;
        CARRY    = 1'b0;
        OVERFLOW = 1'b0;
        temp     = 5'b00000;

        case (OP)

            // ------------------------------------
            // ADDITION
            // ------------------------------------
            3'b000: begin

                temp = {1'b0, A} + {1'b0, B};

                Y = temp[3:0];

                CARRY = temp[4];

                OVERFLOW = (~(A[3] ^ B[3])) &
                           (A[3] ^ Y[3]);

            end

            // ------------------------------------
            // SUBTRACTION
            // ------------------------------------
            3'b001: begin

                temp = {1'b0, A} - {1'b0, B};

                Y = temp[3:0];

                CARRY = (A >= B);

                OVERFLOW = (A[3] ^ B[3]) &
                           (A[3] ^ Y[3]);

            end

            // ------------------------------------
            // BITWISE AND
            // ------------------------------------
            3'b010: begin

                Y = A & B;

            end

            // ------------------------------------
            // BITWISE OR
            // ------------------------------------
            3'b011: begin

                Y = A | B;

            end

            // ------------------------------------
            // BITWISE XOR
            // ------------------------------------
            3'b100: begin

                Y = A ^ B;

            end

            // ------------------------------------
            // BITWISE NOT
            // ------------------------------------
            3'b101: begin

                Y = ~A;

            end

            // ------------------------------------
            // SHIFT LEFT
            // ------------------------------------
            3'b110: begin

                Y = A << 1;

            end

            // ------------------------------------
            // SHIFT RIGHT
            // ------------------------------------
            3'b111: begin

                Y = A >> 1;

            end

            default: begin

                Y        = 4'b0000;
                CARRY    = 1'b0;
                OVERFLOW = 1'b0;

            end

        endcase

    end

    // ============================================
    // STATUS FLAGS
    // ============================================

    assign ZERO = (Y == 4'b0000);

    // ============================================
    // OUTPUT MAPPING
    // ============================================

    assign uo_out[3:0] = Y;

    assign uo_out[4] = CARRY;

    assign uo_out[5] = ZERO;

    assign uo_out[6] = OVERFLOW;

    assign uo_out[7] = 1'b0;

    // ============================================
    // UNUSED BIDIRECTIONAL GPIO
    // ============================================

    assign uio_out = 8'b00000000;

    assign uio_oe = 8'b00000000;

endmodule

`default_nettype wire
