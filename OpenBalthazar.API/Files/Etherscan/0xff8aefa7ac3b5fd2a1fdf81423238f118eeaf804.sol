[{"SourceCode":"pragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\ncontract MultiSigInterface{\r\n  function update_and_check_reach_majority(uint64 id, string memory name, bytes32 hash, address sender) public returns (bool);\r\n  function is_signer(address addr) public view returns(bool);\r\n}\r\n\r\ncontract MultiSigTools{\r\n  MultiSigInterface public multisig_contract;\r\n  constructor(address _contract) public{\r\n    require(_contract!= address(0x0));\r\n    multisig_contract = MultiSigInterface(_contract);\r\n  }\r\n\r\n  modifier only_signer{\r\n    require(multisig_contract.is_signer(msg.sender), \u0022only a signer can call in MultiSigTools\u0022);\r\n    _;\r\n  }\r\n\r\n  modifier is_majority_sig(uint64 id, string memory name) {\r\n    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));\r\n    if(multisig_contract.update_and_check_reach_majority(id, name, hash, msg.sender)){\r\n      _;\r\n    }\r\n  }\r\n\r\n  event TransferMultiSig(address _old, address _new);\r\n\r\n  function transfer_multisig(uint64 id, address _contract) public only_signer\r\n  is_majority_sig(id, \u0022transfer_multisig\u0022){\r\n    require(_contract != address(0x0));\r\n    address old = address(multisig_contract);\r\n    multisig_contract = MultiSigInterface(_contract);\r\n    emit TransferMultiSig(old, _contract);\r\n  }\r\n}\r\n\r\n\r\ncontract TransferableToken{\r\n    function balanceOf(address _owner) public returns (uint256 balance) ;\r\n    function transfer(address _to, uint256 _amount) public returns (bool success) ;\r\n    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) ;\r\n}\r\n\r\n\r\ncontract TokenClaimer{\r\n\r\n    event ClaimedTokens(address indexed _token, address indexed _to, uint _amount);\r\n    /// @notice This method can be used by the controller to extract mistakenly\r\n    ///  sent tokens to this contract.\r\n    /// @param _token The address of the token contract that you want to recover\r\n    ///  set to 0 in case you want to extract ether.\r\n  function _claimStdTokens(address _token, address payable to) internal {\r\n        if (_token == address(0x0)) {\r\n            to.transfer(address(this).balance);\r\n            return;\r\n        }\r\n        TransferableToken token = TransferableToken(_token);\r\n        uint balance = token.balanceOf(address(this));\r\n\r\n        (bool status,) = _token.call(abi.encodeWithSignature(\u0022transfer(address,uint256)\u0022, to, balance));\r\n        require(status, \u0022call failed\u0022);\r\n        emit ClaimedTokens(_token, to, balance);\r\n  }\r\n}\r\n\r\n\r\nlibrary SafeMath {\r\n    function safeAdd(uint a, uint b) public pure returns (uint c) {\r\n        c = a \u002B b;\r\n        require(c \u003E= a);\r\n    }\r\n    function safeSub(uint a, uint b) public pure returns (uint c) {\r\n        require(b \u003C= a);\r\n        c = a - b;\r\n    }\r\n    function safeMul(uint a, uint b) public pure returns (uint c) {\r\n        c = a * b;\r\n        require(a == 0 || c / a == b);\r\n    }\r\n    function safeDiv(uint a, uint b) public pure returns (uint c) {\r\n        require(b \u003E 0);\r\n        c = a / b;\r\n    }\r\n}\r\n\r\ncontract SimpleMultiSigVote is MultiSigTools, TokenClaimer{\r\n\r\n  struct InternalData{\r\n    bool exist;\r\n    bool determined;\r\n    uint start_height;\r\n    uint end_height;\r\n    address owner;\r\n    string announcement;\r\n    string value;\r\n  }\r\n\r\n  mapping (bytes32 =\u003E InternalData) public vote_status;\r\n  uint public determined_vote_number;\r\n  uint public created_vote_number;\r\n\r\n  constructor(address _multisig) MultiSigTools(_multisig) public{\r\n    determined_vote_number = 0;\r\n    created_vote_number = 0;\r\n  }\r\n\r\n  event VoteCreate(bytes32 _hash, uint _start_height, uint _end_height);\r\n  event VoteChange(bytes32 _hash, uint _start_height, uint _end_height, string announcement);\r\n  event VotePass(bytes32 _hash, string _value);\r\n\r\n  modifier vote_exist(bytes32 _hash){\r\n    require(vote_status[_hash].exist, \u0022vote not exist\u0022);\r\n    _;\r\n  }\r\n\r\n  function createVote(bytes32 _hash, uint _start_height, uint _end_height)\r\n    public\r\n    returns (bool){\r\n    require(!vote_status[_hash].exist, \u0022already exist\u0022);\r\n    require(_end_height \u003E block.number, \u0022end height too small\u0022);\r\n    require(_end_height \u003E _start_height, \u0022end height should be greater than start height\u0022);\r\n    if(_start_height == 0){\r\n      _start_height = block.number;\r\n    }\r\n    InternalData storage d = vote_status[_hash];\r\n\r\n    d.exist = true;\r\n    d.determined = false;\r\n    d.start_height = _start_height;\r\n    d.end_height = _end_height;\r\n    d.owner = msg.sender;\r\n    created_vote_number \u002B= 1;\r\n    emit VoteCreate(_hash, _start_height, _end_height);\r\n    return true;\r\n  }\r\n\r\n  function changeVoteInfo(bytes32 _hash, uint _start_height, uint _end_height, string memory announcement) public\r\n    vote_exist(_hash)\r\n    returns (bool){\r\n    InternalData storage d = vote_status[_hash];\r\n    require(d.owner == msg.sender, \u0022only creator can change vote info\u0022);\r\n\r\n    if(_end_height != 0){\r\n      require(_end_height \u003E block.number, \u0022end height too small\u0022);\r\n      d.end_height = _end_height;\r\n    }\r\n    require(d.start_height \u003E block.number, \u0022already start, cannot change start height\u0022);\r\n    if(_start_height != 0){\r\n      require(_start_height \u003E= block.number, \u0022start block too small\u0022);\r\n      d.start_height = _start_height;\r\n    }\r\n\r\n    require(d.end_height \u003E d.start_height, \u0022end height should be greater than start height\u0022);\r\n\r\n    d.announcement = announcement;\r\n    emit VoteChange(_hash, _start_height, _end_height, announcement);\r\n    return true;\r\n  }\r\n\r\n  function vote(uint64 id, bytes32 _hash, string memory _value) public\r\n    vote_exist(_hash)\r\n    only_signer\r\n    is_majority_sig(id, \u0022vote\u0022)\r\n    returns (bool){\r\n    InternalData storage d = vote_status[_hash];\r\n    require(d.start_height \u003C= block.number, \u0022vote not start yet\u0022);\r\n    require(d.end_height \u003E= block.number, \u0022vote already end\u0022);\r\n\r\n    d.value = _value;\r\n    d.determined = true;\r\n    emit VotePass(_hash, _value);\r\n    determined_vote_number \u002B= 1;\r\n    return true;\r\n  }\r\n\r\n  function isVoteDetermined(bytes32 _hash) public view returns (bool){\r\n    return vote_status[_hash].determined;\r\n  }\r\n\r\n  function checkVoteValue(bytes32 _hash) public view returns(string memory value){\r\n    require(vote_status[_hash].exist, \u0022not exist\u0022);\r\n    require(vote_status[_hash].determined, \u0022not determined\u0022);\r\n\r\n    value = vote_status[_hash].value;\r\n  }\r\n\r\n  function voteInfo(bytes32 _hash) public\r\n  vote_exist(_hash)\r\n  view returns(bool determined, uint start_height, uint end_height, address owner, string memory announcement, string memory value){\r\n\r\n    InternalData storage d = vote_status[_hash];\r\n    return (d.determined, d.start_height, d.end_height, d.owner, d.announcement, d.value);\r\n  }\r\n\r\n  function claimStdTokens(uint64 id, address _token, address payable to) public only_signer is_majority_sig(id, \u0022claimStdTokens\u0022){\r\n    _claimStdTokens(_token, to);\r\n  }\r\n}\r\n\r\ncontract SimpleMultiSigVoteFactory {\r\n  event NewSimpleMultiSigVote(address addr);\r\n\r\n  function createSimpleMultiSigVote(address _multisig) public returns(address){\r\n    SimpleMultiSigVote smsv = new SimpleMultiSigVote(_multisig);\r\n\r\n    emit NewSimpleMultiSigVote(address(smsv));\r\n    return address(smsv);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_multisig\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022createSimpleMultiSigVote\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022NewSimpleMultiSigVote\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SimpleMultiSigVoteFactory","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://f116a20180daa7165f00ec331d5fdbfc49d59f5dafbf4a38ac856c776212d459"}]