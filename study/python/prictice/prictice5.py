
print('A'.lower())
print('a'.upper())

def nomalize(name):
	return name[0:1].upper()+name[1:].lower()
b=nomalize('aSDceedD')

def nomalizemap(aaa):
	return map(nomalize,aaa)
c=nomalizemap(['aaa','QsssW','SssSSS'])
list(c)



