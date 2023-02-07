// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract CDForTurkey is ERC1155, Ownable, Pausable, ERC1155Supply {
    
    address public constant AHBAP_WALLET = 0xe1935271D1993434A1a59fE08f24891Dc5F398Cd;

    uint256 public price = 0.003 ether;
    uint256 public total = 10;

    string public baseURI = "https://forturkey.art/metadata/";

    constructor() ERC1155("") {
        _pause();
    }

    function setBaseURI(string memory _newURI) external onlyOwner {
        baseURI = _newURI;
    }

    function setPrice(uint256 _price) external onlyOwner {
		price = _price;
	}

    function setTotal(uint256 _total) external onlyOwner {
        require(total < _total, "VALUE NOT VALID");

		total = _total;
	}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function mint(uint256 _id, uint256 _amount) public payable whenNotPaused {
        require(_id < total, "TOKEN ID NOT VALID");
        require(msg.value >= price * _amount, "NOT ENOUGH ETHERS SEND");

        _mint(msg.sender, _id, _amount, "");
    }

    function withdraw() external onlyOwner {
		require(address(this).balance > 0, "INSUFFICIENT FUNDS");
		
		payable(AHBAP_WALLET).transfer(address(this).balance);
	}

    function uri(uint256 tokenId) public view virtual override(ERC1155) returns (string memory) {
        require(tokenId < total, "TOKEN ID NOT VALID");

		return (
            string(abi.encodePacked(
                baseURI,
                Strings.toString(tokenId),
                ".json"
            ))
        );
	}

    function _beforeTokenTransfer(
        address _operator,
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._beforeTokenTransfer(_operator, _from, _to, _ids, _amounts, _data);
    }
}
