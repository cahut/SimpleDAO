// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IProposal.sol";
import "./ISimpleDAO.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Proposal is IProposal {
    address public DAOaddress;
    uint256 public amountRequested;

    constructor(address _DAOaddress, uint256 _amountRequested) {
        require(_DAOaddress != address(0), "DAO cannot be zero address");

        DAOaddress = _DAOaddress;
        amountRequested = _amountRequested;
    }

    receive() external payable {}

    function execute() external {
        ISimpleDAO(DAOaddress).closeProposal(address(this));
        ISimpleDAO(DAOaddress).implementProposal(amountRequested);

        // Rest of the instructions for what to do with the funds
    }

    function submit() external {
        ISimpleDAO(DAOaddress).submitProposal(amountRequested);
    }
}
