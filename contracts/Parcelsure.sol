// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "hardhat/console.sol";

/* ERRORS */
error Parcelsure__SendMoreETH();
error Parcelsure__PremiumNeedsToBeMoreThanZero();

contract Parcelsure is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    /* STRUCTS */
    struct InsuranceProduct {
        uint256 productId;
        address payable insurer;
        uint256 dailyDelayPayout;
        uint256 availCapital;
        uint128 premiumPercentage;
        uint128 maxDelayDays;
    }

    struct Policy {
        uint256 policyId;
        uint256 productId;
        uint256 trackingId;
        uint256 dateCreated;
        uint256 value;
        address payable insuree;
    }

    //not sure if we need this
    address payable[] private _users;

    uint256 private _productId = 0;
    uint256 private _policyId = 0;
    mapping(uint256 => InsuranceProduct) public products;
    mapping(uint256 => Policy) public policies;
    mapping(uint256 => address) public addresses;

    /* Events */
    event PolicyPurchased(
        uint256 indexed productId,
        uint256 indexed policyId,
        address indexed insuree
    );

    /* Functions */
    constructor() {
        //ERC20 Link token address
        setChainlinkToken(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);
        //Node oracle address
        setChainlinkOracle(0x3ad58Cd3209e843D876Cf2f318E1F402BE267359);
    }

    function createProduct(
        uint256 dailyDelayPayout,
        uint128 premiumPercentage,
        uint128 maxDelayDays
    ) public payable {
        require(premiumPercentage > 0);
        require(maxDelayDays > 0 && maxDelayDays < 365);

        InsuranceProduct memory product = InsuranceProduct({
            productId: _productId,
            insurer: payable(msg.sender),
            dailyDelayPayout: dailyDelayPayout,
            availCapital: msg.value,
            premiumPercentage: premiumPercentage,
            maxDelayDays: maxDelayDays
        });
        products[_productId] = product;
        _productId++;
    }

    function createPolicy(
        uint256 productId,
        uint256 trackingNumber,
        uint256 value
    ) public payable {
        Policy memory policy = Policy({
            policyId: _policyId,
            productId: productId,
            trackingId: trackingNumber,
            dateCreated: block.timestamp,
            value: value,
            insuree: payable(msg.sender)
        });
        InsuranceProduct memory product = products[policy.productId];

        uint256 premium = policy.value * product.premiumPercentage;
        if (premium <= 0) {
            revert Parcelsure__PremiumNeedsToBeMoreThanZero();
        }
        if (msg.value < premium) {
            revert Parcelsure__SendMoreETH();
        }
        
        policies[_policyId] = policy;
        _policyId++;
        
        emit PolicyPurchased(productId, policy.policyId, msg.sender);
    }

}
