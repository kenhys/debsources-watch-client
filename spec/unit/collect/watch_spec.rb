require 'debsources/watch/client/commands/collect/watch'

RSpec.describe Debsources::Watch::Client::Commands::Collect::Watch do
  it "executes `collect watch` command successfully" do
    output = StringIO.new
    package = nil
    options = {}
    command = Debsources::Watch::Client::Commands::Collect::Watch.new(package, options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
