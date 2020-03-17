[{"SourceCode":"pragma solidity 0.5.11;\r\ncontract ERC20 {\r\n  uint256 public totalSupply;\r\n  function balanceOf(address who) public view returns (uint256 _user);\r\n  function transfer(address to, uint256 value) public returns (bool success);\r\n  function allowance(address owner, address spender) public view returns (uint256 value);\r\n  function transferFrom(address from, address to, uint256 value) public returns (bool success);\r\n  function approve(address spender, uint256 value) public returns (bool success);\r\n\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\nlibrary SafeMath {\r\n  \r\n  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function safeAdd(uint256 a, uint256 b) internal pure  returns (uint256) {\r\n    uint c = a \u002B b;\r\n    assert(c\u003E=a);\r\n    return c;\r\n  }\r\n  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n}\r\n\r\ncontract OnlyOwner {\r\n  address public owner;\r\n  address private controller;\r\n  //log the previous and new controller when event  is fired.\r\n  event SetNewController(address prev_controller, address new_controller);\r\n  /** \r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor() public {\r\n    owner = msg.sender;\r\n    controller = owner;\r\n  }\r\n\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner. \r\n   */\r\n  modifier isOwner {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n  \r\n  /**\r\n   * @dev Throws if called by any account other than the controller. \r\n   */\r\n  modifier isController {\r\n    require(msg.sender == controller);\r\n    _;\r\n  }\r\n  \r\n  function replaceController(address new_controller) isController public returns(bool){\r\n    require(new_controller != address(0x0));\r\n\tcontroller = new_controller;\r\n    emit SetNewController(msg.sender,controller);\r\n    return true;   \r\n  }\r\n\r\n}\r\n\r\ncontract StandardToken is ERC20{\r\n  using SafeMath for uint256;\r\n\r\n    mapping(address =\u003E uint256) balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) allowed;\r\n\r\n  \r\n    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success){\r\n      //prevent sending of tokens from genesis address or to self\r\n      require(_from != address(0) \u0026\u0026 _from != _to);\r\n      require(_to != address(0));\r\n      //subtract tokens from the sender on transfer\r\n      balances[_from] = balances[_from].safeSub(_value);\r\n      //add tokens to the receiver on reception\r\n      balances[_to] = balances[_to].safeAdd(_value);\r\n      return true;\r\n    }\r\n\r\n  function transfer(address _to, uint256 _value) public returns (bool success) \r\n  { \r\n    require(_value \u003C= balances[msg.sender]);\r\n      _transfer(msg.sender,_to,_value);\r\n      emit Transfer(msg.sender, _to, _value);\r\n      return true;\r\n  }\r\n\r\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\r\n      uint256 _allowance = allowed[_from][msg.sender];\r\n      //value must be less than allowed value\r\n      require(_value \u003C= _allowance);\r\n      //balance of sender \u002B token value transferred by sender must be greater than balance of sender\r\n      require(balances[_to] \u002B _value \u003E balances[_to]);\r\n      //call transfer function\r\n      _transfer(_from,_to,_value);\r\n      //subtract the amount allowed to the sender \r\n      allowed[_from][msg.sender] = _allowance.safeSub(_value);\r\n      //trigger Transfer event\r\n      emit Transfer(_from, _to, _value);\r\n      return true;\r\n    }\r\n\r\n    function balanceOf(address _owner) public view returns (uint balance) {\r\n      return balances[_owner];\r\n    }\r\n\r\n    \r\n\r\n  /**\r\n   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n   *\r\n   * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n   * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\r\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _value The amount of tokens to be spent.\r\n   */\r\n\r\n  function approve(address _spender, uint256 _value) public returns (bool) {\r\n    // To change the approve amount you first have to reduce the addresses\u0060\r\n    //  allowance to zero by calling \u0060approve(_spender,0)\u0060 if it is not\r\n    //  already 0 to mitigate the race condition described here:\r\n    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n    require((_value == 0) || (allowed[msg.sender][_spender] == 0));\r\n    allowed[msg.sender][_spender] = _value;\r\n    emit Approval(msg.sender, _spender, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n   * @param _owner address The address which owns the funds.\r\n   * @param _spender address The address which will spend the funds.\r\n   * @return A uint256 specifying the amount of tokens still available for the spender.\r\n   */\r\n  function allowance(address _owner, address _spender) public view returns (uint256) {\r\n    return allowed[_owner][_spender];\r\n  }\r\n\r\n}\r\n\r\ncontract TET is StandardToken, OnlyOwner{\r\n\tuint256 public constant decimals = 18;\r\n    string public constant name = \u0022The Eco Tour\u0022;\r\n    string public constant symbol = \u0022TET\u0022;\r\n    string public constant version = \u00221.0\u0022;\r\n    uint256 public constant totalSupply = 18000000000*10**18;\r\n    uint256 private approvalCounts =0;\r\n    uint256 private minRequiredApprovals =2;\r\n    address public burnedTokensReceiver;\r\n    \r\n    constructor() public{\r\n        balances[msg.sender] = totalSupply;\r\n        burnedTokensReceiver = address(0x0);\r\n    }\r\n\r\n    /**\r\n   * @dev Function to set approval count variable value.\r\n   * @param _value uint The value by which approvalCounts variable will be set.\r\n   */\r\n    function setApprovalCounts(uint _value) public isController {\r\n        approvalCounts = _value;\r\n    }\r\n    \r\n    /**\r\n   * @dev Function to set minimum require approval variable value.\r\n   * @param _value uint The value by which minRequiredApprovals variable will be set.\r\n   * @return true.\r\n   */\r\n    function setMinApprovalCounts(uint _value) public isController returns (bool){\r\n        require(_value \u003E 0);\r\n        minRequiredApprovals = _value;\r\n        return true;\r\n    }\r\n    \r\n    /**\r\n   * @dev Function to get approvalCounts variable value.\r\n   * @return approvalCounts.\r\n   */\r\n    function getApprovalCount() public view isController returns(uint){\r\n        return approvalCounts;\r\n    }\r\n    \r\n     /**\r\n   * @dev Function to get burned Tokens Receiver address.\r\n   * @return burnedTokensReceiver.\r\n   */\r\n    function getBurnedTokensReceiver() public view isController returns(address){\r\n        return burnedTokensReceiver;\r\n    }\r\n    \r\n    \r\n    function controllerApproval(address _from, uint256 _value) public isOwner returns (bool) {\r\n        require(minRequiredApprovals \u003C= approvalCounts);\r\n\t\trequire(_value \u003C= balances[_from]);\t\t\r\n        balances[_from] = balances[_from].safeSub(_value);\r\n        balances[burnedTokensReceiver] = balances[burnedTokensReceiver].safeAdd(_value);\r\n        emit Transfer(_from,burnedTokensReceiver, _value);\r\n        return true;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getApprovalCount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setApprovalCounts\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022version\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022burnedTokensReceiver\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getBurnedTokensReceiver\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022new_controller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022replaceController\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setMinApprovalCounts\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022controllerApproval\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022prev_controller\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022new_controller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022SetNewController\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TET","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://b9fe768d63eef15256d041d5751596778fc68cccae4233380ac26eedc947a844"}]