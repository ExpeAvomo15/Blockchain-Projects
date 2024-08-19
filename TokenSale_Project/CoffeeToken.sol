// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title CoffeeToken
 * @dev This contract implements an ERC20 token called "CoffeeToken" with minting capabilities controlled by an access role.
 */
contract CoffeeToken is ERC20, AccessControl {
    // Define a role identifier for the minter role
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Event to log coffee purchases
    event CoffeePurchased(address indexed receiver, address indexed buyer);

    /**
     * @dev Constructor that gives the deployer the default admin and minter roles.
     */
    constructor() ERC20("CoffeeToken", "CFE") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);  // Assign the deployer as the admin
        _grantRole(MINTER_ROLE, msg.sender);        // Assign the deployer as the minter
    }

    /**
     * @dev Function to mint new tokens.
     * @param to The address to which minted tokens will be sent.
     * @param amount The number of tokens to mint.
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /**
     * @dev Function to purchase a coffee by burning one CoffeeToken.
     */
    function buyOneCoffee() public {
        _burn(_msgSender(), 1); // Burn 1 token from the sender's balance
        emit CoffeePurchased(_msgSender(), _msgSender()); // Emit an event for the purchase
    }

    /**
     * @dev Function to purchase a coffee using another account's tokens.
     * @param account The account from which to spend the allowance.
     */
    function buyOneCoffeeFrom(address account) public {
        _spendAllowance(account, _msgSender(), 1); // Use the spender's allowance
        _burn(account, 1); // Burn 1 token from the account's balance
        emit CoffeePurchased(_msgSender(), account); // Emit an event for the purchase
    }
}
