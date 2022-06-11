pragma solidity >=0.8.4;

/// @title SafeMinionSummoner - Factory contract to depoy new Minions and Safes
/// @dev Can deploy a minion and a new safe, or just a minion to be attached to an existing safe
/// @author Isaac Patka, Dekan Brown

import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/libraries/MultiSend.sol";
import "@gnosis.pm/zodiac/contracts/factory/ModuleProxyFactory.sol";

import "./KaliDAOSafeMinion.sol";

contract SafeMinionSummoner is ModuleProxyFactory {
    // Template contract to use for new minion proxies
    address payable public immutable safeMinionSingleton;

    // Template contract to use for new Gnosis safe proxies
    address public gnosisSingleton;

    // Library to use for EIP1271 compatability
    address public gnosisFallbackLibrary;

    // Library to use for all safe transaction executions
    address public gnosisMultisendLibrary;

    // Track list and count of deployed minions
    address[] public minionList;
    uint256 public minionCount;


    // Track metadata and associated moloch for deployed minions
    struct AMinion {
        address dao;
        string details;
    }
    mapping(address => AMinion) public minions;

    event SummonSafeMinion(
        address indexed minion,
        address indexed dao,
        address indexed avatar,
        string details
    );

    /// @dev Construtor sets the initial templates
    /// @notice Can only be called once by factory
    /// @param _safeMinionSingleton Template contract to be used for minion factory
    /// @param _gnosisSingleton Template contract to be used for safe factory
    /// @param _gnosisFallbackLibrary Library contract to be used in configuring new safes
    /// @param _gnosisMultisendLibrary Library contract to be used in configuring new safes
    constructor(
        address payable _safeMinionSingleton,
        address _gnosisSingleton,
        address _gnosisFallbackLibrary,
        address _gnosisMultisendLibrary
    ) {
        safeMinionSingleton = _safeMinionSingleton;
        gnosisSingleton = _gnosisSingleton;
        gnosisFallbackLibrary = _gnosisFallbackLibrary;
        gnosisMultisendLibrary = _gnosisMultisendLibrary;
    }

    /// @dev Function to summon minion and configure with a new safe
    /// @param _dao Already deployed Kali DAO to instruct minion
    /// @param _details Optional metadata to store
    function summonMinionAndSafe(
        address _dao,
        string memory _details,
        uint256 _saltNonce
    ) external returns (address) {
        // Deploy new minion but do not set it up yet
        KaliDAOSafeMinion _minion = KaliDAOSafeMinion(
            payable(
                createProxy(
                    safeMinionSingleton,
                    keccak256(abi.encodePacked(_dao, _saltNonce))
                )
            )
        );

        // Deploy new safe but do not set it up yet
        GnosisSafe _safe = GnosisSafe(
            payable(
                createProxy(
                    gnosisSingleton,
                    keccak256(abi.encodePacked(address(_minion), _saltNonce))
                )
            )
        );

        // Initialize the minion now that we have the new safe address
        _minion.setUp(
            abi.encode(
                _dao,
                address(_safe),
                gnosisMultisendLibrary
            )
        );

        // Generate delegate calls so the safe calls enableModule on itself during setup
        bytes memory _enableMinion = abi.encodeWithSignature(
            "enableModule(address)",
            address(_minion)
        );
        bytes memory _enableMinionMultisend = abi.encodePacked(
            uint8(0),
            address(_safe),
            uint256(0),
            uint256(_enableMinion.length),
            bytes(_enableMinion)
        );
        bytes memory _multisendAction = abi.encodeWithSignature(
            "multiSend(bytes)",
            _enableMinionMultisend
        );

        // Workaround for solidity dynamic memory array
        address[] memory _owners = new address[](1);
        _owners[0] = address(_minion);

        // Call setup on safe to enable our new module and set the module as the only signer
        _safe.setup(
            _owners,
            1,
            gnosisMultisendLibrary,
            _multisendAction,
            gnosisFallbackLibrary,
            address(0),
            0,
            payable(address(0))
        );


        minions[address(_minion)] = AMinion(_dao, _details);
        minionList.push(address(_minion));
        minionCount++;

        emit SummonSafeMinion(
            address(_minion),
            _dao,
            address(_safe),
            _details
        );

        return (address(_minion));
    }
}
