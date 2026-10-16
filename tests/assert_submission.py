#!/usr/bin/env python3
"""Assert on the last form submission recorded by tests/mock_form_server.py.

    python3 tests/assert_submission.py requests.jsonl \
        --fields entry.1001,entry.1002 --equals entry.1001=me@example.com
"""

import argparse
import json
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("log", help="JSON-lines file written by mock_form_server.py")
    parser.add_argument("--count", type=int, help="expected total number of submissions")
    parser.add_argument("--fields", help="comma-separated entry IDs that must be exactly the submitted set")
    parser.add_argument("--equals", action="append", default=[], metavar="ENTRY=VALUE")
    args = parser.parse_args()

    try:
        with open(args.log) as fh:
            submissions = [json.loads(line) for line in fh if line.strip()]
    except FileNotFoundError:
        submissions = []

    errors = []
    if args.count is not None and len(submissions) != args.count:
        errors.append(f"expected {args.count} submission(s), got {len(submissions)}")
    if not submissions:
        errors.append("no submissions recorded")
    else:
        fields = submissions[-1]["fields"]
        print(f"last submission: {json.dumps(fields, indent=2)}")
        if args.fields is not None:
            expected = set(filter(None, args.fields.split(",")))
            if set(fields) != expected:
                errors.append(f"unexpected field set: missing={sorted(expected - set(fields))} extra={sorted(set(fields) - expected)}")
        for item in args.equals:
            key, _, value = item.partition("=")
            if fields.get(key) != value:
                errors.append(f"{key}: expected {value!r}, got {fields.get(key)!r}")
        empty = [k for k, v in fields.items() if not v]
        if empty:
            errors.append(f"empty values submitted for {empty}")

    for err in errors:
        print(f"ERROR: {err}", file=sys.stderr)
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
