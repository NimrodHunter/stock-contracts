pragma solidity 0.4.21;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "./ERC223ReceivingContract.sol";
import "./ERC223BasicToken.sol";
import "./StockToken.sol";

contract Stock is Ownable, ERC223ReceivingContract {
    using SafeMath for uint256;

    mapping(uint256 => address) public tokens;
    mapping(address => uint256) public balances;
    mapping(address => address) public nextToken;
    mapping(address => bool) public isToken;
    
    uint256 public currentPeriod;
    uint256 public revenueFrame;
    uint256 public sharesNumber;
    
    ERC223BasicToken fiatToken;

    function Stock(address _fiatToken, address _stock, uint256 _revenueFrame, uint256 _sharesNumber) public {
        sharesNumber = _sharesNumber;
        fiatToken = ERC223BasicToken(_fiatToken);
        revenueFrame = _revenueFrame;
        currentPeriod =  block.timestamp;
        tokens[currentPeriod] = _stock;
        isToken[_stock] = true;
        address nextStock = new StockToken();
        nextToken[_stock] = nextStock;
        isToken[nextStock] = true;
    }

    function tokenFallback(address _from, uint _value, bytes _data) public updatePeriod {
        require(msg.sender == address(fiatToken) || isToken[msg.sender]);
        if (msg.sender == address(fiatToken)) {
            balances[tokens[currentPeriod]] = balances[tokens[currentPeriod]].add(_value);
        } else {
            require(StockToken(msg.sender).burn(address(this), _value));
            require(fiatToken.transfer(_from, balances[msg.sender].mul(_value).div(sharesNumber)));
            require(StockToken(nextToken[msg.sender]).mint(_from, _value));
            if (StockToken(msg.sender).totalSupply() == 0 && balances[msg.sender] > 0) {
                balances[nextToken[msg.sender]] = balances[nextToken[msg.sender]].add(balances[msg.sender]);
                balances[msg.sender] = 0;
            } 
        }
    }

    function withdraw(uint256 _amount) public onlyOwner updatePeriod {
        require(_amount <= balances[tokens[currentPeriod]]);
        balances[tokens[currentPeriod]] = balances[tokens[currentPeriod]].sub(_amount);
        require(fiatToken.transfer(msg.sender, _amount));
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

    modifier updatePeriod() {
        changePeriod();
        _;
    }
 
}