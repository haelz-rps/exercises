import os, shelve, pprint

os.path.join('usr','local','bin')

myFiles = ['accounts.txt','details.csv','invite.docx']

for filename in myFiles:
    createFile = os.path.join('/tmp',filename)

os.getcwd()
os.chdir('/tmp')
os.getcwd()

directory = os.makedirs('/tmp/testepython')


##STRING COM O PATH ABSOLUTO.
os.path.abspath()
##Retorn True is path absoluto
os.path.isabs()
##String com o path relativo
os.path.realpath()

print(os.path.basename('/usr/local/bin'))
print(os.path.dirname('/usr/local/bin'))
print(os.path.split('/usr/local/bin'))
print(os.path.split('/usr/local/bin'))
x = '/usr/local/bin'
print(x.split(os.path.sep))


sizeDir = os.path.getsize('/home/raphael')
listaDir = os.listdir('/home/raphael')

totalSize = 0
for filename in listaDir:
    totalSize = totalSize + os.path.getsize(os.path.join('/home/raphael', filename))


"""
os.path.exists(path)
os.path.isfile(path) -> return True or False
os.path.isdir(path) -> return True if arg existir e se for uma pasta.
"""

helloFile = open('/tmp/testepython/teste.txt','a')
print(helloFile.write('bora la!\n'))
helloFile.close()
helloFile = open('/tmp/testepython/teste.txt')
print(helloFile.read())
helloFile.close()

shelFile = shelve.open('mydata')
cats = ['Zophie','Pooka','Simon']
shelFile['cats'] = cats
shelFile.close()

shelFile = shelve.open('mydata')
shelFile['cats']
shelFile.close()

dogs = [{
    'name': 'Zophie',
    'desc': 'chubby'},

    {'name': 'Pooka',
     'desc': 'fluffy'}
]

fileObj = open('mydata','w')
x = fileObj.write('dogs = ' + pprint.pformat(dogs) + '\n')
print(x)
fileObj.close()

Exercício 01

import random

capitais = {'Alabama': 'Montgomery', 'Alaska': 'Juneau', 'Arizona': 'Phoenix',
'Arkansas': 'Little Rock', 'California': 'Sacramento', 'Colorado': 'Denver',
'Connecticut': 'Hartford', 'Delaware': 'Dover', 'Florida': 'Tallahassee', 'Georgia':
'Atlanta', 'Hawaii': 'Honolulu', 'Idaho': 'Boise', 'Illinois': 'Springfield',
'Indiana': 'Indianapolis', 'Iowa': 'Des Moines', 'Kansas': 'Topeka', 'Kentucky':
'Frankfort', 'Louisiana': 'Baton Rouge', 'Maine': 'Augusta', 'Maryland': 'Annapolis',
'Massachusetts': 'Boston', 'Michigan': 'Lansing', 'Minnesota': 'Saint Paul',
'Mississippi': 'Jackson', 'Missouri': 'Jefferson City', 'Montana': 'Helena', 'Nebraska':
'Lincoln', 'Nevada': 'Carson City', 'New Hampshire': 'Concord', 'New Jersey': 'Trenton',
'New Mexico': 'Santa Fe', 'New York': 'Albany', 'North Carolina': 'Raleigh',
'North Dakota':'Bismarck', 'Ohio': 'Columbus', 'Oklahoma': 'Oklahoma City', 'Oregon':
'Salem', 'Pennsylvania': 'Harrisburg', 'Rhode Island': 'Providence', 'South Carolina':
'Columbia', 'South Dakota': 'Pierre', 'Tennessee': 'Nashville', 'Texas': 'Austin',
'Utah': 'Salt Lake City', 'Vermont': 'Montpelier', 'Virginia': 'Richmond', 'Washington':
'Olympia', 'West Virginia': 'Charleston', 'Wisconsin': 'Madison', 'Wyoming': 'Cheyenne'}

for quizNum in range(35):
    quizFile = open(f'teste/mydata{quizNum+1}','w')
    answerKeyFile = open(f'teste/mydata_answers{quizNum+1}','w')

    quizFile.write('Name:\n\nData:\n\nPeriod:\n\n')
    quizFile.write((''*20) + f'State Capitals Quiz (Form {quizNum+1})')
    quizFile.write('\n\n')

    states = list(capitais.keys())
    random.shuffle(states)

    for questionNum in range(50):
        correctAnswer = capitais[states[questionNum]]
        wrogesAnswer = list(capitais.values())
        del wrogesAnswer[wrogesAnswer.index(correctAnswer)]
        wrogesAnswer = random.sample(wrogesAnswer,3)
        answerOptions = wrogesAnswer + [correctAnswer]
        random.shuffle(answerOptions)

        quizFile.write('{} What is the capital of {}\n'.format(questionNum+1,states[questionNum]))
        for i in range(4):
            quizFile.write("{} {}\n".format('ABCD'[i],answerOptions[i]))
            quizFile.write('\n')
        answerKeyFile.write("{} {}\n".format(questionNum+1,'ABCD'[answerOptions.index(correctAnswer)]))
    quizFile.close()
    answerKeyFile.close()