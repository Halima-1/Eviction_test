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
        // Deploy contract with 3 owners and threshold 2
        // address ;
         ganiyat = makeAddr("ganiyat");
        halima = makeAddr("halima");
        isaac = makeAddr("isaac");
                feyi = makeAddr("feyi");


        address[] memory signers = new address[](3);
        signers[0] = ganiyat;
        signers[1] = halima;
        signers[2] = isaac;


        ownersContract = new Owners(signers, 2);
    }

    function testSubmitTransaction() public {
        vm.prank(ganiyat);
        ownersContract.submitTransaction(halima, 1 ether, "");

        Owners.Transaction memory txn = ownersContract.transactions(0);

        assertEq(txn.to, halima);
        assertEq(txn.value, 1 ether);
        assertEq(txn.confirmations, 1);
        assertFalse(txn.executed);
    }

    function testConfirmTransactionSetsTimelock() public {
        vm.prank(ganiyat);
        ownersContract.submitTransaction(halima, 1 ether, "");

        // Confirm with second owner (threshold = 2)
        vm.warp(block.timestamp + 10);
        vm.prank(isaac);
        ownersContract.confirmTransaction(0);

        Owners.Transaction memory txn = ownersContract.transactions(0);

        // Execution time should be set
        assertGt(txn.executionTime, 0);
        assertEq(txn.confirmations, 2);
    }

    function testExecuteTransaction() public {
        // Fund halima for testing call
        vm.deal(address(ownersContract), 1 ether);

        vm.prank(ganiyat);
        ownersContract.submitTransaction(halima, 1 ether, "");

        // Confirm with second owner
        vm.prank(isaac);
        ownersContract.confirmTransaction(0);

        Owners.Transaction memory txnBefore = ownersContract.transactions(0);

        // Fast forward time past timelock
        vm.warp(txnBefore.executionTime + 1);

        // Execute transaction
        vm.prank(ganiyat);
        ownersContract.executeTransaction(0);

        Owners.Transaction memory txnAfter = ownersContract.transactions(0);
        assertTrue(txnAfter.executed);
    }

    function testMultipleConfirmations() public {
        vm.prank(ganiyat);
        ownersContract.submitTransaction(halima, 1 ether, "");

        // Confirm twice with isaac and owner3
        vm.prank(isaac);
        ownersContract.confirmTransaction(0);

        Owners.Transaction memory txn = ownersContract.transactions(0);
        assertEq(txn.confirmations, 2); // threshold reached

        vm.prank(isaac);
        ownersContract.confirmTransaction(0);

        txn = ownersContract.transactions(0);
        assertEq(txn.confirmations, 3);
    }


}