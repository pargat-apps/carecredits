// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {CareCredits} from "../../src/CareCredits.sol";
import {BaseTest} from "./BaseTest.t.sol";

/// @notice AC-09..12, AC-20, AC-27..31, AC-37 — redemption.
contract CareCreditsRedeemTest is BaseTest {
    bytes32 internal constant SERVICE_REF = keccak256("booking-1");

    function _issue(address to, uint256 amount) internal {
        vm.prank(issuer);
        credits.issue(to, amount);
    }

    // AC-09 / FR-C-09. Failure here means a completed service never actually
    // consumes the recipient's balance — services would be free forever.
    function test_Redeem_BurnsCreditsFromHolder() public {
        // Arrange
        _issue(recipient, 300e18);

        // Act
        vm.prank(provider);
        credits.redeem(recipient, 250e18, SERVICE_REF);

        // Assert
        assertEq(credits.balanceOf(recipient), 50e18);
    }

    // AC-10 / FR-C-10, INV-2. Failure here means a provider could burn more than
    // a recipient holds, which would make total supply diverge from real balances.
    function test_Redeem_RevertsWhen_AmountExceedsBalance() public {
        // Arrange
        _issue(recipient, 100e18);

        // Act / Assert
        vm.expectRevert(abi.encodeWithSelector(CareCredits.InsufficientCredits.selector, 100e18, 250e18));
        vm.prank(provider);
        credits.redeem(recipient, 250e18, SERVICE_REF);
    }

    // AC-11 / FR-C-11. Failure here means anyone, not just PROVIDER_ROLE, can burn
    // a recipient's credits — the single scariest possible bug in this contract.
    function test_Redeem_RevertsWhen_CallerLacksProviderRole() public {
        // Arrange
        _issue(recipient, 100e18);

        // Act / Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, stranger, credits.PROVIDER_ROLE()
            )
        );
        vm.prank(stranger);
        credits.redeem(recipient, 50e18, SERVICE_REF);
    }

    // AC-12 / FR-C-12, INV-1, INV-2. Failure here means redemption moves the
    // holder's balance without moving total supply, or vice versa — the two must
    // fall together by exactly the redeemed amount.
    function test_Redeem_ReducesBalanceAndTotalSupply() public {
        // Arrange
        _issue(recipient, 300e18);
        uint256 supplyBefore = credits.totalSupply();

        // Act
        vm.prank(provider);
        credits.redeem(recipient, 250e18, SERVICE_REF);

        // Assert
        assertEq(credits.balanceOf(recipient), 50e18);
        assertEq(credits.totalSupply(), supplyBefore - 250e18);
    }

    // AC-20 / FR-C-20. Failure here means the recipient's activity feed and the
    // off-chain booking reconciliation both lose their only on-chain record.
    function test_Redeem_EmitsCreditsRedeemed() public {
        // Arrange
        _issue(recipient, 300e18);

        // Act / Assert
        vm.expectEmit(true, true, false, true);
        emit CareCredits.CreditsRedeemed(recipient, 250e18, SERVICE_REF, provider);
        vm.prank(provider);
        credits.redeem(recipient, 250e18, SERVICE_REF);
    }

    // AC-27 / D-6. Failure here means a redemption with no booking reference could
    // succeed, leaving a burn nobody can trace to an actual service.
    function test_Redeem_RevertsWhen_ServiceRefIsZero() public {
        // Arrange
        _issue(recipient, 100e18);

        // Act / Assert
        vm.expectRevert(CareCredits.InvalidServiceRef.selector);
        vm.prank(provider);
        credits.redeem(recipient, 50e18, bytes32(0));
    }

    // AC-28 / D-7. Failure here means the frontend cannot decode a plain sentence
    // ("That service needs 250 credits, Mom has 120") because the error carries
    // the wrong, or no, data.
    function test_Redeem_InsufficientCreditsReportsBalanceAndRequired() public {
        // Arrange
        _issue(recipient, 120e18);

        // Act / Assert
        vm.expectRevert(abi.encodeWithSelector(CareCredits.InsufficientCredits.selector, 120e18, 250e18));
        vm.prank(provider);
        credits.redeem(recipient, 250e18, SERVICE_REF);
    }

    // AC-29 / D-8. Failure here means a redemption against the zero address could
    // succeed or misbehave instead of cleanly rejecting an impossible holder.
    function test_Redeem_RevertsWhen_HolderIsZeroAddress() public {
        // Arrange / Act / Assert
        vm.expectRevert(CareCredits.ZeroAddress.selector);
        vm.prank(provider);
        credits.redeem(address(0), 50e18, SERVICE_REF);
    }

    // AC-30 / D-8. Failure here means a no-op redemption could succeed and emit a
    // misleading CreditsRedeemed event with no real value burned.
    function test_Redeem_RevertsWhen_AmountIsZero() public {
        // Arrange
        _issue(recipient, 100e18);

        // Act / Assert
        vm.expectRevert(CareCredits.ZeroAmount.selector);
        vm.prank(provider);
        credits.redeem(recipient, 0, SERVICE_REF);
    }

    // AC-31 / D-3. Failure here means an over-redemption attempt could still burn
    // part of the balance before reverting — partial redemption is explicitly
    // disallowed, so the holder's balance must be untouched.
    function test_Redeem_LeavesBalanceUnchangedWhen_AmountExceedsBalance() public {
        // Arrange
        _issue(recipient, 100e18);

        // Act
        vm.expectRevert(abi.encodeWithSelector(CareCredits.InsufficientCredits.selector, 100e18, 250e18));
        vm.prank(provider);
        credits.redeem(recipient, 250e18, SERVICE_REF);

        // Assert
        assertEq(credits.balanceOf(recipient), 100e18);
    }

    // AC-37 / ARCH §6.4. Failure here means indexers and wallets that watch the
    // standard Transfer event never see a redemption, even though CreditsRedeemed
    // did.
    function test_Redeem_EmitsTransferToZeroAddress() public {
        // Arrange
        _issue(recipient, 300e18);

        // Act / Assert
        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(recipient, address(0), 250e18);
        vm.prank(provider);
        credits.redeem(recipient, 250e18, SERVICE_REF);
    }
}
