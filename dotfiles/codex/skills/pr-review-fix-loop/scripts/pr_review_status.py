#!/usr/bin/env python3
"""Report the latest completed Codex review for a pull request head commit."""

import argparse
import json
import re
import sys
from typing import Any


CODEX_LOGIN = "chatgpt-codex-connector"
REVIEWED_COMMIT = re.compile(r"\*\*Reviewed commit:\*\* `([0-9a-f]+)`", re.IGNORECASE)


def _latest_review(data: dict[str, Any], head: str) -> dict[str, Any] | None:
    reviews = [
        review
        for review in data.get("reviews", [])
        if review.get("author", {}).get("login") == CODEX_LOGIN
        and review.get("submittedAt")
        and review.get("commit", {}).get("oid") == head
    ]
    reviews.extend(
        {
            "state": "COMMENTED",
            "submittedAt": comment.get("createdAt"),
        }
        for comment in data.get("comments", [])
        if comment.get("author", {}).get("login") == CODEX_LOGIN
        and comment.get("createdAt")
        and (match := REVIEWED_COMMIT.search(comment.get("body", "")))
        and head.lower().startswith(match.group(1).lower())
    )
    return max(reviews, key=lambda review: review["submittedAt"], default=None)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--head", required=True, help="commit SHA to check")
    args = parser.parse_args()
    data = json.load(sys.stdin)
    review = _latest_review(data, args.head)
    result = {
        "head": args.head,
        "reviewed": review is not None,
        "state": review.get("state") if review else None,
        "submitted_at": review.get("submittedAt") if review else None,
    }
    print(json.dumps(result, ensure_ascii=False, separators=(",", ":")))


if __name__ == "__main__":
    main()
