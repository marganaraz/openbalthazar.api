[{"SourceCode":"{\u0022ISettings.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.4.25;\\n\\n\\n/// @title ISettings\\n/// @dev Interface for getting the data from settings contract.\\ninterface ISettings {\\n    function oracleAddress() external view returns(address);\\n    function minDeposit() external view returns(uint256);\\n    function sysFee() external view returns(uint256);\\n    function userFee() external view returns(uint256);\\n    function ratio() external view returns(uint256);\\n    function globalTargetCollateralization() external view returns(uint256);\\n    function tmvAddress() external view returns(uint256);\\n    function maxStability() external view returns(uint256);\\n    function minStability() external view returns(uint256);\\n    function gasPriceLimit() external view returns(uint256);\\n    function isFeeManager(address account) external view returns (bool);\\n    function tBoxManager() external view returns(address);\\n}\\n\u0022},\u0022ITBoxManager.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.4.25;\\n\\n\\n/// @title ILogic\\n/// @dev Interface for interaction with the TMV logic contract to manage Boxes.\\ninterface ITBoxManager {\\n    function create(uint256 withdraw) external payable returns (uint256);\\n    function precision() external view returns (uint256);\\n    function rate() external view returns (uint256);\\n    function transferFrom(address from, address to, uint256 tokenId) external;\\n    function close(uint256 id) external;\\n    function withdrawPercent(uint256 _collateral) external view returns(uint256);\\n    function boxes(uint256 id) external view returns(uint256, uint256);\\n    function withdrawEth(uint256 _id, uint256 _amount) external;\\n    function withdrawTmv(uint256 _id, uint256 _amount) external;\\n    function withdrawableEth(uint256 id) external view returns(uint256);\\n    function withdrawableTmv(uint256 collateral) external view returns(uint256);\\n    function maxCapAmount(uint256 _id) external view returns (uint256);\\n    function collateralPercent(uint256 _id) external view returns (uint256);\\n    function capitalize(uint256 _id, uint256 _tmv) external;\\n    function boxWithdrawableTmv(uint256 _id) external view returns(uint256);\\n    function addEth(uint256 _id) external payable;\\n    function capitalizeMax(uint256 _id) external payable;\\n    function withdrawTmvMax(uint256 _id) external payable;\\n    function addTmv(uint256 _id, uint256 _amount) external payable;\\n}\\n\u0022},\u0022IToken.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.4.25;\\n\\n\\n/// @title IToken\\n/// @dev Interface for interaction with the TMV token contract.\\ninterface IToken {\\n    function burnLogic(address from, uint256 value) external;\\n    function approve(address spender, uint256 value) external;\\n    function balanceOf(address who) external view returns (uint256);\\n    function mint(address to, uint256 value) external returns (bool);\\n    function totalSupply() external view returns (uint256);\\n    function allowance(address owner, address spender) external view returns (uint256);\\n    function transfer(address to, uint256 value) external returns (bool);\\n    function transferFrom(address from, address to, uint256 tokenId) external;\\n}\\n\\n\u0022},\u0022LeverageService.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.4.25;\\n\\nimport \\\u0022./SafeMath.sol\\\u0022;\\nimport \\\u0022./ISettings.sol\\\u0022;\\nimport \\\u0022./IToken.sol\\\u0022;\\nimport \\\u0022./ITBoxManager.sol\\\u0022;\\n\\n/// @title LeverageService\\ncontract LeverageService {\\n    using SafeMath for uint256;\\n\\n    /// @notice The address of the admin account.\\n    address public admin;\\n\\n    // The amount of Ether received from the commissions of the system.\\n    uint256 public systemETH;\\n\\n    // Commission percentage of leverage\\n    uint256 public feeLeverage;\\n\\n    // Commission percentage of exchange\\n    uint256 public feeExchange;\\n\\n    // The percentage divider\\n    uint256 public divider = 100000;\\n\\n    // The minimum deposit amount\\n    uint256 public minEther;\\n\\n    ISettings public settings;\\n\\n    /// @dev An array containing the Order struct for all Orders in existence. The ID\\n    ///  of each Order is actually an index into this array.\\n    Order[] public orders;\\n\\n    /// @dev The main Order struct. Every Order is represented by a copy\\n    ///  of this structure.\\n    struct Order {\\n        address owner;\\n        uint256 pack;\\n        // 0: exchange order\\n        // \\u003e 0: leverage order\\n        uint256 percent;\\n    }\\n\\n    /// @dev The OrderCreated event is fired whenever a new Order comes into existence.\\n    event OrderCreated(uint256 id, address owner, uint256 pack, uint256 percent);\\n\\n    /// @dev The OrderClosed event is fired whenever Order is closed.\\n    event OrderClosed(uint256 id, address who);\\n\\n    /// @dev The OrderMatched event is fired whenever an Order is matched.\\n    event OrderMatched(uint256 id, uint256 tBox, address who, address owner);\\n\\n    event FeeUpdated(uint256 leverage, uint256 exchange);\\n    event MinEtherUpdated(uint256 value);\\n    event Transferred(address indexed from, address indexed to, uint256 indexed id);\\n\\n    /// @dev Defends against front-running attacks.\\n    modifier validTx() {\\n        require(tx.gasprice \\u003c= settings.gasPriceLimit(), \\\u0022Gas price is greater than allowed\\\u0022);\\n        _;\\n    }\\n\\n    /// @dev Access modifier for admin-only functionality.\\n    modifier onlyAdmin() {\\n        require(admin == msg.sender, \\\u0022You have no access\\\u0022);\\n        _;\\n    }\\n\\n    /// @dev Access modifier for Order owner-only functionality.\\n    modifier onlyOwner(uint256 _id) {\\n        require(orders[_id].owner == msg.sender, \\\u0022Order isn\\u0027t your\\\u0022);\\n        _;\\n    }\\n\\n    modifier ensureLeverageOrder(uint256 _id) {\\n        require(orders[_id].owner != address(0), \\\u0022Order doesn\\u0027t exist\\\u0022);\\n        require(orders[_id].percent \\u003e 0, \\\u0022Not a leverage order\\\u0022);\\n        _;\\n    }\\n\\n    modifier ensureExchangeOrder(uint256 _id) {\\n        require(orders[_id].owner != address(0), \\\u0022Order doesn\\u0027t exist\\\u0022);\\n        require(orders[_id].percent == 0, \\\u0022Not an exchange order\\\u0022);\\n        _;\\n    }\\n\\n    /// @notice ISettings address couldn\\u0027t be changed later.\\n    /// @dev The contract constructor sets the original \u0060admin\u0060 of the contract to the sender\\n    //   account and sets the settings contract with provided address.\\n    /// @param _settings The address of the settings contract.\\n    constructor(ISettings _settings) public {\\n        admin = msg.sender;\\n        settings = ISettings(_settings);\\n\\n        feeLeverage = 500; // 0.5%\\n        feeExchange = 500; // 0.5%\\n        emit FeeUpdated(feeLeverage, feeExchange);\\n\\n        minEther = 0.1 ether;\\n        emit MinEtherUpdated(minEther);\\n    }\\n\\n    /// @dev Withdraws system fee.\\n    function withdrawSystemETH(address _beneficiary)\\n    external\\n    onlyAdmin\\n    {\\n        require(_beneficiary != address(0), \\\u0022Zero address, be careful\\\u0022);\\n        require(systemETH \\u003e 0, \\\u0022There is no available ETH\\\u0022);\\n\\n        uint256 _systemETH = systemETH;\\n        systemETH = 0;\\n        _beneficiary.transfer(_systemETH);\\n    }\\n\\n    /// @dev Reclaims ERC20 tokens.\\n    function reclaimERC20(address _token, address _beneficiary)\\n    external\\n    onlyAdmin\\n    {\\n        require(_beneficiary != address(0), \\\u0022Zero address, be careful\\\u0022);\\n\\n        uint256 _amount = IToken(_token).balanceOf(address(this));\\n        require(_amount \\u003e 0, \\\u0022There are no tokens\\\u0022);\\n        IToken(_token).transfer(_beneficiary, _amount);\\n    }\\n\\n    /// @dev Sets commission.\\n    function setCommission(uint256 _leverage, uint256 _exchange) external onlyAdmin {\\n        require(_leverage \\u003c= 10000 \\u0026\\u0026 _exchange \\u003c= 10000, \\\u0022Too much\\\u0022);\\n        feeLeverage = _leverage;\\n        feeExchange = _exchange;\\n        emit FeeUpdated(_leverage, _exchange);\\n    }\\n\\n    /// @dev Sets minimum deposit amount.\\n    function setMinEther(uint256 _value) external onlyAdmin {\\n        require(_value \\u003c= 100 ether, \\\u0022Too much\\\u0022);\\n        minEther = _value;\\n        emit MinEtherUpdated(_value);\\n    }\\n\\n    /// @dev Sets admin address.\\n    function changeAdmin(address _newAdmin) external onlyAdmin {\\n        require(_newAdmin != address(0), \\\u0022Zero address, be careful\\\u0022);\\n        admin = _newAdmin;\\n    }\\n\\n    /// @dev Creates an Order.\\n    function create(uint256 _percent) public payable returns (uint256) {\\n        require(msg.value \\u003e= minEther, \\\u0022Too small funds\\\u0022);\\n        require(_percent == 0\\n            || _percent \\u003e= ITBoxManager(settings.tBoxManager()).withdrawPercent(msg.value),\\n            \\\u0022Collateral percent out of range\\\u0022\\n        );\\n\\n        Order memory _order = Order(msg.sender, msg.value, _percent);\\n        uint256 _id = orders.push(_order).sub(1);\\n        emit OrderCreated(_id, msg.sender, msg.value, _percent);\\n        return _id;\\n    }\\n\\n    /// @dev Closes an Order.\\n    function close(uint256 _id) external onlyOwner(_id) {\\n        uint256 _eth = orders[_id].pack;\\n        delete orders[_id];\\n        msg.sender.transfer(_eth);\\n        emit OrderClosed(_id, msg.sender);\\n    }\\n\\n    /// @dev Uses to match a leverage Order.\\n    function takeLeverageOrder(uint256 _id) external payable ensureLeverageOrder(_id) validTx returns(uint256) {\\n        address _owner = orders[_id].owner;\\n        uint256 _eth = orders[_id].pack.mul(divider).div(orders[_id].percent);\\n\\n        require(msg.value == _eth, \\\u0022Incorrect ETH value\\\u0022);\\n\\n        uint256 _sysEth = _eth.mul(feeLeverage).div(divider);\\n        systemETH = systemETH.add(_sysEth);\\n        uint256 _tmv = _eth.mul(ITBoxManager(settings.tBoxManager()).rate()).div(\\n            ITBoxManager(settings.tBoxManager()).precision()\\n        );\\n        uint256 _box = ITBoxManager(settings.tBoxManager()).create.value(\\n            orders[_id].pack\\n        )(_tmv);\\n        uint256 _sysTmv = _tmv.mul(feeLeverage).div(divider);\\n        delete orders[_id];\\n        _owner.transfer(_eth.sub(_sysEth));\\n        ITBoxManager(settings.tBoxManager()).transferFrom(\\n            address(this),\\n            _owner,\\n            _box\\n        );\\n        IToken(settings.tmvAddress()).transfer(msg.sender, _tmv.sub(_sysTmv));\\n        emit OrderMatched(_id, _box, msg.sender, _owner);\\n        return _box;\\n    }\\n\\n    /// @dev Uses to match an exchange Order.\\n    function takeExchangeOrder(uint256 _id) external payable ensureExchangeOrder(_id) validTx returns(uint256) {\\n        address _owner = orders[_id].owner;\\n        uint256 _eth = orders[_id].pack;\\n        uint256 _sysEth = _eth.mul(feeExchange).div(divider);\\n        systemETH = systemETH.add(_sysEth);\\n        uint256 _tmv = _eth.mul(ITBoxManager(settings.tBoxManager()).rate()).div(ITBoxManager(settings.tBoxManager()).precision());\\n        uint256 _box = ITBoxManager(settings.tBoxManager()).create.value(msg.value)(_tmv);\\n        uint256 _sysTmv = _tmv.mul(feeExchange).div(divider);\\n        delete orders[_id];\\n        msg.sender.transfer(_eth.sub(_sysEth));\\n        ITBoxManager(settings.tBoxManager()).transferFrom(address(this), msg.sender, _box);\\n        IToken(settings.tmvAddress()).transfer(_owner, _tmv.sub(_sysTmv));\\n        emit OrderMatched(_id, _box, msg.sender, _owner);\\n        return _box;\\n    }\\n\\n    /// @dev Transfers ownership of an Order.\\n    function transfer(address _to, uint256 _id) external onlyOwner(_id) {\\n        require(_to != address(0), \\\u0022Zero address, be careful\\\u0022);\\n        orders[_id].owner = _to;\\n        emit Transferred(msg.sender, _to, _id);\\n    }\\n}\\n\u0022},\u0022SafeMath.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.4.25;\\n\\n/**\\n * @title SafeMath\\n * @dev Math operations with safety checks that revert on error\\n */\\nlibrary SafeMath {\\n    /**\\n    * @dev Multiplies two numbers, reverts on overflow.\\n    */\\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\\n        // Gas optimization: this is cheaper than requiring \\u0027a\\u0027 not being zero, but the\\n        // benefit is lost if \\u0027b\\u0027 is also tested.\\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\\n        if (a == 0) {\\n            return 0;\\n        }\\n\\n        uint256 c = a * b;\\n        require(c / a == b, \\u0027mul\\u0027);\\n\\n        return c;\\n    }\\n\\n    /**\\n    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\\n    */\\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\\n        // Solidity only automatically asserts when dividing by 0\\n        require(b \\u003e 0, \\u0027div\\u0027);\\n        uint256 c = a / b;\\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\\u0027t hold\\n\\n        return c;\\n    }\\n\\n    /**\\n    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\\n    */\\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\\n        require(b \\u003c= a, \\u0027sub\\u0027);\\n        uint256 c = a - b;\\n\\n        return c;\\n    }\\n\\n    /**\\n    * @dev Adds two numbers, reverts on overflow.\\n    */\\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\\n        uint256 c = a \u002B b;\\n        require(c \\u003e= a, \\u0027add\\u0027);\\n\\n        return c;\\n    }\\n\\n    /**\\n    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),\\n    * reverts when dividing by zero.\\n    */\\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\\n        require(b != 0);\\n        return a % b;\\n    }\\n}\\n\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022minEther\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022close\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022systemETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022feeExchange\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022divider\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022takeExchangeOrder\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_leverage\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_exchange\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setCommission\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_beneficiary\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022reclaimERC20\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022takeLeverageOrder\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_percent\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022create\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setMinEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newAdmin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_beneficiary\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawSystemETH\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022orders\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022pack\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022percent\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022feeLeverage\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022settings\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022admin\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_settings\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022pack\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022percent\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022OrderCreated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OrderClosed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tBox\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OrderMatched\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022leverage\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022exchange\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022FeeUpdated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022MinEtherUpdated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"LeverageService","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000680d335f7978e85de2a3168bd07c27b6ceaa7908","Library":"","SwarmSource":"bzzr://5e484d7e49abacc77cabd3aeeb28e7e1dc1fd1ba709cad51d388efb71e91d65a"}]