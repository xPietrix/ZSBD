import java.util.concurrent.ThreadLocalRandom;


public class Neuron 
{
	public int[] input;
	public double[] weights;
	
	public Neuron(int[] input, int layerSize)
	{
		this.input = input;
		this.weights = new double[layerSize];
		
		for(int i = 0; i < layerSize; i++)
		{
			weights[i] = ThreadLocalRandom.current().nextDouble(-1, 1);
		}
	}
	
	public double sum()
	{
		double sum = 0;
		for(int i = 0; i < this.input.length; i++)
		{
			sum = sum + this.input[i]*this.weights[i];
		}
		return sum;
	}
	
	public double activationFunction(double sum)
	{
		double result = 1 / (1 + Math.pow(Math.E, - sum));
		return result;
	}
}
