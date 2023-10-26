// modules/ecs/client/main.ts


resource "aws_ecr_repository" "audio_archive_nextjs_client" {
  name                 = "audio-archive-nextjs-client-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    "Project"   = "Audio-Archive"
    "Env"       = "Development"
    "DockerTag" = "latest"
  }
}

resource "aws_ecr_repository" "audio_archive_express_server" {
  name                 = "audio-archive-express-server-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    "Project"   = "Audio-Archive"
    "Env"       = "Development"
    "DockerTag" = "latest"
  }
}
