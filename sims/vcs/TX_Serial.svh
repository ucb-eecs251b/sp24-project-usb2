// Description: This file contains the SystemVerilog assertions for the TX Serializer module
// TODO: Find the actual verilog pin name of the following signals and replace them
`define clockOut clkOut
`define serial_buffer shiftReg
`define pDataIn pDataIn
`define sDataOut sDataOut

genvar i;
generate
    for (i = 0; i < 8; i++) begin
        property p_check_serialized_bit;
        @(posedge clockOut)
            $past(pDataIn[i], 8) == sDataOut;
        endproperty

        assert property (p_check_serialized_bit)
        else $error("Serialized output bit %0d does not match the expected parallel input bit", i);
    end
endgenerate