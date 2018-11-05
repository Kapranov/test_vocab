# TestVocab

Using RDF.ex to work with RDF vocabularies in Elixir

**TODO: Add description**

## RDF

The Resource Description Framework (RDF) is a framework for expressing
information about resources. Resources can be anything, including
documents, people, physical objects, and abstract concepts.

RDF is intended for situations in which information on the Web needs to
be processed by applications, rather than being only displayed to
people. RDF provides a common framework for expressing this information
so it can be exchanged between applications without loss of meaning.
Since it is a common framework, application designers can leverage the
availability of common RDF parsers and processing tools. The ability to
exchange information between different applications means that the
information may be made available to applications other than those for
which it was originally created.

In particular RDF can be used to publish and interlink data on the Web.
For example, retrieving `http://www.example.org/bob#me`  could provide
data about Bob, including the fact that he knows Alice, as identified by
her IRI (an IRI is an "International Resource Identifier";). Retrieving
Alice's IRI could then provide more data about her, including links to
other datasets for her friends, interests, etc. A person or an automated
process can then follow such links and aggregate data about these
various things. Such uses of RDF are often qualified as Linked Data
[LINKED-DATA].

## Why Use RDF?

The following illustrates various different uses of RDF, aimed at
different communities of practice.

* Adding machine-readable information to Web pages using, for example,
  the popular `schema.org`  vocabulary, enabling them to be displayed in
  an enhanced format on search engines or to be processed automatically
  by third-party applications.
* Enriching a dataset by linking it to third-party datasets. For
  example, a dataset about paintings could be enriched by linking them
  to the corresponding artists in Wikidata, therefore giving access to
  a wide range of information about them and related resources.
* Interlinking API feeds, making sure that clients can easily discover
  how to access more information.
* Using the datasets currently published as Linked Data [LINKED-DATA],
  for example building aggregations of data around specific topics.
* Building distributed social networks by interlinking RDF descriptions
  of people across multiple Web sites.
* Providing a standards-compliant way for exchanging data between
  databases.
* Interlinking various datasets within an organisation, enabling
  cross-dataset queries to be performed using SPARQL

## RDF Data Model

RDF allows us to make statements about resources. The format of these
statements is simple. A statement always has the following structure:

```
<subject> <predicate> <object>
```
An RDF statement expresses a relationship between two resources.  The
subject and the object represent the two resources being related; the
predicate represents the nature of their relationship. The relationship
is phrased in a directional way (from subject to object) and is called
in RDF a property. Because RDF statements consist of three elements they
are called triples.

Here are examples of RDF triples (informally expressed in pseudocode):

Example 1: Sample triples (informal)

```
<Bob> <is a> <person>.
<Bob> <is a friend of> <Alice>.
<Bob> <is born on> <the 4th of July 1990>.
<Bob> <is interested in> <the Mona Lisa>.
<the Mona Lisa> <was created by> <Leonardo da Vinci>.
<the video 'La Joconde à Washington'> <is about> <the Mona Lisa>
```
## Create a `TestVocab` project

```bash
mkdir test_vocab
cd test_vocab

mix new .
```

```elixir
# mix.exs
defmodule TestVocab.MixProject do
  use Mix.Project

  def project do
    [
      app: :test_vocab,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: applications(Mix.env)
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10.1", only: :test},
      {:ex_unit_notifier, "~> 0.1.4", only: :test},
      {:mix_test_watch, "~> 0.9.0", only: :dev, runtime: false},
      {:rdf, "~> 0.5.1"},
      {:remix, "~> 0.0.2", only: :dev}
    ]
  end

  defp applications(:dev), do: applications(:all) ++ [:remix]
  defp applications(_all), do: [:logger]
end

# config/config.exs
use Mix.Config

if Mix.env == :dev do
  config :mix_test_watch, clear: true
  config :remix, escript: true, silent: true
end

if Mix.env == :test do
  config :ex_unit_notifier,
    notifier: ExUnitNotifier.Notifiers.NotifySend
end

# import_config "#{Mix.env()}.exs"

# test/test_helper.exs
ExUnit.configure formatters: [ExUnit.CLIFormatter, ExUnitNotifier]
ExUnit.start()
```

