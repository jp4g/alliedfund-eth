const ERC20 = artifacts.require("ERC20")

module.exports = async (deployer, network, accounts) => {
  deployer.deploy(ERC20)
  let instance = await ERC20.deployed()
  await mint(instance, accounts)
}

let mint = async (instance, accounts) => {
    for (let i = 1; i < accounts.length; i++)
        await instance.mint(10000000, accounts[i], {from: accounts[0]})
} 