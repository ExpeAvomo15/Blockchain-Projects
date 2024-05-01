// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

//Owner: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//User: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

import "./AvStakeToken.sol";
import "./RewardToken.sol";

contract Defi{
    //Declaraciones Inciales
    string public name = "Reward Token Farm";
    address public  owner;
    AvToken public avToken;
    RewardToken public rewardToken;

    //Estructuras de Datos
    address [] public stakers;
    mapping (address=>uint256) public stakingBalance;
    mapping (address=>bool) public hasStaked;
    mapping (address=>bool) public isStaking;

    //Constructor
    constructor(AvToken _avToken, RewardToken _rewardToken){
        avToken = _avToken;
        rewardToken = _rewardToken;
        owner = msg.sender;
    }

    //Satke de Tokens
    function stakeTokens(uint _amount)public{
        //Se requiere una cantidad superior a 0
        require (_amount>0, "La cantidad no puede ser menor a 0");
        //Transferir Tokens AvStakr al Smart Contract principal
        avToken.transferFrom(msg.sender, address(this), _amount);
        //Actualizar el saldo del Staking
        stakingBalance[msg.sender] += _amount;
        //Guardar el usuario o staker
        if(!hasStaked[msg.sender]){
             stakers.push(msg.sender);
        }
       
       //Actualizamos los valores del Staking
       isStaking[msg.sender] = true;
       hasStaked[msg.sender] = true;

    }

    //Devolver los tokens y quitarlos delstaking
    function unstakeTokens() public{
       //Saldo del staking del usuario
        uint balance = stakingBalance[msg.sender];
        //se requiere una cantidad superior a 0
        require(balance>0, "El balance del staking es 0");
        //Transferencia de los tokens al usuario
        avToken.transfer(msg.sender, balance);
        // Se resetea el balance de staking del usuario
        stakingBalance[msg.sender] = 0;
        //Actualizar el estado del staking
        isStaking[msg.sender]=false;

    }

    //Emisión de Tokens de las recmpensas
    function issueTokens () public{
        require(msg.sender==owner, "No eres el owner, no tienes permisos");
        //Emitir tokens a todos los stakers
        for(uint i=0; i<stakers.length; i++){
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];

            if(balance>0){
                rewardToken.transfer(recipient, balance);
            }

        }
    }


}