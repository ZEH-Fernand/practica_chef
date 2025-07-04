#
# Cookbook:: receta_HFSJ_MYSQL
# Recipe:: default
#
# Copyright:: 2025, The Authors, All Rights Reserved.
#
#  1. Instalar MySQL Server
package 'mysql-server' do
  action :install
end

# 2. Iniciar y habilitar el servicio
service 'mysql' do
  action [:enable, :start]
end

# 3. Crear archivo SQL temporal con comandos
file '/tmp/init_db.sql' do
  content <<-EOH
    CREATE DATABASE IF NOT EXISTS hospital_medications;
    CREATE USER IF NOT EXISTS 'w3b_hospital_dm'@'localhost' IDENTIFIED BY 'von_prios2025@';
    GRANT ALL PRIVILEGES ON hospital_medications.* TO 'w3b_hospital_dm'@'localhost';
    FLUSH PRIVILEGES;
  EOH
  owner 'root'
  group 'root'
  mode '0600'
end

# 4. Ejecutar el script SQL con root
execute 'initialize_mysql_database' do
  command "mysql -u root < /tmp/init_db.sql"
  action :run
  not_if "mysql -u root -e 'USE hospital_medications;'"
end
