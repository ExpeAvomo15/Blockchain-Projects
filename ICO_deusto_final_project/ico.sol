// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts@4.5.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";

//Admin = msg.sender : 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//Escrow: 0xdD870fA1b7C4700F2BD7f44238821C26f7392148
//Investor1: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 - 200 tokens - Luego los venderá todos
//Investor2: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db - 400 tokens
 


contract Avomo_ICO is ERC20, Ownable{
    //Variables y declaraciones iniciales
    uint256 public tokenSupply = 10**6; // 1 millon de Tokens
    mapping (address => uint256) public balances;
    mapping (address => bool) public whitelist;
    address public admin;
    address public escrow;
    uint256 public constant exangeRate = 10; // 1 ether = 10 AVT
    uint256 public minInvestment = 1 ether; //Fijo la inversion mínima a 1 ether
    uint256 public maxInvestment = 1000 ether;
    uint256 public cap = 1000000 * 10 ** decimals();
    uint256 public openingTime = block.timestamp+10;
    uint256 public closingTime = 2*openingTime;// 1 de julio de 2024
    bool public finalized = false;

    //Eventos
    event BuyTokens(address indexed _investor, uint256 _value);
    event SellTokens (address indexed _investor, uint256 _value);
    event TransferFounds (address indexed _from, address indexed _to, uint256 _value);
    event AddToList (address indexed _investor);
    event RemoveFromList (address indexed _investor);

    //Funciones y variables auxiliares auxiliares

    //Creo un array donde se guardan los inversores autorizados
    address []  public autorizedInvestors;

    function tokenPrice (uint256 _numTokens) public pure returns (uint256) {
         _numTokens =  _numTokens/exangeRate;
         return _numTokens * (1 ether);
         
    }

    function setTokenSupply (uint256 _value) public onlyOwner {
        tokenSupply = _value;
    }

    function getBalnces (address _investor) public view returns (uint256){
        return balances[_investor];
    }


    function setMinInvestment (uint256 _value) public onlyOwner{
        minInvestment = _value *(1 ether);
    }

    function setMaxInvestment (uint256 _value) public onlyOwner{
        require(_value>minInvestment, "La inversion maxima debe ser mayor que la minima");

        maxInvestment = _value *(1 ether);
    }

    function setCap (uint256 _newCap) public onlyOwner {
        require(_newCap <= tokenSupply, "Has superado el limite de Tokens disponibles");
        cap = _newCap;
    }

    function setOpeningTime (uint256 _value) public onlyOwner {
        openingTime = _value;
    }

      function setClosingTime (uint256 _value) public onlyOwner {
        closingTime = _value;
    }

    //Visualizar el balance de Tokens ERC20  de un usuario
    function balanceTokens(address _user) public view returns(uint256){
        return balances[_user];
    }

    //Visualizar el balance de tokens ERC-20 del Smart Contract
    function balanceTokensSC () public view returns (uint256){
        return balanceOf(address(this));
    }


    //Visualizar balance de ethers en el smart contract del smart contract
    function balancesEthersSC () public view returns (uint256) {
        return address(this).balance/10**decimals();
    }

    //Visualizar el balance de ethers de un inversor  
    function balanceEthers (address _investor) public view returns (uint256){
        return _investor.balance/10**decimals();
    }

    //funcion auxiliar para borrar un iversor de la lista
    function deleteInvestorFromAList (address _investor) internal{
        uint arrayLen = autorizedInvestors.length;

        for (uint i=0; i<arrayLen; i++){
            if(autorizedInvestors[i]==_investor){
                //Desplazamos los elementos a la izquierda para cubrir el hueco
                for (uint j=i; j<arrayLen-1; j++){
                    autorizedInvestors[j] = autorizedInvestors[j+1];
                    
                } 
                //Reducimos el tamaño del array/lista
                arrayLen--; 
                break;
            }
            
        }
    }

    //Generacion de nuevos Tokens ERC20
    function createNewTokens (uint256 _amount) public {
        _mint(escrow, _amount);
    }

//funcion para ver la lista de inversores autorizados
function verInversores()public view returns (address [] memory){
    return autorizedInvestors;
}

    //Constructor
    
    constructor(address _escrow) ERC20 ("Avomo's Token","AVT"){
        
        require(openingTime>block.timestamp, "Incremente el tiempo de Inicio");
        require(openingTime<closingTime, "El tiempo de Inicio debe ser menor al tiempo final");

        admin = msg.sender;
        escrow = _escrow;

        _mint(address(this), tokenSupply);
    }

    //Funcion para añadir y eliminar inversores de la whitlist
    function setEscrow (address _escrow) public onlyOwner {
        escrow = _escrow;
    }

    //Funciones de compra y venta de Tokens
    function addToWhitelist (address _investor) public onlyOwner {

        if(!whitelist[_investor]){
            autorizedInvestors.push(_investor);
            whitelist[_investor] = true;
        }

        emit AddToList(_investor);
        
    }

    function removeFroWhitelist (address _investor) public onlyOwner {
        if(whitelist[_investor]){

            deleteInvestorFromAList(_investor);
            whitelist [_investor] = false;

        }
        emit RemoveFromList(_investor);
    }

    // Compra de Tokens ERC-20    
    
    function buyTokens(uint256 _numTokens) public payable {
        // Nos aseguramos de que _numTokens no supere el cap
        require(_numTokens <= cap, "Has superado el maximo de tokens que se pueden comprar");

        // Establecimiento del coste de los tokens
        uint256 coste = tokenPrice(_numTokens);

        // Nos aseguramos de que el coste es al menos el minInvestment y que no supere el maxInvestment
        require(coste >= minInvestment, "No alcanza el minimo de inversion requerido");
        require(coste <= maxInvestment, "Superas el maximo de inversion");

        // Evaluamos que el inversor tenga fondos suficientes
        require(msg.value >= coste, "Compre menos tokens o paga mas ethers");

        // Obtencion del numero de tokens ERC20 disponibles
        uint256 balance = balanceTokensSC();
        require(_numTokens <= balance, "Compre menos tokens o paga mas Ethers");

        // Devolucion del dinero sobrante
        uint256 returnValue = msg.value - coste;
        if (returnValue > 0) {
            // El smart contract devuelve la cantidad (ethers) restante
            payable(msg.sender).transfer(returnValue);
        }

        // Envio de los tokens al inversor
        _transfer(address(this), msg.sender, _numTokens);

        //Llamamos al evento BuyTkens
        emit BuyTokens(msg.sender, _numTokens);

       
    }

  function sellTokens(uint256 _numTokens) public payable  {
        // Calculamos el valor de los tokens a vender
        uint256 etherAmount = tokenPrice(_numTokens);
        
        // Nos aseguramos de que el contrato tiene suficientes fondos en ether
        require(address(this).balance >= etherAmount, "El contrato no tiene suficientes fondos en Ether");

        // Nos aseguramos de que el usuario tiene suficientes tokens para vender
        require(balanceOf(msg.sender) >= _numTokens, "No tienes suficientes tokens para vender");

        // Transferimos los tokens del usuario al contrato
        _transfer(msg.sender, address(this), _numTokens);

        // Pagamos al usuario en ether
        payable(msg.sender).transfer(etherAmount);

        //Llamamos al evento SellTkens
        emit SellTokens(msg.sender, _numTokens);

       
    }

    //Funcion para transfereir todos los fondos(ethers) recaudados a la cuenta escrow
    function transferirFondos () public onlyOwner{
        payable(escrow).transfer(address(this).balance);
        //Emitimos el evento de transferencia de fondos
        emit TransferFounds(address(this), escrow, address(this).balance);
        
    }

    //Verificamos si el contrato ha iniciado
      function isOpen() public {
        if(block.timestamp >= openingTime && block.timestamp <= closingTime){
            finalized=false;
        } 
    }

    // Función que verifica si el contrato ha finalizado
    function hasClosed() public{
        if ( block.timestamp > closingTime){
            finalized = true;
        }
}
    //Funcion para parar la ICO cuando el Owner/Admin lo decida
    function stopICO () public onlyOwner {
        //Si el admin decide parar La ICO hacemos que el contrato trnsfiera
        //Los fondos a la cuenta escrow.
        if(balancesEthersSC()>0){
            transferirFondos();
        } 
        //Hacemos que el tiempo de cierre sea igual al tiempo actual.
        closingTime = block.timestamp;
        //Actualizamos finalized.
        finalized = true;
    }
}
