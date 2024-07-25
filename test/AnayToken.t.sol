// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
// pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/xyz.sol";

contract AnayTokenTest is Test {
    AnayToken token;
    address owner;
    address addr1;

    function setUp() public {
        owner = address(this);
        addr1 = address(0x123);
        token = new AnayToken("AnayToken", "ATK");
    }

    function testName() public {
        assertEq(token.name(), "AnayToken");
    }

    function testSymbol() public {
        assertEq(token.symbol(), "ATK");
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1000000 * 10 ** token.decimals());
    }

    function testTransfer() public {
        uint256 amount = 100 * 10 ** token.decimals();
        token.transfer(addr1, amount);
        assertEq(token.balanceOf(addr1), amount);
    }

    function testMint() public {
        uint256 amount = 500 * 10 ** token.decimals();
        token.mint(addr1, amount);
        assertEq(token.balanceOf(addr1), amount);
        assertEq(token.totalSupply(), 1000500 * 10 ** token.decimals());
    }

    function testBurn() public {
        uint256 amount = 200 * 10 ** token.decimals();
        token.burn(amount);
        assertEq(token.balanceOf(owner), 999800 * 10 ** token.decimals());
        assertEq(token.totalSupply(), 999800 * 10 ** token.decimals());
    }

    function testFailMintNotOwner() public {
        vm.prank(addr1); // Change sender to addr1
        token.mint(addr1, 100 * 10 ** token.decimals());
    }
}
