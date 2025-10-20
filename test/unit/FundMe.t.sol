//SPDX-Licence-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    //creating a fake user using foundry cheatcodes that will be sending our txns
    address USER = makeAddr("AHMED");
    uint constant GAS_PRICE = 5;

    function setUp() external {
        //   fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundme = new DeployFundMe();
        fundMe = deployFundme.run();
        vm.deal(USER, 56 ether);
    }

    function testMinimumIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgsender() view public {
       // console.log(address(this));
        //this test will fail because, in the setUp fxn, this contract deployed fundMe
        //therefore the address of this contract will be the msg.sender in fundMe, which then
        //makes it the i_owner()
        //while msg.sender here, is our own address i.e the address deploying this test contract.
        //assertEq(fundMe.i_owner(), msg.sender);

        //an appropriate test would be to check if fundme.i_owner == address(this)
        assertEq(fundMe.i_owner(), msg.sender);
    }

    //this test will fail because we're trying to reach out to a smart contract that is not deployed on our local chain.
    //For this test to pass we need to supply the rpc url of the testnet/mainnet where the pricefeed contract is deployed
    //so as to access the version() fxn of the pricefeed contract, by so doing, we have forked the testnet/mainnet chain.
    //we do this by passing a --fork-url <RPC_URL> flag when running the test command.
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        //  console.log(version);
        //console.log(address(fundMe));
        //console.log(address(this));
        assertEq(version, 4);
    }

    //To test that the fund() function fails when we didint call it with enough eth
    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); //expects the next line to fail for test to pass
        fundMe.fund();
    }

    //To test if the fund function actually updates the addressToAmount mapping after funding
    function testFundUpdatesFundedDataMapping() public {
        vm.prank(USER);//USER makes the next tnx
        // vm.expectRevert(); //expects the next line to fail for test to pass
        fundMe.fund{value: 5000000000000000000}();
        assertEq(fundMe.getAddressToAmountFunded(USER), 5000000000000000000);
    }

    function testFundUpdatesFundedDataMapping2() public {
        vm.prank(USER); //the next tx wiil be sent by USER
        fundMe.fund{value: 5000000000000000000}();

        assertEq(fundMe.getAddressToAmountFunded(USER), 5000000000000000000);
    }

    function testAddsFunderToArray() public {
        vm.prank(USER);
        fundMe.fund{value: 5 ether}();
        address funder = fundMe.getFunder(0);

        assertEq(funder, USER);
    }
     
     modifier funded() {
        vm.prank(USER);
        fundMe.fund{value : 5 ether}();
        _;
     }
    //NOTE: USER is not owner, so the test should fail if USER is trying to withdraw
    //msg.sender, which is the default account that calls the setup function is owner
    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }
    

    function testWithdrawWithAsingleFunder() public funded {
        //Arrange
       uint ownerStartingBalance = fundMe.getOwner().balance;
       uint fundMeStartingBalance = address(fundMe).balance;
        
       //Act
       vm.txGasPrice(GAS_PRICE);
       uint gasStart = gasleft();
       vm.prank(fundMe.getOwner());
       fundMe.withdraw();
       uint gasEnd = gasleft();
       uint gasSpent = (gasStart - gasEnd) * tx.gasprice;
       console.log("Gas spent is: ",gasSpent);
    

       
       //Assert
       uint ownerEndingBalance = fundMe.getOwner().balance;
       uint fundMeEndingBalance = address(fundMe).balance;
       assertEq(ownerStartingBalance + fundMeStartingBalance, ownerEndingBalance);
       assertEq(fundMeEndingBalance, 0);

        console.log(ownerStartingBalance);
        console.log(ownerEndingBalance);
        console.log(fundMeStartingBalance);
        console.log(fundMeEndingBalance);
    }

    //instead of creating a list and using vm.prank(address(i)) and vm.deal, we could use hoax(address(i), 5 ether), this is the same.
    function testWithdrawFromMultipleFunders() public {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        FundMe fund_Me = fundMe;
        
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            //vm.prank(funder[i]);
            //vm.deal();
            //funder funds fundME
            //funder withdraws
            address[10] memory funders;
          
            funders[i] = address(i);
            vm.deal(funders[i], 10 ether);
            vm.prank(funders[i]);
            fund_Me.fund{value : 5 ether}();
            console.log(funders[i]);
            console.log(funders[i].balance);
            
        }
        

        //Act
        vm.startPrank(fund_Me.getOwner());
        uint fundMeStartingBalance = address(fund_Me).balance;
        uint ownerStartingBalance = fund_Me.getOwner().balance;
        fund_Me.withdraw();
        uint fundMeEndingBalance = address(fund_Me).balance;
        uint ownerEndingBalance = fund_Me.getOwner().balance;
        vm.stopPrank();


        //Assert
         assert(ownerEndingBalance == ownerStartingBalance + fundMeStartingBalance);
         assert(fundMeEndingBalance == 0);
         //console.log(fundMeStartingBalance);
         //console.log(fundMeEndingBalance);
         //console.log(ownerStartingBalance);
         // console.log(ownerEndingBalance);

    }




    
}
