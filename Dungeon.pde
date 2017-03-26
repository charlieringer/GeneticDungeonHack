/**
 * Created by Charlie on 25/03/2017.
 */

import java.util.Random;
import java.util.ArrayList;


class Dungeon
{
  float fitness;
  Room startRoom;
  int simulations = 100;

  Random gen = new Random();

  Dungeon()
  {
    startRoom = new Room(null, 1.0, 0.1, 0 );
    populateDungeon();
    evaluate();
  }

  Dungeon(float _fitness, Room _startRoom)
  {
    startRoom = _startRoom;
    fitness = _fitness;
  }

  void populateDungeon()
  {
    startRoom.populate(0.5, 0.2);

    //Generate a random goal node
    Room currRoom = startRoom;
    int count = 0;
    while (currRoom.hasChild())
    {
      if (++count > 1000) System.out.println("Error in population");
      currRoom = currRoom.selectNextRoom();
    }
    currRoom.isGoalRoom = true;
  }

  void evaluate() { 
    int minRoomsVisited = -1;
    int minEnemiesEncountered = -1;

    int maxRoomsVisited = -1;
    int maxEnemiesEncountered = -1;

    int totRoomsVisited = 0;
    int totEnemiesEncountered = 0;
    int totLootFound = 0;
    int totDepth = 0;
    int totChildren = 0;

    for (int i = 0; i < simulations; i++) {
      Room currentRoom = startRoom;
      ArrayList<Room> visited = new ArrayList<Room>();
      int count = 0;
      int roomsVisited = 0;
      int enemiesEncountered = 0;
      int lootFound = 0;

      while (currentRoom != null && !currentRoom.isGoalRoom) {
        if (++count > 1000) break;//System.out.println("Error in eval");
        roomsVisited++;
        enemiesEncountered += currentRoom.numbEnemies;
        if (currentRoom.hasLoot)lootFound++;
        visited.add(currentRoom);
        totChildren += currentRoom.children.size();
        currentRoom = getNextRoom(currentRoom, visited);
      }
      if (currentRoom!= null) totDepth += currentRoom.depth;
      if (minRoomsVisited == -1 || minRoomsVisited > roomsVisited) minRoomsVisited = roomsVisited;
      if (maxRoomsVisited == -1 || maxRoomsVisited < roomsVisited) maxRoomsVisited = roomsVisited;

      if (minEnemiesEncountered == -1 || minEnemiesEncountered > enemiesEncountered) minEnemiesEncountered = enemiesEncountered;
      if (maxEnemiesEncountered == -1 || maxEnemiesEncountered < enemiesEncountered) maxEnemiesEncountered = enemiesEncountered;

      totRoomsVisited +=roomsVisited;
      totEnemiesEncountered +=enemiesEncountered;
      totLootFound +=lootFound;
    }
    float roomVarience = minRoomsVisited-maxRoomsVisited;
    float mobVarience = minEnemiesEncountered-maxEnemiesEncountered;

    float roomAVG = totRoomsVisited/simulations;
    float mobAVG = totEnemiesEncountered/simulations;
    float lootAVG = totLootFound/simulations;

    float childAVG = (totRoomsVisited > 0) ? totChildren/totRoomsVisited : 0;

    float depthAVG = totDepth/simulations;

    //fitness = roomVarience+mobVarience+roomAVG+mobAVG+lootAVG;
    fitness = roomAVG+mobAVG+lootAVG+depthAVG+childAVG-roomVarience-mobVarience;
  }

  float sig(float x)
  {
    return 1.0/(1.0+exp(-x));
  }

  Room getNextRoom(Room current, ArrayList<Room> visited)
  {
    ArrayList<Room> potentialRooms = new ArrayList<Room>();

    for (int j = 0; j < current.children.size(); j ++)
    {
      if (!visited.contains(current.children.get(j))) potentialRooms.add(current.children.get(j));
    }
    if (potentialRooms.size() > 0) return potentialRooms.get(gen.nextInt(potentialRooms.size()));
    if (current.parent != null) return getNextRoom(current.parent, visited);
    return null;
  }

  Dungeon crossover(Dungeon other)
  {
    ArrayList<Room> theseNodes = new ArrayList<Room>();
    getNodesFrom(startRoom, theseNodes);

    ArrayList<Room> thoseNodes = new ArrayList<Room>();
    getNodesFrom(other.startRoom, thoseNodes);

    int crossOverThis = gen.nextInt(theseNodes.size());
    int crossOverThat = gen.nextInt(thoseNodes.size());

    theseNodes.get(crossOverThis).children = thoseNodes.get(crossOverThat). children;

    if ( !hasGoal(startRoom))
    {        
      //Generate a random goal node
      Room currRoom = startRoom;
      int count = 0;
      while (currRoom.hasChild())
      {
        if (++count > 1000) System.out.println("Error in population");
        currRoom = currRoom.selectNextRoom();
      }
      currRoom.isGoalRoom = true;
    }
    return this;
  }

  void getNodesFrom(Room start, ArrayList<Room> list)
  {
    list.add(start);
    for (int i = 0; i < start.children.size(); i++)
    {
      getNodesFrom(start.children.get(i), list);
    }
  }

  void mutate(float rate, Room room)
  {
    if (gen.nextFloat() < rate) {
      for (int i = 0; i < room.children.size(); i++)
      {
        room.children.set(i, new Room(room, 1.0, 0.1, 0 ));
      }
    }

    for (int i = 0; i < room.children.size(); i++)
    {
      mutate(rate, room.children.get(i));
    }
    if ( !hasGoal(startRoom))
    {        
      //Generate a random goal node
      Room currRoom = startRoom;
      int count = 0;
      while (currRoom.hasChild())
      {
        if (++count > 1000) System.out.println("Error in population");
        currRoom = currRoom.selectNextRoom();
      }
      currRoom.isGoalRoom = true;
    }
  }

  Dungeon copy()
  {
    float newFitness = fitness;
    Room newStart = startRoom.copy(null);
    return new Dungeon(newFitness, newStart);
  }

  boolean hasGoal(Room thisRoom)
  {
    if (thisRoom.isGoalRoom) return true;
    boolean childHasGoal = false;
    for (int i = 0; i < thisRoom.children.size(); i++)
    {
      if (hasGoal(thisRoom.children.get(i))) childHasGoal = true;
    }
    return childHasGoal;
  }
}