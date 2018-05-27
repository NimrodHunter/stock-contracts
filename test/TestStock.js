import expectThrow from './helpers/expectThrow';
import increaseTime, { duration } from './helpers/increaseTime';

const ExampleToken = artifacts.require('ExampleToken');
const Stocktoken = artifacts.require('StockToken');
const Stock = artifacts.require('Stock');

contract('Stock Behavior', (accounts) => {

  let fiatToken;
  let stock;
  let owner = accounts[0];
  let shareHolderOne =  accounts[1];
  let shareHolderTwo =  accounts[2]
  let shareHolderThree =  accounts[3];
  let stockToken;
  let period = duration.weeks(4);

  beforeEach(async () => {
    fiatToken = await ExampleToken.new();
    fiatToken.mint(owner, 100);
    stockToken = await Stocktoken.new();
    await stockToken.mint(shareHolderOne, 20);
    await stockToken.mint(shareHolderTwo, 50);
    await stockToken.mint(shareHolderThree, 30);
    stock = await Stock.new(fiatToken.address, period);
    await stockToken.transferOwnership(stock.address);
    await stock.begun(stockToken.address);
  });

  it('should set the start values properly', async () => {

  });

  it('send income to stock', async () => {
    const amount = 40;
    const tx = await fiatToken.transfer(stock.address, amount);
    const period = await stock.periodByToken(stockToken.address);
    const balance = await stock.balanceByPeriod(period);
    assert(amount, balance);
  });

  it('withdraw fiat from stock', async () => {
    const incomeAmount = 40;
    const withdrawnAmount = 15;
    await fiatToken.transfer(stock.address, incomeAmount);
    await stock.withdraw(withdrawnAmount);
    const period = await stock.periodByToken(stockToken.address);
    const balance = await stock.balanceByPeriod(period);
    assert(incomeAmount-withdrawnAmount, balance);
  });

  it('change period', async () => {
    await increaseTime(duration.weeks(5));
    const currentPeriodBefore = await stock.currentPeriod.call();
    await stock.changePeriod();
    const currentPeriodAfter = await stock.currentPeriod.call();
    assert(currentPeriodBefore, currentPeriodBefore+duration.weeks(5));
  });

  it('get revenue', async () => {
    const amount = 100;
    await fiatToken.transfer(stock.address, amount);
    let currentPeriod = await stock.currentPeriod.call();
    await increaseTime(duration.weeks(5));
    const sharesAmount = 20;
    const tx = await stockToken.transfer(stock.address, sharesAmount, {from: shareHolderOne});
    currentPeriod = await stock.currentPeriod.call();
    let newToken = await stock.tokens(currentPeriod);
    newToken = Stocktoken.at(newToken);
    const newTokenBalance = await newToken.balanceOf(shareHolderOne);
    assert(newTokenBalance, sharesAmount);
    const fiatBalance = await fiatToken.balanceOf(shareHolderOne);
    assert(fiatBalance, sharesAmount);
  });



});


