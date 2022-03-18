const { expect, use } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("Milestone Mementos",  () => {
  let mementoContract;

  beforeEach(async () => {
    this.mementoFactory = await ethers.getContractFactory("Milestone_Mementos");
    this.mementoFactoryV2 = await ethers.getContractFactory("Milestone_Mementos_V2");

    mementoContract = await upgrades.deployProxy(this.mementoFactory, {kind: "uups"});
  
    [owner, user1] = await ethers.getSigners();
  });

  it("Upgrades correctly", async () => {
    let expctVersion = 2;
    
    expect(await mementoContract.name()).to.equal("Mementos");

    const mementoContractV2 = await upgrades.upgradeProxy(mementoContract, this.mementoFactoryV2);
    const mementoVersion = await mementoContractV2.version();

    expect(mementoVersion).to.equal(expctVersion);
  });

  it("Detects all Mementos held by a user", async () => {
    let expctMementos = [1,2,3];
    let expctMementosLen = 3;
    const description = "Congratulation for all your hard work & effort! You've been an absolute stud, enjoy some time off Vitalik."
    const imgURI = "https://lh3.googleusercontent.com/Q4uXff5hD6T91FlaDiqZTpMu-kEgwx6IcUHXsWF_Moq5u6VOvfqKuIXN2_StL78LNiA1YW3e16vnrLq_zqvfOMtK7PLy9AcKGxWr=w600";
    let txn;
    
    for(i = 0; i < expctMementosLen; i++){
      txn = await mementoContract.mintMemento(description, imgURI);
      await txn.wait();
    }
    
    txn = await mementoContract.getMementos();
    expect(txn.length).to.equal(expctMementosLen);

    for(i = 0; i < expctMementosLen; i++){
      expect(txn[i]).to.equal(expctMementos[i]);
    }
  
    expctMementosLen = 0;

    txn = await mementoContract.connect(user1).getMementos();
    expect(txn.length).to.equal(expctMementosLen);
  });
});