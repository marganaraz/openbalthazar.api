[{"SourceCode":"pragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\ncontract MultiSigInterface{\r\n  function update_and_check_reach_majority(uint64 id, string memory name, bytes32 hash, address sender) public returns (bool);\r\n  function is_signer(address addr) public view returns(bool);\r\n}\r\n\r\ncontract MultiSigTools{\r\n  MultiSigInterface public multisig_contract;\r\n  constructor(address _contract) public{\r\n    require(_contract!= address(0x0));\r\n    multisig_contract = MultiSigInterface(_contract);\r\n  }\r\n\r\n  modifier only_signer{\r\n    require(multisig_contract.is_signer(msg.sender), \u0022only a signer can call in MultiSigTools\u0022);\r\n    _;\r\n  }\r\n\r\n  modifier is_majority_sig(uint64 id, string memory name) {\r\n    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));\r\n    if(multisig_contract.update_and_check_reach_majority(id, name, hash, msg.sender)){\r\n      _;\r\n    }\r\n  }\r\n\r\n  event TransferMultiSig(address _old, address _new);\r\n\r\n  function transfer_multisig(uint64 id, address _contract) public only_signer\r\n  is_majority_sig(id, \u0022transfer_multisig\u0022){\r\n    require(_contract != address(0x0));\r\n    address old = address(multisig_contract);\r\n    multisig_contract = MultiSigInterface(_contract);\r\n    emit TransferMultiSig(old, _contract);\r\n  }\r\n}\r\n\r\n\r\ncontract TrustListInterface{\r\n  function is_trusted(address addr) public returns(bool);\r\n}\r\ncontract TrustListTools{\r\n  TrustListInterface public list;\r\n  constructor(address _list) public {\r\n    require(_list != address(0x0));\r\n    list = TrustListInterface(_list);\r\n  }\r\n\r\n  modifier is_trusted(address addr){\r\n    require(list.is_trusted(addr), \u0022not a trusted issuer\u0022);\r\n    _;\r\n  }\r\n\r\n}\r\n\r\n\r\ncontract TransferableToken{\r\n    function balanceOf(address _owner) public returns (uint256 balance) ;\r\n    function transfer(address _to, uint256 _amount) public returns (bool success) ;\r\n    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) ;\r\n}\r\n\r\n\r\ncontract TokenClaimer{\r\n\r\n    event ClaimedTokens(address indexed _token, address indexed _to, uint _amount);\r\n    /// @notice This method can be used by the controller to extract mistakenly\r\n    ///  sent tokens to this contract.\r\n    /// @param _token The address of the token contract that you want to recover\r\n    ///  set to 0 in case you want to extract ether.\r\n  function _claimStdTokens(address _token, address payable to) internal {\r\n        if (_token == address(0x0)) {\r\n            to.transfer(address(this).balance);\r\n            return;\r\n        }\r\n        TransferableToken token = TransferableToken(_token);\r\n        uint balance = token.balanceOf(address(this));\r\n\r\n        (bool status,) = _token.call(abi.encodeWithSignature(\u0022transfer(address,uint256)\u0022, to, balance));\r\n        require(status, \u0022call failed\u0022);\r\n        emit ClaimedTokens(_token, to, balance);\r\n  }\r\n}\r\n\r\n\r\ncontract ERC20TokenBank is MultiSigTools, TokenClaimer, TrustListTools{\r\n\r\n  string public token_name;\r\n  address public erc20_token_addr;\r\n\r\n  event withdraw_token(address to, uint256 amount);\r\n  event issue_token(address to, uint256 amount);\r\n\r\n  constructor(string memory name, address token_contract,\r\n             address _multisig,\r\n             address _tlist) MultiSigTools(_multisig) TrustListTools(_tlist) public{\r\n    token_name = name;\r\n    erc20_token_addr = token_contract;\r\n  }\r\n\r\n  function claimStdTokens(uint64 id, address _token, address payable to) public only_signer is_majority_sig(id, \u0022claimStdTokens\u0022){\r\n    _claimStdTokens(_token, to);\r\n  }\r\n\r\n  function balance() public returns(uint){\r\n    TransferableToken erc20_token = TransferableToken(erc20_token_addr);\r\n    return erc20_token.balanceOf(address(this));\r\n  }\r\n\r\n  function token() public view returns(address, string memory){\r\n    return (erc20_token_addr, token_name);\r\n  }\r\n\r\n  function transfer(uint64 id, address to, uint tokens)\r\n    public\r\n    only_signer\r\n    is_majority_sig(id, \u0022transfer\u0022)\r\n  returns (bool success){\r\n    require(tokens \u003C= balance(), \u0022not enough tokens\u0022);\r\n    (bool status,) = erc20_token_addr.call(abi.encodeWithSignature(\u0022transfer(address,uint256)\u0022, to, tokens));\r\n    require(status, \u0022call failed\u0022);\r\n    emit withdraw_token(to, tokens);\r\n    return true;\r\n  }\r\n\r\n  function issue(address _to, uint _amount)\r\n    public\r\n    is_trusted(msg.sender)\r\n    returns (bool success){\r\n      require(_amount \u003C= balance(), \u0022not enough tokens\u0022);\r\n      (bool status,) = erc20_token_addr.call(abi.encodeWithSignature(\u0022transfer(address,uint256)\u0022, _to, _amount));\r\n      require(status, \u0022call failed\u0022);\r\n      emit issue_token(_to, _amount);\r\n      return true;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022claimStdTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022list\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022_contract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transfer_multisig\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022erc20_token_addr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022multisig_contract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022issue\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022token_name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022balance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022token_contract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_multisig\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tlist\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw_token\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022issue_token\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ClaimedTokens\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_old\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_new\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TransferMultiSig\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ERC20TokenBank","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000000080000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec7000000000000000000000000d030fffd702b037235676af30612577a7ca201a2000000000000000000000000b6c835d93ffccdcb22ca2c7c1ec1822f29d3d0bc00000000000000000000000000000000000000000000000000000000000000135553445420666f72204153526573656172636800000000000000000000000000","Library":"","SwarmSource":"bzzr://c5f955713d8c9a302701cc799746c4b437563fa109fff46076c37c1c3a9dcd40"}]