[{"SourceCode":"pragma solidity 0.4.25;\r\n\r\nlibrary SafeMath {\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n\r\n        return c;\r\n    }\r\n\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\npragma solidity 0.4.25;\r\n\r\n    contract GODToken {\r\n\r\n        string public name;\r\n\r\n        string public symbol;\r\n\r\n        uint8 public decimals;\r\n\r\n        uint public totalSupply;\r\n\r\n        uint public supplied;\r\n\r\n        uint public surplusSupply;\r\n\r\n        uint beforeFrequency = 0;\r\n\r\n        uint centerFrequency = 300;\r\n\r\n        uint afterFrequency = 400;\r\n\r\n        address owner;\r\n\r\n        uint public usdtPrice = 10000;\r\n\r\n\r\n        address lotteryAddr;\r\n\r\n        address gameAddr;\r\n\r\n        address themisAddr;\r\n\r\n        mapping(address =\u003E uint) public balanceOf;\r\n\r\n        mapping(address =\u003E mapping(address =\u003E uint)) public allowance;\r\n\r\n        constructor(\r\n            string _name,\r\n            string _symbol,\r\n            uint8 _decimals,\r\n            uint _totalSupply,\r\n            address _owner\r\n        )  public {\r\n            name = _name;\r\n            symbol = _symbol;\r\n            decimals = _decimals;\r\n            totalSupply = _totalSupply * (10 ** uint256(decimals));\r\n            owner = _owner;\r\n            surplusSupply = totalSupply;\r\n        }\r\n\r\n        event Transfer(address indexed from, address indexed to,uint value);\r\n\r\n        event Approval(address indexed owner, address indexed spender, uint256 value);\r\n\r\n        modifier validDestination(address _to) {\r\n            require(_to != address(0x0), \u0022address cannot be 0x0\u0022);\r\n            require(_to != address(this), \u0022address cannot be contract address\u0022);\r\n            _;\r\n        }\r\n\r\n        function setAuthorityAddr(address gAddr, address lAddr, address tAddr) external {\r\n            require(owner == msg.sender, \u0022Insufficient permissions\u0022);\r\n            gameAddr = gAddr;\r\n            lotteryAddr = lAddr;\r\n            themisAddr = tAddr;\r\n        }\r\n\r\n        function calculationNeedGOD(uint usdtVal) external view returns(uint) {\r\n            uint godCount = SafeMath.div(SafeMath.div(usdtVal * 10 ** 8, 10), usdtPrice);\r\n            return godCount;\r\n        }\r\n\r\n        function gainGODToken(uint value, bool isCovert) external {\r\n            require(msg.sender == lotteryAddr || msg.sender == themisAddr, \u0022Insufficient permissions\u0022);\r\n            require(value \u003C= surplusSupply, \u0022GOD tokens are larger than the remaining supply\u0022);\r\n            if(isCovert) {\r\n                surplusSupply = SafeMath.sub(surplusSupply, value);\r\n                supplied = SafeMath.add(supplied, value);\r\n                uint number = SafeMath.div(supplied, (10 ** uint256(decimals)) * 10 ** 4);\r\n                if(number \u003C= 18900) {\r\n                    uint count = 0;\r\n                    if(number \u003C= 6000) {\r\n                        count = SafeMath.div(number, 10);\r\n                        if(count \u003E beforeFrequency) {\r\n                            for(uint i = beforeFrequency; i \u003C count; i\u002B\u002B) {\r\n                                usdtPrice = SafeMath.add(usdtPrice, SafeMath.div(usdtPrice, 100));\r\n                            }\r\n                            beforeFrequency = count;\r\n                        }\r\n                    }else if(number \u003C= 12000) {\r\n                        if(beforeFrequency \u003C 600) {\r\n                            count = 600;\r\n                            for(uint i2 = beforeFrequency; i2 \u003C count; i2\u002B\u002B) {\r\n                                usdtPrice = SafeMath.add(usdtPrice, SafeMath.div(usdtPrice, 100));\r\n                            }\r\n                            beforeFrequency = count;\r\n                        }\r\n                        count = SafeMath.div(number, 20);\r\n                        if(count \u003E centerFrequency) {\r\n                            for(uint j = centerFrequency; j \u003C count; j\u002B\u002B) {\r\n                                usdtPrice = SafeMath.add(usdtPrice, SafeMath.div(usdtPrice, 100));\r\n                            }\r\n                            centerFrequency = count;\r\n                        }\r\n                    }else {\r\n                        if(centerFrequency \u003C 600) {\r\n                            count = 600;\r\n                            for(uint j2 = centerFrequency; j2 \u003C count; j2\u002B\u002B) {\r\n                                usdtPrice = SafeMath.add(usdtPrice, SafeMath.div(usdtPrice, 100));\r\n                            }\r\n                            centerFrequency = count;\r\n                        }\r\n                        count = SafeMath.div(number, 30);\r\n                        if(count \u003E afterFrequency) {\r\n                            for(uint k = 0; k \u003C count; k\u002B\u002B) {\r\n                                usdtPrice = SafeMath.add(usdtPrice, SafeMath.div(usdtPrice, 100));\r\n                            }\r\n                            afterFrequency = count;\r\n                        }\r\n                    }\r\n                }\r\n            }\r\n            balanceOf[msg.sender] = SafeMath.add(balanceOf[msg.sender], value);\r\n        }\r\n\r\n        function transfer(address to, uint value) public validDestination(to) {\r\n            require(value \u003E= 0, \u0022Incorrect transfer amount\u0022);\r\n            require(balanceOf[msg.sender] \u003E= value, \u0022Insufficient balance\u0022);\r\n            require(balanceOf[to] \u002B value \u003E= balanceOf[to], \u0022Transfer failed\u0022);\r\n\r\n            balanceOf[msg.sender] = SafeMath.sub(balanceOf[msg.sender], value);\r\n            balanceOf[to] = SafeMath.add(balanceOf[to], value);\r\n\r\n            emit Transfer(msg.sender, to, value);\r\n        }\r\n\r\n        function approve(address spender, uint value) public {\r\n              require((value == 0) || (allowance[msg.sender][spender] == 0));\r\n              allowance[msg.sender][spender] = value;\r\n              emit Approval(msg.sender, spender, value);\r\n        }\r\n\r\n        function transferFrom(\r\n            address from,\r\n            address to,\r\n            uint value\r\n            )\r\n            public validDestination(to) {\r\n            require(value \u003E= 0, \u0022Incorrect transfer amount\u0022);\r\n            require(balanceOf[from] \u003E= value, \u0022Insufficient balance\u0022);\r\n            require(balanceOf[to] \u002B value \u003E= balanceOf[to], \u0022Transfer failed\u0022);\r\n            require(value \u003C= allowance[from][msg.sender], \u0022The transfer amount is higher than the available amount\u0022);\r\n\r\n            balanceOf[from] = SafeMath.sub(balanceOf[from], value);\r\n            balanceOf[to] = SafeMath.add(balanceOf[to], value);\r\n            allowance[from][msg.sender] = SafeMath.sub(allowance[from][msg.sender], value);\r\n\r\n            emit Transfer(from, to, value);\r\n        }\r\n\r\n        function burn(address addr, uint value) public {\r\n            require(msg.sender == gameAddr, \u0022Insufficient permissions\u0022);\r\n            require(balanceOf[addr] \u003E= value, \u0022Insufficient GOD required\u0022);\r\n            balanceOf[addr] = SafeMath.sub(balanceOf[addr], value);\r\n            balanceOf[address(0x0)] = SafeMath.add(balanceOf[address(0x0)], value);\r\n\r\n            emit Transfer(addr, address(0x0), value);\r\n        }\r\n    }","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022gAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022lAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setAuthorityAddr\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022usdtVal\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022calculationNeedGOD\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022supplied\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022isCovert\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022gainGODToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022surplusSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022usdtPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_totalSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"GODToken","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"00000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000c8458800000000000000000000000003b2c68f61a2c98bb0a4cf2ddc8cb0bec3957e1c10000000000000000000000000000000000000000000000000000000000000009474f4420546f6b656e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003474f440000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://e7b25cf0bc9eeca3c6190d8c9f20579aa10031f6fdba76b69d2e6fb9797f460a"}]