// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SmartMoney {
    uint256 public balanaceReceived;

    function deposit() public payable{
        balanaceReceived += msg.value;
    }

    function getContractBlanace () public view returns (uint256){
        return address(this).balance;
    }

    function withdrawAll () public {
       address payable to = payable (msg.sender);
       to.transfer(getContractBlanace());

    }
    function withdrawAdress (address payable _to) public {
        _to.transfer(getContractBlanace());
    }
}