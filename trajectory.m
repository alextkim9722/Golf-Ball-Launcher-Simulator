clear;clc;

% Initial values that one can change to affect trajectory code ------------
v_0 = 191.88/1000;      % in/ms
c_d = 0.24;             % --
g = 386.09/1000000;     % in/ms^2
radius = 1.68;          % in
area = pi*radius^2;     % in^2
rho = 0.0000445;        % lbm/in^3
mass = 0.10125;         % lbm
theta = 45;             % degrees
c_restitution = 0.75;   % --
x = zeros(1);           % in
y = 31;                 % in
v = v_0;                % in/ms

x_first_hit = 0;
bounce = false;

% Trajectory code calculations --------------------------------------------
while true
    % Drag force calculations ---------------------------------------------
    a_D_y = c_d * area * rho * v(end)^2/(2 * mass) * sind(theta);
    a_D_x = c_d * area * rho * v(end)^2/(2 * mass) * cosd(theta);
    
    % Negative accerlation calculations -----------------------------------
    a_y = g + a_D_y;
    
    % Velocity calculations -----------------------------------------------
    temp_vx = v(end)*cosd(theta) - a_D_x;
    temp_vy = v(end)*sind(theta) - a_y;
    
    % Position calculations -----------------------------------------------
    temp_x = x(end) + temp_vx;
    temp_y = y(end) + temp_vy;
    
    % Appending to the position and velocity arrays -----------------------
    x = [x temp_x];
    y = [y temp_y];
    v = [v sqrt(temp_vx^2 + temp_vy^2)];
    
    % Calculating the new trajectory of the ball --------------------------
    theta = atand(temp_vy/temp_vx);
    
    % Golf ball bouncing off of the ground calculations -------------------
    if y(end) < 0 && bounce == false
        v_interpolated = v(end - 1) + (0 - y(end - 1))*(v(end)-v(end-1))/(y(end) - y(end - 1)); % in/ms
        x_interpolated = x(end - 1) + (0 - y(end - 1))*(x(end)-x(end-1))/(y(end) - y(end - 1)); % in
        temp_vxb = v_interpolated * cosd(theta);
        temp_vyb = v_interpolated * sind(theta);
        temp_vyc = -temp_vyb * c_restitution;
        
        theta = atand(temp_vyc/temp_vxb);
        x(end) = x_interpolated;
        x_first_hit = x(end);
        y(end) = 0;
        v(end) = sqrt(temp_vyc^2 + temp_vxb^2);
        
        bounce = true;
    end
    
    % Hitting the ground after a bounce will end the calculations ---------
    if y(end) < 0 && bounce == true
        break;
    end
end

x_interpolated = x(end - 1) + (0 - y(end - 1))*(x(end)-x(end-1))/(y(end) - y(end - 1)); % in
x(end) = x_interpolated;
y(end) = 0;

hold on;

plot(x_first_hit, 0, 'b*', 'Linewidth', 4);
plot(x(end), y(end), 'b*', 'Linewidth', 4);
plot(x(1),y(1), 'b*', 'Linewidth', 4);
plot(x,y);
yline(0);

hold off;