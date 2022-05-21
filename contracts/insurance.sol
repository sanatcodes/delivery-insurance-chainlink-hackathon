// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "hardhat/console.sol";

contract Insurance{


    uint256 public immutablei_insuranceFee;

    address payable[] public payees;
    uint256 public product_price;
    uint256 public premium;
    uint256 public minimum_price;
    AggregatorV3Interface internal ethUSDPriceFeed;

    enum INSURANCE_STATE {
        PAID,
        UNPAID,
        CLAIMED
    }
    INSURANCE_STATE public insuranceState;

    constructor(
        address _priceFeedAddress
        address _productPrice
        
        ) public {
        ethUSDPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        minimum_price = 50 * (10**18);
        product_price = _productPrice * (10**18);
        lottery_state = LOTTER_STATE.UNPAID;
    }
  
    function calculatePremium() public view returns (uint256){
        //get eth/USD price 
        (,int56 price, , , , ) = ethUSDPriceFeed.latestRoundData;
        uint256 adjustedPrice = uint256(price) * 10**10;

        //get premium in eth
        if(product_price > minimum_price){
            premium = (((product_price * 0.05) * 10 ** 18) / price);
        } else {
            // 50 * 100000 / 2000
           premium = (((minimum_price * 0.05) * 10 ** 18) / price);
        }
        
        return premium;
    }

    function payPremium() public payable {
        require(ins)
        require (msg.value >= calculatePremium(), "Not enough ETH!");
        payees.push(msg.sender);

    }

    function reimbursement() {}

    function trackPackage() {}

    
}