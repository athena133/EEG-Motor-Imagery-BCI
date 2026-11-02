function output=laplacianFilter(input)
sample_size=size(input,2);
weights = [1 -0.33 -0.33 -0.33 -0.33]; 
output=zeros(1,sample_size);
n=1;
while n<=sample_size
    output(n)=dot(weights,input(:,n));
    n=n+1;
end
end

