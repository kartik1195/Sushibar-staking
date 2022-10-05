// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// SushiBar is the coolest bar in town. You come in with some Sushi, and leave with more! The longer you stay, the more Sushi you get.
//
// This contract handles swapping to and from xSushi, SushiSwap's staking token.

contract Sushibar is ERC20("SushiBar", "xSUSHI"){
    using SafeMath for uint256;
    IERC20 public sushi;
    uint256 constant DAY = 60; // seconds in day
    struct Stake{
        uint256 amount;
        uint256 since;
        uint256 leftAmount;
    }
    struct StakeSummary{
        uint256 total_amount;
        Stake[] stakes;
    }

    mapping(address => uint256) internal stakes;
    Stake[] internal stake;
    mapping(address => Stake[]) internal stakers;

    event Unstaked(address indexed user, uint256 amount,uint256 tax, uint256 index, uint256 timestamp);
    event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);
    
    // Define the Sushi token contract
    constructor(IERC20 _sushi) {
        sushi = _sushi;
    }

    // Enter the bar. Pay some SUSHIs. Earn some shares.
    // Locks Sushi and mints xSushi
    function enter(uint256 _amount) public {
        // Gets the amount of Sushi locked in the contract
        uint256 totalSushi = sushi.balanceOf(address(this));
        // Gets the amount of xSushi in existence
        uint256 totalShares = totalSupply();
        // If no xSushi exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalSushi == 0) {
            _mint(msg.sender, _amount);
        } 
        // Calculate and mint the amount of xSushi the Sushi is worth. The ratio will change overtime, as xSushi is burned/minted and Sushi deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalSushi);
            _mint(msg.sender, what);
        }
        uint256 timestamp = block.timestamp;
        stakers[msg.sender].push(Stake(_amount,timestamp,_amount));
        // Lock the Sushi in the contract
        sushi.transferFrom(msg.sender, address(this), _amount);
        uint256 index=stakers[msg.sender].length-1;
        emit Staked(msg.sender, _amount, index,timestamp);
    }

    // Leave the bar. Claim back your SUSHIs.
    // Unlocks the staked + gained Sushi and burns xSushi
    function leave(uint256 _share,uint8 index) public {
        require(stakers[msg.sender].length-1>=index,"Stake not exist.");
        require(stakers[msg.sender][index].leftAmount>=_share,"Amount is not valid.");

        uint256 timestamp = block.timestamp;
        require(stakers[msg.sender][index].since+(DAY*2)<=timestamp,"You are not able to unstake due to limit period.");
        uint256 unstake=0;
        uint256 tax=0;

        if(stakers[msg.sender][index].since+(DAY*4)>=timestamp){
            unstake=((stakers[msg.sender][index].amount*25)/100); // 25%
            tax=75;
        }else if(stakers[msg.sender][index].since+(DAY*6)>=timestamp){
            unstake=((stakers[msg.sender][index].amount*50)/100); // 50%
            tax=50;
        }
        else if(stakers[msg.sender][index].since+(DAY*8)>=timestamp){
            unstake=((stakers[msg.sender][index].amount*75)/100); // 75%
            tax=25;
        }else{
            unstake=stakers[msg.sender][index].amount;
        }
        uint256 leftAmt=stakers[msg.sender][index].amount - stakers[msg.sender][index].leftAmount;
        require((leftAmt + _share)<=unstake,string.concat("You can unstake max : ",Strings.toString(unstake-leftAmt)));
        
        // Gets the amount of xSushi in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of Sushi the xSushi is worth
        uint256 what = _share.mul(sushi.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, _share);

        tax=((what*tax)/100);
        what-=tax;
        sushi.transfer(msg.sender, what);
        // transfer to shushi pool
        if(tax>0){
            sushi.transfer(address(this), tax);
        }
        stakers[msg.sender][index].leftAmount-=_share;
        emit Unstaked(msg.sender, what, index, tax, timestamp);
    }

    function hasStake(address _staker) public view returns(StakeSummary memory){
        StakeSummary memory summary = StakeSummary(0, stakers[_staker]);
        return summary;
    }
}