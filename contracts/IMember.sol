// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMember {
    function vote(address proposal, bool y_n) external;

    function DAOaddress() external view returns (address);
}
