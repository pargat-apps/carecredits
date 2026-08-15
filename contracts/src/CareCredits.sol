// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title CareCredits
/// @notice Capped, non-transferable ERC-20 credit token. Issued by ISSUER_ROLE,
/// redeemed by PROVIDER_ROLE against an off-chain service reference.
contract CareCredits is ERC20Capped, AccessControl {
    error ZeroAddress();
    error ZeroAmount();
    error TransfersDisabled();
    error ApprovalsDisabled();
    error InsufficientCredits(uint256 balance, uint256 required);
    error InvalidServiceRef();

    event CreditsIssued(address indexed to, uint256 amount, address indexed issuer);
    event CreditsRedeemed(address indexed from, uint256 amount, bytes32 indexed serviceRef, address provider);

    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");
    bytes32 public constant PROVIDER_ROLE = keccak256("PROVIDER_ROLE");

    constructor(string memory name_, string memory symbol_, uint256 cap_, address admin)
        ERC20(name_, symbol_)
        ERC20Capped(cap_)
    {
        if (admin == address(0)) revert ZeroAddress();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /// @notice Issue new credits to a recipient.
    /// @param to Recipient address.
    /// @param amount Amount to issue, in 18-decimal units.
    function issue(address to, uint256 amount) external onlyRole(ISSUER_ROLE) {
        if (to == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        _mint(to, amount);
        emit CreditsIssued(to, amount, msg.sender);
    }

    /// @notice Burn credits from a holder's balance for a completed service.
    /// @param from Holder address.
    /// @param amount Amount to redeem, in 18-decimal units.
    /// @param serviceRef Non-zero pointer to the off-chain booking.
    function redeem(address from, uint256 amount, bytes32 serviceRef) external onlyRole(PROVIDER_ROLE) {
        if (from == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        if (serviceRef == bytes32(0)) revert InvalidServiceRef();

        uint256 balance = balanceOf(from);
        if (amount > balance) revert InsufficientCredits(balance, amount);

        _burn(from, amount);
        emit CreditsRedeemed(from, amount, serviceRef, msg.sender);
    }

    /// @notice Credits that can still be issued before the cap is reached.
    function remainingIssuable() external view returns (uint256) {
        return cap() - totalSupply();
    }

    /// @notice Disabled — allowances can never be spent, so none may be created.
    function approve(address, uint256) public pure override returns (bool) {
        revert ApprovalsDisabled();
    }

    /// @notice Disabled — `_update` alone cannot guarantee this error, because
    /// `_spendAllowance` runs first and every allowance is always zero.
    function transferFrom(address, address, uint256) public pure override returns (bool) {
        revert TransfersDisabled();
    }

    function _update(address from, address to, uint256 value) internal override(ERC20Capped) {
        if (from != address(0) && to != address(0)) revert TransfersDisabled();
        super._update(from, to, value);
    }
}
