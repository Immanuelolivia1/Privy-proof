import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Lock", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    const ONE_GWEI = 1_000_000_000;

    const lockedAmount = ONE_GWEI;
    const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Lock = await ethers.getContractFactory("Lock");
    const lock = await Lock.deploy(unlockTime, { value: lockedAmount });
    const lockAddress = await lock.getAddress();
    console.log("LOCK CONTRACT ADDRESS IS ----______", lockAddress);

    return { lock, unlockTime, lockedAmount, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right unlockTime", async function () {
      const { lock, unlockTime } = await loadFixture(deployOneYearLockFixture);

      expect(await lock.unlockTime()).to.equal(unlockTime);
    });

    it("Should set the right owner", async function () {
      const { lock, owner } = await loadFixture(deployOneYearLockFixture);

      expect(await lock.owner()).to.equal(owner.address);
    });

    it("Should receive and store the funds to lock", async function () {
      const { lock, lockedAmount } = await loadFixture(
        deployOneYearLockFixture
      );

      expect(await ethers.provider.getBalance(lock.target)).to.equal(
        lockedAmount
      );
    });

    it("Should fail if the unlockTime is not in the future", async function () {
      // We don't use the fixture here because we want a different deployment
      const latestTime = await time.latest();
      const Lock = await ethers.getContractFactory("Lock");
      await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
        "Unlock time should be in the future"
      );
    });
  });

  describe("Withdrawals", function () {
    describe("Validations", function () {
      it("Should revert with the right error if called too soon", async function () {
        const { lock } = await loadFixture(deployOneYearLockFixture);

        await expect(lock.withdraw()).to.be.revertedWith(
          "You can't withdraw yet"
        );
      });

      it("Should revert with the right error if called from another account", async function () {
        const { lock, unlockTime, otherAccount } = await loadFixture(
          deployOneYearLockFixture
        );

        // We can increase the time in Hardhat Network
        await time.increaseTo(unlockTime);

        // We use lock.connect() to send a transaction from another account
        await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
          "You aren't the owner"
        );
      });

      it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
        const { lock, unlockTime } = await loadFixture(
          deployOneYearLockFixture
        );

        // Transactions are sent using the first signer by default
        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).not.to.be.reverted;
      });
    });

    describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { lock, unlockTime, lockedAmount } = await loadFixture(
          deployOneYearLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw())
          .to.emit(lock, "Withdrawal")
          .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
      });
    });

    describe("Transfers", function () {
      it("Should transfer the funds to the owner", async function () {
        const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
          deployOneYearLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).to.changeEtherBalances(
          [owner, lock],
          [lockedAmount, -lockedAmount]
        );
      });
    });
  });
});
// test/AgreementContract.test.js

// const { expect } = require("chai");
// const { ethers } = require("hardhat");

// describe("AgreementContract", () => {

// async function deployAllContracts() {
//   const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
//   const ONE_GWEI = 1_000_000_000;

//   const lockedAmount = ONE_GWEI;
//   const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

//   // Contracts are deployed using the first signer/account by default
//   const [owner, otherAccount] = await ethers.getSigners();

//   const AgreementContract = await ethers.getContractFactory("AgreementContract");
//   const agreementContract = await AgreementContract.deploy();

//   const SoulBoundToken = await ethers.getContractFactory("SoulBoundToken");
//     const soulBoundToken = await SoulBoundToken.deploy(
//       agreementContract.address
//     );

//   return { lock, unlockTime, lockedAmount, owner, otherAccount };
// }

//   let AgreementContract;
//   let agreementContract;
//   let owner;
//   let party1;
//   let party2;

//   beforeEach(async () => {
//     AgreementContract = await ethers.getContractFactory("AgreementContract");
//     [owner, party1, party2] = await ethers.getSigners();

//     agreementContract = await AgreementContract.deploy();
//     await agreementContract.deployed();
//   });

//   it("Should create a new agreement and mint an NFT", async () => {
//     // Set up the SoulBoundToken contract
//     const SoulBoundToken = await ethers.getContractFactory("SoulBoundToken");
//     const soulBoundToken = await SoulBoundToken.deploy(
//       agreementContract.address
//     );
//     await soulBoundToken.deployed();

//     // Set the NFT contract address in AgreementContract
//     await agreementContract.setNFTAddress(soulBoundToken.address);

//     // Create a new agreement
//     await agreementContract.createAgreement(party2.address, "metadataURI");

//     // Sign the agreement
//     await agreementContract.party1SignAgreement(1);
//     await agreementContract.party2SignAgreement(1);

//     // Mint NFT for the agreement
//     await agreementContract.mintNFTAgreement(1);

//     // Check the agreement details
//     const agreementDetails = await agreementContract.getAgreementDetails(1);
//     expect(agreementDetails.tokenIds.length).to.equal(1);
//     expect(agreementDetails.tokenUri).to.equal("metadataURI");

//     // Check party1 and party2 agreements
//     const party1Agreements = await agreementContract.getParty1Agreements();
//     const party2Agreements = await agreementContract.getParty2Agreements();

//     expect(party1Agreements.length).to.equal(1);
//     expect(party2Agreements.length).to.equal(1);

//     // Check the currentTokenId in the SoulBoundToken contract
//     const currentTokenId = await soulBoundToken.currentTokenId();
//     expect(currentTokenId).to.equal(1);
//   });

//   // Add more test cases as needed
// });
