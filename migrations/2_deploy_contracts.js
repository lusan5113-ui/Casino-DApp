const Casino = artifacts.require("Casino");

module.exports = function (deployer) {
  // 部署合约，并设置最小下注金额
  deployer.deploy(Casino, 100000000000000); 
};
