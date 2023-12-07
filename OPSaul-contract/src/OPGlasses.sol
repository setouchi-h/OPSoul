// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721A} from "erc721a/contracts/ERC721A.sol";

contract OPGlasses
 is ERC721A {
    constructor() ERC721A("OPClothes", "OPC") {}
}
