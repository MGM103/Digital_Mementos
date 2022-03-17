const hre = require("hardhat");

async function main() {
  //NFT data
  let nftCount = 0;
  const description = "Congratulation for all your hard work & effort! You've been an absolute stud, enjoy some time off Vitalik."
  const imgURI = "https://lh3.googleusercontent.com/Q4uXff5hD6T91FlaDiqZTpMu-kEgwx6IcUHXsWF_Moq5u6VOvfqKuIXN2_StL78LNiA1YW3e16vnrLq_zqvfOMtK7PLy9AcKGxWr=w600";
  
  // We get the contract to deploy
  const mementoFactory = await hre.ethers.getContractFactory("Milestone_Mementos");
  const mementoContract = await mementoFactory.deploy(10000);

  await mementoContract.deployed();

  console.log("Memento deployed to:", mementoContract.address);

  console.log("Minting underway...")
  let mintTx = await mementoContract.mintMemento(description, imgURI);
  await mintTx.wait();
  nftCount += 1;

  mintTx = await mementoContract.tokenURI(nftCount);
  console.log(mintTx);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
