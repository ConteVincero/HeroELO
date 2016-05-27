%This takes the data from the data file and uses it to create a table of
%scores for each player on each hero.
clear all
HeroList = cell(1,130);
PlayerList = cell(130,1);
Score = zeros(10000,130);
Games = zeros(10000,130);

%Open the file and write the data into the cell array MatchData
fileID = fopen('data.csv');
formatSpec = '%q %q %q %q %q %q %q %q %q %q %q %q %q'; %specifies the format for each column as data surrounded by quotation marks
MatchData = textscan(fileID,formatSpec,'Delimiter',','); %imports the file into the array MatchData
fclose(fileID);


Heroes = MatchData{1,3};    %Import the Hero data into the Heros array
Players = MatchData{1,2};   %Import the Player data into the Players array
Match = MatchData{1,10};    %Mainly useful for finding matches when debugging
Side = MatchData{1,11};   %Import the Side data into the Heros array
Winner = MatchData{1,12};   %Import the Winner data into the Heros array

DataSize = size(Heroes);    %Get the number of records

%Get a list of all the unique heros
HeroMax = 0;
PlayerMax = 0;
h = waitbar(0,'Calculating...');
l = 0;
K = 53;
correct = 0;
wrong = 0;
Brier = 0;
Matches = 0;

for i = DataSize:-1:2
    l = l+1;
    %Finds the hero in the list or adds it if it isn't there
    HeroMarker(l) = 0;
    for j = 1:HeroMax
        if strcmp(Heroes(i),HeroList(j)) ~= 0
            HeroMarker(l) =j;
            break
        end
    end
    if HeroMarker(l) ==0
        HeroMax = HeroMax +1;
        HeroList(HeroMax) = Heroes(i);
        HeroMarker(l) = HeroMax;
    end
    
    %Finds the player in the list or adds it if it isn't there
    PlayerMarker(l) = 0;
    if find(strcmp(Players(i),PlayerList)) ~= 0 
        PlayerMarker(l) =find(strcmp(Players(i),PlayerList));                                             %Once found the position is marked and their ELO stored
        if Score(PlayerMarker(l),HeroMarker(l)) ==0                     %Checks to see if this is the first game the player has played on that hero
            if sum(Score(:,HeroMarker(l))) == 0                         %This should only be called if this is the first game on that hero
                Score(PlayerMarker(l),HeroMarker(l))=ELO(PlayerMarker(l));
            else
                Score(PlayerMarker(l),HeroMarker(l))=(ELO(PlayerMarker(l))+	sum(Score(:,HeroMarker(l)))/sum(Score(:,HeroMarker(l))~=0))/2;          %The Hero's average score and the player's score are averaged
            end
        end
        tempELO(l) = Score(PlayerMarker(l),HeroMarker(l));              %The 
    end
    if PlayerMarker(l) ==0
        PlayerMax = PlayerMax +1;
        PlayerList(PlayerMax,1) = Players(i);
        PlayerMarker(l) = PlayerMax;
        Score(PlayerMarker(l),HeroMarker(l))=1000;
        ELO(PlayerMax,1) = 1000;
        tempELO(l) = ELO(PlayerMax);
    end
    
    if l == 10  %Once all 10 people in the game have been found, the ELO gain can be calculated
        Matches = Matches +1;
        
        dELO = mean(tempELO(1:5));
        rELO = mean(tempELO(6:10));
        
        rExp = 1/(1+10^((dELO-rELO)/400));  %The expected win probability for Radiant and Dire. I coppied this formula off Wikipedia, sue me.
        dExp = 1/(1+10^((rELO-dELO)/400));
        
        if strcmpi(Winner(i),'Radiant')~=0  %The change in rating is now calculated, and kept seperate so that these can be used to update individual records
            rGain=K*(1-rExp);  %The K rating is set at the start
            dGain=K*(0-dExp);
            Brier(Matches) = (rExp-1)^2; 
            if rExp>0.5
                correct = correct +1;
            else
                if rExp ~= 0.5
                    wrong = wrong +1;
                end
            end
        else
            Brier(Matches) = (rExp-0)^2;
            rGain=K*(0-rExp);
            dGain=K*(1-dExp);
            if dExp>0.5
                correct = correct +1;
                
            else
                if dExp ~= 0.5
                    wrong = wrong +1;
                end
            end
        end
        ELOgain(i+4:i)=rGain;           %The ELO gains are saved
        ELOgain(i+9:i+10)=dGain;
        for l=1:5
            ELO(PlayerMarker(l))=ELO(PlayerMarker(l))+dGain;
            Score(PlayerMarker(l),HeroMarker(l))=Score(PlayerMarker(l),HeroMarker(l))+dGain;
            Games(PlayerMarker(l),HeroMarker(l))=Games(PlayerMarker(l),HeroMarker(l))+1;
        end
        for l=6:10
            ELO(PlayerMarker(l))=ELO(PlayerMarker(l))+rGain;
            Score(PlayerMarker(l),HeroMarker(l))=Score(PlayerMarker(l),HeroMarker(l))+rGain;
            Games(PlayerMarker(l),HeroMarker(l))=Games(PlayerMarker(l),HeroMarker(l))+1;
        end
        l=0;
    end
    waitbar(((DataSize(1)-i-2)/DataSize(1)),h);
    
end
fprintf('%i gives %f %% of games correct \n',K,(correct/(correct+wrong))*100)
fprintf('Brier score is %f \n',sum(Brier)/Matches)
waitbar(0,h,'Writing results to file.');

%Write the results to an .xls file
ColMax1 = fix((HeroMax+1)/26);  %This creates an Excel Row reference to make sure that the headers are in the right place.
ColMax2 = rem((HeroMax+1),26);
ColMax = strcat(char(ColMax1+64),char(ColMax2+64));

xlswrite('PlayerHero2.xlsx',HeroList,strcat('B1:',ColMax,'1'))
waitbar(0.1,h);
xlswrite('PlayerHero2.xlsx',PlayerList,strcat('A2:A',num2str(PlayerMax+1)))
waitbar(0.2,h);
xlswrite('PlayerHero2.xlsx',Score,strcat('B2:',ColMax,num2str(PlayerMax+1)))
waitbar(0.3,h);
xlswrite('PlayerHero2.xlsx',HeroList,'Games Played',strcat('B1:',ColMax,'1'))
waitbar(0.4,h);
xlswrite('PlayerHero2.xlsx',PlayerList,'Games Played',strcat('A2:A',num2str(PlayerMax+1)))
waitbar(0.5,h);
xlswrite('PlayerHero2.xlsx',Games,'Games Played',strcat('B2:',ColMax,num2str(PlayerMax+1)))
waitbar(0.6,h);

%This just generates a simple file showing the player rankings. It is of no
%further interest apart from for science.
xlswrite('PlayerRankings.xlsx',{'Player'},strcat('A1:A1'))
waitbar(0.7,h);
xlswrite('PlayerRankings.xlsx',{'Rating'},strcat('B1:B1'))
waitbar(0.8,h);
xlswrite('PlayerRankings.xlsx',PlayerList,strcat('A2:A',num2str(PlayerMax+1)))
waitbar(0.9,h);
xlswrite('PlayerRankings.xlsx',ELO,strcat('B2:B',num2str(PlayerMax+1)))
waitbar(1,h);

close(h)