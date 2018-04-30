
public class MultiLayerPerceptron 
{
	int []inputs;
	int numberOfLayers;
	int []outputs;
	
	public static void main(String[] args) 
	{
		int input[] = new int[4];
		input[0] = 1;
		input[1] = 0;
		input[2] = 0;
		input[3] = 0;
		
		int output[] = new int[4];
		output[0] = 1;
		output[1] = 0;
		output[2] = 0;
		output[3] = 0;
		int number = 1;
		MultiLayerPerceptron MLP = new MultiLayerPerceptron(input, number, output);
		
		Layer[] layers = new Layer[MLP.numberOfLayers];
		for(int i = 0; i < layers.length; i++)
		{
			layers[i] = new Layer(input, 4);
		}
		
		for(int i = 0; i < layers.length; i++)
		{
			for (int j = 0; j < layers[i].neurons.length; j++)
			{
				System.out.println("Sum in neuron: " + j + " " + layers[i].neurons[j].sum());
			}
			System.out.println();
		}
	}
	
	public MultiLayerPerceptron(int []inputs, int numberOfLayers, int []outputs)
	{
		this.inputs = inputs;
		this.numberOfLayers = numberOfLayers;
		this.outputs = outputs;
	}
}
