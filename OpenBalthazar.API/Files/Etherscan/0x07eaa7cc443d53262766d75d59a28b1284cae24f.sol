[{"SourceCode":"pragma solidity ^0.4.25;\r\n\r\n// File: contracts/lib/ownership/Ownable.sol\r\n\r\ncontract Ownable {\r\n    address public owner;\r\n    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);\r\n\r\n    /// @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender account.\r\n    constructor() public { owner = msg.sender; }\r\n\r\n    /// @dev Throws if called by any contract other than latest designated caller\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    /// @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n    /// @param newOwner The address to transfer ownership to.\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: contracts/lib/token/FactoryTokenInterface.sol\r\n\r\ncontract FactoryTokenInterface is Ownable {\r\n    function balanceOf(address _owner) public view returns (uint256);\r\n    function transfer(address _to, uint256 _value) public returns (bool);\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);\r\n    function approve(address _spender, uint256 _value) public returns (bool);\r\n    function allowance(address _owner, address _spender) public view returns (uint256);\r\n    function mint(address _to, uint256 _amount) public returns (bool);\r\n    function burnFrom(address _from, uint256 _value) public;\r\n}\r\n\r\n// File: contracts/lib/token/TokenFactoryInterface.sol\r\n\r\ncontract TokenFactoryInterface {\r\n    function create(string _name, string _symbol) public returns (FactoryTokenInterface);\r\n}\r\n\r\n// File: contracts/lib/ownership/ZapCoordinatorInterface.sol\r\n\r\ncontract ZapCoordinatorInterface is Ownable {\r\n    function addImmutableContract(string contractName, address newAddress) external;\r\n    function updateContract(string contractName, address newAddress) external;\r\n    function getContractName(uint index) public view returns (string);\r\n    function getContract(string contractName) public view returns (address);\r\n    function updateAllDependencies() external;\r\n}\r\n\r\n// File: contracts/platform/bondage/BondageInterface.sol\r\n\r\ncontract BondageInterface {\r\n    function bond(address, bytes32, uint256) external returns(uint256);\r\n    function unbond(address, bytes32, uint256) external returns (uint256);\r\n    function delegateBond(address, address, bytes32, uint256) external returns(uint256);\r\n    function escrowDots(address, address, bytes32, uint256) external returns (bool);\r\n    function releaseDots(address, address, bytes32, uint256) external returns (bool);\r\n    function returnDots(address, address, bytes32, uint256) external returns (bool success);\r\n    function calcZapForDots(address, bytes32, uint256) external view returns (uint256);\r\n    function currentCostOfDot(address, bytes32, uint256) public view returns (uint256);\r\n    function getDotsIssued(address, bytes32) public view returns (uint256);\r\n    function getBoundDots(address, address, bytes32) public view returns (uint256);\r\n    function getZapBound(address, bytes32) public view returns (uint256);\r\n    function dotLimit( address, bytes32) public view returns (uint256);\r\n}\r\n\r\n// File: contracts/platform/bondage/currentCost/CurrentCostInterface.sol\r\n\r\ncontract CurrentCostInterface {\r\n    function _currentCostOfDot(address, bytes32, uint256) public view returns (uint256);\r\n    function _dotLimit(address, bytes32) public view returns (uint256);\r\n    function _costOfNDots(address, bytes32, uint256, uint256) public view returns (uint256);\r\n}\r\n\r\n// File: contracts/platform/registry/RegistryInterface.sol\r\n\r\ncontract RegistryInterface {\r\n    function initiateProvider(uint256, bytes32) public returns (bool);\r\n    function initiateProviderCurve(bytes32, int256[], address) public returns (bool);\r\n    function setEndpointParams(bytes32, bytes32[]) public;\r\n    function getEndpointParams(address, bytes32) public view returns (bytes32[]);\r\n    function getProviderPublicKey(address) public view returns (uint256);\r\n    function getProviderTitle(address) public view returns (bytes32);\r\n    function setProviderParameter(bytes32, bytes) public;\r\n    function setProviderTitle(bytes32) public;\r\n    function clearEndpoint(bytes32) public;\r\n    function getProviderParameter(address, bytes32) public view returns (bytes);\r\n    function getAllProviderParams(address) public view returns (bytes32[]);\r\n    function getProviderCurveLength(address, bytes32) public view returns (uint256);\r\n    function getProviderCurve(address, bytes32) public view returns (int[]);\r\n    function isProviderInitiated(address) public view returns (bool);\r\n    function getAllOracles() external view returns (address[]);\r\n    function getProviderEndpoints(address) public view returns (bytes32[]);\r\n    function getEndpointBroker(address, bytes32) public view returns (address);\r\n}\r\n\r\n// File: contracts/lib/platform/FundingContest.sol\r\n\r\n/*\r\nFundsaising where users can bond to contestant curves which mint tokens( unbondabe*),\r\nwinner decided by oracle\r\ncontract unbonds from loser curves\r\nwinner takes all of fund\r\n\r\nStarting Fundsaising Contest:\r\n\r\n    deploys with contest uninitialized: status = Uninitialized\r\n\r\n    anyone can initialize new token:backed curve\r\n\r\n    owner initializes contest with oracle: status = Initialized\r\n\r\nExpired :\r\n    When Oracle fails to respond in time\r\n    contract will unbond from all Endpoints\r\n    All users will be able to unbond to receive what they have paid\r\n\r\nResolve Funding Contest:\r\n\r\n    owner calls query to data provider oracle.\r\n\r\n    Data provider oracle respond with data, trigger judge function to set winning curve\r\n\r\n    anyone calls settle, contest unbonds from all curves, winner endpoint owner receive all funds\r\n\r\n    *holders of winning token can optionally unbond\r\n*/\r\n\r\ncontract FundingContest is Ownable {\r\n\r\n    CurrentCostInterface currentCost;\r\n    FactoryTokenInterface public reserveToken;\r\n    ZapCoordinatorInterface public coord;\r\n    TokenFactoryInterface public tokenFactory;\r\n    BondageInterface bondage;\r\n\r\n    enum ContestStatus {\r\n        Uninitialized,      //\r\n        Initialized,       // ready for buys\r\n        Expired,          // Oracle did not respond in time -\u003E ready to refund\r\n        Judged,          // winner determined\r\n        Settled         // value of winning tokens determined\r\n    }\r\n\r\n    address public oracle;    // address of oracle who will choose the winner\r\n    uint256 public ttl;    // time allowed before, close and judge. if time expired, allow unbond from all curves\r\n    bytes32 public winner;    // curve identifier of the winner\r\n    uint256 public winValue;  // final value of the winning token\r\n    ContestStatus public status; //state of contest\r\n\r\n    mapping(bytes32 =\u003E address) public curves; // map of endpoint specifier to token-backed dotaddress\r\n    bytes32[] public curves_list; // array of endpoint specifiers\r\n    mapping(bytes32 =\u003E address) public beneficiaries; // beneficiaries of endpoint that participate in funding contest\r\n    mapping(bytes32 =\u003E address) public curve_creators; \r\n\r\n    mapping(address =\u003E uint256) public redeemed; // map of address redemption amount in case of expired\r\n    address[] public redeemed_list;\r\n\r\n    event DotTokenCreated(address tokenAddress);\r\n    event Bonded(bytes32 indexed endpoint, uint256 indexed numDots, address indexed sender);\r\n    event Unbonded(bytes32 indexed endpoint,uint256 indexed amount, address indexed sender);\r\n\r\n    event Initialized(address indexed oracle);\r\n    event Closed();\r\n    event Judged(bytes32 winner);\r\n    event Settled(address indexed winnerAddress, bytes32 indexed winnerEndpoint);\r\n    event Expired(bytes32 indexed endpoint, uint256 indexed totalDots);\r\n    event Reset();\r\n\r\n    constructor(\r\n        address coordinator,\r\n        address factory,\r\n        uint256 providerPubKey,\r\n        bytes32 providerTitle\r\n    ){\r\n        coord = ZapCoordinatorInterface(coordinator);\r\n        reserveToken = FactoryTokenInterface(coord.getContract(\u0022ZAP_TOKEN\u0022));\r\n        bondage = BondageInterface(coord.getContract(\u0022BONDAGE\u0022));\r\n        currentCost = CurrentCostInterface(coord.getContract(\u0022CURRENT_COST\u0022)); //always allow bondage to transfer from wallet\r\n        reserveToken.approve(bondage, ~uint256(0));\r\n        tokenFactory = TokenFactoryInterface(factory);\r\n\r\n        RegistryInterface registry = RegistryInterface(coord.getContract(\u0022REGISTRY\u0022));\r\n        registry.initiateProvider(providerPubKey, providerTitle);\r\n        status = ContestStatus.Uninitialized;\r\n    }\r\n\r\n// contest lifecycle\r\n\r\n    function initializeContest(\r\n        address oracleAddress,\r\n        uint256 _ttl\r\n    ) onlyOwner public {\r\n        require( status == ContestStatus.Uninitialized, \u0022Contest already initialized\u0022);\r\n        oracle = oracleAddress;\r\n        ttl = _ttl \u002B block.number;\r\n        status = ContestStatus.Initialized;\r\n        emit Initialized(oracle);\r\n    }\r\n\r\n  /// TokenDotFactory methods\r\n\r\n    function initializeCurve(\r\n        bytes32 endpoint,\r\n        bytes32 symbol,\r\n        int256[] curve\r\n    ) public returns(address) {\r\n        // require(status==ContestStatus.Initialized,\u0022Contest is not initalized\u0022)\r\n        require(curves[endpoint] == 0, \u0022Curve endpoint already exists or used in the past. Please choose a new endpoint\u0022);\r\n\r\n        RegistryInterface registry = RegistryInterface(coord.getContract(\u0022REGISTRY\u0022));\r\n        registry.initiateProviderCurve(endpoint, curve, address(this));\r\n\r\n        curves[endpoint] = newToken(bytes32ToString(endpoint), bytes32ToString(symbol));\r\n        curves_list.push(endpoint);\r\n        registry.setProviderParameter(endpoint, toBytes(curves[endpoint]));\r\n        emit DotTokenCreated(curves[endpoint]);\r\n\t\t\t\tcurve_creators[endpoint] = msg.sender;\r\n\t\t\t\treturn curves[endpoint];\r\n    }\r\n\r\n    //whether this contract holds tokens or coming from msg.sender,etc\r\n    function bond(bytes32 endpoint, uint numDots) public  {\r\n        require( status == ContestStatus.Initialized, \u0022 contest is not initiated\u0022);\r\n\r\n        uint256 issued = bondage.getDotsIssued(address(this), endpoint);\r\n        uint256 numReserve = currentCost._costOfNDots(address(this), endpoint, issued \u002B 1, numDots - 1);\r\n\r\n        require(\r\n            reserveToken.transferFrom(msg.sender, address(this), numReserve),\r\n            \u0022insufficient accepted token numDots approved for transfer\u0022\r\n        );\r\n        redeemed[msg.sender]=numReserve;\r\n\r\n        reserveToken.approve(address(bondage), numReserve);\r\n        bondage.bond(address(this), endpoint, numDots);\r\n        FactoryTokenInterface(curves[endpoint]).mint(msg.sender, numDots);\r\n        emit Bonded(endpoint, numDots, msg.sender);\r\n    }\r\n\r\n    function judge(bytes32 endpoint) external {\r\n\r\n        require(status!=ContestStatus.Expired, \u0022Contest is already in Expired state, ready to unbond\u0022);\r\n\r\n        if(block.number \u003E ttl ){ //expired\r\n          status=ContestStatus.Expired;\r\n        }\r\n        else{\r\n          require( status == ContestStatus.Initialized, \u0022Contest not initialized\u0022 );\r\n          require( msg.sender == oracle, \u0022Only designated Oracle can judge\u0022);\r\n          require(beneficiaries[endpoint]!=0,\u0022Endpoint invalid\u0022);\r\n          winner = endpoint;\r\n          status = ContestStatus.Judged;\r\n          emit Judged(winner);\r\n        }\r\n    }\r\n\r\n    /**\r\n    If expired -\u003E allow unbond for all\r\n    Else -\u003E allow unbond for winner\r\n    */\r\n    function settle() public {\r\n        if(status == ContestStatus.Expired || block.number \u003E ttl){//expired\r\n          emit Expired(winner,1);\r\n          for(uint256 i = 0; i\u003Ccurves_list.length; i\u002B\u002B){\r\n            uint256 numDots = bondage.getDotsIssued(address(this), curves_list[i]);\r\n            if(numDots\u003E0){ //unbond from this address for all\r\n              bondage.unbond(address(this), curves_list[i], numDots);\r\n            }\r\n            emit Expired(curves_list[i],numDots);\r\n          }\r\n          status=ContestStatus.Expired;\r\n        }\r\n        else{\r\n          require( status == ContestStatus.Judged, \u0022winner not determined\u0022);\r\n          uint256 dots;\r\n          uint256 tokenDotBalance;\r\n\r\n          uint256 numWin = bondage.getDotsIssued(address(this), winner);\r\n          require(numWin\u003E0,\u0022No dots to settle\u0022);\r\n\r\n          for( uint256 j = 0; j \u003C curves_list.length; j\u002B\u002B) {\r\n            if(curves_list[j]!=winner){\r\n\r\n              dots =  bondage.getDotsIssued(address(this), curves_list[j]);\r\n              if( dots \u003E 0) {\r\n                  bondage.unbond(address(this), curves_list[j], dots);\r\n              }\r\n            }\r\n          }\r\n          winValue = reserveToken.balanceOf(address(this))/ numWin;\r\n\r\n          status = ContestStatus.Settled;\r\n          emit Settled(beneficiaries[winner], winner);\r\n\r\n        }\r\n    }\r\n\r\n    //TODO ensure all has been redeemed or enough time has elasped\r\n    function reset() public {\r\n        require(msg.sender == oracle);\r\n        //todo balance is 0\r\n        require(status == ContestStatus.Settled || status == ContestStatus.Expired, \u0022contest not settled\u0022);\r\n        if( status == ContestStatus.Expired ) {\r\n            require(reserveToken.balanceOf(address(this)) == 0, \u0022funds remain\u0022);\r\n        }\r\n\r\n        delete redeemed_list;\r\n        delete curves_list;\r\n        status = ContestStatus.Initialized;\r\n        emit Reset();\r\n    }\r\n\r\n    // If the contract is expired, users can call unbond to get refund back\r\n    function unbond(bytes32 endpoint) public returns(uint256) {\r\n\r\n        uint256 issued = bondage.getDotsIssued(address(this), endpoint);\r\n        uint256 reserveCost;\r\n        uint256 tokensBalance;\r\n        FactoryTokenInterface curveToken = FactoryTokenInterface(getTokenAddress(endpoint));\r\n\r\n        if( status == ContestStatus.Initialized || status == ContestStatus.Expired) {\r\n            //oracle has taken too long to judge winner so unbonds will be allowed for all\r\n            require(block.number \u003E ttl, \u0022oracle query not expired.\u0022);\r\n            // require(status == ContestStatus.Settled, \u0022contest not settled\u0022);\r\n            status = ContestStatus.Expired;\r\n\r\n            //burn dot backed token\r\n            tokensBalance = curveToken.balanceOf(msg.sender);\r\n            require(tokensBalance\u003E0, \u0022Unsufficient balance to redeem\u0022);\r\n            // transfer back to user what they paid\r\n            reserveCost = redeemed[msg.sender];\r\n            require(reserveCost\u003E0,\u0022No funding found\u0022);\r\n\r\n            curveToken.burnFrom(msg.sender, tokensBalance);\r\n            require(reserveToken.transfer(msg.sender, reserveCost), \u0022transfer failed\u0022);\r\n\r\n            emit Unbonded(endpoint, reserveCost, msg.sender);\r\n            return reserveCost;\r\n        }\r\n        else {\r\n            require( status == ContestStatus.Settled, \u0022 contest not settled\u0022);\r\n            require(winner==endpoint, \u0022only winners can unbond for rewards\u0022);\r\n\r\n            tokensBalance = curveToken.balanceOf(msg.sender);\r\n            require(tokensBalance\u003E0, \u0022Unsufficient balance to redeem\u0022);\r\n            //get reserve value to send\r\n            reserveCost = currentCost._costOfNDots(address(this), winner, issued \u002B 1 - tokensBalance, tokensBalance - 1);\r\n\r\n            //reward user\u0027s winning tokens unbond value \u002B share of losing curves reserve token proportional to winning token holdings\r\n\r\n            uint256 reward = ( winValue * tokensBalance )/2; //50% of winning goes to winner beneficiary\r\n            uint256 funderReward = reward \u002B reserveCost;\r\n\r\n            //burn user\u0027s unbonded tokens\r\n            bondage.unbond(address(this), winner,tokensBalance);\r\n            // curveToken.approve(address(this),tokensBalance);\r\n            curveToken.burnFrom(msg.sender, tokensBalance);\r\n            //\r\n            require(reserveToken.transfer(msg.sender, funderReward),\u0022Failed to send to funder\u0022);\r\n            require(reserveToken.transfer(beneficiaries[winner],reward),\u0022Failed to send to beneficiary\u0022);\r\n            return reward;\r\n        }\r\n    }\r\n\r\n    function newToken(\r\n        string name,\r\n        string symbol\r\n    )\r\n        internal\r\n        returns (address tokenAddress)\r\n    {\r\n        FactoryTokenInterface token = tokenFactory.create(name, symbol);\r\n        tokenAddress = address(token);\r\n        return tokenAddress;\r\n    }\r\n\r\n    function getTokenAddress(bytes32 endpoint) public view returns(address) {\r\n        RegistryInterface registry = RegistryInterface(coord.getContract(\u0022REGISTRY\u0022));\r\n        return bytesToAddr(registry.getProviderParameter(address(this), endpoint));\r\n    }\r\n\r\n    function getEndpoints() public view returns(bytes32[]){\r\n      return curves_list;\r\n    }\r\n\r\n    function getStatus() public view returns(uint256){\r\n      return uint(status);\r\n    }\r\n\r\n    function isEndpointValid(bytes32 _endpoint) public view returns(bool){\r\n      for(uint256 i=0; i\u003Ccurves_list.length;i\u002B\u002B){\r\n        if(_endpoint == curves_list[i]){\r\n          return true;\r\n        }\r\n      }\r\n      return false;\r\n    }\r\n\r\n    function setBeneficiary(bytes32 endpoint, address b) { \r\n       require(beneficiaries[endpoint] == 0, \u0022Beneficiary already set for this curve\u0022);\r\n       require(curve_creators[endpoint] == msg.sender, \u0022Only curve creator can set beneficiary address\u0022);\r\n       beneficiaries[endpoint] = b;\r\n    }\r\n\r\n\r\n    // https://ethereum.stackexchange.com/questions/884/how-to-convert-an-address-to-bytes-in-solidity\r\n    function toBytes(address x) public pure returns (bytes b) {\r\n        b = new bytes(20);\r\n        for (uint i = 0; i \u003C 20; i\u002B\u002B)\r\n            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));\r\n    }\r\n\r\n    //https://ethereum.stackexchange.com/questions/2519/how-to-convert-a-bytes32-to-string\r\n    function bytes32ToString(bytes32 x) public pure returns (string) {\r\n        bytes memory bytesString = new bytes(32);\r\n        bytesString = abi.encodePacked(x);\r\n        return string(bytesString);\r\n    }\r\n\r\n    //https://ethereum.stackexchange.com/questions/15350/how-to-convert-an-bytes-to-address-in-solidity\r\n    function bytesToAddr (bytes b) public pure returns (address) {\r\n        uint result = 0;\r\n        for (uint i = b.length-1; i\u002B1 \u003E 0; i--) {\r\n            uint c = uint(b[i]);\r\n            uint to_inc = c * ( 16 ** ((b.length - i-1) * 2));\r\n            result \u002B= to_inc;\r\n        }\r\n        return address(result);\r\n    }\r\n}\r\n\r\n// File: contracts/platform/dispatch/DispatchInterface.sol\r\n\r\ninterface DispatchInterface {\r\n    function query(address, string, bytes32, bytes32[]) external returns (uint256);\r\n    function respond1(uint256, string) external returns (bool);\r\n    function respond2(uint256, string, string) external returns (bool);\r\n    function respond3(uint256, string, string, string) external returns (bool);\r\n    function respond4(uint256, string, string, string, string) external returns (bool);\r\n    function respondBytes32Array(uint256, bytes32[]) external returns (bool);\r\n    function respondIntArray(uint256,int[] ) external returns (bool);\r\n    function cancelQuery(uint256) external;\r\n    function getProvider(uint256 id) public view returns (address);\r\n    function getSubscriber(uint256 id) public view returns (address);\r\n    function getEndpoint(uint256 id) public view returns (bytes32);\r\n    function getStatus(uint256 id) public view returns (uint256);\r\n    function getCancel(uint256 id) public view returns (uint256);\r\n    function getUserQuery(uint256 id) public view returns (string);\r\n    function getSubscriberOnchain(uint256 id) public view returns (bool);\r\n}\r\n\r\n// File: contracts/lib/platform/Client.sol\r\n\r\ncontract Client1 {\r\n    /// @dev callback that provider will call after Dispatch.query() call\r\n    /// @param id request id\r\n    /// @param response1 first provider-specified param\r\n    function callback(uint256 id, string response1) external;\r\n}\r\ncontract Client2 {\r\n    /// @dev callback that provider will call after Dispatch.query() call\r\n    /// @param id request id\r\n    /// @param response1 first provider-specified param\r\n    /// @param response2 second provider-specified param\r\n    function callback(uint256 id, string response1, string response2) external;\r\n}\r\ncontract Client3 {\r\n    /// @dev callback that provider will call after Dispatch.query() call\r\n    /// @param id request id\r\n    /// @param response1 first provider-specified param\r\n    /// @param response2 second provider-specified param\r\n    /// @param response3 third provider-specified param\r\n    function callback(uint256 id, string response1, string response2, string response3) external;\r\n}\r\ncontract Client4 {\r\n    /// @dev callback that provider will call after Dispatch.query() call\r\n    /// @param id request id\r\n    /// @param response1 first provider-specified param\r\n    /// @param response2 second provider-specified param\r\n    /// @param response3 third provider-specified param\r\n    /// @param response4 fourth provider-specified param\r\n    function callback(uint256 id, string response1, string response2, string response3, string response4) external;\r\n}\r\n\r\ncontract ClientBytes32Array {\r\n    /// @dev callback that provider will call after Dispatch.query() call\r\n    /// @param id request id\r\n    /// @param response bytes32 array\r\n    function callback(uint256 id, bytes32[] response) external;\r\n}\r\n\r\ncontract ClientIntArray{\r\n    /// @dev callback that provider will call after Dispatch.query() call\r\n    /// @param id request id\r\n    /// @param response int array\r\n    function callback(uint256 id, int[] response) external;\r\n}\r\n\r\n// File: contracts/lib/platform/GitFundContest.sol\r\n\r\ncontract GitFundContest is Ownable, ClientBytes32Array {\r\n  FundingContest public contest;\r\n  ZapCoordinatorInterface public coordinator;\r\n  BondageInterface bondage;\r\n  DispatchInterface dispatch;\r\n  address public owner;\r\n  uint256 public query_id;\r\n  uint256 public startPrice;\r\n  bytes32[] public endpoints;\r\n  uint256 queryId;\r\n\tuint256 start_time;\r\n\r\n  constructor(\r\n    address _cord,\r\n    address _contest\r\n  ){\r\n    owner = msg.sender;\r\n    contest = FundingContest(_contest);\r\n    coordinator = ZapCoordinatorInterface(_cord);\r\n    address bondageAddress = coordinator.getContract(\u0022BONDAGE\u0022);\r\n    bondage = BondageInterface(bondageAddress);\r\n    address dispatchAddress = coordinator.getContract(\u0022DISPATCH\u0022);\r\n    dispatch = DispatchInterface(dispatchAddress);\r\n    FactoryTokenInterface reserveToken = FactoryTokenInterface(coordinator.getContract(\u0022ZAP_TOKEN\u0022));\r\n    reserveToken.approve(address(bondageAddress),~uint256(0));\r\n\t\tstart_time = now;\r\n  }\r\n\r\n  function bondToGitOracle(address _gitOracle,bytes32 _endpoint,uint256 _numDots)public returns (bool){\r\n    bondage.bond(_gitOracle,_endpoint,_numDots);\r\n    return true;\r\n\r\n  }\r\n  function queryToSettle(address _gitOracle,bytes32 _endpoint) public returns(uint256){\r\n    require(msg.sender == owner, \u0022Only owner can call query to settle\u0022);\r\n\t\tbytes32[] memory params = new bytes32[]( contest.getEndpoints().length \u002B 1);\r\n\t\tparams[0] = bytes32(now); // for the timestamp\r\n\t\tbytes32[] memory tmp_params = contest.getEndpoints();\r\n\t\tfor ( uint i = 1; i \u003C tmp_params.length; i\u002B\u002B) {\r\n\t\t\t\tparams[i] = tmp_params[i-1];\r\n\t\t}\r\n\r\n\t\tqueryId = dispatch.query(_gitOracle,\u0022GitCommits\u0022,_endpoint,params);\r\n    return queryId;\r\n  }\r\n\r\n  function callback(uint256 _id, bytes32[] _endpoints) external {\r\n    address dispatchAddress = coordinator.getContract(\u0022DISPATCH\u0022);\r\n    require(address(msg.sender)==address(dispatchAddress),\u0022Only accept response from dispatch\u0022);\r\n    require(_id == queryId, \u0022wrong query ID\u0022);\r\n    require(contest.getStatus()==1,\u0022Contest is not in initialized state\u0022); //2 is the ReadyToSettle enum value\r\n    return contest.judge(_endpoints[0]);\r\n\r\n  }\r\n\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022coordinator\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_gitOracle\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_endpoint\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_numDots\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022bondToGitOracle\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022endpoints\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_endpoints\u0022,\u0022type\u0022:\u0022bytes32[]\u0022}],\u0022name\u0022:\u0022callback\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_gitOracle\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_endpoint\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022queryToSettle\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022contest\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022query_id\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022startPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_cord\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_contest\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"GitFundContest","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000b007eca49763f31edff95623ed6c23c8c1924a16000000000000000000000000fc9b720e586e8d1e4c022ec940a32e23807478fb","Library":"","SwarmSource":"bzzr://7f96ed85ba9d89477fa3060b2e9507e1061dba119d58314bd121e83f47b0f83a"}]