// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20{
    constructor(string memory name, string memory ticker, uint initialMint) ERC20("RandomAnimalToken", "BBC") {
        _mint(msg.sender, initialMint);
    }
}