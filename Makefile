#   Makefile
#
# license   http://opensource.org/licenses/MIT The MIT License (MIT)
# copyright Copyright (c) 2016, TUNE Inc. (http://www.tune.com)
#

PYTHON3 := $(shell which python3)
PYTHON27 := $(shell which python2.7)
PIP3    := $(shell which pip3)
PY_MODULES := pip setuptools pylint flake8 pprintpp pep8 requests six sphinx wheel retry validators python-dateutil
PYTHON3_SITE_PACKAGES := $(shell python3 -c "import site; print(site.getsitepackages()[0])")

PYHTTPSTATUS_UTILS_PKG := pyhttpstatus-utils
PYHTTPSTATUS_UTILS_PKG_PREFIX := pyhttpstatus_utils

TUNE_MV_PKG_SUFFIX := py3-none-any.whl

VERSION := $(shell $(PYTHON3) setup.py version)
PYHTTPSTATUS_UTILS_WHEEL_ARCHIVE := dist/$(PYHTTPSTATUS_UTILS_PKG_PREFIX)-$(VERSION)-$(TUNE_MV_PKG_SUFFIX)

MV_INTEGRATION_FILES := $(shell find pyhttpstatus-utils ! -name '__init__.py' -type f -name "*.py")
LINT_REQ_FILE := requirements-pylint.txt
REQ_FILE      := requirements.txt
SETUP_FILE    := setup.py
ALL_FILES     := $(MV_INTEGRATION_FILES) $(REQ_FILE) $(SETUP_FILE)

# Report the current pyhttpstatus-utils version.
version:
	@echo MV Integration Base Version: $(VERSION)

# Install Python 3 via Homebrew.
brew-python:
	brew install python3
	$(eval $(shell which python3))
	$(PIP3) install --upgrade $(PY_MODULES)

# Upgrade pip. Note that this does not install pip if you don't have it.
# Pip must already be installed to work with this Makefile.
pip:
	$(PIP3) install --upgrade pip

