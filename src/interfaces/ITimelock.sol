// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITimelock {
    function delay() external view returns (uint256);
}
