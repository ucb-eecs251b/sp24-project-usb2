// Description: This file contains the SystemVerilog assertions for the TX FSM module
// TODO: Find the actual verilog pin name of the following signals and replace them
`define CLOCK clk
`define RESET rst
`define STATE state
`define COUNTER bit_cnt
`define DATA data

`define Idle 2'b00
`define SyncGen 2'b01
`define DataTx 2'b10
`define EOPGen 2'b11

`define IN_VALID tx_valid_i
`define IN_READY tx_ready_o
`define OUT_VALID tx_valid_o
`define OUT_READY tx_ready_i

// FSM state checks
// It generally follow the spec provided by Intel, but it seems like TX team has changed the structure, so some adjustments are made
property CheckIdleToSyncGen;
  @(posedge CLOCK) disable iff (RESET)
  (STATE == Idle && IN_VALID) |-> ##1 (STATE == SyncGen && DATA == 8'b10000000);
endproperty
CheckTransitionAssertion: assert property (CheckTransition);

property CheckSyncGenToDataTx;
   @(posedge CLOCK) disable iff (RESET)
   (STATE == SyncGen && COUNTER == 0 && OUT_READY == 1) |-> ##1 (STATE == DataTx);
endproperty
SyncGenToDataTxAssertion: assert property (CheckSyncGenToDataTx);

property CheckDataTxToEOPGen;
  @(posedge CLOCK) disable iff (RESET)
  (STATE == DataTx && IN_VALID == 0) |-> ##1 (STATE == EOPGen && DATA == 8'b11111001 && IN_READY == 0);
endproperty
EOPTransitionAssertion: assert property (CheckEOPTransition);

property CheckEOPGenToIdle;
  @(posedge CLOCK) disable iff (RESET)
  (STATE == EOPGen && COUNTER == 0) |-> ##1 (STATE == Idle);
endproperty
ReturnToIdleAssertion: assert property (ReturnToIdle);
