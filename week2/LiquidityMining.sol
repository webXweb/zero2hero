pragma solidity ^0.8.0;
/**
 * @title zero2hero homework
 * @dev erc20 token
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract LiquidityMining {
    address public token;
    address public liquidityPair;
    address public owner;
    uint public totalRewards;
    uint public rewardRate;
    uint public startTime;
    mapping(address => uint) public rewards;
    mapping(address => uint) public lastUpdate;

    constructor(address _token, address _liquidityPair, uint _totalRewards, uint _duration) {
        token = _token;
        liquidityPair = _liquidityPair;
        owner = msg.sender;
        totalRewards = _totalRewards;
        rewardRate = totalRewards / _duration;
        startTime = block.timestamp;
        IERC20(token).approve(liquidityPair, type(uint).max);
    }

    function claimReward() public {
        uint earned = calculateReward(msg.sender);
        require(earned > 0, "No rewards to claim");
        rewards[msg.sender] += earned;
        lastUpdate[msg.sender] = block.timestamp;
        require(IERC20(token).transferFrom(liquidityPair, msg.sender, earned), "Reward transfer failed");
    }

    function calculateReward(address account) public view returns (uint) {
        uint timeElapsed = block.timestamp - startTime;
        uint accountBalance = IERC20(liquidityPair).balanceOf(account);
        uint totalSupply = IERC20(liquidityPair).totalSupply();
        uint rewardEarned = accountBalance * timeElapsed * rewardRate / totalSupply;
        return rewardEarned - rewards[account];
    }

    function endMining() public {
        require(msg.sender == owner, "Only the owner can end mining");
        uint remainingRewards = IERC20(token).balanceOf(liquidityPair);
        require(IERC20(token).transferFrom(liquidityPair, owner, remainingRewards), "Reward transfer failed");
        
    }
}
