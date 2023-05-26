// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Burninator.sol";
import "../src/Mock721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract BurninatorTest is Test {
    Burninator public burninator;
    Mock721 public mock721;
    address public user1;
    address public user2;

    receive() external payable {}

    fallback() external payable {}

    constructor() {
        burninator = new Burninator();
        mock721 = new Mock721();
        user1 = vm.addr(1);
        user2 = vm.addr(2);
    }

    function testAcceptOffer() public {
        uint256 value = 0.01 ether;
        uint256 balance = 1 ether;

        mock721.mint(user1, 1);

        vm.deal(user2, balance);

        {
            vm.startPrank(user2);
            burninator.donate{value: value}(address(mock721), 0);
            vm.stopPrank();
        }

        {
            vm.startPrank(user1);
            mock721.setApprovalForAll(address(burninator), true);
            burninator.burninate(address(mock721), 0);
            vm.stopPrank();
        }

        assertEq(burninator.offers(address(mock721), 0), 0, "Offer should be removed");
        assertEq(address(burninator).balance, 0, "Contract should be empty");
        assertEq(user1.balance, value, "User should get their money");
        assertEq(user2.balance, balance - value, "User should have donated their money");
    }

    function testDonate() public payable {
        uint256 value = 0.01 ether;
        uint256 balance = 1 ether;

        mock721.mint(user1, 1);

        burninator.donate{value: value}(address(mock721), 0);

        {
            vm.startPrank(user2);
            vm.deal(user2, balance);
            burninator.donate{value: value}(address(mock721), 0);
            vm.stopPrank();
        }

        assertEq(burninator.offers(address(mock721), 0), value * 2, "Offer should be increased");
        assertEq(address(burninator).balance, value * 2, "Contract should have money");
        assertEq(user1.balance, 0, "User should not have money yet");
        assertEq(user2.balance, balance - value, "User should have donated their money");
    }

    function testWithdrawDonation() public {
        uint256 value = 0.01 ether;
        uint256 balance = 1 ether;

        mock721.mint(user1, 1);

        {
            vm.startPrank(user2);
            vm.deal(user2, balance);
            burninator.donate{value: value}(address(mock721), 0);
            burninator.donate{value: value}(address(mock721), 0);

            assertEq(address(burninator).balance, value * 2, "Contract should have money");
            assertEq(user2.balance, balance - value * 2, "User should have donated their money");

            burninator.withdraw(address(mock721), 0);

            assertEq(user2.balance, balance, "User should get their money back");
            vm.stopPrank();
        }

        assertEq(burninator.offers(address(mock721), 0), 0, "Offer should be removed");
        assertEq(address(burninator).balance, 0, "Contract should be empty");
    }
}
