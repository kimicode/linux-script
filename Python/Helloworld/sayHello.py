what_he_does=' Plays '
his_instrument="guitar"
his_name="Robert Johnson"

artist_intro=his_name+what_he_does+his_instrument

print(artist_intro)

# -----------------------------

words_1="| big bang "
result=words_1*3+"|"
count_result=len(result)
print(result)
print("length of STRING: "+str(count_result))

# -----------------------------

numbers_1="420102199003158093"
hide_num=numbers_1.replace(numbers_1[:-4],'*'*14)
trans_num=numbers_1[-4:]
print("Number is --> "+str(numbers_1))
print("count is --> "+str(len(numbers_1)))
print("Change to --> "+hide_num)

# -----------------------------

search="168"
n_a="1368-168-008"
n_b="1683-212-008"

print("Number a --> "+str(n_a.find(search))+" and "+str(n_a.find(search)+len(search)))
print("Number b --> "+str(n_b.find(search))+" and "+str(n_b.find(search)+len(search)))

