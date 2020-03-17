[{"SourceCode":"pragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\ncontract MultiSig{\r\n\r\n  struct invoke_status{\r\n    uint propose_height;\r\n    bytes32 invoke_hash;\r\n    string func_name;\r\n    uint64 invoke_id;\r\n    bool called;\r\n    address[] invoke_signers;\r\n    bool processing;\r\n    bool exists;\r\n  }\r\n\r\n  uint public signer_number;\r\n  address[] public signers;\r\n  address public owner;\r\n  mapping (bytes32 =\u003E invoke_status) public invokes;\r\n  mapping (bytes32 =\u003E uint64) public used_invoke_ids;\r\n  mapping(address =\u003E uint) public signer_join_height;\r\n\r\n  event signers_reformed(address[] old_signers, address[] new_signers);\r\n  event valid_function_sign(string name, uint64 id, uint64 current_signed_number, uint propose_height);\r\n  event function_called(string name, uint64 id, uint propose_height);\r\n\r\n  modifier enough_signers(address[] memory s){\r\n    require(s.length \u003E=3, \u0022the number of signers must be \u003E=3\u0022);\r\n    _;\r\n  }\r\n  constructor(address[] memory s) public enough_signers(s){\r\n    signers = s;\r\n    signer_number = s.length;\r\n    owner = msg.sender;\r\n    for(uint i = 0; i \u003C s.length; i\u002B\u002B){\r\n      signer_join_height[s[i]] = block.number;\r\n    }\r\n  }\r\n\r\n  modifier only_signer{\r\n    require(array_exist(signers, msg.sender), \u0022only a signer can call this\u0022);\r\n    _;\r\n  }\r\n\r\n  function get_majority_number() private view returns(uint){\r\n    return signer_number/2 \u002B 1;\r\n  }\r\n\r\n  function array_exist (address[] memory accounts, address p) private pure returns (bool){\r\n    for (uint i = 0; i\u003C accounts.length;i\u002B\u002B){\r\n      if (accounts[i]==p){\r\n        return true;\r\n      }\r\n    }\r\n    return false;\r\n  }\r\n\r\n  function is_all_minus_sig(uint number, uint64 id, string memory name, bytes32 hash, address sender) internal only_signer returns (bool){\r\n    bytes32 b = keccak256(abi.encodePacked(name));\r\n    require(id \u003C= used_invoke_ids[b] \u002B 1, \u0022you\u0027re using a too big id.\u0022);\r\n\r\n    if(id \u003E used_invoke_ids[b]){\r\n      used_invoke_ids[b] = id;\r\n    }\r\n\r\n    if(!invokes[hash].exists){\r\n      invokes[hash].propose_height = block.number;\r\n      invokes[hash].invoke_hash = hash;\r\n      invokes[hash].func_name= name;\r\n      invokes[hash].invoke_id= id;\r\n      invokes[hash].called= false;\r\n      invokes[hash].invoke_signers.push(sender);\r\n      invokes[hash].processing= false;\r\n      invokes[hash].exists= true;\r\n      emit valid_function_sign(name, id, 1, block.number);\r\n      return false;\r\n    }\r\n\r\n    invoke_status storage invoke = invokes[hash];\r\n    require(!array_exist(invoke.invoke_signers, sender), \u0022you already called this method\u0022);\r\n\r\n    uint valid_invoke_num = 0;\r\n    uint join_height = signer_join_height[msg.sender];\r\n    for(uint i = 0; i \u003C invoke.invoke_signers.length; i\u002B\u002B){\r\n      require(join_height \u003C invoke.propose_height, \u0022this proposal is already exist before you become a signer\u0022);\r\n      if(array_exist(signers, invoke.invoke_signers[i])){\r\n        valid_invoke_num \u002B\u002B;\r\n      }\r\n    }\r\n    invoke.invoke_signers.push(msg.sender);\r\n    valid_invoke_num \u002B\u002B;\r\n    emit valid_function_sign(name, id, uint64(valid_invoke_num), invoke.propose_height);\r\n    if(invoke.called) return false;\r\n    if(valid_invoke_num \u003C signer_number-number) return false;\r\n    invoke.processing = true;\r\n    return true;\r\n  }\r\n\r\n  modifier is_majority_sig(uint64 id, string memory name) {\r\n    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));\r\n    if(!is_all_minus_sig(get_majority_number()-1, id, name, hash, msg.sender))\r\n      return ;\r\n    set_called(hash);\r\n    _;\r\n  }\r\n\r\n  modifier is_all_sig(uint64 id, string memory name) {\r\n    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));\r\n    if(!is_all_minus_sig(0, id, name, hash, msg.sender)) return ;\r\n    set_called(hash);\r\n    _;\r\n  }\r\n\r\n  function set_called(bytes32 hash) internal only_signer{\r\n    invoke_status storage invoke = invokes[hash];\r\n    require(invoke.exists, \u0022no such function\u0022);\r\n    require(!invoke.called, \u0022already called\u0022);\r\n    require(invoke.processing, \u0022cannot call this separately\u0022);\r\n    invoke.called = true;\r\n    invoke.processing = false;\r\n    emit function_called(invoke.func_name, invoke.invoke_id, invoke.propose_height);\r\n  }\r\n\r\n  function reform_signers(uint64 id, address[] calldata s)\r\n    external\r\n    only_signer\r\n    enough_signers(s)\r\n    is_majority_sig(id, \u0022reform_signers\u0022){\r\n    address[] memory old_signers = signers;\r\n    for(uint i = 0; i \u003C s.length; i\u002B\u002B){\r\n      if(array_exist(old_signers, s[i])){\r\n      }else{\r\n        signer_join_height[s[i]] = block.number;\r\n      }\r\n    }\r\n    for(uint i = 0; i \u003C old_signers.length; i\u002B\u002B){\r\n      if(array_exist(s, old_signers[i])){\r\n      }else{\r\n        signer_join_height[old_signers[i]] = 0;\r\n      }\r\n    }\r\n    signer_number = s.length;\r\n    signers = s;\r\n    emit signers_reformed(old_signers, signers);\r\n  }\r\n\r\n  function get_unused_invoke_id(string memory name) public view returns(uint64){\r\n    return used_invoke_ids[keccak256(abi.encodePacked(name))] \u002B 1;\r\n  }\r\n  function get_signers() public view returns(address[] memory){\r\n    return signers;\r\n  }\r\n}\r\n\r\ncontract SafeMath {\r\n    function safeAdd(uint a, uint b) public pure returns (uint c) {\r\n        c = a \u002B b;\r\n        require(c \u003E= a);\r\n    }\r\n    function safeSub(uint a, uint b) public pure returns (uint c) {\r\n        require(b \u003C= a);\r\n        c = a - b;\r\n    }\r\n    function safeMul(uint a, uint b) public pure returns (uint c) {\r\n        c = a * b;\r\n        require(a == 0 || c / a == b);\r\n    }\r\n    function safeDiv(uint a, uint b) public pure returns (uint c) {\r\n        require(b \u003E 0);\r\n        c = a / b;\r\n    }\r\n}\r\n\r\ncontract ChatTokenInterface{\r\n  function issue(address account, uint num) public;\r\n}\r\n\r\ncontract ChatTokenIssue is SafeMath, MultiSig{\r\n\r\n  uint public ratio;\r\n  uint public price_x_base;\r\n  uint public last_def_price_block_num;\r\n  uint public adjust_price_period;\r\n  uint public adjust_price_unit;\r\n\r\n  bool private paused;\r\n\r\n  ChatTokenInterface chattoken;\r\n\r\n  event Exchange(address, uint base, uint eth_amount, uint cat_amount);\r\n  event SetParam(uint ratio, uint p, uint u);\r\n  event Paused();\r\n  event Unpaused();\r\n  event TransferETH(address account, uint amount);\r\n\r\n  constructor(address contract_address, address[] memory s) MultiSig(s) public {\r\n    chattoken = ChatTokenInterface(contract_address);\r\n    last_def_price_block_num = block.number;\r\n    paused = false;\r\n  }\r\n\r\n  modifier when_paused(){\r\n    require(paused == true, \u0022require paused\u0022);\r\n    _;\r\n  }\r\n\r\n  modifier when_not_paused(){\r\n    require(paused == false, \u0022require not paused\u0022);\r\n    _;\r\n  }\r\n\r\n  function pause(uint64 id) public when_not_paused only_signer is_majority_sig(id, \u0022pause\u0022){\r\n    paused = true;\r\n    emit Paused();\r\n  }\r\n  function unpause(uint64 id) public when_paused only_signer is_majority_sig(id, \u0022unpause\u0022){\r\n    paused = false;\r\n    emit Unpaused();\r\n  }\r\n\r\n  function issue_for_ar(uint64 id, address[] memory accounts, uint[] memory nums)\r\n    public\r\n    only_signer\r\n    is_majority_sig(id, \u0022issue_for_ar\u0022){\r\n      require(accounts.length == nums.length);\r\n      require(accounts.length != 0);\r\n      for(uint i = 0; i \u003C accounts.length; i\u002B\u002B){\r\n        chattoken.issue(accounts[i], nums[i]);\r\n      }\r\n  }\r\n\r\n  function airdrop(uint64 id, address[] memory accounts)\r\n    public\r\n    only_signer\r\n    is_majority_sig(id, \u0022airdrop\u0022){\r\n      require(accounts.length != 0);\r\n      for(uint i = 0; i \u003C accounts.length; i\u002B\u002B){\r\n        chattoken.issue(accounts[i], 1000);\r\n      }\r\n  }\r\n\r\n  function exchange() public payable\r\n    when_not_paused\r\n    returns(bool){\r\n    require(msg.value \u003E 0);\r\n    uint price = cur_price();\r\n    if(price \u003E= msg.value){\r\n      msg.sender.transfer(msg.value);\r\n      return false;\r\n    }\r\n\r\n    uint v = msg.value;\r\n    uint min = 1;\r\n    uint max = safeDiv(v, safeMul(price_x_base \u002B min, ratio));\r\n\r\n    while(min \u003C max){\r\n      uint t = safeDiv(safeAdd(min, max), 2);\r\n      uint amount = _sum(price_x_base, t);\r\n      uint s = safeMul(ratio, amount);\r\n\r\n      if(s \u003E v){\r\n        max = t - 1;\r\n      }else if(s \u003C v){\r\n        min = t \u002B 1;\r\n      }\r\n      else if(s == v){\r\n        exchange_with_value_price(t, 0);\r\n        return true;\r\n      }\r\n    }\r\n    uint amount = _sum(price_x_base, max);\r\n    uint s = safeMul(ratio, amount);\r\n    if(s \u003E v){\r\n      amount = _sum(price_x_base, max - 1);\r\n      s = safeMul(ratio, amount);\r\n      max = max - 1;\r\n    }\r\n    uint r = safeSub(v, s);\r\n    exchange_with_value_price(max, r);\r\n    return true;\r\n  }\r\n\r\n  function _sum(uint x0, uint t) private pure returns(uint){\r\n    return safeAdd(safeMul(t, x0), safeDiv(safeMul(t, t\u002B1), 2));\r\n  }\r\n\r\n  function exchange_with_value_price(uint amount, uint r) private{\r\n    if(r != 0){\r\n      msg.sender.transfer(r);\r\n    }\r\n\r\n    uint base = price_x_base;\r\n    price_x_base \u002B= amount;\r\n    last_def_price_block_num = block.number;\r\n    chattoken.issue(msg.sender, amount);\r\n    emit Exchange(msg.sender, base, safeSub(msg.value,  r), amount);\r\n  }\r\n\r\n  function cur_price() public returns(uint){\r\n    uint period = safeDiv(safeSub(block.number, last_def_price_block_num), adjust_price_period);\r\n    uint minus_base = safeMul(period, adjust_price_unit);\r\n    if(minus_base \u003E= price_x_base){\r\n      price_x_base = 0;\r\n    }else{\r\n      price_x_base = safeSub(price_x_base, minus_base);\r\n    }\r\n    return _price(price_x_base);\r\n  }\r\n\r\n  function _price(uint p) internal view returns(uint){\r\n    return safeMul(p \u002B 1, ratio);\r\n  }\r\n\r\n  function set_param(uint64 id, uint r, uint p, uint u)\r\n    external\r\n    only_signer\r\n    is_majority_sig(id, \u0022set_param\u0022){\r\n      ratio = r;\r\n      adjust_price_period = p;\r\n      adjust_price_unit = u;\r\n      emit SetParam(r, p, u);\r\n  }\r\n\r\n  function balance() public view returns (uint){\r\n    return address(this).balance;\r\n  }\r\n\r\n  function transfer(uint64 id, address payable account, uint amount) public only_signer is_majority_sig(id, \u0022transfer\u0022){\r\n    require(amount \u003C= address(this).balance);\r\n    account.transfer(amount);\r\n    emit TransferETH(account, amount);\r\n  }\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022signers\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022invokes\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022propose_height\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022invoke_hash\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022func_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022invoke_id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022called\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022processing\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022exists\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022get_signers\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022accounts\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022airdrop\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022used_invoke_ids\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ratio\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022adjust_price_unit\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022safeSub\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022c\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022r\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022p\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022u\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022set_param\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022safeDiv\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022c\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022balance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022signer_number\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022accounts\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022nums\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022issue_for_ar\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022get_unused_invoke_id\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022cur_price\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022adjust_price_period\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022last_def_price_block_num\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022safeMul\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022c\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022exchange\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022s\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022reform_signers\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022signer_join_height\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022safeAdd\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022c\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022price_x_base\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022contract_address\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022s\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022base\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022eth_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cat_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Exchange\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ratio\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022p\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022u\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022SetParam\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Paused\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Unpaused\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TransferETH\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022old_signers\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022new_signers\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022signers_reformed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022current_signed_number\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022propose_height\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022valid_function_sign\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022propose_height\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022function_called\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ChatTokenIssue","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000dba248f71003042ab19e37759813ccd12f815abb0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000300000000000000000000000057955d7aa271dbdde92d67e0ef52d90c6e4089ca000000000000000000000000e5d4382b7c97c085ede3f12662445f0686a92bc8000000000000000000000000e855b4cb17ea22cae1be5feb7fcdc0ef67dca84d","Library":"","SwarmSource":"bzzr://8c0a9f86a5c9418c723f3ddf37a1603540656a23c9940b362e7920df06e66325"}]