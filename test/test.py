
import cocotb
from cocotb.triggers import Timer


def alu_reference(a, b, op):

    y = 0
    carry = 0
    overflow = 0

    # ADD
    if op == 0:
        result = a + b
        y = result & 0xF
        carry = (result >> 4) & 1

        overflow = int(
            ((a ^ b) & 0x8) == 0 and
            ((a ^ y) & 0x8) != 0
        )

    # SUB
    elif op == 1:
        y = (a - b) & 0xF
        carry = int(a >= b)

        overflow = int(
            ((a ^ b) & 0x8) != 0 and
            ((a ^ y) & 0x8) != 0
        )

    # AND
    elif op == 2:
        y = a & b

    # OR
    elif op == 3:
        y = a | b

    # XOR
    elif op == 4:
        y = a ^ b

    # NOT
    elif op == 5:
        y = (~a) & 0xF

    # SHIFT LEFT
    elif op == 6:
        y = (a << 1) & 0xF

    # SHIFT RIGHT
    elif op == 7:
        y = (a >> 1) & 0xF

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

                # Set operands
                dut.ui_in.value = (b << 4) | a

                # Set operation
                dut.uio_in.value = op

                # Allow combinational logic to settle
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

    dut._log.info(
        "PASS: All 2048 ALU test cases passed!"
    )
