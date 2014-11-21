% data = struct();
% data.trainX = [1,2,3,4,5;4,5,6,7,8;7,8,9,10,11; 2,3,4,5,6; 3,4,5,6,7; 4,5,6,7,8;5,6,7,8,9];
% data.trainY = [6; 9; 12;7;8;9;10];
% data.validateX = [6,7,8,9,10; 7,8,9,10,11; 8,9,10,11,12];
% data.validateY = [11;12;13];
% data.testX = [3,4,5,6,7; 2,4,6,8,10; 12,13,14,15,16];
% data.testY = [8; 12; 17];
function checker(iterations) 
    data = getData;
    %[Wone1, Wtwo1, Wfinal1, validateY1, testError1] = myTrain(data, 0.00000001, 0, iterations);
    %[Wone2, Wtwo2, Wfinal2, validateY2, testError2] = myTrain(data, 0.000005, 1, iterations);
    [Wone, Wtwo, Wfinal, validateY, testError] = myTrain(data, 0.0001, 2, iterations);
    validateX = 1:1:iterations;
    ylabel('squared error per sample');
    title('Validation error per iterations');
    xlabel('iteration');
    %plot(validateX, transpose(validateY1), validateX, transpose(validateY2), validateX, transpose(validateY3));
    plot(validateX, transpose(validateY));
    saveas(gcf, 'midpoint.fig');
    %save('weights.mat', 'Wfinal1','Wfinal2', 'Wone2', 'Wfinal3', 'Wone3', 'Wtwo3', 'testError1', 'testError2', 'testError3' );
    save('weights.mat', 'Wfinal', 'Wone', 'Wtwo', 'testError', 'data' );
end