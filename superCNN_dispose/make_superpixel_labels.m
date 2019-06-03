%This file is correct
path='../MSRA10K_Imgs_GT/Imgs/'
srcFiles_img = dir([path '*.jpg']);
srcFiles_labels = dir([path '*.png']);
filenum=length(srcFiles_img); %50
all_superpixel_labels = cell(filenum,1);
for i = 1 :filenum
%     i
    filename = strcat(path,srcFiles_img(i).name);
    im = imread(filename);
    filename = strcat(path,srcFiles_labels(i).name);
    label = imread(filename);
    label = imbinarize(label,1);
    
    im_lab = RGB2Lab(im);
    [L,N] = superpixels(im_lab,200,'IsInputLab',1);
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
    all_superpixel_labels(i,1) = {superpixel_label'};
end
save('all_superpixel_labels.mat','all_superpixel_labels');
