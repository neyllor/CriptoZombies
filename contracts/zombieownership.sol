// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.6.0;

import "./zombieattack.sol";
import "./erc721.sol";


//@title: Contrato que gerencia a transferência de propriedade de zumbis
//@author: Neyllor Cardoso
//@dev— Compatível com a implementação do rascunho de especificações ERC721 do OpenZeppelin
contract ZombieOwnership is ZombieAttack, ERC721 {

    mapping (uint => address) zombieApprovals;

    function balanceOf(address _owner) external view returns(uint) {
        return ownerZombieCount[_owner];
    }

    function ownerOf(uint _tokenId) external view returns(address) {
        return zombieToOwner[_tokenId];
    }

    function _transfer(address _from, address _to, uint _tokenId) private {
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
        zombieToOwner[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);

    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require(zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId){
        zombieApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

}