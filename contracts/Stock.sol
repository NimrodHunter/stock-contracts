pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "@acatalan/erc223-20-contracts/contracts/ERC223ReceivingContract.sol";
import "@acatalan/erc223-20-contracts/contracts/ERC223BasicToken.sol";
import "./StockToken.sol";

contract Stock is Ownable, ERC223ReceivingContract {
    using SafeMath for uint256;    
    
    mapping(uint256 => address) public tokens; //current period -> token
    mapping(address => bool) public isToken;
    mapping(address => address) public nextToken;
    uint256 public numberOfPeriods = 1; // number of periods
    mapping(uint256 => uint256) public periodNumber;
    mapping(address => address) public currentTokenOf; //user -> token -> period -> balance
    mapping(address => uint256) public periodByToken; 
    mapping(uint256 => uint256) public balanceByPeriod;

    function currentToken(address user) public view returns(address) {
        return currentTokenOf[user];
    }

    function getPeriodByToken(address stockToken) public view returns(uint256) {
        return periodByToken[stockToken];
    }

    function poolBalance(uint256 period) public view returns(uint256) {
        return balanceByPeriod[period];
    }

    function getPeriodNumber(uint256 period) public view returns(uint256) {
        return periodNumber[period];
    }
  
    uint256 public currentPeriod;
    uint256 public revenueFrame;
    uint256 public sharesNumber;
    address fiatToken;

    constructor(address _fiatToken, uint256 _revenueFrame) public {
        fiatToken = _fiatToken;
        revenueFrame = _revenueFrame;
    }

    function begun(address _stock) public onlyOwner {
        
        sharesNumber = StockToken(_stock).totalSupply();
        isToken[_stock] = true;
        currentPeriod = block.timestamp;
        periodNumber[currentPeriod] = numberOfPeriods;
        tokens[currentPeriod] = _stock;
        periodByToken[_stock] = currentPeriod;
        address nextStock = new StockToken();
        nextToken[_stock] = nextStock;
        isToken[nextStock] = true;
        StockToken(_stock).begun(revenueFrame);
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public updatePeriod {
        require(msg.sender == fiatToken || isToken[msg.sender]);
        if (msg.sender == fiatToken) {
            deposit(_value);
        } else {
            claimRevenue(_from, _value, msg.sender);
            }
    }

    function claimRevenue(address _from, uint256 _amount, address _stockToken) public updatePeriod {
        if (msg.sender != _stockToken) {
            require(StockToken(_stockToken).transferFrom(_from, address(this), _amount), "transfer from fail");
        }
        require(StockToken(_stockToken).burn(address(this), _amount), "burn error");
        require(ERC223BasicToken(fiatToken).transfer(_from, balanceByPeriod[periodByToken[_stockToken]].mul(_amount).div(sharesNumber)), "transfer error");
        require(StockToken(nextToken[_stockToken]).mint(_from, _amount), "mint error");
        if (StockToken(_stockToken).totalSupply() == 0 && balanceByPeriod[periodByToken[_stockToken]] > 0) {
            balanceByPeriod[periodByToken[nextToken[_stockToken]]] = balanceByPeriod[periodByToken[nextToken[_stockToken]]].add(balanceByPeriod[periodByToken[_stockToken]]);
            balanceByPeriod[periodByToken[_stockToken]] = 0;
        }
        currentTokenOf[_from] = nextToken[_stockToken];
    }

    function deposit(uint256 _amount) public updatePeriod {
        require(msg.sender == owner || msg.sender == fiatToken, "doesn't have permissions");
        balanceByPeriod[currentPeriod] = balanceByPeriod[currentPeriod].add(_amount);
        if (msg.sender == owner) {
            require(ERC223BasicToken(fiatToken).transferFrom(owner, address(this), _amount), "transfer from fail");
        }
    }

    function withdraw(uint256 _amount) public onlyOwner updatePeriod {
        require(_amount <= balanceByPeriod[currentPeriod], "doesn't have enough balance");
        balanceByPeriod[currentPeriod] = balanceByPeriod[currentPeriod].sub(_amount);
        require(ERC223BasicToken(fiatToken).transfer(msg.sender, _amount), "fiat transfer error");
    }
        
    function changePeriod() public {
        if (block.timestamp > currentPeriod.add(revenueFrame)) {
            address newCurrentToken = nextToken[tokens[currentPeriod]];
            address nextStock = new StockToken();
            nextToken[newCurrentToken] = nextStock;
            isToken[nextStock] = true;
            currentPeriod = block.timestamp;
            tokens[currentPeriod] = newCurrentToken;
            numberOfPeriods += 1;
            periodByToken[nextStock] = currentPeriod;
            periodNumber[currentPeriod] = numberOfPeriods;
            StockToken(newCurrentToken).begun(revenueFrame);
        }   
    }

    modifier updatePeriod() {
        changePeriod();
        _;
    }
 
}