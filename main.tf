# Required Providers
provider "azurerm" {
  features {

  }
}


data "azurerm_resource_group" "RG_Name" {
  name = "cicd"
}

/*
output "id" {
  value = data.azurerm_resource_group.RG_Name.*
}
*/


# SQL Server
resource "azurerm_mssql_server" "r_sql_server" {
  name                         = "azsqlbangserver"
  resource_group_name          = data.azurerm_resource_group.RG_Name.name
  location                     = data.azurerm_resource_group.RG_Name.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  public_network_access_enabled = true 
}

# SQL Database
resource "azurerm_mssql_database" "r_sql_database" {
  name                = "tf_demo_DB"
  server_id = "${azurerm_mssql_server.r_sql_server.id}"
  max_size_gb = 5
  transparent_data_encryption_enabled = true
}

# Public Access (Allow Azure services and resources to access the server)
resource "azurerm_sql_firewall_rule" "allow_azure_services" {
  name                = "allow_azure_services"
  resource_group_name = data.azurerm_resource_group.RG_Name.name
  server_name         = azurerm_mssql_server.r_sql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Public Access (Allow access from the Internet)
resource "azurerm_sql_firewall_rule" "public_access" {
  name                = "public_access"
  resource_group_name = data.azurerm_resource_group.RG_Name.name
  server_name         = azurerm_mssql_server.r_sql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

# Output the connection string
output "sql_db_connection_string" {
  value = "Server=:${azurerm_mssql_server.r_sql_server.fully_qualified_domain_name};Database=${azurerm_mssql_database.r_sql_database.name};User ID=${azurerm_mssql_server.r_sql_server.administrator_login}"
}
