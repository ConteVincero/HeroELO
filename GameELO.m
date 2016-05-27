%
%This program Calculates the ELO score for each team
%
Clear all
%Teams = cell(100,1);
%Times = zeros(100,5);

fileID = fopen('datdota_games.csv');
formatSpec = '%q %q %q %q %q %q %q %q %q %q'; %specifies the format for each column as data surrounded by quotation marks
MatchData = textscan(fileID,formatSpec,'Delimiter',','); %imports the file into the array MatchData
fclose(fileID);

%Specifiying each of the arrays from the file data
Radiant = MatchData{1,5};
Dire = MatchData{1,6};
Winner = MatchData{1,7};

Games = size(Radiant);
TeamMax = 0;
rGain = zeros(Games);
dGain = zeros(Games);
rMMR = zeros(Games);
dMMR = zeros(Games);
K = 50;
Brier = 0;
h = waitbar(0,'Calculating...');

for i = Games:-1:2
    j = 1;
    rFlag = 0;
    dFlag = 0;
    Flag = 0;
    
    while j <= TeamMax && Flag ==0      %The Teams list is cycled through, until both the radiant and dire teams have been found, and their Rating recorded
        if rFlag == 0       
            if strcmp(strtrim(Radiant(i)),Teams(j))~=0
                rELO = Ratings(j);
                rFlag = j;
            end
        end
        if dFlag == 0;
            if strcmp(strtrim(Dire(i)),Teams(j))~=0
                dELO = Ratings(j);
                dFlag = j;
            end
        end
        j = j+1;
        if rFlag >0 && dFlag >0 %This triggers a loop exit if both teams have been found
            Flag = 1;
        end
    end
    %The program now checks that a record was found for each team, and if
    %not adds it
    if rFlag == 0
        TeamMax = TeamMax + 1;
        Teams(TeamMax) = strtrim(Radiant(i));
        Ratings(TeamMax)= 1000;     %New teams automatically have a rating of 1000 for lazy reasons
        rELO = 1000;
        rFlag = TeamMax;
    end
    if dFlag == 0
        TeamMax = TeamMax + 1;
        Teams(TeamMax) = strtrim(Dire(i));
        Ratings(TeamMax)= 1000;
        dELO = 1000;
        dFlag = TeamMax;
    end
    rExp = 1/(1+10^((dELO-rELO)/400));  %The expected win probability for Radiant and Dire. I coppied this formula off Wikipedia, sue me.
    dExp = 1/(1+10^((rELO-dELO)/400));
    
    if strcmpi(Winner(i),'Radiant')~=0  %The change in rating is now calculated, and kept seperate so that these can be used to update individual records
        rGain(i)=K*(1-rExp);  
        dGain(i)=K*(0-dExp);
        Brier(i) = (rExp-1)^2; 
    else
        rGain(i)=K*(0-rExp);
        dGain(i)=K*(1-dExp);
        Brier(i) = (rExp-0)^2;
    end  
    
    rMMR(i) = rELO+rGain(i);    %The overall ratings are now updated as well
    Ratings(rFlag) = rMMR(i);
    dMMR(i)= dELO+dGain(i);
    Ratings(dFlag) = dMMR(i);
    clc
    waitbar(((Games-i-2)/DataSize(1)),h);
end

fprintf('Brier score is %f \n',sum(Brier)/Games)

%The data is now written to excel files!
%GameELO contains the columns that will be used to update the datdota game
%data file
%this code has never actually worked as the data size is too big
waitbar(0,h,'Writing results to file.');
xlswrite('gameELO.xlsx',rGain,strcat('A1:A',Games))
xlswrite('gameELO.xlsx',dGain,strcat('B1:B',Games))
xlswrite('gameELO.xlsx',rMMR,strcat('C1:C',Games))
xlswrite('gameELO.xlsx',dMMR,strcat('D1:D',Games))

%This just generates a simple file showing the team rankings. It is of no
%further interest apart from for science.
xlswrite('Rankings.xlsx',Teams,strcat('1:1'))
xlswrite('Rankings.xlsx',Ratings,strcat('2:2'))
close(h)