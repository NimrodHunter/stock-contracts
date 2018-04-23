pragma solidity 0.4.21;

import "./MintableToken.sol";
import "./BurnableToken.sol";
import "./ERC223BasicToken.sol";

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/// @title StockToken that uses MintableToken, BurnableToken and ERC223BasicToken.
contract StockToken is Ownable, MintableToken, BurnableToken, ERC223BasicToken {
    uint256 start;
    uint256 revenueFrame;

    function begun(uint256 _revenueFrame) public onlyOwner {
        start = block.timestamp;
        revenueFrame = _revenueFrame;
    }

    function burn(address _who, uint256 _value) public onlyOwner returns (bool) {
        require(block.timestamp > start.add(revenueFrame));
        super.burn(_who, _value);
    }
}

