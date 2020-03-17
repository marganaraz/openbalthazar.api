[{"SourceCode":"pragma solidity ^0.4.26;\r\n\r\ninterface ERC20 {\r\nfunction transferFrom(address _from, address _to, uint256 _value)\r\nexternal returns (bool);\r\nfunction transfer(address _to, uint256 _value)\r\nexternal returns (bool);\r\nfunction balanceOf(address _owner)\r\nexternal constant returns (uint256);\r\nfunction allowance(address _owner, address _spender)\r\nexternal returns (uint256);\r\nfunction approve(address _spender, uint256 _value)\r\nexternal returns (bool);\r\nevent Approval(address indexed _owner, address indexed _spender, uint256  _val);\r\nevent Transfer(address indexed _from, address indexed _to, uint256 _val);\r\n}\r\n\r\ncontract LightShadowChain is ERC20 {\r\nuint256 public totalSupply;\r\nuint public decimals;\r\nstring public symbol;\r\nstring public name;\r\nmapping (address =\u003E mapping (address =\u003E uint256)) approach;\r\nmapping (address =\u003E uint256) holders;\r\n\r\nconstructor() public {\r\n    name = \u0022Light Shadow Chain\u0022;\r\n    symbol = \u0022LSCC\u0022;\r\n    decimals = 18;\r\n    totalSupply = 3000000000 * 10**uint(decimals);\r\n    holders[msg.sender] = totalSupply;\r\n}\r\n\r\nfunction () public {\r\nrevert();\r\n}\r\n\r\nfunction balanceOf(address _own)\r\npublic view returns (uint256) {\r\nreturn holders[_own];\r\n}\r\n\r\nfunction transfer(address _to, uint256 _val)\r\npublic returns (bool) {\r\nrequire(holders[msg.sender] \u003E= _val);\r\nrequire(msg.sender != _to);\r\nassert(_val \u003C= holders[msg.sender]);\r\nholders[msg.sender] = holders[msg.sender] - _val;\r\nholders[_to] = holders[_to] \u002B _val;\r\nassert(holders[_to] \u003E= _val);\r\nemit Transfer(msg.sender, _to, _val);\r\nreturn true;\r\n}\r\n\r\nfunction transferFrom(address _from, address _to, uint256 _val)\r\npublic returns (bool) {\r\nrequire(holders[_from] \u003E= _val);\r\nrequire(approach[_from][msg.sender] \u003E= _val);\r\nassert(_val \u003C= holders[_from]);\r\nholders[_from] = holders[_from] - _val;\r\nassert(_val \u003C= approach[_from][msg.sender]);\r\napproach[_from][msg.sender] = approach[_from][msg.sender] - _val;\r\nholders[_to] = holders[_to] \u002B _val;\r\nassert(holders[_to] \u003E= _val);\r\nemit Transfer(_from, _to, _val);\r\nreturn true;\r\n}\r\n\r\nfunction approve(address _spender, uint256 _val)\r\npublic returns (bool) {\r\nrequire(holders[msg.sender] \u003E= _val);\r\napproach[msg.sender][_spender] = _val;\r\nemit Approval(msg.sender, _spender, _val);\r\nreturn true;\r\n}\r\n\r\nfunction allowance(address _owner, address _spender)\r\npublic view returns (uint256) {\r\nreturn approach[_owner][_spender];\r\n}\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_val\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_val\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_own\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_val\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_val\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_val\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"LightShadowChain","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://50c4fe7685ab5eacaa52ea4e3eaa49216e6b2a34ecd43a58286d49e6b0ce8e6a"}]