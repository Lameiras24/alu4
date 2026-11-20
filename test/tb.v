`default_nettype none

module tb;

    reg  [7:0] ui_in;
    wire [7:0] uo_out;

    reg  [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    reg ena;
    reg clk;
    reg rst_n;

    tt_um_alu4 dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    initial begin
        ui_in = 0;
        uio_in = 0;
        ena = 1;
        clk = 0;
        rst_n = 1;
    end

endmodule

`default_nettype wire
6. test/test.py
This Cocotb test exhaustively checks all 2,048 combinations of operands and operations.


python

import cocotb
from cocotb.triggers import Timer


def alu_reference(a, b, op):

    y = 0
    carry = 0
    overflow = 0

    if op == 0:
        result = a + b
        y = result & 0xF
        carry = (result >> 4) & 1
        overflow = int(
            ((a ^ b) & 0x8) == 0 and
            ((a ^ y) & 0x8) != 0
        )

    elif op == 1:
        y = (a - b) & 0xF
        carry = int(a >= b)
        overflow = int(
            ((a ^ b) & 0x8) != 0 and
            ((a ^ y) & 0x8) != 0
        )

    elif op == 2:
        y = a & b

    elif op == 3:
        y = a | b

    elif op == 4:
        y = a ^ b

    elif op == 5:
        y = (~a) & 0xF

    elif op == 6:
        y = (a << 1) & 0xF
        carry = (a >> 3) & 1

    elif op == 7:
        y = (a >> 1) & 0xF
        carry = a & 1

    zero = int(y == 0)

    return y, carry, zero, overflow


@cocotb.test()
async def test_alu(dut):

    dut.ena.value = 1
    dut.clk.value = 0
    dut.rst_n.value = 1

    for a in range(16):
        for b in range(16):
            for op in range(8):

                dut.ui_in.value = (b << 4) | a
                dut.uio_in.value = op

                await Timer(10, unit="ns")

                expected = alu_reference(a, b, op)

                result = int(dut.uo_out.value)

                actual = (
                    result & 0xF,
                    (result >> 4) & 1,
                    (result >> 5) & 1,
                    (result >> 6) & 1
                )

                assert actual == expected, (
                    f"FAIL: A={a}, B={b}, OP={op}, "
                    f"expected={expected}, actual={actual}"
                )

    assert int(dut.uio_oe.value) == 0

    dut._log.info("PASS: All 2048 ALU test cases passed!")
