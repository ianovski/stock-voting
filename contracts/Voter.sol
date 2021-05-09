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
        uint upVotes;
        uint downVotes;
        int score;
        bool exists;
        string next;
        string prev;
    }
    mapping (string => SecurityPos) securityVotes;
    
    /**
     * @dev initializes security position linked list
     * @param stockName stock ticker name
     * @param voteState vote state input (up, down, unvote)
     */
    function initSecurityPos(string memory stockName, VotingState voteState) public{
        uint upVotes = voteState == VotingState.UpVoted ? 1 : 0;
        uint downVotes = voteState == VotingState.DownVoted ? 1 : 0;
        SecurityPos memory securityPos = SecurityPos({
            name:stockName,
            upVotes: upVotes,
            downVotes: downVotes,
            score: upVotes - downVotes,
            exists: true,
            next: 'none',
            prev: 'none'
        });
        securityVotes[0] = securityPos;
    }

    /**
    * @dev add new security to security pos linked list
    * @param stockName stock ticker name
    * @param voteState vote state (up, down, unvote)
    */
    function appendSecurityPos(string memory stockName, VotingState voteState) public{
        // TODO: find out which securities have values of updown<=downvote to find last position in rank (tied for last)
        uint upVotes = voteState == VotingState.UpVoted ? 1 : 0;
        uint downVotes = voteState == VotingState.DownVoted ? 1 : 0;
        int score = upVotes - downVotes;
        uint position = findSecurityPosByScore(score);
        // if tied, how do you update all following values?
        SecurityPos memory securityPos = SecurityPos({
            name:stockName,
            upVotes: upVotes,
            downVotes: downVotes,
            score: 1,
            exists: true,
            next: 'none',
            prev: 'none'
        });
        securityVotes[stockName] = securityPos;
    }

    /**
     * @dev binary search implementation to find the position of a security given a score (random if tied)
     * @param score - the net score of a security
     * @return the position of the security
     */
    function findSecurityNameByScore(int score) public returns (string name){
        uint securitiesCount = securities.length;
        name = binarySearchPosScore(score, 0, securitiesCount-1);
        return position > 0 ? position : securitiesCount;
    }

    /**
     * @dev return the name of a security with the desired score
     * @param target - targetted score
     * @param left - leftmost boundary
     * @param right - rightmost boundary
     * @return name or security
    */
    function binarySearchNameScore(int target, uint left, uint right) returns(string name){
        if(left > right){
            return 'none';
        }
        uint mid = left + ((right-left)/2);
        if(securityVotes[mid].score == target){
            return securityVotes[mid].name;
        } else if (target < securityVotes[mid].score){
            return binarySearchPosScore(target, left, mid-1);
        } else{
            return binarySearchPosScore(target, mid+1, right);
        }
    }

    /**
     * @dev returns the name of a security in the SecurityPos struct given an index
     * @param _index - index of item in securityPos
     * @return name of security at given index
     */
    function getSecurityPosByIndex(int _index) returns string(_name){
        string currentName;
        for(int i = 0; i<_index; i++){

        }

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