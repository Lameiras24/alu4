
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
            ((a ^ b) & 8) == 0 and
            ((a ^ y) & 8) != 0
        )

    elif op == 1:
        y = (a - b) & 0xF
        carry = int(a >= b)
        overflow = int(
            ((a ^ b) & 8) != 0 and
            ((a ^ y) & 8) != 0
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

    elif op == 7:
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

    await Timer(10, unit="ns")

    for a in range(16):
        for b in range(16):
            for op in range(8):

                dut.ui_in.value = (b << 4) | a
                dut.uio_in.value = op

                await Timer(10, unit="ns")

                # Read output as binary string
                output_bits = str(dut.uo_out.value)

                # Detect X and Z values
                assert all(bit in "01" for bit in output_bits), (
                    f"UNKNOWN OUTPUT: A={a}, B={b}, OP={op}, "
                    f"uo_out={output_bits}"
                )

                actual = int(output_bits, 2)
                expected = alu_reference(a, b, op)

                assert actual == expected, (
                    f"FAIL: A={a}, B={b}, OP={op}, "
                    f"Expected={expected:08b}, "
                    f"Actual={actual:08b}"
                )

    # Check bidirectional outputs
    oe_bits = str(dut.uio_oe.value)

    assert oe_bits == "00000000", (
        f"Unexpected uio_oe: {oe_bits}"
    )

    dut._log.info("PASS: All 2048 ALU4 tests passed!")
