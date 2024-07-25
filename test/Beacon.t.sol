// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "../src/Beacon.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BeaconTest is Test {
    Beacon beacon;
    address initialImplementation;
    address newImplementation;

    function setUp() public {
        initialImplementation = address(new DummyImplementation());
        beacon = new Beacon(initialImplementation);
        newImplementation = address(new DummyImplementation());
    }

    function testInitialImplementation() public {
        assertEq(beacon.implementation(), initialImplementation);
    }

    function testUpdateImplementation() public {
        beacon.update(newImplementation);
        assertEq(beacon.implementation(), newImplementation);
    }
}

contract DummyImplementation {}
