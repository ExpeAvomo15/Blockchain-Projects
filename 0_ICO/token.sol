// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;



//Contrato del Token de la ICO
contract Token {

//-------- Variables & Declaraciones iniciales --------
//Declaraciones Iniciales
//uint256 public decimals = 18;
string public name = "ICO Token";
string public symbol = "TICO";
mapping (address => mapping (address => uint256)) allowance; // Este mapping reguistra los Tokens que un usuario le asigna a otro para gastar/gestionar dentro de la ICO

//Variables esenciales (Para la gestión de los Tokens)
uint256 public totalSupply = 1000000;// 1 Millon de Tokens
mapping (address=>uint256) public balances;
mapping (address=>bool) public whitelist;
address public escrow;//Enviamos los fondos a esta cuenta
uint256 public exchangeRate = 1000; // 1000 TICO = 1 ether;
uint256 minInvestment = 100;
uint256 maxInvestment;
uint256 public cap = 100000; //100000 tokens TICO disponibles para vender

//Variable auxiliar
address public owner;



//------- EVENTOS ----------
//Evento para la transferencia de Tokens a un usuario
event Transfer (
    address indexed _from,
    address indexed  _to,
    uint256 _value
);

event Aproval(
    address indexed _owner,
    address indexed _spender,
    uint256 _amount
);

//Constructor

constructor (){
    
    //Asignamos todos los fondos a la cuenta escrow
    balances[escrow] = totalSupply;

   
}

//Modificador para dar permiso exclusivo al admministradi en las funciones que lo requieran
modifier onlyOwner() {
     require(msg.sender == owner, "Esta funcion solo puede ser ejecutada por el admin");
     _;
}

//------------ Funciones ------------------
//Funciones auxiliares -> RESTRICCIÓN: Solo puede ejecutarlas el Admin

function setExchangeRate (uint256 newExchangeRate) public onlyOwner {
    exchangeRate = newExchangeRate;
}

function setEscrow (address newEscrow) public onlyOwner{
    escrow = newEscrow;
}

function setMinInvest (uint256 newMinInvest) public onlyOwner{
    require(newMinInvest>0, "El minimo no puede ser un valor negativo");
    minInvestment = newMinInvest;
}

function setCap (uint256 newCap) public onlyOwner{
    cap = newCap;
}

function setMaxInvest (uint256 newMaxInvest) public onlyOwner{
   require(newMaxInvest > minInvestment, "Fija un monto superior al minimo");
    require(newMaxInvest <= cap, "El maximo no puede superar el cap");

    maxInvestment = newMaxInvest;

}

//Funciones de Transferencia y Control de los tokens
//Transferencia de tokens de un usuario
function transfer (address _to, uint256 _value) public returns (bool success){
    
    require(balances[escrow] >= _value, "No hay suficientes Tokens");
    balances[escrow] -= _value;
    balances[_to] += _value;
    emit Transfer(escrow, _to, _value);
    return true;

}

//Aprobacion de una cantidad que el admin asigna, para ser gastada/gestionada por un operador
function approve (address _spender, uint256 _amount) public onlyOwner returns (bool success){
    allowance[owner][_spender] = _amount;
    emit  Aproval(owner, _spender, _amount);
    return true;
}

//Transferencia de Tokens especificando el Emisor
function transferFrom (address _from, address _to, uint256 _value) public returns (bool success){
    require(_value <= balances[_from]);
    require(_value <= allowance[_from][owner]);
    balances[_from] -= _value;
    balances[_to] += _value;
    allowance[_from][owner] -= _value;

    return true;
}

}