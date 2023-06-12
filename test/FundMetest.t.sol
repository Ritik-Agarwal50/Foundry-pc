// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("USER");
    uint256 public constant SEND_VALUE = 0.5 ether;
    //uint256 public constant GAS_PRICE = 1

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf
        // 1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 20e18);
    }

    //Modifier
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 1e18}();
        _;
    }

    //Tests
    function testMinimumDollarFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerMsgSender() public {
        //console.log("fundMe.i_owner(): %s", fundMe.i_owner());
        //console.log("msg.sender: %s", msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFails() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdate() public funded {
        // vm.prank(USER);
        // fundMe.fund{value: 1e18}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 1e18);
    }

    function testAddFunderToArray() public funded {
        // vm.prank(USER);
        // fundMe.fund{value: 1e18}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerWithdraw() public funded {
        // vm.prank(USER);
        // fundMe.fund{value: 1e18}();
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdraw() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //Assert
        uint endingOwnerBalance = fundMe.getOwner().balance;
        uint endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMulitpleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        //ACT
        // uint gasStart = gasleft();
        // vm.txgasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // uint gasEnd = gasleft();
        // uint gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log("gasUsed: %s", gasUsed);

        //Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
