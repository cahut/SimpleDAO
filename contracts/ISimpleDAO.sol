pragma solidity ^0.8.0;

import "./Member.sol";

interface ISimpleDAO {
    enum Status {
        OPEN,
        DECIDING,
        PASSED,
        REJECTED,
        IMPLEMENTED
    }

    function joinDAO() external payable;

    function vote(address proposal, bool y_n) external;

    function closeProposal(address proposal) external;

    function implementProposal(uint256 amountToSend) external;

    function minimumEntranceFee() public view returns (uint256);
}
