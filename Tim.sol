pragma solidity >=0.7.0 <0.9.0;

// Caller deposits some ERC20 token in return for some Ether
// hint: ethToSend = contractEthBalance - contractEthBalanceAfterSwap
// where contractEthBalanceAfterSwap = K / contractERC20TokenBalanceAfterSwap Transfer ERC-20 tokens from caller to contract
// Transfer Ether from contract to caller
// Return a uint of the amount of Ether sent

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import './AsaToken.sol';

library Math{
    function divide (uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
}

contract Tim{

    event SwapForEth(
        uint amountERC20TokenDeposited, 
        uint amountEthWithdrew
    );

    AsaToken ass = AsaToken(0x1A5Cf8a4611CA718B6F0218141aC0Bfa114AAf7D);
    // address asa =  0x1A5Cf8a4611CA718B6F0218141aC0Bfa114AAf7D;
    address eth = 0x133c5FE2d2302d98C949064ce02Cb0444708f605;
    uint amountERC20TokenSentOrReceived; 
    uint contractERC20TokenBalance; 
    uint amountEthSentOrReceived; 
    uint contractEthBalance; 
    uint amountTokenSentOrReceived; 
    uint contractTokenBalance; 
    uint liquidityPositionsIssued0rBurned;
    uint totalLiquidityPositions;
    uint contractERC20TokenBalance = AsaToken.balanceOf(asa);
    uint K;
    // for a function to accept ether, it has to be payable type

    constructor(address _ERC20Add){
        

        K = contractEthBalance * contractERC20TokenBalance;


    }

    function swapForEth(uint _amountERC20Token) external returns(uint){
        // Caller deposits some ERC20 token in return for some Ether
        // hint: ethToSend = contractEthBalance - contractEthBalanceAfterSwap
        // where contractEthBalanceAfterSwap = K / contractERC20TokenBalanceAfterSwap Transfer ERC-20 tokens from caller to contract
        // Transfer Ether from contract to caller
        // Return a uint of the amount of Ether sent

        
        uint ethToSend;
        uint contractERC20TokenBalanceAfterSwap = _amountERC20Token.balanceOf() + contractERC20TokenBalance;
        uint contractEthBalanceAfterSwap = K / contractERC20TokenBalanceAfterSwap;
        ethToSend = contractEthBalance - contractEthBalanceAfterSwap;
        contractEthBalance -= contractEthBalanceAfterSwap;

        address(_amountERC20Token).transfer(_ethToSend); // transfer eth to send to the caller of function

        // AsaToken._
        // Pull in erc20token in
        // Calculate token out 
        
        
        // Transfer token out to msg.sender
        //msg.value gets the ether balance of sender
        // Update the reserves
        
        emit SwapForEth(_amountERC20Token.balanceOf(),ethToSend);
        return ethToSend;

    }
}