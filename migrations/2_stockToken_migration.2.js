const StockToken = artifacts.require("./StockToken.sol");

module.exports = function(deployer) {
  deployer.deploy(StockToken);
};