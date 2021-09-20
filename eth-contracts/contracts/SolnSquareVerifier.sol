// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.8;

import {GaleDotToken} from "./ERC721Mintable.sol";
import "./Verifier.sol";

// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
contract SquareVerifier is Verifier {

}

// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is GaleDotToken {
    SquareVerifier public verifier;

    constructor(address verifierAddress) GaleDotToken() {
        verifier = SquareVerifier(verifierAddress);
    }

    // TODO define a solutions struct that can hold an index & an address
    struct Solution {
        uint256 tokenId;
        address to;
    }

    // TODO define an array of the above struct
    Solution[] submittedSolutions;

    // TODO define a mapping to store unique solutions submitted
    mapping(bytes32 => Solution) uniqueSolutions;
    // TODO Create an event to emit when a solution is added
    event SolutionAdded(
        address indexed to,
        uint256 indexed tokenId,
        bytes32 indexed key
    );

    function getVerifierKey(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(a, b, c, input));
    }

    // TODO Create a function to add the solutions to the array and emit the event
    function addSolution(
        address _to,
        uint256 _tokenId,
        bytes32 _key
    ) public {
        Solution memory _soln = Solution({tokenId: _tokenId, to: _to});
        submittedSolutions.push(_soln);
        uniqueSolutions[_key] = _soln;
        emit SolutionAdded(_to, _tokenId, _key);
    }

    // TODO Create a function to mint new NFT only after the solution has been verified
    //  - make sure the solution is unique (has not been used before)
    //  - make sure you handle metadata as well as tokenSuplly
    function mintToken(
        address to,
        uint256 tokenId,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public whenNotPaused {
        bytes32 key = getVerifierKey(a, b, c, input);
        require(
            uniqueSolutions[key].to == address(0),
            "Solution is already used"
        );
        Verifier.Proof memory proof = Verifier.Proof(
            Pairing.G1Point(a[0], a[1]),
            Pairing.G2Point(b[0], b[1]),
            Pairing.G1Point(c[0], c[1])
        );
        require(verifier.verifyTx(proof, input), "Solution is incorrect");
        addSolution(to, tokenId, key);
        super.mint(to, tokenId);
    }
}
