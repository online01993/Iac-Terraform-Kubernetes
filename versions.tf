#versions.tf
terraform {
  required_providers {
    xenorchestra = {
      source = "terra-farm/xenorchestra"
      version = ">=0.24.2"
    }
    tls = {
      source = "hashicorp/tls"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">=1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.22.0"
    }
  }
}
provider "xenorchestra" {
  # Must be ws or wss
  url      = var.global_xen_xoa_url      # Or set XOA_URL environment variable
  username = var.global_xen_xoa_username # Or set XOA_USER environment variable
  password = var.global_xen_xoa_password # Or set XOA_PASSWORD environment variable
  insecure = var.global_xen_xoa_insecure # Or set XOA_INSECURE environment variable to any value
}
# Configure the DNS Provider
# provider "dns" {
# update {
# server = var.dns_server
# key_name      = var.dns_key_name
# key_algorithm = "hmac-sha512"
# key_secret    = var.dns_key_secret   
# }
# alias = "bind"
# }
provider "kubernetes" {
  host                    = module.kubernetes-base.k8s-api-endpont-url
  insecure                = false
  client_certificate      = base64decode(module.kubernetes-base.k8s-client-certificate-data)
  #client_certificate      = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJVENDQWdtZ0F3SUJBZ0lJVktSRFFwTGRHcm93RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TXpBNU1EUXdOekV6TkRsYUZ3MHlOREE1TURNd056RTROVEphTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXIyK21hdHNXcjZoVkErS1kKTk54YjBjWU9yTVVyTDkrU0ZTV0pkVStPRGpSRDZzR1h1blRrTS8wbUR5clhYTlQwNmR3bFlvSXl1bVp0L0Y3WQp1N3M1akk4N2k2WnpZNW44NE9jN0o5K3EvV2pJWHl6KzlCT2pHamt3WkhzUVZvN1I4WkNZNUlPV1cwVFRsUSt2CjVHQTdoQkdwUFdvMnRtakJaUmdKWHl4L3pkdWVEVno3aWtPZ1VPWDg4N3k2SVFrSGhkRGQ1eHMvdlpTU3ovY1gKYlpnWlpSRlAyT01aL0hHZmlyVHlZVXZ6MmRRSUZJeitucjd3bmZSWmhtUG9FZmk2Zzh2cytCZzIxRUFEYllsMwpJeE9GdHFZQzJxY2dDM2xVUzdCUDNXOHF2WHFGU0psbXJublhyWkszc1JDaHhKUFcyK0FsbU1SZ29mV0RxSCsvCkcreExvd0lEQVFBQm8xWXdWREFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUVHREFXZ0JSMjRWY0dUZk42QzFsWkNuMEhnSjYzLzRjMwpTREFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBbFVmeXNrR3NJdytXVU5abitLb2dOMkNQcit0akRKSDZJRjdtCkk2TE10Yk4xVTI5eHZBVWRWM2ErZlRmb3o3bHNmZklCS0orRUF2TG55czZvQVZXYzlZRjJBc0g3bEdUZTB4NzgKdi9CSXRicytzRUFBUGQ2M0xvay94dHdKR1RLQ3NMSWxYZHZyTWhFZEtjN2ZJelJ5NmtEcFVaMTkwUDVaOXAzeAphbkt6MVF3LzZVWE1yZTdQRVZLbGlMejUvUGF6QWJuVkVwVnhTL1ZPaWFSZlprZW81TjNhcWJaWS9jTjhQYXAvClU2NE9CeG8wR0NDMmZBM3JDdkRmdUJvdFovK2N3YWdxV0R3b0Q5cWxxbk91YWZ0VDNJUkZoWE56NGRxOHlwNDIKM1pmbEhtR0p2S2FIVDUvdjlIZFloelQwWXpvY2oyaytEL09uSVFsZUNqdUk4QXVFQkE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==")
  client_key              = base64decode(module.kubernetes-base.k8s-client-key-data)
  #client_key              = base64decode("LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBcjIrbWF0c1dyNmhWQStLWU5OeGIwY1lPck1Vckw5K1NGU1dKZFUrT0RqUkQ2c0dYCnVuVGtNLzBtRHlyWFhOVDA2ZHdsWW9JeXVtWnQvRjdZdTdzNWpJODdpNlp6WTVuODRPYzdKOStxL1dqSVh5eisKOUJPakdqa3daSHNRVm83UjhaQ1k1SU9XVzBUVGxRK3Y1R0E3aEJHcFBXbzJ0bWpCWlJnSlh5eC96ZHVlRFZ6Nwppa09nVU9YODg3eTZJUWtIaGREZDV4cy92WlNTei9jWGJaZ1paUkZQMk9NWi9IR2ZpclR5WVV2ejJkUUlGSXorCm5yN3duZlJaaG1Qb0VmaTZnOHZzK0JnMjFFQURiWWwzSXhPRnRxWUMycWNnQzNsVVM3QlAzVzhxdlhxRlNKbG0Kcm5uWHJaSzNzUkNoeEpQVzIrQWxtTVJnb2ZXRHFIKy9HK3hMb3dJREFRQUJBb0lCQUVwSXRtaXNtRENNMEdLeQp3Y3d3T2xqYXlqL3h4TldpanhLUk1HRVI3STZySnM3eVpqSzNhQ0Z6WVhndXBiNVRGZGtvTkZRLzJRY0FkRFhXClcyTXlaYTNVd0Z2amdSeDlpWXdablB6SFFubkdzb0ZLWmpJblZucTJHSDJUZGxtUVkra3JWdkg3bmVETGhlT3EKSHNwT3pTU2c3YzVwZVAxSDRndlNYN1dDL0NMSDFaVExCMitBSVErUVJ1SVRlY1NLTE50eU50dzdIeHZETndWbgphaENKM1YzQ0FvbzhpQkJHeE1GTmQxWEpwYVA5eWZvbitRRmpmNkVoWklsWGtjNHlFZmQrTHpnU2dHZWdQa0RvClc5VnNtanppazhJUXFCdzI4bTRweER0MmlsQlNVOEJWeHZDWm1FZTJyNFIxWHRDc1Q0QVZhdEVwUTB3aG1mWi8KNjc2U21IRUNnWUVBeHhpT3lYZ2p6aHVmeTNtTW5TcHVxTEk0bHlpcFR1ZmFDUU1vcHJKQjdqbjRVSXRyNlFDMQpXLzljSS9BaXp5ZytlcU5HbE9Qa1djSzNXcU9PK1hwOTZ6NG80K0FQdW1UeVNMa3dkUjJYM29teG4reXp0UUE0CkVZbmZ2b3ZLZlU5TXlKQ1dpdUFVY1VibUlLL3JLYTdXaEYxbk51cUpIcXdJN2NMS294Q1lRMDhDZ1lFQTRaUDAKRW45SCs0bzU1ckhCNUQ4WWFUZTNMWkxLbnFYK2p0QVdLWU56YWRrWFZZQTJnRlRPZHdVNmdVQ1NWYW9kOVB5bQpkSkR5di82KzlyU3E4bGJlRFpvSEgyWHFRb1NFQXZ1VVNFaGhYVC9YSXZTekxBdk1kcVhoQU52bllMNExkS0IwClRIWVJvSGlVcGZVTm1kU1VveXlaYWsvTkpDSEJEMS9HMXBMaGJXMENnWUJ3d1Z1OGhpbmhCSXdQTkp1S053bk0KeUlKOE9TOEozUTBDcGFOVUpRaHAzckxmQ3RibWN0eERhZS9JK3FyOEg1S2k2ZTJEVFQxNkNHakhFSEpjb0I3SQpKOEFJcmxDNkE0bWozaDJ2ZGo4WWJXc0hZNHF6SzVpVmRqd2RNaFpQdWFXR3dUeEJFbjhCV0dIa2lUenBzbmNUCko4TFl1eU5GRjdGRzFsYmsydlVneVFLQmdRRE9XNXdQQTlNazRGbUJtaUdtbkxYSEkwbjJiZS9mM0RpWUN2SUwKUGc1cHlVZ1lWbmNGUlErdlArQTZkNGlteHo0cWJLb1Z2cmZqUGJjU1YwcCs4VXFucEwxWlV0RlAwb3cxY2xJLwpJYis0SDN1K3BaMzI4RUEyVmg4VXV4YmFvR0E0YThTWVlmWlVGNXJjaXVYTFVQWThvOE1neHlvQ0lNTE5QcS9XCmdYMnByUUtCZ1FDc3Y0SmxpdzN3LzJ3ZjA1Zk5EdU8xdjRaZXh0MWhKTzFPY0NsOFpIMUxRb2FFdUhvV0JSQ3MKUzZweGxiaDI3QUVCWUVldHZ6Y0kxbjhEV1lkYzVLWFIzeHNWVlEvSnNvZ3MveGNTRTZ4a3JZTDlVQ2hoSE1KTQozOGhjV3RLZEVJRkFNSXc2cjgzTk4wM2orWGtoYkJDRWx1Z1FsTm42cWtYMWRwUFowY0ZaTmc9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=")
  cluster_ca_certificate  = base64decode(module.kubernetes-base.k8s-certificate-authority-data)
  #cluster_ca_certificate  = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJVFJtZE1UeTBYSGN3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TXpBNU1EUXdOekV6TkRsYUZ3MHpNekE1TURFd056RTRORGxhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURDZlVaZW9zNW5xTjVwbHNYclNZa0JtcnFWZEVzZmluRWd6akc5d0daUkhsT2s5YURTbjBhcHBFSDgKS0VRQUVwQXBBN2puQmROdEZaZWZKYVNCZDZxNGZRbVB0VnpheElpYUJONXRDU1lwMSt0elo2TG5ZUTB2SGZYWQp5MS9Salc5MzFTcnE2UWh5Vi9URCs0R3hrSmlKblFIL3VUY2dRMWlIRzcyZlVEbE5zYk9NTEZkdGtNWnVQeTgzClhydjkzVUROV1FDSE9MN1BONUcwQjFKbEh0c2pFL3ExcEU3R1NvVU9lMlQ0N2ZHSGFxb0JmK21nQTYyQjRIZzMKZnhHSkRabHZQQXdnVTZ4a1p6b2NQYzEvMGZrUU5tR0xZTEQ4NUU5enpFaldVcndZMmFCVDZUbnhzOWZCSjhubQpWcE9RZzNSM2Q4bDhOUnpQQ1ByV1pFQ21ZMkdmQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSMjRWY0dUZk42QzFsWkNuMEhnSjYzLzRjM1NEQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ2dDdlRxT0hocgpVTlByRVdIS00xYmpDUWsybC9ocmloTTNRYkd0N0xKL1ViT2NmcGVCMFc4YmhjSTJKR3JxbCtiOSt5VXJsSnZDCm5IcE8zRnQrcHdPSzZTN0RxRDM4bTVTdnpKc1pKdFl5SFZrdWtiN0xZT01QMGgzSEZvNzcxMUoxRit5bUpDck4KUHdiemhISlErZTdQcnJvK24yODZ3V1M1Ri9uczhIb0RaQjdGa0VWUkc2TnpnNzNldllNdUNWV0p2Um42clFzQQp5bUV1RkxwbkRzcXNPVjhGZllpUjNnN291VWZxTi96NmdneTRZblVUNVpQak4rM3FOZUZZR25YRFYxeGJHWmNsClhBMHFrUTNjYkwxbENCamVYY2tZeXd2YnJEdmc2M3lPVUtWVXVuUnNrbitJK0ladFBlSWw1NzFsSGhNRHE5S1kKRjVPNm56QW5PbW5XCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K")
}
provider "kubectl" {
  host                    = module.kubernetes-base.k8s-api-endpont-url
  load_config_file        = false
  insecure                = false
  client_certificate      = base64decode(module.kubernetes-base.k8s-client-certificate-data)
  client_key              = base64decode(module.kubernetes-base.k8s-client-key-data)
  cluster_ca_certificate  = base64decode(module.kubernetes-base.k8s-certificate-authority-data)
}