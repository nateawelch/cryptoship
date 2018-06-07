const expect = require('expect');
const bn = require('bignumber.js');
const utils = require('../utils/mapUtils.js');

const BattleShip = artifacts.require('./BattleShip.sol');


function gas(msg, tx) {
  console.log(msg, tx.receipt.gasUsed);
}

contract("BattleShip.sol", (accounts) => {

  describe("Basics", (mapUtils) => {
    var battleship;

    beforeEach(async () => {
      battleship = await BattleShip.new();
    })

    it('should pass with correct direction', async () => {
      var cells = utils.createMap([[[0,0],[0,0],[0,0],[3,2],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]],
                 [[0,0],[0,0],[0,0],[3,1],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]],
                 [[0,0],[4,0],[0,0],[3,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]],
                 [[0,0],[4,1],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]],
                 [[0,0],[4,2],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[1,0],[0,0]],
                 [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[1,1],[0,0]],
                 [[0,0],[5,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[1,2],[0,0]],
                 [[0,0],[5,1],[0,0],[2,3],[2,2],[2,1],[2,0],[0,0],[1,3],[0,0]],
                 [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[1,4],[0,0]],
                 [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]]]);

    });

    it('should generate merkle root of ', async () => {
      var cells = utils.createMap(
                [[[0,0],[0,0],[0,0],[3,2],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]],
                 [[0,0],[4,2],[0,0],[3,1],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]],
                 [[0,0],[4,1],[0,0],[3,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]],
                 [[0,0],[4,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]],
                 [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[1,0],[0,0]],
                 [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[1,1],[0,0]],
                 [[0,0],[5,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[1,2],[0,0]],
                 [[0,0],[5,1],[0,0],[2,3],[2,2],[2,1],[2,0],[0,0],[1,3],[0,0]],
                 [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[1,4],[0,0]],
                 [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]]]);
      var seeds = utils.getRandMap();
      var isMapValid = await battleship.isMapValid(seeds, cells);
      console.log(isMapValid);
      expect(isMapValid).toBe(true);
    })

  })
})