clean:
	@echo "======================================================"
	@echo clean
	@echo "======================================================"
	rm -fR __pycache__ venv "*.pyc" build/*    \
		$(PYHTTPSTATUS_UTILS_PKG_PREFIX)/__pycache__/         \
		$(PYHTTPSTATUS_UTILS_PKG_PREFIX)/helpers/__pycache__/ \
		$(PYHTTPSTATUS_UTILS_PKG_PREFIX).egg-info/*
	find ./* -maxdepth 0 -name "*.pyc" -type f -delete
	find $(PYHTTPSTATUS_UTILS_PKG_PREFIX) -name "*.pyc" -type f -delete

# Install the project requirements.
requirements: $(REQ_FILE) pip
	$(PIP3) install --upgrade -r $(REQ_FILE)

# Make a project distributable.
dist: clean
	@echo "======================================================"
	@echo dist
	@echo "======================================================"
	@echo Building: $(PYHTTPSTATUS_UTILS_WHEEL_ARCHIVE)
	$(PYTHON3) --version
	find ./dist/ -name $(PYHTTPSTATUS_UTILS_PKG_PREFIX_PATTERN) -exec rm -vf {} \;
	$(PYTHON3) $(SETUP_FILE) bdist_wheel
	$(PYTHON3) $(SETUP_FILE) bdist_egg
	$(PYTHON3) $(SETUP_FILE) sdist --format=zip,gztar
	ls -al ./dist/$(PYHTTPSTATUS_UTILS_PKG_PREFIX_PATTERN)

# DIST UPDATE INTENTIONALLY REMOVED

# Build and install the module. Apparently this target isn't really used
# anymore. It's a candidate for removal, or at least redefinition, since
# "build" is a useful target, generally speaking.
build: $(ALL_FILES) pip requirements
	$(PYTHON3) $(SETUP_FILE) clean
	$(PYTHON3) $(SETUP_FILE) build
	$(PYTHON3) $(SETUP_FILE) install

uninstall:
	@echo "======================================================"
	@echo uninstall $(PYHTTPSTATUS_UTILS_PKG)
	@echo "======================================================"
	$(PIP3) install --upgrade list
	@if $(PIP3) list --format=legacy | grep -F $(PYHTTPSTATUS_UTILS_PKG) > /dev/null; then \
		echo "python package $(PYHTTPSTATUS_UTILS_PKG) Found"; \
		$(PIP3) uninstall --yes $(PYHTTPSTATUS_UTILS_PKG); \
	else \
		echo "python package $(PYHTTPSTATUS_UTILS_PKG) Not Found"; \
	fi;

remove-package: uninstall
	@echo "======================================================"
	@echo remove-package $(PYHTTPSTATUS_UTILS_PKG)
	@echo "======================================================"
	rm -fR $(PYTHON3_SITE_PACKAGES)/$(PYHTTPSTATUS_UTILS_PKG_PREFIX)*

# Install the module from a binary distribution archive.
install: remove-package
	@echo "======================================================"
	@echo install $(PYHTTPSTATUS_UTILS_PKG)
	@echo "======================================================"
	$(PIP3) install --upgrade pip
	$(PIP3) install --upgrade $(PYHTTPSTATUS_UTILS_WHEEL_ARCHIVE)
	$(PIP3) freeze | grep $(PYHTTPSTATUS_UTILS_PKG)

# Install project for local development. Changes to the files will be reflected in installed code
local-dev-editable: remove-package
	@echo "======================================================"
	@echo local-dev-editable $(PYHTTPSTATUS_UTILS_PKG)
	@echo "======================================================"
	$(PIP3) install --upgrade freeze
	$(PIP3) install --upgrade --editable .
	$(PIP3) freeze | grep $(PYHTTPSTATUS_UTILS_PKG)

local-dev: remove-package
	@echo "======================================================"
	@echo local-dev $(PYHTTPSTATUS_UTILS_PKG)
	@echo "======================================================"
	$(PIP3) install --upgrade freeze
	$(PIP3) install --upgrade .
	$(PIP3) freeze | grep $(PYHTTPSTATUS_UTILS_PKG)

dist:
	rm -fR ./dist/*
	$(PYTHON3) $(SETUP_FILE) sdist --format=zip,gztar upload
	$(PYTHON27) $(SETUP_FILE) bdist_egg upload
	$(PYTHON27) $(SETUP_FILE) bdist_wheel upload
	$(PYTHON3) $(SETUP_FILE) bdist_egg upload
	$(PYTHON3) $(SETUP_FILE) bdist_wheel upload

build:
	$(PIP3) install --upgrade -r requirements.txt
	$(PYTHON3) $(SETUP_FILE) clean
	$(PYTHON3) $(SETUP_FILE) build
	$(PYTHON3) $(SETUP_FILE) install

# Register the module with PyPi.
register:
	$(PYTHON3) $(SETUP_FILE) register

flake8:
	flake8 --ignore=F401,E265,E129 tune
	flake8 --ignore=E123,E126,E128,E265,E501 tests

analysis: install
	. venv/bin/activate; flake8 --ignore=E123,E126,E128,E265,E501 examples
	. venv/bin/activate; flake8 --ignore=E123,E126,E128,E265,E501 tests
	. venv/bin/activate; flake8 --ignore=F401,E265,E129 pyhttpstatus-utils
	. venv/bin/activate; pylint --rcfile tools/pylintrc pyhttpstatus-utils | more

lint: clean
	pylint --rcfile .pylintrc pyhttpstatus-utils | more

lint-requirements: $(LINT_REQ_FILE)
	$(PIP3) install --upgrade -f $(LINT_REQ_FILE)

pep8: lint-requirements
	@echo pep8: $(MV_INTEGRATION_FILES)
	$(PYTHON3) -m pep8 --config .pep8 $(MV_INTEGRATION_FILES)

pyflakes: lint-requirements
	@echo pyflakes: $(MV_INTEGRATION_FILES)
	$(PYTHON3) -m pyflakes $(MV_INTEGRATION_FILES)

pylint: lint-requirements
	@echo pylint: $(MV_INTEGRATION_FILES)
	$(PYTHON3) -m pylint --rcfile .pylintrc $(MV_INTEGRATION_FILES) --disable=C0330,F0401,E0611,E0602,R0903,C0103,E1121,R0913,R0902,R0914,R0912,W1202,R0915,C0302 | more -30

site-packages:
	@echo $(PYTHON3_SITE_PACKAGES)

list-package:
	ls -al $(PYTHON3_SITE_PACKAGES)/$(PYHTTPSTATUS_UTILS_PKG_PREFIX)*


.PHONY: brew-python clean register lint pylint pep8 pyflakes examples analysis
