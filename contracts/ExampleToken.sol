pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "@acatalan/erc223-20-contracts/contracts/ERC223BasicToken.sol";


/// @title ExampleToken that uses MintableToken, DetailedERC20 and ERC223BasicToken.
contract ExampleToken is ERC20Detailed, ERC20Mintable, ERC223BasicToken {
    string constant NAME = "Example";
    string constant SYMBOL = "EXM";
    uint8 constant DECIMALS = 18;

    /// @dev Constructor that sets the details of the ERC20 token.
    constructor()
        ERC20Detailed(NAME, SYMBOL, DECIMALS)
        public
    {}
}