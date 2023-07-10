//SPDX-Lisence-Identifier: MIT

pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { ZedEngine } from "../src/ZedEngine.sol";
import { Zed } from "../src/Zed.sol";


contract DeployZed is Script {
    function run() external returns(Zed, ZedEngine) {
        vm.startBroadcast();
        Zed zed = new Zed();
        //ZedEngine zedEngine = new ZedEngine();
        vm.stopBroadcast();
    }

}