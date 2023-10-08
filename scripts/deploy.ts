const hre = require("hardhat");

async function main() {
  const Agreement = await hre.ethers.deployContract("AgreementContract", []);

  await Agreement.waitForDeployment();

  console.log(`Agreement contract deployed to ${Agreement.target}`);

  const SBT = await hre.ethers.deployContract("SoulBoundToken", [
    Agreement.target,
  ]);

  await SBT.waitForDeployment();

  console.log(`SBT contract deployed to ${SBT.target}`);

  //now we must immediately initialize the nft contract address into our Agreement
  try {
    const tx = await Agreement.setNFTAddress(SBT.target);
    console.log("TX DONE ______", tx);
  } catch (err) {
    console.log(err);
  }
}

//DEFAULT BY HARDHAT:
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
