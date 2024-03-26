#!/usr/bin/env python3

# Import required modules.
import json
import csv
import xml.etree.ElementTree as ET
import argparse
from osgeo import ogr

# Read input arguments.
parser = argparse.ArgumentParser(description='Parse field domains from an ESRI file GDB, optionally writing to a csv file.', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('in_gdb', type=str, help='Path to the input gdb to parse.')
parser.add_argument('--tables', '-t', nargs='+', type=str, required=False, help='Field domain table(s) to parse. If not given, processes all found.')
parser.add_argument('--out_csv', '-o', type=str, required=False, help='Output file to write. If not given, prints result to std out')
args = parser.parse_args()
in_gdb = args.in_gdb
tables = args.tables
out_csv = args.out_csv

# Read gdb and iterate over tables.
ds = ogr.Open(in_gdb)
res = ds.ExecuteSQL('select * from GDB_Items')
res.CommitTransaction()
data = {}
for i in res:
    item = json.loads(i.ExportToJson())['properties']['Definition']
    if item:

        # Parse value domain values.
        xml = ET.fromstring(item)
        if xml.tag == 'GPCodedValueDomain2':
            vals = {}
            name = xml.find('DomainName').text
            if not tables or name in tables:
                for table in xml.iter('CodedValues'):
                    for child in table:
                        vals[child.find('Code').text] = child.find('Name').text
                data[name] = vals
res = None
ds = None

# Write to file, or print.
if out_csv and data:
    with open(out_csv, 'w', newline='') as out_file:
        writer = csv.writer(out_file)
        writer.writerow(['table', 'key', 'description'])
        for name, vals in data.items():
            for key, val in vals.items():
                writer.writerow([name, key, val])
else:
    for name, vals in data.items():
        print(name)
        for key, val in vals.items():
            print('\t{key}: {val}'.format(key=key, val=val))
        print()
