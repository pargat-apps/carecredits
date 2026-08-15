// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {CareCredits} from "../../src/CareCredits.sol";
import {BaseTest} from "./BaseTest.t.sol";

/// @notice AC-04..08, AC-18, AC-19, AC-32, AC-33, AC-35, AC-36 — issuance.
contract CareCreditsIssueTest is BaseTest {
    // AC-04 / FR-C-04. Failure here means funders' payments never reach the
    // recipient's balance — the core "money in, help available" promise breaks.
    function test_Issue_MintsCreditsToRecipient() public {
        // Arrange
        uint256 amount = 300e18;

        // Act
        vm.prank(issuer);
        credits.issue(recipient, amount);

        // Assert
        assertEq(credits.balanceOf(recipient), amount);
        assertEq(credits.totalSupply(), amount);
    }

    // AC-05 / FR-C-05, INV-1. Failure here means the cap is not a real limit —
    // the operator's core solvency control (BR-10) is unenforced.
    function test_Issue_RevertsWhen_AmountExceedsCap() public {
        // Arrange
        uint256 amount = CAP + 1;

        // Act / Assert
        vm.expectRevert(abi.encodeWithSelector(ERC20Capped.ERC20ExceededCap.selector, amount, CAP));
        vm.prank(issuer);
        credits.issue(recipient, amount);
    }

    // AC-06 / FR-C-06. Failure here means anyone, not just ISSUER_ROLE, can create
    // credits out of thin air.
    function test_Issue_RevertsWhen_CallerLacksIssuerRole() public {
        // Arrange / Act / Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, stranger, credits.ISSUER_ROLE()
            )
        );
        vm.prank(stranger);
        credits.issue(recipient, 100e18);
    }

    // AC-07 / FR-C-07. Failure here means credits could be minted to the zero
    // address and become permanently unreachable, silently shrinking real supply.
    function test_Issue_RevertsWhen_RecipientIsZeroAddress() public {
        // Arrange / Act / Assert
        vm.expectRevert(CareCredits.ZeroAddress.selector);
        vm.prank(issuer);
        credits.issue(address(0), 100e18);
    }

    // AC-08 / FR-C-08. Failure here means a no-op issuance could succeed and emit
    // a misleading event with no real value transferred.
    function test_Issue_RevertsWhen_AmountIsZero() public {
        // Arrange / Act / Assert
        vm.expectRevert(CareCredits.ZeroAmount.selector);
        vm.prank(issuer);
        credits.issue(recipient, 0);
    }

    // AC-18 / FR-C-18. Failure here means revoking a compromised issuer's role
    // does not actually stop them from minting — role revocation would be theatre.
    function test_Issue_RevertsAfter_IssuerRoleRevoked() public {
        // Arrange
        bytes32 role = credits.ISSUER_ROLE();
        vm.prank(admin);
        credits.revokeRole(role, issuer);

        // Act / Assert
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, issuer, role));
        vm.prank(issuer);
        credits.issue(recipient, 100e18);
    }

    // AC-19 / FR-C-19. Failure here means the family app's activity feed and audit
    // trail miss issuance events, since the feed is built entirely from logs.
    function test_Issue_EmitsCreditsIssued() public {
        // Arrange
        uint256 amount = 300e18;

        // Act / Assert
        vm.expectEmit(true, true, false, true);
        emit CareCredits.CreditsIssued(recipient, amount, issuer);
        vm.prank(issuer);
        credits.issue(recipient, amount);
    }

    // AC-32 / D-4. Failure here means one recipient's balance leaks into or
    // depends on another's — balances must be fully independent per address.
    function test_Issue_MintsToMultipleRecipientsIndependently() public {
        // Arrange
        uint256 amountA = 300e18;
        uint256 amountB = 500e18;

        // Act
        vm.startPrank(issuer);
        credits.issue(recipient, amountA);
        credits.issue(otherRecipient, amountB);
        vm.stopPrank();

        // Assert
        assertEq(credits.balanceOf(recipient), amountA);
        assertEq(credits.balanceOf(otherRecipient), amountB);
        assertEq(credits.totalSupply(), amountA + amountB);
    }

    // AC-33 / ARCH §6.3. Failure here means holding DEFAULT_ADMIN_ROLE alone is
    // enough to mint, collapsing the separation between admin and issuer duties.
    function test_Issue_RevertsWhen_CallerIsAdminWithoutIssuerRole() public {
        // Arrange — admin never granted itself ISSUER_ROLE in setUp()

        // Act / Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, admin, credits.ISSUER_ROLE()
            )
        );
        vm.prank(admin);
        credits.issue(recipient, 100e18);
    }

    // AC-35 / ARCH §6.5. Failure here means the cap boundary is off by one in
    // either direction — the last issuable credit must succeed, not revert.
    function test_Issue_SucceedsWhen_AmountEqualsRemainingCap() public {
        // Arrange
        uint256 amount = credits.remainingIssuable();

        // Act
        vm.prank(issuer);
        credits.issue(recipient, amount);

        // Assert
        assertEq(credits.totalSupply(), CAP);
        assertEq(credits.remainingIssuable(), 0);
    }

    // AC-36 / ARCH §6.4. Failure here means indexers and wallets that watch the
    // standard Transfer event never see an issuance, even though CreditsIssued did.
    function test_Issue_EmitsTransferFromZeroAddress() public {
        // Arrange
        uint256 amount = 300e18;

        // Act / Assert
        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(address(0), recipient, amount);
        vm.prank(issuer);
        credits.issue(recipient, amount);
    }
}
