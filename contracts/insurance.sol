// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "hardhat/console.sol";

contract ParcelSure {

    struct Product {
        uint256 productId;
        address insurer;
        uint256 dailyDelayPayout;
        uint256 availCapital;
        uint128 premium;
        uint128 maxDelayDays;
    }

    struct Policy {
        uint256 policyId;
        uint256 productId;
        uint256 packageId;
        uint256 dateCreated;
        uint256 value;
    }

    uint256 public productId = 0;
    uint256 public policyId = 0;
    mapping(uint256 => Product) public products;
    mapping(uint256 => Policy) public policies;

    function createProduct(uint256 dailyDelayPayout, uint128 premium, uint128 maxDelayDays) public payable {
        require(
            msg.value > (dailyDelayPayout * maxDelayDays), 
            "Not enough capital provided to insure a policy"
        );
        require(premium > 0);
        require(maxDelayDays > 0 && maxDelayDays < 365);

        Product memory product = Product({
            productId: productId,
            insurer: msg.sender,
            dailyDelayPayout: dailyDelayPayout,
            availCapital: msg.value,
            premium: premium,
            maxDelayDays: maxDelayDays
        });
        products[productId] = product;
        productId++;
    }
}