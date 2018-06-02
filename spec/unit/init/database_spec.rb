require 'debsources/watch/client/commands/init/database'

RSpec.describe Debsources::Watch::Client::Commands::Init::Database do
  it "executes `init database` command successfully" do
    output = StringIO.new
    options = {}
    command = Debsources::Watch::Client::Commands::Init::Database.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
