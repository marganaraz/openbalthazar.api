[{"SourceCode":"pragma solidity ^0.4.16;\r\ncontract Token{\r\n    uint256 public totalSupply;\r\n\r\n    function balanceOf(address _owner) public constant returns (uint256 balance);\r\n    function trashOf(address _owner) public constant returns (uint256 trash);\r\n    function transfer(address _to, uint256 _value) public returns (bool success);\r\n    function inTrash(uint256 _value) internal returns (bool success);\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\r\n    function approve(address _spender, uint256 _value) public returns (bool success);\r\n    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);\r\n    \r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event InTrash(address indexed _from, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n    event transferLogs(address,string,uint);\r\n}\r\n\r\ncontract AladTTS is Token {\r\n    // ===============\r\n    // BASE \r\n    // ===============\r\n    string public name;                 //\u540D\u79F0\r\n    string public symbol;               //token\u7B80\u79F0\r\n    uint32 public rate;                 //\u95E8\u7968\u6C47\u7387\r\n    uint32 public consume;              //\u95E8\u7968\u6D88\u8017\r\n    uint256 public totalConsume;        //\u95E8\u7968\u603B\u6D88\u8017\r\n    uint256 public bigJackpot;          //\u5927\u5956\u6C60 \r\n    uint256 public smallJackpot;        //\u5C0F\u5956\u6C60\r\n    uint256 public consumeRule;         //\u51CF\u534A\u89C4\u5219\r\n    address owner;                      //\u5408\u7EA6\u4F5C\u8005\r\n  \r\n    // ===============\r\n    // INIT \r\n    // ===============\r\n    modifier onlyOwner(){\r\n        require (msg.sender==owner);\r\n        _;\r\n    }\r\n    function () payable public {}\r\n    \r\n    // \u6784\u9020\u5668\r\n    function AladTTS(uint256 _initialAmount, string _tokenName, uint32 _rate) public payable {\r\n        owner = msg.sender;\r\n        totalSupply = _initialAmount * 10 ;         // \u8BBE\u7F6E\u521D\u59CB\u603B\u91CF\r\n        balances[owner] = totalSupply; // \u521D\u59CBtoken\u6570\u91CF\u7ED9\u4E88\u6D88\u606F\u53D1\u9001\u8005\uFF0C\u56E0\u4E3A\u662F\u6784\u9020\u51FD\u6570\uFF0C\u6240\u4EE5\u8FD9\u91CC\u4E5F\u662F\u5408\u7EA6\u7684\u521B\u5EFA\u8005\r\n        name = _tokenName;            \r\n        symbol = _tokenName;\r\n        rate = _rate;\r\n        consume = _rate/10;\r\n        totalConsume = 0;\r\n        consumeRule = 0;\r\n        bigJackpot = 0;\r\n        smallJackpot = 0;\r\n    }  \r\n    \r\n    // ===============\r\n    // ETH \r\n    // ===============\r\n    // \u83B7\u53D6\u5408\u7EA6\u8D26\u6237\u4F59\u989D\r\n    function getBalance() public constant returns(uint){\r\n        return address(this).balance;\r\n    }\r\n    \r\n    // \u6279\u91CF\u51FA\u8D26\r\n    function sendAll(address[] _users,uint[] _prices,uint _allPrices) public onlyOwner{\r\n        require(_users.length\u003E0);\r\n        require(_prices.length\u003E0);\r\n        require(address(this).balance\u003E=_allPrices);\r\n        for(uint32 i =0;i\u003C_users.length;i\u002B\u002B){\r\n            require(_users[i]!=address(0));\r\n            require(_prices[i]\u003E0);\r\n            _users[i].transfer(_prices[i]);  \r\n            transferLogs(_users[i],\u0027\u8F6C\u8D26\u0027,_prices[i]);\r\n        }\r\n    }\r\n    // \u5408\u7EA6\u51FA\u8D26\r\n    function sendTransfer(address _user,uint _price) public onlyOwner{\r\n        if(address(this).balance\u003E=_price){\r\n            _user.transfer(_price);\r\n            transferLogs(_user,\u0027\u8F6C\u8D26\u0027,_price);\r\n        }\r\n    }\r\n    // \u63D0\u5E01\r\n    function getEth(uint _price) public onlyOwner{\r\n        if(_price\u003E0){\r\n            if(address(this).balance\u003E=_price){\r\n                owner.transfer(_price);\r\n            }\r\n        }else{\r\n           owner.transfer(address(this).balance); \r\n        }\r\n    }\r\n    \r\n    // ===============\r\n    // TICKET \r\n    // ===============\r\n    // \u8BBE\u7F6E\u95E8\u7968\u5151\u6362\u6BD4\u4F8B\r\n    function checkConsume(uint256 _conume) internal returns(bool success){\r\n        require(_conume-1000000\u003E0);\r\n        \r\n        rate = rate / 2;\r\n        consume = consume / 2;\r\n        consumeRule = consumeRule - 1000000;\r\n        return true;\r\n    }\r\n    \r\n    // \u8D2D\u4E70\u95E8\u7968\r\n    function tickets() public payable returns(bool success){\r\n        require(msg.value % 1 ether == 0);\r\n        uint e = msg.value / 1 ether;\r\n        e=e*rate;\r\n        require(balances[owner]\u003E=e);\r\n        balances[owner]-=e;\r\n        balances[msg.sender]\u002B=e;\r\n        setJackpot(msg.value);\r\n        return true;\r\n    }\r\n    // \u95E8\u7968\u6D88\u8017\r\n    function ticketConsume()public payable returns(bool success){\r\n        require(msg.value % 1 ether == 0);\r\n        uint e = msg.value / 1 ether * consume;\r\n        \r\n        require(balances[msg.sender]\u003E=e); \r\n        balances[msg.sender]-=e;\r\n        trash[msg.sender]\u002B=e;\r\n        totalConsume\u002B=e;\r\n        consumeRule\u002B=e;\r\n        checkConsume(consumeRule);\r\n        setJackpot(msg.value);\r\n        return true;\r\n    }\r\n\r\n    // ===============\r\n    // JACKPOT \r\n    // ===============\r\n    // \u7D2F\u52A0\u5956\u6C60\r\n    function setJackpot(uint256 _value) internal{\r\n        uint256 jackpot = _value * 12 / 100;\r\n        bigJackpot \u002B= jackpot * 7 / 10;\r\n        smallJackpot \u002B= jackpot * 3 / 10;\r\n    }\r\n    // \u5C0F\u5956\u6C60\u51FA\u8D26\r\n    function smallCheckOut(address[] _users) public onlyOwner{\r\n        require(_users.length\u003E0);\r\n        require(address(this).balance\u003E=smallJackpot);\r\n        uint256 pricce = smallJackpot / _users.length;\r\n        for(uint32 i =0;i\u003C_users.length;i\u002B\u002B){\r\n            require(_users[i]!=address(0));\r\n            require(pricce\u003E0);\r\n            _users[i].transfer(pricce);  \r\n            transferLogs(_users[i],\u0027\u8F6C\u8D26\u0027,pricce);\r\n        }\r\n        smallJackpot=0;\r\n    }\r\n    // \u5927\u5956\u6C60\u51FA\u8D26\r\n    function bigCheckOut(address[] _users) public onlyOwner{\r\n        require(_users.length\u003E0 \u0026\u0026 bigJackpot\u003E=30000 ether\u0026\u0026address(this).balance\u003E=bigJackpot);\r\n        uint256 pricce = bigJackpot / _users.length;\r\n        for(uint32 i =0;i\u003C_users.length;i\u002B\u002B){\r\n            require(_users[i]!=address(0));\r\n            require(pricce\u003E0);\r\n            _users[i].transfer(pricce);  \r\n            transferLogs(_users[i],\u0027\u8F6C\u8D26\u0027,pricce);\r\n        }\r\n        bigJackpot = 0;\r\n    }\r\n    // ===============\r\n    // TOKEN \r\n    // ===============\r\n    function inTrash(uint256 _value) internal returns (bool success) {\r\n        require(balances[msg.sender] \u003E= _value);\r\n        balances[msg.sender] -= _value;//\u4ECE\u6D88\u606F\u53D1\u9001\u8005\u8D26\u6237\u4E2D\u51CF\u53BBtoken\u6570\u91CF_value\r\n        trash[msg.sender] \u002B= _value;//\u5F53\u524D\u5783\u573E\u6876\u589E\u52A0token\u6570\u91CF_value\r\n        totalConsume \u002B= _value;\r\n        InTrash(msg.sender,  _value);//\u89E6\u53D1\u5783\u573E\u6876\u6D88\u8017\u4E8B\u4EF6\r\n        return true;\r\n    }\r\n    \r\n    function transfer(address _to, uint256 _value) public returns (bool success) {\r\n        //\u9ED8\u8BA4totalSupply \u4E0D\u4F1A\u8D85\u8FC7\u6700\u5927\u503C (2^256 - 1).\r\n        //\u5982\u679C\u968F\u7740\u65F6\u95F4\u7684\u63A8\u79FB\u5C06\u4F1A\u6709\u65B0\u7684token\u751F\u6210\uFF0C\u5219\u53EF\u4EE5\u7528\u4E0B\u9762\u8FD9\u53E5\u907F\u514D\u6EA2\u51FA\u7684\u5F02\u5E38\r\n        require(balances[msg.sender] \u003E= _value \u0026\u0026 balances[_to] \u002B _value \u003E balances[_to]);\r\n        require(_to != 0x0);\r\n        balances[msg.sender] -= _value;//\u4ECE\u6D88\u606F\u53D1\u9001\u8005\u8D26\u6237\u4E2D\u51CF\u53BBtoken\u6570\u91CF_value\r\n        balances[_to] \u002B= _value;//\u5F80\u63A5\u6536\u8D26\u6237\u589E\u52A0token\u6570\u91CF_value\r\n        Transfer(msg.sender, _to, _value);//\u89E6\u53D1\u8F6C\u5E01\u4EA4\u6613\u4E8B\u4EF6\r\n        return true;\r\n    }\r\n    \r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\r\n        require(balances[_from] \u003E= _value \u0026\u0026 allowed[_from][msg.sender] \u003E= _value);\r\n        balances[_to] \u002B= _value;//\u63A5\u6536\u8D26\u6237\u589E\u52A0token\u6570\u91CF_value\r\n        balances[_from] -= _value; //\u652F\u51FA\u8D26\u6237_from\u51CF\u53BBtoken\u6570\u91CF_value\r\n        allowed[_from][msg.sender] -= _value;//\u6D88\u606F\u53D1\u9001\u8005\u53EF\u4EE5\u4ECE\u8D26\u6237_from\u4E2D\u8F6C\u51FA\u7684\u6570\u91CF\u51CF\u5C11_value\r\n        Transfer(_from, _to, _value);//\u89E6\u53D1\u8F6C\u5E01\u4EA4\u6613\u4E8B\u4EF6\r\n        return true;\r\n    }\r\n    // \u7528\u6237\u4EE3\u5E01\r\n    function balanceOf(address _owner) public constant returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n    // \u7528\u6237\u4EE3\u5E01\u6D88\u8017\u503C\r\n    function trashOf(address _owner) public constant returns (uint256 trashs) {\r\n        return trash[_owner];\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool success)   { \r\n        allowed[msg.sender][_spender] = _value;\r\n        Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {\r\n        return allowed[_owner][_spender];//\u5141\u8BB8_spender\u4ECE_owner\u4E2D\u8F6C\u51FA\u7684token\u6570\r\n    }\r\n    \r\n    mapping (address =\u003E uint256) trash;\r\n    mapping (address =\u003E uint256) balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) allowed;\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022consume\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tickets\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022rate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_users\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022bigCheckOut\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022bigJackpot\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ticketConsume\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_users\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022smallCheckOut\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022smallJackpot\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sendTransfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022trashOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022trashs\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_users\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_prices\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022_allPrices\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sendAll\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022consumeRule\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalConsume\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_initialAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tokenName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_rate\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022InTrash\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferLogs\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"AladTTS","CompilerVersion":"v0.4.16\u002Bcommit.d7661dd9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000000000000000000000000000000000000501bd0000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000001a0a00000000000000000000000000000000000000000000000000000000000000035454530000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://adb93e8d5930f6ac018cd1ca873541a32e8015252979dd4814cb623436b7d191"}]