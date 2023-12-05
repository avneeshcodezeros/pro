// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../src/propertyMarketplace.sol";
import "./mocks/MockERC20.sol";
import "./mocks/MockERC20copy.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/forge-std/src/console.sol";

interface Vm {
    function startPrank(address msgSender) external;
    function startPrank(address msgSender, address txOrigin) external;
    function stopPrank() external;
}

contract test is DSTest {
    // StdCheats cheats = StdCheats(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    propertyMarketplace public PropertyMarketplace;
    MockERC20 public token;
    uint256 public Amt = 100;
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    usdt public Usdt;
    address Sender;
    // address User1 = address(0xa);
    // address User2 = address(0xb);

    function setUp() public returns (address) {
        vm.startPrank(address(1));
        token = new MockERC20();
        Usdt = new usdt();
        // token1 = address(Usdt);
        PropertyMarketplace = new propertyMarketplace("asdf", "asdf", address(Usdt));
        vm.stopPrank();
        return msg.sender;
    }

    function testListing() public {
        vm.startPrank(address(1), tx.origin);
        (address tokenAddress, uint256 userCount) = PropertyMarketplace.listProperty("Niwaas", 1000, "NW");
        uint256 user = PropertyMarketplace.users();
        propertyMarketplace.property memory storedStruct = PropertyMarketplace.Property1(1);
        uint256 balance = token.balanceOf(address(1));
        uint256 numOfProperties = PropertyMarketplace.numOfPropertiesOfUser(address(1));
        address nft = address(PropertyMarketplace.nftMarket());
        uint256 nftCount = ERC721(nft).balanceOf(address(1));
        assertEq(user, userCount);
        assertEq(storedStruct.token, tokenAddress, "token address not set correctly");
        assertEq(storedStruct.owner, address(1), "owner not set correctly");
        assertEq(storedStruct.propertyCost, 1000, "property cost not set correctly");
        assertEq(storedStruct.numOfinvestors, 0, "number of investors not set correctly");
        assertEq(numOfProperties, 1, "user has no properties listed"); //1000000000000000000000000
        assertEq(balance, 1000, "property tokenbalance is incorrect");
        assertGe(nftCount, 1, "no nft found");
        vm.stopPrank();
    }

    function testInitiateInvestment() public {
        vm.startPrank(address(1), tx.origin);
        Usdt.approve(address(PropertyMarketplace), 10000);
        (address token2, uint256 investorId, uint256 amount, bool success) =
            PropertyMarketplace.InitiateInvestment(1, 50);
        uint256 Contractbalance = Usdt.balanceOf(address(PropertyMarketplace));
        token.approve(address(PropertyMarketplace), 10000);
        assertEq(investorId, 1, "investorId is not same");
        assertEq(amount, 50, "amount is incorrect");
        assertEq(Contractbalance, 50, "contract balance is incorrect");
        assertTrue(success, "transfer of tokens from user to contract failed");
        assertEq(token2, address(Usdt), "tokens for investing are not same");
        assertEq(Contractbalance, 50, "contract balance and amount invested did not match");
        // propertyMarketplace.investor memory storedStruct = PropertyMarketplace.Investor(investorId);
    }

    function testtransferFundsToInvestor() public {
        vm.startPrank(address(1));
        Usdt.approve(address(PropertyMarketplace), 10000);
        token.approve(address(PropertyMarketplace), 10000);
        (address tokenAddress, uint256 userCount) = PropertyMarketplace.listProperty("Niwaas", 1000, "NW");
        (address token2, uint256 investorId, uint256 amount1, bool success1) =
            PropertyMarketplace.InitiateInvestment(1, 50);
        propertyMarketplace.property memory storedStruct = PropertyMarketplace.Property1(1);
        address propertyToken = storedStruct.token;
        ERC20(propertyToken).approve(address(PropertyMarketplace), 1000);
        (uint256 amt, bool success, address sender) = PropertyMarketplace.transferFundsToInvestors(address(1), 1);
        uint256 amount = token.balanceOf(address(1));
        uint256 count = PropertyMarketplace.numOfPropertiesOfUser(address(1));
        uint256 contractBalance = ERC20(Usdt).balanceOf(address(PropertyMarketplace));
        assertEq(amount, 1000, "balance of user not equal ");
        assertTrue(success);
        assertEq(count, 1);
        assertEq(contractBalance, 0, "contract balance should be zero in the end");
        vm.stopPrank();
    }
}
