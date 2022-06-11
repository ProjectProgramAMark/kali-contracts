// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.4;

import "../../libraries/SafeTransferLib.sol";
import "../../interfaces/IERC20minimal.sol";
import "../../utils/ReentrancyGuard.sol";
import "../../interfaces/"
import "@gnosis.pm/zodiac/contracts/core/Module.sol";

/// @notice contract that handles the creation, and transactions of a Gnosis Safe upon proposal pass
contract KaliDAOSafeMinion is ReentrancyGuard, Module {
    using SafeTransferLib for address;

    // address indexed dao;
    // address public contractAddress;
    // uint256 amount;
    // user will upload function signature
    // bytes functionName;

    event NewGnosisSafeProposal(dao, msg.sender, proposal, asset, nft, value);

    // executes arbitrary call to Gnosis Safe
    function executeAsMinion(address targetAddress, bytes functionName, uint256 amount) nonReentrant external {
        exec(
            targetAddress,
            amount,
            abi.encodePacked(bytes4(keccak256(functionName))),
            Enum.Operation.Call
        );
    }


    function createGnosisSafeProposal(
        address targetAddress,
        ProposalType proposalType,
        string calldata description,
        address[] calldata accounts,
        uint256[] calldata amounts,
        bytes[] calldata payloads
    ) public payable nonReentrant external {

        // to make a gnosis safe transaction I need:
        // dao
        // contract address to
        // amount of ETH in wei
        // function, abi encoded transaction data
        // operation (normally call)

        // to make a Kali DAO proposal I need:
        // proposalType (normally CALL)
        // description ???
        // accounts ???
        // amounts ???
        // payloads ???

        dao.propose(proposalType, description, accounts, amounts, payloads);
        emit NewGnosisSafeProposal(dao, msg.sender, proposal, asset, nft, value);


    }


    // following functions only called on module deployed
    constructor(address _owner) {
        bytes memory initializeParams = abi.encode(_owner);
        setUp(initializeParams);
    }

    /// @dev Initialize function, will be triggered when a new proxy is deployed
    /// @param initializeParams Parameters of initialization encoded
    function setUp(bytes memory initializeParams) public override initializer {
        __Ownable_init();
        (address _owner) = abi.decode(initializeParams, (address));

        setAvatar(_owner);
        setTarget(_owner);
        transferOwnership(_owner);
    }
}
