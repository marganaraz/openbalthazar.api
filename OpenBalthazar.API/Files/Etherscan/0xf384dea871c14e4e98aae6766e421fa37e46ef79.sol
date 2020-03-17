[{"SourceCode":"pragma solidity ^0.5.13;\r\nlibrary SafeMath {\r\n    function add(uint256 a,uint256 b)internal pure returns(uint256){uint256 c=a\u002Bb; require(c\u003E=a); return c;}\r\n\tfunction sub(uint256 a,uint256 b)internal pure returns(uint256){require(b\u003C=a);uint256 c=a-b;return c;}\r\n\tfunction mul(uint256 a,uint256 b)internal pure returns(uint256){if(a==0){return 0;}uint256 c=a*b;require(c/a==b);return c;}\r\n\tfunction div(uint256 a,uint256 b)internal pure returns(uint256){require(b\u003E0);uint256 c=a/b;return c;}}\r\ninterface Out{\r\n\tfunction mint(address w,uint256 a)external returns(bool);\r\n    function burn(address w,uint256 a)external returns(bool);\r\n   \tfunction register(address a,address b)external returns(bool);\r\n   \tfunction balanceOf(address account)external view returns(uint256);}\t\r\ncontract ESCROW{    \r\n\tusing SafeMath for uint256;\r\n\taddress private rot=0x45F2aB0ca2116b2e1a70BF5e13293947b25d0272;\r\n\taddress private reg=0x28515e3a4932c3a780875D329FDA8E2C93B79E43;\r\n\tmapping(address =\u003E uint256) public price;\r\n\tmapping(address =\u003E uint256) public amount;\t\r\n\tfunction toPayable(address a)internal pure returns(address payable){return address(uint160(a));}\r\n\tfunction setEscrow(uint256 p,uint256 a)external returns(bool){\r\n\t    require(Out(rot).balanceOf(msg.sender) \u003E= a);\r\n\t    require(p\u003E10**14);price[msg.sender]=p;amount[msg.sender]=a;return true;}\r\n\tfunction payEscrow(address w)external payable returns(bool){require(msg.value\u003E10**14);\r\n\t\tuint256 gam=(msg.value.mul(10**18)).div(price[w]);\r\n\t\trequire(Out(rot).balanceOf(w) \u003E= amount[w] \u0026\u0026 amount[w] \u003E= gam \u0026\u0026 \r\n\t\t    Out(reg).register(msg.sender,w) \u0026\u0026 Out(rot).mint(msg.sender,gam) \u0026\u0026 Out(rot).burn(w,gam));\r\n\t\tamount[w]=amount[w].sub(gam);toPayable(w).transfer(msg.value);return true;}\r\n    function geInfo(address n)external view returns(uint256,uint256){return(price[n],amount[n]);}\r\n   \tfunction()external{revert();}}","ABI":"[{\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022amount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022n\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022geInfo\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022w\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022payEscrow\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022price\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022p\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setEscrow\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"ESCROW","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://f80e5c46fefe04dbebf8d4820191ce8768324666f85d5e01b941aaaa36443cc2"}]