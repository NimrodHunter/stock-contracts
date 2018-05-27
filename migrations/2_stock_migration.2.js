const StockToken = artifacts.require("./StockToken.sol");
const Stock = artifacts.require("./Stock.sol");

const addressDAO = "0xa4d48925cfd968f6cb8662b5edd7e555797c494c";
const addressDAI = "0xc4375b7de8af5a38a93548eb8453a498222c4ff2";

const anibal_metamask = "0xa5652e6244F673cc20c9fb6BeD1572F62183aC8e";
const cristobal_metamask = "0x722622124A1CB03FBA2Ecc3d27929Bc8B0C08104";
const anibal = "0xe9e521cf7cf7d04a89b077339cf10a1cd0c4307c";
const cristobal = "0x57bcc4630eef2bf07e02bc17f4a1879311828f4e";
const eduardo = "0x254e6ba643c48e5e2e7ae24c17756b6e9d7f4217";
const patricio = "0xc96b253590d346A2056E4be567134B6ADef93373";

let StockTokenInstance;
let StockInstance;

module.exports = function(deployer) {
  deployer.deploy(StockToken)
  .then(() => {
    return StockToken.deployed();
  })
  .then((_instance) => {
    StockTokenInstance = _instance;
    return StockTokenInstance.mint(anibal, 33);
  })
  .then(() => {
    return StockTokenInstance.mint(anibal_metamask, 72);
  })
  .then(() => {
    return StockTokenInstance.mint(cristobal_metamask, 46);
  })
  .then(() => {
    return StockTokenInstance.mint(cristobal, 30);
  })
  .then(() => {
    return StockTokenInstance.mint(eduardo, 47);
  })
  .then(() => {
    return StockTokenInstance.mint(patricio, 74);
  })
  .then(() => {
    return deployer.deploy(Stock, addressDAI, 300);
  })
  .then((_instance) => {
    StockInstance = _instance;
    return StockTokenInstance.transferOwnership(StockInstance.address);
  })
  .then((_period) => {
    return StockInstance.begun(StockTokenInstance.address);
  })
  .then(() => {
    return StockInstance.transferOwnership(addressDAO);
  })
};