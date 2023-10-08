// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface ISoulBondToken {
    function safeMint(address to, string memory metadataURI) external;

    function currentTokenId() external returns (uint);
}
