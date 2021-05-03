require "../spec_helper"

describe Utils::ApiUtils::Configuration do
    describe "#init empty" do 
        it "creates a new config entity without a file" do 
            config = Utils::ApiUtils::Configuration.new
            config.database_url.should eq "postgres://:@localhost:5432/"
        end
    end

    describe "#init with config" do
        it "correctly reports the database URL as configured in configuration.yaml" do
            config = Utils::ApiUtils::Configuration.new("./spec/configuration_test.yaml")
            config.database_url.should eq "postgres://test_user:test_password@localhost:5432/test_db"
        end 
    end

    describe "#init and check config parameters" do 
        it "correctly extracts all parameters from the configuration.yaml file" do 
            config = Utils::ApiUtils::Configuration.new("./spec/configuration_test.yaml")
            config.server_config.host.should eq "127.0.0.1"
            config.server_config.port.should eq 8080
        end
    end
end


