import os
import re
import tkinter as tk

from time import time
from tkinter import filedialog

mapdir = None

def select_file():
    root = tk.Tk()
    root.withdraw()  # Hide the root window

    file_path = filedialog.askopenfilename(
        title="Select any .osu beatmap file",
        filetypes=[("Osu beatmap files", "*.osu")]
    )

    if file_path:
        print("Selected map file: ", file_path)
        return file_path
    else:
        print("No file selected.")
        return None

shift = None
while not shift:
    try:
        shift = int(input("Enter shift value for offset (can be negative): "))
    except Exception:
        print("Could not convert to integer. Please, try again.")

mapfile = None
while not mapfile:
    mapfile = select_file()
mapdir = os.path.dirname(mapfile)

#latin_upper = tuple(chr(x) for x in range(65, 91))
#latin_lower = tuple(chr(x) for x in range(97, 123))

suffix = str(time()).replace(".", "")

currentSection = None
newbuf = ""
with open(mapfile, "r") as f:
    for line in f:
        line = line[:-1]  # Removing last LF to easily work with lines

        if not line:
            newbuf += "\n"  # Skipping the empty line
            continue

        if line.startswith("["):
            currentSection = line
            newbuf += line + "\n"  # Do not forget to add LF
            continue

        match currentSection:
            case "[General]":
                if line.startswith("PreviewTime"):
                    newbuf += "PreviewTime: " + str(int(line.split(":")[1]) + shift)
                else:
                    newbuf += line
            case "[Editor]":
                if line.startswith("Bookmarks"):
                    newbuf += "Bookmarks: " + ",".join(str(int(x) + shift) for x in line.split(":")[1].split(","))
                else:
                    newbuf += line
            case "[Metadata]":
                if line.startswith("Version"):
                    newbuf += "Version:" + line.split(":")[1].strip() + suffix
                else:
                    newbuf += line
            case "[Difficulty]":
                newbuf += line
            case "[Events]":
                if line.startswith("  "):
                    newbuf += line
                elif line.startswith("2,"):
                    newbuf += "2," + ",".join(str(int(x) + shift) for x in line.split(",")[1:])
                elif line.startswith(" L,"):
                    split = line.split(",")
                    newbuf += " L," + str((int(split[1]) + shift)) + "," + split[2]
                elif line.startswith(" T,"):
                    newbuf += line
                elif len(line) > 6 and line[0] == " " and line[1].isalpha():
                    split = line.split(",")
                    if split[2] == "0":
                        # Lets assume it is a static background or smth
                        newbuf += line  #(str(int(split[3]) + shift) if split[3] else "")
                    else:
                        newbuf += ",".join(split[0:2]) + "," + str(int(split[2]) + shift) + \
                                  "," + (str(int(split[3]) + shift) if split[3] else "") + \
                                  "," + ",".join(split[4:])
                elif line.startswith("Sample"):
                    split = line.split(",", 2)
                    newbuf += "Sample," + str(int(split[1]) + shift) + "," + split[2]
                else:
                    newbuf += line
            case "[TimingPoints]":
                split = line.split(",", 1)
                newbuf += str(int(split[0]) + shift) + "," + split[1]
            case "[Colours]":
                newbuf += line
            case "[HitObjects]":
                split = line.split(",")
                if split[3] == "12":  # Spinner
                    newbuf += ",".join(split[0:2]) + "," + str(int(split[2]) + shift) + \
                              "," + ",".join(split[3:5]) + "," + str(int(split[5]) + shift) + \
                              "," + split[-1]
                else:  # Does not matter anymore
                    newbuf += ",".join(split[0:2]) + "," + str(int(split[2]) + shift) + \
                              "," + ",".join(split[3:])
            case None:
                newbuf += line  # Adding everything before first section occurence
        newbuf += "\n"  # Do not forget to add LF

map_filename = mapfile.split(".")[0]
with open(os.path.join(mapdir, map_filename.replace("]", f"{suffix}].osu")), "w") as outfile:
    outfile.write(newbuf)

