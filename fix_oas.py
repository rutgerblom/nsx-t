#!/usr/bin/env python

import argparse
import collections
import sys
import yaml

def remove_qs_apis(input_file):
    sys.stdout.write("reading %s..." % input_file)
    sys.stdout.flush()
    y = yaml.load(open(input_file))
    sys.stdout.write(" done.\n")
    sys.stdout.flush()
    paths = y["paths"]
    new_paths = {}
    for path in paths:
        if "?" not in path:
            new_paths[path] = paths[path]
    y["paths"] = new_paths
    output_file = "%s.new" % input_file
    sys.stdout.write("writing %s..." % output_file)
    sys.stdout.flush()
    yaml.dump(y, open(output_file, "w"))
    sys.stdout.write(" done.\n")
    sys.stdout.flush()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input_file', type=str,
                        help='OpenAPI spec file to process')
    args = parser.parse_args()
    remove_qs_apis(args.input_file)

if __name__ == "__main__":
    sys.exit(main())