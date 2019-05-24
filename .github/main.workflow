workflow "Build on Push" {
  on = "push"
  resolves = [".github/actions/XCOM2_Build"]
}

action ".github/actions/XCOM2_Build" {
  uses = ".github/actions/XCOM2_Build"
}
