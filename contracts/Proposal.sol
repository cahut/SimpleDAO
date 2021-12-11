// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IProposal.sol";
import "./ISimpleDAO.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Proposal is IProposal {
    address DAOaddress;
    uint256 amountRequested;

    constructor(address _DAOaddress, uint256 _amountRequested) {
        DAOaddress = _DAOaddress;
        amountRequested = _amountRequested;
    }

    function execute() external view virtual {}

    function submit() external view {}
}
