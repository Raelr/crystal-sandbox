require "yaml"
# TODO: Create fields for users to input general config parameters (such as host and port)
class Configuration 
    @@instance = new

    def initialize 
        @server_config = ServerConfig.new
        @postgres_config = PostgresConfig.new
    end

    def initialize(path : String)
        initialize()
        load_config_from_file(path)
        @@instance = self
    end

    def load_config_from_file(path : String)
        File.open(path) do |file|
            yaml = YAML.parse file
            server_config = yaml["server_config"]
            @server_config = ServerConfig.new(
                get_param_as_string(server_config, "host"),
                server_config["port"].as_i
            )
            postgres_config = yaml["db"]["pg"]
            puts "HOST: #{get_param_as_string(postgres_config, "host")}"
            @postgres_config = PostgresConfig.new(
                get_param_as_string(postgres_config, "postgres_username"),
                get_param_as_string(postgres_config, "postgres_password"),
                get_param_as_string(postgres_config, "host"),
                postgres_config["port"].as_i,
                get_param_as_string(postgres_config, "database_name")
            )
        end 
    end

    def self.instance 
        @@instance
    end

    private def get_param_as_string(postgres_config : YAML::Any, param_name : String) : String
        postgres_config[param_name].to_s
    end

    def database_url : String
        "postgres://#{@postgres_config.username}:#{@postgres_config.password}@#{@postgres_config.host}:#{@postgres_config.port}/#{@postgres_config.database}"
    end

    def server_config 
        @server_config
    end

    def postgres_config
        @postgres_config
    end
end

private struct PostgresConfig
    def initialize(
        @username : String = "", @password : String = "", @host : String = "localhost", @port : Int32 = 5432, 
        @database_name : String = "")
    end 

    def username
        @username
    end

    def password 
        @password
    end

    def host 
        @host
    end

    def port 
        @port
    end

    def database
        @database_name
    end
end

private struct ServerConfig
    def initialize(host : String = "localhost", @port : Int32 = 5432)
        @host = host == "localhost" ? "127.0.0.1" : host
    end

    def host 
        @host
    end

    def port 
        @port
    end
end