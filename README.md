# NFTLottery

1. admin creates lottery by proxy contract
2. user buys tickets from lottery
3. when tickets are sold out, lottery will be opened
4. winner claims the nft in lottery, lottery creator claims the payment

### files
| file  |  |
| - | - |
|proxy.sol|set/upgrade logic contract implementation or delegate call logic contract method|
|nft-lottery-factory.sol|request chainlink to get a random number|
|nft-lottery-factory.sol|the template of logic contract for proxy which contains the logic of createLottery |
|nft-lottery.sol|the template of lottery which contains the logic of buy tickets and claim nft|

#### Contracts deployed on Rinkeby
| name  | contract |
| - | - |
| [NFTLottery](https://rinkeby.etherscan.io/address/0x88ac1d1945d462fab9cdaae0d780cfb92733de0f) | [0x6d6403a2f063eaa07cffefe925dfcae561511424](https://rinkeby.etherscan.io/address/0x6d6403a2f063eaa07cffefe925dfcae561511424)|
| RandomNumberGenerator | [0xD978c5Ccfd54d08f77984eC095a8d05c513a19C8](https://rinkeby.etherscan.io/address/0xD978c5Ccfd54d08f77984eC095a8d05c513a19C8) |
| NFTLotteryFactory | [0x331f7f9004c98f019f42d6122762c152808cd9e7](https://rinkeby.etherscan.io/address/0x331f7f9004c98f019f42d6122762c152808cd9e7) |
| NFTLotteryFactoryProxy | [0x1c7f41fa4b297cac6beedb9a4cf5b6cb4a295974](https://rinkeby.etherscan.io/address/0x1c7f41fa4b297cac6beedb9a4cf5b6cb4a295974) |


