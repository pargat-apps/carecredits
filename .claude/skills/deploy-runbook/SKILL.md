---
name: deploy-runbook
description: Use when deploying CareCredits.sol to Anvil or Sepolia, or when writing or reviewing a deploy script in contracts/script — key handling, commands, and post-deploy verification.
---

# Deploy Runbook

## The order is fixed: Anvil, then Sepolia. Never mainnet.
Anvil catches a wrong role grant or a bad constructor argument for free, in seconds.
Sepolia costs faucet ETH and a wait for confirmations. Mainnet is permanently out of
scope for this project — never write a script that could target it, never deploy there.

## Keys — encrypted keystore only, never a file
```bash
cast wallet import carecredits-deployer --interactive
```
This prompts for the private key interactively and stores it encrypted; the key is
never written to disk in plaintext and never appears in shell history.
`.env` holds the account **name**, never the key:
```
# contracts/.env  (gitignored, never committed)
DEPLOYER_ACCOUNT=carecredits-deployer
SEPOLIA_RPC_URL=...
```
Bad: `PRIVATE_KEY=0xabc...` in any file, ever.
Good: `--account carecredits-deployer` on the `forge script` command line, key
entered once at import time.

## Pre-deploy checklist
- `forge build` and `forge test` both green, including the deploy script's own tests
- Constructor args confirmed: name `CareCredits`, symbol `CARE`, cap value, intended
  admin address
- Confirm the deployer does **not** get auto-granted `ISSUER_ROLE` — the script must
  grant it explicitly or not at all
- `.env` present locally, confirmed untracked
  (`git ls-files --error-unmatch contracts/.env` should fail)
- Correct network selected — re-read the command before running it

## Anvil (local)
```bash
anvil                                    # separate terminal, stays running
forge script script/Deploy.s.sol \
  --rpc-url http://localhost:8545 \
  --broadcast \
  --account carecredits-deployer
```
Anvil's ten keys are built-in, public, and worthless — fine to use directly here,
never on Sepolia.

## Sepolia (testnet)
```bash
forge script script/Deploy.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --account carecredits-deployer \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```
`--verify` publishes source to Etherscan in the same step — don't treat
verification as a separate later task if it can happen here.

## The five post-deploy checks — every deployment, no exceptions
1. `cap()` equals the intended value
2. `totalSupply() == 0`
3. The intended admin holds `DEFAULT_ADMIN_ROLE`
4. No unintended address holds `ISSUER_ROLE`
5. No unintended address holds `PROVIDER_ROLE`
Run these with `cast call`, not by trusting the script's own console output — the
check has to be independent of the code being checked.

## Record in docs/DEPLOYMENTS.md
Contract address, deployment block number, transaction hash, constructor
arguments, deployer address, network, date, and the result of each of the five
post-deploy checks. If a later session needs the address and it isn't written down
here, that's a gap in this step, not a reason to grep `broadcast/`.

## Contracts are immutable — you redeploy, you don't patch
There is no upgrade path (ADR-003, ADR-005). A bug found after deployment means:
deploy a new contract, update the frontend's contract address, and document why in
`docs/DEPLOYMENTS.md`. Never attempt to "fix" a live contract — it can't be done,
and trying wastes the one thing that actually needs doing.

## Never
- Never deploy to mainnet.
- Never put a private key or mnemonic in any file, including `.env`.
- Never skip Anvil and go straight to Sepolia "to save time."
- Never assume a role grant happened — verify with the five checks via `cast call`.
- Never treat a deployed contract as patchable — redeploy and record it.
- Never commit `broadcast/` artifacts from a deployment; they are build output.
