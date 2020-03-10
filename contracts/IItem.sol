pragma solidity >= 0.4.0 < 0.7.0;
pragma experimental ABIEncoderV2;

import './openzeppelin/SafeMath.sol';
import './openzeppelin/Secondary.sol';
import './openzeppelin/IERC20.sol';

abstract contract IItem is Secondary {

    using SafeMath for uint256;

    event Funded(address _funder, uint _serial);
    event Ended(bool _successful);

    enum State {Initialized, Active, Ended}
    State current;

    modifier onlyState(uint _state, State _required) {
        require(_state == uint(_required), "It is not the correct period for this action!");
        _;
    }

    struct Perk {
        uint cost; //uint cost to recieve perk
        string reward; //string representing what reward will be given for funding the project
    }

    struct Funder {
        uint contribution; //the number of euro tokens contributed to this project
        uint perk; //the index of the perk tier achieved by the funder
        address funder; //address of the funding government
    }

    address lister; //address of the account that listed the item
    string title; //title of the listing
    string description; //description of the listing;
    Perk[] perks; //array of all available perks
    uint funds; //total number of euros that must be raised for the project to successfully fund
    uint expiry; //the UNIX timestamp of the fundraiser expiry

    Funder[] funders;
    IERC20 Euro;

    /**
     * @dev modifier onlyState(0, State.Initialized)
     * @dev modifier onlyPrimary
     * Describe the item being created
     * @param _title string: the title of the listing
     * @param _description string: the description of the listing
     * @param _funds uint: the required funds to complete this project
     */
    function describe(string memory _title, string memory _description, uint _funds) public virtual;

    /**
     * @dev modifier onlyState(0, State.Initialized)
     * @dev modifier onlyPrimary
     * Set the UNIX time until the event expires
     * @param _unix uint: the unix time that the item is no longer active
     */
    function expiration(uint _unix) public virutal;
    
    /**
     * @dev modifier onlyState(0, State.Initialized)
     * @dev modifier onlyPrimary
     * Add a perk to this listing
     * @param _cost uint: the cost required to achieve the perk
     * @param _reward string: string representation of the reward
     */
    function addPerk(uint _cost, string memory _reward) public virtual;

    /**
     * @dev modifier onlyPrimary
     * Fund this item listing
     * @param _contribution uint: the number of euro tokens contributed
     * @param _funder address: the address of the funding domain
     * @return _perk uint: the uint code of the perk earned
     */
    function fund(uint _contribution, address _funder) public virtual payable returns (uint _perk);

    /**
     * @dev modifier onlyPrimary
     * End the item listing. Pays refunds to all funders if funding fails, and pays lister if funding succeeds.
     * @return _successful bool: true if paid to lister, and false if refunded.
     */
    function end() public virtual returns (bool _successful);

    /**
     * Returns the remaining time left in the contract.
     * @return _unix uint: the unix seconds left until expiry. Returns 0 if expired.
     */
    function remainingTime() public virtual view returns (uint _unix);

    /**
     * Determine whether this item's fundraiser has been successful or not
     * @return _successful bool: true if the contributions are higher than the item's fundraiser goal, and false otherwise
     */
    function successful() public virtual view returns (bool _successful);

    /**
     * Return a description of the item
     * @return _lister address: the address of the listing company
     * @return _title string: the title of the listing
     * @return _description string: the description of the listing
     * @return _funds uint: the total fundraising goal of this listing
     * @return _expiry uint: the UNIX timecode that the item expires at
     */
    function getDescription() public virtual view returns (
        address _lister,
        string memory _title,
        string memory _description,
        uint _funds, 
        uint _expiry);

    /**
     * Return all funders of the project
     * @return _funders Funder[]: array of funder structs
     */
    function getFunders() public virtual view returns (Funder[] memory _funders);
}