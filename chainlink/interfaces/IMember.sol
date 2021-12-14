// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract IMember is Ownable {
    function vote(address proposal, bool y_n) external;

    function DAOaddress() external view returns (address);
}
