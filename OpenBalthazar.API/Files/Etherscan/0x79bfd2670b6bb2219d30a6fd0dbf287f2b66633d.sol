[{"SourceCode":"{\u0022ERC20.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.18;\\n\\ncontract ERC20 {\\n    uint256 public totalSupply;\\n  function balanceOf(address who) public view returns (uint256);\\n  function transfer(address to, uint256 value) public returns (bool);\\n  function allowance(address owner, address spender) public view returns (uint256);\\n  function transferFrom(address from, address to, uint256 value) public returns (bool);\\n  function approve(address spender, uint256 value) public returns (bool);\\n  event Transfer(address indexed from, address indexed to, uint256 value);\\n  event Approval(address indexed owner, address indexed spender, uint256 value);\\n}\\n\u0022},\u0022ICNode.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.18;\\nimport \\u0027./StandardToken.sol\\u0027;\\n\\ncontract ICNode is StandardToken {\\n    address public admin;\\n    string public name;\\n    string public symbol;\\n    uint8 public decimals;\\n    uint256 public totalSupply;\\n    mapping (address =\\u003e bool) public frozenAccount;\\n    mapping (address =\\u003e uint256) public frozenTimestamp;\\n\\n    event Approval(address indexed owner, address indexed spender, uint256 value);\\n    event Transfer(address indexed from, address indexed to, uint256 value);\\n\\n    function ICNode(\\n        string initialName,\\n        string initialSymbol,\\n        uint256 initialSupply,\\n        uint8 initialDecimals,\\n        address initialAdminAddress\\n        ) public {\\n            name=initialName;\\n            symbol=initialSymbol;\\n            decimals=initialDecimals;\\n            totalSupply =initialSupply * 10 ** uint256(initialDecimals);\\n            admin = initialAdminAddress;\\n            balances[msg.sender] = totalSupply;\\n    }\\n\\n    function freeze(\\n        address _target,\\n        bool _freeze\\n    )\\n    public\\n    returns (bool) {\\n        require(msg.sender == admin);\\n        require(_target != address(0));\\n        frozenAccount[_target] = _freeze;\\n        return true;\\n    }\\n\\n    function freezeWithTimestamp(\\n        address _target,\\n        uint256 _timestamp\\n    )\\n    public\\n    returns (bool) {\\n        require(msg.sender == admin);\\n        require(_target != address(0));\\n        frozenTimestamp[_target] = _timestamp;\\n        return true;\\n    }\\n\\n    function multiFreeze(\\n        address[] _targets,\\n        bool[] _freezes\\n    )\\n    public\\n    returns (bool) {\\n        require(msg.sender == admin);\\n        require(_targets.length == _freezes.length);\\n        uint256 len = _targets.length;\\n        require(len \\u003e 0);\\n        for (uint256 i = 0; i \\u003c len; i = i.add(1)) {\\n            address _target = _targets[i];\\n            require(_target != address(0));\\n            bool _freeze = _freezes[i];\\n            frozenAccount[_target] = _freeze;\\n        }\\n        return true;\\n    }\\n    function multiFreezeWithTimestamp(\\n        address[] _targets,\\n        uint256[] _timestamps\\n    )\\n    public\\n    returns (bool) {\\n        require(msg.sender == admin);\\n        require(_targets.length == _timestamps.length);\\n        uint256 len = _targets.length;\\n        require(len \\u003e 0);\\n        for (uint256 i = 0; i \\u003c len; i = i.add(1)) {\\n            address _target = _targets[i];\\n            require(_target != address(0));\\n            uint256 _timestamp = _timestamps[i];\\n            frozenTimestamp[_target] = _timestamp;\\n        }\\n        return true;\\n    }\\n\\n    function multiTransfer(\\n        address[] _tos,\\n        uint256[] _values\\n    )\\n    public\\n    returns (bool) {\\n        require(!frozenAccount[msg.sender]);\\n        require(now \\u003e frozenTimestamp[msg.sender]);\\n        require(_tos.length == _values.length);\\n        uint256 len = _tos.length;\\n        require(len \\u003e 0);\\n        uint256 amount = 0;\\n        for (uint256 i = 0; i \\u003c len; i = i.add(1)) {\\n            amount = amount.add(_values[i]);\\n        }\\n        require(amount \\u003c= balances[msg.sender]);\\n        for (uint256 j = 0; j \\u003c len; j = j.add(1)) {\\n            address _to = _tos[j];\\n            require(_to != address(0));\\n            balances[_to] = balances[_to].add(_values[j]);\\n            balances[msg.sender] = balances[msg.sender].sub(_values[j]);\\n            Transfer(msg.sender, _to, _values[j]);\\n        }\\n        return true;\\n    }\\n    function transfer(\\n        address _to,\\n        uint256 _value\\n    )\\n    public\\n    returns (bool) {\\n        require(!frozenAccount[msg.sender]);\\n        require(now \\u003e frozenTimestamp[msg.sender]);\\n        require(_to != address(0));\\n        require(_value \\u003c= balances[msg.sender]);\\n\\n        balances[msg.sender] = balances[msg.sender].sub(_value);\\n        balances[_to] = balances[_to].add(_value);\\n\\n        Transfer(msg.sender, _to, _value);\\n        return true;\\n    }\\n    function transferFrom(\\n        address _from,\\n        address _to,\\n        uint256 _value\\n    )\\n    public\\n    returns (bool)\\n    {\\n        require(!frozenAccount[_from]);\\n        require(now \\u003e frozenTimestamp[msg.sender]);\\n        require(_to != address(0));\\n        require(_value \\u003c= balances[_from]);\\n        require(_value \\u003c= allowed[_from][msg.sender]);\\n\\n        balances[_from] = balances[_from].sub(_value);\\n        balances[_to] = balances[_to].add(_value);\\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\\n\\n        Transfer(_from, _to, _value);\\n        return true;\\n    }\\n\\n    function approve(\\n        address _spender,\\n        uint256 _value\\n    ) public\\n    returns (bool) {\\n        allowed[msg.sender][_spender] = _value;\\n        Approval(msg.sender, _spender, _value);\\n        return true;\\n    }\\n    function getFrozenTimestamp(\\n        address _target\\n    )\\n    public view\\n    returns (uint256) {\\n        require(_target != address(0));\\n        return frozenTimestamp[_target];\\n    }\\n    function getFrozenAccount(\\n        address _target\\n    )\\n    public view\\n    returns (bool) {\\n        require(_target != address(0));\\n        return frozenAccount[_target];\\n    }\\n    function getBalance()\\n    public view\\n    returns (uint256) {\\n        return address(this).balance;\\n    }\\n    function setName (\\n        string _value\\n    )\\n    public\\n    returns (bool) {\\n        require(msg.sender == admin);\\n        name = _value;\\n        return true;\\n    }\\n    function setSymbol (\\n        string _value\\n    )\\n    public\\n    returns (bool) {\\n        require(msg.sender == admin);\\n        symbol = _value;\\n        return true;\\n    }\\n    function kill()\\n    public {\\n        require(msg.sender == admin);\\n        selfdestruct(admin);\\n    }\\n\\n}\u0022},\u0022SafeMath.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.18;\\n\\nlibrary SafeMath {\\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\\n    if (a == 0) {\\n      return 0;\\n    }\\n    uint256 c = a * b;\\n    assert(c / a == b);\\n    return c;\\n  }\\n\\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\\n    // assert(b \\u003e 0); // Solidity automatically throws when dividing by 0\\n    uint256 c = a / b;\\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\\u0027t hold\\n    return c;\\n  }\\n\\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\\n    assert(b \\u003c= a);\\n    return a - b;\\n  }\\n\\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\\n    uint256 c = a \u002B b;\\n    assert(c \\u003e= a);\\n    return c;\\n  }\\n}\\n\u0022},\u0022StandardToken.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.18;\\n\\nimport \\u0027./ERC20.sol\\u0027;\\nimport \\u0027./SafeMath.sol\\u0027;\\ncontract StandardToken is ERC20 {\\n    using SafeMath for uint256;\\n    mapping(address =\\u003e uint256) balances;\\n    mapping (address =\\u003e mapping (address =\\u003e uint256)) internal allowed;\\n\\n      function transfer(address _to, uint256 _value) public returns (bool) {\\n        require(_to != address(0));\\n        require(_value \\u003c= balances[msg.sender]);\\n        balances[msg.sender] = balances[msg.sender].sub(_value);\\n        balances[_to] = balances[_to].add(_value);\\n        Transfer(msg.sender, _to, _value);\\n        return true;\\n      }\\n\\n      function balanceOf(address _owner) public view returns (uint256 balance) {\\n        return balances[_owner];\\n      }\\n      function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\\n        require(_to != address(0));\\n        require(_value \\u003c= balances[_from]);\\n        require(_value \\u003c= allowed[_from][msg.sender]);\\n\\n        balances[_from] = balances[_from].sub(_value);\\n        balances[_to] = balances[_to].add(_value);\\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\\n        Transfer(_from, _to, _value);\\n        return true;\\n      }\\n      function approve(address _spender, uint256 _value) public returns (bool) {\\n        allowed[msg.sender][_spender] = _value;\\n        Approval(msg.sender, _spender, _value);\\n        return true;\\n      }\\n      function allowance(address _owner, address _spender) public view returns (uint256) {\\n        return allowed[_owner][_spender];\\n      }\\n}\\n\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tos\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_values\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022multiTransfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022frozenAccount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022setSymbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_freeze\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022freeze\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022setName\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getFrozenAccount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_targets\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_freezes\u0022,\u0022type\u0022:\u0022bool[]\u0022}],\u0022name\u0022:\u0022multiFreeze\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022frozenTimestamp\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_timestamp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022freezeWithTimestamp\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_targets\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_timestamps\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022multiFreezeWithTimestamp\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getFrozenTimestamp\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022admin\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022initialName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022initialSymbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022initialSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022initialDecimals\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022initialAdminAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ICNode","CompilerVersion":"v0.4.18\u002Bcommit.9cf6e910","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"00000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000218711a000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000fd132ec25472de5065195df8ae562f01ec5880e4000000000000000000000000000000000000000000000000000000000000000649434e6f64650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000349434e0000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://3e9f065e26251b157198a3cf77207967df371d8c8c4591979792b37686826cb9"}]