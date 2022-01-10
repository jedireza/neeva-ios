#!/usr/bin/python3

import json
import re
import sys

inputString = sys.stdin.read()


def parseEngineList(engines):
    return (
        engines
        #  remove indentation
        .replace("\n    &", "")
        #  strip trailing ",\n"
        [:-2]
        # split into list
        .split(",")
    )


engineLists = [
    {"code": code, "engines": parseEngineList(engines)}
    for (code, engines) in re.findall(
        r"const PrepopulatedEngine\* const engines_(?P<code>[^ ]+)\[\] = \{(?P<engines>[^}]+)\};",
        inputString,
    )
]

s = lambda t: t[0] + t[1]
countryMapping = {
    s(code): s(code)
    for code in re.findall(r"    DECLARE_COUNTRY\((.+?), (.+?)\)", inputString)
}

toInsert = []
for line in inputString.split("\n"):
    if line.startswith("    UNHANDLED_COUNTRY"):
        toInsert.append(
            s(re.match(r"    UNHANDLED_COUNTRY\((.+?), (.+?)\)", line).groups())
        )
    elif line.startswith("    END_UNHANDLED_COUNTRIES"):
        dest = s(
            re.match(r"    END_UNHANDLED_COUNTRIES\((.+?), (.+?)\)", line).groups()
        )
        for src in toInsert:
            countryMapping[src] = dest
        toInsert = []

json.dump({"engineLists": engineLists, "countryMapping": countryMapping}, sys.stdout)
