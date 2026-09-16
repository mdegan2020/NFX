function valid = rsmGroundDomain(vertices) %#codegen
    %rsmGroundDomain - Check the six oriented quadrilateral domain faces
    valid = all(isfinite(vertices(:))) && vertices(1,1) < vertices(1,2) && ...
        vertices(2,1) < vertices(2,3) && vertices(3,1) < vertices(3,5);
    if ~valid, return; end
    widths = max(vertices,[],2)-min(vertices,[],2);
    if any(widths <= 0), valid = false; return; end
    % Coordinate scaling preserves convexity and avoids mixing radians with
    % meters when setting the dimensionless geometric tolerance.
    points = (vertices-min(vertices,[],2))./widths;
    faces = [1 3 4 2;5 6 8 7;1 5 7 3;2 4 8 6;1 2 6 5;3 7 8 4];
    for k = 1:6
        polygon = points(:,faces(k,:));
        normal = cross(polygon(:,2)-polygon(:,1),polygon(:,3)-polygon(:,1));
        magnitude = norm(normal);
        if magnitude < 1e-12, valid = false; return; end
        normal = normal/magnitude;
        distances = normal'*(points-polygon(:,1));
        if abs(distances(faces(k,4))) > 1e-10 || any(distances > 1e-10) || ...
                ~any(distances < -1e-10)
            valid = false; return
        end
        for j = 1:4
            next = mod(j,4)+1; after = mod(j+1,4)+1;
            turn = dot(cross(polygon(:,next)-polygon(:,j),polygon(:,after)-polygon(:,next)),normal);
            if turn <= 1e-12, valid = false; return; end
        end
    end
end
