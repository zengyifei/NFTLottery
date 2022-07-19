// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./../node_modules/@openzeppelin/contracts/interfaces/IERC721.sol";
import "./../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./../node_modules/@openzeppelin/contracts/utils/Address.sol";
import "./../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./../node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./../node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./random-number-generator.sol";
import "./models.sol";

contract NFTLottery is
    Initializable,
    OwnableUpgradeable,
    IRandomNumberReceiver,
    ReentrancyGuard,
    IERC721Receiver
{
    using SafeMath for uint256;
    mapping(address => uint256[][]) userTicketIdxs; // [ [ticketStartIdx, ticketEndIdx], ... ]

    LotteryInfo public lottery;
    INFTLotteryFactory public factory;
    uint256 public fee; // range [0, 100]
    uint256 public randomNumber;
    address[] users;
    bool public winnerClaimed;
    bool public ownerClaimed;

    event LotteryStatusChanged(Status newStatus);
    event BuyTickets(
        address buyer,
        uint256 ticketStartIdx,
        uint256 tickectEndIdx
    );
    event NftClaimed(address winner);
    event PaymentClaimed(address creator);

    function initialize(
        INFTLotteryFactory _factory,
        uint256 _fee,
        LotteryInfo memory _lottery
    ) external initializer {
        require(_lottery.ticketCount > 0, "Invalid ticket count");
        require(
            _lottery.endTime == 0 ||
                (_lottery.endTime > _lottery.startTime &&
                    _lottery.endTime > block.timestamp),
            "Invalid time"
        );
        require(
            _lottery.ticketPrice >= 0.001 ether,
            "TicketPrice at least 0.001"
        );
        __Ownable_init();

        factory = _factory;
        fee = _fee;
        lottery = _lottery;
    }

    function buyTickets(uint256 count) external payable {
        require(lottery.status == Status.NotOpened, "Only not opened");
        require(block.timestamp > lottery.startTime, "Not start");
        require(
            lottery.endTime == 0 || block.timestamp < lottery.endTime,
            "Ended"
        );
        require(count > 0, "Invalid count");
        require(
            lottery.soldCount + count < lottery.ticketCount + 1,
            "Not enough tickets"
        );
        require(msg.value >= lottery.ticketPrice * count, "Not enough value");
        require(
            IERC721(lottery.nftAddress).ownerOf(lottery.nftId) == address(this),
            "Prize not exist"
        );

        uint256 give = count / 10;
        uint256 ticketStartIdx = lottery.soldCount + lottery.giveCount;
        uint256 ticketEndIdx = ticketStartIdx + count + give - 1;
        if (userTicketIdxs[msg.sender].length == 0) {
            users.push(msg.sender);
        }
        userTicketIdxs[msg.sender].push([ticketStartIdx, ticketEndIdx]);
        emit BuyTickets(msg.sender, ticketStartIdx, ticketEndIdx);

        lottery.soldCount += count;
        lottery.giveCount += give;

        if (lottery.soldCount == lottery.ticketCount) {
            setLotteryStatus(Status.Openable);
        }
    }

    function openLottery() external nonReentrant {
        require(lottery.status == Status.Openable, "Not openable");
        factory.requestRandomNumber();
        Address.sendValue(payable(msg.sender), factory.getOpenLotteryReward());
        setLotteryStatus(Status.Opening);
    }

    function claimNFT(uint256 idx) external {
        require(
            lottery.status == Status.Claimable && !winnerClaimed,
            "Not claimable"
        );
        require(userTicketIdxs[msg.sender].length > idx, "Only valid idx");

        uint256[][] memory ticketIdxs = userTicketIdxs[msg.sender];
        uint256 ticketStartIdx = ticketIdxs[idx][0];
        uint256 ticketEndIdx = ticketIdxs[idx][1];
        require(
            lottery.luckyTicketIdx >= ticketStartIdx &&
                lottery.luckyTicketIdx <= ticketEndIdx,
            "Not the winner"
        );

        winnerClaimed = true;
        IERC721(lottery.nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            lottery.nftId
        );
        emit NftClaimed(msg.sender);
        if (winnerClaimed && ownerClaimed) {
            setLotteryStatus(Status.End);
        }
    }

    function claimPayment() external {
        require(
            lottery.status == Status.Claimable && !ownerClaimed,
            "Not claimable"
        );
        ownerClaimed = true;
        uint256 balance = address(this).balance;
        uint256 feeCost = (lottery.ticketCount * lottery.ticketPrice * fee) /
            (100 + fee);
        Address.sendValue(payable(factory.getTreasury()), feeCost);
        Address.sendValue(payable(owner()), balance - feeCost);
        emit PaymentClaimed(owner());
        if (winnerClaimed && ownerClaimed) {
            setLotteryStatus(Status.End);
        }
    }

    function receiveRandomNumber(uint256 _randomNumber) external override {
        require(lottery.status == Status.Opening, "Not opening");
        require(
            msg.sender == address(factory.getRandomGenerator()),
            "Only RandomGenertor"
        );
        randomNumber = _randomNumber;
        lottery.luckyTicketIdx =
            randomNumber %
            (lottery.soldCount + lottery.giveCount);
        setLotteryStatus(Status.Claimable);
    }

    function setLotteryStatus(Status newStatus) private {
        lottery.status = newStatus;
        emit LotteryStatusChanged(newStatus);
    }

    function getUserTicketIdxs(address user)
        public
        view
        returns (uint256[][] memory)
    {
        return userTicketIdxs[user];
    }

    function getUsers() public view returns (address[] memory) {
        return users;
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
