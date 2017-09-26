% Data clean up
% Init

clear ; close all; clc ;
disp('----- AIR QUALITY DATA CLEAN UP -----');
disp('-----1. Processing WeatherData -----');
%filename = './Data/Weather/Weather_Data(2015-2017 Measured at TSN_AP.xlsx'

fileList = dir('./Data/Weather/*.xlsx');
filename = strcat(fileList(1).folder,'/',fileList(1).name);
weatherTable = readtable(filename);
fprintf('Load table size \n');
weatherTable.Properties.VariableNames{'x7'} = 'Date'; % fix name
size(weatherTable)



disp('-----2. Processing US_data-----');
%[No,Site,Param,Date,Year,Month,Day,Hour,...]
fileList = dir('./Data/US/*.csv');
UStbl = [];
for i = 1: size(fileList,1)
	filename = strcat(fileList(i).folder,'/',fileList(i).name)
	US_data = readtable(filename);
	iv = find( ~(strcmp(US_data.QCName,'Valid')));
	fprintf('Clear %d invalid reading \n', length(iv));
	US_data(iv,:) = [];
%	UStbl = vertcat(UStbl,US_data);
%	size(UStbl)
end	
% transform to average day at US_data 
usDataOut = [];
aveDay = [];
dayV = datetime();
while(size(US_data,1) > 0)
	y = US_data.Year(1);
    m = US_data.Month(1);
    d = US_data.Day(1);

    % filter valid data in day
    v = find((US_data.Year == y) & (US_data.Month == m) & (US_data.Day == d));

    dayV(end+1) = datetime(y,m,d,'Format','d-MMM-y');
    aveDay(end+1) = mean(US_data.RawConc_(v));
    US_data(v,:) = [];
end

dayV(1) = []; % clean up first element
usTable = table;
usTable.Date = dayV';
usTable.mass_aveDay_US = aveDay';
%Create usTable with timestamp
% Join weather and US table by TimeStamp

Out = outerjoin(weatherTable,usTable,'MergeKeys',true);


disp('-----3. Processing ISTable-----');

filename = './Data/IS/ISHCMC Pollution Readings.xlsx';
sheetname = ["1617", "1718"];

for s = 1:size(sheetname,2)
	sheetname(s)
	%[Date,mass,count]
	ISTable = readtable(filename,'Sheet',sheetname(s));
	ISTable.Properties.VariableNames{'Month_Day_Year'} = 'Date';
	ISTable.Date = datetime(ISTable.Date);
	ISTable.Properties.VariableNames{2} = 'mass_IS';
	ISTable.Properties.VariableNames{3} = 'count_IS';

	% clean up empty data
	i = 1;
	cnt = 0 ;
	while(i <= size(ISTable,1))
		if(isnat(ISTable.Date(i)) || isnan(ISTable.mass_IS(i)) || ISTable.mass_IS(i) == 0 )
			cnt = cnt + 1;
			ISTable(i,:) = [];
		else
			i = i + 1;	
		end
	end
	if(~isnumeric(ISTable.count_IS))	% convert to number if input is string
		ISTable.count_IS = cellfun(@str2num,ISTable.count_IS);
	end
	fprintf('Rows Removed: %d\n', cnt);
	Out = outerjoin(Out,ISTable(:,1:3),'MergeKeys',true);

end
disp('-----4. Processing DYLOS Data-----');
% create temp table
mass_aveDay_DylosV1 = 0;
mass_aveDay_DylosV2 = 0;

fileList = dir('./Data/Dylos/*.txt');

k = 1;
datetbl = datetime('now','Format','d-MMM-y');
aveDay1 = [];
aveDay2 = [];
d1  = datetime('now','Format','d-MMM-y');
a1 = [];
a2 = [];
% merge all txt file
while(k < size(fileList,1) )
	file = strcat(fileList(k).folder,'/',fileList(k).name)
	dylosData = readtable(file);
	[y,m,d] = (ymd(dylosData.Date_Time));
	if( y < 2000)
		y = y + 2000;
	end
	dateV = datetime(y,m,d,'Format','d-MMM-y');
	dylosData.Date_Time = dateV;
	d1 = [d1, dylosData.Date_Time'];
	a1 = [a1, dylosData.Small'];
	a2 = [a2, dylosData.Large'];
	k = k + 1;
end
	d1(:,1) = [];

% calculate average  
while(size(d1,2) > 0)
	t = d1(1,1);

    % filter valid data in day
    v = find(d1(1,:) == t);

    datetbl(end+1) = t;
    aveDay1(end+1) = mean(a1(1,v));
    aveDay2(end+1) = mean(a2(1,v));

    d1(:,v) = [];
    a1(:,v) = [];
    a2(:,v) = [];

end
datetbl(:,1) = [];
dylosTable = table(datetbl',aveDay1',aveDay2','VariableNames',{'Date' 'aveDay_Dylos_Small' 'aveDay_Dylos_Large'});
% Join weather and US table by TimeStamp
Out = outerjoin(Out,dylosTable,'MergeKeys',true);
disp('-----5. Processing LaserEgg Data-----');
laserEggTable = readtable('./Data/LaserEgg/Consolidate June-July 2017.xlsx','Sheet','Duplicates removed');
laserEggTable.Properties.VariableNames{1} = 'Date';
% clean up data empty row 
i = 1;
cnt = 0 ;
while(i <= size(laserEggTable,1))
	if(isnat(laserEggTable.Date(i)) || string(laserEggTable.Pm2_5(i)) == '-' || string(laserEggTable.Pm10(i)) == '-')
		cnt = cnt + 1;
		laserEggTable(i,:) = [];
	else
		i = i + 1;	
	end
end
fprintf('Rows Removed: %d\n', cnt);

% transform to average day at DylosData 

i = 1;
aveDayPM2 = [];	
aveDayPM10 = [];	
dayV = datetime();
while(i < size(laserEggTable,1))
	[y,m,d]= ymd(laserEggTable.Date(i));
	[yy,mm,dd] = ymd(laserEggTable.Date(i+1));
	j = 1;
		sumPM2  = str2double(laserEggTable.Pm2_5(i));
		sumPM10 = str2double(laserEggTable.Pm10(i));
	while( (y == yy) && (m == mm) && (d == dd))
		sumPM2 = sumPM2 + str2double(laserEggTable.Pm2_5(i+j));
		sumPM10 = sumPM10 + str2double(laserEggTable.Pm10(i+j));
		j = j + 1;
		if((i + j) <= size(laserEggTable,1))
			[yy,mm,dd] = ymd(laserEggTable.Date(i + j));
		else
			break
		end
	end
    aveDayPM2(end+1) = sumPM2/ j;
    aveDayPM10(end+1) = sumPM10/ j;
    dayV(end+1) = datetime(y,m,d);
	i = i + j;
end
dayV(1) = []; % clean up first element

laserEggTable = table(dayV',aveDayPM2',aveDayPM10','VariableNames',{'Date' 'LE_Pm2_5' 'LE_Pm10'});

% Join weather and US table by TimeStamp
Out = outerjoin(Out,laserEggTable,'MergeKeys',true);

disp('----- EXPORT CSV file --------');
writetable(Out,'data.csv')

%----------- END ----------------------


