[{"SourceCode":"// File: contracts/lib/ownership/Ownable.sol\r\n\r\npragma solidity ^0.4.24;\r\n\r\ncontract Ownable {\r\n    address public owner;\r\n    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);\r\n\r\n    /// @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender account.\r\n    constructor() public { owner = msg.sender; }\r\n\r\n    /// @dev Throws if called by any contract other than latest designated caller\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    /// @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n    /// @param newOwner The address to transfer ownership to.\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: contracts/lib/token/FactoryTokenInterface.sol\r\n\r\npragma solidity ^0.4.24;\r\n\r\n\r\ncontract FactoryTokenInterface is Ownable {\r\n    function balanceOf(address _owner) public view returns (uint256);\r\n    function transfer(address _to, uint256 _value) public returns (bool);\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);\r\n    function approve(address _spender, uint256 _value) public returns (bool);\r\n    function allowance(address _owner, address _spender) public view returns (uint256);\r\n    function mint(address _to, uint256 _amount) public returns (bool);\r\n    function burnFrom(address _from, uint256 _value) public;\r\n}\r\n\r\n// File: contracts/lib/token/TokenFactoryInterface.sol\r\n\r\npragma solidity ^0.4.24;\r\n\r\n\r\ncontract TokenFactoryInterface {\r\n    function create(string _name, string _symbol) public returns (FactoryTokenInterface);\r\n}\r\n\r\n// File: contracts/lib/ownership/ZapCoordinatorInterface.sol\r\n\r\npragma solidity ^0.4.24;\r\n\r\n\r\ncontract ZapCoordinatorInterface is Ownable {\r\n    function addImmutableContract(string contractName, address newAddress) external;\r\n    function updateContract(string contractName, address newAddress) external;\r\n    function getContractName(uint index) public view returns (string);\r\n    function getContract(string contractName) public view returns (address);\r\n    function updateAllDependencies() external;\r\n}\r\n\r\n// File: contracts/platform/bondage/BondageInterface.sol\r\n\r\npragma solidity ^0.4.24;\r\n\r\ncontract BondageInterface {\r\n    function bond(address, bytes32, uint256) external returns(uint256);\r\n    function unbond(address, bytes32, uint256) external returns (uint256);\r\n    function delegateBond(address, address, bytes32, uint256) external returns(uint256);\r\n    function escrowDots(address, address, bytes32, uint256) external returns (bool);\r\n    function releaseDots(address, address, bytes32, uint256) external returns (bool);\r\n    function returnDots(address, address, bytes32, uint256) external returns (bool success);\r\n    function calcZapForDots(address, bytes32, uint256) external view returns (uint256);\r\n    function currentCostOfDot(address, bytes32, uint256) public view returns (uint256);\r\n    function getDotsIssued(address, bytes32) public view returns (uint256);\r\n    function getBoundDots(address, address, bytes32) public view returns (uint256);\r\n    function getZapBound(address, bytes32) public view returns (uint256);\r\n    function dotLimit( address, bytes32) public view returns (uint256);\r\n}\r\n\r\n// File: contracts/platform/bondage/currentCost/CurrentCostInterface.sol\r\n\r\npragma solidity ^0.4.24;\r\n\r\ncontract CurrentCostInterface {\r\n    function _currentCostOfDot(address, bytes32, uint256) public view returns (uint256);\r\n    function _dotLimit(address, bytes32) public view returns (uint256);\r\n    function _costOfNDots(address, bytes32, uint256, uint256) public view returns (uint256);\r\n}\r\n\r\n// File: contracts/platform/registry/RegistryInterface.sol\r\n\r\npragma solidity ^0.4.24;\r\n\r\ncontract RegistryInterface {\r\n    function initiateProvider(uint256, bytes32) public returns (bool);\r\n    function initiateProviderCurve(bytes32, int256[], address) public returns (bool);\r\n    function setEndpointParams(bytes32, bytes32[]) public;\r\n    function getEndpointParams(address, bytes32) public view returns (bytes32[]);\r\n    function getProviderPublicKey(address) public view returns (uint256);\r\n    function getProviderTitle(address) public view returns (bytes32);\r\n    function setProviderParameter(bytes32, bytes) public;\r\n    function setProviderTitle(bytes32) public;\r\n    function clearEndpoint(bytes32) public;\r\n    function getProviderParameter(address, bytes32) public view returns (bytes);\r\n    function getAllProviderParams(address) public view returns (bytes32[]);\r\n    function getProviderCurveLength(address, bytes32) public view returns (uint256);\r\n    function getProviderCurve(address, bytes32) public view returns (int[]);\r\n    function isProviderInitiated(address) public view returns (bool);\r\n    function getAllOracles() external view returns (address[]);\r\n    function getProviderEndpoints(address) public view returns (bytes32[]);\r\n    function getEndpointBroker(address, bytes32) public view returns (address);\r\n}\r\n\r\n// File: contracts/lib/platform/TokenDotFactory.sol\r\n\r\ncontract TokenDotFactory is Ownable {\r\n\r\n    CurrentCostInterface currentCost;\r\n    FactoryTokenInterface public reserveToken;\r\n    ZapCoordinatorInterface public coord;\r\n    TokenFactoryInterface public tokenFactory;\r\n    BondageInterface bondage;\r\n\r\n    mapping(bytes32 =\u003E address) public curves; // map of endpoint specifier to token-backed dotaddress\r\n    bytes32[] public curves_list; // array of endpoint specifiers\r\n    event DotTokenCreated(address tokenAddress);\r\n\r\n    constructor(\r\n        address coordinator, \r\n        address factory,\r\n        uint256 providerPubKey,\r\n        bytes32 providerTitle \r\n    ){\r\n        coord = ZapCoordinatorInterface(coordinator); \r\n        reserveToken = FactoryTokenInterface(coord.getContract(\u0022ZAP_TOKEN\u0022));\r\n        //always allow bondage to transfer from wallet\r\n        reserveToken.approve(coord.getContract(\u0022BONDAGE\u0022), ~uint256(0));\r\n        tokenFactory = TokenFactoryInterface(factory);\r\n\r\n        RegistryInterface registry = RegistryInterface(coord.getContract(\u0022REGISTRY\u0022)); \r\n        registry.initiateProvider(providerPubKey, providerTitle);\r\n    }\r\n\r\n    function initializeCurve(\r\n        bytes32 specifier, \r\n        bytes32 symbol, \r\n        int256[] curve\r\n    ) public returns(address) {\r\n        \r\n        require(curves[specifier] == 0, \u0022Curve specifier already exists\u0022);\r\n        \r\n        RegistryInterface registry = RegistryInterface(coord.getContract(\u0022REGISTRY\u0022)); \r\n        require(registry.isProviderInitiated(address(this)), \u0022Provider not intiialized\u0022);\r\n\r\n        registry.initiateProviderCurve(specifier, curve, address(this));\r\n        curves[specifier] = newToken(bytes32ToString(specifier), bytes32ToString(symbol));\r\n        curves_list.push(specifier);\r\n        \r\n        registry.setProviderParameter(specifier, toBytes(curves[specifier]));\r\n        \r\n        DotTokenCreated(curves[specifier]);\r\n        return curves[specifier];\r\n    }\r\n\r\n\r\n    event Bonded(bytes32 indexed specifier, uint256 indexed numDots, address indexed sender); \r\n\r\n    //whether this contract holds tokens or coming from msg.sender,etc\r\n    function bond(bytes32 specifier, uint numDots) public  {\r\n\r\n        bondage = BondageInterface(coord.getContract(\u0022BONDAGE\u0022));\r\n        uint256 issued = bondage.getDotsIssued(address(this), specifier);\r\n\r\n        CurrentCostInterface cost = CurrentCostInterface(coord.getContract(\u0022CURRENT_COST\u0022));\r\n        uint256 numReserve = cost._costOfNDots(address(this), specifier, issued \u002B 1, numDots - 1);\r\n\r\n        require(\r\n            reserveToken.transferFrom(msg.sender, address(this), numReserve),\r\n            \u0022insufficient accepted token numDots approved for transfer\u0022\r\n        );\r\n\r\n        reserveToken.approve(address(bondage), numReserve);\r\n        bondage.bond(address(this), specifier, numDots);\r\n        FactoryTokenInterface(curves[specifier]).mint(msg.sender, numDots);\r\n        Bonded(specifier, numDots, msg.sender);\r\n\r\n    }\r\n\r\n    event Unbonded(bytes32 indexed specifier, uint256 indexed numDots, address indexed sender); \r\n\r\n    //whether this contract holds tokens or coming from msg.sender,etc\r\n    function unbond(bytes32 specifier, uint numDots) public {\r\n        bondage = BondageInterface(coord.getContract(\u0022BONDAGE\u0022));\r\n        uint issued = bondage.getDotsIssued(address(this), specifier);\r\n\r\n        currentCost = CurrentCostInterface(coord.getContract(\u0022CURRENT_COST\u0022));\r\n        uint reserveCost = currentCost._costOfNDots(address(this), specifier, issued \u002B 1 - numDots, numDots - 1);\r\n\r\n        //unbond dots\r\n        bondage.unbond(address(this), specifier, numDots);\r\n        //burn dot backed token\r\n        FactoryTokenInterface curveToken = FactoryTokenInterface(curves[specifier]);\r\n        curveToken.burnFrom(msg.sender, numDots);\r\n\r\n        require(reserveToken.transfer(msg.sender, reserveCost), \u0022Error: Transfer failed\u0022);\r\n        Unbonded(specifier, numDots, msg.sender);\r\n\r\n    }\r\n\r\n    function newToken(\r\n        string name,\r\n        string symbol\r\n    ) \r\n        public\r\n        returns (address tokenAddress) \r\n    {\r\n        FactoryTokenInterface token = tokenFactory.create(name, symbol);\r\n        tokenAddress = address(token);\r\n        return tokenAddress;\r\n    }\r\n\r\n    function getTokenAddress(bytes32 endpoint) public view returns(address) {\r\n        RegistryInterface registry = RegistryInterface(coord.getContract(\u0022REGISTRY\u0022));\r\n        return bytesToAddr(registry.getProviderParameter(address(this), endpoint));\r\n    }\r\n\r\n    function getEndpoints() public view returns(bytes32[]){\r\n      return curves_list;\r\n    }\r\n\r\n    // https://ethereum.stackexchange.com/questions/884/how-to-convert-an-address-to-bytes-in-solidity\r\n    function toBytes(address x) public pure returns (bytes b) {\r\n        b = new bytes(20);\r\n        for (uint i = 0; i \u003C 20; i\u002B\u002B)\r\n            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));\r\n    }\r\n\r\n    //https://ethereum.stackexchange.com/questions/2519/how-to-convert-a-bytes32-to-string\r\n    function bytes32ToString(bytes32 x) public pure returns (string) {\r\n        bytes memory bytesString = new bytes(32);\r\n\r\n        bytesString = abi.encodePacked(x);\r\n\r\n        return string(bytesString);\r\n    }\r\n\r\n    //https://ethereum.stackexchange.com/questions/15350/how-to-convert-an-bytes-to-address-in-solidity\r\n    function bytesToAddr (bytes b) public pure returns (address) {\r\n        uint result = 0;\r\n        for (uint i = b.length-1; i\u002B1 \u003E 0; i--) {\r\n            uint c = uint(b[i]);\r\n            uint to_inc = c * ( 16 ** ((b.length - i-1) * 2));\r\n            result \u002B= to_inc;\r\n        }\r\n        return address(result);\r\n    }\r\n\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022specifier\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022symbol\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022curve\u0022,\u0022type\u0022:\u0022int256[]\u0022}],\u0022name\u0022:\u0022initializeCurve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022symbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022newToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022specifier\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022numDots\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022unbond\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022specifier\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022numDots\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022bond\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022x\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022toBytes\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getEndpoints\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022bytesToAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022curves\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022x\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022bytes32ToString\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022coord\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022endpoint\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getTokenAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenFactory\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022curves_list\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022reserveToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022coordinator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022factory\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022providerPubKey\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022providerTitle\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022DotTokenCreated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022specifier\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022numDots\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Bonded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022specifier\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022numDots\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Unbonded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TokenDotFactory","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000b007eca49763f31edff95623ed6c23c8c1924a1600000000000000000000000098a8e7bebd444d38294ef66b240804c236fbb583000000036b5252a719be12e4aa87faf67a410ce894d0f79a997fc21ee379ff3d4861636b6174686f6e466163746f727900000000000000000000000000000000","Library":"","SwarmSource":"bzzr://b5890266d1aca886c61e562b137d285f553a8210ff6454eefec4fd42419fa231"}]