```bash
# Makefile
V ?= @
SHELL := /usr/bin/env bash
ERLSERVICE := $(shell pgrep beam.smp)

ELIXIR = elixir

VERSION = $(shell git describe --tags --abbrev=0 | sed 's/^v//')

NO_COLOR=\033[0m
INFO_COLOR=\033[2;32m
STAT_COLOR=\033[2;33m

# ------------------------------------------------------------------------------

help:
			$(V)echo Please use \'make help\' or \'make ..any_parameters..\'

push:
			$(V)git add .
			$(V)git commit -m "added support Makefile"
			$(V)git push -u origin master

git-%:
			$(V)git pull

kill:
			$(V)echo "Checking to see if Erlang process exists:"
			$(V)if [ "$(ERLSERVICE)" ]; then killall beam.smp && echo "Running Erlang Service Killed"; else echo "No Running Erlang Service!"; fi

clean:
			$(V)mix deps.clean --all
			$(V)mix do clean
			$(V)rm -fr _build/ ./deps/

packs:
			$(V)mix deps.get
			$(V)mix deps.update --all
			$(V)mix deps.get

report:
			$(V)MIX_ENV=dev
			$(V)mix coveralls
			$(V)mix coveralls.detail
			$(V)mix coveralls.html
			$(V)mix coveralls.json

test:
			$(V)clear
			$(V)echo -en "\n\t$(INFO_COLOR)Run server tests:$(NO_COLOR)\n\n"
			$(V)mix test

credo:
			$(V)mix credo --strict
			$(V)mix coveralls

run: kill clean packs
			$(V)iex -S mix

halt: kill
			$(V)echo -en "\n\t$(STAT_COLOR) Run server http://localhost:$(NO_COLOR)$(INFO_COLOR)PORT$(NO_COLOR)\n"
			$(V)mix run --no-halt

start: kill
			$(V)echo -en "\n\t$(STAT_COLOR) Run server http://localhost:$(NO_COLOR)$(INFO_COLOR)PORT$(NO_COLOR)\n"
			$(V)iex -S mix

all: test credo report start

.PHONY: test halt
```

```bash
#!/usr/bin/env bash

make start
```

## An implementation of RDF for Elixir

```bash

bash> make all

iex> import RDF, only: [iri: 1]
#=> RDF

iex> alias RDF.NS.{RDFS}
#=> [RDF.NS.RDFS]

iex> RDFS.Class
#=> RDF.NS.RDFS.Class

iex> iri(RDFS.Class)
#=> ~I<http://www.w3.org/2000/01/rdf-schema#Class>

iex> RDFS.subClassOf
#=> ~I<http://www.w3.org/2000/01/rdf-schema#subClassOf>

iex> iri(RDFS.subClassOf)
~I<http://www.w3.org/2000/01/rdf-schema#subClassOf>

iex> RDF.type
#=> ~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>

iex> iri(RDF.Property)
#=> ~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#Property>
```

```elixir
defmodule YourApp.NS do
  use RDF.Vocabulary.Namespace

  defvocab EX,
    base_iri: "http://www.example.com/ns/",
    terms: ~w[Foo bar]
end

defmodule YourApp.NS do
  use RDF.Vocabulary.Namespace

  defvocab EX,
    base_iri: "http://www.example.com/ns/",
    file: "your_vocabulary.nt"
end

defmodule YourApp.NS do
  use RDF.Vocabulary.Namespace

  defvocab EX,
    base_iri: "http://www.example.com/ns/",
    file: "your_vocabulary.nt"
    alias: [example_term: "example-term"]
end

defmodule YourApp.NS do
  use RDF.Vocabulary.Namespace

  defvocab EX,
    base_iri: "http://www.example.com/ns/",
    file: "your_vocabulary.nt",
    ignore: ~w[Foo bar]
end

defmodule YourApp.NS do
  use RDF.Vocabulary.Namespace

  defvocab EX,
    base_iri: "http://www.example.com/ns/",
    terms: [],
    strict: false
end

iex> import RDF, only: [iri: 1]
iex> alias YourApp.NS.{EX}
#=> [YourApp.NS.EX]

iex> iri(EX.Foo)
#=> ~I<http://www.example.com/ns/Foo>

iex> EX.bar
#=> ~I<http://www.example.com/ns/bar>

iex> EX.Foo |> EX.bar(EX.Baz)
#RDF.Description{subject: ~I<http://www.example.com/ns/Foo>
#=> ~I<http://www.example.com/ns/bar>
      ~I<http://www.example.com/ns/Baz>}
```

I won't give any detailed introduction to `RDX.ex` here but will focus
here on one particular aspect – the support for RDF vocabularies. The
distribution ships with five vocabularies (`RDF`, `RDFS`, `OWL`, `SKOS`,
and `XSD`) already included. But it should be pretty simple to add in
some new vocabularies, for example `DC` and `BIBO`.

Let's see how we might do this.

### 5 November 2018 by Oleg G.Kapranov

[1]: https://www.w3.org/TR/rdf11-primer/
[2]: https://github.com/marcelotto/rdf-ex
[3]: https://medium.com/@tonyhammond/early-steps-in-elixir-and-rdf-5078a4ebfe0f
[4]: https://github.com/tonyhammond/examples/tree/master/test_vocab
