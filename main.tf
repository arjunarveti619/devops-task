
resource "azurerm_resource_group" "eedevops" {
    name = "testResourceGroup1"
    location = "KoreaCentral"

    tags = {
        environment = "Production"
    }
}
resource "azurerm_network_interface" "test-nic" {
  name                      = "test-ops-nic"
  location                  = "KoreaCentral"
  resource_group_name       = "${azurerm_resource_group.eedevops.name}"

  ip_configuration {
    name                          = "testipconfig"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.test-pip.id}"
  }
}
resource "azurerm_network_interface" "test-pr-nic" {
  name    =  "test-pr-ops-nic"
  location = "KoreaCentral"
  resource_group_name = "${azurerm_resource_group.eedevops.name}"

  ip_configuration {
    name = "testpripconfig"
    subnet_id = "${azurerm_subnet.subnet2.id}"
    private_ip_address_allocation = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
    load_balancer_inbound_nat_rules_ids     = ["${azurerm_lb_nat_rule.tcp.id}"]
  }
}

resource "azurerm_public_ip" "test-pip" {
  name                         = "test-ip"
  location                     = "KoreaCentral"
  resource_group_name          = "${azurerm_resource_group.eedevops.name}"
  public_ip_address_allocation = "Dynamic"
  domain_name_label            = "testapp"
}

resource "azurerm_public_ip" "test-pip-lb" {
  name                         = "test-ip-lb"
  location                     = "KoreaCentral"
  resource_group_name          = "${azurerm_resource_group.eedevops.name}"
  public_ip_address_allocation = "Dynamic"
  domain_name_label            = "spring-petclinic-app"
}

resource "azurerm_virtual_network" "vnet" {
  name = "virtualNetwork1"
  location = "${azurerm_resource_group.eedevops.location}"
  resource_group_name = "${azurerm_resource_group.eedevops.name}"
  address_space = ["172.20.0.0/16"]
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.eedevops.name}"
  address_prefix       = "172.20.10.0/24"
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.eedevops.name}"
  address_prefix       = "172.20.20.0/24"
}

resource "azurerm_virtual_machine" "site" {
  name                = "testapp-site"
  location            = "KoreaCentral"
  resource_group_name = "${azurerm_resource_group.eedevops.name}"
  vm_size             = "Standard_B1ms"

  network_interface_ids         = ["${azurerm_network_interface.test-nic.id}"]
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "testapp-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "testapp"
    admin_username = "adminuser"
    admin_password = "Admin123"
    custom_data = "${file("./docker-init.sh")}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
     path = "/home/adminuser/.ssh/authorized_keys"
     key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLiBB4X3Xo7+Qw2JHHRQXJNimtq5Rx3M+tW1v7KbwXVo9F73AMgVCSoWfvNewTWh18SED0vpo37m2RmBd46WV25J9skfhJqx+9WHsgbZmXzgaXfcZHUHY/Q4Ky1YeFUv7BiXJQlsDFZMTUXvCWbyv3Gx4RGLWCOdTfPLGQXlwTqW/FJZOl3Lrzw+4LSR0eMtO2q8IMJAxy24TEN7AQhneHGehOGKOG6zBq+J29OGa1XmxpmlNP4QXE7yEPubTnJrQLDmF7xiaJOUJuc6nExcZJTTvbwKK4CnVwhGaUIOu1qLH7JR3SOvVBmSAr7sWqEvQD29CtmVtlPEirHJgTFSy1 arjunarveti@Arjuns-MacBook-Pro.local"
   }
  }
}


resource "azurerm_virtual_machine" "site-pr" {
  name                = "testapp-pr-site"
  location            = "KoreaCentral"
  resource_group_name = "${azurerm_resource_group.eedevops.name}"
  vm_size             = "Standard_B1s"

  network_interface_ids         = ["${azurerm_network_interface.test-pr-nic.id}"]
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "testapp-pr-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "testapp"
    admin_username = "adminuser"
    admin_password = "Admin123"
    custom_data = "${file("./spring-petclinc-init.sh")}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
     path = "/home/adminuser/.ssh/authorized_keys"
     key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLiBB4X3Xo7+Qw2JHHRQXJNimtq5Rx3M+tW1v7KbwXVo9F73AMgVCSoWfvNewTWh18SED0vpo37m2RmBd46WV25J9skfhJqx+9WHsgbZmXzgaXfcZHUHY/Q4Ky1YeFUv7BiXJQlsDFZMTUXvCWbyv3Gx4RGLWCOdTfPLGQXlwTqW/FJZOl3Lrzw+4LSR0eMtO2q8IMJAxy24TEN7AQhneHGehOGKOG6zBq+J29OGa1XmxpmlNP4QXE7yEPubTnJrQLDmF7xiaJOUJuc6nExcZJTTvbwKK4CnVwhGaUIOu1qLH7JR3SOvVBmSAr7sWqEvQD29CtmVtlPEirHJgTFSy1 arjunarveti@Arjuns-MacBook-Pro.local"
   }
  }
}
resource "azurerm_lb" "lb" {
  name  =  "TestLoadBalancer"
  location = "KoreaCentral"
  resource_group_name = "${azurerm_resource_group.eedevops.name}"
  
  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.test-pip-lb.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${azurerm_resource_group.eedevops.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "BackendPool1"
}

resource "azurerm_lb_nat_rule" "tcp" {
  resource_group_name            = "${azurerm_resource_group.eedevops.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "RDP-VM"
  protocol                       = "tcp"
  frontend_port                  = 9091
  backend_port                   = 8080
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${azurerm_resource_group.eedevops.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${azurerm_resource_group.eedevops.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}