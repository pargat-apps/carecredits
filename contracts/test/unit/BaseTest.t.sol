// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {CareCredits} from "../../src/CareCredits.sol";

/// @notice Shared setup for every CareCredits unit test file.
/// @dev Every function on CareCredits is a stub — see specs/04-tests-first.md.
/// The constructor unconditionally reverts NotImplemented(), so deployment below
/// always fails and every test in every file that extends this contract fails at
/// setUp() with NotImplemented(). That is the correct outcome for this session.
abstract contract BaseTest is Test {
    CareCredits internal credits;

    string internal constant NAME = "CareCredits";
    string internal constant SYMBOL = "CCRD";
    uint256 internal constant CAP = 100_000_000e18;

    address internal admin;
    address internal issuer;
    address internal provider;
    address internal recipient;
    address internal otherRecipient;
    address internal stranger;

    function setUp() public virtual {
        admin = makeAddr("admin");
        issuer = makeAddr("issuer");
        provider = makeAddr("provider");
        recipient = makeAddr("recipient");
        otherRecipient = makeAddr("otherRecipient");
        stranger = makeAddr("stranger");

        credits = new CareCredits(NAME, SYMBOL, CAP, admin);

        vm.startPrank(admin);
        credits.grantRole(credits.ISSUER_ROLE(), issuer);
        credits.grantRole(credits.PROVIDER_ROLE(), provider);
        vm.stopPrank();
    }
}
