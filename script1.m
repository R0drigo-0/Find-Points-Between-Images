clearvars;
close all;
clc;

im1 = imread('image1.jpg');
im2 = imread('image2.jpg');

[height, width, ~] = size(im1);
im2 = imresize(im2, [height, width]);

im1gray = rgb2gray(im1);
im2gray = rgb2gray(im2);

corners1 = detectHarrisFeatures(im1gray);
corners2 = detectHarrisFeatures(im2gray);

corners1 = corners1.selectStrongest(100);
corners2 = corners2.selectStrongest(100);

[features1, valid_corners1] = extractFeatures(im1gray, corners1);
[features2, valid_corners2] = extractFeatures(im2gray, corners2);

% Matching
desc1 = features1.Features;
desc2 = features2.Features;
desc = {desc1, desc2};
N = size(desc1, 1);
match = zeros(1,N);
for j=1:N
    d1=desc{1}(j,:);
    [~,match(j)]=min(sum(abs(desc{2}-d1)));
end

pt1 = valid_corners1(match).Location;
pt2 = valid_corners2(match).Location;

figure;
imshowpair(im1, im2, 'montage');
hold on;
despl = size(im1, 2);
plot(pt1(:, 1), pt1(:, 2), 'ro', 'MarkerSize', 5);
plot(pt2(:, 1) + despl, pt2(:, 2), 'go', 'MarkerSize', 5);
for j = 1:size(valid_corners1(match), 1)
    line([pt1(j, 1), pt2(j, 1) + despl], [pt1(j, 2), pt2(j, 2)]);
end
hold off;
