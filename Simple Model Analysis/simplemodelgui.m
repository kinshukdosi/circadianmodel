function circadianPlotterGUI

% First, create a model selection dialog
modelChoice = questdlg('Choose your model:', ...
    'Model Selection', ...
    'Simple Negative Feedback (SNF)', 'Negative-Negative Feedback (NNF)', 'Positive-Negative Feedback (PNF)', ...
    'Simple Negative Feedback (SNF)');

if isempty(modelChoice)
    return;
end

% Set model function based on choice
switch modelChoice
    case 'Simple Negative Feedback (SNF)'
        modelFcn = @SNF;
        molecules = {'M (mRNA)', 'Pc (Repressor Protein)', 'P (Nuclear Protein)'};
    case 'Negative-Negative Feedback (NNF)'
        modelFcn = @NNF;
        molecules = {'M', 'Pc', 'P', 'R', 'A'};
    case 'Positive-Negative Feedback (PNF)'
        modelFcn = @PNF;
        molecules = {'M', 'Pc', 'P', 'R', 'A'};
end

% Create the main figure
fig = figure('Name', ['Circadian Clock Plotter - ' modelChoice], ...
    'Position', [300 300 900 700], ...
    'MenuBar', 'none', ...
    'NumberTitle', 'off');

% Create panel for checkboxes
checkPanel = uipanel(fig, ...
    'Title', 'Select Molecules to Plot', ...
    'Position', [0.05 0.7 0.4 0.25]);

% Create checkboxes for each molecule
checkboxes = zeros(1, length(molecules));
panelHeight = 150; % Fixed height to accommodate all molecules

for i = 1:length(molecules)
    checkboxes(i) = uicontrol(checkPanel, ...
        'Style', 'checkbox', ...
        'String', molecules{i}, ...
        'Position', [20 panelHeight-25*i 200 25], ...
        'Value', 0);
end

% Create plot type panel
plotPanel = uibuttongroup(fig, ...
    'Title', 'Plot Type', ...
    'Position', [0.5 0.7 0.45 0.25]);

uicontrol(plotPanel, 'Style', 'radiobutton', ...
    'String', 'Time Series', ...
    'Position', [10 80 150 25], ...
    'Tag', 'timeSeries', ...
    'Value', 1);

uicontrol(plotPanel, 'Style', 'radiobutton', ...
    'String', 'Amplitude vs Initial Concentration', ...
    'Position', [10 50 200 25], ...
    'Tag', 'ampVsInit');

uicontrol(plotPanel, 'Style', 'radiobutton', ...
    'String', 'Compare Molecules', ...
    'Position', [10 20 200 25], ...
    'Tag', 'compare');

% Parameter Panel
paramPanel = uipanel(fig, ...
    'Title', 'Parameter Values', ...
    'Position', [0.05 0.1 0.9 0.25]);

% Get default parameter values
defaultParams = modelFcn('parametervalues');
paramNames = modelFcn('parameters');

% Create parameter input fields
paramInputs = zeros(1, length(paramNames));
for i = 1:length(paramNames)
    uicontrol(paramPanel, ...
        'Style', 'text', ...
        'String', paramNames{i}, ...
        'Position', [20+110*mod(i-1,4) 120-40*floor((i-1)/4) 50 20]);
    
    paramInputs(i) = uicontrol(paramPanel, ...
        'Style', 'edit', ...
        'String', num2str(defaultParams(i)), ...
        'Position', [70+110*mod(i-1,4) 120-40*floor((i-1)/4) 50 20], ...
        'Tag', ['param' num2str(i)]);
end

% Create time input fields
uicontrol(fig, ...
    'Style', 'text', ...
    'String', 'Time Range:', ...
    'Position', [50 400 70 20]);

uicontrol(fig, ...
    'Style', 'edit', ...
    'String', '0', ...
    'Position', [130 400 50 20], ...
    'Tag', 'tStart');

uicontrol(fig, ...
    'Style', 'edit', ...
    'String', '100', ...
    'Position', [190 400 50 20], ...
    'Tag', 'tEnd');

% Create initial concentration percentage input
uicontrol(fig, ...
    'Style', 'text', ...
    'String', 'Initial Concentration (%):', ...
    'Position', [300 400 120 20]);

uicontrol(fig, ...
    'Style', 'edit', ...
    'String', '100', ...
    'Position', [430 400 50 20], ...
    'Tag', 'initConc');

% Create concentration range input fields
uicontrol(fig, ...
    'Style', 'text', ...
    'String', 'Conc. Range (%):', ...
    'Position', [500 400 100 20]);

uicontrol(fig, ...
    'Style', 'edit', ...
    'String', '50', ...
    'Position', [600 400 50 20], ...
    'Tag', 'concStart');

uicontrol(fig, ...
    'Style', 'edit', ...
    'String', '150', ...
    'Position', [660 400 50 20], ...
    'Tag', 'concEnd');

% Create plot button
uicontrol(fig, ...
    'Style', 'pushbutton', ...
    'String', 'Generate Plot', ...
    'Position', [380 350 140 30], ...
    'Callback', @(src,event)plotButton_Callback(src,event,modelFcn));

