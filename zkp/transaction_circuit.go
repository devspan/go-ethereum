package zkp

import (
    "github.com/consensys/gnark/frontend"
)

type TransactionCircuit struct {
    SenderBalance    frontend.Variable
    ReceiverBalance  frontend.Variable
    Amount           frontend.Variable
    NewSenderBalance frontend.Variable
    NewReceiverBalance frontend.Variable
}

func (circuit *TransactionCircuit) Define(api frontend.API) error {
    // Ensure sender has enough balance
    api.AssertIsLessOrEqual(circuit.Amount, circuit.SenderBalance)

    // Calculate new balances
    newSenderBalance := api.Sub(circuit.SenderBalance, circuit.Amount)
    newReceiverBalance := api.Add(circuit.ReceiverBalance, circuit.Amount)

    // Enforce the new balances
    api.AssertIsEqual(circuit.NewSenderBalance, newSenderBalance)
    api.AssertIsEqual(circuit.NewReceiverBalance, newReceiverBalance)

    return nil
}
