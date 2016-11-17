#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#  @namespace pyhttpstatus-utils

from __future__ import with_statement

# To install the tune-mv-integration-python library, open a Terminal shell,
# then run this file by typing:
#
# python setup.py install
#

import sys
import re
from setuptools import setup

REQUIREMENTS = [
    req for req in open('requirements.txt')
    .read().split('\n')
    if req != ''
]

PACKAGES = [
    'pyhttpstatus_utils'
]

CLASSIFIERS = [
    # How mature is this project? Common values are
    #   3 - Alpha
    #   4 - Beta
    #   5 - Production/Stable
    'Development Status :: 5 - Production/Stable',
    'Intended Audience :: Developers',
    'License :: OSI Approved :: MIT License',
    'Operating System :: OS Independent',
    'Natural Language :: English',
    'Programming Language :: Python',
    'Programming Language :: Python :: 2.7',
    'Programming Language :: Python :: 3',
    'Programming Language :: Python :: 3.0',
    'Programming Language :: Python :: 3.1',
    'Programming Language :: Python :: 3.2',
    'Programming Language :: Python :: 3.3',
    'Programming Language :: Python :: 3.4',
    'Topic :: Software Development :: Libraries :: Python Modules'
]

with open('pyhttpstatus_utils/__init__.py', 'r') as fd:
    version = re.search(r'^__version__\s*=\s*[\'"]([^\'"]*)[\'"]', fd.read(), re.MULTILINE).group(1)

if not version:
    raise RuntimeError('Cannot find version information')

if len(sys.argv) < 2 or sys.argv[1] == 'version':
    print(version)
    sys.exit()

setup(
    name='pyhttpstatus-utils',
    version=version,
    description='Timezone conversion functions for Python',
    author='TUNE Inc., TuneLab',
    author_email='jefft@tune.com',
    url='https://github.com/TuneLab/pyhttpstatus-utils',
    install_requires=REQUIREMENTS,
    packages=PACKAGES,
    package_dir={'pyhttpstatus-utils': 'pyhttpstatus-utils'},
    include_package_data=True,
    license='Apache 2.0',
    zip_safe=False,
    classifiers=CLASSIFIERS,
    long_description="""\
    Timezone conversion functions.
    ------------------------------

    Extension of python package pytz by providing timezone conversion functions.

    See https://github.com/TuneLab/pyhttpstatus-utils for more information.
    """
)
