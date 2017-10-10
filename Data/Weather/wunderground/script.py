# http://api.wunderground.com/api/950403caef5d2406/
# history_YYYYMMDD/q/CA/San_Francisco.json 

# python script get data
import requests
import json
import calendar
import datetime as dt
import pdb # for debug

# some const
site = "http://api.wunderground.com/api/"
api_key = "950403caef5d2406"
feature = "history_"
date = "20161228" # YYYYMMDD
query = "VVTS"
pws = "pws:IHOCHIMI5" # IHOCHIMI5,I65BINHH2, 
extension = "json"


def getDataByDay(date,location):
	url = site + api_key + '/' + feature + date + "/q/" + location+ "." + extension

#	json_data=open("sample.json").read()
	res = requests.get(url)

	if res.status_code != requests.codes.ok : 
#	if False : 
		print "InValid url\n"
		return None,None
	else: 
		print url
		json_data = json.loads(res.text)
		# PARSER OBSERVATION 
		#json_data = json.loads(json_data)
		st = json_data['history']['observations']
		label_hourly ="date,type,";
		row_hourly_list = [];
		if(len(st) > 0):
			for i in range(len(st)):
				t = st[i];
				time_stamp = t['date']['hour'] +':'+  t['date']['min']
				del t['date']
				del t['utcdate']
				row_hourly = date +"," + time_stamp + ","
				for key,value in t.items():
					if not value:
						value = 'NaN'
					row_hourly = row_hourly + value + ","
				row_hourly_list.append(row_hourly)
			for key in st[0]:
				label_hourly = label_hourly + key + ","
			label_hourly = label_hourly + "\n"
		else: 
			print "Date: " + date + "no observation recorded at " + query
			label_hourly = "NaN\n"

		# END OF OBSERVATION CODE

		st = json_data['history']['dailysummary'][0]; # list of only one dictionary
		label_daily = "date,type," ;
		row_daily  = date + ",daily," ;
		del st['date']
		for key,value in st.items():
			label_daily = label_daily + key + ","	
			if not value:
				value = 'NaN'
			row_daily = row_daily + value + "," 
		
		label_daily = label_daily + "\n"
		row_daily = row_daily + "\n"
		return label_daily,row_daily,label_hourly,row_hourly_list 

def getDataByYear(year, location):
	file_name_daily =  location + "_" + str(year) + "_daily" ".csv" # save hour 
	file_name_hourly = location + "_" + str(year) + "_hourly" ".csv" # save daily 
	w_label = 0	

	csv_daily = open(file_name_daily, "w") 
	csv_hourly = open(file_name_hourly, "w")
	#csv_hourly_writer = csv.writer(csv_hourly) 
	for month in range(1,12+1):
		weekday, month_num = calendar.monthrange(year,month)
		for day in range(1,month_num + 1):
			if dt.datetime(year,month,day) >= dt.datetime.now():
				print "Updated up to ..." + str(dt.datetime.now()) # end of 
				return 0
			else:
				date=str(year).zfill(4) + str(month).zfill(2) + str(day).zfill(2)
				label_daily,row_daily,label_hourly,row_hourly_list =  getDataByDay(date,location) 
			
				if w_label == 0 :
					csv_daily.write(label_daily)
					csv_hourly.write(label_hourly)
					w_label	 = 1
				csv_daily.write(row_daily)
				for i in range(len(row_hourly_list)):
					csv_hourly.write(row_hourly_list[i] + '\n')
def getLastestData(location):
	return 0 
# main program 

year = [2015, 2016, 2017]
pws = "VVTS" # station code

getDataByYear(year[2],pws)


