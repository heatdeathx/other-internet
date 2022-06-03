// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";

import { IERC20 } from "../src/interfaces/IERC20.sol";
import { IGovernorBravoDelegate, ProposalState } from "../src/interfaces/IGovernorBravoDelegate.sol";
import { ITimelock } from "../src/interfaces/ITimelock.sol";
import { IUNI } from "../src/interfaces/IUNI.sol";

contract GnosisSafeTest is Test {
    /// @notice The Proxy Factory contract by Gnosis Safe.
    address public factory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
    /// @notice The Gnosis Safe implementation.
    address public safe = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;
    /// @notice The Uniswap timelock.
    address public timelock = 0x1a9C8182C09F50C8318d769245beA52c32BE35BC;
    /// @notice Uniswap Governor Bravo proxy contract.
    address public proxy = 0x408ED6354d4973f66138C91495F2f2FCbd8724C3;
    /// @notice Uniswap Governor Bravo implementation contract.
    address public impl = 0x53a328F4086d7C0F1Fa19e594c9b842125263026;
    /// @notice The Uniswap (UNI) token.
    address public uni = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;

    function setUp() public {}

    function testSafe() public {
        deal(uni, address(this), IGovernorBravoDelegate(proxy).quorumVotes() + 1);
        IUNI(uni).delegate(address(this));
        vm.roll(block.number + 1);

        address[] memory addr = new address[](1);
        uint256[] memory vals = new uint256[](1);
        string[] memory sigs = new string[](1);
        bytes[] memory data = new bytes[](1);
        string memory desc = "Deploy Gnosis Safe upon passing";

        address[] memory keys = new address[](3);
        keys[0] = address(0xDEAD);
        keys[1] = address(0xBEEF);
        keys[2] = address(0xABCD);

        addr[0] = factory;
        vals[0] = 0;
        sigs[0] = "createProxy(address,bytes)";
        data[0] = abi.encode(
            safe,
            abi.encodeWithSignature(
                "function setup(address[],uint256,address,bytes,address,address,uint256,address)",
                keys,
                2,
                address(0),
                "",
                address(0),
                address(0),
                0,
                0
            )
        );

        uint256 id = IGovernorBravoDelegate(proxy).propose(addr, vals, sigs, data, desc);
        vm.roll(block.number + IGovernorBravoDelegate(proxy).votingDelay() + 1);
        IGovernorBravoDelegate(proxy).castVote(id, 1);
        vm.roll(block.number + IGovernorBravoDelegate(proxy).votingPeriod() + 1);
        IGovernorBravoDelegate(proxy).queue(id);
        vm.warp(block.timestamp + ITimelock(timelock).delay() + 1);
        IGovernorBravoDelegate(proxy).execute(id);
        assertEq(uint8(IGovernorBravoDelegate(proxy).state(id)), uint8(ProposalState.Executed));
    }
}
