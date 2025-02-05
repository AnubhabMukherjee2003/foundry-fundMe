// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter{
    function getPrice(AggregatorV3Interface priceFeed) public view returns (uint) {
        // (,int price,,,) = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).latestRoundData();
        (,int price,,,) = priceFeed.latestRoundData();
        return uint(price) * 1e10;
    }
    function getConversionRate(uint ethAmount,AggregatorV3Interface priceFeed) public view returns (uint){
        uint ethPrice= getPrice(priceFeed);
        uint ethAmountInUse=(ethPrice*ethAmount)/1e18;
        return ethAmountInUse;
    }
}