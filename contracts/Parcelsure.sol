// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

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
        bytes32 trackingId;
        uint256 dateCreated;
        uint256 value;
        address payable insuree;
    }

    // not sure if we need this
    address payable[] private _users;

    uint256 private _productId = 0;
    uint256 private _policyId = 0;
    mapping(uint256 => InsuranceProduct) public products;
    mapping(uint256 => Policy) public policies;
    mapping(uint256 => address) public addresses;

    address private immutable _oracle;
    bytes32 private immutable _jobId;
    uint256 private immutable _fee;
    uint public immutable keeperInterval;
    uint public lastTimeStamp;

    /* Events */
    event PolicyPurchased(
        uint256 indexed productId,
        uint256 indexed policyId,
        address indexed insuree
    );

    event ReqFulfilled(
        bytes32 requestId,
        uint256 deliveryStatus,
        uint256 transitTime,
        uint256 avgTime
    );
    /* Functions */
    constructor() {
        // TODO: make these value constructor arguments
        // Node oracle address
        _oracle = 0x3ad58Cd3209e843D876Cf2f318E1F402BE267359;
        _jobId = "62026cd6254542dbb769a1467dea4452";
        _fee = 0;
        setChainlinkToken(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);

        keeperInterval = 24 hours;
        lastTimeStamp = block.timestamp;
    }

    // send api request to oracle. Public for testing purposes only 
    function requestTrackingData(bytes32 trackingId)
    public
    returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(_jobId, address(this), this.fulfillTrackingData.selector);
        request.add("trackingId", string(abi.encodePacked(trackingId)));
        requestId = sendChainlinkRequestTo(_oracle, request, _fee);
    }

    // Function called by oracle with request response
    function fulfillTrackingData(bytes32 requestId, uint256 deliveryStatus, uint256 transitTime, uint256 avgTime)
    public
    recordChainlinkFulfillment(requestId) {
        emit ReqFulfilled(requestId, deliveryStatus, transitTime, avgTime);
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
        bytes32 trackingId,
        uint256 value
    ) public payable {
        Policy memory policy = Policy({
            policyId: _policyId,
            productId: productId,
            trackingId: trackingId,
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