// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.5.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.5.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";

//The Main Contract
contract myLotery is ERC20, Ownable{
    
    //--- INITIALDECLARATIONS ----
    address public winer;
    mapping (address=>address) public user_contract;
    address public nft;


    //Constructor
    constructor()ERC20("Av Lotery", "AVL"){
        _mint(address(this), 1000);
        nft = address(new myERC721());
    }

//--- Functions to managing Tokens ----
    function tokenPrice(uint256 _numTokens) public pure returns(uint256){
        return _numTokens*(1 ether);
    }

    function balanceTokens (address _account) public view returns (uint256){
        return balanceOf(_account);
    }

    function balanceTokensSC () public view returns (uint256){
        return balanceOf(address(this));
    }

    function balanceEtherSC () public view returns (uint256){
        return address(this).balance/10**18;
    }

    function userInfo (address _user) public view returns(address){
        return user_contract[_user];
    }


// ---- Register new users (using a factory function) -----
    function register() public {
        address ticket = address (new myTicket(msg.sender, address(this),nft));
        user_contract[msg.sender] = ticket;
    }


// ---- Functions for buying & selling ERC20 tokens -----
    function buyTokens (uint256 _numTokens) public payable{
        
        if(user_contract[msg.sender] == address(0)){
            register();
        }

        uint256 cost = tokenPrice(_numTokens);
        require(msg.value>=cost, "Pay more or buy less tokens");
        uint256 returnValue = msg.value - cost;

        uint256 balanceSC = balanceTokensSC();
        require(_numTokens<=balanceSC, "Buy less Tokens");

        //We transer the return VALUE to the user/buyer
        payable(msg.sender).transfer(returnValue);

        //Transfer the Tokens to the user/buyer;
        _transfer(address(this), msg.sender, _numTokens);

    }

    function returnTokens (uint256 _numTokens) public payable{
        require (_numTokens>0, "Return a less 1 Token");
        uint256 userBalance = balanceTokens(msg.sender);
        require (_numTokens<=userBalance, "You haven't enough tokens");

        //Transfer the tokens to the smart contract
        _transfer(msg.sender, address(this), _numTokens);

        //transfer the founds to the user
        //total = tokenPrice(_numTokens);
        payable(msg.sender).transfer(tokenPrice(_numTokens));

    }


// ---- Functions for buy tickets using NFTs ----

    // Auxilaries Variables 
    uint public ticketPrice = 5;
    mapping (address=>uint[]) public person_tickets;
    mapping (uint =>address) public ticketDNA;
    uint public randNonce=0;
    uint [] public boughtTickets;

    function buyTickets(uint _numTickets) public {
        //total price of tickets
        uint total = ticketPrice*_numTickets;

        require (balanceTokens(msg.sender)>=total, "Buy less tokens");
        //Transfer tokens from the user to the Smart Contract
        _transfer(msg.sender, address(this), total);

        for(uint i=0; i<_numTickets; i++){
            uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce)))%10000;
            randNonce++;
            //storage tickets data linked to the user
            person_tickets[msg.sender].push(random);
            //add ticket to bought tickets array
            boughtTickets.push(random);
            //storage tikets data
            ticketDNA[random] = msg.sender;
            //Creating a new NFT for the new ticket
            myTicket(user_contract[msg.sender]).mintTickets(msg.sender,random);

        }
    }

    //View user's tickets
    function userTickets(address _owner) public view returns(uint [] memory){
       return person_tickets[_owner];
    }

// ---- Getting the winer of the Lotery ---

    function getWiner () public onlyOwner{
        //array length
        uint arrayLen = boughtTickets.length;
        //Set random for choising the winner aleatory
        uint random = uint(uint(keccak256(abi.encodePacked(block.timestamp)))%arrayLen);
        
        uint choise = boughtTickets[random];
        winer = ticketDNA[choise];

        //Transfering founds to the winer
        payable(winer).transfer(address(this).balance*90/100);

        //Transfer Bonus to the Developer/Owner of the Smart Contract
        payable (owner()).transfer(address(this).balance*10/100);
    }

    }

contract myERC721 is ERC721{

    address lotery;
    //constructor
    constructor()ERC721("Av Lotery", "AVL"){
        lotery = msg.sender;
    }

    function mintNFTs (address _owner, uint _tokenId) public {
        require (msg.sender==myLotery(lotery).userInfo(_owner), "You haven't Permissions");
        _safeMint(_owner, _tokenId);
    }
}


contract myTicket{
    struct Owner{
        address myOwner;
        address faherContract;
        address nftContract;
        address userContract;
    }

    Owner public theOwner;

    constructor(address _myOwner, address _fatherContract, address _nftContract){
        theOwner = Owner(_myOwner, _fatherContract, _nftContract, address(this));
    }

    function mintTickets(address _owner, uint _ticketId) public{
        require(msg.sender==theOwner.faherContract, "You haven't permissions");
        myERC721(theOwner.nftContract).mintNFTs(_owner, _ticketId);

    }

}
