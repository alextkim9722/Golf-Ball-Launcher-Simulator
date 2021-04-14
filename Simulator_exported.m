classdef Simulator_exported < matlab.apps.AppBase

    % For this code, most of the UI components were made by MATLAB's
    % built-in GUI editor. Areas marked as [STUDENT WORK] are areas that
    % the GUI has not worked on.
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
        InitialVelocityinsEditFieldLabel  matlab.ui.control.Label
        InitialVelocityinsEditField     matlab.ui.control.NumericEditField
        AngledegreesEditFieldLabel      matlab.ui.control.Label
        AngledegreesEditField           matlab.ui.control.NumericEditField
        TargetTypeSpinnerLabel          matlab.ui.control.Label
        TargetTypeSpinner               matlab.ui.control.Spinner
        LaunchButton                    matlab.ui.control.Button
        Gravityins2EditFieldLabel       matlab.ui.control.Label
        Gravityins2EditField            matlab.ui.control.NumericEditField
        HeightofStandinEditFieldLabel   matlab.ui.control.Label
        HeightofStandinEditField        matlab.ui.control.NumericEditField
        C_RestitutionEditFieldLabel     matlab.ui.control.Label
        C_RestitutionEditField          matlab.ui.control.NumericEditField
        AirDensitylbmin3EditFieldLabel  matlab.ui.control.Label
        AirDensitylbmin3EditField       matlab.ui.control.NumericEditField
        DragCoefficientEditFieldLabel   matlab.ui.control.Label
        DragCoefficientEditField        matlab.ui.control.NumericEditField
        DefaultButton                   matlab.ui.control.Button
        InputValuesLabel                matlab.ui.control.Label
    end

    
    methods (Access = private)
        
        % [STUDENT WORK]--------------------------------------------[START]
        function generate(app, initial, drag, grav, height, density, angle, rest, type)
            v_0 = initial/1000;        %191.88/1000;      % in/ms     v_0 = 200 in/ms
            c_d = drag;             % --
            g = grav/1000000;     % in/ms^2
            stand_height = height;      % in
            radius = 1.68/2;          % in
            area = pi*radius^2;     % in^2
            rho = density;        % lbm/in^3
            mass = 0.10125;         % lbm
            theta = angle;   % degrees
            c_restitution = rest;   % --
            x = zeros(1);           % in
            y = 31;                 % in
            v = v_0;                % in/ms
            Target_Type = type;
            
            %-[CRITICAL COMPONENTS]----------------------------------------
            % The critical components of this device is the posotion that
            % the ball is launched from the cannon based on the origin. It
            % is also the distance of the origin from the bottom of the
            % cannon. The origin is treated as the hinge connection. The
            % three crucial components are therefore:
            %                   hingeorigin_base_dist
            %                   hingeorigin_ballorigin_dist
            %                   hingeorigin_ballorigin_angle
            % The last two components are used to find the height that the
            % ball leaves the muzzle.
            
            hingeorigin_ballorigin_angle = 37;  % degrees
            hingeorigin_ballorigin_dist = 7.07; % in
            hingeorigin_base_dist = 5;          % in
            y = hingeorigin_ballorigin_dist*sind(hingeorigin_ballorigin_angle+theta) + stand_height + hingeorigin_base_dist; %the value of the distance between the hinge to the ball multiplied by sin(hinge_origin to ball_origin angle + theta) + stand height + the distance between the hinge to the ball
            
            bounce = false; %initializes the bounce to be 0
            
            % Trajectory code calculations --------------------------------------------
            while true 
                % Acceleration due to drag force calculations ---------------------------------------------
                a_D_y = c_d * area * rho * v(end)^2/(2 * mass) * sind(theta); %Acceleration due to Drag Force Equation(y-direction)
                a_D_x = c_d * area * rho * v(end)^2/(2 * mass) * cosd(theta); %Acceleration due to Drag Force Equation(x-direction)
                
                % Negative acceleration calculations -----------------------------------
                a_y = g + a_D_y; %combined acceleration of gravity + Acceleration due to Drag Force Equation(y-direction)
                
                % Velocity calculations -----------------------------------------------
                temp_vx = v(end)*cosd(theta) - a_D_x; %velocity in the x-direction
                temp_vy = v(end)*sind(theta) - a_y; %velocity in the y-direction
                
                % Position calculations -----------------------------------------------
                temp_x = x(end) + temp_vx; %position in the x-direction
                temp_y = y(end) + temp_vy; %position in the y-direction
                
                % Appending to the position and velocity arrays -----------------------
                x = [x temp_x]; %appends initial position, x, to the new position temp_x
                y = [y temp_y]; %appends initial position, y, to the new position temp_y
                v = [v sqrt(temp_vx^2 + temp_vy^2)]; %appends initial velocity and the new velocity in terms of its magnitude
                
                % Calculating the new trajectory of the ball --------------------------
                theta = atand(temp_vy/temp_vx); %angle of the trajectory of the ball
                
                % Golf ball bouncing off of the ground calculations -------------------
                if y(end) < 0 && bounce == false %logical test if the last value in y is less than 0 and bounce equals false
                    v_interpolated = v(end - 1) + (0 - y(end - 1))*(v(end)-v(end-1))/(y(end) - y(end - 1)); % in/ms
                    x_interpolated = x(end - 1) + (0 - y(end - 1))*(x(end)-x(end-1))/(y(end) - y(end - 1)); % in
                    temp_vxb = v_interpolated * cosd(theta); %interpolated,  new velocity of the ball in the x direction
                    temp_vyb = v_interpolated * sind(theta); %interpolated,  new velocity of the ball in the y direction
                    temp_vyc = -temp_vyb * c_restitution; %interpolated,  new velocity of the ball in the x direction * coefficient of restitution
                    
                    theta = atand(temp_vyc/temp_vxb); %angle of the velocity (y-direction) when the ball hits the ground over the initial velocity (x-direction) of the ball
                    x(end) = x_interpolated; %replaces the last value of the x-position array with the interpolated x-position value
                    x_first_hit = x(end); %x-position of the where the ball first hits equals the last value of the x-array
                    y(end) = 0;
                    v(end) = sqrt(temp_vyc^2 + temp_vxb^2); %The last value of the velocity array equals the magnitude of the velocity of the ball after hitting the ground and the velocity of the ball before hitting the ground in the x-direction
                    
                    bounce = true; 
                end
                
                % Hitting the ground after a bounce will end the calculations ---------
                if y(end) < 0 && bounce == true %logical test if the last value in the y array is less than 0 and bounce equals true
                    break; %ends the while loop
                end
            end
            
            hold(app.UIAxes, 'on'); %continues the plot on the same figure
            cla(app.UIAxes); %clears axes of the figure

            if Target_Type == 1
                rectangle(app.UIAxes, 'Position',[60-6.5,0,13,14.5]);
            elseif Target_Type == 2
                rectangle(app.UIAxes, 'Position',[120-6.5,0,13,14.5]);
            elseif Target_Type == 3
                rectangle(app.UIAxes, 'Position',[180-6.5,0,13,14.5]);
            end
            
            plot(app.UIAxes, x_first_hit, 0, 'b*', 'Linewidth', 4);
            plot(app.UIAxes, x(end), y(end), 'b*', 'Linewidth', 4);
            plot(app.UIAxes, x(1),y(1), 'b*', 'Linewidth', 4);
            plot(app.UIAxes, x,y);
            yline(app.UIAxes, 0);
            
            title(app.UIAxes, 'Trajectory of the golf ball going through the air');
            xlabel(app.UIAxes, 'Horizontal Distance (in)');
            ylabel(app.UIAxes, 'Vertical Distance (in)');
            
            hold(app.UIAxes, 'off');
        end
        
        function default(app)
            app.InitialVelocityinsEditField.Value = 191.88;
            app.DragCoefficientEditField.Value = 0.24;
            app.Gravityins2EditField.Value = 386.09;
            app.HeightofStandinEditField.Value = 31;
            app.AirDensitylbmin3EditField.Value = 0.0000445;
            app.AngledegreesEditField.Value = 45;
            app.C_RestitutionEditField.Value = 0.75;
            app.TargetTypeSpinner.Value = 2;
        end
        % [STUDENT WORK]----------------------------------------------[END]
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        % [STUDENT WORK]--------------------------------------------[START]
        function startupFcn(app)
            default(app);
            
            generate(app, app.InitialVelocityinsEditField.Value, app.DragCoefficientEditField.Value, app.Gravityins2EditField.Value, app.HeightofStandinEditField.Value, ...
                app.AirDensitylbmin3EditField.Value, app.AngledegreesEditField.Value, app.C_RestitutionEditField.Value, app.TargetTypeSpinner.Value);
        end

        % Button pushed function: LaunchButton
        function LaunchButtonPushed(app, event)
            generate(app, app.InitialVelocityinsEditField.Value, app.DragCoefficientEditField.Value, app.Gravityins2EditField.Value, app.HeightofStandinEditField.Value, ...
                app.AirDensitylbmin3EditField.Value, app.AngledegreesEditField.Value, app.C_RestitutionEditField.Value, app.TargetTypeSpinner.Value);
        end

        % Button pushed function: DefaultButton
        function DefaultButtonPushed(app, event)
            startupFcn(app);
        end
        % [STUDENT WORK]----------------------------------------------[END]
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 704 476];
            app.UIFigure.Name = 'UI Figure';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.Position = [1 10 460 467];

            % Create InitialVelocityinsEditFieldLabel
            app.InitialVelocityinsEditFieldLabel = uilabel(app.UIFigure);
            app.InitialVelocityinsEditFieldLabel.HorizontalAlignment = 'right';
            app.InitialVelocityinsEditFieldLabel.Position = [471 412 108 22];
            app.InitialVelocityinsEditFieldLabel.Text = 'Initial Velocity (in/s)';

            % Create InitialVelocityinsEditField
            app.InitialVelocityinsEditField = uieditfield(app.UIFigure, 'numeric');
            app.InitialVelocityinsEditField.Limits = [0 Inf];
            app.InitialVelocityinsEditField.Tooltip = {'Velocity at which the golf ball leaves the cannon''s muzzle.'};
            app.InitialVelocityinsEditField.Position = [594 412 100 22];

            % Create AngledegreesEditFieldLabel
            app.AngledegreesEditFieldLabel = uilabel(app.UIFigure);
            app.AngledegreesEditFieldLabel.HorizontalAlignment = 'right';
            app.AngledegreesEditFieldLabel.Position = [488 375 91 22];
            app.AngledegreesEditFieldLabel.Text = 'Angle (degrees)';

            % Create AngledegreesEditField
            app.AngledegreesEditField = uieditfield(app.UIFigure, 'numeric');
            app.AngledegreesEditField.Tooltip = {'Angle that the cannon is aiming.'};
            app.AngledegreesEditField.Position = [594 375 100 22];

            % Create TargetTypeSpinnerLabel
            app.TargetTypeSpinnerLabel = uilabel(app.UIFigure);
            app.TargetTypeSpinnerLabel.HorizontalAlignment = 'right';
            app.TargetTypeSpinnerLabel.Position = [511 335 68 22];
            app.TargetTypeSpinnerLabel.Text = 'Target Type';

            % Create TargetTypeSpinner
            app.TargetTypeSpinner = uispinner(app.UIFigure);
            app.TargetTypeSpinner.Limits = [1 3];
            app.TargetTypeSpinner.Tooltip = {'Type of target to hit.'; '1 - 5 ft'; '2 - 10 ft'; '3 - 15 ft'};
            app.TargetTypeSpinner.Position = [594 335 100 22];
            app.TargetTypeSpinner.Value = 1;

            % Create LaunchButton
            app.LaunchButton = uibutton(app.UIFigure, 'push');
            app.LaunchButton.ButtonPushedFcn = createCallbackFcn(app, @LaunchButtonPushed, true);
            app.LaunchButton.Position = [594 79 100 22];
            app.LaunchButton.Text = 'Launch';

            % Create Gravityins2EditFieldLabel
            app.Gravityins2EditFieldLabel = uilabel(app.UIFigure);
            app.Gravityins2EditFieldLabel.HorizontalAlignment = 'right';
            app.Gravityins2EditFieldLabel.Position = [493 297 86 22];
            app.Gravityins2EditFieldLabel.Text = 'Gravity (in/s^2)';

            % Create Gravityins2EditField
            app.Gravityins2EditField = uieditfield(app.UIFigure, 'numeric');
            app.Gravityins2EditField.Tooltip = {'Gravity that affects the golf ball.'};
            app.Gravityins2EditField.Position = [594 297 100 22];

            % Create HeightofStandinEditFieldLabel
            app.HeightofStandinEditFieldLabel = uilabel(app.UIFigure);
            app.HeightofStandinEditFieldLabel.HorizontalAlignment = 'right';
            app.HeightofStandinEditFieldLabel.Tooltip = {'Height of the table that the cannon will be placed on.'};
            app.HeightofStandinEditFieldLabel.Position = [470 255 109 22];
            app.HeightofStandinEditFieldLabel.Text = 'Height of Stand (in)';

            % Create HeightofStandinEditField
            app.HeightofStandinEditField = uieditfield(app.UIFigure, 'numeric');
            app.HeightofStandinEditField.Position = [594 255 100 22];

            % Create C_RestitutionEditFieldLabel
            app.C_RestitutionEditFieldLabel = uilabel(app.UIFigure);
            app.C_RestitutionEditFieldLabel.HorizontalAlignment = 'right';
            app.C_RestitutionEditFieldLabel.Position = [501 123 78 22];
            app.C_RestitutionEditFieldLabel.Text = 'C_Restitution';

            % Create C_RestitutionEditField
            app.C_RestitutionEditField = uieditfield(app.UIFigure, 'numeric');
            app.C_RestitutionEditField.Tooltip = {'Coefficient of restitution of the ball hitting the floor.'};
            app.C_RestitutionEditField.Position = [594 123 100 22];

            % Create AirDensitylbmin3EditFieldLabel
            app.AirDensitylbmin3EditFieldLabel = uilabel(app.UIFigure);
            app.AirDensitylbmin3EditFieldLabel.HorizontalAlignment = 'right';
            app.AirDensitylbmin3EditFieldLabel.Position = [460 212 119 22];
            app.AirDensitylbmin3EditFieldLabel.Text = 'Air Density (lbm/in^3)';

            % Create AirDensitylbmin3EditField
            app.AirDensitylbmin3EditField = uieditfield(app.UIFigure, 'numeric');
            app.AirDensitylbmin3EditField.Tooltip = {'Density of the air that the golf ball will fly through.'};
            app.AirDensitylbmin3EditField.Position = [594 212 100 22];

            % Create DragCoefficientEditFieldLabel
            app.DragCoefficientEditFieldLabel = uilabel(app.UIFigure);
            app.DragCoefficientEditFieldLabel.HorizontalAlignment = 'right';
            app.DragCoefficientEditFieldLabel.Position = [488 168 91 22];
            app.DragCoefficientEditFieldLabel.Text = 'Drag Coefficient';

            % Create DragCoefficientEditField
            app.DragCoefficientEditField = uieditfield(app.UIFigure, 'numeric');
            app.DragCoefficientEditField.Tooltip = {'Coefficient of drag for the golf ball.'};
            app.DragCoefficientEditField.Position = [594 168 100 22];

            % Create DefaultButton
            app.DefaultButton = uibutton(app.UIFigure, 'push');
            app.DefaultButton.ButtonPushedFcn = createCallbackFcn(app, @DefaultButtonPushed, true);
            app.DefaultButton.Tooltip = {'Reset all input values to startup values.'};
            app.DefaultButton.Position = [484 79 100 22];
            app.DefaultButton.Text = 'Default';

            % Create InputValuesLabel
            app.InputValuesLabel = uilabel(app.UIFigure);
            app.InputValuesLabel.Position = [555 444 71 22];
            app.InputValuesLabel.Text = 'Input Values';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Simulator_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end