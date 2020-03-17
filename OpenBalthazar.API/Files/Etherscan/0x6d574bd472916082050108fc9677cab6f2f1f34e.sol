[{"SourceCode":"pragma solidity ^0.4.11;\r\n\r\n\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n\r\n  function Ownable() {\r\n    owner = \u00220x2B59D24F789f456b1E4Df6e31A4873F34A15AA62\u0022;\r\n  }\r\n\r\n\r\n  modifier onlyOwner() {\r\n    if (msg.sender != owner) {\r\n      throw;\r\n    }\r\n    _;\r\n  }\r\n\r\n  function transferOwnership(address newOwner) onlyOwner {\r\n    if (newOwner != address(0)) {\r\n      owner = newOwner;\r\n    }\r\n  }\r\n\r\n}\r\n\r\ncontract Token{\r\n  function transfer(address to, uint value) returns (bool);\r\n}\r\n\r\ncontract Indorser is Ownable {\r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n    \r\n\r\n    function RPexchange(address _tokenAddr, address[] _to, uint256[] _value) onlyOwner \r\n    returns (bool _success) {\r\n        assert(_to.length == _value.length);\r\n\t\tassert(_to.length \u003C= 150);\r\n        // loop through to addresses and send value\r\n\t\tfor (uint8 i = 0; i \u003C _to.length; i\u002B\u002B) {\r\n            assert((Token(_tokenAddr).transfer(_to[i], _value[i])) == true);\r\n        }\r\n        return true;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022RPexchange\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Indorser","CompilerVersion":"v0.4.11\u002Bcommit.68ef5810","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://ac65a1da0c6a5b0d08ec6a9c347a4c16cdb10f634c3d81097e126daaa241fdb9"}]