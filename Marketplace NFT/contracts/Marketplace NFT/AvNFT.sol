// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

//importamos la ERC721URIStorage para poder almacenar extraer las imágenes en IPFS 

import "@openzeppelin/contracts@4.5.0/token/ERC721/extensions/ERC721URIStorage.sol";

contract MarketPlace_NFT is ERC721URIStorage {

    //Declaramos una variable que lleve la cuenta de los tokens creados
    uint public tokenCount;

    //Cnstructor del Smart Contract
    constructor() ERC721('Av DApp MarketPlace', 'AVM'){}
    
    //Funcion para minterar tokens NFT a un operador/usuario
    function mint(string memory _tokenURI) external returns (uint){
        tokenCount++;
        _safeMint(msg.sender, tokenCount);
        _setTokenURI(tokenCount, _tokenURI);

        return tokenCount;
    }

}
