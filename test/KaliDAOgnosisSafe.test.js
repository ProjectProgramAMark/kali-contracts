const { BigNumber } = require("ethers");
const chai = require("chai");
const { expect } = require("chai");
// const { ethers } = require("hardhat");
const wethAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

chai.should();

const PROPOSAL_TYPE_EXTENSION = 9;
const ENUM_OPERATION_CALL = 0;

// Defaults to e18 using amount * 10^18
function getBigNumber(amount, decimals = 18) {
  return BigNumber.from(amount).mul(BigNumber.from(10).pow(decimals));
}

async function advanceTime(time) {
  await ethers.provider.send("evm_increaseTime", [time]);
}

describe("GnosisSafe", function () {
  let Kali; // KaliDAO contract
  let kali; // KaliDAO contract instance
  // let Whitelist; // Whitelist contract
  // let whitelist; // Whitelist contract instance
  let GnosisSafeExtension; // Gnosis Safe Extension contract
  let gnosisSafeExtension; // Gnosis Safe Extension contract instance
  let GnosisSafeMinion; // Gnosis Safe Minion contract
  let gnosisSafeMinion; // Gnosis Safe Minion contract instance
  let safeAddress; // Gnosis Safe (mock) address
  let proposer; // signerA
  let alice; // signerB
  let bob; // signerC

  beforeEach(async () => {
    [proposer, alice, bob] = await ethers.getSigners();

    Kali = await ethers.getContractFactory("KaliDAO");
    kali = await Kali.deploy();
    await kali.deployed();

    // Whitelist = await ethers.getContractFactory("KaliAccessManager");
    // whitelist = await Whitelist.deploy();
    // await whitelist.deployed();

    GnosisSafeExtension = await ethers.getContractFactory("KaliDAOgnosisSafe");
    gnosisSafeExtension = await GnosisSafeExtension.deploy();
    await gnosisSafeExtension.deployed();

    // deploying MockSafe for testing
    MockSafe = await ethers.getContractFactory("MockSafe");
    mockSafe = await MockSafe.deploy();
    await mockSafe.deployed();

    // deploying Button contract for testing
    Button = await ethers.getContractFactory("Button");
    button = await Button.deploy();
    await button.deployed();

    GnosisSafeMinion = await ethers.getContractFactory("GnosisSafeMinion");

    // setting owner (safe) and button address (might not need this one)
    gnosisSafeMinion = await GnosisSafeMinion.deploy(mockSafe.address, button.address);
    await gnosisSafeMinion.deployed();

    // enabling gnosis safe minion module on mock safe
    mockSafe.enableModule(gnosisSafeMinion.address);
    button.transferOwnership(gnosisSafeMinion.address);

    // instantiate kali DAO
    await kali.init(
      "KALI", // string memory name_,
      "KALI", // string memory symbol_,
      "DOCS", // string memory docs_,
      false, // bool paused_,
      [], // address[] memory extensions_,
      [], // bytes[] memory extensionsData_,
      [proposer.address], // address[] calldata voters_,
      [getBigNumber(10)], // uint256[] calldata shares_,
      [30, 0, 0, 60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] // uint32[16] memory govSettings_
    );

    // debugging
    // printing addresses of deployed contracts
    console.log("kali: ", kali.address);
    console.log("gnosisSafeExtension: ", gnosisSafeExtension.address);
    console.log("mockSafe: ", mockSafe.address);
    console.log("button: ", button.address);
    console.log("gnosis safe minion: ", gnosisSafeMinion.address);
    console.log("proposer: ", proposer.address);
    // console.log("alice: ", alice.address);
    // console.log("bob: ", bob.address);
  });

  // it("Should push the button manually", async function() {
  //   await expect(await button.pushButton()).to.emit(button, "ButtonPushed");
  // })


  // it("Should submit a test proposal to call gnosis safe", async function () {

  //   let paymentValue = 1;
  //   let payload = ethers.utils.defaultAbiCoder.encode(
  //     // Project struct encoding
  //     ["address", "address", "uint256", "bytes", "uint256"],
  //     [
  //       gnosisSafeMinion.address,
  //       mockSafe.address, // to
  //       paymentValue, // value
  //       // abi.encodePacked(bytes4(keccak256("pushButton()"))), // data
  //       ethers.utils.solidityKeccak256(
  //         ["bytes"],
  //         [ethers.utils.toUtf8Bytes("pushButton()")]
  //       ), // data
  //       ENUM_OPERATION_CALL, // operation
  //     ]
  //   );

  //   /*
  //   exec(
  //       to: the address that the safe will call. The Button contract in our case.
  //       value: the amount of ETH in wei that should be sent with the transaction. This is zero in our case.
  //       data: the ABI encoded transaction data that the data for the safe's transaction. In our case this is the function selector for the pushButton() function.
  //       operation: defines whether the transaction should be a call or a delegate call. In our case, we'll just do a call.
  //     )
  //   */

  //   await kali.propose(
  //     PROPOSAL_TYPE_EXTENSION,
  //     "Testing proposal for creating safe transaction",
  //     [gnosisSafeExtension.address],
  //     [1],
  //     [payload]
  //   );

  //   await kali.vote(1, true);
  //   await advanceTime(35);
  //   // await kali.processProposal(1);

  //   await expect(await kali.processProposal(1)).
  //     to.emit(gnosisSafeExtension, "ExtensionSet")
  //       .withArgs(kali.address, mockSafe.address, paymentValue, ENUM_OPERATION_CALL);
  //   // .withArgs(kali.address, [100, kali.address, manager.address, getBigNumber(300), projectDeadline+hours(3), "Website facelift and blog setup"]);

  //   /*
  //   struct Proposal {
  //       ProposalType proposalType;
  //       string description;
  //       address[] accounts; // member(s) being added/kicked; account(s) receiving payload
  //       uint256[] amounts; // value(s) to be minted/burned/spent; gov setting [0]
  //       bytes[] payloads; // data for CALL proposals
  //       uint256 prevProposal;
  //       uint96 yesVotes;
  //       uint96 noVotes;
  //       uint32 creationTime;
  //       address proposer;
  //   }
  //   */
  // });

  it("Should call exec() on gnosis safe minion to do pushButton() on Button", async function() {

    const iface = new ethers.utils.Interface([
      "function pushButton() public"
    ]);
    const pushButtonFunction = iface.getFunction("pushButton");
    console.log('getSighash: ', iface.getSighash(pushButtonFunction));

    let paymentValue = 1;
    let payload = ethers.utils.defaultAbiCoder.encode(
      ["address", "uint256", "bytes4", "uint256"],
      [
        button.address, // to
        paymentValue, // value
        iface.getSighash(pushButtonFunction),
        ENUM_OPERATION_CALL, // operation
      ]
    );

    // await expect(await gnosisSafeMinion.doCustomTransaction(payload)).
    //   to.emit(gnosisSafeMinion, "TransactionSuccess");

    await expect(await gnosisSafeMinion.doCustomTransaction(payload)).
    to.emit(gnosisSafeMinion, "TransactionFailed").withArgs(true);

  });

  // it("Should submit a test transaction to call gnosis safe", async function () {

  //   let paymentValue = 1;
  //   let payload = ethers.utils.defaultAbiCoder.encode(
  //     // Project struct encoding
  //     ["address", "address", "uint256", "bytes", "uint256"],
  //     [
  //       gnosisSafeMinion.address, // gnosis safe minion address
  //       button.address, // to
  //       paymentValue, // value
  //       // abi.encodePacked(bytes4(keccak256("pushButton()"))), // data
  //       ethers.utils.solidityKeccak256(
  //         ["bytes"],
  //         [ethers.utils.toUtf8Bytes("pushButton()")]
  //       ), // data
  //       ENUM_OPERATION_CALL, // operation
  //     ]
  //   );

  //   /*
  //   exec(
  //       to: the address that the safe will call. The Button contract in our case.
  //       value: the amount of ETH in wei that should be sent with the transaction. This is zero in our case.
  //       data: the ABI encoded transaction data that the data for the safe's transaction. In our case this is the function selector for the pushButton() function.
  //       operation: defines whether the transaction should be a call or a delegate call. In our case, we'll just do a call.
  //     )
  //   */

  //   await kali.propose(
  //     PROPOSAL_TYPE_EXTENSION,
  //     "Testing proposal for creating safe transaction",
  //     [gnosisSafeExtension.address],
  //     [1],
  //     [payload]
  //   );

  //   await kali.vote(1, true);
  //   await advanceTime(35);
  //   // await kali.processProposal(1);

  //   await expect(await kali.processProposal(1)).
  //     to.emit(gnosisSafeExtension, "GnosisSafeMinionCreated");
  //       // .withArgs(kali.address, mockSafe.address, paymentValue, ENUM_OPERATION_CALL);
  //   // .withArgs(kali.address, [100, kali.address, manager.address, getBigNumber(300), projectDeadline+hours(3), "Website facelift and blog setup"]);

  // });
});
