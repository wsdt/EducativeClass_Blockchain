pragma solidity ^0.8.7;

import "@layer-zero/contracts/token/onft/IONFT721.sol";
import "@layer-zero/contracts/token/onft/ONFT721Core.sol";

contract Omnichain is ONFT721Core {
    constructor(address _lzEndpoint) ONFT721Core(_lzEndpoint) {}

   /* function supportsInterface(bytes4 interfaceId) public view virtual override(ONFT721Core, IERC165) returns (bool) {
        return interfaceId == type(IONFT721).interfaceId || super.supportsInterface(interfaceId);
    }*/

    function _debitFrom(address _from, uint16, bytes memory, uint _tokenId) internal virtual override {
        //require(_isApprovedOrOwner(_msgSender(), _tokenId), "ONFT721: send caller is not owner nor approved");
        //require(ERC721.ownerOf(_tokenId) == _from, "ONFT721: send from incorrect owner");
        //_burn(_tokenId);
    }

    function _creditTo(uint16, address _toAddress, uint _tokenId) internal virtual override {
        //_safeMint(_toAddress, _tokenId);
    }
}
