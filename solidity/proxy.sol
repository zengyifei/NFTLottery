// SPDX-License-Identifier: MIT
pragma solidity  >=0.8.0;

import "./../node_modules/@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract NFTLotteryFactoryProxy is TransparentUpgradeableProxy {
    constructor(address logic,address admin,bytes memory data) TransparentUpgradeableProxy(logic, admin, data) {
    } 
}