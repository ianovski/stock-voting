pragma solidity ^0.5.0;

contract Voter {
    mapping (address => bool) isRegistered;
    address[] public registeredVoters;
    
    enum VotingState { UnVoted, UpVoted, DownVoted }

    struct Security{
        string name;
        bool exists;
        uint index;
        VotingState state;
    }

    struct VoterSecurities{
        uint count;
        mapping(uint => Security) securityList;
    }

    mapping (address => VoterSecurities) voterSecurityMap;

    string[] public securities;
    struct SecurityPos{
        string name;
        uint pos;
        uint totalVotes;
        uint upVotes;
        uint downVotes;
        bool exists;
        string next;
        string prev;
    }
    mapping (string => SecurityPos) securityVotes;
    
    function initSecurityPos(string memory stockName, VotingState voteState) public{
        uint upVotes = voteState == VotingState.UpVoted ? 1 : 0;
        uint downVotes = voteState == VotingState.DownVoted ? 1 : 0;
        SecurityPos memory securityPos = SecurityPos({
            name:stockName,
            pos: 0,
            totalVotes: 1,
            upVotes: upVotes,
            downVotes: downVotes,
            exists: true,
            next: 'none',
            prev: 'none'
        });
        securityVotes[stockName] = securityPos;
    }

    function registerVoter() public returns (bool output){
        isRegistered[msg.sender] = true;
        registeredVoters.push(msg.sender);
        output = isRegistered[msg.sender];
        return output;
    }

    function hasRegistered() public view returns (bool output){
        output = isRegistered[msg.sender];
        return output;
    }

    function addToTotalSecurityList(string memory security) private {
        securities.push(security);
    } 

    function initSecurityVoterMap() public{
       VoterSecurities memory voterSecurities = VoterSecurities({
           count:0
       });
       voterSecurityMap[msg.sender] = voterSecurities;       
    }

    function voteSecurity(string memory securityName, VotingState votingState) public {
        uint index = voterSecurityMap[msg.sender].count;
        voterSecurityMap[msg.sender].count++;

        Security memory security;

        security = Security({
            name: securityName,
            exists: true,
            index: index,
            state: votingState
        });

        voterSecurityMap[msg.sender].securityList[index] = security;
    } 

    /**
    * @dev Get number of securities that voter has voted for
    * @return number of securities
    */
    function getVoterSecurityCount() public view returns(uint count){
        count = voterSecurityMap[msg.sender].count;
        return count;
    }

    function getVoterSecurityNameByIndex(uint index) public view returns(string memory securityName){
        securityName = voterSecurityMap[msg.sender].securityList[index].name;
        return securityName;
    }

    function getVoterSecurityStateByIndex(uint index) public view returns(VotingState state){
        state = voterSecurityMap[msg.sender].securityList[index].state;
        return state;
    }

    function setSecurityPos(string memory securityName, VotingState votingState) public{
       //TODO
    }

    /**
     * @dev gets position of security in overall stock ranking
     * @param securityName stock ticker
     * @return position
     */
    function getSecurityPos(string memory securityName) public view returns (uint pos){
        return securityVotes[securityName].pos;
    }
}