function [trajectory_x, trajectory_y, journey_dist] = TSP_Solver_Matlab(x_list, y_list)





% Original code source: https://www.mathworks.com/help/optim/ug/travelling-salesman-problem.html
% https://www.mathworks.com/help/optim/ug/travelling-salesman-problem.html

% stopsLon = [1;10;3;7;8;18];
% stopsLat = [1;10;8;5;12;22];
stopsLon = x_list;
stopsLat = y_list;
nStops = length(stopsLon);
%journey_dist = 0;

% Calculate Distances Between Points  % same
idxs = nchoosek(1:nStops,2);
dist = hypot(stopsLat(idxs(:,1)) - stopsLat(idxs(:,2)), ...
             stopsLon(idxs(:,1)) - stopsLon(idxs(:,2)));
lendist = length(dist);

% Create Graph and Draw Map   % same
G = graph(idxs(:,1),idxs(:,2));
figure
hGraph = plot(G,'XData',stopsLon,'YData',stopsLat,'LineStyle','none','NodeLabel',{});
hold on


%  Constraints %---------------------------------different

Aeq = spalloc(nStops,size(idxs,1),nStops*(nStops-1)); % Allocate a sparse matrix
for ii = 1:nStops
    whichIdxs = (idxs == ii); % Find the trips that include stop ii
    whichIdxs = sparse(sum(whichIdxs,2)); % Include trips where ii is at either end
    Aeq(ii,:) = whichIdxs'; % Include in the constraint matrix
end
beq = 2*ones(nStops,1);


% Binary Bounds %---------------------------------different

intcon = 1:lendist;
lb = zeros(lendist,1);
ub = ones(lendist,1);


% Optimize Using intlinprog -------------------------------different

opts = optimoptions('intlinprog','Display','off');
[x_tsp,costopt,exitflag,output] = intlinprog(dist,intcon,[],[],Aeq,beq,lb,ub,opts);

x_tsp = logical(round(x_tsp));
Gsol = graph(idxs(x_tsp,1),idxs(x_tsp,2),[],numnodes(G));
% Gsol = graph(idxs(x_tsp,1),idxs(x_tsp,2)); % Also works in most cases


hold on
highlight(hGraph,Gsol,'LineStyle','-')
title('Solution with Subtours')


% Subtour Constraints    % same 
tourIdxs = conncomp(Gsol);
numtours = max(tourIdxs); % Number of subtours
fprintf('# of subtours: %d\n',numtours);



A = spalloc(0,lendist,0); % Allocate a sparse linear inequality constraint matrix
b = [];
while numtours > 1 % Repeat until there is just one subtour
    % Add the subtour constraints
    b = [b;zeros(numtours,1)]; % allocate b
    A = [A;spalloc(numtours,lendist,nStops)]; % A guess at how many nonzeros to allocate
    for ii = 1:numtours
        rowIdx = size(A,1) + 1; % Counter for indexing
        subTourIdx = find(tourIdxs == ii); % Extract the current subtour
%         The next lines find all of the variables associated with the
%         particular subtour, then add an inequality constraint to prohibit
%         that subtour and all subtours that use those stops.
        variations = nchoosek(1:length(subTourIdx),2);
        for jj = 1:length(variations)
            whichVar = (sum(idxs==subTourIdx(variations(jj,1)),2)) & ...
                       (sum(idxs==subTourIdx(variations(jj,2)),2));
            A(rowIdx,whichVar) = 1;
        end
        b(rowIdx) = length(subTourIdx) - 1; % One less trip than subtour stops
    end

    % Try to optimize again
    [x_tsp,costopt,exitflag,output] = intlinprog(dist,intcon,A,b,Aeq,beq,lb,ub,opts);
    x_tsp = logical(round(x_tsp));
    Gsol = graph(idxs(x_tsp,1),idxs(x_tsp,2),[],numnodes(G));
    % Gsol = graph(idxs(x_tsp,1),idxs(x_tsp,2)); % Also works in most cases
    
    % Visualize result
    hGraph.LineStyle = 'none'; % Remove the previous highlighted path
    highlight(hGraph,Gsol,'LineStyle','-')
    drawnow
    
    % How many subtours this time?
    tourIdxs = conncomp(Gsol);
    numtours = max(tourIdxs); % number of subtours
    fprintf('# of subtours: %d\n',numtours)
    
    % Calculate the total traveling distance
    journey_dist = sum(dist(x_tsp));

end

journey_dist = sum(dist(x_tsp));

title('Solution with Subtours Eliminated');
hold off


disp(output.absolutegap)


edges_num = height(Gsol.Edges);
trajectory_x = zeros(edges_num,2);
trajectory_y = zeros(edges_num,2);

edges = table2array(Gsol.Edges);

%figure


for i = 1:1:edges_num
    node_start = edges(i,1);
    node_end = edges(i,2);
    
    
    x = [stopsLon(node_start) stopsLon(node_end)];
    y = [stopsLat(node_start) stopsLat(node_end)];

    %traj(i,:) = [stopsLon(i); stopsLat(i)];
    %plot(x,y,'-O','Color','y');
    %hold on;
    
    trajectory_x(i,:) = x; 
    trajectory_y(i,:) = y;
end



