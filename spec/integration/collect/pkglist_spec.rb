RSpec.describe "`debsources-watch-client collect pkglist` command", type: :cli do
  it "executes `debsources-watch-client collect help pkglist` command successfully" do
    output = `debsources-watch-client collect help pkglist`
    expected_output = <<-OUT
Usage:
  debsources-watch-client pkglist

Options:
  -h, [--help], [--no-help]  # Display usage information

Collect debian package list
    OUT

    expect(output).to eq(expected_output)
  end
end
