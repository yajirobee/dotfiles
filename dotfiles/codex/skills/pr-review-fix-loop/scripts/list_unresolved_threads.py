#!/usr/bin/env python3
"""List every unresolved review thread for a GitHub pull request via gh."""

import argparse
import json
import subprocess
import sys
from typing import Any
from urllib.parse import unquote, urlsplit


_THREADS_QUERY = """
query($owner: String!, $name: String!, $number: Int!, $cursor: String) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      url
      headRefOid
      reviewThreads(first: 100, after: $cursor) {
        nodes {
          id
          isResolved
          path
          line
          comments(first: 100) {
            nodes {
              id
              body
              url
              createdAt
              author { login }
            }
            pageInfo { hasNextPage endCursor }
          }
        }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}
"""

_COMMENTS_QUERY = """
query($thread: ID!, $cursor: String) {
  node(id: $thread) {
    ... on PullRequestReviewThread {
      comments(first: 100, after: $cursor) {
        nodes {
          id
          body
          url
          createdAt
          author { login }
        }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}
"""

_HEAD_QUERY = """
query($owner: String!, $name: String!, $number: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) { headRefOid }
  }
}
"""


def _run_gh(*arguments: str) -> dict[str, Any]:
    try:
        result = subprocess.run(
            ["gh", *arguments],
            check=True,
            capture_output=True,
            text=True,
        )
    except FileNotFoundError:
        raise RuntimeError("gh is not installed or not available on PATH") from None
    except subprocess.CalledProcessError as error:
        message = error.stderr.strip() or error.stdout.strip() or f"gh exited with status {error.returncode}"
        raise RuntimeError(message) from None
    try:
        value = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise RuntimeError(f"gh returned invalid JSON: {error}") from error
    if not isinstance(value, dict):
        raise RuntimeError("gh returned an unexpected JSON value")
    return value


def _run_graphql(query: str, **variables: str | int | None) -> dict[str, Any]:
    arguments = ["api", "graphql", "-f", f"query={query}"]
    for name, value in variables.items():
        if value is None:
            continue
        arguments.extend(["-F" if isinstance(value, int) else "-f", f"{name}={value}"])
    return _run_gh(*arguments)


def _repository_from_pr_url(url: str) -> tuple[str, str]:
    parts = [unquote(part) for part in urlsplit(url).path.split("/") if part]
    try:
        pull_index = next(index for index in range(2, len(parts) - 1) if parts[index] == "pull")
    except StopIteration:
        raise ValueError(f"pull request URL has no /pull/ segment: {url}") from None
    return parts[pull_index - 2], parts[pull_index - 1]


def _pull_request(response: dict[str, Any]) -> dict[str, Any]:
    pull_request = response["data"]["repository"]["pullRequest"]
    if not isinstance(pull_request, dict):
        raise ValueError("GitHub did not return the requested pull request")
    return pull_request


def _paginate_comments(thread: dict[str, Any]) -> None:
    comments = thread["comments"]
    page_info = comments["pageInfo"]
    while page_info["hasNextPage"]:
        cursor = page_info["endCursor"]
        if not cursor:
            raise ValueError("GitHub reported more comments without an end cursor")
        response = _run_graphql(_COMMENTS_QUERY, thread=thread["id"], cursor=cursor)
        page = response["data"]["node"]["comments"]
        comments["nodes"].extend(page["nodes"])
        page_info = page["pageInfo"]
    comments["pageInfo"] = page_info


def _collect_threads(owner: str, name: str, number: int) -> tuple[str, str, list[dict[str, Any]]]:
    cursor: str | None = None
    expected_head: str | None = None
    pull_request_url: str | None = None
    all_threads: list[dict[str, Any]] = []

    while True:
        response = _run_graphql(
            _THREADS_QUERY,
            owner=owner,
            name=name,
            number=number,
            cursor=cursor,
        )
        pull_request = _pull_request(response)
        page_head = pull_request["headRefOid"]
        if expected_head is None:
            expected_head = page_head
            pull_request_url = pull_request["url"]
        elif page_head != expected_head:
            raise RuntimeError("pull request head changed while threads were being collected; rerun the command")

        threads = pull_request["reviewThreads"]
        all_threads.extend(threads["nodes"])
        page_info = threads["pageInfo"]
        if not page_info["hasNextPage"]:
            break
        cursor = page_info["endCursor"]
        if not cursor:
            raise ValueError("GitHub reported more threads without an end cursor")

    unresolved_threads = [thread for thread in all_threads if not thread["isResolved"]]
    for thread in unresolved_threads:
        _paginate_comments(thread)

    final_response = _run_graphql(_HEAD_QUERY, owner=owner, name=name, number=number)
    final_head = _pull_request(final_response)["headRefOid"]
    if final_head != expected_head:
        raise RuntimeError("pull request head changed while comments were being collected; rerun the command")
    if not expected_head or not pull_request_url:
        raise ValueError("GitHub returned incomplete pull request metadata")
    return expected_head, pull_request_url, unresolved_threads


def _parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pr", help="Pull request number or URL; defaults to the current branch pull request")
    return parser.parse_args()


def main() -> int:
    arguments = _parse_arguments()
    pr_command = ["pr", "view"]
    if arguments.pr:
        pr_command.append(arguments.pr)
    pr_command.extend(["--json", "number,url"])

    try:
        selected_pull_request = _run_gh(*pr_command)
        owner, name = _repository_from_pr_url(selected_pull_request["url"])
        number = selected_pull_request["number"]
        head, pull_request_url, threads = _collect_threads(owner, name, number)
    except (KeyError, TypeError, ValueError, RuntimeError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    output = {
        "pull_request": {
            "number": number,
            "url": pull_request_url,
            "headRefOid": head,
        },
        "has_more_threads": False,
        "unresolved_threads": threads,
    }
    json.dump(output, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
