/* global artifacts */
var RDaiAdmin = artifacts.require('RDaiAdmin.sol')

module.exports = function(deployer) {
  deployer.deploy(RDaiAdmin)
}
