// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.6.0;

import "./zombieFactory.sol";

// Interface para buscar os dados do contrato CriptoKitties
contract KittyInterface{
    function getKitty(uint256 _id) external view returns(
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

//@title: Contrato que gerencia a alimentação dos Zumbis
//@author: Neyllor Cardoso
//@dev— Compatível com a implementação do rascunho de especificações ERC721 do OpenZeppelin
contract ZombieFeeding is ZombieFactory {

    KittyInterface kittyContract;

    modifier onlyOwnerOf(uint _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }

    function setKittyContractAddress(address _address) external onlyOwner{
        kittyContract = KittyInterface(_address);
    }
    
    //Aplica tempo de cooldown
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }

    //retorna se o tempo de cooldown já foi encerrado
    function _isReady(Zombie storage _zombie) internal view returns (bool){
        return (_zombie.readyTime <= now);
    }

    //Função para multplicar os zombies. 
    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombi) {
        
        Zombie storage myZombie = zombies[_zombieId];
        require(_isReady(myZombie));
        
        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;
        
        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newDna = newDna - newDna % 100 + 99; // Substituindo os 2 ultimos digitos do DNA por 99
        }
        _createZombie("NoName", newDna);
        _triggerCooldown(myZombie);

    }

    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);//Buscar somente os genes do cryptokitty
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }

}