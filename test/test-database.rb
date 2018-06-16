class TestDatabase < Test::Unit::TestCase

  def test_init_help
    output = `debsources-watch-crawler help init`
    expected = <<-EOS
Commands:
  debsources-watch-crawler init database        # Initialize database file
  debsources-watch-crawler init help [COMMAND]  # Describe subcommands or one specific subcommand

EOS
    assert_equal(expected, output)
  end
end
