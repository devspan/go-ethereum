package zkp

import (
    "os"

    "github.com/consensys/gnark/backend/groth16"
    "github.com/consensys/gnark/frontend"
    "github.com/consensys/gnark-crypto/ecc/bn254"
)

func VerifyProof(proofBytes []byte) (bool, error) {
    // Load the verification key
    vkFile, err := os.Open("zkp/verifying.key")
    if err != nil {
        return false, err
    }
    defer vkFile.Close()
    vk, err := groth16.ReadVerifyingKey(vkFile)
    if err != nil {
        return false, err
    }

    // Deserialize the proof
    var proof groth16.Proof
    err = proof.UnmarshalBinary(proofBytes)
    if err != nil {
        return false, err
    }

    // Verify the proof
    publicWitness := make([]frontend.Variable, 0) // Public inputs (if any)
    err = groth16.Verify(proof, vk, publicWitness)
    if err != nil {
        return false, err
    }

    return true, nil
}
