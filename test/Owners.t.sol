// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Owners} from "../src/Owners.sol";

contract OwnersTest is Test {
    Owners public owners;

    function setUp() public {

 address[] memory _owners = new address[](3);
        _owners[0] = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        _owners[1] = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        _owners[2] = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;

        owners = new Owners(_owners, 2);   
    }

    function test_submitTxn() public {
       
    }

    function testFuzz_confirmTxn(uint256 x) public {
       
    }
}
