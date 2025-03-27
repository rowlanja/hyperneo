library Path {
    /// @dev The length the bytes encoded address
    uint256 private constant ADDR_SIZE = 20;
    /// @dev The length the bytes encoded tick spacing
    uint256 private constant TICKSPACING_SIZE = 3;

    /// @dev The offset of a single token address + tick spacing
    uint256 private constant NEXT_OFFSET = ADDR_SIZE + TICKSPACING_SIZE;
    /// @dev The offset of an encoded pool key (tokenIn + tick spacing + tokenOut)
    uint256 private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
    /// @dev The minimum length of a path that contains 2 or more pools;
    uint256 private constant MULTIPLE_POOLS_MIN_LENGTH =
        POP_OFFSET + NEXT_OFFSET;

    function hasMultiplePools(bytes memory path) internal pure returns (bool) {
        return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
    }

    function getFirstPool(bytes memory path)
        internal
        pure
        returns (bytes memory)
    {
        return path.slice(0, POP_OFFSET);
    }

    function skipToken(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(NEXT_OFFSET, path.length - NEXT_OFFSET);
    } 

}