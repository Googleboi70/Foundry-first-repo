//SPDX-License-Identifier: MIT

//1. Deploy mocks when we are on a local anvil chain
//2. Keep track of contract addresses across different chains
//3. Put this in a script that we can run via `forge script`

pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/mockV3Aggregator.sol";
//import {FundMe} from "../src/FundMe.sol";

contract HelperConfig is Script {
    //if we are on a local chain, we deploy mocks
    //otherwise, we grab the existing address from the live network
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2e8;

    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = createAndGetAnvilEthConfig();
        }
    }
    //Note that we could have made this fxn reurn an address type since we just need the address of the price feed
    //but instead we made this function return a struct object
    //This is because, incase we need to get more than just an address, me might need other to get other data types too
    //like uint, string or more than one address.

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethConfig;
    }

    function createAndGetAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        //Deploys the mock
        //Returns the mock's address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER); //deploy mock pricefeed
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});

        return anvilConfig;
    }
}
