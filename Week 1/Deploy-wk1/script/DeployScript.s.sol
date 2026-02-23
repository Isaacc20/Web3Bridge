// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Todo} from "../src/Todo.sol";
import {ERC20} from "../src/ERC20.sol";
import {SaveERC} from "../src/SaveERC.sol";
import {SaveAsset} from "../src/SaveAsset.sol";
import {DevSchool} from "../src/DevSchool.sol";

contract DeployScript is Script {
    Todo public todo;
    ERC20 public erc20;
    SaveERC public saveERC;
    SaveAsset public saveAsset;
    DevSchool public devSchool;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        todo = new Todo();
        erc20 = new ERC20();
        saveERC = new SaveERC();
        saveAsset = new SaveAsset(address(erc20));
        devSchool = new DevSchool(address(erc20));

        vm.stopBroadcast();
    }
}
