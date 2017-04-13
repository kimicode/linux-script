
# file: gen_file.py

path_dir='f:/temp_me/python'

def gen_file(file_count):
    for file_item in range(1,file_count):
        temp_full_path=path_dir+'/'+str(file_item)+'.txt'
        temp_file=open(temp_full_path,'w')
        temp_file.write('Count is: ['+str(file_item)+']')
        print('File create successful: ['+temp_full_path+']')

gen_file(10)