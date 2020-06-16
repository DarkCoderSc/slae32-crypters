#!/usr/bin/python3

'''
	Jean-Pierre LESUEUR (@DarkCoderSc)
	SLAE32 - Assignment N°7 (Crypters)
	Description:
		This python script will build both crypter & stub application.
		It is important to use this script since it will patch the crypter source code 
		with the latest stub version.
	---

	Requires Lazarus IDE to be installed.

	sudo apt install lazarus
'''

import os
import sys

#
# Define target projects / files
#
stub_dir         = "stub"
stub_project     = "stub.dpr"
crypter_dir      = "crypter"
crypter_project  = "crypter.dpr"
crypter_stub_res = "untstub.pas"
shared_dir       = "shared"

#
# Log Defs
#
def success(message):
    print("[\033[32m+\033[39m] " + message)

def err(message):
    print("[\033[31m-\033[39m] " + message)

def warn(message):
    print("[\033[33m!\033[39m] " + message)

def info(message):
	print("[\033[34m*\033[39m] " + message)


#
# Compile Projects
#

fpc_template = "fpc -MObjFPC -Scghi -O1 -g -gl -l -vewnhibq -Fu../shared -Fu. -FUlib/i386-linux {}"

os.chdir(stub_dir)

# Stub
info("Compile stub project...")

ret = os.system(fpc_template.format(stub_project))
if (ret != 0):
	err(f"Could not compile stub project with error={ret}")

	sys.exit(1)

success("Stub project successfully built.")

 
# Patch stub
info("Patch stub file on crypter project...")

os.chdir("..")
os.chdir(crypter_dir)

stub_res_file = open(crypter_stub_res, 'r').read()

tag_begin = "{#STUB_BEGIN#}"
tag_end = "{#STUB_END#}"

index_beg = stub_res_file.find(tag_begin, 0)

info("Finding tags locations")

if (index_beg == -1):
	err("Could not find stub begin tag.")

	sys.exit(1)	

index_end = stub_res_file.find(tag_end, index_beg)

if (index_end == -1):
	err("Could not find stub end tag.")

	sys.exit(1)	

success(f"Tags found. tag_begin={index_beg}, tag_end={index_end}")

array_template = "const stub : array[0..{}-1] of byte = (\r\n{}\r\n);"

info("Generate stub array...")

stub_raw = open(f"../{stub_dir}/stub", 'rb').read()

stub_size = len(stub_raw)
stub_matrix = ""

count = 0
pos = 0
for abyte in stub_raw:	
	stub_matrix += "{}".format(str(abyte).rjust(4))

	count += 1
	pos += 1

	if (pos < len(stub_raw)):
		stub_matrix += ","

	if (count >= 16) and (pos < len(stub_raw)):
		stub_matrix += "\r\n"
		count = 0

stub_array = array_template.format(stub_size, stub_matrix)

info("Patch stub source file...")

stub_res_file = stub_res_file[0:(index_beg + len(tag_begin))] + stub_array + stub_res_file[(index_end)::]

open(crypter_stub_res, "w").write(stub_res_file)

success("Stub source file successfully patched.")

info("Compile crypter project...")

ret = os.system(fpc_template.format(crypter_project))
if (ret != 0):
	err(f"Could not compile crypter project with error={ret}")

	sys.exit(1)

success("Crypter project successfully built.")

info("copy crypter to \"dist\" directory...")

ret = os.system("cp crypter ../dist/.")
if (ret != 0):
	err(f"Could not copy project to directory with error={ret}")

	sys.exit(1)

info("doing some cleanup...")

os.chdir("..")

# WARNING IF YOU UPDATE THIS PART

os.system(f"rm -rf {stub_dir}/lib/i386-linux/*")
os.system(f"rm -rf {crypter_dir}/lib/i386-linux/*")
os.system(f"rm -rf {stub_dir}/backup")
os.system(f"rm -rf {crypter_dir}/backup")
os.system(f"rm -rf {shared_dir}/backup")

# WARNING IF YOU UPDATE THIS PART

success("Crypter successfully compiled and is ready for use!")

info("Have fun :-)")
