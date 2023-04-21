pragma circom 2.1.2;

include "../node_modules/circomlib/circuits/mimc.circom";
include "../node_modules/circomlib/circuits/switcher.circom";
include "./mimc.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";

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
  signal input main_pub;
  signal input sub_pub;
  signal input user_info;
  signal input auth_hash;
  signal input credit_score;
  signal input timestamp;
  signal input root;
  signal input cur_timestamp;
  signal input condition;
  signal input direction[depth];
  signal input siblings[depth];

  // Check owner by auth hash 
  component MimcMulti = MultiMimc7(3, 91);
  MimcMulti.in[0] <== main_pub;
  MimcMulti.in[1] <== sub_pub;
  MimcMulti.in[2] <== user_info;
  MimcMulti.k <== 0;
  
  auth_hash === MimcMulti.out;

  component MimcMultiLeaf = MultiMimc7(3, 91);
  MimcMultiLeaf.in[0] <== auth_hash;
  MimcMultiLeaf.in[1] <== credit_score;
  MimcMultiLeaf.in[2] <== timestamp;
  MimcMultiLeaf.k <== 0;
  // component Mimc = Mimc7(91);

  component hashNode[depth+1];
  component selectiveSwitch[depth];
  component MimcUpdate[depth];

  hashNode[0] = Node();
  hashNode[0].leaf <== MimcMultiLeaf.out;

  for (var i = 0; i < depth; i++) {
    MimcUpdate[i] = MultiMimc7(2, 91);
    selectiveSwitch[i] = SelectiveSwitch();
    hashNode[i + 1] = Node();
    selectiveSwitch[i].in0 <== hashNode[i].out;
    selectiveSwitch[i].in1 <== siblings[i];
    selectiveSwitch[i].s <== direction[i];

    MimcUpdate[i].in[0] <== selectiveSwitch[i].out0;
    MimcUpdate[i].in[1] <== selectiveSwitch[i].out1;
    MimcUpdate[i].k <== 0;

    hashNode[i + 1].leaf <== MimcUpdate[i].out;
    log(hashNode[i+1].out);
  }

  // hashNode[depth].out === root;
}

component main = Verifier(4);