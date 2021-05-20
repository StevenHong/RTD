function q = msspoly_to_fun(p,x,fname,optimflag)

% this function takes in an msspoly, p(x) and returns it as a matlab
% function handle, q

%inputs
%p: n by k msspoly
%x: cell array of msspolys this will be passed as an argument into matlabFunction
% for example if you want q:TxZxK->R, input x = {t,z,k}

%Author: Sean Vaskov
%Created: 2019
%%
xsym_fun = cell(1,length(x));

for i = 1:length(x)
    msspoly_names = name(x{i});
%     L_msspoly_char = ismember(msspoly_names{1},msspoly_chars);
%     msspoly_name = msspoly_names{1}(L_msspoly_char);
    xsym_fun{i} = sym(msspoly_names{1},size(x{i}),'real');
end

% xsym_cat = cat(1,xsym_fun{:});
x_cat = [];
xsym_cat = [];

for i = 1:length(x)
    xsym_cat = [xsym_cat;xsym_fun{i}(:)];
    x_cat = [x_cat;x{i}(:)];
end

%outputs
%q: n by k symbolic variable s.t. q(xsym)==p(x)

if all(size(x_cat)==size(xsym_cat)) %|| all(size(x_cat)==size(xsym_cat'))
    [vars,pow,M]=decomp(p);
    
    var_idxs = NaN(size(vars));
    for i=1:length(vars)
        var_idxs(i) = find(arrayfun(@(xin)isequal(vars(i),xin),x_cat));
    end
    
    q=sym(zeros(size(p)));
    
    for i=1:size(M,1)
        
        for k=1:size(M,2)
            term = sym(1);
            for j=1:size(pow,2)
                term = term * xsym_cat(var_idxs(j))^pow(k,j);
            end
            q(i)=q(i)+M(i,k)*term;
        end
    end
else
    error('there is some bug with the dimensions of the msspoly and symbols')
end

if nargin>2
    if nargin>3
        q = matlabFunction(q,'vars',xsym_fun,'File',fname,'Optimize',optimflag);
    else
        q = matlabFunction(q,'vars',xsym_fun,'File',fname);
    end
else
    q = matlabFunction(q,'vars',xsym_fun);
end

end