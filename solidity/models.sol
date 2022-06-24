// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "./random-number-generator.sol";

enum Status {
    NotOpened,
    Openable,
    Opening,
    Claimable,
    End
}

struct LotteryInfo {
    Status status;
    address nftAddress;
    uint256 nftId;
    uint256 ticketPrice;
    uint256 ticketCount;
    uint64 startTime;
    uint64 endTime;
    uint256 soldCount;
    uint256 giveCount;
    uint256 luckyTicketIdx;
}

interface INFTLotteryFactory {
    function requestRandomNumber() external;

    function getRandomGenerator()
        external
        view
        returns (IRandomNumberGenerator);

    function getTreasury() external view returns (address);

    function getOpenLotteryReward() external view returns (uint256);
}
