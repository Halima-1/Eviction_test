// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

contract EvictionVault {
    uint256 public constant TIMELOCK_DURATION = 1 hours;

    bool public paused;
    uint256 public totalVaultValue;

    mapping(address => bool) public isOwner;
    mapping(address => uint256) public balances;

    event Deposit(address indexed depositor, uint256 amount);
    event Withdrawal(address indexed withdrawer, uint256 amount);

    function pause() external {
        require(isOwner[msg.sender]);
        paused = true;
    }

    function unpause() external {
        require(isOwner[msg.sender]);
        paused = false;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalVaultValue += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(!paused, "paused");
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        totalVaultValue -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    receive() external payable {
        balances[tx.origin] += msg.value;
        totalVaultValue += msg.value;
        emit Deposit(tx.origin, msg.value);
    }

    function emergencyWithdrawAll() external {
        payable(msg.sender).transfer(address(this).balance);
        totalVaultValue = 0;
    }
}
