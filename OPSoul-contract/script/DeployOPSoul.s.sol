// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {OPSoul} from "../src/OPSoul.sol";
import {ERC6551Account} from "../src/ERC6551Account.sol";
import {ERC6551Registry} from "../src/ERC6551Registry.sol";

contract DeployOPSoul is Script {
    function deployOPSoulUsingConfig() public returns (address, address, address) {
        HelperConfig helperConfig = new HelperConfig();
        (
            address linkAddr,
            address oracleAddr,
            bytes32 jobId,
            address hatNftAddr,
            address glassesNftAddr,
            address erc6551Registry,
            address implementation,
            string memory bodySvgImageUri,
            string memory glassesSvgUri,
            address defaultAdmin,
            address minter
        ) = helperConfig.activeNetworkConfig();
        address opSoul = deployOPSoul(
            linkAddr,
            oracleAddr,
            jobId,
            hatNftAddr,
            glassesNftAddr,
            erc6551Registry,
            implementation,
            bodySvgImageUri,
            glassesSvgUri,
            defaultAdmin,
            minter
        );
        return (opSoul, erc6551Registry, implementation);
    }

    function deployOPSoul(
        address linkAddr,
        address oracleAddr,
        bytes32 jobId,
        address hatNftAddr,
        address glassesNftAddr,
        address erc6551Registry,
        address implementation,
        string memory bodySvgImageUri,
        string memory glassesSvgUri,
        address defaultAdmin,
        address minter
    ) public returns (address) {
        vm.startBroadcast(msg.sender);
        OPSoul opSoul = new OPSoul(
            // linkAddr,
            // oracleAddr,
            // jobId,
            // hatNftAddr,
            glassesNftAddr,
            erc6551Registry,
            implementation,
            bodySvgImageUri,
            glassesSvgUri,
            msg.sender,
            msg.sender
        );
        vm.stopBroadcast();
        return address(opSoul);
    }

    function run() external returns (OPSoul, ERC6551Registry, ERC6551Account) {
        (address opSoul, address erc6551Registry, address implementation) = deployOPSoulUsingConfig();
        return (OPSoul(opSoul), ERC6551Registry(erc6551Registry), ERC6551Account(payable(implementation)));
    }
}
