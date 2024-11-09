// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AdvancedSmartContract is Ownable, Pausable, Initializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Event declarations
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ContractPaused(address account);
    event ContractUnpaused(address account);
    event Upgraded(address indexed implementation);

    // State variables and mappings
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    // Initialization function
    function initialize(uint256 initialSupply) public initializer {
        _totalSupply = initialSupply;
        _balances[msg.sender] = initialSupply;
    }

    // Only owner functions
    function pauseContract() external onlyOwner whenNotPaused {
        _pause();
        emit ContractPaused(msg.sender);
    }

    function unpauseContract() external onlyOwner whenPaused {
        _unpause();
        emit ContractUnpaused(msg.sender);
    }

    function emergencyWithdraw(IERC20 token, uint256 amount) external onlyOwner {
        token.safeTransfer(owner(), amount);
    }

    // Transfer function example (ERC20 standard)
    function transfer(address to, uint256 amount) external whenNotPaused returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // Fallback function for receiving ETH
    receive() external payable {}

    // Kill switch (self-destruct)
    function killSwitch() external onlyOwner {
        selfdestruct(payable(owner()));
    }

    // Getter for total supply
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // Upgradability functions
    function upgrade(address newImplementation) external onlyOwner {
        emit Upgraded(newImplementation);
        // Code for upgrade logic goes here (proxy setup)
    }
}
