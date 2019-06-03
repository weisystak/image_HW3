%% Initialize
clc
clear all
close all
%% Define hyperparameters
dist_sigma = 10; %sigma for gaussian distance weight in Part 1
gauss_weight = 1;

%% Extract superpixels
path='../MSRA10K_Imgs_GT/Imgs/'
srcFiles_img = dir([path '*.jpg']);
srcFiles_labels = dir([path '*.png']);
% may add some normalization to distance weight
filenum=2000 %50; %length(srcFiles_img); %50
all_Q = cell(1,filenum);
all_superpixel_labels = cell(filenum,1);

for a = 1:filenum
    filename = strcat(path,srcFiles_img(a).name);
    im = imread(filename);
    im_lab = RGB2Lab(im);
    [L,N] = superpixels(im_lab,200,'IsInputLab',1);
    
    filename = strcat(path,srcFiles_labels(a).name);
    label = imread(filename);
    label = imbinarize(label);
%     imshow(label)
    %Note that the N actual will be less than N wanted... Explain why in
    %writeup
%     figure,
%     BW = boundarymask(L);
%     imshow(imoverlay(im_lab,BW,'black'),'InitialMagnification',100)
    
    %% Vectorize superpixels in R and make mean color vector for each r
    
    im_size = size(im);
    label_idx = label2idx(L);
    C = zeros(N,3);
    for i=1:N
        redIdx = label_idx{i};
        greenIdx = label_idx{i}+im_size(1)*im_size(2);
        blueIdx = label_idx{i}+2*im_size(1)*im_size(2);
        C(i,:)=[mean(im(redIdx)),mean(im(greenIdx)),mean(im(blueIdx))];
    end
    
    %% Find the superpixel center for each region r
    P = zeros(N,1);
    for i = 1:N
        P(i,1) = round(mean(label_idx{i}));
    end

    %% Make contrast separation vector Q by comparing each superpixel
    Q_color = zeros(N,N,3);
    dist = zeros(N);
  
    for i = 1:N
        for j = 1:N
            [y_i, x_i] = ind2sub(im_size, P(i,1));
            p_i = [y_i; x_i];
            [y_j, x_j] = ind2sub(im_size, P(j,1));
            p_j = [y_j; x_j];
            dist(i,j) = norm(p_i - p_j);
            t_j = numel(label_idx{j});
            dist_weight = gaussian_weight(dist(i,j),0,dist_sigma);
            Q(i,j,1) = t_j*abs(C(i,1)-C(j,1))*gauss_weight*dist_weight;
            Q(i,j,2) = t_j*abs(C(i,2)-C(j,2))*gauss_weight*dist_weight;
            Q(i,j,3) = t_j*abs(C(i,3)-C(j,3))*gauss_weight*dist_weight;
        end
        [~,I] = sort(dist(i,:));
        Q_color(i,:,:) = Q(i,I,:);
    end
    
    all_Q(1,a) = {Q_color};
    
    superpixel_label = zeros(N,1);
    label_idx = label2idx(L);
    label_idx = label_idx';
    for j = 1:size(label_idx,1)
        label_idx_j = label_idx{j};
        label_region = label(label_idx_j);
        if (nnz(label_region)>nnz(~label_region))
            superpixel_label(j,1) = 1;
        else
            superpixel_label(j,1) = 0;
        end
    end  
%     label_chk = zeros(size(label));
%     for a = 1:size(label,1)
%         for b = 1:size(label,2)
%             if(superpixel_label(L(a,b),1) == 1)
%                 label_chk(a,b) = 1;
%             end
%         end
%     end
%     imshow(label_chk);
    all_superpixel_labels(a,1) = {superpixel_label'};
    
end
save('all_Q.mat','all_Q');
save('all_superpixel_labels.mat','all_superpixel_labels');

