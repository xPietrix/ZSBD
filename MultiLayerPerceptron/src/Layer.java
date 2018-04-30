
public class Layer 
{
	public Neuron []neurons;
	public int lenght;
	public int[] values;
	
	public Layer(int[] input, int lenght)
	{
		this.lenght = lenght;
		this.neurons = new Neuron[lenght];
		
		for(int i = 0; i < lenght; i++)
		{
			neurons[i] = new Neuron(input, lenght);
		}
	}
}
