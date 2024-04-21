clearvars;
close all;
clc;

KAPPA = 0.06;
RADIUS = 2;
SIGMA = 2.5;
TH = 100;
N = 100;

% Load images
im1 = imread('image1.jpg');
im2 = imread('image2.jpg');

% Resize im2 to match the size of im1
[height, width, ~] = size(im1); 
im2 = imresize(im2, [height, width]);

% Convert images to grayscale
im1gray = rgb2gray(im1);
im2gray = rgb2gray(im2);

% Gaussian filter
gaussianKernel = fspecial('gaussian', [9 9], SIGMA);
I1 = imfilter(double(im1gray), gaussianKernel);
I2 = imfilter(double(im2gray), gaussianKernel);


% Gradient magnitude
[I1x, I1y] = imgradientxy(I1, "prewitt");
[I2x, I2y] = imgradientxy(I2, "prewitt");

% Autocorrelation
A = I1x.^2;
B = I1x .* I2x;
C = I2x.^2;

% Noise reduction
Ae = imfilter(A, gaussianKernel);
Be = imfilter(B, gaussianKernel);
Ce = imfilter(C, gaussianKernel);

% Corner strength
R = (Ae .* Ce - Be.^2) - KAPPA * (Ae + Ce).^2;

% Non-maximum suppression
Rmax = ordfilt2(R, 9, ones(3, 3)); % Local maximum filtering
corners = (R == Rmax) & (R > TH); % Thresholding and finding local maximums

% Find the indices of the remaining corners
[corners_y, corners_x] = find(corners);

% Sort corners based on corner strength
[~, sorted_indices] = sort(R(corners), 'descend');
sorted_corners_y = corners_y(sorted_indices);
sorted_corners_x = corners_x(sorted_indices);

% Select N strongest corners
strongest_corners = [sorted_corners_y(1:N), sorted_corners_x(1:N)];

% Plotting
figure;
imshowpair(im1, im2, 'montage');
hold on;
despl = size(im1, 2);
plot(strongest_corners(:, 2), strongest_corners(:, 1), 'ro', 'MarkerSize', 5);
plot(strongest_corners(:, 2) + despl, strongest_corners(:, 1), 'go', 'MarkerSize', 5);
for j = 1:N
    line([strongest_corners(j, 2), strongest_corners(j, 2) + despl], ...
          [strongest_corners(j, 1), strongest_corners(j, 1)]);
end
hold off;
