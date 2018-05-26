pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "@acatalan/erc223-20-contracts/contracts/ERC223ReceivingContract.sol";
import "@acatalan/erc223-20-contracts/contracts/ERC223BasicToken.sol";
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

    constructor(address _fiatToken, address _stock, uint256 _revenueFrame, uint256 _sharesNumber) public {
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

    function tokenFallback(address _from, uint256 _value, bytes _data) public updatePeriod {
        require(msg.sender == address(fiatToken) || isToken[msg.sender]);
        if (msg.sender == address(fiatToken)) {
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
        require(fiatToken.transfer(_from, balances[_stockToken].mul(_amount).div(sharesNumber)), "transfer error");
        require(StockToken(nextToken[_stockToken]).mint(_from, _amount), "mint error");
        if (StockToken(_stockToken).totalSupply() == 0 && balances[_stockToken] > 0) {
            balances[nextToken[_stockToken]] = balances[nextToken[_stockToken]].add(balances[_stockToken]);
            balances[_stockToken] = 0;
        } 
    }

    function deposit(uint256 _amount) public updatePeriod {
        require(msg.sender == owner || msg.sender == address(fiatToken), "doesn't have permissions");
        balances[tokens[currentPeriod]] = balances[tokens[currentPeriod]].add(_amount);
        if (msg.sender == owner) {
            require(fiatToken.transferFrom(owner, address(this), _amount), "transfer from fail");
        }
    }

    function withdraw(uint256 _amount) public onlyOwner updatePeriod {
        require(_amount <= balances[tokens[currentPeriod]], "doesn't have enough balance");
        balances[tokens[currentPeriod]] = balances[tokens[currentPeriod]].sub(_amount);
        require(fiatToken.transfer(msg.sender, _amount), "fiat transfer error");
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