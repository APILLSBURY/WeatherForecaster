% Trains for a specified output feature
function [Winput_min, Winterior_min, Wprev1_min, Wprev2_min, Woutput_min, train_error, valid_error, test_error] = train_BP_lookahead(data, Winput, Winterior, Wprev1, Wprev2, Woutput, batch_size, batches, lookahead)
    iter = 1;
    max_iters = batches;
    lambda_init = 0.05
    train_error = zeros(batches, 1);
    valid_error = zeros(batches, 1); 
    diff = 1000;
    valid_sum = 10;
    lookback = 1;
    i=0;
    min_error = inf;
    while (iter <= max_iters && diff > 10^-5)
        Uinput = zeros(size(Winput));
        Uinterior = zeros(size(Winterior));
        Uprev1 = zeros(size(Wprev1));
        Uprev2 = zeros(size(Wprev2));
        Uoutput = zeros(size(Woutput));
        lambda = lambda_init;
        tmp_error = 0;

        for b=1:batch_size-1
            if (i == size(data.trainX,3))
               i = 1;
            else 
                i = i + 1;
            end

            %Forward pass through the network with a sequence of training data
            [Ypred, signals1, signals1prev, signals2, signals2prev] = feedForward(data.trainX(:,:,i), Winput, Winterior, Wprev1, Wprev2, Woutput);
            tmp_error = tmp_error + sum((Ypred(end-lookahead,:) - data.trainY(end-lookahead,:,i)).^2);
            % Backpropagate and update weight matrices
            [DjN, DiN, DpN] = backpropagate_lookahead(data.trainX(:,:,i), data.trainY(:,:,i), signals1 + signals1prev, signals2 + signals2prev, Ypred, Winterior, Wprev1, Wprev2, Woutput, lookahead);       
            [Uinput, Uinterior, Uprev1, Uprev2, Uoutput] = calculateUpdates(Uinput, Uinterior, Uprev1, Uprev2, Uoutput, data.trainX(:,:,i), signals1, signals1prev, signals2, signals2prev, DjN, DiN, DpN);
        end
        
        %Run the validation data through the network
        train_error(iter) = tmp_error;
        tmp_error = inf;
        
        %Adaptive learning rate
        while (tmp_error > train_error(iter, 1)) && lambda > 10^-8
            disp('adapt');
            tmp_error = 0;
            lambda = lambda/2;
            tmp_Winput = Winput + lambda * Uinput/batch_size;
            tmp_Winterior = Winterior + lambda * Uinterior/batch_size;
            tmp_Wprev1 = Wprev1 + lambda * Uprev1/batch_size;
            tmp_Wprev2 = Wprev2 + lambda * Uprev2/batch_size;
            tmp_Woutput = Woutput + lambda * Uoutput/batch_size;
            
            %Forward pass through the network with validation data to see if error decreases
            for b=1:batch_size
                if (i == size(data.trainX,3))
                   i = 1;
                else 
                    i = i + 1;
                end
                [Ypred, ~, ~, ~, ~] = feedForward(data.trainX(:,:,i), tmp_Winput, tmp_Winterior, tmp_Wprev1, tmp_Wprev2, tmp_Woutput);
                tmp_error = tmp_error + sum((Ypred(end,:) - data.trainY(end,:,i)).^2);
            end
            tmp_error = tmp_error/size(data.trainX, 3);
        end
        
        Winput = tmp_Winput;
        Winterior = tmp_Winterior;
        Wprev1 = tmp_Wprev1;
        Wprev2 = tmp_Wprev2;
        Woutput = tmp_Woutput;
        
        %Calculate validation error
        valid_error_tmp = 0;
        for v=1:size(data.validateX,3)
            [Ypred, ~, ~, ~, ~] = feedForward(data.validateX(:,:,v), Winput, Winterior, Wprev1, Wprev2, Woutput);
            valid_error_tmp = valid_error_tmp + sum((Ypred(end,:) - data.validateY(end,:,v)).^2);
        end

        valid_error_tmp = valid_error_tmp / size(data.validateX,3);
        valid_sum = valid_sum + valid_error_tmp;
        valid_error(iter, 1) = valid_sum/iter;
        if (iter <= lookback + 1)
            diff = 1000;
        else
            diff = abs(valid_error(iter-lookback,1) - valid_sum/iter);
        end 
        
        if valid_error_tmp <= min_error
            Winput_min = Winput;
            Winterior_min = Winterior;
            Wprev1_min = Wprev1;
            Wprev2_min = Wprev2;
            Woutput_min = Woutput;
            min_error = valid_error_tmp;
            disp(min_error);
        end
        iter = iter + 1;
    end
    test_error = 0;
    for i=1:size(data.testX,3)
        [Ypred, ~, ~, ~, ~] = feedForward(data.testX(:,:,i), Winput_min, Winterior_min, Wprev1_min, Wprev2_min, Woutput_min);
        test_error = test_error + sum((Ypred(end,:) - data.testY(end,:,i)).^2);
    end
    test_error = test_error/size(data.testX,3);
    disp(test_error);
end
