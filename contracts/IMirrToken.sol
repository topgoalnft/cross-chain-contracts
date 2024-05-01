// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
interface IMirrToken is IERC20 {
    event BridgeAddressChanged(address indexed addr);
    event EmergencyWithdrawn(address indexed to, address indexed token, uint256 amount);

    function mint(address to, uint256 amount) external returns (bool);
    function burn(address account, uint256 amount) external returns (bool); 
    function setBridge(address addr) external;
    function emergencyWithdraw(address token, address to,  uint256 amount) external;
}
