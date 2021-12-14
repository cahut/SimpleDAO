// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Member.sol";
import "./ISimpleDAO.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SimpleDAO is ISimpleDAO, ReentrancyGuard {
    mapping(address => uint256) public memberStakes;
    mapping(address => Status) public proposalStatus;
    mapping(address => uint256) public proposalNo;
    mapping(address => uint256) public proposalYes;
    mapping(address => mapping(address => bool)) votingHistory;

    uint8 public votingThreshold; // as a percentage
    uint8 public quorum; // as a percentage
    uint256 public dollarEntranceFee;

    event NewMember(address member, uint256 stake);
    event Voted(address member, address proposal, bool y_n, uint256 stake);
    event ProposalCreated(address proposal, address creator);
    event ProposalClosed(address proposal, bool passed);

    constructor(
        uint8 _votingThreshold,
        uint8 _quorum,
        uint256 _dollarEntranceFee
    ) {
        votingThreshold = _votingThreshold;
        quorum = _quorum;
        dollarEntranceFee = _dollarEntranceFee;
    }

    /**
     * @dev Function called by any address, which given a sufficient amount
     * of ETH will create a new member contract of which they are the owner.
     */
    function joinDAO() external payable {
        require(
            msg.value >= minimumEntranceFee(),
            "Payment below minimum entrance fee"
        );
        require(memberStakes[msg.sender] == 0, "You are already a member");

        Member member = new Member();
        memberStakes[address(member)] = msg.value;

        emit NewMember(address(member), msg.value);
        member.transferOwnership(msg.sender);
    }

    /**
     * @dev Function called by a Proposal contract to register itself
     * and become open to voting until quorum is reached
     */
    function submitProposal(uint256 _amountRequested) external {
        address proposal = msg.sender;
        require(
            address(this).balance >= _amountRequested,
            "Requested amount exceeds treasury"
        );
        require(
            (proposalYes[proposal] == 0) && (proposalNo[proposal] == 0),
            "Proposal has already been submitted"
        );

        proposalStatus[proposal] = Status.OPEN;
    }

    /**
     * @dev Function called by a any member of the DAO to vote on a proposal
     * given its address and according to their voting weight.
     * NOTE: nonReentrant modifier used to prevent double-voting
     */
    function vote(address proposal, bool y_n) external nonReentrant {
        require(memberStakes[msg.sender] > 0, "You are not a member");
        require(
            proposalStatus[proposal] == Status.OPEN,
            "Proposal is not open to voting"
        );
        require(!votingHistory[proposal][msg.sender], "You have already voted");

        votingHistory[proposal][msg.sender] = true;

        // if y_n is YES, add weight to the proposalYes count, otherwise to proposalNo
        uint256 votingWeight = memberStakes[msg.sender];
        uint256 totalNo = proposalNo[proposal];
        uint256 totalYes = proposalYes[proposal];

        if (y_n) {
            proposalYes[proposal] = totalYes + votingWeight;
        } else {
            proposalNo[proposal] = totalNo + votingWeight;
        }

        emit Voted(msg.sender, proposal, y_n, votingWeight);
    }

    /**
     * @dev Function called by any user to close a proposal vote when quorum
     * has been reached.
     */
    function closeProposal(address proposal) external {
        uint256 balance = address(this).balance;
        require(
            (proposalNo[proposal] + proposalYes[proposal]) >=
                (quorum * balance) / 100,
            "Quorum has not been reached"
        );

        proposalStatus[proposal] = Status.DECIDING;
        uint256 yesVotes = proposalYes[proposal];
        uint256 noVotes = proposalNo[proposal];

        if (yesVotes / votingThreshold > noVotes / (100 - votingThreshold)) {
            proposalStatus[proposal] = Status.PASSED;
            emit ProposalClosed(proposal, true);
        } else {
            proposalStatus[proposal] = Status.REJECTED;
            emit ProposalClosed(proposal, false);
        }
    }

    /**
     * @dev Function called by a successful proposal to claim the money
     * it requested.
     * NOTE: call.value()() is used because the gas stipend might be too low to
     * execute the proposal's instructions.
     */
    function implementProposal(uint256 amountToSend) external nonReentrant {
        require(
            proposalStatus[msg.sender] == Status.PASSED,
            "This proposal has not been accepted"
        );
        require(
            amountToSend <= address(this).balance,
            "Amount requested too large"
        );

        proposalStatus[msg.sender] = Status.IMPLEMENTED;

        // payable(msg.sender).transfer(amountToSend);

        // we send the requested amount along with all available gas
        (bool success, ) = msg.sender.call{value: amountToSend}("");
        require(success, "Transfer failed.");
    }

    /**
     * @dev Returns the minimum entrance fee in ether
     */
    function minimumEntranceFee() public view returns (uint256) {
        return dollarEntranceFee;
    }
}
