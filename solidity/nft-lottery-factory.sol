// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./../node_modules/@openzeppelin/contracts/proxy/Clones.sol";
import "./../node_modules/@openzeppelin/contracts/utils/Address.sol";
import "./../node_modules/@openzeppelin/contracts/interfaces/IERC721.sol";
import "./random-number-generator.sol";
import "./models.sol";
import "./../node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

interface INFTLottery {
    function initialize(
        INFTLotteryFactory _factory,
        uint256 _treasuryFee,
        LotteryInfo memory info
    ) external;

    function transferOwnership(address newOwner) external;
}

contract NFTLotteryFactory is
    INFTLotteryFactory,
    Initializable,
    OwnableUpgradeable
{
    mapping(address => bool) members;
    mapping(address => bool) lotteries;
    mapping(address => address[]) userLotteries;

    IRandomNumberGenerator rng;
    address public template;

    address public operator;
    address payable treasury;
    uint256 public treasuryFee;
    uint256 openLotteryReward;

    event LotteryCreated(address indexed creator, address pool);

    modifier onlyMember() {
        require(
            members[msg.sender] ||
                msg.sender == operator ||
                msg.sender == owner(),
            "Only member"
        );
        _;
    }

    modifier onlyOperator() {
        require(
            msg.sender == operator || msg.sender == owner(),
            "Only operator"
        );
        _;
    }

    function initialize(
        address _template,
        address _randomGenerator,
        address _operator,
        address payable _treasury,
        uint256 _openLotteryReward,
        uint256 _treasuryFee
    ) external initializer {
        __Ownable_init();

        treasury = _treasury;
        operator = _operator;
        template = _template;
        rng = IRandomNumberGenerator(_randomGenerator);
        openLotteryReward = _openLotteryReward;
        treasuryFee = _treasuryFee;
    }

    function createNFTLottery(
        address nftAddress,
        uint256 nftId,
        uint256 ticketPrice,
        uint256 ticketCount,
        uint256 fee,
        uint64 startTime,
        uint64 endTime
    ) external onlyMember returns (address) {
        INFTLottery lottery = INFTLottery(Clones.clone(template));
        LotteryInfo memory info;
        info.nftAddress = nftAddress;
        info.nftId = nftId;
        info.ticketPrice = ticketPrice;
        info.ticketCount = ticketCount;
        info.startTime = startTime;
        info.endTime = endTime;
        lottery.initialize(this, fee, info);
        lottery.transferOwnership(msg.sender);
        IERC721(nftAddress).safeTransferFrom(
            msg.sender,
            address(lottery),
            nftId
        );
        lotteries[address(lottery)] = true;
        userLotteries[msg.sender].push(address(lottery));

        emit LotteryCreated(msg.sender, address(lottery));
        return address(lottery);
    }

    function setOperator(address _operator) external onlyOwner {
        operator = _operator;
    }

    function setTemplate(address _template) external onlyOperator {
        template = _template;
    }

    function setTreasuryFee(uint256 f) external onlyOperator {
        require(f < 10000, "Too large");
        treasuryFee = f;
    }

    function setTreasury(address payable _treasury) external onlyOperator {
        treasury = _treasury;
    }

    function getTreasury() external view override returns (address) {
        return treasury;
    }

    function setRandomGenerator(address _randomGenerator)
        external
        onlyOperator
    {
        rng = IRandomNumberGenerator(_randomGenerator);
    }

    function getRandomGenerator()
        external
        view
        override
        returns (IRandomNumberGenerator)
    {
        return rng;
    }

    function setOpenLotteryReward(uint256 reward) external onlyOperator {
        openLotteryReward = reward;
    }

    function getOpenLotteryReward() external view override returns (uint256) {
        return openLotteryReward;
    }

    function addMembers(address[] memory addrs) external onlyOperator {
        for (uint256 i = 0; i < addrs.length; i++) {
            members[addrs[i]] = true;
        }
    }

    function removeMembers(address[] memory addrs) external onlyOperator {
        for (uint256 i = 0; i < addrs.length; i++) {
            delete members[addrs[i]];
        }
    }

    function isMember(address addr) external view returns (bool) {
        return members[addr];
    }

    function getUserLotties(address user)
        external
        view
        returns (address[] memory)
    {
        return userLotteries[user];
    }

    function isLottery(address addr) external view returns (bool) {
        return lotteries[addr];
    }

    function requestRandomNumber() external override {
        require(lotteries[msg.sender], "Only lottery");
        rng.requestRandomNumber(IRandomNumberReceiver(msg.sender));
    }

    function withdraw() public onlyOwner {
        Address.sendValue(payable(msg.sender), address(this).balance);
    }

    receive() external payable {}
}
