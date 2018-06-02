RSpec.describe "`debsources-watch-client collect` command", type: :cli do
  it "executes `debsources-watch-client help collect` command successfully" do
    output = `debsources-watch-client help collect`
    expected_output = <<-OUT
Commands:
    OUT

    expect(output).to eq(expected_output)
  end
end
