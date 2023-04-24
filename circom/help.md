circom main.circom --r1cs --wasm --sym --c
node generate_witness.js main.wasm ../all_input.json witness.wtns
snarkjs powersoftau new bn128 14 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="Notta" -v
Notta
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup main.r1cs pot12_final.ptau main_0000.zkey
snarkjs zkey contribute main_0000.zkey main_0001.zkey --name="Notta" -v
Notta
snarkjs zkey export verificationkey main_0001.zkey verification_key.json
snarkjs groth16 prove main_0001.zkey ./main_js/witness.wtns proof.json input.json
snarkjs groth16 verify verification_key.json input.json proof.json