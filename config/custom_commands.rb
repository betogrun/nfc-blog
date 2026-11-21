# Project CLI commands. bin/bridgetown requires this file before parsing its arguments.
require "bridgetown-core/commands/application"
require_relative "../plugins/commands/check_deploy"
require_relative "../plugins/commands/check_links"
require_relative "../plugins/commands/new_post"

Bridgetown::Commands::Registrations.register(Commands::NewPost, "new_post")
Bridgetown::Commands::Registrations.register(Commands::CheckLinks, "check_links")
Bridgetown::Commands::Registrations.register(Commands::CheckDeploy, "check_deploy")
