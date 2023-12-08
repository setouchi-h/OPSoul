// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC6551Registry} from "./ERC6551Registry.sol";
import {ERC6551Account} from "./ERC6551Account.sol";
import {ChainlinkClient, Chainlink, LinkTokenInterface} from "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract OPSoul is ChainlinkClient, ConfirmedOwner, ERC721, AccessControl {
    error OPSoul__TBANotFound();

    // using Chainlink for Chainlink.Request;

    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private constant SALT = 0;

    address private immutable i_erc6551Registry;
    address private immutable i_implementation;
    address private immutable i_glassesNftAddr;
    // address private immutable i_hatNftAddr;

    // bytes32 private s_jobId;
    // uint256 private s_fee;
    uint256 private s_tokenCounter;
    string private s_bodySvgImageUri;
    string private s_glassesSvgUri;

    mapping(uint256 => address) private s_tokenIdToTba;

    // event RequestMultipleFulfilled(bytes32 indexed requestId, bytes indexed glasses);

    constructor(
        // address linkAddr,
        // address oracleAddr,
        // bytes32 jobId,
        // address hatNftAddr,
        address glassesNftAddr,
        address erc6551Registry,
        address implementation,
        string memory bodySvgImageUri,
        string memory glassesSvgUri,
        address defaultAdmin,
        address minter
    ) ConfirmedOwner(msg.sender) ERC721("OPSoul", "OPS") {
        // setChainlinkToken(linkAddr);
        // setChainlinkOracle(oracleAddr);
        // s_fee = (4 * LINK_DIVISIBILITY);
        // s_jobId = jobId;

        // i_hatNftAddr = hatNftAddr;
        i_glassesNftAddr = glassesNftAddr;
        i_erc6551Registry = erc6551Registry;
        i_implementation = implementation;
        s_tokenCounter = 1;
        s_bodySvgImageUri = bodySvgImageUri;
        s_glassesSvgUri = glassesSvgUri;
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    function mint(address to) external onlyRole(MINTER_ROLE) {
        uint256 tokenId = s_tokenCounter;
        _safeMint(to, tokenId);

        address tba = ERC6551Registry(i_erc6551Registry).createAccount(
            i_implementation, SALT, block.chainid, address(this), tokenId
        );
        s_tokenIdToTba[tokenId] = tba;

        s_tokenCounter++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        string memory svg = _drawSvg(tokenId);
        string memory imageUri = _svgToImageUri(svg);

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name": "',
                            name(),
                            " #",
                            string(_toString(tokenId)),
                            '", "description": "You can dress up this bear. Please select glasses. This is a dynamic NFT that is fully on-chain.", "attributes": [{"trait_type":"Character","value":"Bear"},{"trait_type":"Personality","value":"Gentleman"}], "image": "',
                            imageUri,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    // function requestNftImgUrl(uint256 tokenId) public {
    //     _requireOwned(tokenId);

    //     address tba = s_tokenIdToTba[tokenId];
    //     if (tba == address(0)) {
    //         revert OPSoul__TBANotFound();
    //     }

    //     uint256 glassesTokenId = ERC6551Account(payable(tba)).getAsset(i_glassesNftAddr);
    //     // uint256 hatTokenId = ERC6551Account(payable(tba)).getAsset(i_hatNftAddr);

    //     Chainlink.Request memory req = buildChainlinkRequest(s_jobId, address(this), this.fulfillUrlParameter.selector);

    //     string memory glassesTokenUri = "";
    //     // string memory hatTokenUri = "";

    //     try ERC721(i_glassesNftAddr).tokenURI(glassesTokenId) returns (string memory _glassesTokenUri) {
    //         glassesTokenUri = _glassesTokenUri;
    //     } catch {
    //         glassesTokenUri = s_transparentUri;
    //     }

    //     // try ERC721(i_hatNftAddr).tokenURI(hatTokenId) returns (string memory _hatTokenUri) {
    //     //     hatTokenUri = _hatTokenUri;
    //     // } catch {
    //     //     hatTokenUri = s_transparentUri;
    //     // }

    //     req.add("get", glassesTokenUri);
    //     req.add("path", "image");
    //     // req.add("urlHat", hatTokenUri);
    //     // req.add("pathHat", "image");

    //     sendChainlinkRequest(req, s_fee);
    // }

    /**
     * @notice Fulfillment function for multiple parameters in a single request
     * @dev This is called by the oracle. recordChainlinkFulfillment must be used.
     */
    // function fulfillUrlParameter(bytes32 requestId, bytes memory glassesResponse)
    //     public
    //     recordChainlinkFulfillment(requestId)
    // {
    //     emit RequestMultipleFulfilled(requestId, glassesResponse);
    //     s_glassesImageUrl = string(glassesResponse);
    //     // s_hatImageUrl = string(hatResponse);
    // }

    function _drawSvg(uint256 tokenId) private view returns (string memory) {
        address tba = s_tokenIdToTba[tokenId];
        if (tba == address(0)) {
            revert OPSoul__TBANotFound();
        }

        uint256 glassesTokenId = ERC6551Account(payable(tba)).getAsset(i_glassesNftAddr);
        // uint256 hatTokenId = ERC6551Account(payable(tba)).getAsset(i_hatNftAddr);

        string memory svg = string(
            abi.encodePacked(
                '<svg viewBox="0 0 1024 1792" width="400"  height="400" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><image x="0" y="0" width="1024" height="1792" xlink:href="',
                s_bodySvgImageUri,
                '"/>'
            )
        );

        // if (bytes(s_hatImageUrl).length != 0) {
        //     svg = string(
        //         abi.encodePacked(
        //             svg, '<image x="0" y="-620" width="1024" height="1792" xlink:href="', s_hatImageUrl, '"/>'
        //         )
        //     );
        // }

        if (glassesTokenId != 0) {
            svg = string(
                abi.encodePacked(
                    svg, '<image x="0" y="0" width="1024" height="1792" xlink:href="', s_glassesSvgUri, '"/>'
                )
            );
        }

        svg = string(abi.encodePacked(svg, "</svg>"));

        return svg;
    }

    function _svgToImageUri(string memory svgImage) private pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        return string(abi.encodePacked(baseURL, Base64.encode(bytes(svgImage))));
    }

    function _toString(uint256 value) private pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // function withdrawLink() external onlyOwner {
    //     LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    //     require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    // }

    function getTba(uint256 tokenId) external view returns (address) {
        return s_tokenIdToTba[tokenId];
    }
}
