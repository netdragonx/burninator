pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/*
                                                 :::
                                             :: :::.
                       \/,                    .:::::
           \),          \`-._                 :::888
           /\            \   `-.             ::88888
          /  \            | .(                ::88
         /,.  \           ; ( `              .:8888
            ), \         / ;``               :::888
           /_   \     __/_(_                  :88
             `. ,`..-'      `-._    \  /      :8
               )__ `.           `._ .\/.
              /   `. `             `-._______m         _,
  ,-=====-.-;'                 ,  ___________/ _,-_,'"`/__,-.
 C   =--   ;                   `.`._    V V V       -=-'"#==-._
:,  \     ,|      UuUu _,......__   `-.__Ʌ_Ʌ_ -. ._ ,--._ ",`` `-
||  |`---' :    uUuUu,'          `'--...____/   `" `".   `
|`  :       \   UuUu:
:  /         \   UuUu`-._
 \(_          `._  uUuUu `-.
 (_3             `._  uUu   `._
                    ``-._      `.
                         `-._    `.
                             `.    \
                               )   ;
                              /   /
               `.        |\ ,'   /
                 ",_Ʌ_/\-| `   ,'
                   `--..,_|_,-'\
                          |     \
                          |      \__
                          |__

    BURNINATING THE COUNTRYSIDE
    BURNINATING THE PEASANTS
    
    ascii art sauce: https://github.com/asiansteev/trogdor
*/

contract Burninator {
    mapping(address => mapping(uint256 => uint256)) public offers;
    mapping(address => mapping(uint256 => mapping(address => uint256))) public donations;

    event OfferCreated(address indexed tokenAddress, uint256 indexed tokenId, uint256 amount);
    event DonationMade(address indexed tokenAddress, uint256 indexed tokenId, address indexed donor, uint256 amount);
    event DonationWithdrawn(address indexed tokenAddress, uint256 indexed tokenId, address indexed donor, uint256 amount);
    event OfferAccepted(address indexed tokenAddress, uint256 indexed tokenId, address indexed acceptor);

    modifier isNotContract() {
        require(msg.sender == tx.origin, "Contracts not allowed");
        _;
    }

    function createOffer(address tokenAddress, uint256 tokenId) public payable isNotContract {
        require(msg.value > 0, "Initial donation required");
        require(offers[tokenAddress][tokenId] == 0, "Offer already exists");

        offers[tokenAddress][tokenId] = msg.value;
        donations[tokenAddress][tokenId][msg.sender] = msg.value;

        emit OfferCreated(tokenAddress, tokenId, msg.value);
    }

    function donate(address tokenAddress, uint256 tokenId) public payable isNotContract {
        require(msg.value > 0, "Donation required");
        require(offers[tokenAddress][tokenId] != 0, "Offer doesn't exist");

        offers[tokenAddress][tokenId] += msg.value;
        donations[tokenAddress][tokenId][msg.sender] += msg.value;

        emit DonationMade(tokenAddress, tokenId, msg.sender, msg.value);
    }

    function withdrawDonation(address tokenAddress, uint256 tokenId) public isNotContract {
        require(donations[tokenAddress][tokenId][msg.sender] > 0, "No donation to withdraw");

        uint256 donation = donations[tokenAddress][tokenId][msg.sender];
        donations[tokenAddress][tokenId][msg.sender] = 0;
        offers[tokenAddress][tokenId] -= donation;

        (bool success, ) = payable(msg.sender).call{value: donation}("");
        require(success, "Transfer failed");

        emit DonationWithdrawn(tokenAddress, tokenId, msg.sender, donation);
    }

    function acceptOffer(address tokenAddress, uint256 tokenId) public isNotContract {
        require(IERC721(tokenAddress).ownerOf(tokenId) == msg.sender, "Not token owner");

        uint256 amount = offers[tokenAddress][tokenId];
        offers[tokenAddress][tokenId] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        IERC721(tokenAddress).transferFrom(msg.sender, address(0x000000000000000000000000000000000000dEaD), tokenId);

        emit OfferAccepted(tokenAddress, tokenId, msg.sender);
    }
}

