import expectThrow from './helpers/expectThrow';

const ExampleToken = artifacts.require('ExampleToken');

contract('Example Token', (accounts) => {

  let token;
  let owner = accounts[0];

  before(async () => {
    token = await ExampleToken.new();
  });

  it('should set the start values properly', async () => {
    let name = await token.name.call();
    assert.equal(name, 'Example', 'should be Example');

    let symbol = await token.symbol.call();
    assert.equal(symbol, 'EXM', 'should be EXM');

    let decimals = await token.decimals.call();
    assert.equal(decimals.valueOf(), 18, 'should be 18');

    let supply = await token.totalSupply.call();
    assert.equal(supply.valueOf(), 0, 'should be 0');

    let _owner = await token.owner.call();
    assert.equal(_owner, owner, 'should be the owner of the token');

    let mintingFinished = await token.mintingFinished.call();
    assert.equal(mintingFinished, false, 'should be false');

  });

  it('should mint tokens properly until ends minting feature', async () => {
    await token.mint(owner, 1000);

    let supply = await token.totalSupply.call();
    assert.equal(supply.valueOf(), 1000, 'should be 1000');

    let ownerBalance = await token.balanceOf.call(owner);
    assert.equal(ownerBalance.valueOf(), 1000, 'should be 1000');

    await token.finishMinting();
    let mintingFinished = await token.mintingFinished.call();
    assert.equal(mintingFinished, true, 'should be true');

    await expectThrow(token.mint(owner, 500));

    supply = await token.totalSupply.call();
    assert.equal(supply.valueOf(), 1000, 'should be 1000');

  });

  it('should transfer to account', async () => {
    await token.transfer(accounts[1], 20);

    let balanceAccount1 = await token.balanceOf.call(accounts[1]);
    assert.equal(balanceAccount1.valueOf(), 20, 'should be 20');

    it('should approve spend tokens to another account, increase and decrease that amount', async () => {
      await token.approve(accounts[1], 45);

      let amountToSpend = await token.allowance.call(accounts[0], accounts[1]);

      assert.equal(amountToSpend.valueOf(), 45, "should be 45");

      await token.increaseApproval(accounts[1], 15);

      amountToSpend = await token.allowance.call(accounts[0], accounts[1]);

      assert.equal(amountToSpend.valueOf(), 60, "should be 60");

      await token.decreaseApproval(accounts[1], 40);

      amountToSpend = await token.allowance.call(accounts[0], accounts[1]);

      assert.equal(amountToSpend.valueOf(), 20, "should be 20");

    });

    it('should tranfer from spender address', async () => {
      await token.transferFrom(accounts[0], accounts[2], 20, {from: accounts[1]});

      let balance = await token.balanceOf.call(accounts[2]);

      assert.equal(balance.valueOf(), 20, "should be 20");
    });

  });

  it('should not transfer to account, no enough balance', async () => {
    await expectThrow(token.transfer(accounts[2], 10000));
    let ownerBalance = await token.balanceOf.call(owner);
    assert.equal(ownerBalance.valueOf(), 980, "should be 980");
  });

  it('should not allow tranfer eth directly to the token contract', async () => {
    try {
      await expectThrow(web3.eth.sendTransaction({from: accounts[0], to: token.address, value: 10}));
    } catch (error) {
      const revert = error.message.search('revert') >= 0;
      assert.equal(revert, true, "should be true");
      return;
    }
  });


});