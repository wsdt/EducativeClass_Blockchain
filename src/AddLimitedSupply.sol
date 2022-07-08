// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A token tracker that limits the token supply and increments token IDs on each new mint.
abstract contract AddLimitedSupply is Ownable {
    using Counters for Counters.Counter;

    // Keeps track of how many we have minted
    Counters.Counter private _tokenCount;

    /// @dev The maximum count of tokens this token tracker will hold.
    uint256 private _totalSupply;
    bool public supplyFrozen = false;

    /// Instanciate the contract
    /// @param totalSupply_ how many tokens this collection should hold
    constructor (uint256 totalSupply_) {
        _totalSupply = totalSupply_;
    }

    /// @dev Get the max Supply
    /// @return the maximum token count
    function totalSupply() public virtual view returns (uint256) {
        return _totalSupply;
    }

    /// @dev Will only be used in conjunction after the community has voted to allow the community to grow larger.
    function setTotalSupply(uint256 totalSupply_) external onlyOwner {
        require(!supplyFrozen, "Supply frozen");
        require(totalSupply_ > _totalSupply, "Cannot be smaller");
        _totalSupply = totalSupply_;
    }
    /// @dev In case we want to keep ownership, but community really wants to remove the possibility of increasing the supply.
    function freezeTotalSupply() external onlyOwner {
        supplyFrozen = true;
    }

    /// @dev Get the current token count
    /// @return the created token count
    function tokenCount() public view returns (uint256) {
        return _tokenCount.current();
    }

    /// @dev Check whether tokens are still available
    /// @return the available token count
    function availableTokenCount() public view returns (uint256) {
        return totalSupply() - tokenCount();
    }

    /// @dev Increment the token count and fetch the latest count
    /// @return the next token id
    function nextToken() internal virtual ensureAvailability returns (uint256) {
        uint256 token = _tokenCount.current();

        _tokenCount.increment();

        return token;
    }

    /// @dev Check whether another token is still available
    modifier ensureAvailability() {
        require(availableTokenCount() > 0, "No more tokens available");
        _;
    }

    /// @param amount Check whether number of tokens are still available
    /// @dev Check whether tokens are still available
    modifier ensureAvailabilityFor(uint256 amount) {
        require(availableTokenCount() >= amount, "Requested number of tokens not available");
        _;
    }
}
