const { BigNumber } = require("ethers");
const chai = require("chai");
const { expect } = require("chai");

const wethAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

chai.should();

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
  let Whitelist; // Whitelist contract
  let whitelist; // Whitelist contract instance
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

    Whitelist = await ethers.getContractFactory("KaliAccessManager");
    whitelist = await Whitelist.deploy();
    await whitelist.deployed();

    GnosisSafeExtension = await ethers.getContractFactory("KaliDAOgnosisSafe");
    gnosisSafeExtension = await GnosisSafeExtension.deploy(whitelist.address);
    await gnosisSafeExtension.deployed();

    GnosisSafeMinion = await ethers.getContractFactory("gnosisSafeMinion");
    gnosisSafeMinion = await GnosisSafeMinion.deploy(safeAddress, kali.address);
    await GnosisSafeMinion.deployed();
  });

  it("Should instantiate KaliDAO", async function () {
    // Instantiate KaliDAO
    await kali.init(
      "KALI",
      "KALI",
      "DOCS",
      false,
      [],
      [],
      [proposer.address],
      [getBigNumber(10)],
      [30, 0, 0, 60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    );
  });

  it("Should call callExtension() successfully (testing setup only)", async function () {
    // Instantiate KaliDAO
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

    // Set up payload for extension proposal
    let payload = ethers.utils.defaultAbiCoder.encode(
      ["uint256", "string"],
      [0, "DETAILS"]
    );

    // proposing and calling extension
    await kali.propose(
      9,
      "TEST",
      [gnosisSafeExtension.address],
      [1],
      [payload]
    );
    await kali.vote(1, true);
    await advanceTime(35);
    // await gnosisSafeExtension.callExtension(kali.address, getBigNumber(420));
    // await gnosisSafeExtension.connect(alice).callExtension(kali.address, getBigNumber(50));

    // expect(await ethers.provider.getBalance(kali.address)).to.equal(
    //   getBigNumber(470)
    // );
    // expect(await kali.balanceOf(proposer.address)).to.equal(getBigNumber(420));
    // expect(await kali.balanceOf(alice.address)).to.equal(getBigNumber(50));
  });

  it("Should deploy gnosisSafeMinion", async function () {
    // Instantiate KaliDAO
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

    
  });
});
