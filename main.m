clear;
disp('----- AIR QUALITY DATA CLEAN UP -----');
disp('-----1. Processing WeatherData -----');
weatherTable = readtable('./Data/DS1.xlsx','Sheet','Weather');
size(weatherTable)


disp('-----2. Processing US_data-----');
%[No,Site,Param,Date,Year,Month,Day,Hour,...]
US_data = readtable('./Data/DS1.xlsx','Sheet','US_data');
% transform to average day at US_data 
i = 1;
j = 1;
usDataOut = [];
aveDay = [];
dayV = datetime();
while(i < size(US_data,1))
	y = US_data.Year(i);
    m = US_data.Month(i);
    d = US_data.Day(i);
    h = US_data.Hour(i);
    j = 1;
    sumDay = US_data.RawConc_(i);
    while(d == US_data.Day(i+j))
    	sumDay = sumDay + US_data.RawConc_(i+j);
    	j = j + 1;
    end 
    aveDay(end+1) = sumDay / j;
    dayV(end+1) = datetime(y,m,d);
    i = i + j;	
end
	dayV(1) = []; % clean up first element
	usTable = table;
	usTable.Date = dayV';
	usTable.mass_aveDay_US = aveDay';
%Create usTable with timestamp
% Join weather and US table by TimeStamp
Out = outerjoin(weatherTable,usTable,'MergeKeys',true);
disp('-----3. Processing ISTable-----');
%[Date,mass,count]
ISTable = readtable('./Data/DS1.xlsx','Sheet','IS_data');
ISTable.Properties.VariableNames{'Month_Day_Year'} = 'Date';
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
fprintf('Rows Removed: %d\n', cnt);

% Join weather and US table by TimeStamp
Out = outerjoin(Out,ISTable,'MergeKeys',true);
disp('-----4. Processing DYLOS Data-----');
% create temp table
DateV = datetime();
mass_aveDay_DylosV1 = 0;
mass_aveDay_DylosV2 = 0;

fileList = dir('./Data/Dylos/*.txt');

k = 1;
while(k <= size(fileList,1))
	file = strcat(fileList(k).folder,'/',fileList(k).name);
	dylosData = readtable(file);
	% transform to average day at DylosData 

	i = 1;
	aveDay1 = [];	
	aveDay2 = [];	
	dayV = datetime();
	while(i < size(dylosData,1))
		[y,m,d]= ymd(dylosData.Date_Time(i));
		[yy,mm,dd] = ymd(dylosData.Date_Time(i+1));
		sumDay1 =  dylosData.Small(i);
		sumDay2 =  dylosData.Large(i);
		j = 1;
		while( (y == yy) && (m == mm) && (d == dd))
			sumDay1 = sumDay1 + dylosData.Small(i+j);
			sumDay2 = sumDay2 + dylosData.Large(i+j);
			j = j + 1;
			if((i + j) <= size(dylosData,1))
				[yy,mm,dd] = ymd(dylosData.Date_Time(i + j));
			else
				break
			end
		end
		sumDay1 = sumDay1 / j ;
		sumDay2 = sumDay2 / j ;
	    aveDay1(end+1) = sumDay1 / j;
	    aveDay2(end+1) = sumDay2 / j;
	    y = y + 2000 ; % fix later !
	    dayV(end+1) = datetime(y,m,d);
		i = i + j;
	end
	dayV(1) = []; % clean up first element

	DateV = horzcat(DateV,dayV);
	mass_aveDay_DylosV1 = horzcat(mass_aveDay_DylosV1,aveDay1);
	mass_aveDay_DylosV2 = horzcat(mass_aveDay_DylosV2,aveDay2);
	k = k + 1
end
% merge to DylosTable
dylosTable = table(DateV',mass_aveDay_DylosV1',mass_aveDay_DylosV2','VariableNames',{'Date' 'aveDay_Dylos_Small' 'aveDay_Dylos_Large'});

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


