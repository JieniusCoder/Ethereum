// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract MarketMaker {

    address _tokenAddress; //given addresses of the ERC-20 tokens 
    uint256 totalLiquidityPositions;
    mapping(address => uint) liquidityPositions; //mapping of the liqiuidyProviders to amounts of positions that they have
    uint K;
    uint contractERC20TokenBalance = getTokenBalance();
    uint contractEthBalance = getETHBalance();
    uint amountEth;
    
    //this is the constructor that accepts the tokens into the smart contract
    constructor(address tokenAddress) public{ 
        _tokenAddress = tokenAddress;
        K = contractEthBalance * contractERC20TokenBalance; 
           
    }

    //this function actually deposits the ERC-20 tokens in the smart contract
    function depositTokens(uint256 amount) public payable {
        uint _default = 1*(10**18);
        require(amount >= _default, "Default amount to be deposited");

        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount);

    }

    //this function actually deposits the Ether into the smart contract
    function depositEther(uint256 amount) public payable {
        uint _default = 1*(10**18);
        require(amount >= _default, "Default amount to be deposited");

    }

    function getTokenBalance() public returns(uint){
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function getETHBalance() public returns(uint){
        return address(this).balance;
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
            return liquidityPositions[_tokenAddress];
            
        }
    }





    
}



    



