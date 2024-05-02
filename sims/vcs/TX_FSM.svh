// Description: This file contains the SystemVerilog assertions for the TX FSM module
// TODO: Find the actual verilog pin name of the following signals and replace them
`define clock clk
`define reset rst
`define fsm_state state
`define counter bit_cnt
`define fsm_data data

`define IDLE 2'b00
`define SYNCGEN 2'b01
`define DATATX 2'b10
`define EOPGEN 2'b11

`define in_valid tx_valid_i
`define in_ready tx_ready_o
`define out_valid tx_valid_o
`define out_ready tx_ready_i

// FSM state checks
// It generally follow the spec provided by Intel, but it seems like TX team has changed the structure, so some adjustments are made
property CheckIDLEToSYNCGEN;
  @(posedge `clock) disable iff (`reset)
  (`fsm_state == `IDLE && `in_valid) |-> ##1 (`fsm_state == `SYNCGEN && `fsm_data == 8'b10000000);
endproperty
CheckIDLEToSYNCGENAssertion: assert property (CheckIDLEToSYNCGEN);

property CheckSYNCGENToDATATX;
   @(posedge `clock) disable iff (`reset)
   (`fsm_state == `SYNCGEN && `counter == 0 && `out_ready == 1) |-> ##1 (`fsm_state == `DATATX);
endproperty
CheckSYNCGENToDATATXAssertion: assert property (CheckSYNCGENToDATATX);

property CheckDATATXToEOPGEN;
  @(posedge `clock) disable iff (`reset)
  (`fsm_state == `DATATX && `in_valid == 0) |-> ##1 (`fsm_state == `EOPGEN && `fsm_data == 8'b11111001 && `in_ready == 0);
endproperty
CheckDATATXToEOPGENAssertion: assert property (CheckDATATXToEOPGEN);

property CheckEOPGENToIDLE;
  @(posedge `clock) disable iff (`reset)
  (`fsm_state == `EOPGEN && `counter == 0) |-> ##1 (`fsm_state == `IDLE);
endproperty
 CheckEOPGENToIDLEAssertion: assert property (CheckEOPGENToIDLE);



// cover checks for FSM states to be reached
typedef enum {`IDLE, `SYNCGEN, `DATATX, `EOPGEN} StateType;
StateType STATE;

property CoverIDLE;
    @(posedge `clock) disable iff (`reset)
    `fsm_state == `IDLE;
endproperty;
property CoverSYNCGEN;
    @(posedge `clock) disable iff (`reset)
    `fsm_state == `SYNCGEN;
endproperty;
property CoverDATATX;
    @(posedge `clock) disable iff (`reset)
    `fsm_state == `DATATX;
endproperty;
property CoverEOPGEN;
    @(posedge `clock) disable iff (`reset)
    `fsm_state == `EOPGEN;
endproperty;

IDLE_C: cover property (CoverIDLE);
SYNCGEN_C: cover property (CoverSYNCGEN);
DATATX_C: cover property (CoverDATATX);
EOPGEN_C: cover property (CoverEOPGEN);
