// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SoulBoundToken is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIdCounter;

    address immutable MinterContractAddress;

    uint256 public currentTokenId;

    constructor(address minterContractAddress) ERC721("PrivyToken", "PTK") {
        MinterContractAddress = minterContractAddress;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "hello";
    }

    modifier onlyMinterContract() {
        require(msg.sender == MinterContractAddress, "Caller is Invalid");
        _;
    }

    function safeMint(
        address to,
        string memory metadataURI
    ) public onlyMinterContract {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();

        currentTokenId = tokenId;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, metadataURI); // Set the metadata URI for the minted NFT
    }
}
