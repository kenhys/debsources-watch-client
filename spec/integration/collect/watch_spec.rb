RSpec.describe "`debsources-watch-client collect watch` command", type: :cli do
  it "executes `debsources-watch-client collect help watch` command successfully" do
    output = `debsources-watch-client collect help watch`
    expected_output = <<-OUT
Usage:
  debsources-watch-client watch [PACKAGE]

Options:
  -h, [--help], [--no-help]  # Display usage information

Collect debian/watch files
    OUT

    expect(output).to eq(expected_output)
  end
end
