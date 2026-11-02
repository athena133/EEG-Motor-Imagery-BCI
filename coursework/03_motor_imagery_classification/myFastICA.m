function [S, A, W] = myFastICA(X, numIC, maxIter, tol)
    % FastICA Implementation
    % Inputs:
    %   X       - Input data matrix (channels x samples)
    %   numIC   - Number of independent components to extract
    %   maxIter - Maximum number of iterations
    %   tol     - Convergence tolerance
    % Outputs:
    %   S       - Estimated source signals (Independent Components)
    %   A       - Mixing matrix
    %   W       - Unmixing matrix

    % Centering (zero mean)
    X = X - mean(X, 2);

    % Whitening (using eigenvalue decomposition)
    [E, D] = eig(cov(X'));
    whiteningMat = inv(sqrt(D)) * E';  % Whitening matrix
    dewhiteningMat = E * sqrt(D);      % Dewhitening matrix
    X_white = whiteningMat * X;        % Whitened data

    % Initialize random weights
    W = randn(numIC, size(X_white, 1));

    for iter = 1:maxIter
        W_old = W;
        
        % Apply nonlinear function (g = tanh)
        Y = W * X_white;
        g = tanh(Y);
        g_deriv = 1 - g.^2;  % Derivative of g
        
        % Update rule for W
        W = (g * X_white') / size(X, 2) - mean(g_deriv, 2) .* W;
        
        % Orthogonalization (Gram-Schmidt process)
        [W, ~] = qr(W');

        % Check convergence
        if max(abs(abs(diag(W * W_old')) - 1)) < tol
            break;
        end
    end

    % Compute estimated sources and mixing matrix
    S = W * X_white;
    A = dewhiteningMat * W';

end