% Create results text box
resultsText = uicontrol(fig, ...
    'Style', 'text', ...
    'Position', [50 300 800 40], ...
    'HorizontalAlignment', 'left', ...
    'Tag', 'results');

    function plotButton_Callback(~, ~, modelFcn)
        % Get selected molecules
        selected = zeros(1, length(checkboxes));
        for i = 1:length(checkboxes)
            selected(i) = get(checkboxes(i), 'Value');
        end
        
        if sum(selected) == 0
            errordlg('Please select at least one molecule to plot!', 'Selection Error');
            return;
        end
        
        % Get parameter values
        paramValues = zeros(1, length(paramNames));
        for i = 1:length(paramNames)
            paramValues(i) = str2double(get(findobj(fig, 'Tag', ['param' num2str(i)]), 'String'));
        end
        
        % Get plot type
        plotType = get(findobj(plotPanel, 'Value', 1), 'Tag');
        
        % Get time range
        tStart = str2double(get(findobj(fig, 'Tag', 'tStart'), 'String'));
        tEnd = str2double(get(findobj(fig, 'Tag', 'tEnd'), 'String'));
        
        if strcmp(plotType, 'timeSeries')
            % Get initial concentration percentage
            initConcPerc = str2double(get(findobj(fig, 'Tag', 'initConc'), 'String'))/100;
            
            % Time series plot
            initCond = modelFcn() * initConcPerc;
            [t, y] = ode15s(@(t,y) modelFcn(t,y,paramValues), [tStart tEnd], initCond);
            
            figure('Name', 'Circadian Rhythm Plot');
            hold on;
            
            colors = {'b', 'r', 'g', 'm', 'c'};
            legendEntries = {};
            
            % Calculate periods and amplitudes
            resultsStr = 'Results:';
            for i = 1:length(molecules)
                if selected(i)
                    plot(t, y(:,i), colors{i}, 'LineWidth', 2);
                    legendEntries{end+1} = molecules{i};
                    
                    % Calculate period and amplitude
                    [peaks, peakLocs] = findpeaks(y(:,i), t, 'MinPeakDistance', 10);
                    [troughs, troughLocs] = findpeaks(-y(:,i), t, 'MinPeakDistance', 10);
                    if length(peaks) > 1
                        period = mean(diff(peakLocs));
                        amplitude = mean(peaks + troughs);
                        resultsStr = sprintf('%s\n%s - Period: %.2f hours, Amplitude: %.4f', ...
                            resultsStr, molecules{i}, period, amplitude);
                    end
                end
            end
            
            xlabel('Time (hours)');
            ylabel('Concentration');
            title('Circadian Rhythm Time Series');
            legend(legendEntries);
            grid on;
            hold off;
            
            % Update results text
            set(findobj(fig, 'Tag', 'results'), 'String', resultsStr);
            
        elseif strcmp(plotType, 'ampVsInit')
            % Amplitude vs Initial Concentration plot
            concStart = str2double(get(findobj(fig, 'Tag', 'concStart'), 'String'))/100;
            concEnd = str2double(get(findobj(fig, 'Tag', 'concEnd'), 'String'))/100;
            
            % Create concentration range
            concRange = linspace(concStart, concEnd, 50);
            amplitudes = zeros(length(concRange), length(molecules));
            
            % Calculate amplitudes for each concentration
            for i = 1:length(concRange)
                initCond = modelFcn() * concRange(i);
                [t, y] = ode15s(@(t,y) modelFcn(t,y,paramValues), [80 100], initCond);
                amplitudes(i,:) = max(y) - min(y);
            end
            
            figure('Name', 'Amplitude vs Initial Concentration');
            hold on;
            
            colors = {'b', 'r', 'g', 'm', 'c'};
            legendEntries = {};
            
            for i = 1:length(selected)
                if selected(i)
                    plot(concRange*100, amplitudes(:,i), colors{i}, 'LineWidth', 2);
                    legendEntries{end+1} = molecules{i};
                end
            end
            
            xlabel('Initial Concentration (% of baseline)');
            ylabel('Amplitude');
            title('Amplitude vs Initial Concentration');
            legend(legendEntries);
            grid on;
            hold off;
            
        else % Compare molecules
            % Get initial concentration percentage
            initConcPerc = str2double(get(findobj(fig, 'Tag', 'initConc'), 'String'))/100;
            
            % Run simulation
            initCond = modelFcn() * initConcPerc;
            [t, y] = ode15s(@(t,y) modelFcn(t,y,paramValues), [tStart tEnd], initCond);
            
            % Calculate periods and amplitudes for all selected molecules
            periods = zeros(1, length(molecules));
            amplitudes = zeros(1, length(molecules));
            
            for i = 1:length(molecules)
                if selected(i)
                    [peaks, peakLocs] = findpeaks(y(:,i), t, 'MinPeakDistance', 10);
                    [troughs, troughLocs] = findpeaks(-y(:,i), t, 'MinPeakDistance', 10);
                    if length(peaks) > 1
                        periods(i) = mean(diff(peakLocs));
                        amplitudes(i) = mean(peaks + troughs);
                    end
                end
            end
            
            % Create comparison figure with two subplots
            figure('Name', 'Molecule Comparison', 'Position', [100 100 1000 500]);
            
            % Period comparison
            subplot(1,2,1);
            selectedIndices = find(selected);
            bar(periods(selectedIndices));
            set(gca, 'XTick', 1:length(selectedIndices));
            set(gca, 'XTickLabel', molecules(selectedIndices));
            xtickangle(45);
            ylabel('Period (hours)');
            title('Period Comparison');
            grid on;
            
            % Amplitude comparison
            subplot(1,2,2);
            bar(amplitudes(selectedIndices));
            set(gca, 'XTick', 1:length(selectedIndices));
            set(gca, 'XTickLabel', molecules(selectedIndices));
            xtickangle(45);
            ylabel('Amplitude');
            title('Amplitude Comparison');
            grid on;
            
            % Add text summary
            resultsStr = 'Comparison Results:';
            for i = 1:length(selectedIndices)
                idx = selectedIndices(i);
                resultsStr = sprintf('%s\n%s - Period: %.2f hours, Amplitude: %.4f', ...
                    resultsStr, molecules{idx}, periods(idx), amplitudes(idx));
            end
            set(findobj(fig, 'Tag', 'results'), 'String', resultsStr);
        end
    end
end