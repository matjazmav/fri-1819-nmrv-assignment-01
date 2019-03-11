function [U, V] = lucaskanade_pyramidal(I1, I2, n, Lm)
% I1 - first image matrix (grayscale)
% I2 - second image matrix (grayscale)
% n - size of the neighborhood (n x n)
% Lm - number of pyramid levels

% create image pyramid
IL1{1} = I1;
IL2{1} = I2;
for L = 2:Lm
    IL1{L} = imresize(IL1{L-1}, 0.5);
    IL2{L} = imresize(IL2{L-1}, 0.5);
end

% go down the pyramid
for L = Lm:-1:1

    if Lm > L
        crop = cat(2, [0 0],  fliplr(size(IL1{L})));
        
        Upl = imcrop(imresize(U{L+1}.*2, 2), crop);
        Vpl = imcrop(imresize(V{L+1}.*2, 2), crop);
        
        Df = cat(3, Upl.*-1, Vpl.*-1);    % Df - displacement field 
        IL2{L} = imwarp(IL2{L}, Df);      % warp second image with Df
    end

    % perform lucaskanade
    [U{L}, V{L}] = lucaskanade(IL1{L}, IL2{L}, n);

end

% aggregate OP of each layer
d = cat(2, [0 0],  fliplr(size(I1)));
for L = 2:Lm

    scale = 2^(L-1);

    % scale OF vectors
    UL = imcrop(imresize(U{L} .* scale, scale), d); %./2^(L-1)
    VL = imcrop(imresize(V{L} .* scale, scale), d); 

    % aggregate OF vectors
    U{1} = U{1} + UL;
    V{1} = V{1} + VL;
end 

% return OF vectors
U = U{1};
V = V{1};