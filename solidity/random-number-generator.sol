// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./../node_modules/@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "./../node_modules/@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "./../node_modules/@openzeppelin/contracts/utils/Address.sol";

interface IRandomNumberReceiver {
    function receiveRandomNumber(uint256 randomNumber) external;
}

interface IRandomNumberGenerator {
    function requestRandomNumber(IRandomNumberReceiver receiver) external;
}

contract RandomNumberGenerator is
    VRFConsumerBaseV2,
    Ownable,
    IRandomNumberGenerator
{
    uint64 public subscriptionId;
    VRFCoordinatorV2Interface COORDINATOR;

    // retrieve 1 random values in one request here, Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 public numWords = 1;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 public keyHash;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    mapping(uint256 => address) receivers;
    address public lotteryFactory;

    constructor(
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _subscriptionId
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        subscriptionId = _subscriptionId;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        keyHash = _keyHash;
    }

    function setSubscriptionId(uint64 _subscriptionId) external onlyOwner {
        subscriptionId = _subscriptionId;
    }

    function setCallbackGasLimit(uint32 _callbackGasLimit) external onlyOwner {
        callbackGasLimit = _callbackGasLimit;
    }

    function setLotteryFactory(address _lotteryFactory) external onlyOwner {
        lotteryFactory = _lotteryFactory;
    }

    function setRequestConfirmations(uint16 _requestConfirmations)
        external
        onlyOwner
    {
        requestConfirmations = _requestConfirmations;
    }

    // request a random number, once number is generated, `fulfillRandomWords` will be called 
    function requestRandomNumber(IRandomNumberReceiver receiver) external override {
        require(msg.sender == lotteryFactory, "Only LotteryFactory");
        // Will revert if subscription is not set and funded.
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        receivers[requestId] = address(receiver);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        IRandomNumberReceiver(receivers[requestId]).receiveRandomNumber(
            randomWords[0]
        );
    }

    function withdraw() public onlyOwner {
        Address.sendValue(payable(msg.sender), address(this).balance);
    }
}
