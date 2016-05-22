%This takes the data from the data file and uses it to create a table of
%scores for each player on each hero.
clear all
HeroList = cell(1,130);
PlayerList = cell(130,1);
Score = zeros(1000);

%Open the file and write the data into the cell array MatchData
fileID = fopen('data.csv');
formatSpec = '%q %q %q %q %q %q %q %q %q %q %q %q %q'; %specifies the format for each column as data surrounded by quotation marks
MatchData = textscan(fileID,formatSpec,'Delimiter',','); %imports the file into the array MatchData
fclose(fileID);


Heroes = MatchData{1,3};    %Import the Hero data into the Heros array
Players = MatchData{1,2};   %Import the Player data into the Heros array
Side = MatchData{1,11};   %Import the Side data into the Heros array
Winner = MatchData{1,12};   %Import the Winner data into the Heros array
Elo = MatchData{1,13};   %Import the Winner data into the Heros array

DataSize = size(Heroes);    %Get the number of records

%Get a list of all the unique heros
HeroMax = 0;
PlayerMax = 0;
for i = 2:DataSize
    %Grabs the ELO gain from that particular match
    Gain=str2double(Elo(i));
    
    %Finds the player in the list or adds it if it isn't there
    %NOT EFFICIENT
    HeroMarker = 0;
    for j = 1:HeroMax
        if strcmp(Heroes(i),HeroList(j)) ~= 0
            HeroMarker =j;
            break
        end
    end
    if HeroMarker ==0
        HeroMax = HeroMax +1;
        HeroList(HeroMax) = Heroes(i);
        HeroMarker = HeroMax;
    end
    
    %Finds the player in the list or adds it if it isn't there
    %NOT EFFICIENT
    PlayerMarker = 0;
    for j = 1:PlayerMax
        if strcmp(Players(i),PlayerList(j)) ~= 0
            PlayerMarker =j;
            break
        end
    end
    if PlayerMarker ==0
        PlayerMax = PlayerMax +1;
        PlayerList(PlayerMax) = Players(i);
        PlayerMarker = PlayerMax;
    end
    
    %Update the master array with the gain for that hero
    Score(PlayerMarker,HeroMarker)=Score(PlayerMarker,HeroMarker)+Gain;
end

%Write the results to an .xls file
ColMax1 = fix(HeroMax/26);  %This creates an Excel Row reference to make sure that the headers are in the right place.
ColMax2 = rem(HeroMax,26);
ColMax = strcat(char(ColMax1+64),char(ColMax2+64));
xlswrite('PlayerHero.xlsx',HeroList,strcat('B1:',ColMax,'1'))
xlswrite('PlayerHero.xlsx',PlayerList,strcat('A2:A',num2str(PlayerMax)))
xlswrite('PlayerHero.xlsx',Score,strcat('B2:',ColMax,num2str(PlayerMax)))