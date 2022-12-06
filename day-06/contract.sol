// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract Contract {
    function solve(string memory input, uint size) public pure returns (uint) {
        bytes memory input_bytes = bytes(input);
        bytes memory slice_bytes = new bytes(size);
        uint moves = 0;
        for (uint i = 0; i < slice_bytes.length; i++) {
            slice_bytes[i] = input_bytes[i];
            for (uint j = 0; j < i; j++) {
                if (slice_bytes[i] == slice_bytes[j]) {
                    moves = j + 1 > moves ? j + 1 : moves;
                }
            }
        }
        for (uint i = slice_bytes.length; i < input_bytes.length; i++) {
            moves--;
            for (uint j = 1; j < slice_bytes.length; j++) {
                if (input_bytes[i] == slice_bytes[j]) {
                    moves = j > moves ? j : moves;
                }
            }
            if (moves == 0) {
                return i + 1;
            }
            for (uint j = 1; j < slice_bytes.length; j++) {
                slice_bytes[j - 1] = slice_bytes[j];
            }
            slice_bytes[slice_bytes.length - 1] = input_bytes[i];
        }
        return 0;
    }
}