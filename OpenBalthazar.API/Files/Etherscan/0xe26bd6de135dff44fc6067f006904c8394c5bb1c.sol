[{"SourceCode":"pragma solidity \u003E=0.5.0;\r\n\r\ncontract ERC20{\r\n    function transfer(address to, uint value) public;\r\n    function transferFrom(address from, address to, uint value) public;\r\n    function approve(address spender, uint value) public;\r\n    event Transfer(address indexed from, address indexed to, uint value);\r\n    event Approval(address indexed owner, address indexed spender, uint value);\r\n}\r\n\r\n/// @title Main contract to staking processes\r\n/// @author Larry J. Smith\r\n/// @notice users can call public functions to interactive with staking smart contract including stake, withdraw, refund\r\n/// @dev Larry is one of the core technical engineers\r\ncontract Staking{\r\n\r\n    address payable userAddress;\r\n    uint totalStakingEtherAmt;\r\n    uint totalStakingTetherAmt;\r\n    uint totalWithdrawEtherAmt;\r\n    uint totalWithdrawTetherAmt;\r\n    bool isValid;\r\n    \r\n    address tether_0x_address = 0xdAC17F958D2ee523a2206206994597C13D831ec7;\r\n    string  identifier = \u00220xaa6adf5a0a0c2f5bc6432bc47374420b52402f78\u0022;\r\n    address public owner;\r\n    ERC20 tetherContract;\r\n\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner,\u0022invalid sender\u0022);\r\n        _;\r\n    }\r\n\r\n    event EtherStaking(address indexed addr, uint amount);\r\n    event TetherStaking(address indexed addr, uint amount);\r\n    event Withdrawal(address indexed addr, uint indexed _type , uint amount);\r\n    event Refund(address indexed addr);\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n        tetherContract =  ERC20(tether_0x_address);\r\n    }\r\n\r\n    function () external payable{\r\n        revert();\r\n    }\r\n\r\n    function stakeEther() public payable returns(bool){\r\n        address payable addr = msg.sender;\r\n        uint amount = msg.value;\r\n        require(amount \u003E 0, \u0022invalid amount\u0022);\r\n        if(isValid){\r\n            require(msg.sender == userAddress, \u0022invalid sender\u0022);\r\n            totalStakingEtherAmt \u002B= amount;\r\n        }else{\r\n            userAddress = addr;\r\n            totalStakingEtherAmt = amount;\r\n            totalStakingTetherAmt = 0;\r\n            totalWithdrawEtherAmt = 0;\r\n            totalWithdrawTetherAmt = 0;\r\n            isValid = true;\r\n        }\r\n        emit EtherStaking(addr, amount);\r\n        return true;\r\n    }\r\n\r\n    function stakeTether(uint amount) public returns(bool){\r\n        require(amount \u003E 0, \u0022invalid amount\u0022);\r\n        tetherContract.transferFrom(msg.sender,address(this),amount);\r\n        if(isValid){\r\n            require(msg.sender == userAddress, \u0022invalid sender\u0022);\r\n            totalStakingTetherAmt \u002B= amount;\r\n            \r\n        }else{\r\n            userAddress = msg.sender;\r\n            totalStakingEtherAmt = 0;\r\n            totalStakingTetherAmt = amount;\r\n            totalWithdrawEtherAmt = 0;\r\n            totalWithdrawTetherAmt = 0;\r\n            isValid = true;\r\n        }\r\n        emit TetherStaking(msg.sender, amount);\r\n        return true;\r\n    }\r\n\r\n    function withdraw(uint amount,uint _type) public returns(bool){\r\n        address addr = msg.sender;\r\n        require(amount \u003E 0,\u0022invalid amount\u0022);\r\n        require(addr == userAddress, \u0022invalid sender\u0022);\r\n\r\n        if(_type == 1){\r\n            require(totalStakingEtherAmt - totalWithdrawEtherAmt \u003E= amount, \u0022not enough balance\u0022);\r\n            totalWithdrawEtherAmt \u002B= amount;\r\n            userAddress.transfer(amount);\r\n            emit Withdrawal(addr, _type, amount);\r\n            return true;\r\n        }\r\n        if(_type == 2){\r\n            require(totalStakingTetherAmt - totalWithdrawTetherAmt \u003E= amount, \u0022not enough balance\u0022);\r\n            totalWithdrawTetherAmt \u002B= amount;\r\n            tetherContract.transfer(msg.sender, amount);\r\n            emit Withdrawal(addr, _type, amount);\r\n            return true;\r\n        }\r\n        return false;\r\n\r\n    }\r\n\r\n    function refund() public onlyOwner returns(bool){\r\n        if(isValid){\r\n            uint etherAmt = totalStakingEtherAmt - totalWithdrawEtherAmt;\r\n            uint tetherAmt = totalStakingTetherAmt - totalWithdrawTetherAmt;\r\n\r\n            if(etherAmt\u003E0){\r\n                userAddress.transfer(etherAmt);\r\n                totalWithdrawEtherAmt \u002B= etherAmt;\r\n            }\r\n            if(tetherAmt\u003E0){\r\n                tetherContract.transfer(userAddress, tetherAmt);\r\n                totalWithdrawTetherAmt \u002B=tetherAmt;\r\n            }\r\n            emit Refund(userAddress);\r\n            return true;\r\n        }\r\n        return false;\r\n    }\r\n\r\n    function getBalanceOf() public view returns(uint,uint,uint,uint,uint,uint){\r\n        return (totalStakingEtherAmt - totalWithdrawEtherAmt, totalStakingTetherAmt - totalWithdrawTetherAmt, totalStakingEtherAmt, totalStakingTetherAmt, totalWithdrawEtherAmt, totalWithdrawTetherAmt);\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_type\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022refund\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022stakeTether\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022stakeEther\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getBalanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022EtherStaking\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TetherStaking\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_type\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Withdrawal\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Refund\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Staking","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://1dd7cb33cdb534861bb00b283f2b058d2e70cab4605f8f01ba60f08a98ab21b2"}]