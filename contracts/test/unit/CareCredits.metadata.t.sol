// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {BaseTest} from "./BaseTest.t.sol";

/// @notice AC-01, AC-02, AC-21 — identity, cap immutability, remaining issuable.
contract CareCreditsMetadataTest is BaseTest {
    // AC-01 / FR-C-01. Failure here means the deploy script's name/symbol arguments
    // are not what the family and provider apps display to users.
    function test_Metadata_ReturnsCorrectValues() public view {
        // Arrange — deployed in setUp() with NAME/SYMBOL constants

        // Act / Assert
        assertEq(credits.name(), NAME);
        assertEq(credits.symbol(), SYMBOL);
        assertEq(credits.decimals(), 18);
    }

    // AC-02 / FR-C-02. Failure here means the cap could drift after deployment,
    // breaking the core promise that total outstanding liability is bounded.
    function test_Cap_IsImmutableAfterDeployment() public {
        // Arrange
        assertEq(credits.cap(), CAP);

        // Act — a state-changing operation elsewhere must not move the cap
        vm.prank(issuer);
        credits.issue(recipient, 1_000e18);

        // Assert
        assertEq(credits.cap(), CAP);
    }

    // AC-21 / FR-C-21. Failure here means the family app's "how much more can be
    // issued" read is wrong, silently, since it is never checked against totalSupply.
    function test_RemainingIssuable_ReturnsCapMinusSupply() public {
        // Arrange
        assertEq(credits.remainingIssuable(), CAP);
        uint256 amount = 4_000_000e18;

        // Act
        vm.prank(issuer);
        credits.issue(recipient, amount);

        // Assert
        assertEq(credits.remainingIssuable(), CAP - amount);
    }
}
