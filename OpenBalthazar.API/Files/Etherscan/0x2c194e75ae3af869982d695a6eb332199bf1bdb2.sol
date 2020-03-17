[{"SourceCode":"pragma solidity 0.5.8;\r\n\r\ncontract Ownable {\r\n    address public owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner, \u0022Called by unknown account\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(address newOwner) onlyOwner public {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n}\r\n\r\ncontract GameGuess is Ownable {\r\n    event Status(address indexed user, uint number, uint wins, uint loses, int profit);\r\n\r\n    struct GameStats {\r\n        uint wins;\r\n        uint loses;\r\n        int profit;\r\n    }\r\n\r\n    mapping(address =\u003E GameStats) public userGameStats;\r\n\r\n    function play(uint8 chance, bool sign) external payable notContract {\r\n        if (msg.sender == owner) return;\r\n        uint16 number = chance;\r\n        if (sign) number = 100 - chance;\r\n        uint multiplier = getMultiplier(chance);\r\n        require(msg.value \u003E 0 \u0026\u0026 address(this).balance \u003E (multiplier * msg.value) / 10000, \u0022Incorrect bet\u0022);\r\n        require(number \u003E= 1 \u0026\u0026 number \u003C 100, \u0022Invalid number\u0022);\r\n        uint16 randomNumber = random();\r\n        bool result = false;\r\n        if (sign) result = randomNumber \u003E (number * 10);\r\n        else result = randomNumber \u003C (number * 10);\r\n        if (result) {\r\n            uint prize = (msg.value * multiplier) / 10000;\r\n            userGameStats[msg.sender].wins\u002B\u002B;\r\n            userGameStats[msg.sender].profit \u002B= int(prize);\r\n            msg.sender.transfer(prize);\r\n        } else {\r\n            userGameStats[msg.sender].loses\u002B\u002B;\r\n            userGameStats[msg.sender].profit -= int(msg.value);\r\n        }\r\n        emit Status(msg.sender,\r\n            randomNumber,\r\n            userGameStats[msg.sender].wins,\r\n            userGameStats[msg.sender].loses,\r\n            userGameStats[msg.sender].profit\r\n        );\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to withdraw certain amount of ether from the contract.\r\n     * @param amount Amount of wei that needs to be withdrawn.\r\n     */\r\n    function withdraw(uint amount) external onlyOwner {\r\n        require(address(this).balance \u003E= amount);\r\n        msg.sender.transfer(amount);\r\n    }\r\n\r\n    function getMultiplier(uint number) public pure returns (uint) {\r\n        uint multiplier = (99 * 100000) / number;\r\n        if (multiplier % 10 \u003E= 5) multiplier \u002B= 10;\r\n        multiplier = multiplier / 10;\r\n\r\n        return multiplier;\r\n    }\r\n\r\n    function random() private view returns (uint16) {\r\n        uint totalGames = userGameStats[msg.sender].wins \u002B userGameStats[msg.sender].loses;\r\n        return uint16(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, totalGames))) % 1000) \u002B 1;\r\n    }\r\n\r\n    modifier notContract {\r\n        uint size;\r\n        address addr = msg.sender;\r\n        assembly {size := extcodesize(addr)}\r\n        require(size \u003C= 0 \u0026\u0026 tx.origin == addr, \u0022Called by contract\u0022);\r\n        _;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022userGameStats\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022wins\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022loses\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022profit\u0022,\u0022type\u0022:\u0022int256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022number\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getMultiplier\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022chance\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022sign\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022play\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022number\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022wins\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022loses\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022profit\u0022,\u0022type\u0022:\u0022int256\u0022}],\u0022name\u0022:\u0022Status\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"GameGuess","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://286ed83347e27c670be3c02b52b1ff3408cece856d758f49fab7063585c7d7cd"}]