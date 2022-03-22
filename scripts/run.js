const {ethers, upgrades} = require("hardhat");

async function main() {
  //NFT data
  let nftCount = 0;
  const title = "One small step for EY, one giant leap for DET";
  const description = "Thank you for beginning DET on their journey and being such a great leader. We very much appreciate all your hardwork and effort. Best wishes for the future! 'Talent is cheaper than table salt. What separates the talented individual from the successful one is hard work' - Stephen King";
  const imgURI = "ipfs://QmZKENpMCwN8HSF8wdsqJm8Z2eX5waT8c8oQBSJH2eF8N3";
  
  // We get the contract to deploy
  const mementoFactory = await ethers.getContractFactory("Milestone_Mementos");
  const mementoContract = await upgrades.deployProxy(mementoFactory, {kind: 'uups'});

  console.log("Memento deployed to:", mementoContract.address);

  for(i = 0; i < 2; i++){
    console.log("Minting underway...")
    let mintTx = await mementoContract.mintMemento(title, description, imgURI);
    await mintTx.wait();
    nftCount += 1;

    mintTx = await mementoContract.tokenURI(nftCount);
    console.log(mintTx);
  }

  mintTx = await mementoContract.getMementos();
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
