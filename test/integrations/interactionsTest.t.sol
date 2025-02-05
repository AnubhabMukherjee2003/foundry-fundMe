// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {PriceConverter} from "../../src/PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {FundMeDeploy} from "../../script/FundMeDeploy.s.sol";
import {FundFundme, WithdrawFundme} from "../../script/Interactions.s.sol";

contract FundMeTestIntegration is Test {
    FundMe public fundMe;
    address USER = makeAddr("USER");

    function setUp() external {
        FundMeDeploy script = new FundMeDeploy();
        fundMe = script.run();
        vm.deal(USER, 100e18);
    }

    function testUsersCanFundInteract() external {
        // vm.prank(USER);
        FundFundme fundFundme = new FundFundme();
        fundFundme.fundFundme(address(fundMe));

        WithdrawFundme withdrawFundme = new WithdrawFundme();
        withdrawFundme.withdrawFundme(address(fundMe));
        
        assertEq(fundMe.getFundersCount(), 0);
        assert(fundMe.i_owner().balance > 0);
        assertEq(address(fundMe).balance, 0);
    }
}
