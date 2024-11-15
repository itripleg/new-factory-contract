// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Token} from "./Token.sol";

contract TokenFactory {
    uint public constant DECIMALS = 10 ** 18;
    uint public constant MAX_SUPPLY = (10 ** 9) * DECIMALS;
    uint public constant INITIAL_SUPPLY = (MAX_SUPPLY * 20) / 100; // Initial minted supply (20% of max supply)
    uint public constant LINEAR_COEFFICIENT = 46875; // Represents 'k' in the bonding curve equation
    uint public constant OFFSET = 18750000000000000000000000000000; // Represents the offset in the bonding curve
    uint public constant SCALING_FACTOR = 10 ** 39; // Scaling factor to normalize values

    mapping(address => bool) public tokens;

    function createToken(
        string memory name,
        string memory ticker
    ) external returns (address) {
        Token token = new Token(name, ticker, INITIAL_SUPPLY);
        tokens[address(token)] = true;
        return address(token);
    }

    function buy(address tokenAddress, uint amount) external payable {
        require(tokens[tokenAddress] == true, "Token doesn't exist.");
        Token token = Token(tokenAddress);
        uint availableSupply = MAX_SUPPLY - INITIAL_SUPPLY - token.totalSupply();
        require(amount <= availableSupply, "Not enough available supply.");
        // Calculate required ETH for purchase
        calculateRequiredEth(tokenAddress, amount);
    }

    function calculateRequiredEth(
        address tokenAddress,
        uint amount
    ) public view returns (uint) {
        Token token = Token(tokenAddress);

        // Current supply sold (a)
        uint supplySoldStart = token.totalSupply();

        // Updated supply after the purchase (b)
        uint supplySoldEnd = supplySoldStart + amount;

        // Price at supply `a` based on the bonding curve
        uint priceAtStart = LINEAR_COEFFICIENT * supplySoldStart + OFFSET;

        // Price at supply `b` based on the bonding curve
        uint priceAtEnd = LINEAR_COEFFICIENT * supplySoldEnd + OFFSET;

        // Required ETH = (supplyEnd - supplyStart) * (priceAtStart + priceAtEnd) / 2
        return ((supplySoldEnd - supplySoldStart) * (priceAtStart + priceAtEnd)) / (2 * SCALING_FACTOR);
    }
}
