// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/EvictionVault.sol";

contract EvictionVaultTest is Test {

    EvictionVault vault;

    address ganiyat;
    address halima;
    address feyi;

    address user;

  function setUp() public {

    ganiyat = makeAddr("ganiyat");
    halima = makeAddr("halima");
    feyi = makeAddr("feyi");

    user = makeAddr("user");

    address[] memory owners =new address[](3);

    owners[0] = ganiyat;
    owners[1] = halima;
    owners[2] = feyi;

    vault = new EvictionVault(owners, 2);

    vm.deal(ganiyat, 3 ether);
    vm.deal(user, 3 ether);
}
    // Deposit Test

    function test_Deposit() public {

        vm.prank(user);
        vault.deposit{value: 1 ether}();

        uint256 balance = vault.balances(user);

        assertEq(balance, 1 ether);
    }

    // Withdraw Test

    function test_Withdrawal() public {

        vm.startPrank(user);

        vault.deposit{value: 1 ether}();

        vault.withdraw(1 ether);

        vm.stopPrank();

        uint256 balance = vault.balances(user);

        assertEq(balance, 0);
    }

    // Submit Transaction

    function test_SubmitTransaction() public {

        vm.prank(ganiyat);

        vault.submitTransaction(user, 1 ether, "");

        (
            address to,
            uint256 value,
            ,
            bool executed,
            uint256 confirmations,
            ,
            uint256 executionTime
        ) = vault.transactions(0);

        assertEq(to, user);
        assertEq(value, 1 ether);
        assertFalse(executed);
        assertEq(confirmations, 1);
        assertEq(executionTime, 0);
    }

    // Confirm Transaction
    function test_ConfirmTransaction() public {

        vm.prank(ganiyat);
        vault.submitTransaction(user, 1 ether, "");

        vm.prank(halima);
        vault.confirmTransaction(0);

        (
            ,
            ,
            ,
            ,
            uint256 confirmations,
            ,
            uint256 executionTime
        ) = vault.transactions(0);

        assertEq(confirmations, 2);
        assertGt(executionTime, 0);
    }

    // 5. Execute Transaction

    function testExecuteTransaction() public {

        vm.deal(address(vault), 2 ether);

        vm.prank(ganiyat);
        vault.submitTransaction(user, 1 ether, "");

        vm.prank(halima);
        vault.confirmTransaction(0);

        (
            ,
            ,
            ,
            ,
            ,
            ,
            uint256 executionTime
        ) = vault.transactions(0);

        vm.warp(executionTime + 1);

        vm.prank(ganiyat);
        vault.executeTransaction(0);

        (
            ,
            ,
            ,
            bool executed,
            ,
            ,
        ) = vault.transactions(0);

        assertTrue(executed);
    }

    // 6. Pause Control Test

    function test_Pause() public {

        vm.prank(ganiyat);
        vault.pause();

        bool paused = vault.paused();

        assertTrue(paused);
    }
}