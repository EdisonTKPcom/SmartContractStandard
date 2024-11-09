// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

contract AdvancedSmartContract is Initializable, OwnableUpgradeable, PausableUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20 for IERC20;

    // Event declarations
    event OwnershipTransfer(address indexed previousOwner, address indexed newOwner);
    event ContractPaused(address account);
    event ContractUnpaused(address account);
    event Upgraded(address indexed implementation);
    event Transfer(address indexed from, address indexed to, uint256 value);

    // State variables and mappings
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    // Initialization function
    function initialize(address initialOwner, uint256 initialSupply) public initializer {
        __Ownable_init(initialOwner); // Initialize Ownable with initialOwner for upgradeable contracts
        __Pausable_init(); // Initialize Pausable for upgradeable contracts

        // Set initial supply
        _totalSupply = initialSupply;
        _balances[initialOwner] = initialSupply;
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
