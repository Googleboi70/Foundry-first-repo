//SPDX-License-Identifier: MIT
//This contract allows us interact with our fundMe contract
//We are gonna have a fund script and a withdraw script
pragma solidity ^0.8.19;
import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";


//script for funding fundMe
contract FundFundMe is Script{

    function fundFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).fund{value : 5 ether}();
        vm.stopBroadcast();
        console.log("Funded fundMe with value");
        
    } 
    function run() external {
        //looks into the broadcast folder qnd grabs latest deployed contract based on chainid and given name
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentDeployed);
        vm.stopBroadcast();
    }
}

//script for withdrawing from fundMe
contract WithdrawFundMe is Script{
    function withdrawFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).withdraw();
        vm.stopBroadcast();

    } 
    function run() external {
        //looks into the broadcast folder qnd grabs latest deployed contract based on chainid and given name
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostRecentDeployed);
        vm.stopBroadcast();
    }
}