[{"SourceCode":"// GoToken is an open community aims to explore a decentralized collaboration network incentived and well-governed through blockchain. Learn more about gotoken @ forum.gotoken.io\r\npragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\ncontract TransferableToken{\r\n    function balanceOf(address _owner) public returns (uint256 balance) ;\r\n    function transfer(address _to, uint256 _amount) public returns (bool success) ;\r\n    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) ;\r\n}\r\n\r\n\r\ncontract TokenClaimer{\r\n\r\n    event ClaimedTokens(address indexed _token, address indexed _to, uint _amount);\r\n    /// @notice This method can be used by the controller to extract mistakenly\r\n    ///  sent tokens to this contract.\r\n    /// @param _token The address of the token contract that you want to recover\r\n    ///  set to 0 in case you want to extract ether.\r\n  function _claimStdTokens(address _token, address payable to) internal {\r\n        if (_token == address(0x0)) {\r\n            to.transfer(address(this).balance);\r\n            return;\r\n        }\r\n        TransferableToken token = TransferableToken(_token);\r\n        uint balance = token.balanceOf(address(this));\r\n\r\n        (bool status,) = _token.call(abi.encodeWithSignature(\u0022transfer(address,uint256)\u0022, to, balance));\r\n        require(status, \u0022call failed\u0022);\r\n        emit ClaimedTokens(_token, to, balance);\r\n  }\r\n}\r\n\r\n\r\npragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\ncontract MultiSigInterface{\r\n  function update_and_check_reach_majority(uint64 id, string memory name, bytes32 hash, address sender) public returns (bool);\r\n  function is_signer(address addr) public view returns(bool);\r\n}\r\n\r\ncontract MultiSigTools{\r\n  MultiSigInterface public multisig_contract;\r\n  constructor(address _contract) public{\r\n    require(_contract!= address(0x0));\r\n    multisig_contract = MultiSigInterface(_contract);\r\n  }\r\n\r\n  modifier only_signer{\r\n    require(multisig_contract.is_signer(msg.sender), \u0022only a signer can call in MultiSigTools\u0022);\r\n    _;\r\n  }\r\n\r\n  modifier is_majority_sig(uint64 id, string memory name) {\r\n    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));\r\n    if(multisig_contract.update_and_check_reach_majority(id, name, hash, msg.sender)){\r\n      _;\r\n    }\r\n  }\r\n\r\n  event TransferMultiSig(address _old, address _new);\r\n\r\n  function transfer_multisig(uint64 id, address _contract) public only_signer\r\n  is_majority_sig(id, \u0022transfer_multisig\u0022){\r\n    require(_contract != address(0x0));\r\n    address old = address(multisig_contract);\r\n    multisig_contract = MultiSigInterface(_contract);\r\n    emit TransferMultiSig(old, _contract);\r\n  }\r\n}\r\n\r\n\r\npragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\ncontract TrustListInterface{\r\n  function is_trusted(address addr) public returns(bool);\r\n}\r\ncontract TrustListTools{\r\n  TrustListInterface public list;\r\n  constructor(address _list) public {\r\n    require(_list != address(0x0));\r\n    list = TrustListInterface(_list);\r\n  }\r\n\r\n  modifier is_trusted(address addr){\r\n    require(list.is_trusted(addr), \u0022not a trusted issuer\u0022);\r\n    _;\r\n  }\r\n\r\n}\r\n\r\n\r\npragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\nlibrary SafeMath {\r\n    function safeAdd(uint a, uint b) public pure returns (uint c) {\r\n        c = a \u002B b;\r\n        require(c \u003E= a);\r\n    }\r\n    function safeSub(uint a, uint b) public pure returns (uint c) {\r\n        require(b \u003C= a);\r\n        c = a - b;\r\n    }\r\n    function safeMul(uint a, uint b) public pure returns (uint c) {\r\n        c = a * b;\r\n        require(a == 0 || c / a == b);\r\n    }\r\n    function safeDiv(uint a, uint b) public pure returns (uint c) {\r\n        require(b \u003E 0);\r\n        c = a / b;\r\n    }\r\n}\r\n\r\n\r\npragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\n\r\n\r\n\r\n\r\ncontract GTTokenInterface is TransferableToken{\r\n    function destroyTokens(address _owner, uint _amount) public returns (bool);\r\n    function generateTokens(address _owner, uint _amount) public returns (bool);\r\n}\r\n\r\n\r\ncontract FundAndDistribute is TokenClaimer, MultiSigTools, TrustListTools{\r\n  using SafeMath for uint;\r\n\r\n  string public name;\r\n  string public desc;\r\n  address public token_contract;\r\n  uint public tokens_per_k_gt;\r\n  uint public exchange_ratio; //actual is 10/exchange_ratio\r\n  GTTokenInterface public gt_token;\r\n  bool public paused;\r\n\r\n  event Fund(address addr, address token, uint cost_amount, uint remain, uint got_amount);\r\n  event Exchange(address addr, address token, uint cost_amout, uint remain, uint got_amount);\r\n\r\n  constructor(address _gt_token,\r\n              string memory _name,\r\n              string memory _desc,\r\n              address _token_contract,\r\n              address _multisig,\r\n              address _tlist)  public MultiSigTools(_multisig) TrustListTools(_tlist){\r\n    gt_token = GTTokenInterface(_gt_token);\r\n    name = _name;\r\n    desc = _desc;\r\n    token_contract = _token_contract;\r\n    tokens_per_k_gt = 1000;\r\n    exchange_ratio = 20; //1/2\r\n    paused = false;\r\n  }\r\n\r\n  function balance() public returns(uint){\r\n      TransferableToken token = TransferableToken(address(gt_token));\r\n      return token.balanceOf(address(this));\r\n  }\r\n  function transfer(uint64 id, address to, uint amount)\r\n    public\r\n    only_signer\r\n    is_majority_sig(id, \u0022transfer\u0022)\r\n  returns (bool success){\r\n      TransferableToken token = TransferableToken(address(gt_token));\r\n      token.transfer(to, amount);\r\n      return true;\r\n  }\r\n\r\n    function claimStdTokens(uint64 id, address _token, address payable to) public only_signer is_majority_sig(id, \u0022claimStdTokens\u0022){\r\n      _claimStdTokens(_token, to);\r\n    }\r\n  modifier when_paused(){\r\n    require(paused == true, \u0022require paused\u0022);\r\n    _;\r\n  }\r\n  modifier when_not_paused(){\r\n    require(paused == false, \u0022require not paused\u0022);\r\n    _;\r\n  }\r\n\r\n    function pause(uint64 id) public only_signer is_majority_sig(id, \u0022pause\u0022){\r\n      paused = true;\r\n    }\r\n    function unpause(uint64 id) public only_signer is_majority_sig(id, \u0022unpause\u0022){\r\n      paused = false;\r\n    }\r\n\r\n    function set_param(uint64 id, uint _tokens_per_k_gt, uint _exchange_ratio) public only_signer is_majority_sig(id, \u0022set_param\u0022){\r\n      require(_tokens_per_k_gt \u003E 0);\r\n      require(_exchange_ratio \u003E 0);\r\n      tokens_per_k_gt = _tokens_per_k_gt;\r\n      exchange_ratio = _exchange_ratio;\r\n    }\r\n\r\n    /* @_amount: in token_contract unit, like USDT\r\n     */\r\n    function _fund(uint _amount) internal returns(uint remain){\r\n      uint v = SafeMath.safeDiv(_amount, tokens_per_k_gt);\r\n      uint cost = SafeMath.safeMul(v, tokens_per_k_gt);\r\n      remain = SafeMath.safeSub(_amount, cost);\r\n      v = SafeMath.safeMul(v, 1000);\r\n      gt_token.generateTokens(msg.sender, v);\r\n      gt_token.generateTokens(address(this), v);\r\n      emit Fund(msg.sender, token_contract, cost, remain, v);\r\n    }\r\n\r\n    /* @_amount: in GTToken unit\r\n     * @remain_token: in token_contract unit, like USDT\r\n     */\r\n    function _exchange(uint _amount) internal returns(uint remain_token){\r\n      require(_amount \u003E 0, \u0022fund should be \u003E 0\u0022);\r\n      GTTokenInterface token = GTTokenInterface(address(gt_token));\r\n      uint old_balance = token.balanceOf(msg.sender);\r\n      require(old_balance \u003E= _amount, \u0022not enough amout\u0022);\r\n\r\n      uint k_gts = SafeMath.safeDiv(_amount, 1000);\r\n      uint cost = SafeMath.safeMul(k_gts, 1000);\r\n      uint r = SafeMath.safeSub(_amount, cost);\r\n      uint burn = SafeMath.safeSub(_amount, r);\r\n      if(burn \u003E 0){\r\n        token.destroyTokens(msg.sender, burn);\r\n      }\r\n      remain_token = SafeMath.safeMul(k_gts, tokens_per_k_gt);\r\n      remain_token = SafeMath.safeDiv(SafeMath.safeMul(remain_token, 10), exchange_ratio);\r\n      emit Exchange(msg.sender, token_contract,cost, r, remain_token);\r\n    }\r\n\r\n  function fund(uint amount) public when_not_paused is_trusted(msg.sender) returns (bool){\r\n    require(amount \u003E 0, \u0022fund should be \u003E 0\u0022);\r\n    TransferableToken token = TransferableToken(token_contract);\r\n    uint old_balance = token.balanceOf(address(this));\r\n    (bool ret, ) = token_contract.call(abi.encodeWithSignature(\u0022transferFrom(address,address,uint256)\u0022, msg.sender, address(this), amount));\r\n    require(ret, \u0022FundAndDistribute:fund, transferFrom return false\u0022);\r\n    uint new_balance = token.balanceOf(address(this));\r\n    require(new_balance == old_balance \u002B amount, \u0022StdFundAndDistribute:fund, invalid transfer\u0022);\r\n    uint remain = _fund(amount);\r\n    if(remain \u003E 0){\r\n      token.transfer(msg.sender, remain);\r\n    }\r\n    return true;\r\n  }\r\n\r\n  function exchange(uint amount) public when_not_paused returns(bool){\r\n    uint ret_token_amount = _exchange(amount);\r\n    if(ret_token_amount \u003E 0){\r\n      (bool ret, ) = token_contract.call(abi.encodeWithSignature(\u0022transfer(address,uint256)\u0022, msg.sender, ret_token_amount));\r\n      require(ret, \u0022FundAndDistribute:fund, transferFrom return false\u0022);\r\n    }\r\n    return true;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022claimStdTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022list\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022_contract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transfer_multisig\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022exchange_ratio\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokens_per_k_gt\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022_tokens_per_k_gt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_exchange_ratio\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022set_param\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022exchange\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022desc\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022multisig_contract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022gt_token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022token_contract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022balance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022fund\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_gt_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_desc\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_token_contract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_multisig\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tlist\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cost_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022remain\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022got_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Fund\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cost_amout\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022remain\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022got_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Exchange\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_old\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_new\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TransferMultiSig\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ClaimedTokens\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"FundAndDistribute","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000353214343ee192ad8a58c62961b972f4d5a6877e00000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec70000000000000000000000009fdb24df185b4e6c42846c2f1355ca0a2bb7e043000000000000000000000000735451974a28f63b0593cce91696659c1b900380000000000000000000000000000000000000000000000000000000000000000c5553445420666f7220474f4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000104f6e6c7920666f722046756e6465727300000000000000000000000000000000","Library":"SafeMath:a37426cdca2be3d52c950d5ca1ffac842b89b06a","SwarmSource":"bzzr://5ab24957c07000d5e12b1058e51f18997dfd5275818b5dfb9ff466fa3a7141ce"}]