[{"SourceCode":"pragma solidity ^ 0.5 .1;\r\n\r\n// ----------------------------------------------------------------------------\r\n//\u0027ButtCoin\u0027 contract, version 2.1\r\n// See: https://github.com/butttcoin/0xBUTT\r\n// Symbol      : 0xBUTT\r\n// Name        : ButtCoin\r\n// Total supply: Dynamic\r\n// Decimals    : 8\r\n// ----------------------------------------------------------------------------\r\n\r\n// ----------------------------------------------------------------------------\r\n// Safe maths\r\n// ----------------------------------------------------------------------------\r\n\r\nlibrary SafeMath {\r\n\r\n  //addition\r\n  function add(uint a, uint b) internal pure returns(uint c) {\r\n    c = a \u002B b;\r\n    require(c \u003E= a);\r\n  }\r\n\r\n  //subtraction\r\n  function sub(uint a, uint b) internal pure returns(uint c) {\r\n    require(b \u003C= a);\r\n    c = a - b;\r\n  }\r\n\r\n  //multiplication\r\n  function mul(uint a, uint b) internal pure returns(uint c) {\r\n    c = a * b;\r\n    require(a == 0 || c / a == b);\r\n  }\r\n\r\n  //division\r\n  function div(uint a, uint b) internal pure returns(uint c) {\r\n    require(b \u003E 0);\r\n    c = a / b;\r\n  }\r\n\r\n  //ceil\r\n  function ceil(uint a, uint m) internal pure returns(uint) {\r\n    uint c = add(a, m);\r\n    uint d = sub(c, 1);\r\n    return mul(div(d, m), m);\r\n  }\r\n\r\n}\r\n\r\nlibrary ExtendedMath {\r\n  //also known as the minimum\r\n  function limitLessThan(uint a, uint b) internal pure returns(uint c) {\r\n    if (a \u003E b) return b;\r\n    return a;\r\n  }\r\n}\r\n\r\n// ----------------------------------------------------------------------------\r\n// ERC Token Standard #20 Interface\r\n// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\r\n// ----------------------------------------------------------------------------\r\n\r\ncontract ERC20Interface {\r\n\r\n  function totalSupply() public view returns(uint);\r\n\r\n  function burned() public view returns(uint);\r\n\r\n  function minted() public view returns(uint);\r\n\r\n  function mintingEpoch() public view returns(uint);\r\n\r\n  function balanceOf(address tokenOwner) public view returns(uint balance);\r\n\r\n  function allowance(address tokenOwner, address spender) public view returns(uint remaining);\r\n\r\n  function transfer(address to, uint tokens) public returns(bool success);\r\n\r\n  function approve(address spender, uint tokens) public returns(bool success);\r\n\r\n  function transferFrom(address from, address to, uint tokens) public returns(bool success);\r\n\r\n  event Transfer(address indexed from, address indexed to, uint tokens);\r\n  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n}\r\n\r\n// ----------------------------------------------------------------------------\r\n// Contract function to receive approval and execute function in one call\r\n// ----------------------------------------------------------------------------\r\ncontract ApproveAndCallFallBack {\r\n  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;\r\n}\r\n\r\n// ----------------------------------------------------------------------------\r\n// Owned contract\r\n// ----------------------------------------------------------------------------\r\n\r\ncontract Owned {\r\n\r\n  address public owner;\r\n  address public newOwner;\r\n\r\n  event OwnershipTransferred(address indexed _from, address indexed _to);\r\n\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  modifier onlyOwner {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  function transferOwnership(address _newOwner) public onlyOwner {\r\n    newOwner = _newOwner;\r\n  }\r\n\r\n  function acceptOwnership() public {\r\n    require(msg.sender == newOwner);\r\n    emit OwnershipTransferred(owner, newOwner);\r\n    owner = newOwner;\r\n    newOwner = address(0);\r\n  }\r\n}\r\n\r\n// ----------------------------------------------------------------------------\r\n// ERC20 Token, with the addition of symbol, name and decimals and an\r\n// initial fixed supply\r\n// ----------------------------------------------------------------------------\r\n\r\ncontract ZERO_X_BUTTv3 is ERC20Interface, Owned {\r\n\r\n  using SafeMath for uint;\r\n  using ExtendedMath for uint;\r\n\r\n  string public symbol;\r\n  string public name;\r\n  uint8 public decimals;\r\n  uint256 public _totalSupply;\r\n  uint256 public _burned;\r\n\r\n  //a big number is easier ; just find a solution that is smaller\r\n  uint private n = 212; //the maxiumum target exponent\r\n  uint private nFutureTime = now \u002B 1097 days; // about 3 years in future\r\n  \r\n  uint public _MAXIMUM_TARGET = 2 ** n;\r\n\r\n  bytes32 public challengeNumber; //generate a new one when a new reward is minted\r\n\r\n  uint public rewardEra;\r\n\r\n  address public lastRewardTo;\r\n  uint public lastRewardAmount;\r\n  uint public lastRewardEthBlockNumber;\r\n\r\n  mapping(bytes32 =\u003E bytes32) solutionForChallenge;\r\n  uint public tokensMinted;\r\n\r\n  mapping(address =\u003E uint) balances;\r\n  mapping(address =\u003E mapping(address =\u003E uint)) allowed;\r\n\r\n  uint private basePercent;\r\n  bool private locked = false;\r\n  address private previousSender = address(0); //the previous user of a contract\r\n\r\n  uint private miningTarget;\r\n  uint private _mintingEpoch;\r\n\r\n  event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Constructor\r\n  // ------------------------------------------------------------------------\r\n\r\n  constructor() public {\r\n    if (locked) revert();\r\n\r\n    symbol = \u00220xBUTT\u0022;\r\n    name = \u0022ButtCoin\u0022;\r\n    decimals = 8;\r\n    basePercent = 100;\r\n\r\n    uint toMint = 33554432 * 10 ** uint(decimals); //This is an assumption and a kick-start, which resets when 75% is burned.\r\n    _mint(msg.sender, toMint);\r\n\r\n    tokensMinted = toMint;\r\n    _totalSupply = _totalSupply.add(toMint);\r\n    rewardEra = 22;\r\n    miningTarget = _MAXIMUM_TARGET;\r\n    _startNewMiningEpoch();\r\n\r\n    _mintingEpoch = 0;\r\n\r\n    locked = true;\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Minting tokens before the mining.\r\n  // ------------------------------------------------------------------------\r\n  function _mint(address account, uint256 amount) internal {\r\n    if (locked) revert();\r\n    require(amount != 0);\r\n    balances[account] = balances[account].add(amount);\r\n    emit Transfer(address(0), account, amount);\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Minting of tokens during the mining.\r\n  // ------------------------------------------------------------------------\r\n  function mint(uint256 nonce, bytes32 challenge_digest) public returns(bool success) {\r\n    //the PoW must contain work that includes a recent ethereum block hash (challenge number) and the msg.sender\u0027s address to prevent MITM attacks\r\n    bytes32 digest = keccak256(abi.encodePacked(challengeNumber, msg.sender, nonce));\r\n\r\n    //the challenge digest must match the expected\r\n    if (digest != challenge_digest) revert();\r\n\r\n    //the digest must be smaller than the target\r\n    if (uint256(digest) \u003E miningTarget) revert();\r\n\r\n    //only allow one reward for each challenge\r\n    bytes32 solution = solutionForChallenge[challengeNumber];\r\n    solutionForChallenge[challengeNumber] = digest;\r\n    if (solution != 0x0) revert(); //prevent the same answer from awarding twice\r\n\r\n    uint reward_amount = getMiningReward();\r\n    balances[msg.sender] = balances[msg.sender].add(reward_amount);\r\n    tokensMinted = tokensMinted.add(reward_amount);\r\n    _totalSupply = _totalSupply.add(tokensMinted);\r\n\r\n    //set readonly diagnostics data\r\n    lastRewardTo = msg.sender;\r\n    lastRewardAmount = reward_amount;\r\n    lastRewardEthBlockNumber = block.number;\r\n\r\n    _startNewMiningEpoch();\r\n    emit Mint(msg.sender, reward_amount, rewardEra, challengeNumber);\r\n\r\n    return true;\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Starts a new mining epoch, a new \u0027block\u0027 to be mined.\r\n  // ------------------------------------------------------------------------\r\n  function _startNewMiningEpoch() internal {\r\n    rewardEra = rewardEra \u002B 1; //increment the rewardEra\r\n    checkMintedNumber();\r\n    _reAdjustDifficulty();\r\n    challengeNumber = blockhash(block.number - 1);\r\n  }\r\n\r\n  //checks if the minted number is too high, reduces a tracking number if it is\r\n  function checkMintedNumber() internal {\r\n    if (tokensMinted \u003E= (2 ** (230))) { //This will not happen in the forseable future.\r\n        \r\n        //50 is neither too low or too high, we\u0027d need additional tracking to get overall totals after this.\r\n        tokensMinted = tokensMinted.div(2 ** (50));\r\n        _burned = _burned.div(2 ** (50));\r\n         \r\n      _mintingEpoch = _mintingEpoch \u002B 1;\r\n    }\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Readjust difficulty\r\n  // ------------------------------------------------------------------------\r\n  function _reAdjustDifficulty() internal {\r\n    n = n - 1;\r\n    miningTarget = (2 ** n);\r\n    nFutureTime = now \u002B 1097 days;\r\n    \r\n    //if difficulty level became too much for the miners and coins are running out of a supply, we need to lower a difficulty to mint new coins...\r\n    //this way, the coin does not become store of a value. Nevertheless, it may be required for the miners to do some extra work to lower a difficulty.\r\n    uint treshold = (tokensMinted.mul(95)).div(100);\r\n    if(_burned\u003E=treshold){\r\n        //lower difficulty to significant levels\r\n        n = (n.mul(105)).div(100);\r\n        if(n \u003E 213){n = 213;}\r\n        miningTarget = (2 ** n);\r\n    }\r\n  }\r\n\r\n  // -------------------------------------------------------------------------------\r\n  // this is a recent ethereum block hash, used to prevent pre-mining future blocks.\r\n  // -------------------------------------------------------------------------------\r\n  function getChallengeNumber() public view returns(bytes32) {\r\n    return challengeNumber;\r\n  }\r\n\r\n  // -------------------------------------------------------------------------------\r\n  // Auto adjusts the number of zeroes the digest of the PoW solution requires.  \r\n  // -------------------------------------------------------------------------------\r\n  function getMiningDifficulty() public view returns(uint) {\r\n    return _MAXIMUM_TARGET.div(miningTarget);\r\n  }\r\n\r\n  // -------------------------------------------------------------------------------\r\n  // returns the miningTarget.\r\n  // -------------------------------------------------------------------------------\r\n  function getMiningTarget() public view returns(uint) {\r\n    return miningTarget;\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Gives miners their earned reward, zero if everything is mined.\r\n  // ------------------------------------------------------------------------\r\n  function getMiningReward() internal returns(uint) {\r\n    uint reward = ((234 - n) ** 3) * 10 ** uint(decimals);\r\n    return reward;\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Used to help debugging the mining software.\r\n  // ------------------------------------------------------------------------\r\n  function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns(bytes32 digesttest) {\r\n    bytes32 digest = keccak256(abi.encodePacked(challenge_number, msg.sender, nonce));\r\n    return digest;\r\n\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Used to help debugging the mining software.\r\n  // ------------------------------------------------------------------------\r\n  function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns(bool success) {\r\n    bytes32 digest = keccak256(abi.encodePacked(challenge_number, msg.sender, nonce));\r\n    if (uint256(digest) \u003E testTarget) revert();\r\n    return (digest == challenge_digest);\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Total supply\r\n  // ------------------------------------------------------------------------\r\n  function totalSupply() public view returns(uint) {\r\n    return tokensMinted.sub(_burned);\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Burned tokens\r\n  // ------------------------------------------------------------------------\r\n  function burned() public view returns(uint) {\r\n    return _burned;\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Minted tokens\r\n  // ------------------------------------------------------------------------\r\n  function minted() public view returns(uint) {\r\n    return tokensMinted;\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Minting epoch\r\n  // ------------------------------------------------------------------------\r\n  function mintingEpoch() public view returns(uint) {\r\n    return _mintingEpoch;\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Get the token balance for account \u0060tokenOwner\u0060\r\n  // ------------------------------------------------------------------------\r\n\r\n  function balanceOf(address tokenOwner) public view returns(uint balance) {\r\n    return balances[tokenOwner];\r\n  }\r\n\r\n\r\n  function pulseCheck() internal{\r\n   //if either the coin is dead or the mining is stuck  \r\n    if(nFutureTime\u003C=now){\r\n      n = (n.mul(150)).div(100); \r\n      miningTarget = (2 ** n);\r\n      _startNewMiningEpoch();\r\n    }  \r\n      \r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Transfer the balance from token owner\u0027s account to \u0060to\u0060 account\r\n  // - Owner\u0027s account must have sufficient balance to transfer\r\n  // - 0 value transfers are allowed\r\n  // ------------------------------------------------------------------------\r\n \r\n\r\n  //Otherwise, it is a bug\r\n  function sendTo(address to, uint tokens) public returns(bool success) {\r\n    balances[msg.sender] = balances[msg.sender].sub(tokens);\r\n    balances[to] = balances[to].add(tokens);\r\n    emit Transfer(msg.sender, to, tokens);\r\n    return true;\r\n  }\r\n \r\n\r\n  function transfer(address to, uint tokens) public returns(bool success) {\r\n      \r\n    pulseCheck(); \r\n\r\n    balances[msg.sender] = balances[msg.sender].sub(tokens);\r\n\r\n    balances[to] = balances[to].add(tokens);\r\n\r\n    uint256 tokensToBurn = findTwoPercent(tokens);\r\n    uint256 toZeroAddress = tokensToBurn.div(2);\r\n    uint256 toPreviousAddress = tokensToBurn.sub(toZeroAddress);\r\n    uint256 tokensToTransfer = tokens.sub(toZeroAddress.add(toPreviousAddress));\r\n\r\n     sendTo(msg.sender, to, tokensToTransfer);\r\n     sendTo(msg.sender, address(0), toZeroAddress);\r\n    if (previousSender != to) { //Don\u0027t send the tokens to yourself\r\n     sendTo(to, previousSender, toPreviousAddress);\r\n      if (previousSender == address(0)) {\r\n        _burned = _burned.add(toPreviousAddress);\r\n      }\r\n    }\r\n\r\n    if (to == address(0)) {\r\n      _burned = _burned.add(tokensToTransfer);\r\n    }\r\n\r\n    _burned = _burned.add(toZeroAddress);\r\n\r\n    _totalSupply = totalSupply();\r\n    previousSender = msg.sender;\r\n    return true;\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Transfers to multiple accounts\r\n  // ------------------------------------------------------------------------\r\n  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {\r\n    for (uint256 i = 0; i \u003C receivers.length; i\u002B\u002B) {\r\n      transfer(receivers[i], amounts[i]);\r\n    }\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Calculates 2% for burning\r\n  // ------------------------------------------------------------------------\r\n  function findTwoPercent(uint256 value) private view returns(uint256) {\r\n    uint256 roundValue = value.ceil(basePercent);\r\n    uint256 onePercent = roundValue.mul(basePercent).div(10000);\r\n    return onePercent.mul(2);\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Token owner can approve for \u0060spender\u0060 to transferFrom(...) \u0060tokens\u0060\r\n  // from the token owner\u0027s account\r\n  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\r\n  // recommends that there are no checks for the approval double-spend attack\r\n  // as this should be implemented in user interfaces\r\n  // ------------------------------------------------------------------------\r\n  function approve(address spender, uint tokens) public returns(bool success) {\r\n    allowed[msg.sender][spender] = tokens;\r\n    emit Approval(msg.sender, spender, tokens);\r\n    return true;\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Transfer \u0060tokens\u0060 from the \u0060from\u0060 account to the \u0060to\u0060 account\r\n  // The calling account must already have sufficient tokens approve(...)-d\r\n  // for spending from the \u0060from\u0060 account and\r\n  // - From account must have sufficient balance to transfer\r\n  // - Spender must have sufficient allowance to transfer\r\n  // - 0 value transfers are allowed\r\n  // ------------------------------------------------------------------------\r\n\r\n  //otherwise, it is a bug\r\n    function sendTo(address from, address to, uint tokens) public returns(bool success) {\r\n        balances[msg.sender] = balances[msg.sender].sub(tokens);\r\n        balances[to] = balances[to].add(tokens);\r\n        emit Transfer(msg.sender, to, tokens);\r\n        return true;\r\n    }\r\n\r\n  function transferFrom(address from, address to, uint tokens) public returns(bool success) {\r\n    \r\n    pulseCheck();\r\n    \r\n    balances[from] = balances[from].sub(tokens);\r\n    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);\r\n    balances[to] = balances[to].add(tokens);\r\n\r\n    uint256 tokensToBurn = findTwoPercent(tokens);\r\n    uint256 toZeroAddress = tokensToBurn.div(2);\r\n    uint256 toPreviousAddress = tokensToBurn - toZeroAddress;\r\n    uint256 tokensToTransfer = tokens.sub(toZeroAddress).sub(toPreviousAddress);\r\n\r\n    sendTo(msg.sender, to, tokensToTransfer);\r\n    sendTo(msg.sender, address(0), toZeroAddress);\r\n    if (previousSender != to) { //Don\u0027t send tokens to yourself\r\n      sendTo(to, previousSender, toPreviousAddress);\r\n      if (previousSender == address(0)) {\r\n        _burned = _burned.add(toPreviousAddress);\r\n      }\r\n    }\r\n    if (to == address(0)) {\r\n      _burned = _burned.add(tokensToTransfer);\r\n    }\r\n\r\n    _burned = _burned.add(toZeroAddress);\r\n    _totalSupply = totalSupply();\r\n    previousSender = msg.sender;\r\n\r\n    return true;\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Returns the amount of tokens approved by the owner that can be\r\n  // transferred to the spender\u0027s account\r\n  // ------------------------------------------------------------------------\r\n  function allowance(address tokenOwner, address spender) public view returns(uint remaining) {\r\n    return allowed[tokenOwner][spender];\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Token owner can approve for \u0060spender\u0060 to transferFrom(...) \u0060tokens\u0060\r\n  // from the token owner\u0027s account. The \u0060spender\u0060 contract function\r\n  // \u0060receiveApproval(...)\u0060 is then executed\r\n  // ------------------------------------------------------------------------\r\n  function approveAndCall(address spender, uint tokens, bytes memory data) public returns(bool success) {\r\n    allowed[msg.sender][spender] = tokens;\r\n    emit Approval(msg.sender, spender, tokens);\r\n    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);\r\n    return true;\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Do not accept ETH\r\n  // ------------------------------------------------------------------------\r\n  function () external payable {\r\n    revert();\r\n  }\r\n\r\n  // ------------------------------------------------------------------------\r\n  // Owner can transfer out any accidentally sent ERC20 tokens\r\n  // ------------------------------------------------------------------------\r\n  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns(bool success) {\r\n    return ERC20Interface(tokenAddress).transfer(owner, tokens);\r\n  }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lastRewardEthBlockNumber\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMiningDifficulty\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022challenge_digest\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022receivers\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022amounts\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022multiTransfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022rewardEra\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMiningTarget\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_burned\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getChallengeNumber\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022minted\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokensMinted\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lastRewardTo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022burned\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022challenge_digest\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022challenge_number\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022testTarget\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022checkMintSolution\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_MAXIMUM_TARGET\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022challengeNumber\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022challenge_digest\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022challenge_number\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getMintDigest\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022digesttest\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sendTo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sendTo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lastRewardAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022mintingEpoch\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferAnyERC20Token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022reward_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022epochCount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newChallengeNumber\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022Mint\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ZERO_X_BUTTv3","CompilerVersion":"v0.5.1\u002Bcommit.c8a2cb62","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://bd9375a09d18a6aec5b8a1291d4d8be51c7813518f1412962916b5334e3fc7fa"}]