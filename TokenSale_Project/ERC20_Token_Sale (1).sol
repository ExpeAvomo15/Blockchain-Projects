// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ERC20TokenSale
 * @dev This contract manages the sale of ERC20 tokens in exchange for Ether.
 */
contract ERC20TokenSale is Ownable {
    // The ERC20 token being sold
    IERC20 public token;
    
    // Token price in Wei
    uint256 public tokenPriceInWei = 1 ether;

    /**
     * @dev Constructor sets the token to be sold.
     * @param _token The address of the ERC20 token contract.
     */
    constructor(IERC20 _token) {
        token = _token;  // Set the ERC20 token contract
    }

    /**
     * @dev Function to purchase tokens by sending Ether.
     */
    function purchaseTokens() public payable {
        require(msg.value >= tokenPriceInWei, "Not enough Ether sent");
        
        // Calculate the number of tokens to transfer
        uint256 tokensToTransfer = msg.value / tokenPriceInWei;
        
        // Calculate the remainder to refund
        uint256 remainder = msg.value - (tokensToTransfer * tokenPriceInWei);
        
        // Transfer the tokens to the buyer
        token.transfer(msg.sender, tokensToTransfer * 10 ** token.decimals());
        
        // Refund any excess Ether to the buyer
        payable(msg.sender).transfer(remainder);
    }

    /**
     * @dev Function to withdraw all Ether from the contract.
     */
    function withdrawFunds() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
