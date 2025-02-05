// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {PriceConverter} from "../../src/PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {FundMeDeploy} from "../../script/FundMeDeploy.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;
    address USER = makeAddr("USER");

    function setUp() external {
        FundMeDeploy script = new FundMeDeploy();
        fundMe = script.run();
        vm.deal(USER, 100e18);
    }

    function testMinimumDollar() external view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() external view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testGetPrice() external view {
        assertEq(PriceConverter.getPrice(fundMe.s_priceFeed()), 200e18);
    }

    function testFundFalisWithoutEnoughEth() external {
        vm.expectRevert();
        fundMe.fund{value: 1e16}();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 5e18}();
        _;
    }

    function testFundUpdateDataStructure() external funded {
        assertEq(fundMe.getFundersCount(), 1);
        assertEq(fundMe.getFunders(0), USER);
        assertEq(fundMe.getFunderAmount(USER), 5e18);
    }

    function testOnluOwnerCanWithdraw() external funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawAsOwner() external {
        uint startingUserBalance = fundMe.i_owner().balance;
        uint startingContractBalance = address(fundMe).balance;
        vm.prank(fundMe.i_owner());
        fundMe.withdraw();
        uint endingUserBalance = fundMe.i_owner().balance;
        uint endingContractBalance = address(fundMe).balance;
        assertEq(endingContractBalance, 0);
        assertEq(
            startingUserBalance + startingContractBalance,
            endingUserBalance 
        );
    }

    function testWithdrawAsOwnerWithMultipleFunders() external {
        for (uint160 i = 0; i < 10; i++) {
            hoax(address(i), 10e18);
            fundMe.fund{value: 5e18}();
        }
        uint startingUserBalance = fundMe.i_owner().balance;
        uint startingContractBalance = address(fundMe).balance;
        uint gasStart= gasleft();
        vm.txGasPrice(1);
        vm.startPrank(fundMe.i_owner());
        fundMe.withdraw();
        vm.stopPrank();
uint gasEnd= gasleft();
        console.log("Gas used: ", gasStart-gasEnd);
        assertEq(address(fundMe).balance, 0);
        assertEq(
            startingUserBalance + startingContractBalance,
            fundMe.i_owner().balance
        );

    }
}
