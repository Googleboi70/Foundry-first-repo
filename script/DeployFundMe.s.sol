//SPDX-Licence-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        //notice that we deployed helper config before writing vm.Broadcast
        //This is to save gas, coz anything before vm.Broadcast will be
        //run in a simulated environment and not sent as a real txn /
        HelperConfig helperConfig = new HelperConfig(); //here we deploy helper config
        (address priceFeed) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        // console.log(address(fundMe));
        //console.log(msg.sender);
        //console.log(tx.gasprice);
        //console.log(fundMe.getVersion());
        //console.log(address(helperConfig));
        // console.log(address(this));
        //console.log(msg.sender);
        return fundMe;
    }
}
