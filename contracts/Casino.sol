pragma solidity ^0.4.15;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 * @notice This is a softer (in terms of throws) variant of SafeMath:
 *         https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1121
 */
library SafeMath {
  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint128 _a, uint128 _b) internal constant returns (uint128 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }
    c = _a * _b;
    require(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint128 _a, uint128 _b) internal constant returns (uint128) {
    // Solidity automatically throws when dividing by 0
    // therefore require beforehand avoid throw
    require(_b > 0);
    // uint128 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint128 _a, uint128 _b) internal constant returns (uint128) {
    require(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint128 _a, uint128 _b) internal constant returns (uint128 c) {
    c = _a + _b;
    require(c >= _a);
    return c;
  }
}

/// @title Contract to bet AION for a number and win randomly when the number of bets is met.
/// @author Merunas Grincalaitis
/// edited by Kim Codeashian
contract Casino {
  using SafeMath for uint;
  address owner;
  // The minimum bet a user has to make to participate in the game
  uint public minimumBet = 1; // Equal to 1.00 AION
  // The maximum bet a user has to make to participate in the game
  uint public maximumBet = 100; // Equal to 100 AION
  // The total number of bets the users have made
  uint public numberOfBets;
  // The maximum amount of bets can be made for each game
  uint public maxAmountOfBets = 7;
  // The total amount of AION bet for this current game
  uint public totalBet;
  // The total amount of AION paid out (contract paid out)
  uint public totalPaid;
  // The number / animal that won the last game
  uint public lastLuckyAnimal;
  // Array of players in each round
  address[] public players;

  struct Player {
    uint amountBet;
    uint numberSelected;
  }
  // The address of the player and => the user info
  mapping(address => Player) public playerInfo;

  event AnimalChosen(uint value);
  event WinnerTransfer(address to, uint value);

  // Modifier to only allow the execution of functions when the bets are completed
  modifier onEndGame(){
    if(numberOfBets >= maxAmountOfBets) _;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function Casino(){
    owner = msg.sender;
  }

  // Make sure contract has balance > maximumBet so
  // distributePrizes will be able to execute without failure
  function() public payable {}

  // refund all tokens back to owner
  function refund() public onlyOwner {
    uint totalBalance = this.balance;
    owner.transfer(totalBalance);
  }

  function kill() public {
    if(msg.sender == owner) selfdestruct(owner);
   }
  /// @notice Check if a player exists in the current game
  /// @param player The address of the player to check
  /// @return bool Returns true is it exists or false if it doesn't
  function checkPlayerExists(address player) public constant returns(bool){
    for(uint i = 0; i < players.length; i++){
      if(players[i] == player) return true;
    }
    return false;
 }

  /// @notice To bet for a number by sending AION
  /// @param numberSelected The number that the player wants to bet for. Must be between 1 and 10 both inclusive
  function bet(uint numberSelected) payable {
    // Check that the max amount of bets hasn't been met yet
    require(numberOfBets <= maxAmountOfBets);

    // Check that the number to bet is within the range
    require(numberSelected >= 1 && numberSelected <= 10);

    // Check that the player doesn't exists
    require(checkPlayerExists(msg.sender) == false);

    // Check that the amount paid is bigger or equal the minimum bet
    require(msg.value >= minimumBet);

    playerInfo[msg.sender].amountBet = msg.value;
    playerInfo[msg.sender].numberSelected = numberSelected;
    numberOfBets++;
    players.push(msg.sender);
    totalBet += msg.value;

    if(numberOfBets >= maxAmountOfBets) generateNumberWinner();
  }

  /// @notice Generates a random number between 1 and 10 both inclusive.
  /// Can only be executed when the game ends.
  function generateNumberWinner() private onEndGame {
    uint numberGenerated = block.number % 10 + 1; // This isn't secure
    lastLuckyAnimal = numberGenerated;
    distributePrizes();

    AnimalChosen(lastLuckyAnimal);
  }

  /// @notice Sends the corresponding AION to each winner then deletes all the
  /// players for the next game and resets the `totalBet` and `numberOfBets`
  function distributePrizes() private onEndGame {
    address[100] memory winners; // We have to create a temporary in memory array with fixed size
    uint count = 0; // Winner count
    uint winnerBetPool = 0; // Total Winner Bet Pool

    // Store winners in array, and tally winner bet pool
    for(uint i = 0; i < players.length; i++){
      address playerAddress = players[i];
      if(playerInfo[playerAddress].numberSelected == lastLuckyAnimal){
        winners[count] = playerAddress;
        winnerBetPool += playerInfo[playerAddress].amountBet;
        count++;
      }
    }

    if (count > 0){
      uint winnerAIONAmount = totalBet / count; // How much each winner gets
      for(uint j = 0; j < count; j++){
        if(winners[j] != address(0)) // Check that the address in this fixed array is not empty
        address playerAddressW = winners[j]; // Grab winning addresses
        uint winnerAIONAmount = SafeMath.div(SafeMath.mul(totalBet, playerInfo[playerAddressW].amountBet), winnerBetPool);
        winners[j].transfer(winnerAIONAmount); // Calculate winner proportions of the prize pool

        totalPaid += winnerAIONAmount; // Add to Total Payout
        WinnerTransfer(winners[j], winnerAIONAmount);
      }
      totalBet = 0; // Clear total bets, if no winner - totalBets get rolled over
    }

    players.length = 0; // Delete all the players array
    numberOfBets = 0;   // Reset number of bets
    numberRound++;   // Increase Round Number
  }
}
