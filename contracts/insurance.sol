// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "hardhat/console.sol";

contract ParcelSure {

    struct Product {
        uint256 productId;
        address payable insurer;
        uint256 dailyDelayPayout;
        uint256 failurePayout;
        uint256 availCapital;
        uint256 premium;
    }

    struct Policy {
        uint256 policyId;
        uint256 productId;
        uint256 packageId;
    }

    uint256 public productId = 0;
    uint256 public policyId = 0;
    mapping(uint256 => Product) public products;
    mapping(uint256 => Policy) public policies;
    
}