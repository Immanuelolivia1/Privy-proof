pragma solidity ^0.8.0;

// Import the ERC-721 NFT contract interface
import "./Soul_bond_token.sol";

contract AgreementContract {
    // Address of the NFT contract
    address public nftContractAddress;

    // Soul Bond NFT contract instance
    SoulBondNFT public nftContract;

    // Counter for agreement IDs
    uint256 public agreementCounter;

    // Struct to represent an agreement
    struct Agreement {
        address party1;
        address party2;
        bool party1Signed;
        bool party2Signed;
        uint256 tokenId;  // Token ID of the soul-bound NFT
    }

    // Mapping to store agreements by agreement ID
    mapping(uint256 => Agreement) public agreements;

    // Event emitted when a new agreement is created
    event AgreementCreated(uint256 agreementId, address party1, address party2);

    // Event emitted when an agreement is signed
    event AgreementSigned(uint256 agreementId, address party);

    constructor(address _nftContractAddress) {
        nftContractAddress = _nftContractAddress;
        nftContract = SoulBondNFT(_nftContractAddress);
        agreementCounter = 0;
    }

    // Function to create a new agreement and mint a Soul Bond NFT
    function createAgreement(address _party2) public {
        agreementCounter++;

        // Mint a new NFT and get the token ID
        uint256 tokenId = nftContract.mintSoulBoundNFT();

        // Create a new agreement
        Agreement memory newAgreement = Agreement({
            party1: msg.sender,
            party2: _party2,
            party1Signed: false,
            party2Signed: false,
            tokenId: tokenId
        });

        agreements[agreementCounter] = newAgreement;

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


    // Function to get the details of an agreement
    function getAgreementDetails(uint256 _agreementId) public view returns (Agreement memory) {
        require(_agreementId < agreements.length, "Invalid agreement ID");
        return agreements[_agreementId];
}
}
