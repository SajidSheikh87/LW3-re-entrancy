// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {GoodContract} from "../src/GoodContract.sol";
import {BadContract} from "../src/BadContract.sol";

contract Attack is Test {
    // declare variables for instances of GoodContract and BadContract
    GoodContract goodContract;
    BadContract badContract;

    uint256 public constant STARTING_BALANCE_OF_USERS = 100 ether;

    // get two addresses; treat one as an innocent user and the other as an attacker
    // these addresses created by explicitly casting decimals  to addresss
    address innocentUser = address(1);
    address attacker = address(2);

    function setUp() public {
        // Deploy the Good Contract
        goodContract = new GoodContract();

        // Deploy the Bad Contract
        badContract = new BadContract(address(goodContract));

        // set the balances of the attacker and the innocent user to STARTING_BALANCE_OF_USERS ether
        vm.deal(attacker, STARTING_BALANCE_OF_USERS);
        vm.deal(innocentUser, STARTING_BALANCE_OF_USERS);
    }

    function testAttack() public {
        // First value to deposit (10 ETH)
        uint256 firstDeposit = 10 ether;

        // for sending the next call via innocent user's address
        // prank is a cheatcode in foundry that allows us to impersonate someone
        vm.prank(innocentUser);

        // Innocent User deposites 10 ETH into GoodContract
        goodContract.addBalance{value: firstDeposit}();

        // Check that at this point the GoodContract's balance is 10 ETH
        assertEq(address(goodContract).balance, firstDeposit);

        // for sending the next call via attacker's address
        vm.prank(attacker);
        badContract.attack{value: 1 ether}();

        // Balaance of the GoodContract's address is now zero
        assertEq(address(goodContract).balance, 0);

        //Balance of BadContract is now 11 ETH (10 Eth stolen + 1 ETH from the attacker)
        assertEq(address(badContract).balance, 11 ether);
    }
}
