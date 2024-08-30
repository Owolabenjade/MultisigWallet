# Multi-Signature Wallet (Multisig) Smart Contract

## Overview

This project is a Multi-Signature Wallet (Multisig) smart contract implemented in Clarity, a programming language for smart contracts on the Stacks blockchain. A Multisig wallet requires multiple authorized owners to approve a transaction before it can be executed. This ensures enhanced security and accountability for managing funds on the blockchain.

## Features

- **Multi-Signature Approval:** Transactions require multiple approvals from authorized wallet owners before execution.
- **Owner Management:** Authorized owners can add new owners to the wallet.
- **Transaction Submission:** Owners can propose transactions to be approved by other owners.
- **Approval Process:** Transactions are approved by authorized owners, and a transaction must reach the required number of approvals before it can be executed.
- **Execution of Transactions:** Approved transactions can be executed, transferring the specified amount of STX to the designated recipient.

## Smart Contract Components

### 1. **Constants**
   - **ERR_NOT_AUTHORIZED:** Error code `u100` for unauthorized actions.
   - **ERR_INSUFFICIENT_APPROVALS:** Error code `u101` for insufficient approvals.
   - **ERR_ALREADY_APPROVED:** Error code `u102` when an owner tries to approve a transaction they've already approved.
   - **ERR_TRANSACTION_NOT_FOUND:** Error code `u103` for non-existent transactions.
   - **ERR_INVALID_TRANSFER_AMOUNT:** Error code `u104` for invalid transfer amounts.

### 2. **Data Variables**
   - **wallet-owners:** A list of principals who are authorized to manage the wallet.
   - **required-approvals:** The number of approvals required to execute a transaction.
   - **transaction-records:** A map of transaction IDs to transaction details, including the amount, recipient, list of approvals, and execution status.
   - **transaction-id-counter:** A counter to track the number of submitted transactions.

### 3. **Functions**
   - **is-authorized-owner(user):** Checks if a given principal is an authorized owner of the wallet.
   - **add-wallet-owner(new-owner):** Adds a new principal to the list of authorized wallet owners.
   - **submit-wallet-transaction(recipient, transfer-amount):** Submits a new transaction for approval by the wallet owners.
   - **approve-wallet-transaction(tx-id):** Approves a submitted transaction by an authorized owner.
   - **execute-wallet-transaction(tx-id):** Executes a transaction that has received the required number of approvals.


## Security Considerations

- **Authorization:** Ensure that only authorized owners can submit, approve, and execute transactions.
- **Approvals:** Be mindful of setting the `required-approvals` to a number that balances security with usability.
- **Error Handling:** The contract includes error handling for unauthorized actions, insufficient approvals, duplicate approvals, and invalid transactions.

## Contributing

Contributions are welcome! If you find bugs, have feature requests, or want to improve the code, feel free to fork the repository and submit a pull request.