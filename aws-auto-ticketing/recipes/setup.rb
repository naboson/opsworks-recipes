cookbook_file '/opt/aws-auto-ticketing/lib/auto-ticketing-agent.jar' do
    source 'auto-ticketing-agent.jar'
    owner 'root'
    group 'root'
    mode '0755'
end

template '/opt/aws-auto-ticketing/conf/applicationContext.xml' do
	source 'applicationContext.xml.erb'
	variables ({
		:DynamoDbTableName => node['DynamoDbTableName'],
        :EventQueueName => node['EventQueueName'],
        :FromMailAddress => node['FromMailAddress'],
        :HostMailAddress => node['HostMailAddress'],
        :RecipientMailAddress => node['RecipientMailAddress'],
        :P1_ARN => node['P1_ARN'],
        :P2_ARN => node['P2_ARN'],
        :JIRA_URL => node['JIRA_URL'],
        :JIRA_USERNAME => node['JIRA_USERNAME'],
        :JIRA_PASSWORD => node['JIRA_PASSWORD']
	})
end

execut 'cd to auto-ticketing' do
    command 'cd /opt/aws-auto-ticketing'
    action :run
end

execute 'run auto-ticketing' do
    command 'bash ./run.sh'
    action :run
end