// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {OPSoul} from "../src/OPSoul.sol";
import {ERC6551Account} from "../src/ERC6551Account.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract SetHat is Script {
    // The token ID of NFT that user owns
    uint256 public tokenIdOfUser = 1;

    function run() external {
        address opSoul = 0xA40F3bD10fb32D3ABb2307f69727d71C6277522F;
        address opHat = 0x35B9B2B23f01452eab2095d074966F99A1d1aAd0;
        // the address of tba of the tokenIdOfUser
        address tba = OPSoul(opSoul).getTba(tokenIdOfUser);

        // The token ID of NFT that tba owns
        uint256 tokenIdOfTBA = 3;

        vm.startBroadcast(msg.sender);
        setAsset(tba, opHat, tokenIdOfTBA);
        vm.stopBroadcast();
    }

    function setAsset(address tba, address collection, uint256 tokenId) public {
        ERC6551Account(payable(tba)).setAsset(collection, tokenId);
    }
}

contract SetGlasses is Script {
    // The token ID of NFT that user owns
    uint256 public tokenIdOfUser = 2;

    function run() external {
        address opSoul = 0x858115d4B961419C4195CA5c74d120f60764d3FB;
        address opGlasses = 0x1A5eDBfB1e43661262b5c33Dcc3887bA45D99791;
        // the address of tba of the tokenIdOfUser
        address tba = OPSoul(opSoul).getTba(tokenIdOfUser);

        // The token ID of NFT that tba owns
        uint256 tokenIdOfTBA = 3;

        vm.startBroadcast(msg.sender);
        setAsset(tba, opGlasses, tokenIdOfTBA);
        vm.stopBroadcast();
    }

    function setAsset(address tba, address collection, uint256 tokenId) public {
        ERC6551Account(payable(tba)).setAsset(collection, tokenId);
    }
}

contract DeleteGlasses is Script {
    // The token ID of NFT that user owns
    uint256 public tokenIdOfUser = 2;

    function run() external {
        address opSoul = 0x858115d4B961419C4195CA5c74d120f60764d3FB;
        address opGlasses = 0x1A5eDBfB1e43661262b5c33Dcc3887bA45D99791;
        // the address of tba of the tokenIdOfUser
        address tba = OPSoul(opSoul).getTba(tokenIdOfUser);

        // The token ID of NFT that tba owns
        uint256 tokenIdTodelete = 0;

        vm.startBroadcast(msg.sender);
        setAsset(tba, opGlasses, tokenIdTodelete);
        vm.stopBroadcast();
    }

    function setAsset(address tba, address collection, uint256 tokenId) public {
        ERC6551Account(payable(tba)).setAsset(collection, tokenId);
    }
}
