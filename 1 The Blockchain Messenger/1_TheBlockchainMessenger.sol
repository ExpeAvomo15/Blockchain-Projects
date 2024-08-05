// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TheBlockchainMessenger{

    uint public changeCounter;
    string public theMessage;
    address public owner;

    constructor (){
        owner = msg.sender;
    }

    function updateTheMessage (string memory _newMessage) public {
        if(owner==msg.sender){
            theMessage = _newMessage;
            changeCounter++;
        }
        
    }
    
}