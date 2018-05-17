import subprocess
import os
import pandas as pd

myCWD = r"C:\Users\Taylor\AppData\Local\Programs\Python\Python35"
input_dir = r"D:\OneDrive\Documents\Graduate School\2017 Fall\CS 478\NHANES\cdc\2015"

def convert1(old_file, new_file):
    p = subprocess.Popen(["python",  "-m",  "xport", old_file, ">", new_file], cwd=myCWD, shell=True)
    print(p.communicate()[0],p.returncode)

for root, subdir, files in os.walk(input_dir):
    print(root)
    for f in files:
        f = f[:-4] + f[-4:].lower()
        if f[-4:] != ".xpt":
            continue
        #print(f)
        old_file = os.path.join(root, f)
        new_file = old_file.replace(".xpt", ".csv")

        df = pd.read_sas(old_file)
        df = pd.read_sas(
        stop

        if not os.path.isfile(new_file):
            print(new_file)
            #convert1(old_file, new_file)


