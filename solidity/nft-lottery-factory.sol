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
    mapping(address => bool) isLottery;
    address[] public allLottery;

    IRandomNumberGenerator rng;
    address public template;

    address payable treasury;
    uint256 openLotteryReward;
    mapping(address => bool) public isWhitelist;

    event LotteryCreated(address indexed creator, address pool);

    modifier onlyWhitelist() {
        require(
            isWhitelist[msg.sender] || msg.sender == owner(),
            "Only whitelist"
        );
        _;
    }

    function initialize(
        address _template,
        address _randomGenerator,
        address payable _treasury,
        uint256 _openLotteryReward
    ) external initializer {
        __Ownable_init();

        treasury = _treasury;
        template = _template;
        rng = IRandomNumberGenerator(_randomGenerator);
        openLotteryReward = _openLotteryReward;
    }

    function createNFTLottery(
        address nftAddress,
        uint256 nftId,
        uint256 ticketPrice,
        uint256 ticketCount,
        uint256 fee,
        uint64 startTime,
        uint64 endTime
    ) external onlyWhitelist returns (address) {
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
        isLottery[address(lottery)] = true;
        allLottery.push(address(lottery));

        emit LotteryCreated(msg.sender, address(lottery));
        return address(lottery);
    }

    function setTemplate(address _template) external onlyOwner {
        template = _template;
    }

    function setTreasury(address payable _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function getTreasury() external view override returns (address) {
        return treasury;
    }

    function setRandomGenerator(address _randomGenerator) external onlyOwner {
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

    function setOpenLotteryReward(uint256 reward) external onlyOwner {
        openLotteryReward = reward;
    }

    function getOpenLotteryReward() external view override returns (uint256) {
        return openLotteryReward;
    }

    function requestRandomNumber() external override {
        require(isLottery[msg.sender], "Only lottery");
        rng.requestRandomNumber(IRandomNumberReceiver(msg.sender));
    }

    function allLotteryLength() external view returns (uint256) {
        return allLottery.length;
    }

    function addWhitelists(address[] memory addrs) external onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            isWhitelist[addrs[i]] = true;
        }
    }

    function removeWhitelists(address[] memory addrs) external onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            delete isWhitelist[addrs[i]];
        }
    }

    function withdraw() public onlyOwner {
        Address.sendValue(payable(msg.sender), address(this).balance);
    }

    receive() external payable {}
}
