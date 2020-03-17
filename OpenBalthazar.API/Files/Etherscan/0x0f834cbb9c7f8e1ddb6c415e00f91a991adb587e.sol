[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\n/**\r\n * Library to handle user permissions.\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(\r\n        address indexed previousOwner,\r\n        address indexed newOwner\r\n    );\r\n\r\n    /** @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender account. */\r\n    constructor()\r\n        internal\r\n    {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /** @return the address of the owner. */\r\n    function owner()\r\n        public\r\n        view\r\n        returns(address)\r\n    {\r\n        return _owner;\r\n    }\r\n\r\n    /** @dev Throws if called by any account other than the owner. */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022NOT_OWNER\u0022);\r\n        _;\r\n    }\r\n\r\n    /** @return true if \u0060msg.sender\u0060 is the owner of the contract. */\r\n    function isOwner()\r\n        public\r\n        view\r\n        returns(bool)\r\n    {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /** @dev Allows the current owner to relinquish control of the contract.\r\n     * @notice Renouncing to ownership will leave the contract without an owner.\r\n     * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n     * modifier anymore.\r\n     */\r\n    function renounceOwnership()\r\n        public\r\n        onlyOwner\r\n    {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /** @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(\r\n        address newOwner\r\n    )\r\n        public\r\n        onlyOwner\r\n    {\r\n        require(newOwner != address(0), \u0022INVALID_OWNER\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\ncontract Eth2daiInterface {\r\n    // sellAllAmount(ERC20 pay_gem, uint pay_amt, ERC20 buy_gem, uint min_fill_amount)\r\n    function sellAllAmount(address, uint, address, uint) public returns (uint);\r\n}\r\n\r\ncontract TokenInterface {\r\n    function balanceOf(address) public returns (uint);\r\n    function allowance(address, address) public returns (uint);\r\n    function approve(address, uint) public;\r\n    function transfer(address,uint) public returns (bool);\r\n    function transferFrom(address, address, uint) public returns (bool);\r\n    function deposit() public payable;\r\n    function withdraw(uint) public;\r\n}\r\n\r\ncontract Eth2daiDirect is Ownable {\r\n\r\n    Eth2daiInterface public constant eth2dai = Eth2daiInterface(0x794e6e91555438aFc3ccF1c5076A74F42133d08D);\r\n    TokenInterface public constant wethToken = TokenInterface(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);\r\n    TokenInterface public constant daiToken = TokenInterface(0x6B175474E89094C44Da98b954EedeAC495271d0F);\r\n\r\n    constructor()\r\n        public\r\n    {\r\n        daiToken.approve(address(eth2dai), 2**256-1);\r\n        wethToken.approve(address(eth2dai), 2**256-1);\r\n    }\r\n\r\n    function marketBuyEth(\r\n        uint256 payDaiAmount,\r\n        uint256 minBuyEthAmount\r\n    )\r\n        public\r\n    {\r\n        daiToken.transferFrom(msg.sender, address(this), payDaiAmount);\r\n        uint256 fillAmount = eth2dai.sellAllAmount(address(daiToken), payDaiAmount, address(wethToken), minBuyEthAmount);\r\n        wethToken.withdraw(fillAmount);\r\n        msg.sender.transfer(fillAmount);\r\n    }\r\n\r\n    function marketSellEth(\r\n        uint256 payEthAmount,\r\n        uint256 minBuyDaiAmount\r\n    )\r\n        public\r\n        payable\r\n    {\r\n        require(msg.value == payEthAmount, \u0022MSG_VALUE_NOT_MATCH\u0022);\r\n        wethToken.deposit.value(msg.value)();\r\n        uint256 fillAmount = eth2dai.sellAllAmount(address(wethToken), payEthAmount, address(daiToken), minBuyDaiAmount);\r\n        daiToken.transfer(msg.sender, fillAmount);\r\n    }\r\n\r\n    function withdraw(\r\n        address tokenAddress,\r\n        uint256 amount\r\n    )\r\n        public\r\n        onlyOwner\r\n    {\r\n        if (tokenAddress == address(0)) {\r\n            msg.sender.transfer(amount);\r\n        } else {\r\n            TokenInterface(tokenAddress).transfer(msg.sender, amount);\r\n        }\r\n    }\r\n\r\n    function() external payable {\r\n        require(msg.sender == address(wethToken), \u0022CONTRACT_NOT_PAYABLE\u0022);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022payDaiAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022minBuyEthAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022marketBuyEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022wethToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022eth2dai\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022daiToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022payEthAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022minBuyDaiAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022marketSellEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Eth2daiDirect","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://a5116f4597652ad52ab10dc5fa996506121a43e82cee0eb077ac8f793693029e"}]