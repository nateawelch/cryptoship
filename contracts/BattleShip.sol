pragma solidity 0.4.23;


contract BattleShip is Ownable {
  uint8[6] private shipLengths = [0, 5, 4, 3, 3, 2];
  uint32 public constant MAX_TURN_TIME=12*60*4 //12 hours
  uint32 public constant DEPOSIT_DENOMINATOR = 2;
  uint32 public constant FEE_DENOMINATOR=25;
  uint128 public feePool;

  event GameCreated(address maker, uint128 bet, uint32 gameID);
  event GameCommitted(address taker, uint32 gameID);
  event GameCancelled(address maker, uint32 gameID);
  event Shot(uint32 gameID, uint16 location, bool turn)

  struct Player {
    address address;
    bytes32 rootHash;
    uint104 shots;
    uint104 hits;
    uint16 lastShot;
  }

  struct Game {
    uint96 betAmount;
    uint32 lastActionBlockNumber;
    uint8 currentTurn;
    mapping(uint => Player) players;
  }

  Game[] public gameList;

  function createGame(bytes32 rootHash) public payable {
    require(rootHash != 0x0); // Must have a root hash
    Game memory game = new Game(msg.value, block.number, false);
    game.players[0] = new Player(rootHash, 0, 0, 0);
    gameList.push(game);
  }

  function joinGame(uint32 gameID, bytes32 rootHash, uint8 shotLocation) public {
    Game storage game = gameList[gameID];      // Will fail if gameID is larger than array
    require(msg.value == game.betAmount);      // Amount is correct - 50% is security deposit,
                                               //   2% is game fee, 48% is bet amount
    require(game.players[0].address != 0x0);         // Game isn't started
    require(shotLocation < 100);               // Shot is valid
    feePool += msg.value/FEE_DENOMINATOR;
    game.lastTakeShot = shotLocation;
    game.currentTurn = true;
    game.rootHash = rootHash;
  }

  function cancelGame(uint32 gameID) public {
    Game storage game = gameList[gameID];
    require(game.players[0].rootHash != 0x0 && game.lastActionBlockNumber = 0);

    msg.sender.transfer(game.betAmount);
  }

  function makeShot(uint32 gameID, bytes32[9] proofOfLastShot, uint8 shotLocation) public {
    Game memory game = gameList[gameID];
    require(game.currentTurn == (msg.sender == game.makerAddress ? true : false));
    require(shotLocation < 100);
    require(isProofValid(proofOfLastShot));
    uint x;
    uint y;
    uint ship;
    (x, y, ship,) = unpackCell(proofOfLastShot[1]);
    if (game.currentTurn) {
      require(game.makerAddress == msg.sender);
      require()
    } else {
      require(game.takerAddress == msg.sender);

    }
  }

  function isProofValid(bytes32[9] proofOfLastShot, bytes32 rootHash) public view returns(bool) {
    return rootHash == generateMerkleRootOfProof(proofOfLastShot);
  }

  function isMapValid(uint256[10][10] seeds, uint16[10][10] cells, bytes32 rootHash) public view returns (bool) {
    bytes32[256] memory dataList;
    bool[5][6] memory subsectionsFound;
    for (uint8 yIndex = 0; yIndex < 10; yIndex++) {
      for (uint8 xIndex = 0; xIndex < 10; xIndex++) {
        dataList[(yIndex*10+xIndex)*2] = (seeds[yIndex][xIndex]);
        dataList[(yIndex*10+xIndex)*2+1] = (cells[yIndex][xIndex]);
        uint x;
        uint y;
        uint ship;
        uint subsection;
        (x, y, ship, subsection) = unpackCell(cells[yIndex][xIndex]);
        if (ship == 0) {
          continue;
        }
        if (ship > 5 || subsectionsFound[ship][subsection]
          || subsection >= shipLengths[ship]) {
          return false;
        }
        if (subsection == 0 && !testShipConnectivity(cells, int16(xIndex), int16(yIndex))) {
          return false;
        }
        subsectionsFound[ship][subsection] = true;
      }
    }
    if (!doAllSubsectionsExist(subsectionsFound) || generateMerkleRoot(hasheddCells) != rootHash) {
      return false;
    }
    return true;
  }

  function checkDirection(uint16[10][10] cells,
    int16 x,
    int16 y,
    int16 xMove,
    int16 yMove) public view returns (bool) {
    uint ship;
    (, , ship,) = unpackCell(cells[uint(y)][uint(x)]);
    if (x+1+xMove*shipLengths[ship] >= 0 && x-1+xMove*shipLengths[ship] <= 9 &&
      y+1+yMove*shipLengths[ship] >= 0 && y-1+yMove*shipLengths[ship] <= 9) {
      uint8 currentLength = 1;
      uint newShip;
      uint newSubsection;
      (, , newShip, newSubsection) = unpackCell(cells[uint(y+yMove)][uint(x+xMove)]);
      x += xMove;
      y += yMove;
      if (ship == newShip && newSubsection == 1) {
        currentLength = 2;
        while (currentLength < shipLengths[ship]) {
          (, , newShip, newSubsection) = unpackCell(cells[uint(y+yMove)][uint(x+xMove)]);
          if (newShip == ship && newSubsection == currentLength) {
            currentLength++;
          } else {
            return false;
          }
          x += xMove;
          y += yMove;
        }
        return true;
      }

    }
    return false;
  }

  function testShipConnectivity(uint16[10][10] cells, int16 x, int16 y) public view returns (bool) {
    return checkDirection(cells, x, y, -1, 0)
    || checkDirection(cells, x, y, 1, 0)
    || checkDirection(cells, x, y, 0, -1)
    || checkDirection(cells, x, y, 0, 1);
  }

  function doAllSubsectionsExist(bool[5][6] subsectionsFound) public view returns (bool) {
    for (uint8 shipIndex = 1; shipIndex < 6; shipIndex++) {
      for (uint8 subsectionIndex = 0; subsectionIndex < shipLengths[shipIndex]; subsectionIndex++) {
        if (!subsectionsFound[shipIndex][subsectionIndex]) {
          return false;
        }
      }
    }
    return true;
  }

  function generateMerkleRootOfProof(bytes32[9] memory proof) public pure returns (bytes32 rootHash) {
    for (uint index = 1; index < 9; index++) {
      if (proof[0] > proof[index]) {
        proof[0] = keccak256(proof[0], proof[index]);
      } else {
        proof[0] = keccak256(proof[index], proof[0]);
      }
    }
    return proof[0];
  }

  function generateMerkleRoot(bytes32[] memory hashedCells) public pure returns (bytes32 rootHash) {
    for (uint length=256; length > 1; length /= 2) {
      for (uint index=0; index < length-1; index += 2) {
        if (hashedCells[index] > hashedCells[index]) {
          hashedCells[index/2] = keccak256(hashedCells[index], hashedCells[index+1]);
        } else {
          hashedCells[index/2] = keccak256(hashedCells[index+1], hashedCells[index]);
        }
      }
    }
    return hashedCells[0];
  }

  uint8 private constant FOUR_DIGITS = 1+2+4+8;

  function unpackCell(uint16 cell) public pure returns (uint8 x, uint8 y, uint8 ship, uint8 subsection) {
    x = uint8((cell >> 12) & FOUR_DIGITS);
    y = uint8((cell >> 8) & FOUR_DIGITS);
    ship = uint8((cell >> 4) & FOUR_DIGITS);
    subsection = uint8(cell & FOUR_DIGITS);
    return (x, y, ship, subsection);
  }
}
