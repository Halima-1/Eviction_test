##Eviction Vault – Owners Contract Refactor & Hardening
Project Overview

##This project is part of the Nebula Yield – Eviction Vault Hardening Challenge. The original EvictionVault contract was a single-file monolith with multiple critical vulnerabilities.

The objective of this phase was to:

-Refactor the monolithic contract into a modular, multi-file architecture.

-Mitigate critical vulnerabilities.

-Implement a Foundry test suite to verify correct functionality.

-Ensure the contract compiles cleanly and passes all positive tests.

##Key Features

-Multi-sig transaction system: Submit, confirm, and execute transactions based on a configurable threshold.

-Timelock: Transactions cannot execute until a defined delay passes.

-Owner management: Prevent duplicate or zero-address owners, ensures only valid owners participate.

-Pause mechanism: Contract operations can be paused/unpaused safely by owners.

-Secure ETH transfers: Uses .transfer .

##Foundry Testing

- The test/Owners.t.sol suite includes:

- Submit Transaction – Verifies owners can submit transactions.

- Confirm Transaction – Confirms transactions and sets timelock when threshold reached.

 -Execute Transaction – Executes a confirmed transaction after the timelock.

- Multiple Confirmations – Tracks confirmations correctly beyond the threshold.

