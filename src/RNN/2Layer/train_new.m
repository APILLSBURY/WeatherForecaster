% TODO - erroar
% Trains for a specified output feature
function [Winput, Winterior, Wprev1, Wprev2, Woutput, error] = train(X, outputs)
    if (strcmp(outputs, 'temp') == 1)
        % Only train against the 2nd column of the outputs
        Y = X(2:size(X), 2);
    else
        Y = X(2:size(X), :);
    end

    X = X(1:size(X)-1, :);
    num_neurons  = 30;
    X = [ones(size(X,1), 1) X]; % Add bias feature

    Winput = initWeights(size(X, 2), num_neurons,-1/10, 1/10); % Create a d + 1 x n matrix for the extra bias feature
    Winterior = initWeights(num_neurons, num_neurons,-1/10, 1/10);
    Wprev1 = initWeights(num_neurons, num_neurons,-1/10, 1/10);
    Wprev2 = initWeights(num_neurons, num_neurons,-1/10, 1/10);
    Woutput = initWeights(num_neurons, size(Y,2), -1/2, 1/2);
    
    iter = 1;
    batch_size = 10000;
    max_iters = batch_size*10;
    lambda = 0.0000000000000000000001;
    error = zeros(floor(max_iters/batch_size), 1);
    while (iter <= max_iters)
        Uinput = zeros(size(Winput));
        Uinterior = zeros(size(Winterior));
        Uprev1 = zeros(size(Wprev1));
        Uprev2 = zeros(size(Wprev2));
        Uoutput = zeros(size(Woutput));
        tmp_error = 0;
        for b=1:batch_size
            i = mod(iter, size(X, 1) - 12) + 1;

            %Forward pass through the network with a sequence of training data
            [Ypred, signals] = feedForward(X(i:i+11,:), Winput, Winterior, Wprev1, Wprev2, Woutput);
            tmp_error = tmp_error + sum((Ypred(size(Ypred,1),:) - Y(i+11,:)).^2);
            
            % Backpropagate and update weight matrices
            [DiN] = backpropagate(X(i:i+11,:), Y(i:i+11,:), signals, Ypred, Winterior, Wprev1, Wprev2, Woutput);       
            [Uinput, Uinterior, Uprev1, Uprev2, Uoutput] = calculateUpdates(Uinput, Uinterior, Uprev1, Uprev2, Uoutput, X, signals, DiN);
            iter = iter + 1;
        end
        % Update the weight matrices based on average deltas
        Winput = Winput + lambda * Uinput/batch_size;
        Winterior = Winterior + lambda * Uinterior/batch_size;
        Wprev1 = Wprev1 + lambda * Uprev1/batch_size;
        Wprev2 = Wprev2 + lambda * Uprev2/batch_size;
        Woutput = Woutput + lambda * Uoutput/batch_size;
        error(floor(iter/batch_size), 1) = tmp_error/batch_size;
        disp(iter-1);
    end 
end