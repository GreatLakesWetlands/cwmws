import os
import sys
need_blank = False
filename = sys.argv[1]
print(os.path.basename(filename))
print("=" * len(os.path.basename(filename)))
print("")
for line in open(filename):
    if line.lstrip().startswith('#: '):
        print(line.lstrip()[3:].strip())
        need_blank = True
    else:
        if need_blank:
            print("")
            need_blank = False
