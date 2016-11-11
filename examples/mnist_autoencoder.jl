# based on http://int8.io/automatic-differentiation-machine-learning-julia/

using MNIST # if not installed try Pkg.add("MNIST")
using Distributions # if not installed try Pkg.add("Distributions")
using AutoDiffSource # if not installed try Pkg.add("AutoDiffSource")

@δ function sigmoid(x)
    t = exp.(-x)
    1 ./ (1 + t)
end

@δ sum_sigmoid(x) = sum(sigmoid(x))
@assert checkdiff(sum_sigmoid, δsum_sigmoid, randn(10))

@δ function autoencoderError(We1, We2 , Wd, b1, b2,  input)
    firstLayer = sigmoid(We1 * input .+ b1)
    encodedInput = sigmoid(We2 * firstLayer .+ b2)
    reconstructedInput = sigmoid(Wd * encodedInput)
    sum((input .- reconstructedInput).^2)
end
@assert checkdiff(autoencoderError, δautoencoderError, randn(3,3), randn(3,3), rand(3,3), randn(3), randn(3), randn(3))

function initializeNetworkParams(inputSize, layer1Size, layer2Size, initThetaDist)
    We1 =  rand(initThetaDist, layer1Size, inputSize)
    b1 = zeros(layer1Size, 1)
    We2 =  rand(initThetaDist, layer2Size, layer1Size)
    b2 = zeros(layer2Size, 1)
    Wd = rand(initThetaDist, inputSize, layer2Size)
    return (We1, We2, b1, b2, Wd)
end

function trainAutoencoder(epochs, inputData, We1, We2, b1, b2, Wd, alpha)
    for _ in 1:epochs
        for i in 1:size(inputData,2)
            input = A[:,i]
            val, ∇autoencoderError = δautoencoderError(We1, We2, Wd, b1, b2, input);
            if mod(i, 100) == 0
                @show _, i, val
            end
            ∂We1, ∂We2, ∂Wd, ∂B1, ∂B2 = ∇autoencoderError()
            We1 = We1 - alpha * ∂We1
            b1 = b1 - alpha * ∂B1
            We2 = We2 - alpha * ∂We2
            b2 = b2 - alpha * ∂B2
            Wd = Wd - alpha * ∂Wd
        end
    end
    return (We1, We2, b1, b2, Wd)
end

# read input MNIST data
A = MNIST.traindata()[1] ./ 255

# 784 -> 300 -> 100 -> 784 with weights normally distributed (with small variance)
We1, We2, b1, b2, Wd = initializeNetworkParams(784, 300, 100, Normal(0, .1))

# 4 epochs with alpha = 0.02
@time We1, We2, b1, b2, Wd = trainAutoencoder(4, A,  We1, We2, b1, b2, Wd, 0.02);
