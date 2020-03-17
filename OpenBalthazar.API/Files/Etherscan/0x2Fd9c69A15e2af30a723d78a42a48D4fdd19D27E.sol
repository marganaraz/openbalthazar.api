[{"SourceCode":"pragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\nlibrary SafeMath {\r\n    function safeAdd(uint a, uint b) public pure returns (uint c) {\r\n        c = a \u002B b;\r\n        require(c \u003E= a, \u0022add\u0022);\r\n    }\r\n    function safeSub(uint a, uint b) public pure returns (uint c) {\r\n        require(b \u003C= a, \u0022sub\u0022);\r\n        c = a - b;\r\n    }\r\n    function safeMul(uint a, uint b) public pure returns (uint c) {\r\n        c = a * b;\r\n        require(a == 0 || c / a == b, \u0022mul\u0022);\r\n    }\r\n    function safeDiv(uint a, uint b) public pure returns (uint c) {\r\n        require(b \u003E 0, \u0022div\u0022);\r\n        c = a / b;\r\n    }\r\n}\r\n\r\ncontract MultiSigInterface{\r\n  function update_and_check_reach_majority(uint64 id, string memory name, bytes32 hash, address sender) public returns (bool);\r\n  function is_signer(address addr) public view returns(bool);\r\n}\r\n\r\ncontract MultiSigTools{\r\n  MultiSigInterface public multisig_contract;\r\n  constructor(address _contract) public{\r\n    require(_contract!= address(0x0));\r\n    multisig_contract = MultiSigInterface(_contract);\r\n  }\r\n\r\n  modifier only_signer{\r\n    require(multisig_contract.is_signer(msg.sender), \u0022only a signer can call in MultiSigTools\u0022);\r\n    _;\r\n  }\r\n\r\n  modifier is_majority_sig(uint64 id, string memory name) {\r\n    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));\r\n    if(multisig_contract.update_and_check_reach_majority(id, name, hash, msg.sender)){\r\n      _;\r\n    }\r\n  }\r\n\r\n  event TransferMultiSig(address _old, address _new);\r\n\r\n  function transfer_multisig(uint64 id, address _contract) public only_signer\r\n  is_majority_sig(id, \u0022transfer_multisig\u0022){\r\n    require(_contract != address(0x0));\r\n    address old = address(multisig_contract);\r\n    multisig_contract = MultiSigInterface(_contract);\r\n    emit TransferMultiSig(old, _contract);\r\n  }\r\n}\r\n\r\ncontract TransferableToken{\r\n    function balanceOf(address _owner) public returns (uint256 balance) ;\r\n    function transfer(address _to, uint256 _amount) public returns (bool success) ;\r\n    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) ;\r\n}\r\n\r\n\r\ncontract TokenClaimer{\r\n\r\n    event ClaimedTokens(address indexed _token, address indexed _to, uint _amount);\r\n    /// @notice This method can be used by the controller to extract mistakenly\r\n    ///  sent tokens to this contract.\r\n    /// @param _token The address of the token contract that you want to recover\r\n    ///  set to 0 in case you want to extract ether.\r\n  function _claimStdTokens(address _token, address payable to) internal {\r\n        if (_token == address(0x0)) {\r\n            to.transfer(address(this).balance);\r\n            return;\r\n        }\r\n        TransferableToken token = TransferableToken(_token);\r\n        uint balance = token.balanceOf(address(this));\r\n\r\n        (bool status,) = _token.call(abi.encodeWithSignature(\u0022transfer(address,uint256)\u0022, to, balance));\r\n        require(status, \u0022call failed\u0022);\r\n        emit ClaimedTokens(_token, to, balance);\r\n  }\r\n}\r\n\r\ncontract TokenInterface is TransferableToken{\r\n    function destroyTokens(address _owner, uint _amount) public returns (bool);\r\n    function generateTokens(address _owner, uint _amount) public returns (bool);\r\n}\r\n\r\ncontract DoubleCurveFund is TokenClaimer, MultiSigTools{\r\n  using SafeMath for uint;\r\n\r\n  string public desc;\r\n  address public native_token;\r\n  address public exchange_token;\r\n\r\n  uint public t; // y param\r\n  uint public s; // x param\r\n  uint public l; // ratio\r\n\r\n  uint internal x; // remain token in current section\r\n  uint internal m; // section no. from 0\r\n  uint internal rest;\r\n  uint internal exp;\r\n\r\n  bool public paused;\r\n\r\n  uint public withdraw;\r\n  uint public profit;\r\n  uint public total_exchange_token;\r\n\r\n  event Fund(address addr, uint amount, uint remain, uint got_amount);\r\n  event Exchange(address addr, uint amount, uint remain, uint got_amount);\r\n\r\n  constructor(address _native_token,\r\n              address _exchange_token,\r\n              uint _t,\r\n              uint _s,\r\n              uint _l,\r\n              address _multisig\r\n             ) public MultiSigTools(_multisig){\r\n               t = _t;\r\n               s = _s;\r\n               l = _l;\r\n               native_token = _native_token;\r\n               exchange_token = _exchange_token;\r\n\r\n               x = 1;\r\n               m = 0;\r\n               rest = SafeMath.safeSub(s.safeMul(t.safeDiv(2)), t.safeDiv(2));\r\n               exp = 1;\r\n\r\n               withdraw = 0;\r\n               profit = 0;\r\n               total_exchange_token = 0;\r\n               paused = false;\r\n             }\r\n\r\n  function balance() public returns(uint){\r\n    TransferableToken token = TransferableToken(address(exchange_token));\r\n    return token.balanceOf(address(this));\r\n  }\r\n\r\n\r\n  function claimStdTokens(uint64 id, address _token, address payable to) public only_signer is_majority_sig(id, \u0022claimStdTokens\u0022){\r\n    require(_token != exchange_token);\r\n    _claimStdTokens(_token, to);\r\n  }\r\n  modifier when_paused(){\r\n    require(paused == true, \u0022require paused\u0022);\r\n    _;\r\n  }\r\n  modifier when_not_paused(){\r\n    require(paused == false, \u0022require not paused\u0022);\r\n    _;\r\n  }\r\n\r\n  function pause(uint64 id) public only_signer is_majority_sig(id, \u0022pause\u0022){\r\n    paused = true;\r\n  }\r\n  function unpause(uint64 id) public only_signer is_majority_sig(id, \u0022unpause\u0022){\r\n    paused = false;\r\n  }\r\n\r\n  function current_exchange_price() public view returns(uint) {\r\n    uint t1 = m.safeMul(t);\r\n    uint t2 = x.safeSub((exp - 1).safeMul(s)) * t;\r\n    uint t3 = exp * s;\r\n\r\n    return t1 \u002B t2.safeDiv(t3);\r\n  }\r\n\r\n  function set_desc(uint64 id, string memory _desc) public only_signer is_majority_sig(id, \u0022set_desc\u0022){\r\n    desc = _desc;\r\n  }\r\n\r\n  function withdraw_profit(uint64 id, address _addr, uint amount)\r\n    public\r\n    only_signer\r\n    is_majority_sig(id, \u0022withdraw_profit\u0022)\r\n    returns(bool){\r\n    require(amount \u003E 0, \u0022withdraw_profit, amount should be \u003E 0\u0022);\r\n    require(amount \u002B withdraw \u003C= profit, \u0022claim too much!\u0022);\r\n\r\n    TransferableToken token = TransferableToken(exchange_token);\r\n    uint old_balance = token.balanceOf(address(this));\r\n    (bool ret, ) = exchange_token.call(abi.encodeWithSignature(\u0022transfer(address,uint256)\u0022, _addr, amount));\r\n    require(ret, \u0022DoubleCurveFund:withdraw_profit, transfer return false\u0022);\r\n    uint new_balance = token.balanceOf(address(this));\r\n    require(new_balance \u002B amount == old_balance, \u0022DoubleCurveFund:withdraw_profit, invalid transfer\u0022);\r\n    withdraw \u002B= amount;\r\n    return true;\r\n  }\r\n\r\n  function fund(uint amount) public when_not_paused returns(bool){\r\n    require(amount \u003E 0, \u0022fund, amount should be \u003E 0\u0022);\r\n    (uint remain, uint native_amount) = _fund(amount);\r\n    require(native_amount != 0, \u0022amount too small\u0022);\r\n\r\n    amount = amount - remain;\r\n\r\n    TransferableToken token = TransferableToken(exchange_token);\r\n    uint old_balance = token.balanceOf(address(this));\r\n    (bool ret, ) = exchange_token.call(abi.encodeWithSignature(\u0022transferFrom(address,address,uint256)\u0022, msg.sender, address(this), amount));\r\n    require(ret, \u0022DoubleCurveFund:fund, transferFrom return false\u0022);\r\n    uint new_balance = token.balanceOf(address(this));\r\n    require(new_balance == old_balance \u002B amount, \u0022DoubleCurveFund:fund, invalid transfer\u0022);\r\n    if(native_amount \u003E 0){\r\n      TokenInterface ti = TokenInterface(native_token);\r\n      ti.generateTokens(msg.sender, native_amount);\r\n    }\r\n    emit Fund(msg.sender, amount, remain, native_amount);\r\n    return true;\r\n  }\r\n\r\n\r\n  function _fund(uint _amount) internal returns(uint exchange_amount, uint native_amount){\r\n    uint api = 0;\r\n    uint amount = _amount;\r\n\r\n    while(amount \u003E= rest){\r\n      amount = amount.safeSub(rest);\r\n      exp = exp.safeMul(2);\r\n      m \u002B= 1;\r\n      uint tmp = (exp - 1).safeMul(s);\r\n      api \u002B= tmp.safeSub(x);\r\n      rest = (exp.safeMul(m) \u002B exp.safeDiv(2)).safeMul(s).safeMul(t).safeSub(t.safeDiv(2));\r\n      x = tmp;\r\n    }\r\n    uint a = x.safeSub((exp-1).safeMul(s));\r\n    (uint b, bool status) = binary(a, amount);\r\n    if(!status){\r\n      uint t1 = m.safeMul(t).safeMul(b \u002B 1 - a);\r\n      uint t2 = t.safeMul(b \u002B 1 - a).safeMul(b \u002B a);\r\n      uint t3 = s.safeMul(exp).safeMul(2);\r\n      uint c = t1.safeAdd(t2.safeDiv(t3));\r\n\r\n      rest = rest.safeSub(c);\r\n      x = x.safeAdd(b-a \u002B 1);\r\n      api = api.safeAdd(b-a\u002B1);\r\n      amount = amount.safeSub(c);\r\n    }\r\n    uint tmp = _amount.safeSub(amount);\r\n    uint c = tmp.safeMul(l).safeDiv(10000);\r\n\r\n    profit = profit.safeAdd(tmp.safeSub(c));\r\n    total_exchange_token = total_exchange_token.safeAdd(tmp);\r\n\r\n    return (amount, api);\r\n  }\r\n\r\n  function binary(uint _x, uint _amount) internal view returns(uint, bool){\r\n    uint min = x;\r\n    uint max = exp.safeMul(s);\r\n    uint y = max;\r\n\r\n    uint v = m.safeMul(t).safeAdd(min.safeMul(t).safeDiv(t));\r\n    if(_amount \u003C v){\r\n      return (0, true);\r\n    }\r\n\r\n    while(min \u003C max){\r\n      uint b = min.safeAdd(max).safeDiv(2);\r\n      uint t1 = m.safeMul(t).safeMul(b\u002B1 - _x);\r\n      uint t2 = t.safeMul(b\u002B1 - _x).safeMul(b \u002B _x).safeDiv(y.safeMul(2));\r\n      uint c = t1.safeAdd(t2);\r\n      if(_amount \u003C c){\r\n        max = b.safeSub(1);\r\n      }\r\n      if(_amount \u003E= c){\r\n        min = b.safeAdd(1);\r\n      }\r\n    }\r\n    uint t1 = m.safeMul(t).safeMul(max \u002B 1 - _x) ;\r\n    uint t2 = t.safeMul(_x \u002B max).safeMul(max \u002B 1 - _x).safeDiv(y.safeMul(2));\r\n    uint c = t1.safeAdd(t2);\r\n    if(c \u003E _amount){\r\n      max = max - 1;\r\n    }\r\n    return (max, false);\r\n  }\r\n\r\n  function exchange(uint amount) public when_not_paused returns(bool){\r\n    require(amount \u003E 0, \u0022exchange, amount should be \u003E 0\u0022);\r\n    TransferableToken token = TransferableToken(native_token);\r\n    uint b = token.balanceOf(msg.sender);\r\n    require(b \u003E= amount, \u0022not enough amount\u0022);\r\n\r\n    uint exchange_amount = _exchange(amount);\r\n    require(exchange_amount != 0, \u0022no exchanges\u0022);\r\n\r\n    (bool ret, ) = exchange_token.call(abi.encodeWithSignature(\u0022transfer(address,uint256)\u0022, msg.sender, exchange_amount));\r\n    require(ret, \u0022DoubleCurveFund:exchange 1, transfer return false\u0022);\r\n    TokenInterface ti = TokenInterface(native_token);\r\n    ti.destroyTokens(msg.sender, amount);\r\n\r\n    emit Exchange(msg.sender, amount, 0, exchange_amount);\r\n    return true;\r\n  }\r\n  function _exchange(uint _api) internal returns(uint exchange_token_amount){\r\n    uint amount = 0;\r\n    uint api = _api;\r\n    if(api == 0){return 0;}\r\n\r\n    uint restsell = rest.safeMul(l).safeDiv(10000);\r\n    uint tt = t.safeMul(l).safeDiv(10000);\r\n    while (api \u003E 0 \u0026\u0026 api \u003E x.safeSub((exp - 1).safeMul(s))){\r\n      api = api.safeSub(x.safeSub((exp - 1).safeMul(s)));\r\n      uint k = (exp.safeMul(m).safeAdd(exp.safeDiv(2))).safeMul(s).safeMul(tt);\r\n      amount = amount.safeAdd(k.safeSub(tt.safeDiv(2)).safeSub(restsell));\r\n      x = (exp - 1).safeMul(s);\r\n      m = m.safeSub(1);\r\n      exp = exp.safeDiv(2);\r\n      restsell = 0;\r\n    }\r\n    uint kx = x.safeSub((exp - 1).safeMul(s));\r\n    uint t1 = m.safeMul(tt).safeMul(api);\r\n    uint t2 = (kx.safeMul(2).safeSub(api).safeSub(1)).safeMul(api).safeMul(tt);\r\n    uint t3 = s.safeMul(exp).safeMul(2);\r\n    amount = amount.safeAdd(t1.safeAdd(t2.safeDiv(t3)));\r\n\r\n    x = x.safeSub(api);\r\n    restsell = restsell.safeAdd(amount);\r\n    rest = restsell.safeMul(10000).safeDiv(l);\r\n    total_exchange_token = total_exchange_token.safeSub(amount.safeSub(1));\r\n    return amount.safeSub(1);\r\n  }\r\n}\r\n\r\ncontract DoubleCurveFundFactory{\r\n  event NewDoubleCurveFund(address addr);\r\n  function createDoubleCurveFund(address _native_token,\r\n                                 address _exchange_token,\r\n                                 address _multisig,\r\n                                 uint _t, //y param\r\n                                 uint _s, //x param\r\n                                 uint _l  //profit ratio * 10000\r\n                                ) public returns(address){\r\n    DoubleCurveFund c = new DoubleCurveFund(_native_token, _exchange_token, _t, _s, _l, _multisig);\r\n    emit NewDoubleCurveFund(address(c));\r\n    return address(c);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_native_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_exchange_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_multisig\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_t\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_s\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_l\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022createDoubleCurveFund\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022NewDoubleCurveFund\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"DoubleCurveFundFactory","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"SafeMath:a37426cdca2be3d52c950d5ca1ffac842b89b06a","SwarmSource":"bzzr://b4faedb0344ce3e4b9abe1f301811919222f050c97d8cb8f59bff27c8ec5ec98"}]