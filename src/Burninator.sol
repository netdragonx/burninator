// SPDX-License-Identifier: MIT
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
    
    ascii art sauce: https://github.com/asiansteev/trogdor

    author: 🐉
*/

contract Burninator {
    mapping(address => mapping(uint256 => uint256)) public offers;
    mapping(address => mapping(uint256 => mapping(address => uint256))) public donations;

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    error ContractsNotAllowed();
    error InitialDonationRequired();
    error OfferAlreadyExists();
    error AlreadyBurned();
    error DonationRequired();
    error OfferDoesNotExist();
    error NoDonationToWithdraw();
    error TransferFailed();
    error NotTokenOwner();
    error NoOfferToAccept();

    event OfferCreated(address indexed tokenAddress, uint256 indexed tokenId, uint256 amount);
    event OfferAccepted(address indexed tokenAddress, uint256 indexed tokenId, address indexed acceptor);
    event DonationMade(address indexed tokenAddress, uint256 indexed tokenId, address indexed donor, uint256 amount);
    event DonationWithdrawn(
        address indexed tokenAddress,
        uint256 indexed tokenId,
        address indexed donor,
        uint256 amount
    );

    function createOffer(address tokenAddress, uint256 tokenId) public payable {
        if (msg.value == 0) revert InitialDonationRequired();
        if (offers[tokenAddress][tokenId] != 0) revert OfferAlreadyExists();
        if (IERC721(tokenAddress).ownerOf(tokenId) == BURN_ADDRESS) revert AlreadyBurned();

        offers[tokenAddress][tokenId] = msg.value;
        donations[tokenAddress][tokenId][msg.sender] = msg.value;

        emit OfferCreated(tokenAddress, tokenId, msg.value);
    }

    function donate(address tokenAddress, uint256 tokenId) public payable {
        if (msg.value == 0) revert DonationRequired();
        if (offers[tokenAddress][tokenId] == 0) revert OfferDoesNotExist();

        offers[tokenAddress][tokenId] += msg.value;
        donations[tokenAddress][tokenId][msg.sender] += msg.value;

        emit DonationMade(tokenAddress, tokenId, msg.sender, msg.value);
    }

    function withdrawDonation(address tokenAddress, uint256 tokenId) public {
        if (donations[tokenAddress][tokenId][msg.sender] == 0) revert NoDonationToWithdraw();

        uint256 donation = donations[tokenAddress][tokenId][msg.sender];
        donations[tokenAddress][tokenId][msg.sender] = 0;
        offers[tokenAddress][tokenId] -= donation;

        (bool success, ) = payable(msg.sender).call{value: donation}("");

        if (!success) revert TransferFailed();

        emit DonationWithdrawn(tokenAddress, tokenId, msg.sender, donation);
    }

    function acceptOffer(address tokenAddress, uint256 tokenId) public {
        if (IERC721(tokenAddress).ownerOf(tokenId) != msg.sender) revert NotTokenOwner();
        if (offers[tokenAddress][tokenId] == 0) revert NoOfferToAccept();

        uint256 amount = offers[tokenAddress][tokenId];
        offers[tokenAddress][tokenId] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) revert TransferFailed();

        IERC721(tokenAddress).transferFrom(msg.sender, BURN_ADDRESS, tokenId);

        emit OfferAccepted(tokenAddress, tokenId, msg.sender);
    }
}
