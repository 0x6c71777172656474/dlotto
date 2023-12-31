// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Roles} from "./lib/Roles.sol";
import "../contracts/lib/Errors.sol";
import "../contracts/lib/Constants.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RandomNumbersGenerator is
    VRFConsumerBaseV2,
    Ownable,
    AccessControl,
    ReentrancyGuard
{
    uint16 requestConfirmations = 3;
    uint64 s_subscriptionId;
    uint256[] public requestIds;
    uint256 lastRequestId;
    VRFCoordinatorV2Interface immutable COORDINATOR;

    struct RequestStatus {
        bool fulfilled;
        bool exist;
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    constructor(
        uint64 subscriptionId,
        address coordinatorAddr
    ) VRFConsumerBaseV2(coordinatorAddr) {
        COORDINATOR = VRFCoordinatorV2Interface(coordinatorAddr);
        s_subscriptionId = subscriptionId;
    }

    // numWords = N;
    // callBackGaslimit = N * 100000;
    //@TODO protect it via role checker or somehow
    function requestRandomWords(
        uint32 numWords
    ) external returns (uint requestId) {
        requestId = COORDINATOR.requestRandomWords(
            Constants.KEY_HASH,
            s_subscriptionId,
            requestConfirmations,
            numWords * 100000,
            numWords
        );

        s_requests[requestId] = RequestStatus({
            fulfilled: false,
            exist: true,
            randomWords: new uint[](0)
        });

        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);

        return requestId;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal virtual override {
        require(s_requests[requestId].exist, Errors.REQUEST_NOT_FOUND);
        s_requests[requestId].fulfilled = true;
        s_requests[requestId].randomWords = randomWords;
        emit RequestFulfilled(requestId, randomWords);
    }

    function getLastRequestId() public view returns (uint256) {
        return lastRequestId;
    }

    function getRequestStatus(
        uint256 requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[requestId].exist, Errors.REQUEST_NOT_FOUND);
        RequestStatus memory request = s_requests[requestId];
        return (request.fulfilled, request.randomWords);
    }
}
