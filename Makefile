all: build

HOMEBREW_PREFIX:= $(shell brew --prefix 2>/dev/null || echo '/Homebrew_is_Missing')
RUBY_VERSION:= $(shell cat .ruby-version)

RBENV:= $(HOMEBREW_PREFIX)/bin/rbenv
RBENV_DIR:= ~/.rbenv

RUBY_BUILD:= $(HOMEBREW_PREFIX)/bin/ruby-build
RUBY_DIR:= $(RBENV_DIR)/versions/$(RUBY_VERSION)
RUBY:= $(RUBY_DIR)/bin/ruby

GEM:= $(RUBY_DIR)/bin/gem
GEMS_DIR:= $(shell $(GEM) env home 2>/dev/null || echo '/Gem_is_missing')

BUNDLER_VERSION:= 2.4.10
BUNDLER:= $(GEMS_DIR)/gems/bundler-$(BUNDLER_VERSION)/exe/bundle

BUNDLER_CACHE:= vendor
MIDDLEMAN:= bin/middleman

TIDY = $(HOMEBREW_PREFIX)/bin/tidy
TIDY_FLAGS = -q -e --gnu-emacs true --strict-tags-attributes true --drop-empty-elements false

$(HOMEBREW_PREFIX):
	@echo 'We need Homebrew in order to install some dependencies. Please install it by going to https://brew.sh and following the instructions there.'
	@false

$(RBENV) $(RUBY_BUILD): $(HOMEBREW_PREFIX)
	@echo 'We need rbenv and ruby-build in order to install the correct version of ruby. Please install them by running `brew install rbenv ruby-build`.'
	@false

$(RUBY): $(RBENV) $(RUBY_BUILD)
	@echo 'We don’t have the correct version of ruby installed into $(RUBY_DIR), so we’re going to build and install it now.'
	@echo 'This may take some time...'
	@echo
	$(RBENV) install $(RUBY_VERSION)

$(BUNDLER): $(RUBY)
	@echo 'Missing bundler at $(BUNDLER). Installing it now...'
	$(GEM) install -v $(BUNDLER_VERSION) bundler

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

$(TIDY): $(HOMEBREW_PREFIX)
	@echo 'Please install HTML5 Tidy using the command \`brew install tidy-html5\`.'
	@echo 'Note that there is an ancient version of tidy installed with macOS into'
	@echo '/usr/bin/tidy, but that is not the one we need, the one we need will be'
	@echo 'installed via Homebrew at $(TIDY)'
	false

validate valid lint:: build $(TIDY)
	find docs -iname \*.html -print0 | xargs -0 -n 1 $(TIDY) $(TIDY_FLAGS)

distclean:
		rm -rf $(BUNDLER_CACHE) bin
