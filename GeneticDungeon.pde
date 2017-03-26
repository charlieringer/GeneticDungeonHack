import java.util.Random;

/**
 * Created by Charlie on 25/03/2017.
 */
public class GeneticDungeon {
  Dungeon[] population = new Dungeon[50];

  GeneticDungeon()
  {
    for (int i = 0; i < population.length; i++) {
      population[i] = new Dungeon();
    }
  }
  public  void run() {

    population = generateChildren(population, 0.5f, 0.1f);
    population = sortPopulation(population);
    System.out.println("Population: ");
    System.out.println(population[0].fitness);
  }

  public Dungeon[] generateChildren(Dungeon[] population, float selectionPercent, float mutationRate)
  {
    int selectionThreshold = (int)(population.length*selectionPercent);
    Random gen = new Random();
    Dungeon[] next = new Dungeon[population.length];
    Dungeon[] sorted = sortPopulation(population);

    //selection
    int[] selected = new int[selectionThreshold];
    for (int i = 0; i < selectionThreshold; i++)
    {
      int totalFitness = 0;
      for (int j = 0; j < sorted.length; j++) if (sorted[j] != null)
      {
        totalFitness += (int)sorted[j].fitness;
        println("Fitness loop: " + j + " fitness: " + sorted[j].fitness);
      }
      int randomPoint = (totalFitness > 0) ? gen.nextInt(totalFitness) : 0;
      println("loop: " + i +  "totfit: " + totalFitness + " randpoint " + randomPoint);
      int count = 0;

      boolean added = false;
      for (int j = 0; j < sorted.length; j++)
      {
        if (sorted[j] != null)
        {
          count+=(int)sorted[j].fitness;
          if (count >=  randomPoint)
          {
            next[i] = sorted[j].copy();
            sorted[j] = null;
            added = true;
            break;
          }
        }
      }
      if(!added) println("oops");

      //next[i] = sorted[i];
    }

    //crossover
    for (int i = selectionThreshold; i < next.length; i++ )
    {
      int indxA = gen.nextInt(selectionThreshold);
      int indxB = gen.nextInt(selectionThreshold);
      Dungeon a = next[indxA].copy();
      Dungeon b = next[indxB].copy();

      next[i] = a.crossover(b);
      next[i].evaluate();
    }

    //mutation
    for (int i = 0; i < next.length; i++ ) {
      if (gen.nextFloat() < mutationRate)
      {
        next[i].mutate(0.000001, next[i].startRoom);
      }
    }
    return  next;
  }

  public Dungeon[] sortPopulation(Dungeon[] population)
  {
    Dungeon[] sorted = new Dungeon[population.length];
    for (int i = 0; i < population.length; i++)
    {
      int bestIndex = -1;
      float bestFitness = -1.0f;
      for (int j = 0; j < population.length; j++)
      {
        if (population[j] != null && population[j].fitness > bestFitness)
        {
          bestFitness = population[j].fitness;
          bestIndex = j;
        }
      }
      sorted[i] = population[bestIndex];
      population[bestIndex] = null;
    }
    return sorted;
  }

  void drawBest(int gridSize)
  {
    population[0].startRoom.draw(0, 0, gridSize, new ArrayList<int[]>());
    fill(255);
    text(population[0].fitness, gridSize*2, gridSize/2);
  }
}