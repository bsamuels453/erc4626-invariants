// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {ERC4626TestVault} from "../src/ERC4626TestVault.sol";
import {ERC20Mintable} from "../src/ERC20Mintable.sol";

contract ERC4626StrictInvariants is Test {
  address constant alice = address(0xaaaa);
  address constant bob = address(0xbbbb);

  ERC20Mintable underlying;
  ERC4626TestVault vault;

  function setUp() public {
    underlying = new ERC20Mintable("DAI Stablecoin", "DAI", 18);
    // mint an initial amount to set the supply
    underlying.mint(address(this), 50000 ether);

    vault = new ERC4626TestVault(underlying);

    vm.label(alice, "Alice");
    vm.label(bob, "Bob");
    vm.label(address(underlying), "Underlying");
    vm.label(address(vault), "Vault");
  }

  function checkDepositAssumptions(uint256 amount) internal {
    vm.assume(amount <= vault.maxDeposit(address(this)));
    vm.assume(amount < underlying.totalSupply());
    // this deposit amount must produce at least 1 share
    uint256 sharesMinted = vault.previewDeposit(amount);
    vm.assume(sharesMinted >= 1);
  }

  function prepareAccountForDeposit(address account, uint256 amount) internal {
    checkDepositAssumptions(amount);
    deal(address(underlying), account, amount);
    vm.prank(account);
    underlying.approve(address(vault), amount);
  }

  // @notice Validates the following properties:
  // - Deposits consume the exact amount of underlying specified
  // - Deposits mint the exact number of shares reported by deposit
  function testDeposit(uint256 amount) public {
    prepareAccountForDeposit(alice, amount);

    vm.prank(alice);
    uint256 sharesReported = vault.deposit(amount, alice);
    uint256 sharesReal = vault.balanceOf(alice);

    assertEq(sharesReported, sharesReal, "deposit must report the amount of shares that were minted");
    assertEq(underlying.balanceOf(alice), 0, "deposit must consume exactly the number of tokens requested");
  }

  // @notice Validates the following properties:
  // - Deposits consume the exact amount of underlying specified
  // - Deposits mint the exact number of shares reported by deposit
  // - Shares are only credited to the correct account
  function testDepositOnOthersBehalf(uint256 amount) public {
    prepareAccountForDeposit(alice, amount);

    vm.prank(alice);
    uint256 sharesReported = vault.deposit(amount, bob);
    uint256 sharesReal = vault.balanceOf(bob);
    uint256 aliceSharesReal = vault.balanceOf(alice);

    assertEq(sharesReported, sharesReal, "deposit must report the amount of shares that were minted");
    assertEq(vault.balanceOf(bob), sharesReal, "deposit must mint shares to the receiver account");
    assertEq(underlying.balanceOf(alice), 0, "deposit must consume exactly the number of tokens requested");
    assertEq(vault.balanceOf(alice), 0, "deposit most only mint shares to the receiver account");
  }

  // @notice Validates the following properties:
  // - Mints generate the exact number of shares specified
  // - Mints consume the exact number of tokens reported by mint
  function testMint(uint256 amount) public {}

  // @notice Validates the following properties:
  // - Mints generate the exact number of shares specified
  // - Shares are only credited to the correct account
  // - Mints consume the exact number of tokens reported by mint
  function testMintOnOthersBehalf(uint256 amount) public {}

  function testWithdraw(uint256 amount) public {}

  function testWithdrawOnOthersBehalf(uint256 amount) public {}

  function testRedeem(uint256 amount) public {}

  function testRedeemOnOthersBehalf(uint256 amount) public {}

  function testPreviewDepositMatchesDeposit(uint256 amount) public {}

  function testPreviewMintMatchesMint(uint256 amount) public {}

  function testPreviewWithdrawMatchesWithdraw(uint256 amount) public {}

  function testPreviewRedeemMatchesRedeem(uint256 amount) public {}

  function testAsset() public {}

  function testTotalAssets(uint256 amount) public {}

  function testTotalSupply(uint256 amount) public {}

  function testFailMaxDeposit(uint256 amount) public {
    assert(false);
  }

  function testFailMaxMint(uint256 amount) public {
    assert(false);
  }

  function testFailMaxRedeem(uint256 amount) public {
    assert(false);
  }

  function testFailMaxWithdraw(uint256 amount) public {
    assert(false);
  }

  function testMaxDepositNotBalanceDependent() public {}

  function testMaxMintNotBalanceDependent() public {}
}
