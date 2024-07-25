// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "../src/HybridDAO.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract HybridDAOTest is Test {
    HybridDAO dao;
    address owner = address(0x123);
    address member = address(0x456);

    function setUp() public {
        vm.startPrank(owner);
        dao = new HybridDAO();
        dao.initialize(
            "TokenName",
            "TKN",
            1000000,
            new address ,
            new uint256 ,
            500,
            100,
            1 days
        );
        vm.stopPrank();
    }

    function testInitialParameters() public {
        assertEq(dao.maxSupply(), 1000000);
        assertEq(dao.executionThreshold(), 500);
        assertEq(dao.proposalThreshold(), 100);
        assertEq(dao.votePeriod(), 1 days);
    }

    function testMint() public {
        address[] memory owners = new address[](1);
        owners[0] = member;
        uint256[] memory votes = new uint256[](1);
        votes[0] = 100;

        vm.startPrank(owner);
        dao.mint(owners, votes);
        vm.stopPrank();

        assertEq(dao.balanceOf(member), 100);
    }

    function testCreateProposal() public {
        address[] memory targets = new address[](1);
        targets[0] = address(dao);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes memory calldatas = abi.encodeWithSignature("mint(address,uint256)", member, 100);
        string memory description = "Increase token supply";

        vm.startPrank(owner);
        uint256 proposalId = dao.createProposal(targets, values, calldatas, description);
        vm.stopPrank();

        assert(dao.checkProposalStatus(proposalId));
    }

    function testExecuteProposal() public {
        address[] memory targets = new address[](1);
        targets[0] = address(dao);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes memory calldatas = abi.encodeWithSignature("mint(address,uint256)", member, 100);
        bytes32 descriptionHash = keccak256(abi.encodePacked("Increase token supply"));

        vm.startPrank(owner);
        uint256 proposalId = dao.hashProposal(targets, values, calldatas, descriptionHash);
        dao.createProposal(targets, values, calldatas, "Increase token supply");
        dao.executeProposal(targets, values, calldatas, descriptionHash);
        vm.stopPrank();

        assert(dao.Proposals(proposalId).executed);
    }

    function testVoteProposal() public {
        address[] memory targets = new address[](1);
        targets[0] = address(dao);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes memory calldatas = abi.encodeWithSignature("mint(address,uint256)", member, 100);
        string memory description = "Increase token supply";

        vm.startPrank(owner);
        uint256 proposalId = dao.createProposal(targets, values, calldatas, description);
        dao.voteProposal(proposalId);
        vm.stopPrank();

        assert(dao.ProposalVotes(proposalId).hasVoted[owner]);
    }

    function testCancelProposal() public {
        address[] memory targets = new address[](1);
        targets[0] = address(dao);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes memory calldatas = abi.encodeWithSignature("mint(address,uint256)", member, 100);
        string memory description = "Increase token supply";

        vm.startPrank(owner);
        uint256 proposalId = dao.createProposal(targets, values, calldatas, description);
        dao.cancelProposal(proposalId);
        vm.stopPrank();

        assert(dao.Proposals(proposalId).canceled);
    }

    function testModifyDAO() public {
        uint256 newMaxSupply = 2000000;
        uint256 newExecutionThreshold = 1000;
        uint256 newProposalThreshold = 200;
        uint256 newVotePeriod = 2 days;

        vm.startPrank(owner);
        dao.modifyDAO(newMaxSupply, newExecutionThreshold, newProposalThreshold, newVotePeriod);
        vm.stopPrank();

        assertEq(dao.maxSupply(), newMaxSupply);
        assertEq(dao.executionThreshold(), newExecutionThreshold);
        assertEq(dao.proposalThreshold(), newProposalThreshold);
        assertEq(dao.votePeriod(), newVotePeriod);
    }
}
