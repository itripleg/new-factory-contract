// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol";

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import {Token} from "../Token.sol";
import {TokenFactory} from "../TokenFactory.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    TokenFactory public factory;

    function beforeAll() public {
        // <instantiate contract>
        Assert.equal(uint(1), uint(1), "1 should be equal to 1");
        factory = new TokenFactory();
    }

    function createToken() public {
        string memory name = "name";
        string memory ticker = "ticker";
        address tokenAddress = factory.createToken(name, ticker);
        Token token = Token(tokenAddress);
        Assert.equal(
            token.balanceOf(address(factory)),
            factory.INITIAL_SUPPLY(),
            "Balance of Factory doesn't equal INITIAL_SUPPLY"
        );
        Assert.equal(
            token.totalSupply(),
            factory.INITIAL_SUPPLY(),
            "Total supply doesn't equal INITIAL_SUPPLY"
        );
        Assert.equal(
            factory.tokens(tokenAddress),
            true,
            "Token not added to map."
        );
    }
}
