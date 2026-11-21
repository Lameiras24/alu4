
import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_connection(dut):

    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1
    dut.clk.value = 0
    dut.rst_n.value = 1

    await Timer(10, unit="ns")

    output = str(dut.uo_out.value)

    dut._log.info(f"Diagnostic output: {output}")

    assert output == "10100101", (
        f"Module connection failed: got {output}, "
        "expected 10100101"
    )
