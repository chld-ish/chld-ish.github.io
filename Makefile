all: build

HOMEBREW_PREFIX = /usr/local
RUBY_BINDIR = ~/.rbenv/versions/3.4.0/bin
RUBY = $(RUBY_BINDIR)/ruby
BUNDLER = /Users/ruthejane/.rbenv/versions/3.4.0/lib/ruby/gems/3.4.0+1/gems/bundler-2.6.2/exe/bundle

BUNDLER_CACHE = vendor
MIDDLEMAN = bin/middleman

TIDY = $(HOMEBREW_PREFIX)/bin/tidy
TIDY_FLAGS = -q -e --gnu-emacs true --strict-tags-attributes true --drop-empty-elements false

$(BUNDLER):
	@echo 'Ruby from Homebrew is not installed. Please install it by running `brew install ruby`'
	@false

$(MIDDLEMAN): $(BUNDLER)
	$(BUNDLER) install --path $(BUNDLER_CACHE) --binstubs

.PHONY: middleman-init
middleman-init:: $(MIDDLEMAN)
	$(RUBY) $(MIDDLEMAN) init

.PHONY: build
build: $(MIDDLEMAN)
	$(RUBY) $(MIDDLEMAN) build --verbose

preview serve: $(MIDDLEMAN)
	$(RUBY) $(MIDDLEMAN) serve

$(TIDY):
	@echo 'Please install HTML5 Tidy using the command \`brew install tidy-html5\`.'
	@echo 'Note that there is an ancient version of tidy installed with macOS into'
	@echo '/usr/bin/tidy, but that is not the one we need, the one we need will be'
	@echo 'installed via Homebrew at $(TIDY)'
	false

validate valid lint:: build $(TIDY)
	find docs -iname \*.html -print0 | xargs -0 -n 1 $(TIDY) $(TIDY_FLAGS)

distclean:
		rm -rf $(BUNDLER_CACHE) bin
