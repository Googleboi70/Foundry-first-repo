//SPDX-Licence-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    //creating a fake user using foundry cheatcodes that will be sending our txns
    address USER = makeAddr("AHMED");
    

    function setUp() external {
        //   fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundme = new DeployFundMe();
        fundMe = deployFundme.run();
        vm.deal(USER, 56 ether);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundfundMe = new FundFundMe();
       // vm.prank(USER);
        //vm.deal(USER, 5 ether);
        fundfundMe.fundFundMe(address(fundMe));
        
        address funder = fundMe.getFunder(0);
        assertEq(funder, msg.sender);
        
        WithdrawFundMe withdrawfundMe = new WithdrawFundMe();
        withdrawfundMe.withdrawFundMe(address(fundMe));
        assert(address(fundMe).balance == 0);
    }


}
