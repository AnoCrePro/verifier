pragma circom 2.1.2;

include "../node_modules/circomlib/circuits/mimc.circom";
include "../node_modules/circomlib/circuits/switcher.circom";
include "./mimc.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template SelectiveSwitch() {
  signal input in0;
  signal input in1;
  signal input s;
  signal output out0;
  signal output out1;

  component Switch = Switcher();

  s*(s-1) === 0;

  Switch.sel <== s;
  Switch.L <== in0;
  Switch.R <== in1;

  out0 <== Switch.outL;
  out1 <== Switch.outR;
}

template Node () {
    signal input leaf;
    signal output out;

    out <== leaf;
}


template Verifier(depth) {
  signal input first;
  signal input second;

  // Check owner by auth hash 
  component MimcMulti = LessThan(8);
  MimcMulti.in[0] <== first;
  MimcMulti.in[1] <== second;
  
  log(MimcMulti.out);
}

component main = Verifier(4);