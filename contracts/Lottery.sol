// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Roles} from "./lib/Roles.sol";

contract Lottery is AccessControl, ReentrancyGuard {
    address public owner;
    using Counters for Counters.Counter;
    mapping(uint256 => address) lotteryCreatorByID;
    mapping(uint256 => address[]) lotteryPlayers;
    mapping(uint256 => address[]) lotteryWinners;
    mapping(uint256 => LotteryData) public lotteryInfo;
    mapping(address => uint256) creatorToBalance;

    /**
     * @dev Global counter for lottery id
     */
    Counters.Counter _lotteryIdsCount;

    enum LotteryStatus {
        PLANNED,
        STARTED,
        FINISHED
    }

    struct LotteryData {
        uint256 id;
        address creator;
        LotteryStatus status;
        uint16 prizePositionsCount;
        uint256 prizePool;
        uint256 ticketCount;
        uint256 availableTicketsPerUser;
        bool isTicketTransferable;
        uint256 delayBeforeStart;
    }

    constructor() {
        _setupRole(Roles.ADMIN, _msgSender());
        _setupRole(Roles.FABRIC, address(this));
    }

    function createLottery(
        uint16 prizePositionsCount,
        uint256 ticketCount,
        uint256 availableTicketsPerUser,
        bool isTicketTransferable,
        uint256 delayBeforeStart
    ) external nonReentrant onlyRole(Roles.LOTTERY_CREATOR) {
        _lotteryIdsCount.increment();
        uint256 id = _lotteryIdsCount.current();
        LotteryData memory newLottery = LotteryData(
            id,
            msg.sender,
            LotteryStatus.PLANNED,
            prizePositionsCount,
            creatorToBalance[msg.sender],
            ticketCount,
            availableTicketsPerUser,
            isTicketTransferable,
            block.timestamp + delayBeforeStart
        );

        lotteryCreatorByID[id] = msg.sender;
        lotteryInfo[id] = newLottery;
    }

    function grantLotteryCreatorRole(address _token) external {
        require(
            !hasRole(Roles.LOTTERY_CREATOR, msg.sender),
            "You already has creator role"
        );
        require(
            IERC20(_token).balanceOf(msg.sender) >= 1000,
            "Not enougth funds to become a lottery creator"
        );
        IERC20(_token).transferFrom(msg.sender, address(this), 1000);
        creatorToBalance[msg.sender] = 1000;
        _grantRole(Roles.LOTTERY_CREATOR, msg.sender);
    }

    function grabDonations(address _token) external onlyRole(Roles.ADMIN) {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transferFrom(address(this), msg.sender, balance);
    }

    function getBalance(address _token) external view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }
}
