pragma solidity ^0.4.23;

import "./MintableToken.sol";
import "./BurnableToken.sol";
import "@acatalan/erc223-20-contracts/contracts/ERC223BasicToken.sol";

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/// @title StockToken that uses MintableToken, BurnableToken and ERC223BasicToken.
contract StockToken is Ownable, MintableToken, BurnableToken, ERC223BasicToken {
    uint256 public start;
    uint256 public revenueFrame;

    function begun(uint256 _revenueFrame) public onlyOwner {
        start = block.timestamp;
        revenueFrame = _revenueFrame;
    }

    function burn(address _who, uint256 _value) public onlyOwner returns (bool) {
        require(block.timestamp > start.add(revenueFrame), "it isn't the right period");
        super.burn(_who, _value);
        return true;
    }
}

