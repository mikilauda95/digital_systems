import sys

a = raw_input("insert the text: \n")

print(type(a))

f = open("test.txt", "w")

f.write(a)

f.close()

f = open("test.txt", "r")

b = f.read()
print(b)
f.close()
