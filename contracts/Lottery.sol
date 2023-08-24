// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Roles} from "./lib/Roles.sol";
import "../contracts/interface/IRandomNumberGenerator.sol";

/**
 * @title Lottery Contract
 * @dev A contract that enables the creation and management of lotteries.
 */
contract Lottery is AccessControl, ReentrancyGuard {
    address public owner;
    // Using OpenZeppelin's Counters library to manage lottery IDs
    using Counters for Counters.Counter;
    Counters.Counter _lotteryIdsCount;
    IRandomNumberGenerator immutable NumberGenerator;
    uint256 subscribtionPrice = 1000 ether;
    // Mapping to store the creator of each lottery ID
    mapping(uint256 => address) lotteryCreatorByID;

    // Mapping to store the list of players for each lottery ID
    mapping(uint256 => address[]) lotteryPlayers;

    // Mapping to store the list of winners for each lottery ID
    mapping(uint256 => address[]) lotteryWinners;

    // Struct to store data for each lottery
    struct LotteryData {
        uint256 id;
        address creator;
        LotteryStatus status;
        uint256 prizePool;
        uint256 ticketCount;
        uint256 availableTicketsPerUser;
        bool isTicketTransferable;
        uint256 delayBeforeStart;
        uint256 lotteryPrintRun;
    }

    // Mapping to store lottery data for each lottery ID
    mapping(uint256 => LotteryData) public lotteryInfo;

    // Mapping to store the balance of each creator
    mapping(address => uint256) creatorToBalance;

    // Enumeration to represent the status of a lottery
    enum LotteryStatus {
        PLANNED,
        STARTED,
        FINISHED
    }

    constructor(address _numberGenerator) {
        NumberGenerator = IRandomNumberGenerator(_numberGenerator);
        _grantRole(Roles.ADMIN, _msgSender());
        _grantRole(Roles.FABRIC, address(this));
    }

    /**
     * @dev Function to create a new lottery.
     * @param ticketCount The total number of tickets available for the lottery.
     * @param availableTicketsPerUser The maximum number of tickets a user can purchase.
     * @param isTicketTransferable Flag indicating if tickets are transferable between users.
     * @param delayBeforeStart The delay in seconds before the lottery starts after creation.
     */
    function createLottery(
        uint32 ticketCount,
        uint256 availableTicketsPerUser,
        bool isTicketTransferable,
        uint256 delayBeforeStart
    ) external nonReentrant onlyRole(Roles.LOTTERY_CREATOR) {
        // Increment the lottery ID counter
        _lotteryIdsCount.increment();
        uint256 id = _lotteryIdsCount.current();
        NumberGenerator.requestRandomWords(ticketCount * 5);
        // Create a new LotteryData struct to store the lottery information
        LotteryData memory newLottery = LotteryData(
            id,
            msg.sender,
            LotteryStatus.PLANNED,
            creatorToBalance[msg.sender],
            ticketCount,
            availableTicketsPerUser,
            isTicketTransferable,
            block.timestamp + delayBeforeStart,
            NumberGenerator.getLastRequestId()
        );

        // Store the creator's address for the lottery ID
        lotteryCreatorByID[id] = msg.sender;

        // Store the lottery information for the given ID
        lotteryInfo[id] = newLottery;
    }

    /**
     * @dev Function to grant the LOTTERY_CREATOR role to an address.
     * @param _token The address of the ERC20 token used for granting the role.
     * Requirements:
     * - The caller should not have the LOTTERY_CREATOR role already.
     * - The caller should have a balance of at least 1000 tokens to become a lottery creator.
     */
    function grantLotteryCreatorRole(address _token) external {
        require(
            !hasRole(Roles.LOTTERY_CREATOR, msg.sender),
            "You already have the creator role"
        );
        require(
            IERC20(_token).balanceOf(msg.sender) >= subscribtionPrice,
            "Not enough funds to become a lottery creator"
        );

        // Transfer 1000 tokens from the caller to the contract
        IERC20(_token).transferFrom(
            msg.sender,
            address(this),
            subscribtionPrice
        );

        // Set the balance of the caller to 1000 tokens
        creatorToBalance[msg.sender] = subscribtionPrice;

        // Grant the LOTTERY_CREATOR role to the caller
        _grantRole(Roles.LOTTERY_CREATOR, msg.sender);
    }

    /**
     * @dev Function for the contract owner to grab the contract's ERC20 token donations.
     * @param _token The address of the ERC20 token to grab donations from.
     * Requirements:
     * - The caller must have the ADMIN role.
     */
    function grabDonations(address _token) external onlyRole(Roles.ADMIN) {
        // Get the balance of the ERC20 token held by the contract
        uint256 balance = IERC20(_token).balanceOf(address(this));

        // Transfer the entire balance to the caller (contract owner)
        IERC20(_token).transferFrom(address(this), msg.sender, balance);
    }

    /**
     * @dev Function to get the balance of the specified ERC20 token held by the contract.
     * @param _token The address of the ERC20 token to check the balance of.
     * @return The balance of the specified ERC20 token held by the contract.
     */
    function getBalance(address _token) external view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }
}
