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
        //TODO: change upVotes and downVotes to uint
        string name;
        int upVotes;
        int downVotes;
        int score;
        bool exists;
        string next;
        string prev;
    }
    mapping (string => SecurityPos) securityVotes;
    string public securityHead;
    
    /**
     * @dev initializes security position linked list
     * @param stockName stock ticker name
     * @param voteState vote state input (up, down, unvote)
     */
    function initSecurityPos(string memory stockName, VotingState voteState) public{
        int upVotes = voteState == VotingState.UpVoted ? 1 : 0;
        int downVotes = voteState == VotingState.DownVoted ? 1 : 0;
        SecurityPos memory securityPos = SecurityPos({
            name:stockName,
            upVotes: upVotes,
            downVotes: downVotes,
            score: upVotes - downVotes, // Need to parse uint to int
            exists: true,
            next: 'none',
            prev: 'none'
        });
        securityVotes[stockName] = securityPos;
        securityHead = stockName;
    }

    /**
     * @dev Updates score of existing seurity
     * @param stockName stock ticker name
     * @param voteState vote state input (up, down, unvote)
     */
    function updateSecurityPosScore(string memory stockName, VotingState voteState) public{
        int upVotes = voteState == VotingState.UpVoted ? 1 : 0;
        int downVotes = voteState == VotingState.DownVoted ? 1 : 0;
        int newScore = securityVotes[stockName].upVotes + upVotes - securityVotes[stockName].downVotes - downVotes;
        updatePositions(stockName, newScore);
        securityVotes[stockName].score = newScore;
        securityHead = stockName;
    }

    /**
     * @dev update secuirty and adjacent security positions if rank of security is reduced
     * @param security - name of updated security
     * @param nextSecurity - name of adjacent higher ranked security
     */
    function updateDownRankedPosition(string memory security, string memory nextSecurity, string memory prevSecurity){
        // swap positions
        securityVotes[security].next = securityVotes[nextSecurity].next;
        securityVotes[security].prev = nextSecurity;
        securityVotes[nextSecurity].prev = prevSecurity;
        securityVotes[nextSecurity].next = security;

        // update adjacent links
        securityVotes[prevSecurity].next = nextSecurity;
        nextSecurity = securityVotes[security].next;
        if(securityVotes[security].next != 'none'){
            securityVotes[nextSecurity].prev = security;
        }
    }

    function updateUpRankedPosition(string memory security, string memory nextSecurity, string memory prevSecurity){
        // swap positions
        securityVotes[security].next = prevSecurity;
        securityVotes[security].prev = securityVotes[prevSecurity].prev;
        securityVotes[prevSecurity].prev = security;
        securityVotes[prevSecurity].next = nextSecurity;

        // update adjacent links
        securityVotes[nextSecurity].prev = prevSecurity;
        prevSecurity = securityVotes[security].prev;
        if(securityVotes[security].prev != 'none'){
            securityVotes[prevSecurity].next = security;
        }
    }

    function updatePositions(string memory security, int newScore) public {
        string memory nextSecurity = securityVotes[security].next;
        string memory prevSecurity = securityVotes[security].prev;
        if(newScore < securityVotes[nextSecurity].score){
            updateDownRankedPosition(security, nextSecurity);
        }
        if(newScore > securityVotes[prevSecurity].score){
            updateUpRankedPosition(security, nextSecurity);
        }
    }

    /**
    * @dev add new security to security pos linked list
    * @param stockName stock ticker name
    * @param voteState vote state (up, down, unvote)
    */
    function appendSecurityPos(string memory stockName, VotingState voteState) public{
        // TODO: find out which securities have values of updown<=downvote to find last position in rank (tied for last)
        // TODO: change upVotes and downVotes to uint
        int upVotes = voteState == VotingState.UpVoted ? 1 : 0;
        int downVotes = voteState == VotingState.DownVoted ? 1 : 0;
        int score = upVotes - downVotes;
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
    * @dev returns the name of a security <= to given score
    * @param _score - voting score
    * @return name of security
    */
    function getSecurityNameByScore(int _score) public view returns(string memory name){
        bool scoreFound = false;
        name = 'none';
        string memory current = securityHead;
        return securityHead;
        uint count = 0;
        while(!scoreFound && count < securities.length){
            if(securityVotes[current].score <= _score){
                name = current;
                scoreFound = true;
            }
            else{
                current = securityVotes[current].next;
                count++;
            }
        }
        return name;
    }

    // /**
    //  * @dev binary search implementation to find the position of a security given a score (random if tied)
    //  * @param score - the net score of a security
    //  * @return the position of the security
    //  */
    // function findSecurityNameByScore(int score) public returns (string memory name){
    //     uint securitiesCount = securities.length;
    //     name = binarySearchPosScore(score, 0, securitiesCount-1);
    //     return position > 0 ? position : securitiesCount;
    // }

    // /**
    //  * @dev return the name of a security with the desired score
    //  * @param target - targetted score
    //  * @param left - leftmost boundary
    //  * @param right - rightmost boundary
    //  * @return name or security
    // */
    // function binarySearchNameScore(int target, uint left, uint right) public returns(string memory name){
    //     if(left > right){
    //         return 'none';
    //     }
    //     uint mid = left + ((right-left)/2);
    //     if(securityVotes[mid].score == target){
    //         return securityVotes[mid].name;
    //     } else if (target < securityVotes[mid].score){
    //         return binarySearchPosScore(target, left, mid-1);
    //     } else{
    //         return binarySearchPosScore(target, mid+1, right);
    //     }
    // }

    // /**
    //  * @dev returns the name of a security in the SecurityPos struct given an index
    //  * @param _index - index of item in securityPos
    //  * @return name of security at given index
    //  */
    // function getSecurityNameByIndex(int _index) public returns (string memory _name){
    //     string memory currentName;
    //     for(int i = 0; i<_index; i++){

    //     }

    // }
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

    // /**
    //  * @dev gets position of security in overall stock ranking
    //  * @param securityName stock ticker
    //  * @return position
    //  */
    // function getSecurityPos(string memory securityName) public view returns (uint pos){
    //     return securityVotes[securityName].pos;
    // }
}