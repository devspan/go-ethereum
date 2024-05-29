package main

import (
    "log"
    "os"
    "github.com/consensys/gnark/frontend"
    "github.com/consensys/gnark/backend/groth16"
    "github.com/consensys/gnark/std/algebra/sw_bls12381"
    "github.com/yourusername/go-ethereum/zkp"
)

func main() {
    var circuit zkp.TransactionCircuit

    // Compile the circuit
    r1cs, err := frontend.Compile(sw_bls12381.New(), frontend.Groth16, &circuit)
    if err != nil {
        log.Fatal(err)
    }

    // Generate proving and verification keys
    pk, vk, err := groth16.Setup(r1cs)
    if err != nil {
        log.Fatal(err)
    }

    // Save the proving key
    pkFile, err := os.Create("zkp/proving.key")
    if err != nil {
        log.Fatal(err)
    }
    defer pkFile.Close()
    err = groth16.WriteProvingKey(pkFile, pk)
    if err != nil {
        log.Fatal(err)
    }

    // Save the verifying key
    vkFile, err := os.Create("zkp/verifying.key")
    if err != nil {
        log.Fatal(err)
    }
    defer vkFile.Close()
    err = groth16.WriteVerifyingKey(vkFile, vk)
    if err != nil {
        log.Fatal(err)
    }

    log.Println("Circuit compiled and keys generated successfully")
}
