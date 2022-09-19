// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import "@gnosis.pm/zodiac/contracts/core/Module.sol";
import "hardhat/console.sol";
import "./Button.sol";
import "./MockSafe.sol";

contract GnosisSafeMinion is Module {
    event TestTransactionDone(address to, uint256 value, uint256 operation);
    event GnosisSafeMinionDeployed(address _owner, address _button);
    event CustomTransactionCalled();
    event ButtonPushed();
    event TransactionSuccess();
    // event TransactionFailed(bytes returnData);
    event TransactionFailed(bool transactionSucceeded);


    uint256 public tests;
    address public button;
    MockSafe mockSafe;
    // enum Enum.Operation{ SMALL, MEDIUM, LARGE }

    // function pushingButton(address to, uint256 value, string memory data, uint8 operation) external {
    //     Enum.Operation enum_operation = operation == 1 ? Enum.Operation.DelegateCall : Enum.Operation.Call;
    //     // debugging
    //     // console.log('data at pushButton(): ', data);
    //     exec(
    //         to,
    //         value,
    //         // abi.encodePacked(bytes4(keccak256(data))),
    //         abi.encodeWithSignature(data),
    //         // "0x0a007972",
    //         // data,
    //         enum_operation
    //     );

    //     // emit ButtonPushed();
    // }

    function doCustomTransaction(bytes memory payload) external payable {
        (
            address payable to, uint256 value, bytes4 data, uint8 operation
        ) = abi
            .decode(
                payload, (address, uint256, bytes4, uint8)
                );

        Enum.Operation enum_operation = operation == 1 ? Enum.Operation.DelegateCall : Enum.Operation.Call;

        console.log('to: ', to);
        console.log('value: ', value);
        console.log('operation: ', operation);
        (bool transactionSucceeded) = exec(
            to,
            value,
            // abi.encodeWithSelector(data),
            // abi.encodeWithSignature("pushButton()"),
            abi.encodeWithSelector(bytes4(keccak256("pushButton()"))),
            enum_operation
        );

        // (bool transactionSucceeded, bytes memory returnData) = execAndReturnData(
        //     to,
        //     value,
        //     abi.encodeWithSelector(data),
        //     enum_operation
        // );

        if(transactionSucceeded ==  true) {
            emit TransactionSuccess();
        } else {
            // emit TransactionFailed(returnData);
            emit TransactionFailed(transactionSucceeded);

        }

        emit CustomTransactionCalled();
    }

    constructor(address _owner, address _button) {
        // debugging
        console.log("_owner: ", _owner);
        console.log("_button: ", _button);

        bytes memory initializeParams = abi.encode(_owner, _button);
        setUp(initializeParams);
        emit GnosisSafeMinionDeployed(_owner, _button);
    }

    /// @dev Initialize function, will be triggered when a new proxy is deployed
    /// @param initializeParams Parameters of initialization encoded
    function setUp(bytes memory initializeParams) public override initializer {
        __Ownable_init();
        (address _owner, address _button) = abi.decode(
            initializeParams,
            (address, address)
        );

        button = _button;
        setAvatar(_owner);
        setTarget(_owner);
        transferOwnership(_owner);
    }
}
