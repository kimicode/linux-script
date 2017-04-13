def multi_thousand(C):
    result=C*1000
    print('result is: '+str(result))
    return result

multi_thousand(3)

file = open('f:/temp_me/python/open_function_me.txt','w')
file.write('Hello world')
file.write('Oracle Open World')

def text_create(file_name,msg):
    path='f:/temp_me/python/'
    full_path=path+file_name+'.txt'
    file=open(full_path,'w')
    file.write(msg)
    file.close()
    print('Done')

def text_filter(word,censored_word='lame',changed_word='*'):
    return word.replace(censored_word,changed_word)

text_create('Hello','Adamhuan')

for i in range(1,11):
    for b in range(1,11):
        result_num=i+b
        print(str(b)+' + '+str(i)+' = '+str(result_num))

print('----------------------')
