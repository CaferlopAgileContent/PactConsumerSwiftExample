#!/usr/bin/env bash

# Xcode scripting does not invoke rvm. To get the correct ruby,
# we must invoke rvm manually. This requires loading the rvm 
# *shell function*, which can manipulate the active shell-script
# environment.
# cf. http://rvm.io/workflow/scripting

# Print out result from script
exec > ${PROJECT_DIR}/prebuild.log 2>&1

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then

  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"

elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then

  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"
else

  printf "ERROR: An RVM installation was not found.\n"
  exit 128
fi

# rvm will use the controlling versioning (e.g. .ruby-version) for the
# pwd using this function call.
rvm use .

PactPath=`which pact-mock-service`
echo $PactPath
TrimmedPath=${PactPath%?????????????????} 
echo $TrimmedPath
PATH=TrimmedPath:$PATH
pact-mock-service start --ssl --pact-specification-version 2.0.0 --log "${SRCROOT}/tmp/pact-ssl.log" --pact-dir "${SRCROOT}/tmp/pacts-ssl" -p 1234
