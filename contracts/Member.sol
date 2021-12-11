pragma solidity ^0.8.0;

import "@openzeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol";

contract Member is Ownable {
    address private DAOaddress;

    constructor() public {
        // the DAO contract calls the constructor, so owner() returns the DAO address at initialization
        _DAOaddress = owner();
        // ownership is transferred to creator's address within the DAO's joinDAO() function
    }

    function vote(address proposal, bool y_n) public view onlyOwner {
        ISimpleDAO(_DAOaddress).vote(proposal, y_n);
    }

    function DAOaddress() public view returns (address) {
        return _DAOaddress;
    }
}
