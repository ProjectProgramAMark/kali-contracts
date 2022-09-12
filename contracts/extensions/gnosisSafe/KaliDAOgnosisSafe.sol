// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import {SafeTransferLib} from "../../libraries/SafeTransferLib.sol";

import {IKaliAccessManager} from "../../interfaces/IKaliAccessManager.sol";
import {IKaliShareManager} from "../../interfaces/IKaliShareManager.sol";
import {IERC20permit} from "../../interfaces/IERC20permit.sol";

import {KaliOwnable} from "../../access/KaliOwnable.sol";

import {Multicall} from "../../utils/Multicall.sol";
import {ReentrancyGuard} from "../../utils/ReentrancyGuard.sol";

import {IKaliDAOextension} from "../../interfaces/IKaliDAOextension.sol";


/// @notice GnosisSafe creates transactions to the Kali DAO's Gnosis Safe
contract KaliDAOgnosisSafe is KaliOwnable, Multicall, ReentrancyGuard {
    /// -----------------------------------------------------------------------
    /// Library Usage
    /// -----------------------------------------------------------------------

    using SafeTransferLib for address;

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event ExtensionSet(address indexed dao, address safeAddress);

    event ExtensionCalled(address indexed dao, address safeAddress);

    IKaliAccessManager private immutable accessManager;
    mapping(address => GnosisSafe) public gnosisSafes;

    struct GnosisSafe {
        address safeAddress;
        string details;
    }

    constructor(IKaliAccessManager accessManager_) {
        accessManager = accessManager_;
        KaliOwnable._init(msg.sender);
    }

    /// -----------------------------------------------------------------------
    /// Logic
    /// -----------------------------------------------------------------------

    // stores settings for the extension
    // gnosis safe address
    function setExtension(bytes calldata extensionData) external payable {
        address safeAddress = abi.decode(extensionData, (address));

        emit ExtensionSet(msg.sender, safeAddress);
    }

    // calls extension, or makes transaction from safe
    function callExtension(
        address dao, 
        address safeAddress, 
        address addressTo, 
        uint256 value,
        bytes memory data
        )
        external
        payable
        nonReentrant
        returns (uint256 amountInSafe)
    {
        // get gnosis safe minion instance

        // call doCustomTransaction() on gnosis safe minion contract, passing in params
        

        emit ExtensionCalled(dao, safeAddress);
    }
}
