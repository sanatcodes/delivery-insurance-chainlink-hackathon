// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/* ERRORS */
error Parcelsure__SendMoreETH();
error Parcelsure__PremiumNeedsToBeMoreThanZero();

contract Parcelsure is ChainlinkClient, KeeperCompatibleInterface {
    using Chainlink for Chainlink.Request;

    /* ENUMS */
    enum PolicyState {
        ACTIVE,
        INACTIVE
    }

    enum DeliveryStatus {
        TRANSIT,
        FINISHED
    }

    /* STRUCTS */
    struct InsuranceProduct {
        uint256 productId;
        address payable insurer;
        uint256 dailyDelayPayoutPercentage;
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
        PolicyState state;
        uint256 lastReqTimestamp;
    }

    // not sure if we need this
    address payable[] private _users;

    uint256 private _productId = 0;
    uint256 private _policyId = 0;
    InsuranceProduct[] public products;
    Policy[] public policies;

    address private immutable _oracle;
    bytes32 private immutable _jobId;
    uint256 private immutable _fee;
    mapping(bytes32 => uint256) requestToPolicyId;

    uint256 public immutable keeperInterval;
    uint256 public lastTimeStamp;
    uint256 public keeperPolicyIndex = 0;

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

        keeperInterval = 3 minutes;
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
    function fulfillTrackingData(
        bytes32 requestId,
        uint256 deliveryStatus,
        uint256 transitTime,
        uint256 avgTime
    ) public recordChainlinkFulfillment(requestId) {
        emit ReqFulfilled(requestId, deliveryStatus, transitTime, avgTime);

        uint256 policyId = requestToPolicyId[requestId];
        Policy storage pol = policies[policyId];

        uint256 prodId = pol.productId;
        InsuranceProduct storage prod = products[prodId];

        //If delivery is completed close policy
        if (deliveryStatus == 1) {
            pol.state = PolicyState.INACTIVE;
            return;
        }

        if (transitTime > avgTime) {
            uint256 daysDelayed = transitTime - avgTime;
            if (daysDelayed > prod.maxDelayDays) {
                pol.state = PolicyState.INACTIVE;
                return;
            }

            //Send insurance payout
            uint256 payout = (pol.value * prod.dailyDelayPayoutPercentage) / 10000;
            prod.availCapital -= payout;
            pol.insuree.transfer(payout);
        }

    }

    function createProduct(
        uint256 dailyDelayPayoutPercentage,
        uint128 premiumPercentage,
        uint128 maxDelayDays
    ) public payable {
        require(premiumPercentage > 0);
        require(maxDelayDays > 0 && maxDelayDays < 365);

        InsuranceProduct memory product = InsuranceProduct({
            productId: _productId,
            insurer: payable(msg.sender),
            dailyDelayPayoutPercentage: dailyDelayPayoutPercentage,
            availCapital: msg.value,
            premiumPercentage: premiumPercentage,
            maxDelayDays: maxDelayDays
        });
        products.push(product);
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
            insuree: payable(msg.sender),
            state: PolicyState.ACTIVE,
            lastReqTimestamp: 0
        });
        InsuranceProduct memory product = products[policy.productId];

        uint256 premium = (policy.value * product.premiumPercentage) / 10000;
        if (premium <= 0) {
            revert Parcelsure__PremiumNeedsToBeMoreThanZero();
        }
        if (msg.value < premium) {
            revert Parcelsure__SendMoreETH();
        }
        
        policies.push(policy);
        _policyId++;
        
        emit PolicyPurchased(productId, policy.policyId, msg.sender);
    }

    function checkUpkeep(bytes calldata checkData) 
    external view override returns (bool upkeepNeeded, bytes memory performData) {
        bool isIntervalExceeded = (block.timestamp - lastTimeStamp) > keeperInterval;
        upkeepNeeded = isIntervalExceeded;
        performData = checkData;
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        // End iteration cycle
        if ((block.timestamp - lastTimeStamp) > keeperInterval && keeperPolicyIndex == (policies.length)) {
            lastTimeStamp = block.timestamp;
            keeperPolicyIndex = 0;
            return;
        }

        // Go through remaining policies in current policy iteration cycle. Call API on the first active Policy
        // An iteration cycle is when the keeper executes an API call for every active policy in seperate transactions
        // Policy iteration cycle is triggered when keeperInterval is exceeded
        for (uint256 i = (keeperPolicyIndex); i < policies.length; i++) {
            if (i == policies.length - 1) {
                keeperPolicyIndex = policies.length - 1;
            }
            if (policies[i].state == PolicyState.INACTIVE) continue;
            bytes32 reqId = requestTrackingData(policies[i].trackingId);
            requestToPolicyId[reqId] = i;

            keeperPolicyIndex = i+1;
            break;
        }
    }

}