function rotation=createMatrixRotation(degreangle)
% createMatrixRotation Simply create a 2D rotation matrix from an angle in
% degree.
% Perrine.paul-gilloteaux@curie.fr
q=degreangle*pi/180;
rotation=...
    [cos(q), sin(q),0;...
    -sin(q), cos(q),0;...
    0,0,1];
    
end

