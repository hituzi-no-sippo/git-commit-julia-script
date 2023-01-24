function git(subcommannd...)
    run(Cmd(["git", subcommannd...]))
end

function add(msg)
    file = "commit.txt"

    open(file, "a") do io
        write(io, "$msg\n")
    end

    run(`git add $file`)
end

function commit(msg)
    add(msg)
    run(`git commit --message "$msg"`)
end

function init()
    run(`rm -rf .git`)
    run(`rm -f commit.txt`)
    run(`git init`)
    run(`git config --local commit.gpgsign false`)
    run(`git config --local tag.gpgsign false`)

    commit("Initial commit")
end

function merge_branch(branch, base_branch_name)
    git("switch", "-C", branch.name)

    for msg in branch.commit_msgs
        commit(msg)
    end

    if haskey(branch, :merged_branch)
        merge_branch(branch.merged_branch, branch.name)
    end

    git("switch", base_branch_name)

    merge_msg = haskey(branch, :merge) ? branch.merge : branch.commit_msgs[1]

    msg = let
      str = "$merge_msg\n\nMerge branch '$(branch.name)'"

      if base_branch_name != "main"
        str *= " into $(base_branch_name)"
      end

      str
    end

    git("merge", branch.name, "-m", msg)

    git("branch", "--delete", branch.name)

    if haskey(branch, :tag)
        # https://github.com/orhun/git-cliff/issues/139
        sleep(1)

        git("tag", branch.tag, "--message", branch.tag)
    end
end

init()

docs_branch = (name = "fix-README", commit_msgs = ("docs(project): fix README.md",))
branches = (
    (name = "add-README", commit_msgs = ("docs(project): add README.md",)),
    (
        name = "add-parser",
        commit_msgs = ("feat(parser): add ability to parse arrays",),
        merge = "feat(parser): add parser",
        merged_branch = docs_branch,
    ),
    (name = "fix-parser", commit_msgs = ("fix(parser)!: fix parser",), tag = "v1.0.0"),
    (
        name = "refactor-type-commit",
        commit_msgs = ("refactor(parser): refactor type commit",),
    ),
    (
        name = "chore-type-commit",
        commit_msgs = ("chore(release): chore type commit",),
        tag = "v1.0.1",
    ),
    (name = "set-config", commit_msgs = ("feat(config): set config",)),
    (name = "use-config", commit_msgs = ("feat(cache): use cache",), tag = "v2.0.0-beat.1"),
    (
        name = "fix-config",
        commit_msgs = ("fix(config): fix config",),
        tag = "v2.0.0-beat.2",
    ),
    (name = "fix-cache", commit_msgs = ("fix(cache): fix cache",), tag = "v2.0.0"),
    (name = "test-type-commit", commit_msgs = ("test(busted): test type commit",)),
    (name = "style-type-commit", commit_msgs = ("style(editorconfig): style type commit",)),
    (name = "ci-type-commit", commit_msgs = ("ci(github-actions): ci commit type",)),
    (name = "build-type-commit", commit_msgs = ("build(make): build type commit",)),
    (name = "perf-type-commit", commit_msgs = ("perf(db): perf type commit",)),
    (name = "revert-commit", commit_msgs = ("Revert \"perf(db): perf type commit\"",)),
    (name = "revert-type-commit", commit_msgs = ("revert(db): revert type commit",)),
    (name = "feat-security-commit", commit_msgs = ("feat(key): security",)),
    (name = "fix-security-commit", commit_msgs = ("fix(security): fix private key",)),
    (name = "perf-security-commit", commit_msgs = ("perf(protect): secret scanner\n\nsecurity",)),
    (name = "docs-security-commit", commit_msgs = ("docs(security): update README.md",)),
    (name = "non-scope-commit", commit_msgs = ("feat: commit without scope",)),
    (
        name = "many-commits",
        commit_msgs = (
            "build(aqua): build type commit",
            "style(dprint): style type commit",
            "test(luaunit): test type commit",
            "ci(dagger): ci commit type",
        ),
        merge = "chore(dagger): many commits",
    ),
    (
        name = "commit-with-issue-number",
        commit_msgs = ("feat(cache)!: ticket #1 (close #1)",),
        tag = "v3.0.0",
    ),
)

for branch in branches
    merge_branch(branch, "main")
end
