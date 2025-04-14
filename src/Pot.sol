//SPDX-License-Identifier:MIT

pragma solidity 0.8.24;

import {IUniswapV3PoolActions} from "./interfaces/pool/IUniswapV3PoolActions.sol";
import {IUniswapV3PoolImmutables} from "./interfaces/pool/IUniswapV3PoolImmutables.sol";
import {IERC20} from "./interfaces/IERC20.sol";

contract Pot{

    error onlyOwnerCanCall();
    error Not_allowed();
    event Swap(int256 amount);
    address public owner;
    address poolcallback;
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    constructor(){
        owner = msg.sender;
    }

    /// @notice This contract must hold the tokens which will be swapped
    /// @param Pool address of the pool to swap
    /// @param zeroForOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amount The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param sqrtPriceLimitX96 The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
 
     function swap(address Pool, bool zeroForOne, uint256 amount, uint160 sqrtPriceLimitX96) external{
         
       if(msg.sender != owner) revert onlyOwnerCanCall();

        address token0 = IUniswapV3PoolImmutables(Pool).token0();
        address token1 = IUniswapV3PoolImmutables(Pool).token1();
        (int256 amount0,int256 amount1) = swapV3(Pool,zeroForOne, int256(amount), sqrtPriceLimitX96, zeroForOne?token0:token1);
        emit Swap(zeroForOne?amount1:amount0);

    }
    
    
    function swapV3(address pool,bool zeroForOne,int256 amountIn,uint160 sqrtPriceLimitX96,address token) private returns(int256 amount0,int256 amount1){
        poolcallback = pool;
        (amount0, amount1) = IUniswapV3PoolActions(pool).swap(
                address(this),
                zeroForOne,
                amountIn,
                (sqrtPriceLimitX96 == 0)
                ? (
                    zeroForOne 
                        ? MIN_SQRT_RATIO + 1
                        : MAX_SQRT_RATIO - 1
                )
                :sqrtPriceLimitX96,
                abi.encode(token));

        poolcallback = address(0);        
       

    }

    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external {
         address token = abi.decode(data, (address));

        if(msg.sender != poolcallback) revert Not_allowed();
        
        bool zeroForOne = (amount0Delta>0)?true:false;

        int256 amount = zeroForOne ? amount0Delta : amount1Delta;

        if(amount > 0) IERC20(token).transfer(msg.sender, uint256(amount));
 
    }

    ///@notice only owner can call. To transfer onwnership of this contract
    ///@param _newOwner address of the new owner
    function changeOwner(address _newOwner) external{
        if(msg.sender != owner) revert onlyOwnerCanCall();
        owner = _newOwner;
    }

    ///@notice only owner can call. To transfer tokens from this contract
    ///@param token address of the token to transfer
    ///@param amount amount of token to transfer
    ///@param to address of the recipient
    function transferAmount(address token,uint256 amount,address to) external {
        if(msg.sender != owner) revert onlyOwnerCanCall();
        IERC20(token).transfer(to,amount);
    }

    
    


}

