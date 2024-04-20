clearvars;
close all;
clc;

im1 = imread('image1.jpg');
im2 = imread('image2.jpg');

% Resize images to have the same dimensions
[height, width, ~] = size(im1);
im2 = imresize(im2, [height, width]);

im1gray = rgb2gray(im1);
im2gray = rgb2gray(im2);

corners1 = detectHarrisFeatures(im1gray);
corners2 = detectHarrisFeatures(im2gray);

% Select 100 strongest corners from each image
corners1 = corners1.selectStrongest(100);
corners2 = corners2.selectStrongest(100);

[features1, valid_corners1] = extractFeatures(im1gray, corners1);
[features2, valid_corners2] = extractFeatures(im2gray, corners2);

% Matching
desc1 = features1.Features;
desc2 = features2.Features;
N = size(desc1, 1);
match = zeros(N, 1);
for j = 1:N
    d1 = desc1(j, :);
    distances = sum(abs(desc2 - d1), 2);
    [~, match(j)] = min(distances);
end

% Get matched points
matchedPoints1 = valid_corners1;
matchedPoints2 = valid_corners2(match);

pt1 = matchedPoints1.Location;
pt2 = matchedPoints2.Location;

% Plotting
figure;
imshowpair(im1, im2, 'montage');
hold on;
despl = size(im1, 2);
plot(pt1(:, 1), pt1(:, 2), 'ro', 'MarkerSize', 5);
plot(pt2(:, 1) + despl, pt2(:, 2), 'go', 'MarkerSize', 5);
for j = 1:size(matchedPoints1, 1)
    line([pt1(j, 1), pt2(j, 1) + despl], [pt1(j, 2), pt2(j, 2)]);
end
hold off;
