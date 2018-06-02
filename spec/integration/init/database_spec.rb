RSpec.describe "`debsources-watch-client init database` command", type: :cli do
  it "executes `debsources-watch-client init help database` command successfully" do
    output = `debsources-watch-client init help database`
    expected_output = <<-OUT
Usage:
  debsources-watch-client database

Options:
  -h, [--help], [--no-help]  # Display usage information

Initialize database file
    OUT

    expect(output).to eq(expected_output)
  end
end
