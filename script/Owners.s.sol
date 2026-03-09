// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Owners} from "../src/Owners.sol";

contract OwnersScript is Script {
    Owners public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address[] memory owners = new address[](3);
        owners[0] = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        owners[1] = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        owners[2] = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;

        counter = new Owners(owners, 2);

        vm.stopBroadcast();
    }
}
