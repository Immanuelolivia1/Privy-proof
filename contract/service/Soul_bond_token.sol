// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .16;
// Made with Love by Dennison Bertram @Tally.xyz
import "@openzeppelin/contracts@4.6.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.6.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.6.0/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract Soul_bond_token is ERC721, Ownable, EIP712, ERC721Votes {
    using Counters
    for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    constructor() ERC721("PrivyToken", "PTK") EIP712("PrivyToken", "1") {}

    function _baseURI() internal pure override returns(string memory) {
        return "hello";
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
    // The following functions are overrides required by Solidity.
    function _afterTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721, ERC721Votes) {
        super._afterTokenTransfer(from, to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721) {
        require(from == address(0), "Err: token is SOUL BOND");
        super._beforeTokenTransfer(from, to, tokenId);
    }
}