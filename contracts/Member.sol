// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISimpleDAO.sol";
import "./IMember.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Member is IMember, Ownable {
    address private _DAOaddress;

    constructor() {
        // the DAO contract calls the constructor, so owner() returns the DAO address at initialization
        _DAOaddress = owner();
        // ownership is transferred to creator's address within the DAO's joinDAO() function
    }

    function vote(address proposal, bool y_n) public onlyOwner {
        ISimpleDAO(_DAOaddress).vote(proposal, y_n);
    }

    function DAOaddress() public view returns (address) {
        return _DAOaddress;
    }
}
