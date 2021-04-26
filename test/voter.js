let Voter = artifacts.require("./Voter.sol");

contract("Voter", function (accounts) {
  let voter;
  let firstAccount;

  beforeEach(async function () {
    firstAccount = accounts[0];
    voter = await Voter.new();
  });

  it("can register new voter", async function () {
    let verification = await voter.registerVoter.call({ from: firstAccount });
    expect(verification).equal(true);
  });

  it("can verify registered voter is registered", async function () {
    await voter.methods["registerVoter()"]({ from: firstAccount });
    let verification = await voter.hasRegistered.call({ from: firstAccount });
    expect(verification).equal(true);
  });

  it("can verify unregistered voter is not registered", async function () {
    let secondAccount = accounts[1];
    let verification = await voter.hasRegistered.call({ from: secondAccount });
    expect(verification).equal(false);
  });

  it("can verify initializing voter map", async function () {
    await voter.methods["initSecurityVoterMap()"]({ from: firstAccount });
    let verification = await voter.getVoterSecurityCount.call({
      from: firstAccount,
    });
    expect(parseInt(verification)).equal(0);
  });

  it("can verify upvoting stock increases count", async function () {
    await voter.methods["initSecurityVoterMap()"]({ from: firstAccount });
    await voter.voteSecurity("tsla", 1, { from: firstAccount });
    let verification = await voter.getVoterSecurityCount.call({
      from: firstAccount,
    });
    expect(parseInt(verification)).equal(1);
  });

  it("can verify upvoted stock name added to user map", async function () {
    let index = 0;
    await upVoteByName("tsla");
    let verification = await voter.getVoterSecurityNameByIndex.call(index, {
      from: firstAccount,
    });
    expect(verification).equal("tsla");
  });

  it("can verify upvoted stock state added to user map", async function () {
    let index = 0;
    await upVoteByName("tsla");
    let verification = await voter.getVoterSecurityStateByIndex.call(index, {
      from: firstAccount,
    });
    expect(parseInt(verification)).equal(1);
  });

  async function upVoteByName(stockName) {
    let voteState = 1;
    await voter.methods["initSecurityVoterMap()"]({ from: firstAccount });
    await voter.voteSecurity(stockName, voteState, {
      from: firstAccount,
    });
  }
});
