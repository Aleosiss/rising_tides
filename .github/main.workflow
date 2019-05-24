workflow "Build on Push" {
  on = "push"
  resolves = ["Build Mod"]
}

action "Docker Registry" {
  uses = "actions/docker/login@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "Build Mod" {
  needs = ["Docker Registry"]
  uses = "./.github/actions/XCOM2_Build"
  args = "mod=RisingTides"
}
