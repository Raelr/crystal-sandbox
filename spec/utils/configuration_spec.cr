require "../spec_helper"

describe Utils::ApiUtils::Configuration do
    describe "#init empty" do 
        it "creates a new config entity without a file" do 
            config = Utils::ApiUtils::Configuration.new
            config.database_url.should eq "postgres://:@:/"
        end
    end

    describe "#init with config" do
        it "correctly reports the database URL as configured in configuration.yaml" do
            config = Utils::ApiUtils::Configuration.new("./spec/configuration_test.yaml")
            config.database_url.should eq "postgres://test_user:test_password@localhost:5432/test_db"
        end 
    end
end


