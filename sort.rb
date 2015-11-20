# Contains attributes for a single individual in a population
class Individual
  # The genome for the individual. In this case, a random array with the values from the input
  attr_accessor :genome

  def initialize(genome = [])
    @genome = genome
  end

  # Calculates the fitness score for the individual.
  # This calculates how close the individual is to being sorted by starting
  # from the beginning and removing all values in front that are not in order.
  def fitness
    fitness_check = []
    self.genome.each do |gene|
      # Add the first element to the check, and every subsequent element that is in order.
      if fitness_check.empty? || gene > fitness_check.last
        fitness_check.push(gene)
      end
    end

    # Fitness is the length of the check, which is the number of digits in order from the genome.
    return fitness_check.length
  end
end

# Contains attributes for a population of individuals
class Population
  # The array of individuals
  attr_accessor :individuals

  def initialize
    @individuals = []
  end

  # Adds an individual to the population
  def add(individual)
    @individuals.push(individual)
  end

  # Creates a random population based on the original input array
  def random_population(genes, size)
    size.times do
      @individuals.push(Individual.new(genes.shuffle))
    end
  end

  # Finds the individual with the highest fitness.
  # If there is a tie, the first one found is used.
  def best_individual
    best_fitness = 0
    best_indv = nil
    @individuals.each do |individual|
      if individual.fitness > best_fitness
        best_fitness = individual.fitness
        best_indv = individual
      end
    end

    return best_indv
  end
end

# Main algorithm class
class Algorithm
  # Evolves the population. This creates a new population by moving the individual with the
  # highest fitness score to the new population and mating the individuals from the old population
  # in sequential order. i.e. 1 mates with 2, 2 mates with 3, 3 mates with 4, etc.
  def self.evolve(population, mutation_rate)
    new_population = Population.new

    # Keep the individual with the highest fitness
    new_population.add(population.best_individual)

    population.individuals.each_with_index do |individual, i|
      # Find a random crossover start point
      start_at = rand(0..(individual.genome.length - 1))

      # Find a random crossover end point
      stop_at = rand(start_at..(individual.genome.length - 1))

      # Create offspring with the next individual in the population, unless this is the last individual.
      baby = self.crossover(individual.genome, population.individuals[i + 1].genome, start_at, stop_at) unless i == (population.individuals.length - 1)

      # Add the offspring to the population unless there is none (the last individual)
      new_population.add(baby) unless baby.nil?
    end

    # Mutate the population before finishing
    return mutate(new_population, mutation_rate)
  end

  # Creates offspring from two individuals
  def self.crossover(father, mother, start_index, end_index)
    # A subset of the father based on the start and end indices
    sperm = father[start_index..end_index]

    # Remove the duplicate genes from the mother
    fetus = mother - sperm

    # The offspring is the result of the two parents' genes merging together.
    # It is key that the subset remains at the same index. The remaining genes
    # are filled in by the mothers' genes.
    baby = fetus[0..(start_index - 1)] + sperm
    baby = baby + fetus[start_index..(fetus.length - 1)] if baby.length < father.length
    return Individual.new(baby)
  end

  # Mutates the population based on a given rate. 0 is no mutation, while 1 is 100% mutation.
  def self.mutate(population, rate)
    population.individuals.map! { |individual|
      # Since rand() creates a random float between 0 and 1, the probability that rand()
      # will be less than the rate is equal to the rate itself.
      if rand() < rate
        # Fun Ruby trick to grab two random indices from an array.
        # Create an array from a range of 0 to the length - 1, then shuffle.
        # The first two elements in the new array are your two random indices.
        swap_indices = (0..(individual.genome.length - 1)).to_a.shuffle

        # Swap the genes at the indices determined above.
        individual.genome[swap_indices[0]], individual.genome[swap_indices[1]] = individual.genome[swap_indices[1]], individual.genome[swap_indices[0]]
      end
      individual
    }

    return population
  end

  # Actually runs the algorithm.
  def self.run(input, population_size, mutation_rate, i)
    # Create an array of integers from a comma-delimited string
    gene_array = input.split(",").map { |i| i.to_i }

    # Create a new random population
    population = Population.new
    population.random_population(gene_array, population_size)

    # Start at generation 1. This will increase by 1 each time the population evolves.
    generation = 1

    # Continue to evolve the population until we found our solution (the best fitness is equal to the length of the genome)
    while population.best_individual.fitness < gene_array.length
      #p "Generation: #{generation}"
      population = self.evolve(population, mutation_rate)
      #p "Best fitness: #{population.best_individual.fitness}"
      #puts "\n"
      generation = generation + 1
    end

    # Output the solution to verify it worked
    #p "Solution found!"
    #p population.best_individual
    puts "{ x: #{i}, y: #{generation}},"
  end
end

input = "1,2,3,4,5"
Algorithm.run(input, 10, 0.005, i)
