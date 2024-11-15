// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address public factory;
    uint256 public MAX_SUPPLY;

    constructor(
        string memory name,
        string memory ticker,
        uint256 initialMint,
        uint256 maxSupply,
        address factoryAddress
    ) ERC20(name, ticker) {
        factory = factoryAddress;
        MAX_SUPPLY = maxSupply;
        _mint(factory, initialMint);
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == factory, "Only factory can mint");
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
    }
}
