function init()
    run(`rm -rf .git`)
    run(`rm -f commit.txt`)
    run(`git init`)
    run(`git config --local commit.gpgsign false`)
    run(`git config --local tag.gpgsign false`)
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

init()
commits = (
    "Initial commit",
    "docs(project): add README.md",
    "feat(parser): add ability to parse arrays",
    ( msg = "fix(parser)!: fix parser", tag = "v1.0.0"),
    "refactor(parser): refactor type commit",
    "chore(release): chore type commit",
    "docs(README): documentation commit type",
    "docs(README): fix typo",
    "docs(README): add url",
    "docs(README): fix url",
    "docs(README): delete url",
    "docs(README): add links",
    "docs(README): change links",
    "docs(README): remove links",
    "docs(README): add GitHub URL",
    ( msg = "docs(README): fix URL in README", tag = "v1.0.1"),
    "feat(config): set config",
    ( msg = "feat(cache): use cache", tag = "v2.0.0-beta.1"),
    ( msg = "fix(config): fix config", tag = "v2.0.0-beta.2"),
    ( msg = "fix(cache): fix cache", tag = "v2.0.0"),
    "test(busted): test type commit",
    "style(editorconfig): style type commit",
    "ci(github-actions): ci commit type",
    "build(make): build type commit",
    "perf(db): perf type commit",
    "Revert \"perf(db): perf type commit\"",
    "revert(db): revert type commit",
    "feat(key): security",
    "fix(security): fix private key",
    "perf(protect): secret scanner\n\nsecurity",
    "docs(security): update README.md",
    "feat: commit without scope",
    ( msg = "feat(cache)!: ticket #1 (close #1)", tag = "v3.0.0"),
)

for c in commits
  if typeof(c) == String
    commit(c)
    continue
  end

  commit(c.msg)

  # https://github.com/orhun/git-cliff/issues/139
  sleep(1)

  run(`git tag $(c.tag) --message "$(c.tag)"`)
end
