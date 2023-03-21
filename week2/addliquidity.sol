pragma solidity ^0.8.0;
interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function mint(address to) external returns (uint liquidity);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
}
/**
 * @title zero2hero homework
 * @dev erc20 token
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}



interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);

}

contract LiquidityAdder {
    address public tokenA;
    address public tokenB;
    address public liquidityPair;
    address public owner;

    constructor(address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        owner = msg.sender;

        // Create liquidity pair
        address factory = 0x6725F303b657a9451d8BA641348b6761A6CC7a17; // PancakeSwap factory address
        liquidityPair = IUniswapV2Factory(factory).createPair(tokenA, tokenB);
        IERC20(tokenA).approve(liquidityPair, type(uint).max);
        IERC20(tokenB).approve(liquidityPair, type(uint).max);
    }

    function addLiquidity(uint amountA, uint amountB) public {
        require(msg.sender == owner, "Only the owner can add liquidity");
        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");

        // Add liquidity to the pair
        uint liquidity;
        IUniswapV2Pair pair = IUniswapV2Pair(liquidityPair);
        (uint reserveA, uint reserveB, ) = pair.getReserves();
        uint amountBOptimal = (amountA * reserveB) / reserveA;
        liquidity = pair.mint(address(this));
        require(IERC20(tokenA).transferFrom(msg.sender, address(pair), amountA), "Transfer of tokenA failed");
        require(IERC20(tokenB).transferFrom(msg.sender, address(pair), amountBOptimal), "Transfer of tokenB failed");
        require(pair.transfer(msg.sender, liquidity), "Transfer of liquidity failed");
    }

    function retrieveTokens(address token, uint amount) public {
        require(msg.sender == owner, "Only the owner can retrieve tokens");
        IERC20(token).transfer(msg.sender, amount);
    }
}
