// SPDX-License-Identifier: GNU AGPLv3

pragma solidity ^0.8.16;

import {IMorpho} from "./interface/IMorpho.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IWETH9} from "./interface/IWETH9.sol";

contract StoaMorphoCompound {
    address private immutable i_MORPHO;
    address private immutable i_WETH;
    address private immutable i_CETH;
    address private immutable i_DAI;
    address private immutable i_CDAI;

    constructor(
        address _morpho,
        address _WETH,
        address _CETH,
        address _DAI,
        address _CDAI
    ) {
        i_MORPHO = _morpho;
        i_WETH = _WETH;
        i_CETH = _CETH;
        i_DAI = _DAI;
        i_CDAI = _CDAI;
    }

    function _supplyERC20(
        address _cToken,
        address _underlying,
        uint256 _amount
    ) internal {
        IERC20(_underlying).approve(i_MORPHO, _amount);
        IMorpho(i_MORPHO).supply(_cToken, address(this), _amount);
    }

    function supplyDAI(uint256 _amount) external {
        _supplyERC20(i_CDAI, i_DAI, _amount);
    }

    function supplyETH() external payable {
        IWETH9(i_WETH).deposit{value: msg.value}();

        _supplyERC20(i_CETH, i_WETH, msg.value);
    }

    function claimRewards() external {
        address[] memory poolTokens = new address[](2);
        poolTokens[0] = i_CDAI;
        poolTokens[1] = i_CETH;

        IMorpho(i_MORPHO).claimRewards(poolTokens, false);
    }

    function _withdrawERC20(address _cToken, uint256 _amount) internal {
        IMorpho(i_MORPHO).withdraw(_cToken, _amount);
    }

    function withdrawDAI(uint256 _amount) external {
        _withdrawERC20(i_CDAI, _amount);
    }

    function withdrawETH(uint256 _amount) external {
        _withdrawERC20(i_CETH, _amount);

        IWETH9(i_WETH).withdraw(_amount);
    }
}
