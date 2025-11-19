function matrix = vectomat(vector,size1,size2)    
% make symmetric matrix based on vector...
    l=1;
    mat = zeros(size1,size2);
    for i=1:size1
        for j=1:i-1
            mat(i,j) = vector(l);
            l=l+1;
        end
    end
    matrix = (mat + mat').*~eye(size1,size2);
    
end