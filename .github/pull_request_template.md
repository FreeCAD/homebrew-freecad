- [ ] Have you ensured that your commits follow the [commit style guide](https://docs.brew.sh/Formula-Cookbook#commit)?

<!-- NOTE: ipatch, recently rubocop started styling this file, the below code example causes a styling error  -->
```shell
brew style freecad/freecad/[NAME_OF_FORMULA_FILE]
```

**output** from running above command should _output_ something similiar to the below

```
1 file inspected, no offenses detected
```

- [ ] Have you ensured your commit passed audit checks, ie.

```shell
brew audit freecad/freecad/[NAME_OF_FORMULA_FILE] --online --new-formula
```

---

Not all PRs require passing these checks ie. adding `[no ci]` in the commit message will prevent the CI from running but PRs that change formula files generally should run through the CI checks that way new bottles are built and uploaded to the repository thus not having to build all formula from source but rather installing from a bottle (significantly faster 🐰 ... 🐢)

For more information about this template file [learn more][lm1]


[lm1]: <https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository>
