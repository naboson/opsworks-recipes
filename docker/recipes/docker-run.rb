include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  
  if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
    Chef::Log.debug("Skipping deploy::docker application #{application} as it is not deployed to this layer")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  bash "docker-cleanup" do
    user "root"
    code <<-EOH
      if docker ps | grep #{deploy[:application]}; 
      then
        docker stop #{deploy[:application]}
        sleep 3
        docker rm #{deploy[:application]}
        sleep 3
      fi
      if docker ps -a | grep #{deploy[:application]}; 
      then
        docker rm #{deploy[:application]}
        sleep 3
      fi
      if docker images | grep #{deploy[:environment_variables][:image]}; 
      then
        docker rmi #{deploy[:environment_variables][:image]}
      fi
    EOH
  end
  
  dockerenvs = " "
  deploy[:environment_variables].each do |key, value|
    dockerenvs = dockerenvs + " -e " + key + "=" + value
  end

  dockervolume = " "
  if deploy[:environment_variables][:host_volume]
	dockervolume = " -v " + deploy[:environment_variables][:host_volume] + ":" + deploy[:environment_variables][:container_volume]
  end
  
  bash "docker-run" do
    user "root"
    code <<-EOH
      docker run #{dockerenvs} #{dockervolume} -p #{node[:opsworks][:instance][:private_ip]}:#{deploy[:environment_variables][:service_port]}:#{deploy[:environment_variables][:container_port]} --name #{deploy[:application]} -d #{deploy[:environment_variables][:image]}
    EOH
  end

end

