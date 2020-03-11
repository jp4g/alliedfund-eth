let { expect } = require('chai')
let { BN, expectRevert } = require('@openzeppelin/test-helpers')

let ERC20Contract = artifacts.require('./ERC20')
let ItemContract = artifacts.require('./Item')

let dummy_items = require('../dummy_items.json')

contract("Item Test", (accounts) => {
    before(async () => {
        this.token = await ERC20Contract.new({from: accounts[0]})
        this.instance = await ItemContract.new(this.token.address, accounts[1], {from: accounts[0]})
    })

    describe('Item Creation: Individual', async () => {
        it('Descriptions are added', async () => {
            console.log("Pre-description: ")
            console.log("=-=-=-=-=-=-=-=-=")
            console.log("Current State: ", await this.instance.current())
            console.log("Title: ", await this.instance.title())
            console.log("Description: ", await this.instance.description())
            console.log("Required Funding: ", (await this.instance.funds()).toNumber())
            await this.instance.describe(
                dummy_items[0].title,
                dummy_items[0].description,
                dummy_items[0].funds,
                { from: accounts[0] }
            )
            console.log("Post-description: ")
            console.log("=-=-=-=-=-=-=-=-=")
            console.log("Current State: ", await this.instance.current())
            console.log("Title: ", await this.instance.title())
            console.log("Description: ", await this.instance.description())
            console.log("Required Funding: ", (await this.instance.funds()).toNumber())
        })

        it('Expiration is added', async () => {
            console.log("Pre-expiry")
            console.log("=-=-=-=-=-=-=")
            console.log('Current expiration time: ', (await this.instance.expiry()).toNumber())
            await this.instance.expiration(dummy_items[0].expiry)
            console.log("Post-expiry")
            console.log("=-=-=-=-=-=-=")
            let expiry = (await this.instance.expiry()).toNumber()
            console.log('Current expiration time: ', expiry)
            let now = Date.now()/1000
            console.log('JS Timestamp: ', now)
            console.log('Estimated days until expiration: ', (expiry - now)/24/60/60)
        })
        it('Perks are added', async () => {

            let getPerks = async (_serial) => {
                let arr = [];
                for (let i = 0; i < _serial; i++)
                    arr[i] = await this.instance.perks(i)
                return arr;
            }

            console.log("No Perks")
            console.log("=-=-=-=-=-=-=")
            let serial = (await this.instance.perkSerial()).toNumber()
            let perks = await getPerks(serial)
            console.log("Perk Serial: ", serial)
            console.log("Perks: ", perks)
            console.log("=-=-=-=-=-=-=")

            console.log("1 Perk")
            console.log("=-=-=-=-=-=-=")
            console.log(dummy_items[0])
            let perk = dummy_items[0].perks[0]
            await this.instance.addPerk(perk.cost, perk.reward)
            serial = (await this.instance.perkSerial()).toNumber()
            perks = await getPerks(serial)
            console.log("Perk Serial: ", serial)
            console.log("Perks: ", perks)
            console.log("=-=-=-=-=-=-=")

            console.log("2 Perks")
            console.log("=-=-=-=-=-=-=")
            perk = dummy_items[0].perks[1]
            await this.instance.addPerk(perk.cost, perk.reward)
            serial = (await this.instance.perkSerial()).toNumber()
            perks = await getPerks(serial)
            console.log("Perk Serial: ", serial)
            console.log("Perks: ", perks)
            console.log("=-=-=-=-=-=-=")

            console.log("3 Perks")
            console.log("=-=-=-=-=-=-=")
            perk = dummy_items[0].perks[2]
            await this.instance.addPerk(perk.cost, perk.reward)
            serial = (await this.instance.perkSerial()).toNumber()
            perks = await getPerks(serial)
            console.log("Perk Serial: ", serial)
            console.log("Perks: ", perks)
            console.log("=-=-=-=-=-=-=")
        })

        it('Item is confirmed', async () => {
            console.log("Pre-confirmation")
            console.log("=-=-=-=-=-=-=")
            console.log("Current State: ", await this.instance.current())
            await this.instance.confirm()
            console.log("Post-confirmation")
            console.log("=-=-=-=-=-=-=")
            console.log("Current State: ", await this.instance.current())

        })
    })

    describe('Item Funding', async () => {
        it('Adding a contributor', async () => {

        })

        it('Adding a second contributor', async () => {

        })
    })

    describe('Item Ending', async () => {
        it('')
    })
})