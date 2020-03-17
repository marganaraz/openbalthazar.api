[{"SourceCode":"pragma solidity 0.5.13;\r\ninterface Out{function check(address w)external view returns(bool);}\r\ncontract REGISTER{\r\n    address private own;address private uni;uint256 private cnt=4;\r\n    modifier onlyOwn{require(own==msg.sender);_;} \r\n    modifier infra{require(Out(uni).check(msg.sender));_;}\r\n\tmapping(uint256=\u003Eaddress)private ac;mapping(address=\u003Euint256)private id;\r\n\tmapping(address=\u003Eaddress)private rref;mapping(address=\u003Euint256)private rdate;\r\n    address private rvs=0xd8E399398839201C464cda7109b27302CFF0CEaE;\r\n    address private fts=0xc0ae03412B19B4303cc67603B54d1309b19Df158;\r\n    address private sts=0xd1d5bd873AA0A064C3Bd78266a9C7149510fAC41;\r\n\tmapping(address=\u003Eaddress[])public fref;mapping(address=\u003Eaddress[])public sref;\r\n\tfunction rff(address a,address b)private returns(bool){\r\n\t\trdate[a]=now;rref[a]=b;fref[b].push(a);sref[rref[b]].push(a);return true;}\r\n    function _register(address a,address b)private returns(bool){\r\n\t\trequire(id[b]!=0);if(id[a]==0){ac[cnt\u002Bnow]=a;id[a]=cnt\u002Bnow;cnt=cnt\u002B1;require(rff(a,b));}return true;}\r\n    function register(address a,address b)external infra returns(bool){require(_register(a,b));return true;}\r\n    function segister(address b)external returns(bool){require(_register(msg.sender,b));return true;}\r\n    function total()external view returns(uint256){return cnt-1;}\r\n    function acc(uint256 a)external view returns(address){return ac[a];}\r\n    function idd(address a)external view returns(uint256){return id[a];}\r\n    function ref(address a)external view returns(address){return rref[a];}\r\n    function sef(address a)external view returns(address){return rref[rref[a]];}\r\n    function pro(address a)external view returns(uint256,uint256,uint256){return(fref[a].length,sref[a].length,rdate[a]);}\r\n    function setuni(address a)external onlyOwn returns(bool){uni=a;return true;}\r\n\tfunction()external{revert();}\r\n\tconstructor()public{own=msg.sender;\r\n\t   id[rvs]=1000000000;ac[1000000000]=rvs;rref[rvs]=rvs;\r\n\t   id[fts]=1100000000;ac[1100000000]=fts;rref[fts]=fts;\r\n\t   id[sts]=1200000000;ac[1200000000]=sts;rref[sts]=sts;}}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022acc\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022fref\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022idd\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022pro\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ref\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022register\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022sef\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022segister\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setuni\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sref\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022total\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"REGISTER","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://39d1a16cb483ab4f7800e1947425d6702698e371a8c0bd72afa625e99e8dcb2e"}]