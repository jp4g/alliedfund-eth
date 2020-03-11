pragma solidity >= 0.4.0 < 0.7.0;
pragma experimental ABIEncoderV2;

import './IItem.sol';


contract Item is IItem {

    constructor(address _euro, address _lister) public {
        Euro = IERC20(_euro);
        lister = _lister;
        current = State.Initialized;
    }

    /// FUNCTIONAL METHODS ///

    function describe(string memory _title, string memory _description, uint _funds)
        public override onlyState(State.Initialized) onlyPrimary {

        title = _title;
        description = _description;
        funds = _funds;
    }

    function expiration(uint _unix) public override onlyState(State.Initialized) onlyPrimary {
        expiry = now + _unix;
    }

    function addPerk(uint _cost, string memory _reward) public override onlyState(State.Initialized) onlyPrimary {
        Perk memory perk;
        perk.cost = _cost;
        perk.reward = _reward;
        perkSerial = perkSerial.add(1);
        perks[perkSerial] = perk;
    }

    function confirm() public override onlyState(State.Initialized) onlyPrimary {
        current = State.Active;
    }

    function contribute(uint _funds, address _funder) public override onlyState(State.Active) {
        contributorSerial = contributorSerial.add(1);
        contributorID[_funder] = contributorSerial;
        Contributor storage contributor = contributors[contributorSerial];
        contributor.funds = _funds;
        contributor.funder = _funder;
    }

    function end() public override onlyState(State.Active) {
        uint balance = Euro.balanceOf(address(this));
        if (balance >= funds)
            Euro.transfer(lister, balance);
        else
            refund();
    }

    /// VIEWABLE METHODS ///

    function getPerk(uint _serial) public override view returns (uint _cost, string memory _reward) {
        _cost = perks[_serial].cost;
        _reward = perks[_serial].reward;
    }

    function remainingTime() public override view returns (uint _unix) {
        if (now > expiry || current != State.Active)
            return 0;
        else
            return expiry - now;
    }

    function rewardedPerk(uint _contributor) public override view returns (uint _perk) {
        uint index;
        uint contribution = contributors[_contributor].funds;
        for (uint i = 0; i < perkSerial; i++) {
            Perk memory perk = perks[i];
            if (perk.cost < contribution) {
                if (perk.cost > perks[i].cost)
                    index = i;
            }
        }
        return index;
    }

    /// INTERNAL METHODS ///

    function refund() internal {
        for (uint i = 0; i < contributorSerial; i++)
            Euro.transfer(contributors[i].funder, contributors[i].funds);
    }
}