// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract MirrToken is Initializable, ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    using SafeERC20 for IERC20;

    address internal bridge;

    event BridgeAddressChanged(address indexed addr);
    event EmergencyWithdrawn(address indexed to, address indexed token, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory name_, string memory symbol_) initializer public {
        __ERC20_init(name_, symbol_);
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    modifier onlyBridge() {
        require(address(bridge) != address(0), "Bridge contract isn't set");
        require(bridge == _msgSender(), "Only bridge can call this function");
        _;
    }

    function mint(address to, uint256 amount) external onlyBridge returns (bool){
        _mint(to, amount);
        return true;
    }

    function burn(address account, uint256 amount) external onlyBridge returns (bool) {
        _burn(account, amount);
        return true;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function setBridge(address addr) external onlyOwner {
        bridge = addr;
        emit BridgeAddressChanged(addr);
    }

    // Emergency withdrawal
    function emergencyWithdraw(address token, address to,  uint256 amount) external onlyOwner {
        if (token == address(0)) {
            (bool sent, ) = payable(to).call{value: amount}("");
            require(sent, "Token transfer failed");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
        
        emit EmergencyWithdrawn(to, token, amount);
    }

}