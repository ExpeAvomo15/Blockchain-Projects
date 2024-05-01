// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RewardToken {
    //Declaraciones Iniciales
    string public name = "Reward Token";
    string public symbol = "RWT";
    uint256 public totalSupply = 10**24;
    uint8 public decimals = 18;

    //Eventos
    //Evento para la transferencia de tokens de un usuario
    event Transfer (
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    //Evento para la aprobación de un operador
    event Approval (
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );

    //Estructuras de Datos
    mapping(address=>uint256) public balanceOf;
    mapping (address=>mapping(address=>uint256)) public allowance;

    //Constructor
    constructor(){
        balanceOf[msg.sender] = totalSupply;
    }

    //Funciones de control y transferencia de Tokens
    //Transferencia de Tokens de un usuario
    function transfer (address _to, uint256 _value) public returns (bool success){
        require(balanceOf[msg.sender]>=_value, "Fondos insuficientes");
        //actualizamos los balance
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;

    } 

    //Función para asignar permisos s un operador
    function approve (address _spender, uint256 _amount) public returns(bool success){
        allowance[msg.sender][_spender] =_amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    //Funcion de transferencia de Tokens especifcando el emisor
    function transferFrom (address _from, address _to, uint256 _amount) public returns (bool success){
       require (_amount<=balanceOf[_from]);
       require (_amount<=allowance[_from][msg.sender]);

       balanceOf[_from] -= _amount;
       balanceOf[_to] += _amount;
       allowance[_from][msg.sender] -= _amount;

       emit Transfer(_from, _to, _amount);

       return true;



    }








}