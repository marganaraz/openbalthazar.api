[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\n// Saturn Network\r\n\r\nlibrary SafeMath {\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a * b;\r\n    assert(a == 0 || c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\nlibrary BytesLib {\r\n  function toAddress(bytes _bytes, uint _start) internal pure returns (address) {\r\n    require(_bytes.length \u003E= (_start \u002B 20));\r\n    address tempAddress;\r\n\r\n    assembly {\r\n      tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)\r\n    }\r\n\r\n    return tempAddress;\r\n  }\r\n\r\n  function toUint(bytes _bytes, uint _start) internal pure returns (uint256) {\r\n    require(_bytes.length \u003E= (_start \u002B 32));\r\n    uint256 tempUint;\r\n\r\n    assembly {\r\n      tempUint := mload(add(add(_bytes, 0x20), _start))\r\n    }\r\n\r\n    return tempUint;\r\n  }\r\n}\r\n\r\ncontract ERC223 {\r\n  uint public totalSupply;\r\n  function balanceOf(address who) constant public returns (uint);\r\n\r\n  function name() constant public returns (string _name);\r\n  function symbol() constant public returns (string _symbol);\r\n  function decimals() constant public returns (uint8 _decimals);\r\n  function totalSupply() constant public returns (uint256 _supply);\r\n\r\n  function transfer(address to, uint value) public returns (bool ok);\r\n  function transfer(address to, uint value, bytes data) public returns (bool ok);\r\n  event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n  event ERC223Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);\r\n}\r\n\r\ncontract ContractReceiver {\r\n  function tokenFallback(address _from, uint _value, bytes _data) public;\r\n}\r\n\r\ncontract ERC20 {\r\n    function totalSupply() public view returns (uint);\r\n    function balanceOf(address holder) public view returns (uint);\r\n    function allowance(address holder, address other) public view returns (uint);\r\n\r\n    function approve(address other, uint amount) public returns (bool);\r\n    function transfer(address to, uint amount) public returns (bool);\r\n    function transferFrom(\r\n        address from, address to, uint amount\r\n    ) public returns (bool);\r\n}\r\n\r\ncontract Exchange is ContractReceiver {\r\n  using SafeMath for uint256;\r\n  using BytesLib for bytes;\r\n\r\n  struct Order {\r\n    address owner;\r\n    bool    active;\r\n    address sellToken;\r\n    address buyToken;\r\n    address ring;\r\n    uint256 amount;\r\n    uint256 priceMul;\r\n    uint256 priceDiv;\r\n  }\r\n\r\n  // person =\u003E token =\u003E balance\r\n  mapping(address =\u003E mapping(address =\u003E uint256)) private balances;\r\n  mapping(uint256 =\u003E Order) private orderBook;\r\n  uint256 public orderCount;\r\n  address private etherAddress = 0x0;\r\n\r\n  address private saturnToken;\r\n  address private admin;\r\n  uint256 public tradeMiningBalance;\r\n  address public treasury;\r\n\r\n  uint256 public feeMul;\r\n  uint256 public feeDiv;\r\n  uint256 public tradeMiningMul;\r\n  uint256 public tradeMiningDiv;\r\n\r\n  event NewOrder(\r\n    uint256 id,\r\n    address owner,\r\n    address sellToken,\r\n    address buyToken,\r\n    address ring,\r\n    uint256 amount,\r\n    uint256 priceMul,\r\n    uint256 priceDiv,\r\n    uint256 time\r\n  );\r\n\r\n  event OrderCancelled(\r\n    uint256 id,\r\n    uint256 time\r\n  );\r\n\r\n  event OrderFulfilled(\r\n    uint256 id,\r\n    uint256 time\r\n  );\r\n\r\n  event Trade(\r\n    address from,\r\n    address to,\r\n    uint256 orderId,\r\n    uint256 soldTokens,\r\n    uint256 boughtTokens,\r\n    uint256 feePaid,\r\n    uint256 time\r\n  );\r\n\r\n  event Mined(\r\n    address trader,\r\n    uint256 amount,\r\n    uint256 time\r\n  );\r\n\r\n  // this syntax was too advanced for ETC pre-Agharta\r\n  /* constructor( */\r\n  function Exchange(\r\n    address _saturnToken,\r\n    address _treasury,\r\n    uint256 _feeMul,\r\n    uint256 _feeDiv,\r\n    uint256 _tradeMiningMul,\r\n    uint256 _tradeMiningDiv\r\n  ) public {\r\n    saturnToken    = _saturnToken;\r\n    treasury       = _treasury;\r\n    feeMul         = _feeMul;\r\n    feeDiv         = _feeDiv;\r\n    tradeMiningMul = _tradeMiningMul;\r\n    tradeMiningDiv = _tradeMiningDiv;\r\n    // admin can only add \u0026 remove tokens from SATURN trade mining token distribution program\r\n    // admin has no ability to halt trading, delist tokens, or claim anyone\u0027s funds\r\n    admin          = msg.sender;\r\n  }\r\n\r\n  function() payable public { revert(); }\r\n\r\n  //////////////////\r\n  // public views //\r\n  //////////////////\r\n  // TODO: add views for prices too\r\n  // TODO: and for order owner too\r\n\r\n  function getBalance(address token, address user) view public returns(uint256) {\r\n    return balances[user][token];\r\n  }\r\n\r\n  function isOrderActive(uint256 orderId) view public returns(bool) {\r\n    return orderBook[orderId].active;\r\n  }\r\n\r\n  function remainingAmount(uint256 orderId) view public returns(uint256) {\r\n    return orderBook[orderId].amount;\r\n  }\r\n\r\n  function getBuyTokenAmount(uint256 desiredSellTokenAmount, uint256 orderId) public view returns(uint256 amount) {\r\n    require(desiredSellTokenAmount \u003E 0);\r\n    Order storage order = orderBook[orderId];\r\n\r\n    if (order.sellToken == etherAddress || order.buyToken == etherAddress) {\r\n      uint256 feediff = feeDiv.sub(feeMul);\r\n      amount = desiredSellTokenAmount.mul(order.priceDiv).mul(feeDiv).div(order.priceMul).div(feediff);\r\n    } else {\r\n      amount = desiredSellTokenAmount.mul(order.priceDiv).div(order.priceMul);\r\n    }\r\n    require(amount \u003E 0);\r\n  }\r\n\r\n  function calcFees(uint256 amount, uint256 orderId) public view returns(uint256 fees) {\r\n    Order storage order = orderBook[orderId];\r\n\r\n    if (order.sellToken == etherAddress) {\r\n      uint256 sellTokenAmount = amount.mul(order.priceMul).div(order.priceDiv);\r\n      fees = sellTokenAmount.mul(feeMul).div(feeDiv);\r\n    } else if (order.buyToken == etherAddress) {\r\n      fees = amount.mul(feeMul).div(feeDiv);\r\n    } else {\r\n      fees = 0;\r\n    }\r\n    return fees;\r\n  }\r\n\r\n  function tradeMiningAmount(uint256 fees, uint256 orderId) public view returns(uint256) {\r\n    if (fees == 0) { return 0; }\r\n    Order storage order = orderBook[orderId];\r\n    if (!order.active) { return 0; }\r\n    uint256 tokenAmount = fees.mul(tradeMiningMul).div(tradeMiningDiv);\r\n\r\n    if (tradeMiningBalance \u003C tokenAmount) {\r\n      return tradeMiningBalance;\r\n    } else {\r\n      return tokenAmount;\r\n    }\r\n  }\r\n\r\n  ////////////////////\r\n  // public methods //\r\n  ////////////////////\r\n\r\n  function withdrawTradeMining() public {\r\n    if (msg.sender != admin) { revert(); }\r\n    require(tradeMiningBalance \u003E 0);\r\n\r\n    uint toSend = tradeMiningBalance;\r\n    tradeMiningBalance = 0;\r\n    require(sendTokensTo(admin, toSend, saturnToken));\r\n  }\r\n\r\n  function changeTradeMiningPrice(uint256 newMul, uint256 newDiv) public {\r\n    if (msg.sender != admin) { revert(); }\r\n    require(newDiv != 0);\r\n    tradeMiningMul = newMul;\r\n    tradeMiningDiv = newDiv;\r\n  }\r\n\r\n  // handle incoming ERC223 tokens\r\n  function tokenFallback(address from, uint value, bytes data) public {\r\n    // depending on length of data\r\n    // this should be either an order creating transaction\r\n    // or an order taking transaction\r\n    // or a transaction allocating tokens for trade mining\r\n    if (data.length == 0 \u0026\u0026 msg.sender == saturnToken) {\r\n      _topUpTradeMining(value);\r\n    } else if (data.length == 84) {\r\n      _newOrder(from, msg.sender, data.toAddress(64), value, data.toUint(0), data.toUint(32), etherAddress);\r\n    } else if (data.length == 104) {\r\n      _newOrder(from, msg.sender, data.toAddress(64), value, data.toUint(0), data.toUint(32), data.toAddress(84));\r\n    } else if (data.length == 32) {\r\n      _executeOrder(from, data.toUint(0), msg.sender, value);\r\n    } else {\r\n      // unknown payload!\r\n      revert();\r\n    }\r\n  }\r\n\r\n  function sellEther(\r\n    address buyToken,\r\n    uint256 priceMul,\r\n    uint256 priceDiv\r\n  ) public payable returns(uint256 orderId) {\r\n    require(msg.value \u003E 0);\r\n    return _newOrder(msg.sender, etherAddress, buyToken, msg.value, priceMul, priceDiv, etherAddress);\r\n  }\r\n\r\n  function sellEtherWithRing(\r\n    address buyToken,\r\n    uint256 priceMul,\r\n    uint256 priceDiv,\r\n    address ring\r\n  ) public payable returns(uint256 orderId) {\r\n    require(msg.value \u003E 0);\r\n    return _newOrder(msg.sender, etherAddress, buyToken, msg.value, priceMul, priceDiv, ring);\r\n  }\r\n\r\n  function buyOrderWithEth(uint256 orderId) public payable {\r\n    require(msg.value \u003E 0);\r\n    _executeOrder(msg.sender, orderId, etherAddress, msg.value);\r\n  }\r\n\r\n  function sellERC20Token(\r\n    address sellToken,\r\n    address buyToken,\r\n    uint256 amount,\r\n    uint256 priceMul,\r\n    uint256 priceDiv\r\n  ) public returns(uint256 orderId) {\r\n    require(amount \u003E 0);\r\n    require(pullTokens(sellToken, amount));\r\n    return _newOrder(msg.sender, sellToken, buyToken, amount, priceMul, priceDiv, etherAddress);\r\n  }\r\n\r\n  function sellERC20TokenWithRing(\r\n    address sellToken,\r\n    address buyToken,\r\n    uint256 amount,\r\n    uint256 priceMul,\r\n    uint256 priceDiv,\r\n    address ring\r\n  ) public returns(uint256 orderId) {\r\n    require(amount \u003E 0);\r\n    require(pullTokens(sellToken, amount));\r\n    return _newOrder(msg.sender, sellToken, buyToken, amount, priceMul, priceDiv, ring);\r\n  }\r\n\r\n  function buyOrderWithERC20Token(\r\n    uint256 orderId,\r\n    address token,\r\n    uint256 amount\r\n  ) public {\r\n    require(amount \u003E 0);\r\n    require(pullTokens(token, amount));\r\n    _executeOrder(msg.sender, orderId, token, amount);\r\n  }\r\n\r\n  function cancelOrder(uint256 orderId) public {\r\n    Order storage order = orderBook[orderId];\r\n    require(order.amount \u003E 0);\r\n    require(order.active);\r\n    require(msg.sender == order.owner);\r\n\r\n    balances[msg.sender][order.sellToken] = balances[msg.sender][order.sellToken].sub(order.amount);\r\n    require(sendTokensTo(order.owner, order.amount, order.sellToken));\r\n\r\n    // deleting the order refunds the caller some gas (up to 50%)\r\n    // this also sets order.active to false\r\n    delete orderBook[orderId];\r\n    emit OrderCancelled(orderId, now);\r\n  }\r\n\r\n  /////////////////////\r\n  // private methods //\r\n  /////////////////////\r\n\r\n  function _newOrder(\r\n    address owner,\r\n    address sellToken,\r\n    address buyToken,\r\n    uint256 amount,\r\n    uint256 priceMul,\r\n    uint256 priceDiv,\r\n    address ring\r\n  ) private returns(uint256 orderId) {\r\n    /////////////////////////\r\n    // step 1. validations //\r\n    /////////////////////////\r\n    require(amount \u003E 0);\r\n    require(priceMul \u003E 0);\r\n    require(priceDiv \u003E 0);\r\n    require(sellToken != buyToken);\r\n    ///////////////////////////////\r\n    // step 2. Update order book //\r\n    ///////////////////////////////\r\n    orderId = orderCount\u002B\u002B;\r\n    orderBook[orderId] = Order(owner, true, sellToken, buyToken, ring, amount, priceMul, priceDiv);\r\n    balances[owner][sellToken] = balances[owner][sellToken].add(amount);\r\n\r\n    emit NewOrder(orderId, owner, sellToken, buyToken, ring, amount, priceMul, priceDiv, now);\r\n  }\r\n\r\n  function _executeBuyOrder(address trader, uint256 orderId, uint256 buyTokenAmount) private returns(uint256) {\r\n    // buytoken: tkn\r\n    // selltoken: ether\r\n    Order storage order = orderBook[orderId];\r\n    uint256 sellTokenAmount = buyTokenAmount.mul(order.priceMul).div(order.priceDiv);\r\n    uint256 fees = sellTokenAmount.mul(feeMul).div(feeDiv);\r\n\r\n    require(sellTokenAmount \u003E 0);\r\n    require(sellTokenAmount \u003C= order.amount);\r\n    order.amount = order.amount.sub(sellTokenAmount);\r\n    // send tokens to order owner\r\n    require(sendTokensTo(order.owner, buyTokenAmount, order.buyToken));\r\n    // send ether to trader\r\n    require(sendTokensTo(trader, sellTokenAmount.sub(fees), order.sellToken));\r\n\r\n    emit Trade(trader, order.owner, orderId, sellTokenAmount.sub(fees), buyTokenAmount, fees, now);\r\n    return fees;\r\n  }\r\n\r\n  function _executeSellOrder(address trader, uint256 orderId, uint256 buyTokenAmount) private returns(uint256) {\r\n    // buytoken: ether\r\n    // selltoken: tkn\r\n    Order storage order = orderBook[orderId];\r\n    uint256 fees = buyTokenAmount.mul(feeMul).div(feeDiv);\r\n    uint256 sellTokenAmount = buyTokenAmount.sub(fees).mul(order.priceMul).div(order.priceDiv);\r\n\r\n\r\n    require(sellTokenAmount \u003E 0);\r\n    require(sellTokenAmount \u003C= order.amount);\r\n    order.amount = order.amount.sub(sellTokenAmount);\r\n    // send ether to order owner\r\n    require(sendTokensTo(order.owner, buyTokenAmount.sub(fees), order.buyToken));\r\n    // send token to trader\r\n    require(sendTokensTo(trader, sellTokenAmount, order.sellToken));\r\n\r\n    emit Trade(trader, order.owner, orderId, sellTokenAmount, buyTokenAmount.sub(fees), fees, now);\r\n    return fees;\r\n  }\r\n\r\n  function _executeTokenSwap(address trader, uint256 orderId, uint256 buyTokenAmount) private returns(uint256) {\r\n    // no ether was exchanged\r\n    Order storage order = orderBook[orderId];\r\n    uint256 sellTokenAmount = buyTokenAmount.mul(order.priceMul).div(order.priceDiv);\r\n\r\n    require(sellTokenAmount \u003E 0);\r\n    require(sellTokenAmount \u003C= order.amount);\r\n    order.amount = order.amount.sub(sellTokenAmount);\r\n\r\n    require(sendTokensTo(order.owner, buyTokenAmount, order.buyToken));\r\n    require(sendTokensTo(trader, sellTokenAmount, order.sellToken));\r\n\r\n    emit Trade(trader, order.owner, orderId, sellTokenAmount, buyTokenAmount, 0, now);\r\n    return 0;\r\n  }\r\n\r\n  function _executeOrder(address trader, uint256 orderId, address buyToken, uint256 buyTokenAmount) private {\r\n    /////////////////////////\r\n    // step 0. validations //\r\n    /////////////////////////\r\n    require(orderId \u003C orderCount);\r\n    require(buyTokenAmount \u003E 0);\r\n    Order storage order = orderBook[orderId];\r\n    require(order.active);\r\n    require(trader != order.owner);\r\n    require(buyToken == order.buyToken);\r\n\r\n    // enforce exclusivity for the rings\r\n    if (order.ring != etherAddress) { require(order.ring == tx.origin); }\r\n\r\n    ////////////////////////////\r\n    // step 1. token exchange //\r\n    ////////////////////////////\r\n    uint256 fees;\r\n    if (order.sellToken == etherAddress) {\r\n      // buy order: taker sends ether, gets tokens\r\n      fees = _executeBuyOrder(trader, orderId, buyTokenAmount);\r\n    } else if (order.buyToken == etherAddress) {\r\n      // sell order: taker sends tokens, gets ether\r\n      fees = _executeSellOrder(trader, orderId, buyTokenAmount);\r\n    } else {\r\n      fees = _executeTokenSwap(trader, orderId, buyTokenAmount);\r\n    }\r\n\r\n    ////////////////////////////\r\n    // step 2. fees \u0026 wrap up //\r\n    ////////////////////////////\r\n    // collect fees and issue trade mining\r\n    require(_tradeMiningAndFees(fees, trader));\r\n    // deleting the order refunds the caller some gas\r\n    if (orderBook[orderId].amount == 0) {\r\n      delete orderBook[orderId];\r\n      emit OrderFulfilled(orderId, now);\r\n    }\r\n  }\r\n\r\n  function _tradeMiningAndFees(uint256 fees, address trader) private returns(bool) {\r\n    if (fees == 0) { return true; }\r\n    // step one: send fees to the treasury\r\n    require(sendTokensTo(treasury, fees, etherAddress));\r\n    if (tradeMiningBalance == 0) { return true; }\r\n\r\n    // step two: calculate reward\r\n    uint256 tokenAmount = fees.mul(tradeMiningMul).div(tradeMiningDiv);\r\n    if (tokenAmount == 0) { return true; }\r\n    if (tokenAmount \u003E tradeMiningBalance) { tokenAmount = tradeMiningBalance; }\r\n\r\n    // account for sent tokens\r\n    tradeMiningBalance = tradeMiningBalance.sub(tokenAmount);\r\n    // step three: send the reward to the trader\r\n    require(sendTokensTo(trader, tokenAmount, saturnToken));\r\n    emit Mined(trader, tokenAmount, now);\r\n    return true;\r\n  }\r\n\r\n  function sendTokensTo(address destination, uint256 amount, address tkn) private returns(bool) {\r\n    if (tkn == etherAddress) {\r\n      destination.transfer(amount);\r\n    } else {\r\n      // works with both ERC223 and ERC20\r\n      require(ERC20(tkn).transfer(destination, amount));\r\n    }\r\n    return true;\r\n  }\r\n\r\n  // ERC20 fixture\r\n  function pullTokens(address token, uint256 amount) private returns(bool) {\r\n    return ERC20(token).transferFrom(msg.sender, address(this), amount);\r\n  }\r\n\r\n  function _topUpTradeMining(uint256 amount) private returns(bool) {\r\n    tradeMiningBalance = tradeMiningBalance.add(amount);\r\n    return true;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022sellToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022buyToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022priceMul\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022priceDiv\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022ring\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022sellERC20TokenWithRing\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022orderId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022orderCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newMul\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022newDiv\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022changeTradeMiningPrice\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022orderId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022cancelOrder\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022feeMul\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022treasury\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tradeMiningMul\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022orderId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022calcFees\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022fees\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022orderId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022remainingAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022feeDiv\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022orderId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022buyOrderWithEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022tokenFallback\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022fees\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022orderId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tradeMiningAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tradeMiningBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022buyToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022priceMul\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022priceDiv\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sellEther\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022orderId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022orderId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022buyOrderWithERC20Token\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022orderId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022isOrderActive\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022buyToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022priceMul\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022priceDiv\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022ring\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022sellEtherWithRing\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022orderId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022sellToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022buyToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022priceMul\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022priceDiv\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sellERC20Token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022orderId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawTradeMining\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tradeMiningDiv\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022desiredSellTokenAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022orderId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBuyTokenAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_saturnToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_treasury\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_feeMul\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_feeDiv\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tradeMiningMul\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tradeMiningDiv\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022sellToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022buyToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ring\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022priceMul\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022priceDiv\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022NewOrder\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022OrderCancelled\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022OrderFulfilled\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022orderId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022soldTokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022boughtTokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022feePaid\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Trade\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022trader\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Mined\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Exchange","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000b9440022a095343b440d590fcd2d7a3794bd76c800000000000000000000000092eeb915dafe3803f8a9d12000765c3b6af6d5fd00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000190000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000002540be400","Library":"","SwarmSource":"bzzr://2010bc52368ea0ee38b0099f8ceee568961a3f0c4d317bc50903c65ca8945c15"}]