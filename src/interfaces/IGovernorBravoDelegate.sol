// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum ProposalState {
    Pending,
    Active,
    Canceled,
    Defeated,
    Succeeded,
    Queued,
    Expired,
    Executed
}

interface IGovernorBravoDelegate {
    function castVote(uint256, uint8) external;
    function execute(uint proposalId) external payable;
    function proposalThreshold() external view returns (uint256);
    function propose(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256);
    function queue(uint proposalId) external;
    function quorumVotes() external view returns (uint256);
    function state(uint256) external view returns (ProposalState);
    function votingDelay() external view returns (uint256);
    function votingPeriod() external view returns (uint256);
}
