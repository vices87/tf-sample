
#create network
module "tf-vpc" {
  source = "../modules/tf-vpc"
  prefix = "news-project"

}

#create load balancer
module "tf-alb" {
  source  = "../modules/tf-alb"
  project = "news-project"
  vpc_id  = module.tf-vpc.main-vpc-id
  subnet_id = module.tf-vpc.subnet-private

}

#frontend 
module "tf-autoscaling" {
  source        = "../modules/tf-autoscaling"
  prefix       = "frontend"
  vpc_id        = module.tf-vpc.main-vpc-id
  subnet_id     = module.tf-vpc.subnet-private
  instance_type = "t3.nano"
  max_size      = 3
  min_size      = 1
  desired_size  = 1
  ebs_size      = "8"
  ebs_type      = "gp2"
  user_data = "provision-front_end.sh"

}

#backend
module "tf-autoscaling" {
  source        = "../modules/tf-autoscaling"
  prefix       = "backend"
  vpc_id        = module.tf-vpc.main-vpc-id
  subnet_id     = module.tf-vpc.subnet-private
  instance_type = "t3.nano"
  max_size      = 3
  min_size      = 1
  desired_size  = 1
  ebs_size      = "8"
  ebs_type      = "gp2"
  user_data = "provision-docker.sh"

}


module "tf-s3-static" {
  source  = "../modules/tf-s3-static"
  prefix = "news-project"

}