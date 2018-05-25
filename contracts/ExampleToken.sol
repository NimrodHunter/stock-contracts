pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "@acatalan/erc223-20-contracts/contracts/ERC223BasicToken.sol";


/// @title ExampleToken that uses MintableToken, DetailedERC20 and ERC223BasicToken.
contract ExampleToken is DetailedERC20, MintableToken, ERC223BasicToken {
    string constant NAME = "Example";
    string constant SYMBOL = "EXM";
    uint8 constant DECIMALS = 18;

    /// @dev Constructor that sets the details of the ERC20 token.
    constructor()
        DetailedERC20(NAME, SYMBOL, DECIMALS)
        public
    {}
}