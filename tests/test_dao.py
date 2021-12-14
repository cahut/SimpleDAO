from brownie import (
    SimpleDAO,
    Member,
    Proposal,
    accounts,
    network,
    config,
    interface,
    reverts,
)
from scripts.helpful_scripts import get_account
from web3 import Web3


def test_balances():
    account = get_account()

    dao = SimpleDAO.deploy(50, 50, 1 * 10 ** 18, {"from": account})

    assert dao.memberStakes(account, {"from": account}) == 0

    member_tx = dao.joinDAO({"from": account, "value": 1.2 * 10 ** 18})
    member = interface.IMember(member_tx.events["NewMember"]["member"])

    assert dao.memberStakes(member.address, {"from": account}) == 1.2 * 10 ** 18


def test_proposal():
    account = get_account()

    dao = SimpleDAO.deploy(50, 50, 1 * 10 ** 18, {"from": account})

    member_tx = dao.joinDAO({"from": account, "value": 1.2 * 10 ** 18})
    member = interface.IMember(member_tx.events["NewMember"]["member"])

    proposal = Proposal.deploy(dao.address, 1 * 10 ** 18, {"from": account})
    proposal.submit({"from": account})

    with reverts():
        proposal.execute({"from": account})

    member.vote(proposal.address, True, {"from": account})

    assert dao.balance() == 1.2 * 10 ** 18
    proposal.execute({"from": account})

    assert proposal.balance() == 1 * 10 ** 18


def test_voting():
    account = get_account()

    dao = SimpleDAO.deploy(50, 50, 1 * 10 ** 18, {"from": account})

    member_tx = dao.joinDAO({"from": account, "value": 1.2 * 10 ** 18})
    member = interface.IMember(member_tx.events["NewMember"]["member"])

    proposal = Proposal.deploy(dao.address, 1 * 10 ** 18, {"from": account})
    proposal.submit({"from": account})

    member.vote(proposal.address, True, {"from": account})
    proposal.execute({"from": account})

    with reverts():
        member.vote(proposal.address, True, {"from": account})

    new_acc = accounts[1]

    new_member_tx = dao.joinDAO({"from": new_acc, "value": 1.2 * 10 ** 18})
    new_member = interface.IMember(new_member_tx.events["NewMember"]["member"])

    with reverts():
        new_member.vote(proposal.address, True, {"from": new_acc})


def test_quorum():
    account = get_account()
    new_acc = accounts[1]

    dao = SimpleDAO.deploy(50, 60, 1 * 10 ** 18, {"from": account})

    member_tx = dao.joinDAO({"from": account, "value": 1.2 * 10 ** 18})
    member = interface.IMember(member_tx.events["NewMember"]["member"])
    new_member_tx = dao.joinDAO({"from": new_acc, "value": 1.2 * 10 ** 18})
    new_member = interface.IMember(new_member_tx.events["NewMember"]["member"])

    proposal = Proposal.deploy(dao.address, 1 * 10 ** 18, {"from": account})
    proposal.submit({"from": account})

    with reverts():
        member.vote(proposal.address, True, {"from": new_acc})

    member.vote(proposal.address, True, {"from": account})

    print(
        dao.proposalYes(proposal.address, {"from": account})
        + dao.proposalNo(proposal.address, {"from": account})
    )
    print(dao.quorum({"from": account}) * dao.balance())
    with reverts():
        proposal.execute({"from": account})

    new_member.vote(proposal.address, True, {"from": new_acc})
    proposal.execute({"from": account})
