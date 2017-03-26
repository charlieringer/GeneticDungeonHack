/**
 * Created by Charlie on 25/03/2017.
 */
import java.util.ArrayList;
import java.util.Random;

public class Room {
    ArrayList<Room> children = new ArrayList<Room>();
    Room parent;
    Random gen = new Random();
    boolean isGoalRoom;
    int numbEnemies = 0;
    boolean hasLoot;
    int depth;

    Room()
    {

    }

    Room(Room _parent, double spawnRate, double spawnDecay, int _depth)
    {
        depth = _depth;
        parent = _parent;
        double total = gen.nextDouble();
        int counter = 0;
        while(total < spawnRate)
        {
            if (++counter > 4) return;
            total+=gen.nextDouble();
            children.add(new Room(this, spawnRate-spawnDecay, spawnDecay, depth+1));
        }
    }

    Room(Room _parent, ArrayList<Room> newChildren, boolean _isGoalRoom, int _numbEnemies, boolean _hasLoot)
    {
        parent = _parent;
        children = newChildren;
        isGoalRoom = _isGoalRoom;
        numbEnemies = _numbEnemies;
        hasLoot = _hasLoot;
    }

    boolean hasChild()
    {
        return children.size() > 0;
    }

    Room selectNextRoom()
    {
        int roomIndx = gen.nextInt(children.size());
        return children.get(roomIndx);
    }

    void populate(double percentMobChance, double percentLootChance)
    {
        for(int i = 0; i < children.size(); i++)
        {
            children.get(i).populate(percentMobChance, percentLootChance);
        }
        float randNumb = gen.nextFloat();
        if(randNumb < percentLootChance)
        {
            hasLoot = true;
        } else if(randNumb < percentLootChance+percentMobChance)
        {
          numbEnemies = 1;
        }
    }

    Room copy(Room parent)
    {
        Room copy = new Room();

        ArrayList<Room> newChildren = new ArrayList<Room>();
        for(int i = 0; i < children.size(); i++)
        {
            newChildren.add(children.get(i).copy(copy));
        }

        copy.parent = parent;
        copy.children = newChildren;
        copy.isGoalRoom = isGoalRoom;
        copy.numbEnemies = numbEnemies;
        copy.hasLoot = hasLoot;

        return copy;

    }
    
    void draw(int x, int y, int gridSize, ArrayList<int[]> usedLocations)
    {
      if(isGoalRoom)fill(0, 255, 0);
      else if(numbEnemies >0)fill(255,0,0);
      else if(hasLoot) fill(255,255,0);
      else fill(128);
      rect(x,y,gridSize,gridSize);
      
      float gridSection = gridSize+gridSize/2;
      
      for(int i = 0; i < children.size(); i++)
      {
        int cX = (int)(i*gridSection);
        int cY = (int)(y+(gridSection*2));
        
        boolean locationFound = false;
        
        while(!locationFound)
        {
          for(int j = 0; j < usedLocations.size(); j++)
          {
            int[] location = usedLocations.get(j);
            if(cX == location[0] && cY == location[1])
            {
              cX+=gridSection;
              continue;
            }
          }
          locationFound = true;
        }
        usedLocations.add(new int[] {cX, cY});
        strokeWeight(gridSize/3);
        line(x+(gridSize/2),y+gridSize,(int)(cX + gridSize/2), (cY));
        strokeWeight(1);
        children.get(i).draw(cX, cY, gridSize, usedLocations);
      }
      
    }
}