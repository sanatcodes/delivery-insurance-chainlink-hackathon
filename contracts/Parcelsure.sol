// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "hardhat/console.sol";

/* ERRORS */
error Parcelsure__SendMoreETHtoEnterRaffle();
error Parcelsure__PremiumNeedsToBeMoreThanZero();

contract Parcelsure {
    /* STRUCTS */
    struct InsuranceProduct {
        uint256 productId;
        address insurer;
        uint256 dailyDelayPayout;
        uint256 availCapital;
        uint128 premiumPercentage;
        uint128 maxDelayDays;
    }

    struct Policy {
        uint256 policyId;
        uint256 productId;
        uint256 packageId;
        uint256 dateCreated;
        uint256 value;
        address payable insuree;
    }

    //not sure if we need this
    address payable[] private users;

    uint256 public productId = 0;
    uint256 public policyId = 0;
    mapping(uint256 => InsuranceProduct) public products;
    mapping(uint256 => Policy) public policies;
    mapping(uint256 => address) public addresses;

    /* Events */
    event PolicyPurchased(address indexed users);

    /* Functions */
    function createProduct(
        uint256 dailyDelayPayout,
        uint128 premiumPercentage,
        uint128 maxDelayDays
    ) public payable {
        require(premiumPercentage > 0);
        require(maxDelayDays > 0 && maxDelayDays < 365);

        InsuranceProduct memory product = InsuranceProduct({
            productId: productId,
            insurer: msg.sender,
            dailyDelayPayout: dailyDelayPayout,
            availCapital: msg.value,
            premiumPercentage: premiumPercentage,
            maxDelayDays: maxDelayDays
        });
        products[productId] = product;
        productId++;
    }

    function createPolicy(
        uint256 productId,
        uint256 trackingNumber,
        uint256 value
    ) public {
        Policy memory policy = Policy({
            policyId: policyId,
            productId: productId,
            packageId: trackingNumber,
            dateCreated: block.timestamp,
            value: value,
            insuree: msg.sender
        });

        policies[policyId] = policy;
        policyId++;
    }

    function getPolicy(uint256 _policyId) public payable {
        Policy memory policy = policies[_policyId];
        InsuranceProduct memory product = products[policy.productId];

        //not sure if this is the formula we are going for
        uint256 premium = policy.value * product.premiumPercentage;
        if (premium <= 0) {
            revert Parcelsure__PremiumNeedsToBeMoreThanZero();
        }
        if (msg.value < premium) {
            revert Parcelsure__SendMoreETHtoEnterRaffle();
        }

        //find a way to do this without arrays 
        users.push(payable(msg.sender));
        addresses[policyId] = msg.sender;

        //do we need this?
        emit PolicyPurchased(msg.sender);
    }


    function reimbursement(_policyId) public payable {

        Policy memory policy = policies[_policyId];
        InsuranceProduct memory product = products[policy.productId];
        uint256 daysDelayedCount = 0;

        //check if the package is delayed through keepers
        if( daysDelayedCount < product.daysDelayedCount && ) {
            uint256 amountPayable = policy.value * premium.dailyDelayPayout;
            address[policy.policyId].transfer(amountPayable);
            policy.availCapital = policy.availCapital - amountPayable;
            daysDelayedCount++
        }
        
    }

    //boilerplate functions for keepers 
    function checkUpKeep(){

    }

    function performUpKeep(){

    }



}
