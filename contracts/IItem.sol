pragma solidity >= 0.4.0 < 0.7.0;
pragma experimental ABIEncoderV2;

import './openzeppelin/SafeMath.sol';
import './openzeppelin/Secondary.sol';
import './openzeppelin/IERC20.sol';

abstract contract IItem is Secondary {


    using SafeMath for uint256;

    modifier onlyState(State _required) {
        require(current == _required, "It is not the correct period for this action!");
        _;
    }

    struct Perk {
        uint cost;
        string reward; 
    }

    struct Contributor {
        address funder;
        uint funds;
    }

    enum State {Initialized, Active, Ended}
    State public current;
    address public lister;
    string public title;
    string public description;
    uint public funds;
    uint public expiry;
    IERC20 Euro;

    uint public perkSerial;
    mapping(uint => Perk) public perks;

    uint contributorSerial;
    mapping(address => uint) public contributorID;
    mapping(uint => Contributor) contributors;

    /// FUNCTIONAL METHODS ///

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
     * @param _unix uint: the number of days in UNIX seconds until the item is no longer active
     */
    function expiration(uint _unix) public virtual;
    
    /**
     * @dev modifier onlyState(0, State.Initialized)
     * @dev modifier onlyPrimary
     * Add a perk to this listing
     * @param _cost uint: the cost required to achieve the perk
     * @param _reward string: string representation of the reward
     */
    function addPerk(uint _cost, string memory _reward) public virtual;

    /**
     * Launch the item
     */
    function confirm() public virtual;

    /**
     * @dev modifier onlyState(State.Active)
     * @dev modifier onlyPrimary
     * Contribute to the project
     * @param _funds uint: the number of euro token transfered into the contract
     * @param _funder address: the address of the funder
     */
    function contribute(uint _funds, address _funder) public virtual;

    /**
     * @dev modifier onlyState(State.Active)
     * @dev modifier onlyPrimary
     * End the crowdfund listing
     * Refunds if funding goal is not hit, pays out if funding goal is hit.
     */
    function end() public virtual;

    /// VIEWABLE METHODS ///

    /**
     * Return the data associated with a perk
     * @param _serial uint: the serial of the perk being viewed
     */
    function getPerk(uint _serial) public virtual view returns (uint _cost, string memory _reward);

    /**
     * Determine the remaining amount of time left until this item is no longer active
     * @dev returns 0 if in initialized state of if no more time
     * @return _unix uint: the number of seconds until the item is no longer available
     */
    function remainingTime() public virtual view returns (uint _unix);

    /**
     * Determine what perk the funder has been awarded based off of their contribution
     * @param _contributor uint: the ID of the contributor
     * @return _perk uint: the ID of the perk
     */
    function rewardedPerk(uint _contributor) public virtual view returns (uint _perk);
}