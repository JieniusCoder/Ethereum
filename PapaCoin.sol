// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
contract MyContract {
//mapping(address => uint256) public balances;
address wallet;
uint contractEthBalance;


function estimateERC20TokenToProvide(uint _amountEth) public view returns(uint){
uint amountERC20;
amountERC20 = contractERC20TokenBalance * _amountEth/contractEthBalance;
return amountERC20;

}

/**
Return a unit of the amount of the caller’s liquidity positions
*/
function getMyLiquidityPositions() public view returns(uint){
    return liquidityPositions; //my??
} 

function withdrawLiquidity (uint _liquidityPositionsToBurn) public view{
    // decrement liquiditypositions & total
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
    transferFrom(address(this),msg.sender, amountERC20ToSend);

    // msg.sender.transfer(amountEthToSend); // transfering eth

    bool sent = msg.sender.send(amountEthToSend);
    require(sent, "An error occured while sending");
    //transferFrom(address(this),msg.sender, amountEthToSend);//sketchy, not too sure of eth
    //return amt erc20 & eth sent
    return (amountERC20ToSend,amountEthToSend);
}

}
