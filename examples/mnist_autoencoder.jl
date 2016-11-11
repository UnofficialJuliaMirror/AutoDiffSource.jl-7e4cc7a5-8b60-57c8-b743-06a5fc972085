# based on http://int8.io/automatic-differentiation-machine-learning-julia/

using MNIST; # if not installed try Pkg.add("MNIST")
using Distributions; # if not installed try Pkg.add("Distributions")
using AutoDiffSource

@δ function autoencoderError(We1, We2 , Wd, b1, b2,  input)
    firstLayer = 1. ./ (1. + exp.(-We1 * input .- b1))
    encodedInput = 1. ./ (1. + exp.(-We2 * firstLayer .- b2))
    reconstructedInput = 1. ./ (1. + exp.(-Wd * encodedInput))
    sum((input .- reconstructedInput).^2)
end

function readInputData()
    a,_ = MNIST.traindata();
    A = a ./ 255;
    return A;
end

function initializeNetworkParams(inputSize, layer1Size, layer2Size, initThetaDist)
    We1 =  rand(initThetaDist, layer1Size, inputSize); b1 = zeros(layer1Size, 1);
    We2 =  rand(initThetaDist, layer2Size, layer1Size); b2 = zeros(layer2Size, 1);
    Wd = rand(initThetaDist, inputSize, layer2Size);
    return (We1, We2, b1, b2, Wd);
end

A = readInputData(); # read input MNIST data
input = A[:,1]; # single input example is needed for AD routine
We1, We2, b1, b2, Wd = initializeNetworkParams(784, 300, 100, Normal(0, .1)); # 784 -> 300 -> 100 -> 784 with weights normally distributed (with small variance)


function trainAutoencoder(epochs, inputData, We1, We2, b1, b2, Wd, alpha)
    for _ in 1:epochs
        for i in 1:size(inputData,2)
            input = A[:,i]
            val, ∇autoencoderError = δautoencoderError(We1, We2, Wd, b1, b2, input);
            if mod(i, 100) == 0
                @show _, i, val
            end
            partialWe1, partialWe2, partialWd, partialB1, partialB2 = ∇autoencoderError();
            We1 = We1 - alpha * partialWe1; b1 = b1 - alpha * partialB1;
            We2 = We2 - alpha * partialWe2; b2 = b2 - alpha * partialB2;
            Wd = Wd - alpha * partialWd;
        end
    end
    return (We1, We2, b1, b2, Wd)
end

@time We1, We2, b1, b2, Wd = trainAutoencoder(4, A,  We1, We2, b1, b2, Wd, 0.02);
