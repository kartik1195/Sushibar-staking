// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  let =""
  let STAKE=""
  describe("Sushi Deployed", function () {
    it("test initial value on deploy", async function () {
      const deployTime =  Math.round(Date.now() / 1000);

      const SushiToken = await hre.ethers.getContractFactory("SushiToken");
      const sushiToken = await SushiToken.deploy();

      await sushiToken.deployed();
      ERC20=sushiToken.address
      console.log(`timestamp ${deployTime} deployed to ${sushiToken.address} for ERC20`);
      const SushiBar = await hre.ethers.getContractFactory("SushiBar");
      const sushiBar = await SushiBar.deploy(sushiToken.address);

      await sushiBar.deployed();
      STAKE=sushiBar.address
      console.log(`timestamp ${deployTime} deployed to ${sushiBar.address} for SushiBar`);
    });
    it("Add Balance to user Account : 20 Token", async function () {
      const ercContract = await ethers.getContractAt("SushiToken", storage.address);

      const [owner, otherAccount] = await ethers.getSigners();
      console.log("--------",owner, otherAccount);
      //const giveBalance =await ercContract.mint(,10000000000000000000);
      //await setValue.wait();
      //expect((await ercContract.retrieve()).toNumber()).to.equal(56);
    });
  })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
