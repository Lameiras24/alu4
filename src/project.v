/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_alu (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [2:0] OP,

    output reg  [3:0] Y,
    output reg        CARRY,
    output wire       ZERO,
    output reg        OVERFLOW
);

    reg [4:0] temp;

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
            3'b010: Y = A & B;

            // OR
            3'b011: Y = A | B;

            // XOR
            3'b100: Y = A ^ B;

            // NOT
            3'b101: Y = ~A;

            // Shift left
            3'b110: Y = A << 1;

            // Shift right
            3'b111: Y = A >> 1;

            default: Y = 4'b0000;

        endcase
    end

    assign ZERO = (Y == 4'b0000);

endmodule