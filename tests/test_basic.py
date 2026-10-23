"""Basic smoke tests."""
import os
import sys

def test_repo_exists():
    """Verify repo has expected structure."""
    assert os.path.exists("README.md"), "README.md missing"

def test_no_secrets():
    """Verify no hardcoded secrets."""
    for root, dirs, files in os.walk("."):
        for f in files:
            if f.endswith((".py", ".js", ".ts", ".ps1", ".sh")):
                path = os.path.join(root, f)
                with open(path, errors="ignore") as fh:
                    content = fh.read()
                assert "password" not in content.lower() or "example" in content.lower(), f"Possible secret in {path}"
