pragma solidity ^0.5.0;

contract Voter {
    mapping (address => bool) isRegistered;
    address[] public registeredVoters;
    
    enum VotingState { NotVoted, UpVoted, DownVoted }

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
        uint pos;
        bool exists;
    }
    mapping (string => SecurityPos) posOfSecurity;

    string[] public options;
    bool votingStarted;
    
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

    function voteSecurity(string memory securityName, VotingState votingState) public returns(string memory securityNameOutput) {
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
        securityNameOutput = voterSecurityMap[msg.sender].securityList[index].name;
        // return securityNameOutput; 
    } 

    function getVoterSecurityCount() public view returns(uint count){
        count = voterSecurityMap[msg.sender].count;
        return count;
    }

    function getVoterSecurityNameByIndex(uint index) public view returns(string memory securityName){
        securityName = voterSecurityMap[msg.sender].securityList[index].name;
        return securityName;
    }
}