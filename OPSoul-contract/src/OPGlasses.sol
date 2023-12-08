// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract OPGlasses is ERC721, AccessControl {
    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private s_tokenCounter;
    string private s_glassesSvgImageUri;

    constructor(string memory glassesSvgImageUri, address defaultAdmin, address minter) ERC721("OPGlasses", "OPG") {
        s_tokenCounter = 1;
        s_glassesSvgImageUri = glassesSvgImageUri;
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    function mint(address to) external onlyRole(MINTER_ROLE) {
        _safeMint(to, s_tokenCounter);
        s_tokenCounter++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name": "',
                            name(),
                            " #",
                            tokenId,
                            '", "description": "This NFT is a cool glasses, that is 100% on OP mainnet!.", "attributes": [{"trait_type": "Item", "value": "Glasses"}, {"trait_type": "Material", "value": "Glass"}, {"trait_type": "Color", "value": "Black"}], "image": "',
                            s_glassesSvgImageUri,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
