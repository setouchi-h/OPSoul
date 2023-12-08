// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC6551Registry} from "./ERC6551Registry.sol";

contract OPSoul is ERC721, AccessControl {
    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private s_tokenCounter;
    string private s_bodySvgImageUri;
    address private immutable i_erc6551Registry;
    address private immutable i_erc6551Account;

    mapping(uint256 => address) private s_tokenIdToTba;

    constructor(string memory bodySvgImageUri, address defaultAdmin, address minter) ERC721("OPSoul", "OPS") {
        s_tokenCounter = 1;
        s_bodySvgImageUri = bodySvgImageUri;
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    function mint(address to) external onlyRole(MINTER_ROLE) {
        uint256 tokenId = s_tokenCounter;
        _safeMint(to, tokenId);

        address tba = ERC6551Registry(i_erc6551Registry).createAccount(
            i_erc6551Account, block.chainid, address(this), tokenId, SALT, ""
        );

        s_tokenCounter++;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
