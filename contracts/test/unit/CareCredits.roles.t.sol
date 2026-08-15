// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {BaseTest} from "./BaseTest.t.sol";

/// @notice AC-16, AC-17, AC-25, AC-26, AC-34 — role administration and separation
/// of duties (P4).
contract CareCreditsRolesTest is BaseTest {
    // AC-16 / FR-C-16 (grant half). Failure here means the admin cannot bring on
    // a new issuer without redeploying — role management would not actually work.
    function test_GrantRole_AdminCanGrantIssuerRole() public {
        // Arrange
        address newIssuer = makeAddr("newIssuer");

        // Act
        vm.prank(admin);
        credits.grantRole(credits.ISSUER_ROLE(), newIssuer);

        // Assert
        assertTrue(credits.hasRole(credits.ISSUER_ROLE(), newIssuer));
    }

    // AC-17 / FR-C-17. Failure here means any address could hand out roles,
    // collapsing DEFAULT_ADMIN_ROLE's exclusivity entirely.
    function test_GrantRole_RevertsWhen_CallerIsNotAdmin() public {
        // Arrange / Act / Assert
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, stranger, bytes32(0))
        );
        vm.prank(stranger);
        credits.grantRole(credits.ISSUER_ROLE(), stranger);
    }

    // AC-25 / FR-C-16 (revoke half). Failure here means a compromised or departing
    // issuer's key keeps working after the admin revokes it — revocation would be
    // theatre, not a real control.
    function test_RevokeRole_AdminCanRevokeIssuerRole() public {
        // Arrange — issuer already holds ISSUER_ROLE from setUp()
        assertTrue(credits.hasRole(credits.ISSUER_ROLE(), issuer));

        // Act
        vm.prank(admin);
        credits.revokeRole(credits.ISSUER_ROLE(), issuer);

        // Assert
        assertFalse(credits.hasRole(credits.ISSUER_ROLE(), issuer));
    }

    // AC-26 / FR-C-16 (PROVIDER_ROLE half). Failure here means the admin cannot
    // bring on a new provider without redeploying.
    function test_GrantRole_AdminCanGrantProviderRole() public {
        // Arrange
        address newProvider = makeAddr("newProvider");

        // Act
        vm.prank(admin);
        credits.grantRole(credits.PROVIDER_ROLE(), newProvider);

        // Assert
        assertTrue(credits.hasRole(credits.PROVIDER_ROLE(), newProvider));
    }

    // AC-34 / ARCH §6.3. Failure here means holding ISSUER_ROLE is enough to grant
    // roles too, letting a compromised issuer key escalate into an admin key.
    function test_GrantRole_RevertsWhen_CallerIsIssuer() public {
        // Arrange — issuer holds ISSUER_ROLE but not DEFAULT_ADMIN_ROLE

        // Act / Assert
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, issuer, bytes32(0))
        );
        vm.prank(issuer);
        credits.grantRole(credits.PROVIDER_ROLE(), issuer);
    }
}
