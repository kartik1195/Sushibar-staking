const { expect } = require("chai");
const hre = require("hardhat");

describe("Sushi Deployed", function () {
  let ERC20=""
  let STAKE=""
  describe("Deployment", function () {

    it("test initial value on deploy", async function () {
      const deployTime =  Math.round(Date.now() / 1000);

      const SushiToken = await hre.ethers.getContractFactory("Sushitoken");
      const sushiToken = await SushiToken.deploy();

      await sushiToken.deployed();
      ERC20=sushiToken.address
      console.log(`timestamp ${deployTime} deployed to ${sushiToken.address} for ERC20`);
      const SushiBar = await hre.ethers.getContractFactory("Sushibar");
      const sushiBar = await SushiBar.deploy(sushiToken.address);

      await sushiBar.deployed();
      STAKE=sushiBar.address
      console.log(`timestamp ${deployTime} deployed to ${sushiBar.address} for Sushibar`);
    });

    it("Add Balance to user Account : 30 Token", async function () {
      const ercContract = await hre.ethers.getContractAt("Sushitoken", ERC20);

      const [owner, user1, user2] = await ethers.getSigners();
      console.log("--------",owner, user1, user2);
      const giveBalance =await ercContract.mint(user1.address,30*1e18);
      await giveBalance.wait();
    });
    it("give Approve SushiBar contract in SushiToken through User account for give access of some fund", async function () {

      const ercContract = await hre.ethers.getContractAt("Sushitoken", ERC20);
      const [owner, user1, user2] = await ethers.getSigners();
      const giveApprove =await ercContract.connect(user1).approve(STAKE,20*1e18);
      await giveApprove.wait();
    });

    it("Stake some amount from user 1", async function () {
      const stakeContract = await hre.ethers.getContractAt("Sushibar", STAKE);
      const [owner, user1, user2] = await ethers.getSigners();

      const ercContract = await hre.ethers.getContractAt("Sushitoken", ERC20);

      expect(await ercContract.allowance(user1,STAKE)).to.be.greaterThan((10*1e18+5*1e18));

      const stakeAmount =await stakeContract.connect(user1).enter(10*1e18);
      await stakeAmount.wait();

      const stakeAmount2 =await stakeContract.connect(user1).enter(5*1e18);
      await stakeAmount2.wait();
    });

    it("UnStake some amount from user 1 based on staking index", async function () {
      const stakeContract = await hre.ethers.getContractAt("Sushibar", STAKE);
      const [owner, user1, user2] = await ethers.getSigners();

      const unstakeAmount =await stakeContract.connect(user1).leave(2.5*1e18,0);
      await unstakeAmount.wait();

      const unstakeAmount2 =await stakeContract.connect(user1).leave(5*1e18,1);
      await unstakeAmount2.wait();
    });

  });
});
