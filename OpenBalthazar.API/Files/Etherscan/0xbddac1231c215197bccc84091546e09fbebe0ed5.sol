[{"SourceCode":"{\u0022ERC20Standard.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.7;\\n\\nlibrary SafeMath {\\n\\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\\n        if (a == 0) {\\n            return 0;\\n        }\\n\\n        uint256 c = a * b;\\n        require(c / a == b);\\n\\n        return c;\\n    }\\n\\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\\n        require(b \\u003e 0);\\n        uint256 c = a / b;\\n        \\n\\treturn c;\\n    }\\n\\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\\n        require(b \\u003c= a);\\n        uint256 c = a - b;\\n\\n        return c;\\n    }\\n\\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\\n        uint256 c = a \u002B b;\\n        require(c \\u003e= a);\\n\\n        return c;\\n    }\\n\\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\\n        require(b != 0);\\n        return a % b;\\n    }\\n}\\n\\ncontract ERC20Standard {\\n\\tusing SafeMath for uint256;\\n\\tuint public totalSupply;\\n\\t\\n\\tstring public name;\\n\\tuint8 public decimals;\\n\\tstring public symbol;\\n\\tstring public version;\\n\\t\\n\\tmapping (address =\\u003e uint256) balances;\\n\\tmapping (address =\\u003e mapping (address =\\u003e uint)) allowed;\\n\\n\\t//Fix for short address attack against ERC20\\n\\tmodifier onlyPayloadSize(uint size) {\\n\\t\\tassert(msg.data.length == size \u002B 4);\\n\\t\\t_;\\n\\t} \\n\\n\\tfunction balanceOf(address _owner) public view returns (uint balance) {\\n\\t\\treturn balances[_owner];\\n\\t}\\n\\n\\n\\tfunction transfer(address _recipient, uint _value) public onlyPayloadSize(2*32) {\\n\\t    require(balances[msg.sender] \\u003e= _value \\u0026\\u0026 _value \\u003e 0);\\n\\t    balances[msg.sender] = balances[msg.sender].sub(_value);\\n\\t    balances[_recipient] = balances[_recipient].add(_value);\\n\\t    emit Transfer(msg.sender, _recipient, _value);        \\n        }\\n\\n\\tfunction transferFrom(address _from, address _to, uint _value) public {\\n\\t    require(balances[_from] \\u003e= _value \\u0026\\u0026 allowed[_from][msg.sender] \\u003e= _value \\u0026\\u0026 _value \\u003e 0);\\n            balances[_to] = balances[_to].add(_value);\\n            balances[_from] = balances[_from].sub(_value);\\n            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\\n            emit Transfer(_from, _to, _value);\\n        }\\n\\n\\tfunction  approve(address _spender, uint _value) public {\\n\\t\\tallowed[msg.sender][_spender] = _value;\\n\\t\\temit Approval(msg.sender, _spender, _value);\\n\\t}\\n\\n\\tfunction allowance(address _spender, address _owner) public view returns (uint balance) {\\n\\t\\treturn allowed[_owner][_spender];\\n\\t}\\n\\n\\t//Event which is triggered to log all transfers to this contract\\u0027s event log\\n\\tevent Transfer(\\n\\t\\taddress indexed _from,\\n\\t\\taddress indexed _to,\\n\\t\\tuint _value\\n\\t\\t);\\n\\t\\t\\n\\t//Event which is triggered whenever an owner approves a new allowance for a spender.\\n\\tevent Approval(\\n\\t\\taddress indexed _owner,\\n\\t\\taddress indexed _spender,\\n\\t\\tuint _value\\n\\t\\t);\\n}\\n\u0022},\u0022ZeldaCoin.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.7;\\n\\nimport \\\u0022./ERC20Standard.sol\\\u0022;\\n\\ncontract ZeldaCoin is ERC20Standard {\\n\\tconstructor() public {\\n\\t\\ttotalSupply = 1000000;\\n\\t\\tname = \\\u0022ZeldaCoin\\\u0022;\\n\\t\\tdecimals = 1;  \\n\\t\\tsymbol = \\\u0022ZLD\\\u0022;\\n\\t\\tversion = \\\u00221.0\\\u0022;\\n\\t\\tbalances[msg.sender] = totalSupply;\\n\\t}\\n}\\n\u0022}}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022version\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"ZeldaCoin","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://a4c0671b2bfe544ad15976c88ccb50e2b34aca4e3e23a615159eb73de706faca"}]