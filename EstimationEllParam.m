%% 座標点の入力から楕円の情報を推定するプログラム（重要）

function ellipse_params = EstimationEllParam(points)

% 初期係数の推定
initial_guess = [600; 350; 600; 350; 500];

% 最小二乗法を使用して楕円の方程式の係数を求める
ellipse_params = lsqcurvefit(@ellipse_residuals, initial_guess, points, zeros(size(points, 1), 1));

% 楕円の方程式の係数を表示
disp('楕円の方程式の係数:');
disp(ellipse_params);
end

function residual = ellipse_residuals(params, points)
    A1 = params(1);
    A2 = params(2);
    B1 = params(3);
    B2 = params(4);
    R = params(5);
    
    x = points(:, 1);
    y = points(:, 2);
    
    residual = sqrt((A1 - x).^2 + (A2 - y).^2) + sqrt((B1 - x).^2 + (B2 - y).^2)-2*R;
end