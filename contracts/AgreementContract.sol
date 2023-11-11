// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the ERC-721 NFT contract interface
import "./ISoulBoundToken.sol";

contract AgreementContract {
    // Address of the NFT contract
    address public nftContractAddress;

    //address owner
    address immutable owner;

    constructor() {
        owner = msg.sender;
    }

    // Soul Bond NFT contract instance
    ISoulBoundToken public nftContract;

    // Counter for agreement IDs
    uint256 public agreementCounter;

    // Struct to represent an agreement
    struct Agreement {
        address party1;
        address party2;
        bool party1Signed;
        bool party2Signed;
        uint256[] tokenIds;
        string tokenUri; // Token ID of the soul-bound NFT
    }

    // Mapping to store agreements by agreement ID
    mapping(uint256 => Agreement) public agreements;

    mapping(address => uint256[]) private initiator;
    mapping(address => uint256[]) private party;

    // Event emitted when a new agreement is created
    event AgreementCreated(uint256 agreementId, address party1, address party2);

    // Event emitted when an agreement is signed
    event AgreementSigned(uint256 agreementId, address party);

    // Event emitted when an agreement is minted
    event AgreementMinted(uint256 agreementId, address party);

    // Function to create a new agreement and mint a Soul Bond NFT
    function createAgreement(address _party2, string memory _tokenUri) public {
        agreementCounter++;

        // // Mint a new NFT and get the token ID
        // uint256 tokenId = nftContract.mintSoulBoundNFT();

        uint256[] memory _tokenIds;

        // Create a new agreement
        Agreement memory newAgreement = Agreement({
            party1: msg.sender,
            party2: _party2,
            party1Signed: false,
            party2Signed: false,
            tokenIds: _tokenIds,
            tokenUri: _tokenUri
        });

        agreements[agreementCounter] = newAgreement;
        initiator[msg.sender].push(agreementCounter);
        party[_party2].push(agreementCounter);

        // Emit an event for the new agreement
        emit AgreementCreated(agreementCounter, msg.sender, _party2);
    }

    // Function for party1 to sign the agreement
    function party1SignAgreement(uint256 _agreementId) public {
        Agreement storage agreement = agreements[_agreementId];
        require(msg.sender == agreement.party1, "You are not party1");
        require(!agreement.party1Signed, "Party1 already signed");

        agreement.party1Signed = true;
        emit AgreementSigned(_agreementId, msg.sender);
    }

    // Function for party2 to sign the agreement
    function party2SignAgreement(uint256 _agreementId) public {
        Agreement storage agreement = agreements[_agreementId];
        require(msg.sender == agreement.party2, "You are not party2");
        require(agreement.party1Signed, "Party1 has not signed yet");
        require(!agreement.party2Signed, "Party2 already signed");

        agreement.party2Signed = true;
        emit AgreementSigned(_agreementId, msg.sender);
    }

    function mintNFTAgreement(uint256 _agreementId) public {
        Agreement storage agreement = agreements[_agreementId];
        require(msg.sender == agreement.party2, "not allowed");
        require(msg.sender == agreement.party1, "not allowed");
        require(agreement.party1Signed, "Party1 has not signed ");
        require(agreement.party2Signed, "Party2 hasnt signed");

        string memory metadataURI = agreement.tokenUri;

        // Mint a new NFT and get the token ID
        nftContract.safeMint(msg.sender, metadataURI);
        uint256 tokenId = nftContract.currentTokenId();

        agreement.tokenIds.push(tokenId);

        emit AgreementMinted(_agreementId, msg.sender);
    }

    // Function to get the details of an agreement
    function getAgreementDetails(
        uint256 _agreementId
    ) public view returns (Agreement memory) {
        require(
            agreements[_agreementId].party1 != address(0),
            "Invalid agreement ID"
        );
        return agreements[_agreementId];
    }

    //getUserAgreements
    function getParty1Agreements() public view returns (uint256[] memory) {
        return initiator[msg.sender];
    }

    function getParty2Agreements() public view returns (uint256[] memory) {
        return party[msg.sender];
    }

    //function called by owner to set NFT contract address
    function setNFTAddress(address _nftContractAddress) public {
        require(msg.sender == owner, "not allowed");
        nftContract = ISoulBoundToken(_nftContractAddress);
    }
}
