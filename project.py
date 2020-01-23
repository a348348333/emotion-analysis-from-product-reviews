from __future__ import print_function
import json
import csv
from ibm_watson import NaturalLanguageUnderstandingV1
from ibm_watson.natural_language_understanding_v1 import Features, SentimentOptions, KeywordsOptions, EmotionOptions
import praw
import datetime
import json
import cudf
import sys
import os

def get_date(time):
  #return time
  return datetime.datetime.fromtimestamp(time)

reddit = praw.Reddit(client_id='vmMtIVJAMSP2Zw',
                     client_secret='VY3t-1RomgQ91YFpo8zqPaXXKT4',
                     password='348348333',
                     user_agent='testscrip',
                     username='a348348333')

#print(reddit.user.me())
#print(reddit.read_only)
keyword = sys.argv[1]
folderpath = keyword.lower()
if os.path.isdir(folderpath):
  if os.path.isfile(folderpath+"/NLU.csv"):
    if os.path.isfile(folderpath+"/KEY.csv"):
      sys.exit()
else:
  try:
    os.makedirs(folderpath)
  except FileExistsError:
    print("error")
subreddit = reddit.subreddit('all')
search_python = subreddit.search(keyword,limit=None)
#conversedict = {}
df = {"time":[],
     "ups":[],
     "downs":[],
     "author":[],
     "score":[],
     "comms_num":[],
     "title":[],
     "body":[]}
numData = 0
for submission in search_python:
  if not submission.stickied:
    df["ups"].append(submission.ups)
    df["downs"].append(submission.downs)
    df["author"].append(submission.author.name)
    df["body"].append(submission.selftext)
    df["time"].append(get_date(submission.created_utc))
    df["title"].append(submission.title)
    df["score"].append(submission.score)
    df["comms_num"].append(submission.num_comments)
    numData += 1
#data_df = cudf.DataFrame(df)
#print(data_df.to_pandas().to_csv(keyword+'/'+keyword+'.csv', index=False))

natural_language_understanding = NaturalLanguageUnderstandingV1(
    version='2018-11-16',
    iam_apikey='tjuSDKzozH6xkacB9sj9o1Ke-TiRClcnpVTGvisJMtwo',
    url='https://gateway-tok.watsonplatform.net/natural-language-understanding/api'
)

df_nlu = {"time":[],
     "score":[],
     "sentiment":[],
     "sadness":[],
     "joy":[],
     "fear":[],
     "disgust":[],
     "anger":[]
     }

i = 0
for data in range(numData):
  #titleAndBody = row[6] + ' ' + row[7]
  #if(titleAndBody.lower().find(keyword.lower())!=-1): #ignore data without keyword
  response = natural_language_understanding.analyze(
      text = df['title'][data] + "\n" + df['body'][data],
      language = 'en',
      features=Features(sentiment=SentimentOptions(), emotion=EmotionOptions())).get_result()
  #print(json.dumps(response, indent=2))
  df_nlu["time"].append(df['time'][data])
  df_nlu["score"].append(df['score'][data])
  df_nlu["sentiment"].append(response["sentiment"]["document"]["score"])
  df_nlu["sadness"].append(response["emotion"]["document"]["emotion"]["sadness"])
  df_nlu["joy"].append(response["emotion"]["document"]["emotion"]["joy"])
  df_nlu["fear"].append(response["emotion"]["document"]["emotion"]["fear"])
  df_nlu["disgust"].append(response["emotion"]["document"]["emotion"]["disgust"])
  df_nlu["anger"].append(response["emotion"]["document"]["emotion"]["anger"])
  i+=1
data_df = cudf.DataFrame(df_nlu)
print(data_df.to_pandas().to_csv(keyword+'/NLU.csv', index=False))

df_key = {"keywords":[],
      "count":[],
      "relevance":[]
}
titleAndBody = ''
keyNum = 0
findKey=False
for data in range(numData):
  titleAndBody += df['title'][data] + "\n" + df['body'][data] + '\n'
  if(len(titleAndBody)>40000):
    response = natural_language_understanding.analyze(
        text = titleAndBody,
        language = 'en',
        features=Features(keywords=KeywordsOptions())).get_result()
    titleAndBody = ''
    for key in response['keywords']:
      findKey = False
      for text in range(keyNum):
        if(df_key["keywords"][text] == key['text']):
          df_key["count"][text] += key['count']
          df_key["relevance"][text] = (df_key["relevance"][text]+key['relevance'])/2
          findKey = True
          break
      if(findKey == False):
        df_key["keywords"].append(key['text'])
        df_key["count"].append(key['count'])
        df_key["relevance"].append(key['relevance'])
        keyNum += 1
    
response = natural_language_understanding.analyze(
        text = titleAndBody,
        language = 'en',
        features=Features(keywords=KeywordsOptions())).get_result()
titleAndBody = ''
for key in response['keywords']:
  findKey = False
  for text in range(keyNum):
    if(df_key["keywords"][text] == key['text']):
      df_key["count"][text] += key['count']
      df_key["relevance"][text] = (df_key["relevance"][text]+key['relevance'])/2
      findKey = True
      break
  if(findKey == False):
    df_key["keywords"].append(key['text'])
    df_key["count"].append(key['count'])
    df_key["relevance"].append(key['relevance'])
    keyNum += 1

data_df = cudf.DataFrame(df_key)
print(data_df.to_pandas().to_csv(keyword+'/KEY.csv', index=False))
