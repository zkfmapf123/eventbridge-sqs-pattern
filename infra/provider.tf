## main
provider "aws" {
  profile = "admin"
  region  = "ap-northeast-2"

  alias = "main"
}

## blue
provider "aws" {

  profile = "blue"
  region  = "ap-northeast-2"

  alias = "blue"
}
