// test/Owners.t.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Owners.sol";

contract OwnersTest is Test {
    Owners public ownersContract;

    address internal ganiyat;
    address internal halima;
    address internal isaac;
    address internal feyi;

    function setUp() public {
        // Create test addresses
        ganiyat = makeAddr("ganiyat");
        halima = makeAddr("halima");
        isaac = makeAddr("isaac");
        feyi = makeAddr("feyi");

        // Deploy contract with 3 owners and threshold 2
        address[] memory signers = new address[](3);
        signers[0] = ganiyat;
        signers[1] = halima;
        signers[2] = isaac;

        ownersContract = new Owners(signers, 2);

        // Fund the contract to allow transaction execution
        vm.deal(address(ownersContract), 5 ether);
    }

    // Test: submit a transaction
    function testSubmitTransaction() public {
        vm.prank(ganiyat);
        ownersContract.submitTransaction(halima, 1 ether, "");

        Owners.Transaction memory txn = ownersContract.transactions(0);

        assertEq(txn.to, halima);
        assertEq(txn.value, 1 ether);
        assertEq(txn.confirmations, 1); // submitter counts as first confirmation
        assertFalse(txn.executed);
    }

    // Test: confirmation sets timelock when threshold reached
    function testConfirmTransactionSetsTimelock() public {
        vm.prank(ganiyat);
        ownersContract.submitTransaction(halima, 1 ether, "");

        // Confirm with second owner
        vm.prank(isaac);
        ownersContract.confirmTransaction(0);

        Owners.Transaction memory txn = ownersContract.transactions(0);

        // Timelock should be set
        assertGt(txn.executionTime, 0);
        assertEq(txn.confirmations, 2);
    }

    // Test: execute transaction after timelock
    function testExecuteTransaction() public {
        vm.prank(ganiyat);
        ownersContract.submitTransaction(halima, 1 ether, "");

        // Confirm with second owner
        vm.prank(isaac);
        ownersContract.confirmTransaction(0);

        Owners.Transaction memory txnBefore = ownersContract.transactions(0);

        // Move time forward past timelock
        vm.warp(txnBefore.executionTime + 1);

        // Execute transaction
        vm.prank(ganiyat);
        ownersContract.executeTransaction(0);

        Owners.Transaction memory txnAfter = ownersContract.transactions(0);
        assertTrue(txnAfter.executed);
    }

    // Test: multiple confirmations
    function testMultipleConfirmations() public {
        vm.prank(ganiyat);
        ownersContract.submitTransaction(halima, 1 ether, "");

        // Confirm with second owner
        vm.prank(isaac);
        ownersContract.confirmTransaction(0);

        Owners.Transaction memory txn = ownersContract.transactions(0);
        assertEq(txn.confirmations, 2);

        vm.prank(halima);
        ownersContract.confirmTransaction(0);

        txn = ownersContract.transactions(0);
        assertEq(txn.confirmations, 3);
    }
}
