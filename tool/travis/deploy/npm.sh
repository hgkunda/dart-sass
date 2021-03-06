#!/bin/bash -e
# Copyright 2018 Google Inc. Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.

source tool/travis/util.sh

decrypt_credentials
tar xfO credentials.tar npm > ~/.npmrc

travis_cmd pub run grinder npm_release_package
travis_cmd npm publish build/npm
travis_cmd npm publish build/npm-old
