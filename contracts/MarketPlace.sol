//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MarketPlace is ReentrancyGuard {
    
    using Counters for Counters.Counter;
    Counters.Counter public auctionsCount;

    struct EachAuction {
        address nftContract;
        address nftOwner;
        address highestBidAddress;
        uint256 tokenId;
        uint256 createdAt;
        uint256 endTime;
        uint256 highestBid;
        bool isCancel;
    }

    uint256 internal listingPrice;
    mapping(uint256 => EachAuction) public auctions;

    event AuctionCreated(
        address nftContract,
        address nftOwner,
        address highestBidAddress,
        uint256 tokenId,
        uint256 createdAt,
        uint256 endTime,
        uint256 highestBid,
        bool isCancel
    );

    constructor() {
        listingPrice = 0.0045 ether;
    }

    function addAuction(
        address _nftContract,
        uint256 _tokenId,
        uint256 _startingBid,
        uint256 _endTime
    ) external payable {
        require(_startingBid > 0, "Starting bid must be at least one wei!");

        require(
            msg.value == listingPrice,
            "Price must be equal to listing price!"
        );

        require(_endTime > 0, "Duration can not be zero!");

        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

        auctionsCount.increment();
        uint256 currentId = auctionsCount.current();
        uint256 endTime = block.timestamp + _endTime;

        EachAuction memory newAuction = EachAuction(
            _nftContract,
            msg.sender,
            msg.sender,
            _tokenId,
            block.timestamp,
            endTime,
            _startingBid,
            false
        );
        auctions[currentId] = newAuction;

        emit AuctionCreated(
            _nftContract,
            msg.sender,
            msg.sender,
            _tokenId,
            block.timestamp,
            endTime,
            _startingBid,
            false
        );
    } 
    

    function placeBid(uint256 _auctionId , uint256 _newBid) external payable nonReentrant {
        
        EachAuction storage theAuction = auctions[_auctionId];
        bool isCancel = theAuction.isCancel;
        require(isCancel == false , "This auction has canceld");
        address auctionOwner = theAuction.nftOwner;
        address highestBidAddress = theAuction.highestBidAddress;
        uint256 highestBid = theAuction.highestBid;

        require(_newBid > highestBid , "Your bid must be more than the highest bid price");
        require(msg.sender != auctionOwner , "You are the owner of this auction");

        if (auctionOwner != highestBidAddress) {
            (bool success, ) = payable(highestBidAddress).call{value: highestBid}("");
            require(success == true, "Transfered failed");
        }

        (bool success1, ) = payable(address(this)).call{value: _newBid}("");
        require(success1 == true, "Transfered failed2");

        theAuction.highestBidAddress = msg.sender;
        theAuction.highestBid = _newBid;

    }


    function endAuction(uint256 _auctionId) external nonReentrant{
        EachAuction memory theAuction = auctions[_auctionId];
        
        uint256 endTime = theAuction.endTime;
        require(block.timestamp > endTime , "Auction has not finished yet");
        
    
        uint256 highestBid = theAuction.highestBid;
        uint256 tokenId = theAuction.tokenId;
        address highestBidAddress = theAuction.highestBidAddress;
        address auctionOwner = theAuction.nftOwner;
        address nftContract = theAuction.nftContract;
        
        IERC721(nftContract).transferFrom(address(this), highestBidAddress, tokenId);
        
        (bool success1, ) = payable(auctionOwner).call{value: highestBid}("");
        require(success1 == true, "Transfered failed");
    }

    function cancelAuction(uint256 _auctionId) external {
        
        EachAuction storage theAuction = auctions[_auctionId];  
        uint256 endTime = theAuction.endTime;
        require(block.timestamp < endTime , "Auction has finished");
        
        address auctionOwner = theAuction.nftOwner;
        require(msg.sender == auctionOwner , "You are not the auction's owner");

        address highestBidAddress = theAuction.highestBidAddress;
        uint256 highestBid = theAuction.highestBid;
        
        if (auctionOwner != highestBidAddress) {
            (bool success, ) = payable(highestBidAddress).call{value: highestBid}("");
            require(success == true, "Transfered failed");
        }

        theAuction.isCancel = true;
    }

    function contractBalance() public view returns(uint256) {
        return address(this).balance;
    }

    // solhint-disable-next-line
    receive() external payable {}
}