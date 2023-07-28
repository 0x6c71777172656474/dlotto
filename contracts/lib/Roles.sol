// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Roles Library
 * @dev A library for managing roles in smart contracts
 */
library Roles {
    bytes32 public constant ADMIN =
        bytes32(
            0xc055000000000000000000000000000000000000000000000000000000000000
        );
    bytes32 public constant FABRIC =
        bytes32(
            0xfeb5000000000000000000000000000000000000000000000000000000000000
        );
    bytes32 public constant PLAYER =
        bytes32(
            0xdea10000000000000000000000001c0000000000000000000000000000000000
        );
    bytes32 public constant LOTTERY_CREATOR =
        bytes32(
            0xaa670000000003f0000000000000000000000000000000000000000000000000
        );
}
