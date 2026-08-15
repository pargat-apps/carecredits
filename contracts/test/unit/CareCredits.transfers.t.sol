// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {CareCredits} from "../../src/CareCredits.sol";
import {BaseTest} from "./BaseTest.t.sol";

/// @notice AC-13, AC-14, AC-15 — non-transferability. This is the property that
/// makes a stolen or overheard credit worthless to a scammer (P3).
contract CareCreditsTransfersTest is BaseTest {
    // AC-13 / FR-C-13, invariant 4. Failure here means a recipient could move
    // credits to any address — the single most important safety property lost.
    function test_Transfer_AlwaysReverts() public {
        // Arrange
        vm.prank(issuer);
        credits.issue(recipient, 300e18);

        // Act / Assert
        vm.expectRevert(CareCredits.TransfersDisabled.selector);
        vm.prank(recipient);
        credits.transfer(otherRecipient, 100e18);
    }

    // AC-14 / FR-C-14. Failure here means the same value-moving path is left open
    // via an allowance instead of a direct call — a classic and costly oversight.
    function test_TransferFrom_AlwaysReverts() public {
        // Arrange
        vm.prank(issuer);
        credits.issue(recipient, 300e18);

        // Act / Assert
        vm.expectRevert(CareCredits.TransfersDisabled.selector);
        vm.prank(stranger);
        credits.transferFrom(recipient, otherRecipient, 100e18);
    }

    // AC-15 / FR-C-15. Failure here means an allowance could be created even
    // though it can never be spent — a misleading, unusable UI surface.
    function test_Approve_AlwaysReverts() public {
        // Arrange / Act / Assert
        vm.expectRevert(CareCredits.ApprovalsDisabled.selector);
        vm.prank(recipient);
        credits.approve(stranger, 100e18);
    }
}
