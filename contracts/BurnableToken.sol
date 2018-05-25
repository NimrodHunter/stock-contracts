pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is Ownable, BasicToken {
    event Burn(address indexed burner, uint256 value);

    function burn(address _who, uint256 _value) public onlyOwner returns (bool) {
        require(_value <= balances[_who], "doesn't have enough balance");
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
        return true;
    }
}