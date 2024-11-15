// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

import "remix_tests.sol";
import "remix_accounts.sol";
import "../Token.sol";
import "../TokenFactory.sol";

contract testSuite {
    TokenFactory factory;
    address public tokenAddress;

    /// #value: 1000000000000000000 // 1 ETH
    function beforeAll() public payable {
        // Instantiate the TokenFactory contract
        factory = new TokenFactory();
        Assert.ok(address(factory) != address(0), "Factory contract should be deployed.");

        // Create an initial token for tests
        string memory name = "TestToken";
        string memory ticker = "TTK";
        tokenAddress = factory.createToken(name, ticker);
        Assert.ok(tokenAddress != address(0), "Token should be successfully created.");
    }

    /// #sender: account-0
    function testCreateToken() public {
        string memory name = "SecondToken";
        string memory ticker = "STK";
        address newTokenAddress = factory.createToken(name, ticker);

        // Verify the token creation
        Assert.ok(newTokenAddress != address(0), "New token address should be valid.");
        Token token = Token(newTokenAddress);
        Assert.equal(
            token.totalSupply(),
            factory.INITIAL_SUPPLY(),
            "Token total supply should equal INITIAL_SUPPLY."
        );
        Assert.ok(factory.tokens(newTokenAddress), "Token should be registered in the factory.");
    }

    /// #sender: account-0
    function testCalculateRequiredEth() public {
        uint amount = 100 * factory.DECIMALS();
        uint requiredEth = factory.calculateRequiredEth(tokenAddress, amount);

        // Assert the calculated ETH is valid
        Assert.greaterThan(requiredEth, uint(0), "Required ETH should be greater than zero.");
    }

function testBuyTokens() public payable {
    uint amount = 100 * factory.DECIMALS();
    uint ethRequired = factory.calculateRequiredEth(tokenAddress, amount);

    // Log balances for debugging
    emit LogBalances(address(this).balance, msg.sender, ethRequired);

    // Ensure sufficient balance for the transaction
    Assert.greaterThan(
        address(this).balance,
        ethRequired,
        "Insufficient balance for purchase."
    );

    // Buy tokens
    factory.buy{value: ethRequired}(tokenAddress, amount);

    // Check the buyer's balance (address(this))
    Token token = Token(tokenAddress);
    Assert.equal(
        token.balanceOf(address(this)),
        amount,
        "Buyer should receive the purchased tokens."
    );
}



    /// #sender: account-0
    function testExceedAvailableSupply() public {
        Token token = Token(tokenAddress);

        uint availableSupply = factory.MAX_SUPPLY() - token.totalSupply();
        uint excessiveAmount = availableSupply + 1;

        bool r = false;
        try factory.buy{value: 1 ether}(tokenAddress, excessiveAmount) {
            r = true;
        } catch {}

        Assert.ok(!r, "Purchase exceeding available supply should fail.");
    }

    /// #sender: account-0
    function testMultipleTokenCreation() public {
        string memory name1 = "FirstToken";
        string memory ticker1 = "FTK";
        address tokenAddress1 = factory.createToken(name1, ticker1);

        string memory name2 = "SecondToken";
        string memory ticker2 = "STK";
        address tokenAddress2 = factory.createToken(name2, ticker2);

        // Verify tokens
        Assert.ok(factory.tokens(tokenAddress1), "First token should be registered in the factory.");
        Assert.ok(factory.tokens(tokenAddress2), "Second token should be registered in the factory.");
        Assert.notEqual(tokenAddress1, tokenAddress2, "Token addresses should not be identical.");
    }

    // Event for logging balances
    event LogBalances(uint contractBalance, address sender, uint ethRequired);
}
