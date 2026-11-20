
import cocotb
from cocotb.triggers import Timer


def alu_reference(a, b, op):
    y = 0
    carry = 0
    overflow = 0

    if op == 0:  # ADD
        result = a + b
        y = result & 0xF
        carry = (result >> 4) & 1
        overflow = int(
            ((a ^ b) & 8) == 0 and
            ((a ^ y) & 8) != 0
        )

    elif op == 1:  # SUB
        y = (a - b) & 0xF
        carry = int(a >= b)
        overflow = int(
            ((a ^ b) & 8) != 0 and
            ((a ^ y) & 8) != 0
        )

    elif op == 2:  # AND
        y = a & b

    elif op == 3:  # OR
        y = a | b

    elif op == 4:  # XOR
        y = a ^ b

    elif op == 5:  # NOT
        y = (~a) & 0xF

    elif op == 6:  # SHIFT LEFT
        y = (a << 1) & 0xF

    elif op == 7:  # SHIFT RIGHT
        y = a >> 1

    zero = int(y == 0)

    return (
        y |
        (carry << 4) |
        (zero << 5) |
        (overflow << 6)
    )


@cocotb.test()
async def test_alu4(dut):

    dut.ena.value = 1
    dut.clk.value = 0
    dut.rst_n.value = 1

    # Test all 2048 combinations
    for a in range(16):
        for b in range(16):
            for op in range(8):

                dut.ui_in.value = (b << 4) | a
                dut.uio_in.value = op

                await Timer(10, unit="ns")

                expected = alu_reference(a, b, op)
                actual = int(dut.uo_out.value)

                assert actual == expected, (
                    f"FAIL: A={a}, B={b}, OP={op}, "
                    f"Expected={expected}, Actual={actual}"
                )

    # Check unused bidirectional outputs
    assert int(dut.uio_oe.value) == 0

    dut._log.info("PASS: All 2048 ALU4 tests passed!")
