#!/usr/bin/env python3
"""Regression tests for list_unresolved_threads.py."""

import importlib.util
from pathlib import Path
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).with_name("list_unresolved_threads.py")
SPEC = importlib.util.spec_from_file_location("list_unresolved_threads", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def _thread(thread_id: str, *, more_comments: bool = False, resolved: bool = False) -> dict:
    return {
        "id": thread_id,
        "isResolved": resolved,
        "path": "example.py",
        "line": 1,
        "comments": {
            "nodes": [{"id": f"{thread_id}-comment-1"}],
            "pageInfo": {"hasNextPage": more_comments, "endCursor": "comment-cursor"},
        },
    }


def _threads_page(nodes: list[dict], *, more: bool, head: str = "head-1") -> dict:
    return {
        "data": {
            "repository": {
                "pullRequest": {
                    "url": "https://github.example/acme/widgets/pull/7",
                    "headRefOid": head,
                    "reviewThreads": {
                        "nodes": nodes,
                        "pageInfo": {"hasNextPage": more, "endCursor": "thread-cursor"},
                    },
                }
            }
        }
    }


class RepositoryUrlTests(unittest.TestCase):
    def test_repository_comes_from_selected_pr_url(self) -> None:
        self.assertEqual(
            MODULE._repository_from_pr_url("https://github.com/another-owner/another-repo/pull/42"),
            ("another-owner", "another-repo"),
        )

    def test_owner_may_be_named_pull(self) -> None:
        self.assertEqual(
            MODULE._repository_from_pr_url("https://github.example/pull/widgets/pull/7"),
            ("pull", "widgets"),
        )


class PaginationTests(unittest.TestCase):
    def test_collects_all_thread_and_comment_pages(self) -> None:
        first = _thread("thread-1", more_comments=True)
        second = _thread("thread-2", resolved=True)
        responses = [
            _threads_page([first], more=True),
            _threads_page([second], more=False),
            {
                "data": {
                    "node": {
                        "comments": {
                            "nodes": [{"id": "thread-1-comment-2"}],
                            "pageInfo": {"hasNextPage": False, "endCursor": None},
                        }
                    }
                }
            },
            {"data": {"repository": {"pullRequest": {"headRefOid": "head-1"}}}},
        ]

        with patch.object(MODULE, "_run_graphql", side_effect=responses):
            head, url, threads = MODULE._collect_threads("acme", "widgets", 7)

        self.assertEqual(head, "head-1")
        self.assertEqual(url, "https://github.example/acme/widgets/pull/7")
        self.assertEqual([thread["id"] for thread in threads], ["thread-1"])
        self.assertEqual(
            [comment["id"] for comment in threads[0]["comments"]["nodes"]],
            ["thread-1-comment-1", "thread-1-comment-2"],
        )

    def test_rejects_snapshot_if_head_changes(self) -> None:
        responses = [
            _threads_page([], more=False),
            {"data": {"repository": {"pullRequest": {"headRefOid": "head-2"}}}},
        ]

        with patch.object(MODULE, "_run_graphql", side_effect=responses):
            with self.assertRaisesRegex(RuntimeError, "head changed"):
                MODULE._collect_threads("acme", "widgets", 7)


if __name__ == "__main__":
    unittest.main()
