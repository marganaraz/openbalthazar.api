[{"SourceCode":"pragma solidity ^0.5.1;\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n// \u0027GOLD\u0027 contract\r\n\r\n// Mineable ERC20 Token using Proof Of Work\r\n\r\n//\r\n\r\n// Symbol      : AU79\r\n\r\n// Name        : GOLD\r\n\r\n// Total supply: 21,000,000.00\r\n\r\n// Decimals    : 8\r\n\r\n//\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n// Safe maths\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\nlibrary SafeMath {\r\n\r\n    function add(uint a, uint b) internal pure returns (uint c) {\r\n\r\n        c = a \u002B b;\r\n\r\n        require(c \u003E= a);\r\n\r\n    }\r\n\r\n    function sub(uint a, uint b) internal pure returns (uint c) {\r\n\r\n        require(b \u003C= a);\r\n\r\n        c = a - b;\r\n\r\n    }\r\n\r\n    function mul(uint a, uint b) internal pure returns (uint c) {\r\n\r\n        c = a * b;\r\n\r\n        require(a == 0 || c / a == b);\r\n\r\n    }\r\n\r\n    function div(uint a, uint b) internal pure returns (uint c) {\r\n\r\n        require(b \u003E 0);\r\n\r\n        c = a / b;\r\n\r\n    }\r\n\r\n}\r\n\r\n\r\n\r\nlibrary ExtendedMath {\r\n\r\n\r\n    //return the smaller of the two inputs (a or b)\r\n    function limitLessThan(uint a, uint b) internal pure returns (uint c) {\r\n\r\n        if(a \u003E b) return b;\r\n\r\n        return a;\r\n\r\n    }\r\n}\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n// ERC Token Standard #20 Interface\r\n\r\n// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\ncontract ERC20Interface {\r\n\r\n    function totalSupply() public view returns (uint);\r\n\r\n    function balanceOf(address tokenOwner) public view returns (uint balance);\r\n\r\n    function allowance(address tokenOwner, address spender) public view returns (uint remaining);\r\n\r\n    function transfer(address to, uint tokens) public returns (bool success);\r\n\r\n    function approve(address spender, uint tokens) public returns (bool success);\r\n\r\n    function transferFrom(address from, address to, uint tokens) public returns (bool success);\r\n\r\n\r\n    event Transfer(address indexed from, address indexed to, uint tokens);\r\n\r\n    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n\r\n}\r\n\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n// Contract function to receive approval and execute function in one call\r\n\r\n//\r\n\r\n// Borrowed from MiniMeToken\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\ncontract ApproveAndCallFallBack {\r\n\r\n    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;\r\n\r\n}\r\n\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n// Owned contract\r\n\r\n// ----------------------------------------------------------------------------\r\ncontract Owned {\r\n    address public owner;\r\n    address public newOwner;\r\n\r\n    event OwnershipTransferred(address indexed _from, address indexed _to);\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    function transferOwnership(address _newOwner) public onlyOwner {\r\n        newOwner = _newOwner;\r\n    }\r\n    function acceptOwnership() public {\r\n        require(msg.sender == newOwner);\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n        newOwner = address(0);\r\n    }\r\n}\r\n// ----------------------------------------------------------------------------\r\n\r\n// ERC20 Token, with the addition of symbol, name and decimals and an\r\n\r\n// initial fixed supply\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\ncontract GOLD is ERC20Interface, Owned {\r\n\r\n    using SafeMath for uint;\r\n    using ExtendedMath for uint;\r\n\r\n\r\n    string public symbol;\r\n\r\n    string public  name;\r\n\r\n    uint8 public decimals;\r\n\r\n    uint public _totalSupply;\r\n\r\n\r\n\r\n     uint public latestDifficultyPeriodStarted;\r\n\r\n\r\n\r\n    uint public epochCount;//number of \u0027blocks\u0027 mined\r\n\r\n\r\n    uint public _BLOCKS_PER_READJUSTMENT = 1024;\r\n\r\n\r\n    //a little number\r\n    uint public  _MINIMUM_TARGET = 2**16;\r\n\r\n\r\n      //a big number is easier ; just find a solution that is smaller\r\n    //uint public  _MAXIMUM_TARGET = 2**224;  bitcoin uses 224\r\n    uint public  _MAXIMUM_TARGET = 2**234;\r\n\r\n\r\n    uint public miningTarget;\r\n\r\n    bytes32 public challengeNumber;   //generate a new one when a new reward is minted\r\n\r\n\r\n\r\n    uint public rewardEra;\r\n    uint public maxSupplyForEra;\r\n\r\n\r\n    address public lastRewardTo;\r\n    uint public lastRewardAmount;\r\n    uint public lastRewardEthBlockNumber;\r\n\r\n    bool locked = false;\r\n\r\n    mapping(bytes32 =\u003E bytes32) solutionForChallenge;\r\n\r\n    uint public tokensMinted;\r\n\r\n    mapping(address =\u003E uint) balances;\r\n\r\n\r\n    mapping(address =\u003E mapping(address =\u003E uint)) allowed;\r\n\r\n\r\n    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Constructor\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    constructor () public onlyOwner{\r\n\r\n\r\n\r\n        symbol = \u0022AU79\u0022;\r\n\r\n        name = \u0022GOLD\u0022;\r\n\r\n        decimals = 8;\r\n\r\n        _totalSupply = 21000000 * 10**uint(decimals);\r\n\r\n        if(locked) revert();\r\n        locked = true;\r\n\r\n        tokensMinted = 0;\r\n\r\n        rewardEra = 0;\r\n        maxSupplyForEra = _totalSupply.div(2);\r\n\r\n        miningTarget = _MAXIMUM_TARGET;\r\n\r\n        latestDifficultyPeriodStarted = block.number;\r\n\r\n        _startNewMiningEpoch();\r\n\r\n\r\n        //The owner gets nothing! You must mine this ERC20 token\r\n        //balances[owner] = _totalSupply;\r\n        //Transfer(address(0), owner, _totalSupply);\r\n\r\n    }\r\n\r\n\r\n\r\n\r\n        function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success) {\r\n\r\n\r\n            //the PoW must contain work that includes a recent ethereum block hash (challenge number) and the msg.sender\u0027s address to prevent MITM attacks\r\n            bytes32 digest =  keccak256(abi.encodePacked(challengeNumber, msg.sender, nonce ));\r\n\r\n            //the challenge digest must match the expected\r\n            if (digest != challenge_digest) revert();\r\n\r\n            //the digest must be smaller than the target\r\n            if(uint256(digest) \u003E miningTarget) revert();\r\n\r\n\r\n            //only allow one reward for each challenge\r\n             bytes32 solution = solutionForChallenge[challengeNumber];\r\n             solutionForChallenge[challengeNumber] = digest;\r\n             if(solution != 0x0) revert();  //prevent the same answer from awarding twice\r\n\r\n\r\n            uint reward_amount = getMiningReward();\r\n\r\n            balances[msg.sender] = balances[msg.sender].add(reward_amount);\r\n\r\n            tokensMinted = tokensMinted.add(reward_amount);\r\n\r\n\r\n            //Cannot mint more tokens than there are\r\n            assert(tokensMinted \u003C= maxSupplyForEra);\r\n\r\n            //set readonly diagnostics data\r\n            lastRewardTo = msg.sender;\r\n            lastRewardAmount = reward_amount;\r\n            lastRewardEthBlockNumber = block.number;\r\n\r\n\r\n             _startNewMiningEpoch();\r\n\r\n              emit Mint(msg.sender, reward_amount, epochCount, challengeNumber );\r\n\r\n           return true;\r\n\r\n        }\r\n\r\n\r\n    //a new \u0027block\u0027 to be mined\r\n    function _startNewMiningEpoch() internal {\r\n\r\n      //if max supply for the era will be exceeded next reward round then enter the new era before that happens\r\n\r\n      //40 is the final reward era, almost all tokens minted\r\n      //once the final era is reached, more tokens will not be given out because the assert function\r\n      if( tokensMinted.add(getMiningReward()) \u003E maxSupplyForEra \u0026\u0026 rewardEra \u003C 39)\r\n      {\r\n        rewardEra = rewardEra \u002B 1;\r\n      }\r\n\r\n      //set the next minted supply at which the era will change\r\n      // total supply is 2100000000000000  because of 8 decimal places\r\n      maxSupplyForEra = _totalSupply - _totalSupply.div( 2**(rewardEra \u002B 1));\r\n\r\n      epochCount = epochCount.add(1);\r\n\r\n      //every so often, readjust difficulty. Dont readjust when deploying\r\n      if(epochCount % _BLOCKS_PER_READJUSTMENT == 0)\r\n      {\r\n        _reAdjustDifficulty();\r\n      }\r\n\r\n\r\n      //make the latest ethereum block hash a part of the next challenge for PoW to prevent pre-mining future blocks\r\n      //do this last since this is a protection mechanism in the mint() function\r\n      challengeNumber = blockhash(block.number - 1);\r\n\r\n\r\n\r\n\r\n\r\n\r\n    }\r\n\r\n\r\n\r\n\r\n    //https://en.bitcoin.it/wiki/Difficulty#What_is_the_formula_for_difficulty.3F\r\n    //as of 2017 the bitcoin difficulty was up to 17 zeroes, it was only 8 in the early days\r\n\r\n    //readjust the target by 5 percent\r\n    function _reAdjustDifficulty() internal {\r\n\r\n\r\n        uint ethBlocksSinceLastDifficultyPeriod = block.number - latestDifficultyPeriodStarted;\r\n        //assume 360 ethereum blocks per hour\r\n\r\n        //we want miners to spend 10 minutes to mine each \u0027block\u0027, about 60 ethereum blocks = one GOLD epoch\r\n        uint epochsMined = _BLOCKS_PER_READJUSTMENT; //256\r\n\r\n        uint targetEthBlocksPerDiffPeriod = epochsMined * 60; //should be 60 times slower than ethereum\r\n\r\n        //if there were less eth blocks passed in time than expected\r\n        if( ethBlocksSinceLastDifficultyPeriod \u003C targetEthBlocksPerDiffPeriod )\r\n        {\r\n          uint excess_block_pct = (targetEthBlocksPerDiffPeriod.mul(100)).div( ethBlocksSinceLastDifficultyPeriod );\r\n\r\n          uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(1000);\r\n          // If there were 5% more blocks mined than expected then this is 5.  If there were 100% more blocks mined than expected then this is 100.\r\n\r\n          //make it harder\r\n          miningTarget = miningTarget.sub(miningTarget.div(2000).mul(excess_block_pct_extra));   //by up to 50 %\r\n        }else{\r\n          uint shortage_block_pct = (ethBlocksSinceLastDifficultyPeriod.mul(100)).div( targetEthBlocksPerDiffPeriod );\r\n\r\n          uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(1000); //always between 0 and 1000\r\n\r\n          //make it easier\r\n          miningTarget = miningTarget.add(miningTarget.div(2000).mul(shortage_block_pct_extra));   //by up to 50 %\r\n        }\r\n\r\n\r\n\r\n        latestDifficultyPeriodStarted = block.number;\r\n\r\n        if(miningTarget \u003C _MINIMUM_TARGET) //very difficult\r\n        {\r\n          miningTarget = _MINIMUM_TARGET;\r\n        }\r\n\r\n        if(miningTarget \u003E _MAXIMUM_TARGET) //very easy\r\n        {\r\n          miningTarget = _MAXIMUM_TARGET;\r\n        }\r\n    }\r\n\r\n\r\n    //this is a recent ethereum block hash, used to prevent pre-mining future blocks\r\n    function getChallengeNumber() public view returns (bytes32) {\r\n        return challengeNumber;\r\n    }\r\n\r\n    //the number of zeroes the digest of the PoW solution requires.  Auto adjusts\r\n     function getMiningDifficulty() public view returns (uint) {\r\n        return _MAXIMUM_TARGET.div(miningTarget);\r\n    }\r\n\r\n    function getMiningTarget() public view returns (uint) {\r\n       return miningTarget;\r\n   }\r\n\r\n\r\n\r\n    //21m coins total\r\n    //reward begins at 50 and is cut in half every reward era (as tokens are mined)\r\n    function getMiningReward() public view returns (uint) {\r\n        //once we get half way thru the coins, only get 25 per block\r\n\r\n         //every reward era, the reward amount halves.\r\n\r\n         return (50 * 10**uint(decimals) ).div( 2**rewardEra ) ;\r\n\r\n    }\r\n\r\n    //help debug mining software\r\n    function getMintDigest(uint256 nonce, bytes32 challenge_number) public view returns (bytes32 digesttest) {\r\n\r\n        bytes32 digest = keccak256(abi.encodePacked(challenge_number,msg.sender,nonce));\r\n\r\n        return digest;\r\n\r\n      }\r\n\r\n        //help debug mining software\r\n      function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns (bool success) {\r\n\r\n          bytes32 digest = keccak256(abi.encodePacked(challenge_number,msg.sender,nonce));\r\n\r\n          if(uint256(digest) \u003E testTarget) revert();\r\n\r\n          return (digest == challenge_digest);\r\n\r\n        }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Total supply\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function totalSupply() public view returns (uint) {\r\n\r\n        return _totalSupply  - balances[address(0)];\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Get the token balance for account \u0060tokenOwner\u0060\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function balanceOf(address tokenOwner) public view returns (uint balance) {\r\n\r\n        return balances[tokenOwner];\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Transfer the balance from token owner\u0027s account to \u0060to\u0060 account\r\n\r\n    // - Owner\u0027s account must have sufficient balance to transfer\r\n\r\n    // - 0 value transfers are allowed\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function transfer(address to, uint tokens) public returns (bool success) {\r\n\r\n        balances[msg.sender] = balances[msg.sender].sub(tokens);\r\n\r\n        balances[to] = balances[to].add(tokens);\r\n\r\n        emit Transfer(msg.sender, to, tokens);\r\n\r\n        return true;\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Token owner can approve for \u0060spender\u0060 to transferFrom(...) \u0060tokens\u0060\r\n\r\n    // from the token owner\u0027s account\r\n\r\n    //\r\n\r\n    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\r\n\r\n    // recommends that there are no checks for the approval double-spend attack\r\n\r\n    // as this should be implemented in user interfaces\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function approve(address spender, uint tokens) public returns (bool success) {\r\n\r\n        allowed[msg.sender][spender] = tokens;\r\n\r\n        emit Approval(msg.sender, spender, tokens);\r\n\r\n        return true;\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Transfer \u0060tokens\u0060 from the \u0060from\u0060 account to the \u0060to\u0060 account\r\n\r\n    //\r\n\r\n    // The calling account must already have sufficient tokens approve(...)-d\r\n\r\n    // for spending from the \u0060from\u0060 account and\r\n\r\n    // - From account must have sufficient balance to transfer\r\n\r\n    // - Spender must have sufficient allowance to transfer\r\n\r\n    // - 0 value transfers are allowed\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function transferFrom(address from, address to, uint tokens) public returns (bool success) {\r\n\r\n        balances[from] = balances[from].sub(tokens);\r\n\r\n        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);\r\n\r\n        balances[to] = balances[to].add(tokens);\r\n\r\n        emit Transfer(from, to, tokens);\r\n\r\n        return true;\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Returns the amount of tokens approved by the owner that can be\r\n\r\n    // transferred to the spender\u0027s account\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {\r\n\r\n        return allowed[tokenOwner][spender];\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Token owner can approve for \u0060spender\u0060 to transferFrom(...) \u0060tokens\u0060\r\n\r\n    // from the token owner\u0027s account. The \u0060spender\u0060 contract function\r\n\r\n    // \u0060receiveApproval(...)\u0060 is then executed\r\n\r\n    // ------------------------------------------------------------------------\r\n    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {\r\n        allowed[msg.sender][spender] = tokens;\r\n        emit Approval(msg.sender, spender, tokens);\r\n        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);\r\n        return true;\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Don\u0027t accept ETH\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function () external payable {\r\n\r\n        revert();\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Owner can transfer out any accidentally sent ERC20 tokens\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {\r\n\r\n        return ERC20Interface(tokenAddress).transfer(owner, tokens);\r\n\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lastRewardEthBlockNumber\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMiningDifficulty\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022challenge_digest\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022rewardEra\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMiningTarget\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMiningReward\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getChallengeNumber\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022maxSupplyForEra\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokensMinted\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lastRewardTo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022challenge_digest\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022challenge_number\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022testTarget\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022checkMintSolution\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022epochCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_MAXIMUM_TARGET\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022miningTarget\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022challengeNumber\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022challenge_number\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getMintDigest\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022digesttest\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_BLOCKS_PER_READJUSTMENT\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lastRewardAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022latestDifficultyPeriodStarted\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferAnyERC20Token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_MINIMUM_TARGET\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022reward_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022epochCount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newChallengeNumber\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022Mint\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"GOLD","CompilerVersion":"v0.5.1\u002Bcommit.c8a2cb62","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://6dd38d9c8ad970eff0e7bb695eed902b8db47d48a0c134411ccfdaa6587b03b5"}]