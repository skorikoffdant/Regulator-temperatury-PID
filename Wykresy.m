port = "COM4"; 
baudRate = 115200; 
s = serialport(port, baudRate);

s.Timeout = 5; 
configureTerminator(s, "LF"); 
flush(s);

figure;
hold on;
h1 = animatedline('Color', 'r', 'DisplayName', 'Temperatura bieżąca'); 
h2 = animatedline('Color', 'b', 'DisplayName', 'Temperatura zadana'); 
tunnel = fill([0 0], [0 0], 'cyan', 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', 'Tunel ±1%'); 
legend('show', 'Location', 'northeast'); 
ax = gca;
grid on;
xlabel('Czas (sekundy)');
ylabel('Temperatura (°C)');
title('Temperatura w czasie rzeczywistym');
hold off;

startTime = []; 
timeData = []; 
upperBound = []; 
lowerBound = []; 

while isvalid(s)
    try
        data = readline(s);
        disp("Otrzymane dane: " + data); 
        data = strtrim(data); 
        
        parsedData = sscanf(data, '%lu,%f,%f'); 
        if numel(parsedData) == 3
            time_ms = parsedData(1); 
            temperature = parsedData(2); 
            temp_zadana = parsedData(3); 
            
            if isempty(startTime)
                startTime = time_ms; 
            end
            time_sec = (time_ms - startTime) / 1000; 
            
            addpoints(h1, time_sec, temperature); 
            addpoints(h2, time_sec, temp_zadana); 
            
            timeData = [timeData, time_sec]; 
            upperBound = [upperBound, temp_zadana * 1.01]; 
            lowerBound = [lowerBound, temp_zadana * 0.99]; 
            
            set(tunnel, 'XData', [timeData, fliplr(timeData)], ...
                        'YData', [upperBound, fliplr(lowerBound)]);
            
            ax.XLim = [0, time_sec + 1]; 
            ax.YLim = [min(lowerBound) - 1, max(upperBound) + 1]; 
            drawnow; 
        end
    catch ME
        disp("Błąd: " + ME.message); 
    end
end

clear s;
