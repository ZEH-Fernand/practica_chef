# test/integration/default/mysql_test.rb

# Control principal para verificar la configuración de MySQL
control 'mysql-server' do
  impact 1.0  # Nivel de impacto (1.0 = crítico). Se usa para priorizar resultados.
  title 'Verifica la instalación y configuración de MySQL para hospital_medications'
  desc 'Comprueba que el paquete mysql-server está instalado, que el servicio está activo, y que la base de datos y usuario fueron correctamente configurados.'

  # Verifica que el paquete mysql-server esté instalado en el sistema
  describe package('mysql-server') do
    it { should be_installed }
  end

  # Verifica que el servicio de MySQL esté habilitado para iniciarse automáticamente y esté corriendo
  describe service('mysql') do
    it { should be_enabled }   # Se asegura que el servicio inicie al arrancar el sistema
    it { should be_running }   # Se asegura que el servicio esté corriendo actualmente
  end

  # Verifica que la base de datos 'hospital_medications' exista
  describe command("mysql -u root -e 'SHOW DATABASES LIKE \"hospital_medications\";'") do
    its('stdout') { should match /hospital_medications/ }  # Espera ver el nombre en la salida
    its('exit_status') { should eq 0 }                     # Comando ejecutado exitosamente
  end

  # Verifica que el usuario 'w3b_hospital_dm' exista en la base de datos MySQL
  describe command("mysql -u root -e \"SELECT user FROM mysql.user WHERE user = 'w3b_hospital_dm';\"") do
    its('stdout') { should match /w3b_hospital_dm/ }       # Espera encontrar el nombre de usuario
    its('exit_status') { should eq 0 }                     # Comando ejecutado sin errores
  end

  # Verifica que el usuario tenga privilegios sobre la base de datos hospital_medications
  describe command("mysql -u root -e \"SHOW GRANTS FOR 'w3b_hospital_dm'@'localhost';\"") do
    # Comprobamos que la salida incluya específicamente los privilegios esperados
    its('stdout') { should include "GRANT ALL PRIVILEGES ON `hospital_medications`.* TO `w3b_hospital_dm`@`localhost`" }
  end
end

