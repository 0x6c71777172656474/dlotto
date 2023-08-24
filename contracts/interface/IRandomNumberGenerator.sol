// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IRandomNumberGenerator {
    function requestRandomWords(
        uint32 numWords
    ) external returns (uint256 requestId);

    function getRequestStatus(
        uint256 requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords);

    function getLastRequestId() external view returns (uint256);
}
