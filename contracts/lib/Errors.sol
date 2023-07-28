// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Errors {
    string public constant ZERO_ADDRESS = "0"; // Address should NOT be zero
    string public constant NOT_ENOUGH_SHOP_TOKENS = "1"; // Not enough shop tokens
    string public constant NOT_ENOUGH_FUNDS = "2"; // Not enough funds
    string public constant NOT_OWNER = "3"; // Not a shop owner
    string public constant INCORRECT_AMOUNT = "4"; // Amount should NOT be zero or incorrect
    string public constant OVER_ALLOWANCE = "5"; // Cannot transfer amount greater than allowance
    string public constant REQUEST_NOT_FOUND = "6"; // Request not found
}
