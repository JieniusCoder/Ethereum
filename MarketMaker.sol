pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


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

    totalLiquidlity 

    //events
    event SwapForEth(
        uint amountERC20TokenDeposited, 
        uint amountEthWithdrew
    );

    event SwapForERC20Token(
        uint amountERC20TokenWithdrew, 
        uint amountEthDeposited
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

    //constructor sets the defalut value of variable in the contract
    constructor() public {

    }

    function estimateEthToProvide(uint _amountERC20Token) public view returns(uint) {
        uint estimateEth = contractEthBalance * _amountERC20Token / contractERC20TokenBalance;
        return estimateEth;
    }

    /*
    function that swap for Eth and return the amount of Eth caller received
    */
    function SwapForEth (uint _amountERC20Token) public returns(uint) {
        uint contractEthBalanceBeforeSawp = contractEthBalance;
        contractERC20TokenBalance = contractERC20TokenBalance + _amountERC20Token;
        contractEthBalance = K / contractERC20TokenBalance;
        uint ethToSend = contractEthBalanceBeforeSawp - contractEthBalance;
        emit SwapForEth(_amountERC20Token, ethToSend);
        return ethToSend;
    }

    /*
    function that give estimate on how much Eth the caller receive
    doee not actually perform the operation in the contract. 
    */
    function estimateSwapForEth (uint _amountERC20Token) public view returns(uint) {
        uint contractERC20TokenBalanceAfterSwap = contractERC20TokenBalance + _amountERC20Token;
        uint contractEthBalanceAfterSwap = K / contractERC20TokenBalanceAfterSwap;
        uint estimateEthToSend = contractEthBalance - contractEthBalanceAfterSwap;
        return estimateEthToSend;
    }

    /*
    function that swap for ERC20 token and return the amount of ERC20 token caller received
    */
    function SwapForERC20Token (uint _amountEth) public returns(uint) {
        uint contractERC20TokenBalanceBeforeSwap = contractERC20TokenBalance;
        contractEthBalance = contractEthBalance + _amountEth;
        contractERC20TokenBalance = K / contractEthBalance;
        uint ERC20TokenToSend = contractERC20TokenBalanceBeforeSwap - contractERC20TokenBalance;
        emit SwapForERC20Token(_amountEth, ERC20TokenToSend);
        return ERC20TokenToSend;
    }

    /*
    function that give estimate on how much ERC20 token the caller receive
    doee not actually perform the operation in the contract. 
    */
    function estimateSwapForERC20Token(uint _amountEth) public view returns(uint) {
        uint contractEthBalanceAfterSwap = contractEthBalance + _amountEth;
        uint contractERC20TokenBalanceAfterSwap = K / contractEthBalanceAfterSwap;
        uint estimateERC20TokenToSend = contractERC20TokenBalance - contractERC20TokenBalanceAfterSwap;
        return estimateERC20TokenToSend;
    }

    function provideLiquidity(uint _amountERC20Token) public returns(uint) {
        
        require((totalLiquidityPositions * _amountERC20Token/contractERC20TokenBalance) == (totalLiquidityPositions * amountEth/contractEthBalance));
        depositTokens(_amountERC20Token); 
        // depositEther();

        if(totalLiquidityPositions == 0){
            liquidityPositions[_tokenAddress] =  100;
            
        }else {
            liquidityPositions[_tokenAddress] = totalLiquidityPositions * _amountERC20Token / contractERC20TokenBalance;
            K = contractEthBalance * contractERC20TokenBalance;
            totalLiquidityPositions += 1;
            
        }

        emit LiquidityProvided(_amountERC20Token, amountEthDeposited, liquidityPositionsIssued);
        return liquidityPositions[_tokenAddress];
    }
}



