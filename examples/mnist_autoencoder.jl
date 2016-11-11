# based on http://int8.io/automatic-differentiation-machine-learning-julia/

using MNIST # if not installed try Pkg.add("MNIST")
using AutoDiffSource # if not installed try Pkg.add("AutoDiffSource")
using PyPlot # if not installed try Pkg.add("PyPlot")

@δ function sigmoid(x)
    t = exp.(-x)
    1 ./ (1 + t)
end
@δ sum_sigmoid(x) = sum(sigmoid(x))
@assert checkdiff(sum_sigmoid, δsum_sigmoid, randn(10))

@δ function autoencoder(We1, We2 , Wd, b1, b2,  input)
    firstLayer = sigmoid(We1 * input .+ b1)
    encodedInput = sigmoid(We2 * firstLayer .+ b2)
    reconstructedInput = sigmoid(Wd * encodedInput)
end

@δ function autoencoderError(We1, We2 , Wd, b1, b2,  input)
    reconstructedInput = autoencoder(We1, We2 , Wd, b1, b2,  input)
    sum((input .- reconstructedInput).^2)
end
@assert checkdiff(autoencoderError, δautoencoderError, randn(3,3), randn(3,3), rand(3,3), randn(3), randn(3), randn(3))

function initializeNetworkParams(inputSize, layer1Size, layer2Size)
    We1 =  0.1 * randn(layer1Size, inputSize)
    b1 = zeros(layer1Size, 1)
    We2 =  0.1 * randn(layer2Size, layer1Size)
    b2 = zeros(layer2Size, 1)
    Wd = 0.1 * randn(inputSize, layer2Size)
    return (We1, We2, b1, b2, Wd)
end

function trainAutoencoder(epochs, inputData, We1, We2, b1, b2, Wd, alpha)
    for k in 1:epochs
        total_error = 0.
        for i in 1:size(inputData,2)
            input = inputData[:,i]
            val, ∇autoencoderError = δautoencoderError(We1, We2, Wd, b1, b2, input)
            total_error += val
            if mod(i, 1000) == 0
                @printf("epoch=%d iter=%d error=%f\n", k, i, total_error)
                input = inputData[:, rand(1:size(inputData, 2))]
                reconstructedInput = autoencoder(We1, We2 , Wd, b1, b2,  input)
                clf()
                subplot(211)
                title("input")
                pcolor(reshape(input, 28, 28); cmap="Greys")
                subplot(212)
                title("reconstructed")
                pcolor(reshape(reconstructedInput, 28, 28); cmap="Greys")
                total_error = 0.
            end
            ∂We1, ∂We2, ∂Wd, ∂b1, ∂b2 = ∇autoencoderError()
            We1 = We1 - alpha * ∂We1
            b1 = b1 - alpha * ∂b1
            We2 = We2 - alpha * ∂We2
            b2 = b2 - alpha * ∂b2
            Wd = Wd - alpha * ∂Wd
        end
    end
    return (We1, We2, b1, b2, Wd)
end

# read input MNIST data
A = MNIST.traindata()[1] ./ 255

# 784 -> 300 -> 100 -> 784 with weights normally distributed (with small variance)
We1, We2, b1, b2, Wd = initializeNetworkParams(784, 300, 100)

# 4 epochs with alpha = 0.02
@time We1, We2, b1, b2, Wd = trainAutoencoder(4, A,  We1, We2, b1, b2, Wd, 0.02);
