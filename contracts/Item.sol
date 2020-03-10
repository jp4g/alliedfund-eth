pragma solidity >= 0.4.0 < 0.7.0;
pragma experimental ABIEncoderV2;

import './IItem.sol';


contract Item is IItem {

    modifier isActive() {
        require(remainingTime() != 0, "Item is no longer active!");
        _;
    }

    constructor(address _euro, address _lister) public {
        Euro = IERC20(_euro);
        lister = _lister;
        description = _description;
        title = _title;
        funds = _funds;
        expiry = _expiry;
    }


    function fund(uint _contribution, address _funder) public override isActive onlyPrimary {
        Funder memory contributor;
        contributor.funder = _funder;
        contributor.contribution = _contribution;
        funders.push(contributor);
    }

    function end() public override onlyPrimary returns (bool _successful) {
        require (remainingTime() == 0, "Cannot end item while crowdfunding is still occuring!");
        if (successful()) {
            Euro.transfer(lister, Euro.balanceOf(address(this)));
        } else {
            refund();
        }
    }

    function remainingTime() public override view returns (uint _unix) {
        if (now >= expiry)
            return 0;
        else
            return expiry - now;
    }

    function successful() public override view returns (bool _successful) {
        uint balance = Euro.balanceOf(address(this));
        return balance >= funds;
    }

    function getDescription() public override view returns (
        address _lister,
        string memory _title,
        string memory _description,
        uint _funds,
        uint _expiry) {
        
        _lister = lister;
        _title = title;
        _description = description;
        _funds = funds;
        _expiry = expiry;
    }

    function getFunders() public override view returns (Funder[] memory _funders) {
        _funders = funders;
    }

    /**
     * Determine the perk that will be awarded according to the contribution.
     * @dev perks must be ordered from lowest to highest.
     */
    //function choosePerk(uint _contribution) internal view returns (uint _perk) {
    //    for(uint i = perks.length - 1; i >= 0; i--) {
    //        if (_contribution >= perks[i].cost)
    //            return i+1;
    //    }
    //    return 0;
    //}

    function refund() internal {
        for (uint i = 0; i < funders.length; i++)
            Euro.transfer(funders[i].funder, funders[i].contribution);
    }
}