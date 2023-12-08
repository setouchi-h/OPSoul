// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {OPGlasses} from "../src/OPGlasses.sol";

contract DeployOPGlasses is Script {
    string tokenUri = "https://ipfs.io/ipfs/QmWcznipqZyuL4Ua9apznuxKzgokzCMRLBFPQTnARXYKeg";

    function run() external returns (address) {
        vm.startBroadcast(msg.sender);
        OPGlasses opGlassesNft = new OPGlasses(tokenUri, msg.sender, msg.sender);
        vm.stopBroadcast();
        return address(opGlassesNft);
    }
}
