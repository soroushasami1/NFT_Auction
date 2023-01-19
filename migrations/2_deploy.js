const NftCollection = artifacts.require("NftCollection");
const MarketPlace = artifacts.require("MarketPlace");


module.exports = function (deployer, network, accounts) {
  deployer.then(async () => {
    await deployer.deploy(NftCollection);
    await deployer.deploy(MarketPlace);
  })
}