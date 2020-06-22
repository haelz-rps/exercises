import re, pyperclip
""""

EXEMPLOS DE CORRESPONDÊNCIA DE PADRÕES COM EXPRESSÕES REGULARES.

Revisão dos símbolos de regex
• ? corresponde a zero ou uma ocorrência do grupo anterior.
• * corresponde a zero ou mais ocorrências do grupo anterior.
• + corresponde a uma ou mais ocorrências do grupo anterior.
• {n} corresponde a exatamente n ocorrências do grupo anterior.
• {n,} corresponde a n ou mais ocorrências do grupo anterior.
• {,m} corresponde a zero até m ocorrências do grupo anterior.
• {n,m} corresponde a no mínimo n e no máximo m ocorrências do grupo anterior.
• {n,m}? ou *? ou +? faz uma correspondência nongreedy do grupo anterior.
• ^spam quer dizer que a string deve começar com spam.
• spam$ quer dizer que a string dever terminar com spam.
• . corresponde a qualquer caractere, exceto os caracteres de quebra de linha.
• \d, \w e \s correspondem a um dígito, um caractere de palavra ou um
caractere de espaço, respectivamente.
• \D, \W e \S correspondem a qualquer caractere, exceto um dígito, um
caractere de palavra ou um caractere de espaço, respectivamente.
• [abc] corresponde a qualquer caractere que estiver entre os colchetes (por
exemplo, a, b ou c).
• [^abc] corresponde a qualquer caractere que não esteja entre os colchetes.
"""

def isPhoneNumber(text):
    if len(text) != 12:
        return False
    for i in range(0,3):
        if not text[i].isdecimal():
            return False
    if text[3] != '-':
        return False
    for i in range(4,7):
        if not text[i].isdecimal():
            return False
    if text[7] != '-':
        return False
    for i in range(8,12):
        if not text[i].isdecimal():
            return False
    return True

message = 'Call me at 415 555-1011 tomorrow. 415 555-9999 is my office'

for i in range(len(message)):
    chunk = message[i:i+12]
    if isPhoneNumber(chunk):
        print(i)
        print(f'Phone number found: {chunk}')
print('Done')

phoneNumRegex = re.compile(r'(\(?\d{3}\)?) (\d{3}-\d{4})')
buscanumero = phoneNumRegex.search(message)
print(buscanumero.group())

heroRegex = re.compile(r'Batman|Tina Fey')
hero = heroRegex.findall('Batman and Tina Fey')

batRegex = re.compile(r'Bat(man|mobile|copter|bat|car)')
hero2 = batRegex.search('Batmobile lost a whell')

batRegex2 = re.compile(r'Bat(wo)?man')
hero3 = batRegex2.search('The adventure of Batman')
hero4 = batRegex2.search('The adventure of Batwoman')

batRegex3 = re.compile(r'Bat(wo)*man')
hero5 = batRegex3.search('The Adventure of Batman')
hero6 = batRegex3.search('The Adventure of Batwoman')
hero7 = batRegex3.search('The Adventure of Batwowowowowowoman')

haRegex = re.compile(r'(Ha){3}')
mo1 = haRegex.search('HaHaHa')
mo2 = haRegex.search('Ha')

greedyHaRegex = re.compile(r'(Ha){3,5}')
mo3 = greedyHaRegex.search('HaHaHaHaHa')

nongreedyHaRegex = re.compile(r'(Ha){3,5}?')
mo4 = nongreedyHaRegex.search('HaHaHaHaHa')

phoneNumRegex2 = re.compile(r'\d\d\d-\d\d\d-\d\d\d\d')
num = phoneNumRegex2.search('Cell: 415-555-9999 Work: 212-555-0000')
phoneNumRegex3 = re.compile(r'\d\d\d-\d\d\d-\d\d\d\d')
num2 = phoneNumRegex3.findall('Cell: 415-555-9999 Work: 212-555-0000')

phoneNumRegex4 = re.compile(r'(\d\d\d)-(\d\d\d)-(\d\d\d\d)')
num3 = phoneNumRegex4.findall('Cell: 415-555-9999 Work: 212-555-0000')

xmasRegex = re.compile(r'\d+\s\w+')
mo5 = xmasRegex.findall('12 drummers, 11 pipers, 10 lords, 9 ladies, 8 maids, 7 swans, 6 geese, 5 rings, 4 birds, 3 hens, 2 doves, 1 partridge')

vowelRegex = re.compile(r'[aeiouAEIOU]')
vogal = vowelRegex.findall('RoboCop eats baby food. BABY FOOD.')

