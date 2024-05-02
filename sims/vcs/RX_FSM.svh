// Description: This file contains the SystemVerilog assertions for the TX FSM module
// TODO: Find the actual verilog pin name of the following signals and replace them
`define clock clk
`define reset rst
`define fsm_state state
`define fsm_data data

`define RX_WAIT     2'b000
`define STRIP_EOP   2'b001
`define STRIP_SYNC  2'b010
`define RX_DATA     2'b011
`define ERROR       2'b100
`define ABORT       2'b101
`define TERMINATE   2'b110

`define sync sync
`define rxActive rxActive
`define rxValid rxValid
`define rxError rxError
`define fifoReady fifoReady
`define eop eop


// FSM state transition checks
property CheckRX_WAITStays;
  @(posedge `clock) disable iff (`reset)
    (`fsm_state == `RX_WAIT && `sync == 1'b0) |-> ##1 (`fsm_state == `RX_WAIT);
endproperty
CheckRX_WAITStaysAssertion: assert property (CheckRX_WAITStays);

property CheckRX_WAITtoSTRIP_SYNC;
  @(posedge `clock) disable iff (`reset)
    (`fsm_state == `RX_WAIT && `sync == 1'b1) |-> ##1 (`fsm_state == `STRIP_SYNC && `rxActive == 1'b1);
endproperty
CheckRX_WAITtoSTRIP_SYNCAssertion: assert property (CheckRX_WAITtoSTRIP_SYNC);

// For here, we assume we will detect the input data to be the start of package signal, and either stay or advance
property CheckSTRIP_SYNCStay;
  @(posedge `clock) disable iff (`reset)
    (`fsm_state == `STRIP_SYNC && `sync == 1'b1 && `fifoReady == 1'b0) |-> ##1 (`fsm_state == `STRIP_SYNC);
endproperty
CheckSTRIP_SYNCStayAssertion: assert property (CheckSTRIP_SYNCStay);

property CheckSTRIP_SYNCToRX_DATA;
  @(posedge `clock) disable iff (`reset)
    (`fsm_state == `STRIP_SYNC && `fifoReady == 1'b1) |-> ##1 (`fsm_state == `RX_DATA);
endproperty
CheckSTRIP_SYNCToRX_DATAAssertion: assert property (CheckSTRIP_SYNCToRX_DATA);

property CheckRX_DATAtoERROR;
  @(posedge `clock) disable iff (`reset)
    (`fsm_state == `RX_DATA && `rxError == 1'b1) |-> ##1 (`fsm_state == `ERROR);
endproperty
CheckRX_DATAtoERRORAssertion: assert property (CheckRX_DATAtoERROR);

// For here, we assume we can check data to see if the package is eop information, so that we can exit to the eop state
property CheckRX_DATAtoSTRIP_EOP;
  @(posedge `clock) disable iff (`reset)
    (`fsm_state == `RX_DATA && `eop == 1'b1) |-> ##1 (`fsm_state == `STRIP_EOP && `rxActive == 1'b0 && `rxValid == 1'b0);
endproperty
CheckRX_DATAtoSTRIP_EOPAssertion: assert property (CheckRX_DATAtoSTRIP_EOP);

property CheckSTRIP_EOPtoRX_WAIT;
  @(posedge `clock) disable iff (`reset)
    (`fsm_state == `STRIP_EOP) |-> ##1 (`fsm_state == `RX_WAIT);
endproperty
CheckSTRIP_EOPtoRX_WAITAssertion: assert property (CheckSTRIP_EOPtoRX_WAIT);

property CheckERRORtoABORT;
  @(posedge `clock) disable iff (`reset)
    (`fsm_state == `ERROR) |-> ##1 (`fsm_state == `ABORT && `rxValid == 1'b0 && `rxError == 1'b0);
endproperty
CheckERRORtoABORTAssertion: assert property (CheckERRORtoABORT);

property CheckABORTtoTERMINATE;
  @(posedge `clock) disable iff (`reset)
    (`fsm_state == `ABORT) |-> ##1 (`fsm_state == `TERMINATE && `rxActive == 1'b0);
endproperty
CheckABORTtoTERMINATEAssertion: assert property (CheckABORTtoTERMINATE);

property CheckTERMINATEtoRX_WAIT;
  @(posedge `clock) disable iff (`reset)
    (`fsm_state == `TERMINATE) |-> ##1 (`fsm_state == `RX_WAIT);
endproperty
CheckTERMINATEtoRX_WAITAssertion: assert property (CheckTERMINATEtoRX_WAIT);



// cover checks for FSM states to be reached
typedef enum {`RX_WAIT, `STRIP_EOP, `STRIP_SYNC, `RX_DATA, `ERROR, `ABORT, `TERMINATE} NewStateType;
NewStateType NEW_STATE;

property CoverRX_WAIT;
    @(posedge `clock) disable iff (`reset)
    `fsm_state == `RX_WAIT;
endproperty;
property CoverSTRIP_EOP;
    @(posedge `clock) disable iff (`reset)
    `fsm_state == `STRIP_EOP;
endproperty;
property CoverSTRIP_SYNC;
    @(posedge `clock) disable iff (`reset)
    `fsm_state == `STRIP_SYNC;
endproperty;
property CoverRX_DATA;
    @(posedge `clock) disable iff (`reset)
    `fsm_state == `RX_DATA;
endproperty;
property CoverERROR;
    @(posedge `clock) disable iff (`reset)
    `fsm_state == `ERROR;
endproperty;
property CoverABORT;
    @(posedge `clock) disable iff (`reset)
    `fsm_state == `ABORT;
endproperty;
property CoverTERMINATE;
    @(posedge `clock) disable iff (`reset)
    `fsm_state == `TERMINATE;
endproperty;

RX_WAIT_C: cover property (CoverRX_WAIT);
STRIP_EOP_C: cover property (CoverSTRIP_EOP);
STRIP_SYNC_C: cover property (CoverSTRIP_SYNC);
RX_DATA_C: cover property (CoverRX_DATA);
ERROR_C: cover property (CoverERROR);
ABORT_C: cover property (CoverABORT);
TERMINATE_C: cover property (CoverTERMINATE);
