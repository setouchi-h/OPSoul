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

    using Chainlink for Chainlink.Request;

    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private constant SALT = 0;

    address private immutable i_erc6551Registry;
    address private immutable i_erc6551Account;
    address private immutable i_hatNftAddr;
    address private immutable i_glassesNftAddr;

    bytes32 private s_jobId;
    uint256 private s_tokenCounter;
    uint256 private s_fee;
    string private s_bodySvgImageUri;

    string public s_glassesImageUrl;
    string public s_hatImageUrl;

    mapping(uint256 => address) private s_tokenIdToTba;

    event RequestMultipleFulfilled(bytes32 indexed requestId, bytes indexed glasses, bytes indexed hat);

    constructor(
        address linkAddr,
        address oracleAddr,
        address hatNftAddr,
        address glassesNftAddr,
        address erc6551Registry,
        address erc6551Account,
        string memory bodySvgImageUri,
        address defaultAdmin,
        address minter
    ) ConfirmedOwner(msg.sender) ERC721("OPSoul", "OPS") {
        setChainlinkToken(linkAddr);
        setChainlinkOracle(oracleAddr);
        s_fee = (1 * LINK_DIVISIBILITY) / 10;

        i_hatNftAddr = hatNftAddr;
        i_glassesNftAddr = glassesNftAddr;
        i_erc6551Registry = erc6551Registry;
        i_erc6551Account = erc6551Account;
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
        s_tokenIdToTba[tokenId] = tba;

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
                            '", "description": "This NFT is a cool hat, that is 100% on OP mainnet!.", "attributes": [{"trait_type": "Item", "value": "Hat"}, {"trait_type": "Material", "value": "Wool"}, {"trait_type": "Color", "value": "Black"}], "image": "',
                            s_glassesImageUrl,
                            ",dd",
                            s_hatImageUrl,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function requestNftImgUrl(uint256 tokenId) public {
        _requireOwned(tokenId);

        address tba = s_tokenIdToTba[tokenId];
        if (tba == address(0)) {
            revert OPSoul__TBANotFound();
        }

        uint256 glassesTokenId = ERC6551Account(payable(tba)).getAsset(i_glassesNftAddr);
        uint256 hatTokenId = ERC6551Account(payable(tba)).getAsset(i_hatNftAddr);

        Chainlink.Request memory req = buildChainlinkRequest(s_jobId, address(this), this.fulfillUrlParameters.selector);

        string memory glassesTokenUri = "";
        string memory hatTokenUri = "";

        try ERC721(i_glassesNftAddr).tokenURI(glassesTokenId) returns (string memory _glassesTokenUri) {
            glassesTokenUri = _glassesTokenUri;
        } catch {
            s_glassesImageUrl = "";
        }

        try ERC721(i_hatNftAddr).tokenURI(hatTokenId) returns (string memory _hatTokenUri) {
            hatTokenUri = _hatTokenUri;
        } catch {
            s_hatImageUrl = "";
        }

        req.add("urlGlasses", glassesTokenUri);
        req.add("pathGlasses", "image");
        req.add("urlHat", hatTokenUri);
        req.add("pathHat", "image");

        sendChainlinkRequest(req, s_fee);
    }

    /**
     * @notice Fulfillment function for multiple parameters in a single request
     * @dev This is called by the oracle. recordChainlinkFulfillment must be used.
     */
    function fulfillUrlParameters(bytes32 requestId, bytes memory glassesResponse, bytes memory hatResponse)
        public
        recordChainlinkFulfillment(requestId)
    {
        emit RequestMultipleFulfilled(requestId, glassesResponse, hatResponse);
        s_glassesImageUrl = string(glassesResponse);
        s_hatImageUrl = string(hatResponse);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    }
}
