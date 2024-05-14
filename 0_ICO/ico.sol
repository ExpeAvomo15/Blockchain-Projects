// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./token.sol";

//Contrato Principal
contract ICO {

//----- Declaraciones iniciales ------
    string public name = "ICO";
    Token public token;

    //Variables esenciales
    uint256 public openingTime; //Tiempo en segundos
    uint256 public closingTime; //tiempo en segundos
    address public admin; //Administrador de la ICO
    bool public finalized;
    
    //Estructuras de Datos
    address [] public investors; //Array que almacena a los usaurios que han invertido
    mapping (address => uint256) investorBalance;
    mapping (address => bool) public hasInvested;
    mapping (address => bool) public isInvesting;


    constructor (Token _token, uint256 _openingTime, uint256 _closingTime){
    
    token = _token;
    admin = msg.sender;

    require(_openingTime >= block.timestamp,  "La hora/fecha de inicio debe ser en el futuro");
    require(_closingTime > _openingTime,  "La hora/fecha de cierre debe ser posterior a la hora de inicio");

    openingTime = _openingTime;
    closingTime = _closingTime;
    
}

}
