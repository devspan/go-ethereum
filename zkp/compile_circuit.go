package zkp

import (
    "log"
    "os"

    "github.com/consensys/gnark/backend/groth16"
    "github.com/consensys/gnark/frontend"
    "github.com/consensys/gnark-crypto/ecc/bn254"
)

func CompileCircuit() {
    var circuit TransactionCircuit

    // Compile the circuit
    r1cs, err := frontend.Compile(bn254.New(), frontend.Groth16, &circuit)
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
    _, err = pk.WriteTo(pkFile)
    if err != nil {
        log.Fatal(err)
    }

    // Save the verifying key
    vkFile, err := os.Create("zkp/verifying.key")
    if err != nil {
        log.Fatal(err)
    }
    defer vkFile.Close()
    _, err = vk.WriteTo(vkFile)
    if err != nil {
        log.Fatal(err)
    }

    log.Println("Circuit compiled and keys generated successfully")
}
