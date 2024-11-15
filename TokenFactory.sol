//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "./Token.sol";

contract TokenFactory {
    uint public constant DECIMALS = 10 ** 18;
    uint public constant MAX_SUPPLY = (10 ** 9) * DECIMALS;
    uint public constant INITIAL_MINT = (MAX_SUPPLY * 20) / 100;
    uint public constant k = 46875;
    uint public constant offset = 18750000000000000000000000000000;
    uint public constant SCALING_FACTOR = 10 ** 39;

    mapping(address => bool) public tokens;

    function createToken(
        string memory name,
        string memory ticker
    ) external returns (address) {
        // initialOwner = msg.sender;
        Token token = new Token(name, ticker, INITIAL_MINT);
        tokens[address(token)] = true;
        return address(token);
    }

    function buy(address tokenAddress, uint amount) external payable {
        require(tokens[tokenAddress] == true, "Token doesn't exist.");
        Token token = Token(tokenAddress);
        uint availableSupply = MAX_SUPPLY - INITIAL_MINT - token.totalSupply();
        require(amount <= availableSupply, "Not enough available supply.");
        //calculate
        calculateRequiredEth(tokenAddress, amount);
    }

    function calculateRequiredEth(
        address tokenAddress,
        uint amount
    ) public returns (uint) {
        //amount eth = (b-a) * (f(a) + f(b) / 2)
        Token token = Token(tokenAddress);
        uint b = token.TotalSupply() + amount;
        uint a = token.totalSupply();
        uint f_a = k * a + offset;
        uint f_b = k * b + offset;
        return ((b - a) * (f_a + f_b)) / (2 * SCALING_FACTOR);
    }
}
