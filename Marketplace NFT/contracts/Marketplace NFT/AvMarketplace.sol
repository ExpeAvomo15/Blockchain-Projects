// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

//Impotamos la interfaz de ERC721 para poder interactuar con los nft ya creados
import "@openzeppelin/contracts@4.5.0/token/ERC721/IERC721.sol";
//para  dotar de seguridad al marketplace,importamos la libreria ReentrancyGuard
import "@openzeppelin/contracts@4.5.0/security/ReentrancyGuard.sol";

contract AvMarketplace is ReentrancyGuard {
//------ DECLARACIONES INICIALES -------
    //Variables
    //direecion de la cuenta que emitirá recibirá paaos de la marketplace
    address payable public immutable feeAccount;
    //Porcentaje que se queda la marketplace por cada transacción
    uint public immutable feePercent;

    //Contador de items de la Marketplace
    uint public itemCount;

    //Estructuras de datos
    struct Item{

        uint itemId;
        IERC721 nft;
        uint tokenId;
        uint price;
        address payable seller;
        bool sold;

    }

    //Maping que relaciona un item con su estructura de datos
    mapping (uint => Item) public items;

    //EVENTOS
    event Offered (
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller

    );

    event Bought (
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller,
        address indexed buyer

    );

    //constructor
    constructor (uint _feePercent) {
        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
    }

    //Funcion para crear Items en el Marketplace
    function makeItems (IERC721 _nft, uint _tokenId, uint _price) external {
        require(_price>0);
        itemCount++;
        //Transferimos el Item creado al Marketplace (smart contract)
        _nft.transferFrom(msg.sender, address(this), _tokenId);
        //asociamos al item a su estructura
        items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable (msg.sender),
            false

        );
        //Emitimos la oferta
        emit Offered(
            itemCount, 
            address(_nft), 
            _tokenId, 
            _price, 
            msg.sender
        );
    }

    //Compra de Items (NFT) en el Marketplace.
    function buyItems (uint _itemId)external payable nonReentrant {
        uint _totalPrice = totalPrice(_itemId);
        Item storage item = items[_itemId];
        //requisitos para la compra de Items
        require(_itemId>0 && _itemId<=itemCount);
        require (msg.value >= _totalPrice);
        require (!item.sold);
        
        //Transferimos los fondos al comprador 
        item.seller.transfer(item.price);
        //Transferimos las comisiones al owner del Smart Contract
        item.seller.transfer(item.price);
        //Transfereimos las comisiones al desarrollador
        feeAccount.transfer(_totalPrice - feePercent);

         //Actualizamos parametros
        item.sold = true;

        //transferimos los items al comprador
        item.nft.transferFrom(address(this), msg.sender, _itemId);

     

        //Emitimos el  evento de compra
        emit Bought(
            _itemId, 
            address(item.nft), 
            item.tokenId, 
            item.price, 
            item.seller, 
            msg.sender
        );




    }

    //Funcion auxiliar para calcular el precio de los Tokens
    function totalPrice (uint _itemId) public view returns (uint){
        return ((items[_itemId].price*(100 + feePercent))/100);
    }
}