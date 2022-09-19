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

import {GnosisSafeMinion} from "./gnosisSafeMinion.sol";

import "hardhat/console.sol";


/// @notice GnosisSafe creates transactions to the Kali DAO's Gnosis Safe
contract KaliDAOgnosisSafe is ReentrancyGuard {
    /// -----------------------------------------------------------------------
    /// Library Usage
    /// -----------------------------------------------------------------------

    using SafeTransferLib for address;

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event ExtensionSet(address indexed dao, address to, uint256 value, uint256 operation);

    event ExtensionCalled(address indexed dao, address safeAddress);

    // debugging
    event EqualMessageSenders(address messageSender, address msgDotSender);
    event DifferentMessageSenders(address messageSender, address msgDotSender);
    event GnosisSafeMinionCreated(address gnosisSafeMinionAddress);

    mapping(address => GnosisSafe) public gnosisSafes;

    struct GnosisSafe {
        address safeAddress;
    }

    /// -----------------------------------------------------------------------
    /// Logic
    /// -----------------------------------------------------------------------

    // this is called when the proposal is processed
    function setExtension(bytes calldata extensionData) external payable {
        (
            address gnosisSafeMinionAddress,
            address to,
            uint256 value,
            bytes memory data,
            uint256 operation
        ) = abi.decode(
                extensionData,
                (address, address, uint256, bytes, uint256)
            );
        // address safeAddress = abi.decode(extensionData, (address));
        console.log('solidity functions: ');
        console.log('to: ', to);
        console.log('value: ', value);
        // console.log('data: ', data);
        console.log('operation: ', operation);
        console.log('msg.sender: ', msg.sender);
        console.log('address(this): ', address(this));

        // address currentAddress = address(this);

        // sending transaction data to gnosis safe minion to call
        GnosisSafeMinion gnosisSafeMinion = GnosisSafeMinion(gnosisSafeMinionAddress);
        emit GnosisSafeMinionCreated(gnosisSafeMinionAddress);

        // gnosisSafeMinion.doTestTransaction(extensionData);
        // gnosisSafeMinion.doTestTransaction(abi.encodePacked(to, value, data, operation));

        emit ExtensionSet(msg.sender, to, value, operation);
    }

    // set Extension gets called on proposal pass/process, callExtension
    // can be called "arbitrarily" without passing the proposal
    // calls extension, or makes transaction from safe
    function callExtension(
        address account,
        uint256 amount,
        bytes calldata extensionData
    ) external payable returns (bool mint, uint256 amountOut) {
        // do nothing here
    }
}