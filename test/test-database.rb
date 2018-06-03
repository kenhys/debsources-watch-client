class TestDatabase < Test::Unit::TestCase

  def test_init_help
    output = `debsources-watch-client help init`
    expected = <<-EOS
Commands:
  debsources-watch-client init database        # Initialize database file
  debsources-watch-client init help [COMMAND]  # Describe subcommands or one specific subcommand

EOS
    assert_equal(expected, output)
  end
end
