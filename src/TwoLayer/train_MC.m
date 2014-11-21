% Trains for a specified output feature using a montecarlo udpate method
% instead of backpropagation

% Inputs:
% data = struct with the following memebers trainX, trainY, validateX,
% validateY, testX, testY (values should be randomized)
% N= number of neurons
% Winput = [d+1 x N] where d+1 is the number of input features + a bias 
% Winterior = Wprev1 = Wprev2 = [N+1 x N] (same size but different values)
% Woutput = [N+1 x l] where l is the nubmer of output features
% max_epochs = scalar

% Outputs
% Weight matrices = same size as respective input corresponding to the
% lowest validation error
% errors = [iter x 1]
function [Winput, Winterior, Wprev1, Wprev2, Woutput, error] = train_MC(data, Winput, Winterior, Wprev1, Wprev2, Woutput, max_epochs)
    Winput_lambda = 10;
    Winterior_lambda = 10;
    Wprev1_lambda = 10;
    Wprev2_lambda = 10;
    Woutput_lambda = 2.5;
    min_lambda = 10^-3;
    count_limit = 10;
    batch_size = size(data.trainX, 3);
    error = zeros(max_epochs, 1);
    for i=1:batch_size
        %Forward pass through the network with a sequence of training data
        [Ypred, signals1, signals2] = feedForward(data.trainX(:,:,i), Winput, Winterior, Wprev1, Wprev2, Woutput);
        error(1, 1) = error(1,1) + sum((Ypred(end,:) - data.trainY(end,:,i)).^2);
    end
    error(1,1) = error(1,1)/batch_size;
    epoch = 1;
    while epoch <= max_epochs && (epoch <= 2 || error(epoch-1,1) < error(epoch-2, 1) - 10^-4)
        disp(strcat('Starting epoch ', num2str(epoch)));
        %set Winput
        tmp_error = inf;
        count = 1;
        disp('setting Winput');
        disp(error(epoch,1));
        disp(Winput_lambda);
        if Winput_lambda > min_lambda
            while tmp_error > error(epoch, 1) && Winput_lambda > 10^-3
                if count > count_limit
                    count = 1;
                    Winput_lambda = Winput_lambda / 2;
                    tmp_Winput = Winput;
                    tmp_error = error(epoch, 1);
                else
                    tmp_Winput = Winput + initWeights(size(Winput, 1), size(Winput, 2), -1, 1)*Winput_lambda;
                    tmp_error = 0;
                    for i=1:batch_size
                        %Forward pass through the network with a sequence of training data
                        [Ypred, signals1, signals2] = feedForward(data.trainX(:,:,i), Winput, Winterior, Wprev1, Wprev2, Woutput);
                        tmp_error = tmp_error + sum((Ypred(end,:) - data.trainY(end,:,i)).^2);
                    end
                    tmp_error = tmp_error/batch_size;
                    count = count+1;
                end
            end
            Winput = tmp_Winput;
            error(epoch, 1) = tmp_error;
        end
        
        %set Winterior
        tmp_error = inf;
        count = 1;
        disp('setting Winterior');
        disp(error(epoch,1));
        disp(Winterior_lambda);
        if Winterior_lambda > min_lambda
            while tmp_error > error(epoch, 1)
                if count > count_limit
                    count = 1;
                    Winterior_lambda = Winterior_lambda / 2;
                    tmp_Winterior = Winterior;
                    tmp_error = error(epoch, 1);
                else
                    tmp_Winterior = Winterior + initWeights(size(Winterior, 1), size(Winterior, 2), -1, 1)*Winterior_lambda;
                    tmp_error = 0;
                    for i=1:batch_size
                        %Forward pass through the network with a sequence of training data
                        [Ypred, signals1, signals2] = feedForward(data.trainX(:,:,i), Winput, tmp_Winterior, Wprev1, Wprev2, Woutput);
                        tmp_error = tmp_error + sum((Ypred(end,:) - data.trainY(end,:,i)).^2);
                    end
                    tmp_error = tmp_error/batch_size;
                    count = count+1;
                end
            end
            Winterior = tmp_Winterior;
            error(epoch, 1) = tmp_error;
        end
        
        %set Wprev1
        tmp_error = inf;
        count = 1;
        disp('setting Wprev1');
        disp(error(epoch,1));
        disp(Wprev1_lambda);
        if Wprev1_lambda > min_lambda
            while tmp_error > error(epoch, 1)
                if count > count_limit
                    count = 1;
                    Wprev1_lambda = Wprev1_lambda / 2;
                    tmp_Wprev1 = Wprev1;
                    tmp_error = error(epoch, 1);
                else
                    tmp_Wprev1 = Wprev1 + initWeights(size(Wprev1, 1), size(Wprev1, 2), -1, 1)*Wprev1_lambda;
                    tmp_error = 0;
                    for i=1:batch_size
                        %Forward pass through the network with a sequence of training data
                        [Ypred, signals1, signals2] = feedForward(data.trainX(:,:,i), Winput, Winterior, tmp_Wprev1, Wprev2, Woutput);
                        tmp_error = tmp_error + sum((Ypred(end,:) - data.trainY(end,:,i)).^2);
                    end
                    tmp_error = tmp_error/batch_size;
                    count = count+1;
                end
            end
            Wprev1 = tmp_Wprev1;
            error(epoch, 1) = tmp_error;
        end
        
        %set Wprev2
        tmp_error = inf;
        count = 1;
        disp('setting Wprev2');
        disp(error(epoch,1));
        disp(Wprev2_lambda);
        if Wprev2_lambda > min_lambda
            while tmp_error > error(epoch, 1)
                if count > count_limit
                    count = 1;
                    Wprev2_lambda = Wprev2_lambda / 2;
                    tmp_Wprev2 = Wprev2;
                    tmp_error = error(epoch, 1);
                else
                    tmp_Wprev2 = Wprev2 + initWeights(size(Wprev2, 1), size(Wprev2, 2), -1, 1)*Wprev2_lambda;
                    tmp_error = 0;
                    for i=1:batch_size
                        %Forward pass through the network with a sequence of training data
                        [Ypred, signals1, signals2] = feedForward(data.trainX(:,:,i), Winput, Winterior, Wprev1, tmp_Wprev2, Woutput);
                        tmp_error = tmp_error + sum((Ypred(end,:) - data.trainY(end,:,i)).^2);
                    end
                    tmp_error = tmp_error/batch_size;
                    count = count+1;
                end
            end
            Wprev2 = tmp_Wprev2;
            error(epoch, 1) = tmp_error;
        end
        
        %set Woutput
        tmp_error = inf;
        count = 1;
        disp('setting Woutput');
        disp(error(epoch,1));
        disp(Woutput_lambda);
        if Woutput_lambda > min_lambda
            while tmp_error > error(epoch, 1)
                if count > count_limit
                    count = 1;
                    Woutput_lambda = Woutput_lambda / 2;
                    tmp_Woutput = Woutput;
                    tmp_error = error(epoch, 1);
                else
                    tmp_Woutput = Woutput + initWeights(size(Woutput, 1), size(Woutput, 2), -1, 1) * Woutput_lambda;
                    tmp_error = 0;
                    for i=1:batch_size
                        %Forward pass through the network with a sequence of training data
                        [Ypred, signals1, signals2] = feedForward(data.trainX(:,:,i), Winput, Winterior, Wprev1, Wprev2, tmp_Woutput);
                        tmp_error = tmp_error + sum((Ypred(end,:) - data.trainY(end,:,i)).^2);
                    end
                    tmp_error = tmp_error/batch_size;
                    count = count+1;
                end
            end
            Woutput = tmp_Woutput;
            error(epoch, 1) = tmp_error;
        end
        
        if (epoch < size(error, 1))
            error(epoch+1, 1) = tmp_error;
        end
        epoch = epoch + 1;
    end
end 
    