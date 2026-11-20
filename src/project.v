
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

    wire [3:0] A = ui_in[3:0];
    wire [3:0] B = ui_in[7:4];
    wire [2:0] OP = uio_in[2:0];

    reg [3:0] Y;
    reg CARRY;
    reg OVERFLOW;
    reg [4:0] temp;

    wire ZERO;

    always @(*) begin
        Y = 4'b0000;
        CARRY = 1'b0;
        OVERFLOW = 1'b0;
        temp = 5'b00000;

        case (OP)

            3'b000: begin
                temp = {1'b0, A} + {1'b0, B};
                Y = temp[3:0];
                CARRY = temp[4];
                OVERFLOW = (~(A[3] ^ B[3])) &
                           (A[3] ^ Y[3]);
            end

            3'b001: begin
                temp = {1'b0, A} - {1'b0, B};
                Y = temp[3:0];
                CARRY = (A >= B);
                OVERFLOW = (A[3] ^ B[3]) &
                           (A[3] ^ Y[3]);
            end

            3'b010: Y = A & B;
            3'b011: Y = A | B;
            3'b100: Y = A ^ B;
            3'b101: Y = ~A;
            3'b110: Y = A << 1;
            3'b111: Y = A >> 1;

            default: begin
                Y = 4'b0000;
                CARRY = 1'b0;
                OVERFLOW = 1'b0;
            end
        endcase
    end

    assign ZERO = (Y == 4'b0000);

    assign uo_out = {
        1'b0,
        OVERFLOW,
        ZERO,
        CARRY,
        Y
    };

    assign uio_out = 8'b00000000;
    assign uio_oe = 8'b00000000;

endmodule

`default_nettype wire
