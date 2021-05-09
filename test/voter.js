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
    await initAccount(firstAccount);
    await upVoteByName("tsla", firstAccount);
    let verification = await voter.getVoterSecurityNameByIndex.call(index, {
      from: firstAccount,
    });
    expect(verification).equal("tsla");
  });

  it("can verify upvoted stock state added to user map", async function () {
    let index = 0;
    await initAccount(firstAccount);
    await upVoteByName("tsla", firstAccount);
    let verification = await voter.getVoterSecurityStateByIndex.call(index, {
      from: firstAccount,
    });
    expect(parseInt(verification)).equal(1);
  });
  
  it("can verify fetching security name by score with single voting account initialized", async function () {
    let index = 0;
    await initAccount(firstAccount);
    await upVoteByName("tsla", firstAccount);
    await upVoteByName("tsla", firstAccount);
    await upVoteByName("tsla", firstAccount);
    await upVoteByName("tsla", firstAccount);
    await upVoteByName("nflx", firstAccount);
    await upVoteByName("nflx", firstAccount);
    await upVoteByName("amzn", firstAccount);
    let verification = await voter.getSecurityNameByScore.call(4, {
      from: firstAccount,
    });
    expect(verification).equal("tsla");
  });


  // it("can verify initializing ranking position struct", async function () {
  //   await voter.initSecurityPos('tsla', 1, {
  //     from: firstAccount,
  //   });
  //   let verification = await voter.getSecurityPos.call('tsla', {
  //     from: firstAccount,
  //   });
  //   expect(parseInt(verification)).equal(0);
  // });

  async function initAccount(accountAddress){
    await voter.methods["initSecurityVoterMap()"]({ from: accountAddress });
  }

  async function upVoteByName(stockName, accountAddress) {
    let voteState = 1;
    await voter.voteSecurity(stockName, voteState, {
      from: accountAddress,
    });
  }
});
