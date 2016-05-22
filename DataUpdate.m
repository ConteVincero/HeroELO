%This file is used to update the player records in data file with the
%winner of each match as well as the ELO change
%
%It creates columns of data in a temporary file that can be copied and
%pasted into the data file 

clear all

%Files are opened and copied into memory as normal
fileID = fopen('datdota_games.csv');
formatSpec = '%q %q %q %q %q %q %q %q %q %q %q %q %q %q'; %specifies the format for each column as data surrounded by quotation marks
MatchData = textscan(fileID,formatSpec,'Delimiter',','); %imports the file into the array MatchData
fclose(fileID);
%IF you don't get the right number of %q's the program dies
fileID = fopen('data.csv');
formatSpec = '%q %q %q %q %q %q %q %q %q %q %q %q'; %specifies the format for each column as data surrounded by quotation marks
PlayerData = textscan(fileID,formatSpec,'Delimiter',','); %imports the file into the array MatchData
fclose(fileID);

%Arrays created as normal
PlayerMatch = PlayerData{1,10};
PlayerSide = PlayerData{1,11};
MatchID = MatchData{1,2};
MatchWinners = MatchData{1,7};
rGain = MatchData{1,11};
dGain = MatchData{1,12};
j = 2;

for i = 2:size(PlayerMatch)
    %This assumes that the DatDota_games and data files are both sorted by
    %match ID
    
    while str2double(PlayerMatch(i)) ~= str2double(MatchID(j)) %If necessary, the match data in the datDota file is moved on to the next match
        j = j+1;
    end
    
    %The appropriate data from each match is then taken and placed into the
    %new columns
    Winners(i,1) = MatchWinners(j);
    if strcmp(PlayerSide(i),'Radiant')~=0
        eloGain(i,1) = str2double(rGain(j));
    else
        eloGain(i,1) = str2double(dGain(j));        
    end
end
Winners(1)=[];  %This just removes the headers from the columns
eloGain(1)=[];

%And now they are written to file!
xlswrite('tempdata.xlsx',Winners,strcat('L1:L',num2str(i)))
xlswrite('tempdata.xlsx.',eloGain,strcat('M1:M',num2str(i)))