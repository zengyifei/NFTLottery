# NFTLottery

- proxy.sol: `set/upgrade logic contract implementation or delegate call logic contract method`
- random-number-generator.sol: `request chainlink to get a random number`
- nft-lottery-factory.sol: `the implementation of logic contract which can set treasury,lott template and create nft lottery by template`
- nft-lottery.sol: `lott template implementation which contains the logic of buy tickets and claim nft`

#### Contracts deployed on Rinkeby
solidity compiler: 0.8.7+commit.e28d00a7
- [nft-lottery](https://rinkeby.etherscan.io/address/0x88ac1d1945d462fab9cdaae0d780cfb92733de0f): `0x6d6403a2f063eaa07cffefe925dfcae561511424`
- random-number-generator: `0xD978c5Ccfd54d08f77984eC095a8d05c513a19C8`
- nft-lottery-factory: `0x331f7f9004c98f019f42d6122762c152808cd9e7`
- [proxy](https://rinkeby.etherscan.io/address/0x1c7f41fa4b297cac6beedb9a4cf5b6cb4a295974): `0x1c7f41fa4b297cac6beedb9a4cf5b6cb4a295974`

#### Process
1. admin creates lottery by proxy contract
2. user buys tickets from lottery
3. when tickets are sold out, lottery will be opened
4. winner claims the nft in lottery, lottery creator claims the payment
