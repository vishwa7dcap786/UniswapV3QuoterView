// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Quoter} from "../src/Quoter.sol";

contract CounterScript is Script {
   
    
    function setUp() public {}

     function run() public {


        deploy();
        //getQuotes(qouterAddress, pool, zeroForOne, amount)

    }

    function deploy() internal {
        vm.startBroadcast();

        Quoter quoter = new Quoter();
        console.log(address(quoter));

        vm.stopBroadcast();
    }

    function getQuotes(
        address qouterAddress, 
        address pool,
        bool zeroForOne,
        int256 amount)
    internal view{

        Quoter quoter = Quoter(qouterAddress);

        (int256 amount0, int256 amount1)= quoter.swap(pool,zeroForOne, amount);
        if(amount0<0){
            amount0 = -amount0;
        }else{
            amount1 = -amount1;
        }
        console.log(uint256(amount0),uint256(amount1));
    }
}