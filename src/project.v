
/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 * 4-bit ALU - Tiny Tapeout SKY130
 */

`default_nettype none

module tt_um_alu4 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,

    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    // Input mapping
    wire [3:0] A = ui_in[3:0];
    wire [3:0] B = ui_in[7:4];
    wire [2:0] OP = uio_in[2:0];

    // Internal signals
    reg [3:0] Y;
    reg CARRY;
    reg OVERFLOW;
    reg [4:0] temp;

    wire ZERO;

    // ALU operations
    always @(*) begin

        Y        = 4'b0000;
        CARRY    = 1'b0;
        OVERFLOW = 1'b0;
        temp     = 5'b00000;

        case (OP)

            // ADD
            3'b000: begin
                temp = {1'b0, A} + {1'b0, B};
                Y = temp[3:0];
                CARRY = temp[4];

                OVERFLOW = (~(A[3] ^ B[3])) &
                           (A[3] ^ Y[3]);
            end

            // SUB
            3'b001: begin
                temp = {1'b0, A} - {1'b0, B};
                Y = temp[3:0];
                CARRY = (A >= B);

                OVERFLOW = (A[3] ^ B[3]) &
                           (A[3] ^ Y[3]);
            end

            // AND
            3'b010:
                Y = A & B;

            // OR
            3'b011:
                Y = A | B;

            // XOR
            3'b100:
                Y = A ^ B;

            // NOT A
            3'b101:
                Y = ~A;

            // SHIFT LEFT
            3'b110:
                Y = A << 1;

            // SHIFT RIGHT
            3'b111:
                Y = A >> 1;

            default: begin
                Y = 4'b0000;
                CARRY = 1'b0;
                OVERFLOW = 1'b0;
            end

        endcase
    end

    // Status flags
    assign ZERO = (Y == 4'b0000);

    // Output mapping
    assign uo_out = {
        1'b0,
        OVERFLOW,
        ZERO,
        CARRY,
        Y
    };

    // Unused bidirectional GPIO
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

endmodule

`default_nettype wire
