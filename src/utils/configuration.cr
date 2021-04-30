require "yaml"
# TODO: Create fields for users to input general config parameters (such as host and port)
module Utils::ApiUtils
    class Configuration 
        def initialize 
            @pg_username = ""
            @pg_password = ""
            @pg_host = ""
            @pg_port = ""
            @pg_database = ""
        end

        def initialize(path : String)
            initialize()
            load_config_from_file(path)
        end

        def load_config_from_file(path : String)
            File.open(path) do |file|
                yaml = YAML.parse file
                postgres_config = yaml["db"]["pg"]
                @pg_username = get_param_as_string(postgres_config, "postgres_username")
                @pg_password = get_param_as_string(postgres_config, "postgres_password")
                @pg_host = get_param_as_string(postgres_config, "host")
                @pg_port = get_param_as_string(postgres_config, "port")
                @pg_database = get_param_as_string(postgres_config, "database_name")
            end 
        end

        private def get_param_as_string(postgres_config : YAML::Any, param_name : String) : String
            postgres_config[param_name].to_s
        end

        def database_url : String
            "postgres://#{@pg_username}:#{@pg_password}@#{@pg_host}:#{@pg_port}/#{@pg_database}"
        end
    end
end