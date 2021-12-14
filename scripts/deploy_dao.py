from brownie import (
    SimpleDAO,
    Member,
    Proposal,
    accounts,
    network,
    config,
    interface,
)
from scripts.helpful_scripts import get_account
from web3 import Web3


def main():
    deploy_dao()


def deploy_dao():
    account = get_account()

    dao = SimpleDAO.deploy(50, 50, 1 * 10 ** 18, {"from": account})
    member_tx = dao.joinDAO({"from": account, "value": 1.2 * 10 ** 18})

    member = interface.IMember(member_tx.events["NewMember"]["member"])
    proposal = Proposal.deploy(dao.address, 1 * 10 ** 18, {"from": account})

    proposal.submit({"from": account})

    return {"dao": dao, "account": account, "member": member, "proposal": proposal}
