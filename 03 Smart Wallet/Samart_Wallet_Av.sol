// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// The Consumer contract is a simple contract that can hold and track its own Ether balance.
contract Consumer {
    
    // Function to check the balance of the contract
    function balanceSC () public view returns (uint) {
        return address(this).balance;
    }

    // Function to deposit Ether into the contract
    function deposit() public payable {}
}

// The SmartWallet contract allows an owner to manage funds, set allowances for others, and transfer Ether.
contract SmartWallet {

    // Address of the contract owner
    address payable public owner;

    // Mapping to store allowances for specific addresses
    mapping (address => uint) public allowance;

    // Mapping to check if an address is allowed to spend from the wallet
    mapping (address => bool) public isAllowed;

    // Mapping to track guardian addresses; guardians can propose a new owner
    mapping (address => bool) public guardian;

    // Address of the proposed new owner
    address payable nextOwner;

    // Counter for guardian confirmations when resetting the owner
    uint guardiansResetCount;

    // Constant defining how many guardian confirmations are needed to change the owner
    uint public constant confirmationsGuardiansResetCount = 3;

    // Constructor sets the initial owner to the contract deployer
    constructor() {
        owner = payable(msg.sender);
    }

    // Function to propose and confirm a new owner by the guardians
    function setNewOwner(address payable newOwner) public {
        require(guardian[msg.sender], "You are not a guardian");

        // If the proposed new owner is different, reset the guardian confirmation count
        if (nextOwner != newOwner) {
            nextOwner = newOwner;
            guardiansResetCount = 0;
        }

        guardiansResetCount++;

        // If enough guardians have confirmed, change the owner
        if (guardiansResetCount >= confirmationsGuardiansResetCount) {
            owner = nextOwner;
            nextOwner = payable(address(0)); // Reset the next owner to address(0)
        }
    }

    // Function to set an allowance for a specific address
    function setAllowance(address _spender, uint _amount) public {
        require(msg.sender == owner, "You are not the owner");
        allowance[_spender] = _amount;
        isAllowed[_spender] = true;
    }

    // Function to revoke an address's ability to spend from the wallet
    function denySending(address _for) public {
        require(msg.sender == owner, "You are not the owner");
        isAllowed[_for] = false;
    }

    // Function to transfer Ether from the wallet to another address, with an optional payload
    function transfer(address payable _to, uint _amount, bytes memory payload) public returns (bytes memory) {
        require(address(this).balance >= _amount, "Insufficient funds");

        // If the sender is not the owner, check if they are allowed and within their allowance
        if (msg.sender != owner) {
            require(isAllowed[msg.sender], "You are not allowed");
            require(allowance[msg.sender] >= _amount, "Insufficient allowance");

            allowance[msg.sender] -= _amount;
        }

        // Perform the transfer with a call, passing the payload if any
        (bool success, bytes memory returnData) = _to.call{value: _amount}(payload);
        require(success, "Transfer failed");

        return returnData;
    }

    // Fallback function to receive Ether into the wallet
    receive() external payable {}

}
