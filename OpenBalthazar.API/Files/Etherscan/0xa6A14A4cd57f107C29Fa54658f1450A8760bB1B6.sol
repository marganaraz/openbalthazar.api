[{"SourceCode":"pragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\ncontract MultiSig{\r\n\r\n  struct invoke_status{\r\n    uint propose_height;\r\n    bytes32 invoke_hash;\r\n    string func_name;\r\n    uint64 invoke_id;\r\n    bool called;\r\n    address[] invoke_signers;\r\n    bool processing;\r\n    bool exists;\r\n  }\r\n\r\n  uint public signer_number;\r\n  address[] public signers;\r\n  address public owner;\r\n  mapping (bytes32 =\u003E invoke_status) public invokes;\r\n  mapping (bytes32 =\u003E uint64) public used_invoke_ids;\r\n  mapping(address =\u003E uint) public signer_join_height;\r\n\r\n  event signers_reformed(address[] old_signers, address[] new_signers);\r\n  event valid_function_sign(string name, uint64 id, uint64 current_signed_number, uint propose_height);\r\n  event function_called(string name, uint64 id, uint propose_height);\r\n\r\n  modifier enough_signers(address[] memory s){\r\n    require(s.length \u003E=3, \u0022the number of signers must be \u003E=3\u0022);\r\n    _;\r\n  }\r\n  constructor(address[] memory s) public enough_signers(s){\r\n    signers = s;\r\n    signer_number = s.length;\r\n    owner = msg.sender;\r\n    for(uint i = 0; i \u003C s.length; i\u002B\u002B){\r\n      signer_join_height[s[i]] = block.number;\r\n    }\r\n  }\r\n\r\n  modifier only_signer{\r\n    require(array_exist(signers, msg.sender), \u0022only a signer can call this\u0022);\r\n    _;\r\n  }\r\n\r\n  function get_majority_number() private view returns(uint){\r\n    return signer_number/2 \u002B 1;\r\n  }\r\n\r\n  function array_exist (address[] memory accounts, address p) private pure returns (bool){\r\n    for (uint i = 0; i\u003C accounts.length;i\u002B\u002B){\r\n      if (accounts[i]==p){\r\n        return true;\r\n      }\r\n    }\r\n    return false;\r\n  }\r\n\r\n  function is_all_minus_sig(uint number, uint64 id, string memory name, bytes32 hash, address sender) internal only_signer returns (bool){\r\n    bytes32 b = keccak256(abi.encodePacked(name));\r\n    require(id \u003C= used_invoke_ids[b] \u002B 1, \u0022you\u0027re using a too big id.\u0022);\r\n\r\n    if(id \u003E used_invoke_ids[b]){\r\n      used_invoke_ids[b] = id;\r\n    }\r\n\r\n    if(!invokes[hash].exists){\r\n      invokes[hash].propose_height = block.number;\r\n      invokes[hash].invoke_hash = hash;\r\n      invokes[hash].func_name= name;\r\n      invokes[hash].invoke_id= id;\r\n      invokes[hash].called= false;\r\n      invokes[hash].invoke_signers.push(sender);\r\n      invokes[hash].processing= false;\r\n      invokes[hash].exists= true;\r\n      emit valid_function_sign(name, id, 1, block.number);\r\n      return false;\r\n    }\r\n\r\n    invoke_status storage invoke = invokes[hash];\r\n    require(!array_exist(invoke.invoke_signers, sender), \u0022you already called this method\u0022);\r\n\r\n    uint valid_invoke_num = 0;\r\n    uint join_height = signer_join_height[msg.sender];\r\n    for(uint i = 0; i \u003C invoke.invoke_signers.length; i\u002B\u002B){\r\n      require(join_height \u003C invoke.propose_height, \u0022this proposal is already exist before you become a signer\u0022);\r\n      if(array_exist(signers, invoke.invoke_signers[i])){\r\n        valid_invoke_num \u002B\u002B;\r\n      }\r\n    }\r\n    invoke.invoke_signers.push(msg.sender);\r\n    valid_invoke_num \u002B\u002B;\r\n    emit valid_function_sign(name, id, uint64(valid_invoke_num), invoke.propose_height);\r\n    if(invoke.called) return false;\r\n    if(valid_invoke_num \u003C signer_number-number) return false;\r\n    invoke.processing = true;\r\n    return true;\r\n  }\r\n\r\n  modifier is_majority_sig(uint64 id, string memory name) {\r\n    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));\r\n    if(!is_all_minus_sig(get_majority_number()-1, id, name, hash, msg.sender))\r\n      return ;\r\n    set_called(hash);\r\n    _;\r\n  }\r\n\r\n  modifier is_all_sig(uint64 id, string memory name) {\r\n    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));\r\n    if(!is_all_minus_sig(0, id, name, hash, msg.sender)) return ;\r\n    set_called(hash);\r\n    _;\r\n  }\r\n\r\n  function set_called(bytes32 hash) internal only_signer{\r\n    invoke_status storage invoke = invokes[hash];\r\n    require(invoke.exists, \u0022no such function\u0022);\r\n    require(!invoke.called, \u0022already called\u0022);\r\n    require(invoke.processing, \u0022cannot call this separately\u0022);\r\n    invoke.called = true;\r\n    invoke.processing = false;\r\n    emit function_called(invoke.func_name, invoke.invoke_id, invoke.propose_height);\r\n  }\r\n\r\n  function reform_signers(uint64 id, address[] calldata s)\r\n    external\r\n    only_signer\r\n    enough_signers(s)\r\n    is_majority_sig(id, \u0022reform_signers\u0022){\r\n    address[] memory old_signers = signers;\r\n    for(uint i = 0; i \u003C s.length; i\u002B\u002B){\r\n      if(array_exist(old_signers, s[i])){\r\n      }else{\r\n        signer_join_height[s[i]] = block.number;\r\n      }\r\n    }\r\n    for(uint i = 0; i \u003C old_signers.length; i\u002B\u002B){\r\n      if(array_exist(s, old_signers[i])){\r\n      }else{\r\n        signer_join_height[old_signers[i]] = 0;\r\n      }\r\n    }\r\n    signer_number = s.length;\r\n    signers = s;\r\n    emit signers_reformed(old_signers, signers);\r\n  }\r\n\r\n  function get_unused_invoke_id(string memory name) public view returns(uint64){\r\n    return used_invoke_ids[keccak256(abi.encodePacked(name))] \u002B 1;\r\n  }\r\n  function get_signers() public view returns(address[] memory){\r\n    return signers;\r\n  }\r\n}\r\n\r\ncontract ERC20TokenBankInterface{\r\n  function transfer(uint64 id, address to, uint tokens) external returns(bool success);\r\n  function balance() public view returns(uint);\r\n  function token() public view returns(address, string memory);\r\n}\r\n\r\ncontract TokenBankFactoryInterface{\r\n  function newTokenBank(string memory name, address token_contract, address[] memory s) public returns(ERC20TokenBankInterface);\r\n}\r\n\r\ncontract ERC20TokenBankProvider is MultiSig{\r\n  mapping (bytes32 =\u003E address) public supported_token_factories;\r\n  mapping (bytes32 =\u003E uint) public created_token_numbers;\r\n  uint public total_created_token_numbers;\r\n\r\n  string[] public supported_token_factory_names;\r\n\r\n  event token_bank_created(string name, ERC20TokenBankInterface addr);\r\n  event add_token_factory(string name, address factory);\r\n\r\n  constructor(address[] memory s) MultiSig(s) public{}\r\n\r\n  function addTokenFactory(uint64 id, string memory factory_name, address factory)\r\n    public\r\n    only_signer\r\n    is_majority_sig(id, \u0022addTokenFactory\u0022){\r\n      bytes32 b = keccak256(abi.encodePacked(factory_name));\r\n      require(factory!=address(0));\r\n      supported_token_factories[b] = factory;\r\n      supported_token_factory_names.push(factory_name);\r\n      emit add_token_factory(factory_name, factory);\r\n    }\r\n\r\n  function newTokenBank(string memory name, address token_contract, string memory factory_name, address[] memory s) public returns(ERC20TokenBankInterface){\r\n\r\n      bytes32 b = keccak256(abi.encodePacked(factory_name));\r\n      address a = supported_token_factories[b];\r\n      require(a != address(0), \u0022not supported factory name\u0022);\r\n      TokenBankFactoryInterface tbfi = TokenBankFactoryInterface(a);\r\n      ERC20TokenBankInterface addr = tbfi.newTokenBank(name, token_contract, s);\r\n      created_token_numbers[b] = created_token_numbers[b] \u002B 1;\r\n      total_created_token_numbers = total_created_token_numbers \u002B 1;\r\n      emit token_bank_created(name, addr);\r\n      return addr;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022factory_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022factory\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addTokenFactory\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022supported_token_factory_names\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022signers\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022token_contract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022factory_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022s\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022newTokenBank\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022invokes\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022propose_height\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022invoke_hash\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022func_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022invoke_id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022called\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022processing\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022exists\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022get_signers\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022created_token_numbers\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022used_invoke_ids\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022total_created_token_numbers\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022supported_token_factories\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022signer_number\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022get_unused_invoke_id\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022s\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022reform_signers\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022signer_join_height\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022s\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022token_bank_created\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022factory\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022add_token_factory\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022old_signers\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022new_signers\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022signers_reformed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022current_signed_number\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022propose_height\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022valid_function_sign\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022propose_height\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022function_called\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ERC20TokenBankProvider","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000300000000000000000000000057955d7aa271dbdde92d67e0ef52d90c6e4089ca0000000000000000000000004aa66237b79d0b9be8f6fe9e416d3975d480ec2000000000000000000000000006790b9e80a921824cbcf0e22df100a72bb832be","Library":"","SwarmSource":"bzzr://b534bf2a870fc94e08b426a2248569dcf61ebab11f90a1aafe1e1fdfeaf3b120"}]