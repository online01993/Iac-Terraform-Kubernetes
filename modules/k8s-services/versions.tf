#versions.tf
terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}

provider "kubernetes" {
  # Configuration options
  #host                    = var.k8s-url
  #config_path             = var.k8s-admin_file
  #config_path            = "~/.kube/config"
  #client_certificate     = file("~/.kube/client-cert.pem")
  #client_key             = file("~/.kube/client-key.pem")
  #cluster_ca_certificate = file("~/.kube/cluster-ca-cert.pem")
}
provider "kubectl" {
  #host                    = var.k8s-url
  host                    = "https://10.200.0.10:8888"
  load_config_file        = false
  insecure                = false
  client_certificate      = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJVENDQWdtZ0F3SUJBZ0lJYnIxZWF3VUNxTFF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TXpBNE1ESXdNekF6TWpsYUZ3MHlOREE0TURFd016QXpNekphTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQW8xRUFMNTZ6d1pwK0tZOWkKNkZ6L3lkZ0g2TXFibzJhK01OcTNtK01uTW1XcHBIQy8wU3UvM291ZFdWOTczUk0wTGxoNzZEOTQyMVpiSzZRZApLY243Vlc5OW5aWWZNbFNETUR1ZXk1c3AyWGRCL0VIeW0zNXNIdmM3Z0w1dGo3SUZtYlJIM3prTitteEcyWkdnCnpDRFN6ZS85anFSWjBhdEQrUHJBMU1zSUk1NHEvTVpXTStsVXArdzRDa2NxdTdOWm1QNVVtcmRDeC9PaWZFdk8KdDBFRldLOTlKbkl0QmIweTY1NEpEbC9RbWNjcHNRbFZsL3VwKzFmTWFmZjBSS3JUZW41TERvMUZ1N2RzS0tjSAo0Zms0YU9XZTcwQ0ZkZG85UG1MekkxOGpJY0Q3TkpoL0xrYWNaZWE5WWJ0SkxRTksyV1p6eHNMaFF2eWZxWmVhCkpDdnArUUlEQVFBQm8xWXdWREFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUVHREFXZ0JUcExEQ0oyMkh0ZWJLSExwaTdzZU5nbEg4bAprREFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBTEw3anUzYkxXUDVQdGhpTUZVcGI1Y1lCSGRITFJ1N0d2YmFKCktKQlpaSkJ6d0xPVldLMitBbXp2RkMxbndQSHNqVU5jWG9OR3NnNWRjY2taR08vRXlFU21VaEh1aTdUSERpbDMKSVZ3d0RmbGRUSnJVUzZ4NVF3S3hNUWFBYmFHYUNSck53UGJ2RFBBdlZBZVlEcE85bzNOeVA0MG8vRm1ZVXhvdgpoYlZVbTQ4eVgvaEhyS0JPd21kSkRMa1QxYk9oQmcwbm5Xakx2WTU0S0tISTRHaEtHUm4zYjBYQWdHeVhJRGQ1CkFEZk1pRnIxMFh3VEJpSEVBZkZIUXY1aDBXR3FPNkxoTG9tSVNHNFRMSHhhWmRYQjNFWEFpazN5VmQ0Z1hneDAKbmw2a3pRL3ZFdnBCS3QwaGg4Q0NuYUgrTEFhUWxieDNQekU1Y205enNrUTBxajREOGc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==")
  client_key              = base64decode("LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb2dJQkFBS0NBUUVBbzFFQUw1Nnp3WnArS1k5aTZGei95ZGdINk1xYm8yYStNTnEzbStNbk1tV3BwSEMvCjBTdS8zb3VkV1Y5NzNSTTBMbGg3NkQ5NDIxWmJLNlFkS2NuN1ZXOTluWllmTWxTRE1EdWV5NXNwMlhkQi9FSHkKbTM1c0h2YzdnTDV0ajdJRm1iUkgzemtOK214RzJaR2d6Q0RTemUvOWpxUlowYXREK1ByQTFNc0lJNTRxL01aVwpNK2xVcCt3NENrY3F1N05abVA1VW1yZEN4L09pZkV2T3QwRUZXSzk5Sm5JdEJiMHk2NTRKRGwvUW1jY3BzUWxWCmwvdXArMWZNYWZmMFJLclRlbjVMRG8xRnU3ZHNLS2NINGZrNGFPV2U3MENGZGRvOVBtTHpJMThqSWNEN05KaC8KTGthY1plYTlZYnRKTFFOSzJXWnp4c0xoUXZ5ZnFaZWFKQ3ZwK1FJREFRQUJBb0lCQUhLUVByWW8rT1lGenh5dQpWZTYwVmthc1FaZ2VrS0ZHVUlLSzJ5UUNhNXVoenlmb1k5YUNmeHpKQ1g4SlNTVmk5RWJTa1ZEeFBZRjNpWXNLCm05NlZyclpXK0dKVVRkd0xodCtONHkzbTBhdVlTZlIvK29UellUc3pxVXo5eUhOMXFSSVNjaHgzdElPSDh3ZHEKYmNiais1eTFEa1JDckRNMWxnQVJQclhIR3hXSUhrNVdGZmljWUsrZmp0SWFsU0Vmeko4d2J5ZmVLTWtFdXVOWAo5Y0U2SlQ5eVR3Y1ZpMWlQdUp4UmNySTlsaWdkNVpxakpQSGE1LzZ4MjRYOVJOQlM3UTFQU2tmNllCQTVCWDQ2CmVoMFpZanB5d2NUTXd3cEpJaGptYXRSMHdYZzVEeWxTKytEdCtXVXV5YUlpYURwSGpJcHVJVGpGNVdEREVsN1MKVUF1SXZvVUNnWUVBMTZmSVY3OXdlWE5sRHBCSmtyV2I1SGJrZDY0aDFBaEt1eGxZOXQzK0ZML05pMjd4OUt5bgp3M0NYSlFGSlpjQm9vRGhVclNtejl3WitETTRaMUx1NC9BQjkyaUZSNWlRb08yYmQxaDVsMTNvSHRuQ3Vabit6CnQ4R0pIb1dPWjU1NGVCcWJoSHFRRk54Z0NkMGlyajgzT2Q0Z1FHWDlBMlA1NzhXdlcybmZNQzhDZ1lFQXdkNlcKVnlnMXNXK2J0bnZOdmhkeThaRVFYZVpWaVVKZHNOcWE1a2FNbEpYM21PK3RtZExnbFlIdWQ2VkVZM3BqSjZMRQpFQXlXWHhkNTYwK3FBa0lUZGs0Z0x3dGdSUnhNNlF6WmFkb2tXak9qUVExeHJKekdlc2p1SlZmd1VUMEhQZU4vCjhCVlltVEdxWkFSaHFodyt3Qk8rZGF2ZjJwMlB3NUIzR0JtWmxsY0NnWUI0QTYvQzVZODZoN1dkdlQ2MG5zejcKQUE5MWF6cjRQUVVaeXFsditXc0ZNUmk2bUN1ZTl0Y0dOUXBvVmFiN01YRUllVkRtYldieCtuTDd2VmN5eEtYVgoySkF4YkltZmdrL0JmeVhGbTNVaHpZK3RRRmhPUXBOSm1ETXZBVFNYQmVJVk5QbUhhSTMyamc0RWIwUjFwRWlmCnM3WlBJSE1HQ0FWNElwUE1VOGNaa1FLQmdBT3VFZlI5a3VkWFV3Rlh3RVFIZGVzWDhkT1dkN0V2VFUvNkZrNmcKc0RKeDFrMVUzMXE0SWdNMGdDNU5PTXNhbTU4NCs3ZkNSV2h3cmFQRjAxaFBvTWJ5SExKSDZQL20xWjdtMjRtaQoxbVhQN1IxaS8vRmkySEdrTnNFR3RrMFVkM3E1UXNodjMwcXBJcTdiVm05QU1nQzdYellrbVE4eFJuVlQzSzdjCmJZbnBBb0dBTDN6QW9GOE1LdHVVMEFacDBzc0duNldvWEFaNjhVTmVJaFdzNU9CWWZPNU55Nkg0TjdFVHQyeGwKWFZNSVRXejJYWkNmZ1RNLzBRQWY0dUNJQjU4VDM0SWlEN1k2c0lhditFVGNBMzRUOERhL0krOGpmNTJEQ3NONwpiaHNFVDgxVjVFZkE0U0F0TTJ6R3FLT0tHUnRsb1BMeGxHbXQySGhCS3hlclZTZmpFcDg9Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==")
  cluster_ca_certificate  = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJSUQ4Nm54cVQreXd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TXpBNE1ESXdNekF6TWpsYUZ3MHpNekEzTXpBd016QXpNamxhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUMwclNjUjdQQ1hpZi9mQnpraUpENmVKS0pXUjFSTUttcE00RzhmOGhmMkczd05aU3B0TWhpRFI4Z1QKYnRrbFo0V0VwZk5XaS9nZStZOWhFbTAybUt1WXpvMVpiU2lGZGppVURTMktnTVJtU2JTWlVMTVlRMHdDT2lvdgp4Q1UvWGQ0TEp0ZlkwTi9pNE1ZY2lGbzljeHNrL09YUkVsZ0ZLRlhlTmw0QjVXMW8xUGhyaUw1cy9YV2R6TTNDClIydmpMMlpSdzBqY1haanZpRDBEOFZOaHVCbElaVzlON3BQZUxXT0lEU3p1NVlCb0xjZDF4cjN6VFZGOUFzeXEKQnAyZXVOOFdkNnNhVHdvL2pRa1BwUEF0QTBHOUd2ZFlXYzdRbURGMGhobFFVb1N3L3c4RXA1bmZ4T0FIOEhucQpFSmNsYTBSeGR3cDI4UVVtelRKZG15RTF4TmxuQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJUcExEQ0oyMkh0ZWJLSExwaTdzZU5nbEg4bGtEQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQnN6eStmN2RUbgpOQTduT01zUGRFTkFBWXBWdzFnbDM0Mk9hOW1DUm8vL3k2MG9hS0Mva2Q3ay9NK2VXL1hPUTBVUG5Rc1FpMDVHCjVnbjBadDV6L1lKaUFRemdMbUwwUU9OQk1kVkpqWHNOTllJR25RS2dSV0RKU3lGRWM2bWI3RFlCeHdTbG5rSDEKT1dPdXBtUTRKekJWVUdqbmdjU1U4dnFrMHJYL0tOYkhTMk1aMEU3b2NERVNENk1WblNzWmV1M3ZSbHVia0NjaApNemUvZTZUcXRjNkViaTJoekJ6Nko1MFFJVFpEN0tRZEhMcVRIS1RVUmJsb1pPaDZnbGN5MUhMZkhGc3JnazlzCjFpQkdUS0RTZ2lFbGlmNFIyOE1RRGxsU2x4TGgyWllEdGgrbTQ5SC85ZjRGcHUyODlYR2FFRkUrbkFES3UxUEcKRWRkVFF0QTBUM2VrCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K")
}