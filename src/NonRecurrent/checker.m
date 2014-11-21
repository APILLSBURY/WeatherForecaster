% data = struct();
% data.trainX = [1,2,3,4,5;4,5,6,7,8;7,8,9,10,11; 2,3,4,5,6; 3,4,5,6,7; 4,5,6,7,8;5,6,7,8,9];
% data.trainY = [6; 9; 12;7;8;9;10];
% data.validateX = [6,7,8,9,10; 7,8,9,10,11; 8,9,10,11,12];
% data.validateY = [11;12;13];
% data.testX = [3,4,5,6,7; 2,4,6,8,10; 12,13,14,15,16];
% data.testY = [8; 12; 17];
function checker(numHidden, learningRate, iterations) 
    data = getData_small();
    [Wone, Wtwo, Wfinal, validateY, testError] = myTrain(data, learningRate, numHidden, iterations);
    validateX = 1:1:iterations;
    ylabel('squared error per sample');
    title('Validation error per iterations');
    xlabel('iteration');
    scatter(validateX, transpose(validateY)); 
    saveas(gcf, 'midpoint.fig');
    save('weights.mat', 'Wfinal', 'Wone', 'Wtwo');
end