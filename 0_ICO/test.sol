
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract MiContratoICO {
    uint256 public openingTime;
    uint256 public closingTime;

    constructor(uint256 _openingTime, uint256 _closingTime) {
        require(_openingTime >= block.timestamp, "La hora de inicio debe ser en el futuro");
        require(_closingTime > _openingTime, "La hora de cierre debe ser posterior a la hora de inicio");

        openingTime = _openingTime;
        closingTime = _closingTime;
    }

    // Resto del código...
}
