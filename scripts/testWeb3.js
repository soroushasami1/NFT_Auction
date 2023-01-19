const HDWalletProvider = require('@truffle/hdwallet-provider')
const Web3 = require('web3')

const address = ''
const privateKey = ''

const NftCollection = '0x4F36fD16189Ec698A8891389407D6256Dd227970';
const NftCollectionAbi = require('../build/contracts/NftCollection.json').abi;

const MarketPlace = '0x0CE5A40659E8B3A22ef9B973b7cC0312B0B6Ed27';
const MarketPlaceAbi = require('../build/contracts/MarketPlace.json').abi;

const init = async () => {
    const provider = new HDWalletProvider(privateKey, 'https://data-seed-prebsc-2-s3.binance.org:8545')
    const web3 = new Web3(provider)

    const NftCollection_Contract = new web3.eth.Contract(NftCollectionAbi, NftCollection);
    const MarketPlace_Contract = new web3.eth.Contract(MarketPlaceAbi, MarketPlace);

    //Now we can create new transactions with web3 : 
    //For example :  

    const mintNft = await contract.methods.mintNft("https://ipfs.io/ipfs/QmcvkFEfq2E1UZ16MKG6yyaZyTD7zc2xyrfcftYnjJZF7D").send({from : address})
    console.log(mintNft);

}


init()