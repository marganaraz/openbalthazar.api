[{"SourceCode":"{\u0022BasicToken.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.18;\\n\\n\\nimport \\\u0022./ERC20Basic.sol\\\u0022;\\nimport \\\u0022./SafeMath.sol\\\u0022;\\n\\n\\n/**\\n * @title Basic token\\n * @dev Basic version of StandardToken, with no allowances.\\n */\\ncontract BasicToken is ERC20Basic {\\n  using SafeMath for uint256;\\n\\n  mapping(address =\\u003e uint256) balances;\\n\\n  uint256 totalSupply_;\\n\\n  /**\\n  * @dev total number of tokens in existence\\n  */\\n  function totalSupply() public view returns (uint256) {\\n    return totalSupply_;\\n  }\\n\\n  /**\\n  * @dev transfer token for a specified address\\n  * @param _to The address to transfer to.\\n  * @param _value The amount to be transferred.\\n  */\\n  function transfer(address _to, uint256 _value) public returns (bool) {\\n    require(_to != address(0));\\n    require(_value \\u003c= balances[msg.sender]);\\n\\n    // SafeMath.sub will throw if there is not enough balance.\\n    balances[msg.sender] = balances[msg.sender].sub(_value);\\n    balances[_to] = balances[_to].add(_value);\\n    Transfer(msg.sender, _to, _value);\\n    return true;\\n  }\\n\\n  /**\\n  * @dev Gets the balance of the specified address.\\n  * @param _owner The address to query the the balance of.\\n  * @return An uint256 representing the amount owned by the passed address.\\n  */\\n  function balanceOf(address _owner) public view returns (uint256 balance) {\\n    return balances[_owner];\\n  }\\n\\n}\\n\u0022},\u0022DetailedERC20.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.18;\\n\\nimport \\\u0022./ERC20.sol\\\u0022;\\n\\n\\ncontract DetailedERC20 is ERC20 {\\n  string public name;\\n  string public symbol;\\n  uint8 public decimals;\\n\\n  function DetailedERC20(string _name, string _symbol, uint8 _decimals) public {\\n    name = _name;\\n    symbol = _symbol;\\n    decimals = _decimals;\\n  }\\n}\\n\u0022},\u0022ERC20.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.18;\\n\\nimport \\\u0022./ERC20Basic.sol\\\u0022;\\n\\n\\n/**\\n * @title ERC20 interface\\n * @dev see https://github.com/ethereum/EIPs/issues/20\\n */\\ncontract ERC20 is ERC20Basic {\\n  function allowance(address owner, address spender) public view returns (uint256);\\n  function transferFrom(address from, address to, uint256 value) public returns (bool);\\n  function approve(address spender, uint256 value) public returns (bool);\\n  event Approval(address indexed owner, address indexed spender, uint256 value);\\n}\\n\u0022},\u0022ERC20Basic.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.18;\\n\\n\\n/**\\n * @title ERC20Basic\\n * @dev Simpler version of ERC20 interface\\n * @dev see https://github.com/ethereum/EIPs/issues/179\\n */\\ncontract ERC20Basic {\\n  function totalSupply() public view returns (uint256);\\n  function balanceOf(address who) public view returns (uint256);\\n  function transfer(address to, uint256 value) public returns (bool);\\n  event Transfer(address indexed from, address indexed to, uint256 value);\\n}\\n\u0022},\u0022Migrations.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.18;\\n\\ncontract Migrations {\\n  address public owner;\\n  uint public last_completed_migration;\\n\\n  modifier restricted() {\\n    if (msg.sender == owner) _;\\n  }\\n\\n  function Migrations() public {\\n    owner = msg.sender;\\n  }\\n\\n  function setCompleted(uint completed) restricted public {\\n    last_completed_migration = completed;\\n  }\\n\\n  function upgrade(address new_address) restricted public {\\n    Migrations upgraded = Migrations(new_address);\\n    upgraded.setCompleted(last_completed_migration);\\n  }\\n}\\n\u0022},\u0022MintableToken.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.18;\\n\\nimport \\\u0022./StandardToken.sol\\\u0022;\\nimport \\\u0022./Ownable.sol\\\u0022;\\n\\n\\n/**\\n * @title Mintable token\\n * @dev Simple ERC20 Token example, with mintable token creation\\n * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120\\n * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol\\n */\\ncontract MintableToken is StandardToken, Ownable {\\n  event Mint(address indexed to, uint256 amount);\\n  event MintFinished();\\n\\n  bool public mintingFinished = false;\\n\\n\\n  modifier canMint() {\\n    require(!mintingFinished);\\n    _;\\n  }\\n\\n  /**\\n   * @dev Function to mint tokens\\n   * @param _to The address that will receive the minted tokens.\\n   * @param _amount The amount of tokens to mint.\\n   * @return A boolean that indicates if the operation was successful.\\n   */\\n  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {\\n    totalSupply_ = totalSupply_.add(_amount);\\n    balances[_to] = balances[_to].add(_amount);\\n    Mint(_to, _amount);\\n    Transfer(address(0), _to, _amount);\\n    return true;\\n  }\\n\\n  /**\\n   * @dev Function to stop minting new tokens.\\n   * @return True if the operation was successful.\\n   */\\n  function finishMinting() onlyOwner canMint public returns (bool) {\\n    mintingFinished = true;\\n    MintFinished();\\n    return true;\\n  }\\n}\\n\u0022},\u0022Ownable.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.18;\\n\\n\\n/**\\n * @title Ownable\\n * @dev The Ownable contract has an owner address, and provides basic authorization control\\n * functions, this simplifies the implementation of \\\u0022user permissions\\\u0022.\\n */\\ncontract Ownable {\\n  address public owner;\\n\\n\\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\\n\\n\\n  /**\\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\\n   * account.\\n   */\\n  function Ownable() public {\\n    owner = msg.sender;\\n  }\\n\\n  /**\\n   * @dev Throws if called by any account other than the owner.\\n   */\\n  modifier onlyOwner() {\\n    require(msg.sender == owner);\\n    _;\\n  }\\n\\n  /**\\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\\n   * @param newOwner The address to transfer ownership to.\\n   */\\n  function transferOwnership(address newOwner) public onlyOwner {\\n    require(newOwner != address(0));\\n    OwnershipTransferred(owner, newOwner);\\n    owner = newOwner;\\n  }\\n\\n}\\n\u0022},\u0022RegulatedToken.sol\u0022:{\u0022content\u0022:\u0022/**\\n   Copyright (c) 2017 Harbor Platform, Inc.\\n\\n   Licensed under the Apache License, Version 2.0 (the \u201CLicense\u201D);\\n   you may not use this file except in compliance with the License.\\n   You may obtain a copy of the License at\\n\\n   http://www.apache.org/licenses/LICENSE-2.0\\n\\n   Unless required by applicable law or agreed to in writing, software\\n   distributed under the License is distributed on an \u201CAS IS\u201D BASIS,\\n   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\\n   See the License for the specific language governing permissions and\\n   limitations under the License.\\n*/\\n\\npragma solidity ^0.4.18;\\n\\nimport \\u0027./DetailedERC20.sol\\u0027;\\nimport \\u0027./MintableToken.sol\\u0027;\\nimport \\u0027./ServiceRegistry.sol\\u0027;\\nimport \\u0027./RegulatorService.sol\\u0027;\\n\\n/// @notice An ERC-20 token that has the ability to check for trade validity\\ncontract RegulatedToken is DetailedERC20, MintableToken {\\n\\n  /**\\n   * @notice R-Token decimals setting (used when constructing DetailedERC20)\\n   */\\n  uint8 constant public RTOKEN_DECIMALS = 18;\\n\\n  /**\\n   * @notice Triggered when regulator checks pass or fail\\n   */\\n  event CheckStatus(uint8 reason, address indexed spender, address indexed from, address indexed to, uint256 value);\\n\\n  /**\\n   * @notice Address of the \u0060ServiceRegistry\u0060 that has the location of the\\n   *         \u0060RegulatorService\u0060 contract responsible for checking trade\\n   *         permissions.\\n   */\\n  ServiceRegistry public registry;\\n\\n  /**\\n   * @notice Constructor\\n   *\\n   * @param _registry Address of \u0060ServiceRegistry\u0060 contract\\n   * @param _name Name of the token: See DetailedERC20\\n   * @param _symbol Symbol of the token: See DetailedERC20\\n   */\\n  function RegulatedToken(ServiceRegistry _registry, string _name, string _symbol) public\\n    DetailedERC20(_name, _symbol, RTOKEN_DECIMALS)\\n  {\\n    require(_registry != address(0));\\n\\n    registry = _registry;\\n  }\\n\\n  /**\\n   * @notice ERC-20 overridden function that include logic to check for trade validity.\\n   *\\n   * @param _to The address of the receiver\\n   * @param _value The number of tokens to transfer\\n   *\\n   * @return \u0060true\u0060 if successful and \u0060false\u0060 if unsuccessful\\n   */\\n  function transfer(address _to, uint256 _value) public returns (bool) {\\n    if (_check(msg.sender, _to, _value)) {\\n      return super.transfer(_to, _value);\\n    } else {\\n      return false;\\n    }\\n  }\\n\\n  /**\\n   * @notice ERC-20 overridden function that include logic to check for trade validity.\\n   *\\n   * @param _from The address of the sender\\n   * @param _to The address of the receiver\\n   * @param _value The number of tokens to transfer\\n   *\\n   * @return \u0060true\u0060 if successful and \u0060false\u0060 if unsuccessful\\n   */\\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\\n    if (_check(_from, _to, _value)) {\\n      return super.transferFrom(_from, _to, _value);\\n    } else {\\n      return false;\\n    }\\n  }\\n\\n  /**\\n   * @notice Performs the regulator check\\n   *\\n   * @dev This method raises a CheckStatus event indicating success or failure of the check\\n   *\\n   * @param _from The address of the sender\\n   * @param _to The address of the receiver\\n   * @param _value The number of tokens to transfer\\n   *\\n   * @return \u0060true\u0060 if the check was successful and \u0060false\u0060 if unsuccessful\\n   */\\n  function _check(address _from, address _to, uint256 _value) private returns (bool) {\\n    var reason = _service().check(this, msg.sender, _from, _to, _value);\\n\\n    CheckStatus(reason, msg.sender, _from, _to, _value);\\n\\n    return reason == 0;\\n  }\\n\\n  /**\\n   * @notice Retreives the address of the \u0060RegulatorService\u0060 that manages this token.\\n   *\\n   * @dev This function *MUST NOT* memoize the \u0060RegulatorService\u0060 address.  This would\\n   *      break the ability to upgrade the \u0060RegulatorService\u0060.\\n   *\\n   * @return The \u0060RegulatorService\u0060 that manages this token.\\n   */\\n  function _service() constant public returns (RegulatorService) {\\n    return RegulatorService(registry.service());\\n  }\\n}\\n\u0022},\u0022RegulatorService.sol\u0022:{\u0022content\u0022:\u0022/**\\n   Copyright (c) 2017 Harbor Platform, Inc.\\n\\n   Licensed under the Apache License, Version 2.0 (the \u201CLicense\u201D);\\n   you may not use this file except in compliance with the License.\\n   You may obtain a copy of the License at\\n\\n   http://www.apache.org/licenses/LICENSE-2.0\\n\\n   Unless required by applicable law or agreed to in writing, software\\n   distributed under the License is distributed on an \u201CAS IS\u201D BASIS,\\n   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\\n   See the License for the specific language governing permissions and\\n   limitations under the License.\\n*/\\n\\npragma solidity ^0.4.18;\\n\\n/// @notice Standard interface for \u0060RegulatorService\u0060s\\ncontract RegulatorService {\\n\\n  /*\\n   * @notice This method *MUST* be called by \u0060RegulatedToken\u0060s during \u0060transfer()\u0060 and \u0060transferFrom()\u0060.\\n   *         The implementation *SHOULD* check whether or not a transfer can be approved.\\n   *\\n   * @dev    This method *MAY* call back to the token contract specified by \u0060_token\u0060 for\\n   *         more information needed to enforce trade approval.\\n   *\\n   * @param  _token The address of the token to be transfered\\n   * @param  _spender The address of the spender of the token\\n   * @param  _from The address of the sender account\\n   * @param  _to The address of the receiver account\\n   * @param  _amount The quantity of the token to trade\\n   *\\n   * @return uint8 The reason code: 0 means success.  Non-zero values are left to the implementation\\n   *               to assign meaning.\\n   */\\n  function check(address _token, address _spender, address _from, address _to, uint256 _amount) public returns (uint8);\\n}\\n\u0022},\u0022SafeMath.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.18;\\n\\n\\n/**\\n * @title SafeMath\\n * @dev Math operations with safety checks that throw on error\\n */\\nlibrary SafeMath {\\n\\n  /**\\n  * @dev Multiplies two numbers, throws on overflow.\\n  */\\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\\n    if (a == 0) {\\n      return 0;\\n    }\\n    uint256 c = a * b;\\n    assert(c / a == b);\\n    return c;\\n  }\\n\\n  /**\\n  * @dev Integer division of two numbers, truncating the quotient.\\n  */\\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\\n    // assert(b \\u003e 0); // Solidity automatically throws when dividing by 0\\n    uint256 c = a / b;\\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\\u0027t hold\\n    return c;\\n  }\\n\\n  /**\\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\\n  */\\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\\n    assert(b \\u003c= a);\\n    return a - b;\\n  }\\n\\n  /**\\n  * @dev Adds two numbers, throws on overflow.\\n  */\\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\\n    uint256 c = a \u002B b;\\n    assert(c \\u003e= a);\\n    return c;\\n  }\\n}\\n\u0022},\u0022ServiceRegistry.sol\u0022:{\u0022content\u0022:\u0022/**\\n   Copyright (c) 2017 Harbor Platform, Inc.\\n\\n   Licensed under the Apache License, Version 2.0 (the \u201CLicense\u201D);\\n   you may not use this file except in compliance with the License.\\n   You may obtain a copy of the License at\\n\\n   http://www.apache.org/licenses/LICENSE-2.0\\n\\n   Unless required by applicable law or agreed to in writing, software\\n   distributed under the License is distributed on an \u201CAS IS\u201D BASIS,\\n   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\\n   See the License for the specific language governing permissions and\\n   limitations under the License.\\n*/\\n\\npragma solidity ^0.4.18;\\n\\nimport \\u0027./RegulatorService.sol\\u0027;\\nimport \\u0027./Ownable.sol\\u0027;\\n\\n/// @notice A service that points to a \u0060RegulatorService\u0060\\ncontract ServiceRegistry is Ownable {\\n  address public service;\\n\\n  /**\\n   * @notice Triggered when service address is replaced\\n   */\\n  event ReplaceService(address oldService, address newService);\\n\\n  /**\\n   * @dev Validate contract address\\n   * Credit: https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Token.sol#L107-L114\\n   *\\n   * @param _addr The address of a smart contract\\n   */\\n  modifier withContract(address _addr) {\\n    uint length;\\n    assembly { length := extcodesize(_addr) }\\n    require(length \\u003e 0);\\n    _;\\n  }\\n\\n  /**\\n   * @notice Constructor\\n   *\\n   * @param _service The address of the \u0060RegulatorService\u0060\\n   *\\n   */\\n  function ServiceRegistry(address _service) public {\\n    service = _service;\\n  }\\n\\n  /**\\n   * @notice Replaces the address pointer to the \u0060RegulatorService\u0060\\n   *\\n   * @dev This method is only callable by the contract\\u0027s owner\\n   *\\n   * @param _service The address of the new \u0060RegulatorService\u0060\\n   */\\n  function replaceService(address _service) onlyOwner withContract(_service) public {\\n    address oldService = service;\\n    service = _service;\\n    ReplaceService(oldService, service);\\n  }\\n}\\n\u0022},\u0022StandardToken.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.18;\\n\\nimport \\\u0022./BasicToken.sol\\\u0022;\\nimport \\\u0022./ERC20.sol\\\u0022;\\n\\n\\n/**\\n * @title Standard ERC20 token\\n *\\n * @dev Implementation of the basic standard token.\\n * @dev https://github.com/ethereum/EIPs/issues/20\\n * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\\n */\\ncontract StandardToken is ERC20, BasicToken {\\n\\n  mapping (address =\\u003e mapping (address =\\u003e uint256)) internal allowed;\\n\\n\\n  /**\\n   * @dev Transfer tokens from one address to another\\n   * @param _from address The address which you want to send tokens from\\n   * @param _to address The address which you want to transfer to\\n   * @param _value uint256 the amount of tokens to be transferred\\n   */\\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\\n    require(_to != address(0));\\n    require(_value \\u003c= balances[_from]);\\n    require(_value \\u003c= allowed[_from][msg.sender]);\\n\\n    balances[_from] = balances[_from].sub(_value);\\n    balances[_to] = balances[_to].add(_value);\\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\\n    Transfer(_from, _to, _value);\\n    return true;\\n  }\\n\\n  /**\\n   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\\n   *\\n   * Beware that changing an allowance with this method brings the risk that someone may use both the old\\n   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\\n   * race condition is to first reduce the spender\\u0027s allowance to 0 and set the desired value afterwards:\\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\\n   * @param _spender The address which will spend the funds.\\n   * @param _value The amount of tokens to be spent.\\n   */\\n  function approve(address _spender, uint256 _value) public returns (bool) {\\n    allowed[msg.sender][_spender] = _value;\\n    Approval(msg.sender, _spender, _value);\\n    return true;\\n  }\\n\\n  /**\\n   * @dev Function to check the amount of tokens that an owner allowed to a spender.\\n   * @param _owner address The address which owns the funds.\\n   * @param _spender address The address which will spend the funds.\\n   * @return A uint256 specifying the amount of tokens still available for the spender.\\n   */\\n  function allowance(address _owner, address _spender) public view returns (uint256) {\\n    return allowed[_owner][_spender];\\n  }\\n\\n  /**\\n   * @dev Increase the amount of tokens that an owner allowed to a spender.\\n   *\\n   * approve should be called when allowed[_spender] == 0. To increment\\n   * allowed value is better to use this function to avoid 2 calls (and wait until\\n   * the first transaction is mined)\\n   * From MonolithDAO Token.sol\\n   * @param _spender The address which will spend the funds.\\n   * @param _addedValue The amount of tokens to increase the allowance by.\\n   */\\n  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {\\n    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);\\n    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\\n    return true;\\n  }\\n\\n  /**\\n   * @dev Decrease the amount of tokens that an owner allowed to a spender.\\n   *\\n   * approve should be called when allowed[_spender] == 0. To decrement\\n   * allowed value is better to use this function to avoid 2 calls (and wait until\\n   * the first transaction is mined)\\n   * From MonolithDAO Token.sol\\n   * @param _spender The address which will spend the funds.\\n   * @param _subtractedValue The amount of tokens to decrease the allowance by.\\n   */\\n  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {\\n    uint oldValue = allowed[msg.sender][_spender];\\n    if (_subtractedValue \\u003e oldValue) {\\n      allowed[msg.sender][_spender] = 0;\\n    } else {\\n      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\\n    }\\n    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\\n    return true;\\n  }\\n\\n}\\n\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022mintingFinished\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022RTOKEN_DECIMALS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022registry\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022finishMinting\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_service\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_registry\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022reason\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022CheckStatus\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Mint\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MintFinished\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"RegulatedToken","CompilerVersion":"v0.4.18\u002Bcommit.9cf6e910","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000008f49b76384e4dd01da03f9a59b99271a2c61c010000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000001c554e49564552474520494e564553544f525320474f525020434f494e0000000000000000000000000000000000000000000000000000000000000000000000035549470000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://4c4a3abec03c3c9f1b0387614ace48cb6a347950c2bd5d59d0c706e92cdb34d0"}]