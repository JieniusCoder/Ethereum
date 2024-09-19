pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import './AsaToken.sol';
import './HawKoin.sol';
import './KorthCoin.sol';


contract MarketMaker{
    /*
    known conditions in the contract:
    amountERC20TokenSentOrReceived / contractERC20TokenBalance = amountEthSentOrReceived / contractEthBalance
    and
    amountTokenSentOrReceived / contractTokenBalance = liquidityPositionsIssuedOrBurned / totalLiquidityPositions
    */

    uint K; //k = contractEthBalance * contractERC20TokenBalance
    uint contractEthBalance;
    uint contractERC20TokenBalance;
    uint amountERC20TokenSentOrReceived; 
    uint amountEthSentOrReceived; 
    uint amountTokenSentOrReceived; 
    uint contractTokenBalance; 
    uint liquidityPositionsIssued0rBurned;
    uint totalLiquidityPositions;
    address _tokenAddress;
    IERC20 public token;
    mapping(address => uint) liquidityPositions;

    event SwapForEth(
        uint amountERC20TokenDeposited, 
        uint amountEthWithdrew
    );

    event LiquidityProvided(
        uint amountERC20TokenDeposited, 
        uint amountEthDeposited,
        uint liquidityPositionsIssued
    );


    event LiquidityWithdrew(
        uint amountERC20TokenWithdrew, 
        uint amountEthWithdrew,
        uint liquidityPositionsBurned
    );


    event SwapForERC20Token(
        uint amountERC20TokenWithdrew, 
        uint amountEthDeposited
    );


    //constructor sets the defalut value of variable in the contract
    constructor(address tokenAddress) public{ 
        _tokenAddress = tokenAddress;
        K = contractEthBalance * contractERC20TokenBalance;
        token = IERC20(_tokenAddress);
    }

    //this function actually deposits the ERC-20 tokens in the smart contract
    function depositTokens(uint256 amount) public payable {
        uint _default = 1*(10**18);
        require(amount >= _default, "Default amount to be deposited");
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount);
        contractERC20TokenBalance = getTokenBalance();
        K = contractEthBalance * contractERC20TokenBalance; 


    }

    function depositEther(uint256 amount) public payable {
        uint _default = 1e18;
        require(amount >= _default, "Default amount to be deposited");
        contractEthBalance = getETHBalance();

    }

    function getTokenBalance() public returns(uint){
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function getETHBalance() public returns(uint){
        return address(this).balance;
    }

    function estimateEthToProvide(uint _amountERC20Token) public view returns(uint) {
        uint estimateEth = contractEthBalance * _amountERC20Token / contractERC20TokenBalance;
        return estimateEth;
    }

    function estimateERC20TokenToProvide(uint _amountEth){
        uint amountERC20 = contractERC20TokenBalance * _amountEth/contractEthBalance;
        return amountERC20;
    }

    /*
    function that swap for Eth and return the amount of Eth caller received
    */
    function SwapForEth (uint _amountERC20Token) public returns(uint) {
        uint contractEthBalanceBeforeSawp = contractEthBalance;
        contractERC20TokenBalance = contractERC20TokenBalance + _amountERC20Token;
        contractEthBalance = K / contractERC20TokenBalance;
        uint ethToSend = contractEthBalanceBeforeSawp - contractEthBalance;
        emit SwapForEth(_amountERC20Token,ethToSend);
        return ethToSend;
    }

    /*
    function that give estimate on how much Eth the caller receive
    doee not actually perform the operation in the contract. 
    */
    function estimateSwapForEth (uint _amountERC20Token) public view returns(uint) {
        uint contractERC20TokenBalanceAfterSwap = contractERC20TokenBalance + _amountERC20Token;
        uint contractEthBalanceAfterSwap = K / contractERC20TokenBalanceAfterSwap;
        uint estimateEthToReceived = contractEthBalance - contractEthBalanceAfterSwap;
        return estimateEthToReceived;
    }

    /*
    function that swap for ERC20 token and return the amount of ERC20 token caller received
    */
    function SwapForERC20Token (uint _amountEth) public returns(uint) {
        uint contractERC20TokenBalanceBeforeSwap = contractERC20TokenBalance;
        contractEthBalance = contractEthBalance + _amountEth;
        contractERC20TokenBalance = K / contractEthBalance;
        uint estimateERC20TokenToReceived = contractERC20TokenBalanceBeforeSwap - contractERC20TokenBalance;
        emit SwapForERC20Token(estimateERC20TokenToReceived, _amountEth);
        return estimateERC20TokenToReceived;
    }

    /*
    function that give estimate on how much ERC20 token the caller receive
    doee not actually perform the operation in the contract. 
    */
    function estimateSwapForERC20Token(uint _amountEth) public view returns(uint) {
        uint contractEthBalanceAfterSwap = contractEthBalance - _amountEth;
        uint contractERC20TokenBalanceAfterSwap = K / contractEthBalanceAfterSwap;
        uint estimateERC20TokenToReceived = contractERC20TokenBalance - contractERC20TokenBalanceAfterSwap;
        return estimateERC20TokenToReceived;
    }

    function estimateERC20TokenToProvide(uint _amountEth){
        uint amountERC20 = contractERC20TokenBalance * _amountEth/contractEthBalance;
        return amountERC20;
    }

    /**
        Return a unit of the amount of the caller’s liquidity positions
    */
    function getMyLiquidityPositions() public view returns(uint){
        return liquidityPositions; //my??
    } 

    function withdrawLiquidity (uint _liquidityPositionsToBurn) public view{
        liquidityPositions[msg.sender] -= _liquidityPositionsToBurn;
        totalLiquidityPositions -= _liquidityPositionsToBurn;
        //deduct liquidity from wallet

        //send ether to wallet
        amountEthToSend = _liquidityPositionsToBurn * contractEthBalance/ totalLiquidityPositions;
        amountERC20ToSend = _liquidityPositionsToBurn * contractERC20TokenBalance/ totalLiquidityPositions;
        //cant give up>= liquidity they own/ in pool
        if(_liquidityPositionsToBurn > liquidityPositions[msg.sender] || _liquidityPositionsToBurn >= totalLiquidityPositions){
            return; //error message?
        }
        //update mapping
        contractEthBalance -= amountEthToSend;
        contractERC20TokenBalance -= amountERC20ToSend;

        K = contractEthBalance * contractERC20TokenBalance;
        //transfer from contract to caller
        token.transferFrom(address(this),msg.sender, amountERC20ToSend);

        // msg.sender.transfer(amountEthToSend); // transfering eth

        bool sent = (msg.sender).send(amountEthToSend);
        require(sent, "An error occured while sending");
        //transferFrom(address(this),msg.sender, amountEthToSend);//sketchy, not too sure of eth
        //return amt erc20 & eth sent
        return (amountERC20ToSend,amountEthToSend);
        emit LiquidityWithdrew(amountERC20ToSend,amountEthToSend,_liquidityPositionsToBurn);

    }

    function provideLiquidity(uint _amountERC20Token) public payable returns(uint) {
        
        // require((totalLiquidityPositions * _amountERC20Token/contractERC20TokenBalance) == (totalLiquidityPositions * estimateEthToProvide(_amountERC20Token)/contractEthBalance));
        // depositTokens(_amountERC20Token); 
        // depositEther();

        token.transferFrom(msg.sender, address(this), _amountERC20Token);

        if(totalLiquidityPositions == 0){
            liquidityPositions[_tokenAddress] +=  100;
            totalLiquidityPositions += 100;
        }else {
            liquidityPositions[_tokenAddress] = totalLiquidityPositions * (_amountERC20Token / contractERC20TokenBalance);
            totalLiquidityPositions += liquidityPositions[_tokenAddress] ;
        }
        
        contractEthBalance += msg.value;
        contractERC20TokenBalance += token.balanceOf(address(this));
        K = contractEthBalance * contractERC20TokenBalance;
        // K = msg.value * token.balanceOf()

        emit LiquidityProvided(amountERC20TokenDeposited, msg.value, liquidityPositionsIssued);
        return liquidityPositions[_tokenAddress];

    }
}