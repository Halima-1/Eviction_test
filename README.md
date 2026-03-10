##Eviction Vault – Owners Contract Refactor & Hardening


##EvictionVault Refactor & Security Fixes

Overview

-This project refactors and secures the original EvictionVault smart contract.
The initial implementation existed as a single-file monolithic contract containing multiple responsibilities (vault logic, multisig governance, Merkle claims, and access control). This structure made the contract harder to audit, maintain, and secure.

-The project reorganizes the system into a modular multi-contract architecture while fixing several critical security vulnerabilities discovered in the original implementation.


##The system now supports:

-Secure ETH deposits and withdrawals

-Multisig governance with timelock execution

-Merkle tree based claims

-Emergency pause control

-Improved ETH transfer safety

##Description of Each File
The main file was refractured into 5 different files which are EvictionVault.sol, VaultClaims.sol, VaultOwners.sol, VaultStorage.sol, and VaultTransaction.sol and the content of each files  are explained below.

-VaultStorage.sol

This contract contains all shared state variables and data structures used across the system.
It defines: Transaction struct, owner mappings,transaction storage, balance storage, Merkle claim tracking, vault accounting variables, Separating storage improves readability and avoids duplication across modules.

##VaultOwners.sol

This contract implements access control and emergency pause logic.

Features include:onlyOwner modifier, whenNotPaused modifier, pause() and unpause() functions

These controls ensure that sensitive operations can only be performed by vault owners and that the contract can be halted during emergencies.

##VaultTransactions.sol

This contract manages the multisignature governance system. It allows owners to:submit transactions, confirm transactions, execute transactions and Transactions require a configurable approval threshold and must pass a timelock delay before execution. This prevents instant execution of potentially malicious proposals.

##VaultClaims.sol

This contract handles Merkle tree based claim distributions. Users can claim funds if they are included in a Merkle tree generated off-chain. The contract verifies claims using OpenZeppelin’s MerkleProof library.

Security checks prevent:invalid proofs, duplicate claims, transfers while the contract is paused

##EvictionVault.sol

This is the main vault contract that users interact with. It integrates all modules and provides functionality for: deposits, withdrawals, multisig governance claims


Identified Vulnerabilities and Fixes
1. Public setMerkleRoot Vulnerability
Problem

In the original contract, the function for updating the Merkle root could be called by any address.

function setMerkleRoot(bytes32 root) external

An attacker could set their own Merkle root and claim all vault funds.

Fix

Access control was added using the onlyOwner modifier.

function setMerkleRoot(bytes32 root)
    external
    onlyOwner

This ensures that only trusted vault owners can update the claim distribution list.

2. Public emergencyWithdrawAll Function
Problem

The original contract allowed any user to drain the entire vault balance.

function emergencyWithdrawAll() external

This created a critical vulnerability where attackers could steal all funds instantly.

Fix

The function is now restricted to vault owners.

function emergencyWithdrawAll() external onlyOwner

This prevents unauthorized withdrawals.

3. Single Owner Pause Control
Problem

Pause functionality lacked structured access control in the original implementation.

This could lead to unintended contract freezing or misuse.

Fix

A dedicated owner access layer was implemented.

modifier onlyOwner()
modifier whenNotPaused()

Sensitive operations now require owner authorization and pause checks.

4. Use of tx.origin in receive()
Problem

The original implementation used:

balances[tx.origin]

Using tx.origin introduces phishing attack risks, because malicious contracts can trick users into unintentionally authorizing actions.

Fix

Replaced with the safer:

balances[msg.sender]

This ensures that the immediate caller is credited correctly.

5. Unsafe ETH Transfer using .transfer
Problem

The original contract used:

payable(msg.sender).transfer(amount)

.transfer() forwards only 2300 gas, which may cause transactions to fail when interacting with smart contracts.

Fix

Replaced with .call, which is now the recommended pattern.

(bool success,) = payable(msg.sender).call{value: amount}("");
require(success, "transfer failed");

This ensures compatibility with modern smart contracts.

6. Timelock Validation
Problem

Transaction execution relied on a timelock but lacked strict validation checks.

This could allow execution without a properly set delay.

Fix

Additional checks were implemented:

require(txn.executionTime != 0);
require(block.timestamp >= txn.executionTime);

These ensure that transactions can only execute after the timelock expires.