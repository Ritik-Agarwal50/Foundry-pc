// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {
        //Everything inside vm.StartBroadcast() will be executed on the blockchain i.e it will send it to rpc node
        vm.startBroadcast();
        SimpleStorage simpleStorage = new SimpleStorage();

        vm.stopBroadcast();
        //between vm.start and stop everything will be executed on the blockchain
        return simpleStorage;
    }
}
