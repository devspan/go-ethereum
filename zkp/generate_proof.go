package zkp

import (
    "github.com/consensys/gnark/backend/groth16"
    "github.com/consensys/gnark/frontend"
    "github.com/consensys/gnark-crypto/ecc/bls12-381/fr"
    "os"
)

func GenerateProof(senderBalance, receiverBalance, amount, newSenderBalance, newReceiverBalance frontend.Variable) ([]byte, error) {
    // Load the proving key
    pkFile, err := os.Open("zkp/proving.key")
    if err != nil {
        return nil, err
    }
    defer pkFile.Close()
    pk, err := groth16.ReadProvingKey(pkFile)
    if err != nil {
        return nil, err
    }

    // Create the witness
    witness := &TransactionCircuit{
        SenderBalance:     senderBalance,
        ReceiverBalance:   receiverBalance,
        Amount:            amount,
        NewSenderBalance:  newSenderBalance,
        NewReceiverBalance: newReceiverBalance,
    }

    // Compile the circuit
    builder := frontend.NewBuilder()
    r1cs, err := frontend.Compile(fr.Modulus(), builder, witness)
    if err != nil {
        return nil, err
    }

    // Generate the proof
    proof, err := groth16.Prove(r1cs, pk, witness)
    if err != nil {
        return nil, err
    }

    // Serialize the proof
    proofBytes, err := proof.MarshalBinary()
    if err != nil {
        return nil, err
    }

    return proofBytes, nil
}
