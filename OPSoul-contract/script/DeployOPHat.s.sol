// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {OPHat} from "../src/OPHat.sol";

contract DeployBasicNft is Script {
    string tokenUri = "ipfs://QmWcznipqZyuL4Ua9apznuxKzgokzCMRLBFPQTnARXYKeg";

    function run() external returns (address) {
        vm.startBroadcast(msg.sender);
        OPHat opHatNft = new OPHat(tokenUri, msg.sender, msg.sender);
        vm.stopBroadcast();
        return address(opHatNft);
    }
}
