// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IMirrToken.sol";

struct DepositReqquest {
    IMirrToken fromToken;
    address to;
    uint toChainId;
    uint256 amount;
}

struct WithdrawRequest {
    IMirrToken fromToken;
    IMirrToken toToken;
    address from;
    address to;
    uint fromChainId;
    uint toChainId;
    uint256 amount;
    bytes32 txId;
}
