// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundme is Script {
    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "MyContract",
            block.chainid
        );
        vm.startBroadcast();
        fundFundme(contractAddress);
        vm.stopBroadcast();
    }

    function fundFundme(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).fund{value: 10e18}();
        vm.stopBroadcast();
        // console.log("Funded Contract with %s", 5e18);
    }
}

contract WithdrawFundme is Script {
    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "MyContract",
            block.chainid
        );
        vm.startBroadcast();
        withdrawFundme(contractAddress);
        vm.stopBroadcast();
    }

    function withdrawFundme(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).withdraw();
        vm.stopBroadcast();
        // console.log("Funded Contract with %s", 5e18);
    }
}
