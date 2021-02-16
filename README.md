## PactConsumerSwiftExample SSL Implementation example.
Example of implementation of Pact Consumer library with SSL configuration.

Install pact standalone in your machine.

brew tap pact-foundation/pact-ruby-standalone
brew install pact-ruby-standalone

Start the server with ssl configuration by running:
pact-mock-service start --ssl --pact-specification-version 2.0.0 --log "${SRCROOT}/tmp/pact-ssl.log" --pact-dir "${SRCROOT}/tmp/pacts-ssl" -p 1234

Run pod install in order to execute this project.
Run testItSaysHello test.

