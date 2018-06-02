RSpec.describe "`debsources-watch-client init` command", type: :cli do
  it "executes `debsources-watch-client help init` command successfully" do
    output = `debsources-watch-client help init`
    expected_output = <<-OUT
Commands:
    OUT

    expect(output).to eq(expected_output)
  end
end
