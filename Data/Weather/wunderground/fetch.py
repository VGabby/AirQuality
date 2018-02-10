# python script get data
import requests
import json
import calendar
import datetime as dt
import pdb # for debug
import os,sys,re
import pandas as pd

# some const
site = "http://api.wunderground.com/api/"
api_key = "950403caef5d2406"
feature = "history_"
date = "20161228" # YYYYMMDD
query = "VVTS"
pws = "pws:IHOCHIMI5" # IHOCHIMI5,I65BINHH2, 
extension = "json"

def get_json(location,date):
    filename = extension + "/" + location + "_" + date + ".json"
    if os.path.exists(filename):
        #print (filename +" existed, skip this date")
        pass
    else:
        url = site + api_key + '/' + feature + date + "/q/" + location+ "." + extension
        res = requests.get(url)
        if res.status_code != requests.codes.ok :
                print("InValid url\n")
        else:
            print ("Downloading json at url : " + url)
            json_data = json.loads(res.text)
            with open(filename, 'w') as f:
                json.dump(json_data, f, ensure_ascii=False, indent=4,separators=(',',': '))
def make_csv():
    json_files = sorted(os.listdir("./json/"))
    obser_frames = pd.DataFrame()
    daily_frames = pd.DataFrame()
    for j_file in json_files:
        if j_file.endswith("json"):
            print ("Processing file: {}".format(j_file))
            input_file = open("./json/"+j_file, "r")
            raw_data = json.loads(input_file.read())
            print ("No of observation: ", len(raw_data['history']['observations']))
            print ("No of dailysum: ",len(raw_data['history']['dailysummary']))
            df_o = pd.DataFrame.from_dict(raw_data['history']['observations'])
            df_d = pd.DataFrame.from_dict(raw_data['history']['dailysummary'])
            obser_frames = pd.concat([obser_frames,df_o])
            daily_frames = pd.concat([daily_frames,df_d])
    #Move date and utcdate to up front
    obser_frames = obser_frames.reindex(columns = sorted(obser_frames.columns))
    obser_frames = obser_frames.reindex(columns=(['utcdate'] + list([a for a in obser_frames.columns if a != 'utcdate']) ))
    obser_frames = obser_frames.reindex(columns=(['date'] + list([a for a in obser_frames.columns if a != 'date']) ))

    daily_frames = daily_frames.reindex(columns = sorted(daily_frames.columns))
    daily_frames = daily_frames.reindex(columns=(['date'] + list([a for a in daily_frames.columns if a != 'date']) ))
    # write to csv file

    obser_frames.to_csv('./VVTS_observations.csv')
    daily_frames.to_csv('./VVTS_daily.csv')
if __name__ == '__main__':
    location ="VVTS"
    print ("location = {}".format(location))
    print ("==================BEGIN=====================")
    for delta in range (1,3*365+40):
        date =(dt.date.today()-dt.timedelta(days=delta))
        date = date.strftime('%Y%m%d')
        get_json(location,date)
    print ("===================END=========================")

    print ("============Make CSV file============")
    make_csv()
    print ("============END CSV file============")

