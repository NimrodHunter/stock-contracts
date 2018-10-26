pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is Ownable, ERC20 {
    event Burn(address indexed burner, uint256 value);

    function burn(address _who, uint256 _value) public onlyOwner returns (bool) {
        _burn(_who, _value);
        emit Burn(_who, _value);
        return true;
    }
}