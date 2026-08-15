// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {CareCredits} from "../../src/CareCredits.sol";
import {BaseTest} from "./BaseTest.t.sol";

/// @notice AC-03, AC-22, AC-23, AC-24 — constructor validation and deploy-time state.
contract CareCreditsConstructorTest is BaseTest {
    // AC-03 / FR-C-03. Failure here means a fresh deployment starts with credits
    // already in circulation, which nobody issued.
    function test_Deploy_InitialSupplyIsZero() public view {
        // Arrange — deployed in setUp()

        // Act / Assert
        assertEq(credits.totalSupply(), 0);
    }

    // AC-22 / FR-C-22. Failure here means a deployment with no admin could succeed,
    // permanently locking every role behind an address nobody controls.
    function test_Constructor_RevertsWhen_AdminIsZeroAddress() public {
        // Arrange — a valid cap, so ERC20Capped's own check does not fire first
        // (constructor ordering trap: ERC20Capped(cap_) runs before the body)

        // Act / Assert
        vm.expectRevert(CareCredits.ZeroAddress.selector);
        new CareCredits(NAME, SYMBOL, CAP, address(0));
    }

    // AC-23 / FR-C-23. Failure here means a deployment with a zero cap could
    // succeed, producing a token that can never issue a single credit.
    function test_Constructor_RevertsWhen_CapIsZero() public {
        // Arrange / Act / Assert
        vm.expectRevert(abi.encodeWithSelector(ERC20Capped.ERC20InvalidCap.selector, 0));
        new CareCredits(NAME, SYMBOL, 0, admin);
    }

    // AC-24 / FR-C-24. Failure here means whoever runs the deploy script can mint
    // credits without ever being granted the role — the entire point of the role
    // system, silently defeated.
    function test_Deploy_DeployerHasNoIssuerRole() public view {
        // Arrange — this test contract is the deployer of `credits` (setUp calls `new`)

        // Act / Assert
        assertFalse(credits.hasRole(credits.ISSUER_ROLE(), address(this)));
    }
}
