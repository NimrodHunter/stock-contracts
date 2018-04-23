pragma solidity 0.4.21;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "./ERC223ReceivingContract.sol";
import "./ERC223BasicToken.sol";
import "./StockToken.sol";

contract Stock is Ownable, ERC223ReceivingContract {
    using SafeMath for uint256;

    mapping(uint256 => address) tokens;
    mapping(address => uint256) balances;
    mapping(address => address) nextToken;
    mapping(address => bool) isToken;
    
    uint256 currentPeriod;
    uint256 revenueFrame;
    uint256 shareholdersNumber;
    
    ERC223BasicToken fiatToken;
    
   

    function Stock(address _fiatToken, address _stock, uint256 _revenueFrame, uint256 _shareholdersNumber) public {
        shareholdersNumber = _shareholdersNumber;
        fiatToken = ERC223BasicToken(_fiatToken);
        revenueFrame = _revenueFrame;
        currentPeriod =  block.timestamp;
        tokens[currentPeriod] = _stock;
        isToken[_stock] = true;
        address nextStock = new StockToken();
        nextToken[_stock] = nextStock;
        isToken[nextStock] = true;
    }

    function tokenFallback(address _from, uint _value, bytes _data) public {
        require(msg.sender == address(fiatToken) || isToken[msg.sender]);
        changePeriod();
        if (msg.sender == address(fiatToken)) {
            balances[tokens[currentPeriod]] = balances[tokens[currentPeriod]].add(_value);
        } else {
            require(StockToken(msg.sender).burn(_from, _value));
            require(fiatToken.transfer(_from, (balances[msg.sender]*_value)/shareholdersNumber));
            require(StockToken(nextToken[msg.sender]).mint(_from, _value));
        }
    }
        
    function changePeriod() public {
        if (block.timestamp > currentPeriod.add(revenueFrame)) {
            address currentToken = nextToken[tokens[currentPeriod]];
            address nextStock = new StockToken();
            nextToken[currentToken] = nextStock;
            isToken[nextStock] = true;
            currentPeriod = block.timestamp;
            tokens[currentPeriod] = currentToken;
            StockToken(currentToken).begun(revenueFrame);
        }   
    }
}