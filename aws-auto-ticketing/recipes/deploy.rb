cookbook_file '/opt/aws-auto-ticketing/lib/auto-ticketing-agent.jar' do
    source 'AutoTicketingAgent-0.1.jar'
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
        :slackToken => node['slackToken'],
        :JIRA_URL => node['JIRA_URL'],
        :JIRA_USERNAME => node['JIRA_USERNAME'],
        :JIRA_PASSWORD => node['JIRA_PASSWORD']
	})
end

execute 'run auto-ticketing' do
    user 'root'
    cwd '/opt/aws-auto-ticketing/'
    command 'sh ./run.sh &'
    action :run
end