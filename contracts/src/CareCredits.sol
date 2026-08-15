// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title CareCredits
/// @notice Capped, non-transferable ERC-20 credit token. Issued by ISSUER_ROLE,
/// redeemed by PROVIDER_ROLE against an off-chain service reference.
/// @dev STUB — every function body reverts NotImplemented(). See specs/04-tests-first.md.
contract CareCredits is ERC20Capped, AccessControl {
    error ZeroAddress();
    error ZeroAmount();
    error TransfersDisabled();
    error ApprovalsDisabled();
    error InsufficientCredits(uint256 balance, uint256 required);
    error InvalidServiceRef();
    error NotImplemented();

    event CreditsIssued(address indexed to, uint256 amount, address indexed issuer);
    event CreditsRedeemed(address indexed from, uint256 amount, bytes32 indexed serviceRef, address provider);

    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");
    bytes32 public constant PROVIDER_ROLE = keccak256("PROVIDER_ROLE");

    constructor(string memory name_, string memory symbol_, uint256 cap_, address admin)
        ERC20(name_, symbol_)
        ERC20Capped(cap_)
    {
        _stub();
    }

    /// @dev Solc (0.8.25, error 1284) cannot prove the ERC20Capped immutable `cap` is
    /// assigned when the derived constructor body is a bare `revert`. Routing through
    /// a call sidesteps the false positive without changing observable behaviour —
    /// construction still always reverts with NotImplemented().
    function _stub() private pure {
        revert NotImplemented();
    }

    /// @notice Issue new credits to a recipient.
    /// @param to Recipient address.
    /// @param amount Amount to issue, in 18-decimal units.
    function issue(address to, uint256 amount) external onlyRole(ISSUER_ROLE) {
        revert NotImplemented();
    }

    /// @notice Burn credits from a holder's balance for a completed service.
    /// @param from Holder address.
    /// @param amount Amount to redeem, in 18-decimal units.
    /// @param serviceRef Non-zero pointer to the off-chain booking.
    function redeem(address from, uint256 amount, bytes32 serviceRef) external onlyRole(PROVIDER_ROLE) {
        revert NotImplemented();
    }

    /// @notice Credits that can still be issued before the cap is reached.
    function remainingIssuable() external view returns (uint256) {
        revert NotImplemented();
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        revert NotImplemented();
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        revert NotImplemented();
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        revert NotImplemented();
    }

    function _update(address from, address to, uint256 value) internal override(ERC20Capped) {
        revert NotImplemented();
    }
}
