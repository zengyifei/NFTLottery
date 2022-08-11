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
| NFTLotteryFactory | [0xad8de40c50db52b60423b7d7e3306763ec5dc2eb](https://rinkeby.etherscan.io/address/0xad8de40c50db52b60423b7d7e3306763ec5dc2eb) |
| NFTLotteryFactoryProxy | [0xf8eecd58530be7611e7b2df1d3e17b825644e8fd](https://rinkeby.etherscan.io/address/0xf8eecd58530be7611e7b2df1d3e17b825644e8fd) |


### MainProcessCall
1. member in whitelist calls `factory.createNFTLottery` to create new lottery
2. user calls `lottery.buyTickets` until tickets are sold out
3. `lottery.openLottery` is called and it will call `factory.requestRandomNumber`.The factory will confirm and call `randomNumberGeneraor.requestRandomNumber(receiverAddr)` and set `receiverAddr = lottery`. Once number is generated, `lottery.receiveRandomNumber` will be called and update lottery status.
