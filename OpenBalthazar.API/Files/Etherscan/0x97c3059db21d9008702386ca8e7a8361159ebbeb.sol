[{"SourceCode":"pragma solidity ^0.4.25;\r\n\r\nlibrary SafeMath {\r\n\r\n    /**\r\n    * @dev Multiplies two numbers, throws on overflow.\r\n    */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two numbers, truncating the quotient.\r\n    */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        // uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return a / b;\r\n    }\r\n\r\n    /**\r\n    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two numbers, throws on overflow.\r\n    */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n\r\ncontract ForeignToken {\r\n    function balanceOf(address _owner) constant public returns (uint256);\r\n    function transfer(address _to, uint256 _value) public returns (bool);\r\n}\r\n\r\ncontract ERC20Basic {\r\n    uint256 public totalSupply;\r\n    function balanceOf(address who) public constant returns (uint256);\r\n    function transfer(address to, uint256 value) public returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\ncontract ERC20 is ERC20Basic {\r\n    function allowance(address owner, address spender) public constant returns (uint256);\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n    function approve(address spender, uint256 value) public returns (bool);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\ncontract Deschain is ERC20 {\r\n    \r\n    using SafeMath for uint256;\r\n    address owner = msg.sender;\r\n\r\n    mapping (address =\u003E uint256) balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) allowed;\r\n    mapping (address =\u003E bool) public Claimed; \r\n\r\n    string public constant name = \u0022Deschain\u0022;\r\n    string public constant symbol = \u0022DCH\u0022;\r\n    uint public constant decimals = 8;\r\n    uint public deadline = now \u002B 15 * 1 days;\r\n    uint public round2 = now \u002B 15 * 1 days;\r\n    uint public round1 = now \u002B 10 * 1 days;\r\n    \r\n    uint256 public totalSupply = 1689656700000000;\r\n    uint256 public totalDistributed;\r\n    uint256 public constant requestMinimum = 1 ether / 100; // 0.02 Ether\r\n    uint256 public tokensPerEth = 666600000000;\r\n    \r\n    uint public target0drop = 6600;\r\n    uint public progress0drop = 0;\r\n    \r\n    //here u will write your ether address\r\n    address multisig = 0xCE21f3B9d626B971C45Da317B24C680fDa14D412;\r\n\r\n\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n    \r\n    event Distr(address indexed to, uint256 amount);\r\n    event DistrFinished();\r\n    \r\n    event Airdrop(address indexed _owner, uint _amount, uint _balance);\r\n\r\n    event TokensPerEthUpdated(uint _tokensPerEth);\r\n    \r\n    event Burn(address indexed burner, uint256 value);\r\n    \r\n    event Add(uint256 value);\r\n\r\n    bool public distributionFinished = false;\r\n    \r\n    modifier canDistr() {\r\n        require(!distributionFinished);\r\n        _;\r\n    }\r\n    \r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n    \r\n    constructor() public {\r\n        uint256 teamFund = 987987600000000;\r\n        owner = msg.sender;\r\n        distr(owner, teamFund);\r\n    }\r\n    \r\n    function transferOwnership(address newOwner) onlyOwner public {\r\n        if (newOwner != address(0)) {\r\n            owner = newOwner;\r\n        }\r\n    }\r\n\r\n    function finishDistribution() onlyOwner canDistr public returns (bool) {\r\n        distributionFinished = true;\r\n        emit DistrFinished();\r\n        return true;\r\n    }\r\n    \r\n    function distr(address _to, uint256 _amount) canDistr private returns (bool) {\r\n        totalDistributed = totalDistributed.add(_amount);        \r\n        balances[_to] = balances[_to].add(_amount);\r\n        emit Distr(_to, _amount);\r\n        emit Transfer(address(0), _to, _amount);\r\n\r\n        return true;\r\n    }\r\n    \r\n    function Distribute(address _participant, uint _amount) onlyOwner internal {\r\n\r\n        require( _amount \u003E 0 );      \r\n        require( totalDistributed \u003C totalSupply );\r\n        balances[_participant] = balances[_participant].add(_amount);\r\n        totalDistributed = totalDistributed.add(_amount);\r\n\r\n        if (totalDistributed \u003E= totalSupply) {\r\n            distributionFinished = true;\r\n        }\r\n\r\n        // log\r\n        emit Airdrop(_participant, _amount, balances[_participant]);\r\n        emit Transfer(address(0), _participant, _amount);\r\n    }\r\n    \r\n    function DistributeAirdrop(address _participant, uint _amount) onlyOwner external {        \r\n        Distribute(_participant, _amount);\r\n    }\r\n\r\n    function DistributeAirdropMultiple(address[] _addresses, uint _amount) onlyOwner external {        \r\n        for (uint i = 0; i \u003C _addresses.length; i\u002B\u002B) Distribute(_addresses[i], _amount);\r\n    }\r\n\r\n    function updateTokensPerEth(uint _tokensPerEth) public onlyOwner {        \r\n        tokensPerEth = _tokensPerEth;\r\n        emit TokensPerEthUpdated(_tokensPerEth);\r\n    }\r\n           \r\n    function () external payable {\r\n        getTokens();\r\n     }\r\n\r\n    function getTokens() payable canDistr  public {\r\n        uint256 tokens = 0;\r\n        uint256 bonus = 0;\r\n        uint256 countbonus = 0;\r\n        uint256 bonusCond1 = 1 ether / 10;\r\n        uint256 bonusCond2 = 5 ether / 10;\r\n        uint256 bonusCond3 = 1 ether;\r\n\r\n        tokens = tokensPerEth.mul(msg.value) / 1 ether;        \r\n        address investor = msg.sender;\r\n\r\n        if (msg.value \u003E= requestMinimum \u0026\u0026 now \u003C deadline \u0026\u0026 now \u003C round1 \u0026\u0026 now \u003C round2) {\r\n            if(msg.value \u003E= bonusCond1 \u0026\u0026 msg.value \u003C bonusCond2){\r\n                countbonus = tokens * 10 / 100;\r\n            }else if(msg.value \u003E= bonusCond2 \u0026\u0026 msg.value \u003C bonusCond3){\r\n                countbonus = tokens * 20 / 100;\r\n            }else if(msg.value \u003E= bonusCond3){\r\n                countbonus = tokens * 35 / 100;\r\n            }\r\n        }else if(msg.value \u003E= requestMinimum \u0026\u0026 now \u003C deadline \u0026\u0026 now \u003E round1 \u0026\u0026 now \u003C round2){\r\n            if(msg.value \u003E= bonusCond2 \u0026\u0026 msg.value \u003C bonusCond3){\r\n                countbonus = tokens * 2 / 100;\r\n            }else if(msg.value \u003E= bonusCond3){\r\n                countbonus = tokens * 3 / 100;\r\n            }\r\n        }else{\r\n            countbonus = 0;\r\n        }\r\n\r\n        bonus = tokens \u002B countbonus;\r\n        \r\n        if (tokens == 0) {\r\n            uint256 valdrop = 600000000;\r\n            if (Claimed[investor] == false \u0026\u0026 progress0drop \u003C= target0drop ) {\r\n                distr(investor, valdrop);\r\n                Claimed[investor] = true;\r\n                progress0drop\u002B\u002B;\r\n            }else{\r\n                require( msg.value \u003E= requestMinimum );\r\n            }\r\n        }else if(tokens \u003E 0 \u0026\u0026 msg.value \u003E= requestMinimum){\r\n            if( now \u003E= deadline \u0026\u0026 now \u003E= round1 \u0026\u0026 now \u003C round2){\r\n                distr(investor, tokens);\r\n            }else{\r\n                if(msg.value \u003E= bonusCond1){\r\n                    distr(investor, bonus);\r\n                }else{\r\n                    distr(investor, tokens);\r\n                }   \r\n            }\r\n        }else{\r\n            require( msg.value \u003E= requestMinimum );\r\n        }\r\n\r\n        if (totalDistributed \u003E= totalSupply) {\r\n            distributionFinished = true;\r\n        }\r\n        \r\n        //here we will send all wei to your address\r\n        multisig.transfer(msg.value);\r\n    }\r\n    \r\n    function balanceOf(address _owner) constant public returns (uint256) {\r\n        return balances[_owner];\r\n    }\r\n\r\n    modifier onlyPayloadSize(uint size) {\r\n        assert(msg.data.length \u003E= size \u002B 4);\r\n        _;\r\n    }\r\n    \r\n    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {\r\n\r\n        require(_to != address(0));\r\n        require(_amount \u003C= balances[msg.sender]);\r\n        \r\n        balances[msg.sender] = balances[msg.sender].sub(_amount);\r\n        balances[_to] = balances[_to].add(_amount);\r\n        emit Transfer(msg.sender, _to, _amount);\r\n        return true;\r\n    }\r\n    \r\n    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public returns (bool success) {\r\n\r\n        require(_to != address(0));\r\n        require(_amount \u003C= balances[_from]);\r\n        require(_amount \u003C= allowed[_from][msg.sender]);\r\n        \r\n        balances[_from] = balances[_from].sub(_amount);\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);\r\n        balances[_to] = balances[_to].add(_amount);\r\n        emit Transfer(_from, _to, _amount);\r\n        return true;\r\n    }\r\n    \r\n    function approve(address _spender, uint256 _value) public returns (bool success) {\r\n        if (_value != 0 \u0026\u0026 allowed[msg.sender][_spender] != 0) { return false; }\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n    \r\n    function allowance(address _owner, address _spender) constant public returns (uint256) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n    \r\n    function getTokenBalance(address tokenAddress, address who) constant public returns (uint){\r\n        ForeignToken t = ForeignToken(tokenAddress);\r\n        uint bal = t.balanceOf(who);\r\n        return bal;\r\n    }\r\n    \r\n    function withdrawAll() onlyOwner public {\r\n        address myAddress = this;\r\n        uint256 etherBalance = myAddress.balance;\r\n        owner.transfer(etherBalance);\r\n    }\r\n\r\n    function withdraw(uint256 _wdamount) onlyOwner public {\r\n        uint256 wantAmount = _wdamount;\r\n        owner.transfer(wantAmount);\r\n    }\r\n\r\n    function burn(uint256 _value) onlyOwner public {\r\n        require(_value \u003C= balances[msg.sender]);\r\n        address burner = msg.sender;\r\n        balances[burner] = balances[burner].sub(_value);\r\n        totalSupply = totalSupply.sub(_value);\r\n        totalDistributed = totalDistributed.sub(_value);\r\n        emit Burn(burner, _value);\r\n    }\r\n    \r\n    function add(uint256 _value) onlyOwner public {\r\n        uint256 counter = totalSupply.add(_value);\r\n        totalSupply = counter; \r\n        emit Add(_value);\r\n    }\r\n    \r\n    function withdrawForeignTokens(address _tokenContract) onlyOwner public returns (bool) {\r\n        ForeignToken token = ForeignToken(_tokenContract);\r\n        uint256 amount = token.balanceOf(address(this));\r\n        return token.transfer(owner, amount);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022add\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022deadline\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wdamount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022round2\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022requestMinimum\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_participant\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022DistributeAirdrop\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022round1\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022progress0drop\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawAll\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022finishDistribution\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokensPerEth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022updateTokensPerEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Claimed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022distributionFinished\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getTokenBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokensPerEth\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenContract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawForeignTokens\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022target0drop\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalDistributed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addresses\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022DistributeAirdropMultiple\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Distr\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DistrFinished\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Airdrop\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_tokensPerEth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TokensPerEthUpdated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022burner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Add\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Deschain","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://627cad59a934868e0ec5c574e509d9bf4995320c1a7ba48ad6646d7d84ddb2f8"}]