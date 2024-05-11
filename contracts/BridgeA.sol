// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./BridgeStructs.sol";

contract BridgeA is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using SafeERC20 for IERC20;

    address internal signer;
    mapping(bytes => bool) internal signUsed;

    // support bridge token(1) bridge to chainId(2) target chain token address(3)
    mapping(IERC20 => mapping(uint => IERC20)) public bridges;

    event BridgeDeposited(
        IERC20 indexed fromToken,
        IERC20 toToken,
        address indexed from,
        address indexed to,
        uint fromChainId,
        uint toChainId,
        uint256 amount
    );
    event BridgeWithdrawn(
        IERC20 fromToken,
        IERC20 indexed toToken,
        address indexed from,
        address indexed to,
        uint fromChainId,
        uint toChainId,
        uint256 amount,
        bytes32 txId
    );
    event SetSignerEvent(address signer);
    event BridgeAddressAdded(IERC20 indexed fromToken, uint toChainId, IERC20 indexed toToken);
    event EmergencyWithdrawn(address indexed to, address indexed token, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        signer = _msgSender();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    // bridge token from A to B. step1: transfer token to bridge
    function depositToken(
        DepositReqquest calldata req
    ) external {
        IERC20 toToken = bridges[req.fromToken][req.toChainId];
        address from = _msgSender();
        require(address(toToken) != address(0), "Token or target chain is not supported");
        require(req.to != address(0), "Target address should not be 0");
        require(req.amount > 0, "Amount must be greater than 0");
        IERC20(req.fromToken).safeTransferFrom(from, address(this), req.amount);
        emit BridgeDeposited(req.fromToken, toToken, from, req.to, block.chainid, req.toChainId, req.amount);
    }

    // bridge token from B to A. step2: withdraw token from bridge
    function withdrawToken(
        WithdrawRequest calldata req,
        bytes memory sign
    ) external {
        require(address(req.toToken) != address(0), "Token address is invalid");
        require(_msgSender() == address(req.to), "Target address mismatch");
        require(block.chainid == req.toChainId, "Target chain mismatch");
        require(signUsed[sign] != true, "This signature already be used");

        bytes32 msgHash = ECDSA.toEthSignedMessageHash(
            keccak256(
                abi.encodePacked(
                    req.fromToken,
                    req.toToken,
                    req.from,
                    req.to,
                    req.fromChainId,
                    req.toChainId,
                    req.amount,
                    req.txId
                )
            )
        );
        address recoveredSigner = ECDSA.recover(msgHash, sign);
        require(
            recoveredSigner != address(0) && recoveredSigner == signer,
            "Invalid Signer!"
        );
        signUsed[sign] = true;
        IERC20(req.toToken).safeTransfer(_msgSender(), req.amount);

        emit BridgeWithdrawn(req.fromToken, req.toToken, req.from, req.to, req.fromChainId, req.toChainId, req.amount, req.txId);
    }

    function setSigner(address addr) external onlyOwner {
        require(addr != address(0), "Signer should not be 0");
        signer = addr;
        emit SetSignerEvent(addr);
    }

    function addBridge(IERC20 fromToken, uint toChainId, IERC20 toToken) external onlyOwner {
        require(address(fromToken) != address(0), "From token invalid");
        require(address(toToken) != address(0), "To token invalid");

        bridges[fromToken][toChainId] = toToken;
        emit BridgeAddressAdded(fromToken, toChainId, toToken);
    }

    // Emergency withdrawal
    function emergencyWithdraw(address token, address to,  uint256 amount) external onlyOwner {
        require(to != address(0), "To address should not be 0");
        if (token == address(0)) {
            (bool sent, ) = payable(to).call{value: amount}("");
            require(sent, "Token transfer failed");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
        
        emit EmergencyWithdrawn(to, token, amount);
    }
}
