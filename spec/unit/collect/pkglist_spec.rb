require 'debsources/watch/client/commands/collect/pkglist'

RSpec.describe Debsources::Watch::Client::Commands::Collect::Pkglist do
  it "executes `collect pkglist` command successfully" do
    output = StringIO.new
    options = {}
    command = Debsources::Watch::Client::Commands::Collect::Pkglist.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
