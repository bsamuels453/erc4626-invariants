// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";

contract ERC4626TestVault is ERC4626 {
  uint256 private _totalAssets;

  constructor(ERC20 asset) ERC4626(asset, string.concat(asset.name(), " Test Vault"), string.concat(asset.symbol(), "-4626")) {}

  function totalAssets() public view virtual override returns (uint256) {
    return _totalAssets;
  }

  function beforeWithdraw(uint256 assets, uint256) internal override {
    _totalAssets = _totalAssets - assets;
  }

  function afterDeposit(uint256 assets, uint256) internal override {
    _totalAssets = _totalAssets + assets;
  }
}
