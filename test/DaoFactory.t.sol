// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "../src/DaoFactory.sol";
import "../src/HybridDAO.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DaoFactoryTest is Test {
    DaoFactory factory;
    Beacon beacon;
    address owner = address(0x123);
    address daoImplementation;

    function setUp() public {
        beacon = new Beacon(address(new HybridDAO()));
        factory = new DaoFactory(address(beacon));
        vm.startPrank(owner);
        daoImplementation = address(new HybridDAO());
        beacon.update(daoImplementation);
        vm.stopPrank();
    }

    function testCreateDao() public {
        address[] memory owners = new address[](1);
        owners[0] = owner;
        uint256[] memory votes = new uint256[](1);
        votes[0] = 1000;

        factory.createDao(
            "TokenName",
            "TKN",
            1000000,
            owners,
            votes,
            500,
            100,
            1 days
        );

        address daoProxy = factory.getUserDao(owner)[0];
        assertEq(BeaconProxy(daoProxy).implementation(), daoImplementation);
    }

    function testDaoCreationEvent() public {
        address[] memory owners = new address[](1);
        owners[0] = owner;
        uint256[] memory votes = new uint256[](1);
        votes[0] = 1000;

        vm.expectEmit(true, true, true, true);
        emit DaoCreated(owner, address(new BeaconProxy(address(beacon), "")));
        factory.createDao(
            "TokenName",
            "TKN",
            1000000,
            owners,
            votes,
            500,
            100,
            1 days
        );
    }

    event DaoCreated(address indexed creator, address indexed dao);
}
