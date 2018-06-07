var web3 = require('web3');
function createMap(map){
  for(var y = 0; y < 10; y++){
    for(var x = 0; x < 10; x++){
      map[y][x]=(x<<12) + (y<<8)+(map[y][x][0]<<4) + (map[y][x][1]);
    }
  }
  return map;
}

var savedSeed = '0x0';
function generateRands(seed=savedSeed){
  savedSeed = web3.utils.sha3(seed);
  return savedSeed;
}

function getRandMap(){
  var map = [[],[],[],[],[],[],[],[],[],[]];
  for(var y = 0; y < 10; y++){
    for(var x = 0; x < 10; x++){
      map[y].push(generateRands());
    }
  }
  return map;
}
module.exports = {createMap: createMap, rand: generateRands, getRandMap: getRandMap};
