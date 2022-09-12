// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import "@gnosis.pm/zodiac/contracts/core/Module.sol";

contract GnosisSafeMinion is Module {
    event TestTransactionDone(address indexed dao, uint256 tests);

    uint256 public tests;
    address public kaliDAO;

    function doTestTransaction() external {
        tests++;
        emit TestTransactionDone(msg.sender, tests);
    }

    function doCustomTransaction(address addressTo) external {
        exec(
            addressTo,
            0,
            abi.encodePacked(bytes4(keccak256("doTestTransaction()"))),
            Enum.Operation.Call
        );
    }

    constructor(address _owner, address _kaliDAO) {
        bytes memory initializeParams = abi.encode(_owner, _kaliDAO);
        setUp(initializeParams);
    }

    /// @dev Initialize function, will be triggered when a new proxy is deployed
    /// @param initializeParams Parameters of initialization encoded
    function setUp(bytes memory initializeParams) public override initializer {
        __Ownable_init();
        (address _owner, address _kaliDAO) = abi.decode(
            initializeParams,
            (address, address)
        );

        kaliDAO = _kaliDAO;
        setAvatar(_owner);
        setTarget(_owner);
        transferOwnership(_owner);
    }


}