consonantRegex = re.compile(r'[^aeiouAEIOU]')
consonat = consonantRegex.findall('RoboCop eats baby food. BABY FOOD.')

beginsWithHello = re.compile(r'^Hello')
begin = beginsWithHello.search('Hello world!')
begin2 = beginsWithHello.search('He said hello')

endsWithNumber = re.compile(r'\d$')
number = endsWithNumber.search('Your number is 42')
number2 = endsWithNumber.search('Your number is forty two')

wholeStringIsNum = re.compile(r'^\d+$')
numberString = wholeStringIsNum.search('1234567890')
numberString2 = wholeStringIsNum.search('1234567 sdad2 asbdaus172e12 890')

atRegex = re.compile(r'.at')
at = atRegex.findall('The cat in the hat sat on the flat mat.')

nameRegex = re.compile(r'First Name:(.*) Last Name: (.*)')
name = nameRegex.search('First Name: Al Last Name: Sweigart')

nongreedyNameRegex2 = re.compile(r'<.*?>')
name2 = nongreedyNameRegex2.search('<To serve man> for dinner.>')

greedyNameRegex = re.compile(r'<.*>')
name3 = greedyNameRegex.search('<To serve man> for dinner>')

noNewlineRegex = re.compile(r'.*')
newline = noNewlineRegex.search('Serve the public trust.\nProtect the innocent.\nUphold the law.')

noNewlineRegex2 = re.compile('.*',re.DOTALL)
newline2 = noNewlineRegex2.search('Serve the public trust.\nProtect the innocent.\nUphold the law.')

robocop = re.compile(r'robocop',re.I)
robo1 = robocop.search('RoboCop is part man, part machine, all cop.')
robo2 = robocop.search('ROBOCOP protects the innocent')
robo3 = robocop.search('Al, why does your programming book talk about robocop so much?')

namesRegex = re.compile(r'Agent \w+')
names = namesRegex.sub('CENSORED','Agent Alice gave the secret documents to Agent Bob.')

namesRegex2 = re.compile(r'Agent (\w)\w*')
names2 = namesRegex2.sub(r'\1****','Agent Alice told Agent Carol that Agent Eve knew Agent Bob was a double agent.')

phoneRegex5 = re.compile(r'''(
(\d{3}|\(\d{3}\))?
# código de área
(\s|-|\.)?
# separador
\d{3}
# primeiros 3 dígitos
(\s|-|\.)
# separador
\d{4}
# últimos 4 dígitos
(\s*(ext|x|ext.)\s*\d{2,5})? # extensão
)''', re.VERBOSE)

someRegexValue = re.compile('foo',re.IGNORECASE|re.DOTALL|re.VERBOSE)

"""
Exemplos práticos: Extrator de números de telefone e de endereços de email:
• Obter o texto do clipboard.
• Encontrar todos os números de telefone e os endereços de email no texto.
• Colá-los no clipboard.
    Agora você poderá começar a pensar em como isso funcionará no código. O
código deverá fazer o seguinte:
• Usar o módulo pyperclip para copiar e colar strings.
• Criar duas regexes: uma para corresponder a números de telefone e outra
para endereços de email.
• Encontrar todas as correspondências, e não apenas a primeira, para ambas as
regexes.
• Formatar as strings correspondentes de forma elegante em uma única string
a ser colada no clipboard.
• Exibir algum tipo de mensagem caso nenhuma correspondência tenha sido
encontrada no texto.
"""

phoneNumberRegex = re.compile(r'''(
    (\d{3}|\(\d{3}\))?
    (\s|-|\.)?
    \d{3}
    (\s|-|\.)
    \d{4}
    (\s*(ext|x.|ext.)\s*\d{2,5})?
    )''',re.VERBOSE)

findEmailRegex = re.compile(r'([a-zA-Z0-9_%+-]+@[a-zA-Z0-9.-]+(\.[a-zA-Z]{2,4}))',re.VERBOSE)

text = str(pyperclip.paste())
matches = []

def procuraemailfone():
    for groups in findEmailRegex.findall(text):
        phoneNum = '-'.join([groups[1], groups[3], groups[5]])
        if groups[8] != '':
            phoneNumber += 'x'+groups[8]
        matches.append(phoneNumber)
    for groups in findEmailRegex.findall(text):
        matches.append(groups[0])

    if len(matches) > 0:
        pyperclip.copy('\n'.join((matches)))
        print('Copied to clipboard: ')
        print('\n'.join(matches))
    else:
        print(f"No phone numbers or email addresses found.")