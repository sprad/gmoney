# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gmoney}
  s.version = "0.4.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Justin Spradlin"]
  s.date = %q{2010-04-13}
  s.description = %q{A gem for interacting with the Google Finance API}
  s.email = %q{jspradlin@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "lib/extensions/fixnum.rb", "lib/extensions/nil_class.rb", "lib/extensions/string.rb", "lib/gmoney.rb", "lib/gmoney/authentication_request.rb", "lib/gmoney/feed_parser.rb", "lib/gmoney/gf_request.rb", "lib/gmoney/gf_response.rb", "lib/gmoney/gf_service.rb", "lib/gmoney/gf_session.rb", "lib/gmoney/portfolio.rb", "lib/gmoney/portfolio_feed_parser.rb", "lib/gmoney/position.rb", "lib/gmoney/position_feed_parser.rb", "lib/gmoney/transaction.rb", "lib/gmoney/transaction_feed_parser.rb"]
  s.files = ["Manifest", "README.rdoc", "Rakefile", "gmoney.gemspec", "lib/extensions/fixnum.rb", "lib/extensions/nil_class.rb", "lib/extensions/string.rb", "lib/gmoney.rb", "lib/gmoney/authentication_request.rb", "lib/gmoney/feed_parser.rb", "lib/gmoney/gf_request.rb", "lib/gmoney/gf_response.rb", "lib/gmoney/gf_service.rb", "lib/gmoney/gf_session.rb", "lib/gmoney/portfolio.rb", "lib/gmoney/portfolio_feed_parser.rb", "lib/gmoney/position.rb", "lib/gmoney/position_feed_parser.rb", "lib/gmoney/transaction.rb", "lib/gmoney/transaction_feed_parser.rb", "spec/authentication_request_spec.rb", "spec/fixtures/cacert.pem", "spec/fixtures/default_portfolios_feed.xml", "spec/fixtures/empty_portfolio_feed.xml", "spec/fixtures/new_portfolio_feed.xml", "spec/fixtures/new_transaction_feed.xml", "spec/fixtures/portfolio_9_feed.xml", "spec/fixtures/portfolio_feed_with_returns.xml", "spec/fixtures/position_feed_for_9_GOOG.xml", "spec/fixtures/positions_feed_for_portfolio_14.xml", "spec/fixtures/positions_feed_for_portfolio_9.xml", "spec/fixtures/positions_feed_for_portfolio_9r.xml", "spec/fixtures/transaction_feed_for_GOOG_1.xml", "spec/fixtures/transactions_feed_for_GOOG.xml", "spec/fixtures/updated_portfolio_feed.xml", "spec/gmoney_spec.rb", "spec/nil_class_spec.rb", "spec/portfolio_feed_parser_spec.rb", "spec/portfolio_spec.rb", "spec/position_feed_parser_spec.rb", "spec/position_spec.rb", "spec/request_spec.rb", "spec/response_spec.rb", "spec/service_spec.rb", "spec/session_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/string_spec.rb", "spec/transaction_feed_parser_spec.rb", "spec/transaction_spec.rb"]
  s.homepage = %q{http://www.justinspradlin.com/programming/introducing-gmoney-a-rubygem-for-interacting-with-the-google-finance-api/}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Gmoney", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{gmoney}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A gem for interacting with the Google Finance API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
