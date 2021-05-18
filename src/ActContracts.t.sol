pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./ActContracts.sol";

contract ActContractsTest is DSTest {
    ActContracts contracts;

    function setUp() public {
        contracts = new ActContracts();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
