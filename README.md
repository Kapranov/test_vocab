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

First off, let's create a new project `TestVocab` (in camel case) using
the usual Mix build tool invocation (in snake case): `mix new test_vocab`
We'll then declare a dependency on `RDF.ex` in the `mix.exs` file:

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

I won't give any detailed introduction to `RDX.ex` here but will focus
here on one particular aspect – the support for RDF vocabularies. The
distribution ships with five vocabularies (`RDF`, `RDFS`, `OWL`, `SKOS`,
and `XSD`) already included. But it should be pretty simple to add in
some new vocabularies, for example `DC` and `BIBO`.

Let's see how we might do this.

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

## Add a new vocabulary for `DC` elements

Now let's look first at the core DC elements vocabulary as this is very
simple: 15 properties only. In fact, with this small a number we can
easily list these out by hand. We'll make some changes to our main
module `TestVocab` which is defined in the usual `lib/test_vocab.ex`
location. Specifically, we'll remove the standard boilerplate and add a
`use` declaration, and also a `defvocab`  definition block for `DC`.
We also include a `@moduledoc` attribute for documentation purposes.

```elixir
# lib/test_vocab.ex
defmodule TestVocab do
  @moduledoc """
  Test module used in "Early steps in Elixir and RDF"
  """

  use RDF.Vocabulary.Namespace

  defvocab DC,
    base_iri: "http://purl.org/dc/elements/1.1/",
    terms: ~w[
      contributor coverage creator date description format
      identifier language publisher relation rights source
      subject title type
    ]
end
```
Note that in the `defvocab` definition block we have two keywords:
`base_iri` which is a string specifying the base IRI for the vocabulary,
and `terms` which takes a word list of the vocabulary terms.
Let's try this out in Elixir shell `make all`:

```bash
iex> alias TestVocab.DC
#=> TestVocab.DC

iex> DC.type
#=> ~I<http://purl.org/dc/elements/1.1/type>

iex> DC.format
#=> ~I<http://purl.org/dc/elements/1.1/format>

iex> i DC.type

iex> DC.type.value
#=> "http://purl.org/dc/elements/1.1/type"
```

So, there we have it, a very simple means of generating RDF IRIs in the
DC namespace. Note that `RDF.ex` maintains IRIs as Elixir structs as we
can see by using the `i` helper in IEx: `i DC.type`.

The `~I` sigil is used to provide a simple string representation for the
IRI struct. We can access the IRI string by using the `value` field of
the struct.

Now, there is a simpler way to do this. Instead of explicitly listing
out all the terms we can just point at a vocabulary schema file and
`RDF.ex` will determine which terms to include for us. The schema file
`dc.ttl` is read from the standard location `priv/vocabs/`. We just need
to add this path to the project and add in the schema file itself.
(Note that other RDF serializations could also have been used.)

```elixir
defmodule TestVocab do
  @moduledoc """
  Test module used in "Early steps in Elixir and RDF"
  """

  use RDF.Vocabulary.Namespace

  defvocab DC,
    base_iri: "http://purl.org/dc/elements/1.1/",
    file: "dc.ttl"
end
```

```bash
mkdir -p priv/vocabs/
mkdir -p priv/data

touch priv/vocabs/dc.ttl
touch priv/vocabs/bibo.ttl
touch priv/data/978-1-68050-252-7.ttl
```

Well first let's make things easier by adding a `.iex.exs` hidden
file for IEx configuration on startup which imports functions from
our project `TestVocab`, imports some basic building block functions
(`iri/1`, `literal/1`, `literal/2`, `triple/3`) from the `RDF` module,
and also adds an alias for the builtin XSD namespace so we can use the
unqualified namespace form `XSD.*`, as well as our vocabulary namespaces
so we can use the unqualified namespace forms `BIBO.*`, `DC.*`, etc.
(By the way,  functions tend to be identified using a `name/arity` form,
where `arity` is the number of arguments a function takes.)

```elixir
# .iex.exs
import TestVocab
import RDF, only: [iri: 1, literal: 1, literal: 2, triple: 3]

alias RDF.NS.{XSD}
alias TestVocab.{DC, BIBO, DCTERMS, EVENT, FOAF, PRISM, SCHEMA, STATUS}
```

We can also check out the namespace using the private fields
`__base_iri__` and `__terms__` which echo the keywords `base_iri `
and `terms` used in creating the vocabulary term.

```bash
iex> DC.__base_iri__
#=> "http://purl.org/dc/elements/1.1/"

iex> DC.__terms__
#=> [:contributor, :coverage, :creator, :date, :description,
     :format, :identifier, :language, :publisher, :relation,
     :rights, :source, :subject, :title, :type]
```

## Add new vocabularies for `BIBO` ontology

Now let's try something more ambitious – the BIBO ontology. This term
set has both classes and properties and also spans multiple namespaces.
For this term set we will read the RDF file `bibo.ttl` in `priv/vocabs/`
and add in these vocabulary definitions to our `lib/test_vocab.ex` file:

```elixir
defmodule TestVocab do
  @moduledoc """
  Test module used in "Early steps in Elixir and RDF"
  """

  use RDF.Vocabulary.Namespace

  ## vocabulary defintions

  # DC namespaces

  defvocab DC,
    base_iri: "http://purl.org/dc/elements/1.1/",
    file: "dc.ttl"

  # BIBO namespaces

  defvocab BIBO,
    base_iri: "http://purl.org/ontology/bibo/",
    file: "bibo.ttl",
    case_violations: :ignore

  defvocab DCTERMS,
    base_iri: "http://purl.org/dc/terms/",
    file: "bibo.ttl",
    case_violations: :ignore

  defvocab EVENT,
    base_iri: "http://purl.org/NET/c4dm/event.owl#",
    file: "bibo.ttl"

  defvocab FOAF,
    base_iri: "http://xmlns.com/foaf/0.1/",
    file: "bibo.ttl"

  defvocab PRISM,
    base_iri: "http://prismstandard.org/namespaces/1.2/basic/",
    file: "bibo.ttl"

  defvocab SCHEMA,
    base_iri: "http://schemas.talis.com/2005/address/schema#",
    file: "bibo.ttl"

  defvocab STATUS,
    base_iri: "http://purl.org/ontology/bibo/status/",
    file: "bibo.ttl",
    case_violations: :ignore
end
```
Now when we recompile this by opening IEx again (or by using the
`recompile` command), we'll  see some warnings. For the purposes
of this tutorial let's just ignore this validation behaviour for
now by setting the `case_violations` option to `:ignore` for
these namespaces.

```
defvocab BIBO,
  base_iri: "http://purl.org/ontology/bibo/",
  file: "bibo.ttl",
  case_violations: :ignore

defvocab DCTERMS,
  base_iri: "http://purl.org/dc/terms/",
  file: "bibo.ttl",
  case_violations: :ignore

...

defvocab STATUS,
  base_iri: "http://purl.org/ontology/bibo/status/",
  file: "bibo.ttl",
  case_violations: :ignore
```
If we now reopen IEx we can try out the new vocabularies. We'll
first alias the namespaces so we can use project unqualified names.

```bash
bash> make all

...
Compiler.spawn_workers/6
Compiling 1 file (.ex)
Compiling vocabulary namespace for http://purl.org/dc/elements/1.1/
Compiling vocabulary namespace for http://purl.org/ontology/bibo/
Compiling vocabulary namespace for http://purl.org/dc/terms/
Compiling vocabulary namespace for http://purl.org/NET/c4dm/event.owl#
Compiling vocabulary namespace for http://xmlns.com/foaf/0.1/
Compiling vocabulary namespace for http://prismstandard.org/namespaces/1.2/basic/
Compiling vocabulary namespace for http://schemas.talis.com/2005/address/schema#
Compiling vocabulary namespace for http://purl.org/ontology/bibo/status/

iex> alias TestVocab.{DC, BIBO, DCTERMS, EVENT, FOAF, PRISM, SCHEMA STATUS}
#=> [TestVocab.DC, TestVocab.BIBO, TestVocab.DCTERMS, TestVocab.EVENT,
     TestVocab.FOAF, TestVocab.PRISM, TestVocab.SCHEMA, TestVocab.STATUS]

iex> FOAF.family_name
#=> ~I<http://xmlns.com/foaf/0.1/family_name>

iex> DCTERMS.isVersionOf
#=> ~I<http://purl.org/dc/terms/isVersionOf>

iex> BIBO.editor
#=> ~I<http://purl.org/ontology/bibo/editor>

iex> PRISM.doi
#=> ~I<http://prismstandard.org/namespaces/1.2/basic/doi>
```

Looks good so far for these properties.

Now classes behave a little differently. They do not resolve directly
to IRIs as properties do but can be made to resolve using the `RDF.iri`
function. They are, however, allowed by `RDF.ex` in any place that an
IRI is expected.

```bash
iex> BIBO.Book
#=> TestVocab.BIBO.Book

iex> RDF.iri(BIBO.Book)
#=> ~I<http://purl.org/ontology/bibo/Book>

iex> i BIBO.Book
```

## Use the vocabularies to build RDF statements

So, let's put this to use now and build some RDF statements. And what
better subject to use than the recent book 'Adopting Elixir' by Ben
Marx, José Valim, and Bruce Tate.

Following the simple example given for a book resource in the BIBO
ontology we aim to provide a very basic RDF description for this
bibliographic item as recorded in the file `978–1–68050–252–7.ttl`.

```bash
# priv/data/978-1-68050-252-7.ttl
@prefix bibo: <http://purl.org/ontology/bibo/> .
@prefix dc: <http://purl.org/dc/elements/1.1/> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<urn:isbn:978-1-68050-252-7> a bibo:Book ;
    dc:creator <https://twitter.com/bgmarx> ;
    dc:creator <https://twitter.com/josevalim> ;
    dc:creator <https://twitter.com/redrapids> ;
    dc:date "2018-03-14"^^xsd:date ;
    dc:format "Paper" ;
    dc:publisher <https://pragprog.com/> ;
    dc:title "Adopting Elixir"@en .
```

Now how can we generate this RDF description in Elixir?

We're going to show two ways:

1. a rather basic version building on explicit RDF triples, and
2. a more natural Elixir style using piped function calls and
   `RDF.Sigils` for RDF terms.

## Long form with explicit RDF triples

Let's define a subject for our RDF triples.

```bash
iex> s = iri("urn:isbn:978-1-68050-252-7")
#=> ~I<urn:isbn:978-1-68050-252-7>
```

And now let's create those RDF triples.  These are implemented in
`RDF.ex` as regular Elixir tuples, i.e. `{s, p, o}`. Now we've already
defined our subject `s`, we're using the new vocabulary terms for our
predicates `p`, and we use either the functions `iri/1`, or `literal/1`
to generate our objects `o`. There is an exception with the `DC.date`
and `DC.title` objects where we instead use a `literal/2` function to
generate a literal with datatype and language tag, respectively.

```bash
iex> t0 =  {s, RDF.type, iri(BIBO.Book)}
#=> {~I<urn:isbn:978-1-68050-252-7>,
     ~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>,
     ~I<http://purl.org/ontology/bibo/Book>}

iex> t1 = {s, DC.creator, iri("https://twitter.com/bgmarx")}
#=> {~I<urn:isbn:978-1-68050-252-7>,
     ~I<http://purl.org/dc/elements/1.1/creator>,
     ~I<https://twitter.com/bgmarx>}

iex> t2 = {s, DC.creator, iri("https://twitter.com/josevalim")}
#=> {~I<urn:isbn:978-1-68050-252-7>,
     ~I<http://purl.org/dc/elements/1.1/creator>,
     ~I<https://twitter.com/josevalim>}

iex> t3 = {s, DC.creator, iri("https://twitter.com/redrapids")}
#=> {~I<urn:isbn:978-1-68050-252-7>,
     ~I<http://purl.org/dc/elements/1.1/creator>,
     ~I<https://twitter.com/redrapids>}

iex> t4 = {s, DC.date, literal("2018-03-14", datatype: XSD.date)}
#=> {~I<urn:isbn:978-1-68050-252-7>,
     ~I<http://purl.org/dc/elements/1.1/date>,
     %RDF.Literal{value: ~D[2018-03-14],
     datatype: ~I<http://www.w3.org/2001/XMLSchema#date>}}

iex> t5 = {s, DC.format, literal("Paper")}
#=> {~I<urn:isbn:978-1-68050-252-7>,
     ~I<http://purl.org/dc/elements/1.1/format>,
     ~L"Paper"}

iex> t6 = {s, DC.publisher, iri("https://pragprog.com/")}
#=> {~I<urn:isbn:978-1-68050-252-7>,
     ~I<http://purl.org/dc/elements/1.1/publisher>,
     ~I<https://pragprog.com/>}

iex> t7 = {s, DC.title, literal("Adopting Elixir", language: "en")}
#=> {~I<urn:isbn:978-1-68050-252-7>,
     ~I<http://purl.org/dc/elements/1.1/title>,
     ~L"Adopting Elixir"en}
```

And finally we assemble those triples into an RDF description. Here we
just scoop them up and pass them as a list to the `RDF.Description`
constructor.

```bash
iex> RDF.Description.new [t0, t1, t2, t3, t4, t5, t6, t7]

#=> #RDF.Description{subject: ~I<urn:isbn:978-1-68050-252-7>
         ~I<http://purl.org/dc/elements/1.1/creator>
             ~I<https://twitter.com/bgmarx>
             ~I<https://twitter.com/josevalim>
             ~I<https://twitter.com/redrapids>
         ~I<http://purl.org/dc/elements/1.1/date>
             %RDF.Literal{value: ~D[2018-03-14],
                datatype: ~I<http://www.w3.org/2001/XMLSchema#date>}
         ~I<http://purl.org/dc/elements/1.1/format>
             ~L"Paper"
         ~I<http://purl.org/dc/elements/1.1/publisher>
             ~I<https://pragprog.com/>
         ~I<http://purl.org/dc/elements/1.1/title>
             ~L"Adopting Elixir"en
         ~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>
             ~I<http://purl.org/ontology/bibo/Book>}
```

We can wrap this whole construction into a function which we'll call
`book/1` and invoke with the argument `:with_triples` and we'll add that
to the `TestVocab` module.

```elixir
# lib/test_vocab.ex
defmodule TestVocab do
  @moduledoc """
  Test module used in "Early steps in Elixir and RDF"
  """

  # ...

  ## book function defintions

  def book(:with_triples) do

    alias RDF.NS.{XSD}

    s = RDF.iri("urn:isbn:978-1-68050-252-7")

    t0 = {s, RDF.type, RDF.iri(BIBO.Book)}
    t1 = {s, DC.creator, RDF.iri("https://twitter.com/bgmarx")}
    t2 = {s, DC.creator, RDF.iri("https://twitter.com/josevalim")}
    t3 = {s, DC.creator, RDF.iri("https://twitter.com/redrapids")}
    t4 = {s, DC.date, RDF.literal("2018-03-14", datatype: XSD.date)}
    t5 = {s, DC.format, RDF.literal("Paper")}
    t6 = {s, DC.publisher, RDF.iri("https://pragprog.com/")}
    t7 = {s, DC.title, RDF.literal("Adopting Elixir", language: "en")}

    RDF.Description.new [t0, t1, t2, t3, t4, t5, t6, t7]

  end
end
```

Note that for explicitness we'll use the fully qualified names `RDF.iri`
and `RDF.literal`.

## Short form with piped function calls

OK, so let's now show how we might do this in a more natural Elixir
style. Here we make use of two `RDF.ex` features: sigils for RDF terms,
and variant property function calls which implement a description
builder style. And to glue it all together, the Elixir pipe operator
`|>`.

We can show this construction style also using the function `book/1` but
invoked with the argument `:with_pipes` and we'll also that add to the
`TestVocab` module.

```elixir
defmodule TestVocab do
  @moduledoc """
  Test module used in "Early steps in Elixir and RDF"
  """

  # ...

  def book(:with_pipes) do
    import RDF.Sigils

    ~I<urn:isbn:978-1-68050-252-7>
    |> RDF.type(BIBO.Book)
    |> DC.creator(~I<https://twitter.com/bgmarx>,
                  ~I<https://twitter.com/josevalim>,
                  ~I<https://twitter.com/redrapids>)
    |> DC.date(RDF.date("2018-03-14"))
    |> DC.format(~L"Paper")
    |> DC.publisher(~I<https://pragprog.com/>)
    |> DC.title(~L"Adopting Elixir"en)
  end
end
```

So, briefly we can construct new RDF terms using the sigils defined in
the `RDF.Sigils` module (which we import):

* `~I` for IRIs, e.g. `~I<urn:isbn:978–1–68050–252–7>`
* `~L` for literals, e.g. `~L"Paper"` for a plain string, and
  `~L"Adopting Elixir"en` for a language tagged string (with no `@` sign)
* `~B` for blank nodes, e.g. `~B<foo>`

Note that there is no sigil form for datatyped literals and instead we
make use of convenience RDF functions (here `RDF.date/1` for
`"2018–03–14"`).

The property functions we used earlier took no arguments and just
returned the property IRI as an `RDF.IRI` struct. But there are also
property functions with the same name but taking multiple arguments
(between 2 and 6 arguments) for RDF subject and RDF object(s). The
2-argument form expects an RDF subject and a single RDF object and
returns an `RDF.Description` struct.

```bash
iex> import RDF.Sigils
iex> DC.format(~I<urn:isbn:978–1–68050–252–7>, ~L"Paper")
#=> #RDF.Description{subject: ~I<urn:isbn:978–1–68050–252–7>
         ~I<http://purl.org/dc/elements/1.1/format>
             ~L"Paper"}
```

In our function `book(:with_pipes)` there's an example of a 4-argument
function call for `DC.creator`. The first argument is the RDF subject
and subsequent arguments are for RDF objects.

And that leaves that essential piece of plumbing, the Elixir pipe
operator `|>`. This takes an Elixir expression and passes it along
as the first argument to the next function call. Elixir functions
are usually arranged to expect the first argument to be piped in
thus allowing for chains of function calls to be built up.

Now we can call the two constructions directly using the separate
function clauses `book(:with_triples)` and `book(:with_pipes)`.
And to generalize we can add the further function clause `book(arg)`
which just takes a single argument `arg` and raises an error with a help
message. Note, however, that if either of the keywords `:with_triples`
or `:with_pipes` are used the previously defined function clauses will
be invoked instead. To keep things simple we'll also define a function
form `book/0` taking no arguments but silently selecting for one of the
construction functions.

```elixir
defmodule TestVocab do
  @moduledoc """
  Test module used in "Early steps in Elixir and RDF"
  """

  # ...

  def book(arg) do
    raise "! Error: Usage is book( :with_triples | :with_pipes ) with #{arg}"
  end

  def book, do: book(:with_pipes)
end
```

Note that this fragment shows the two forms for defining a function, a
block form and a keyword form.

## Serializing the RDF description

There are various options for reading and writing the [RDF description][4]
as a string or as a file. See the documentation for `RDF.Serialization`.
But the simplest solution for serializing in Turtle format are the
`RDF.Turtle` module functions.

So, we can write the RDF description to stdout as a Turtle string as
follows:

```elixir
bash> make all

iex> RDF.Turtle.write_string!(book) |> IO.puts
iex(1)> RDF.Turtle.write_string!(book) |> IO.puts
#=> <urn:isbn:978-1-68050-252-7>
      a <http://purl.org/ontology/bibo/Book> ;
      <http://purl.org/dc/elements/1.1/creator> <https://twitter.com/bgmarx>,
        <https://twitter.com/josevalim>, <https://twitter.com/redrapids> ;
      <http://purl.org/dc/elements/1.1/date>"2018-03-14"^^<http://www.w3.org/2001/XMLSchema#date> ;
      <http://purl.org/dc/elements/1.1/format> "Paper" ;
      <http://purl.org/dc/elements/1.1/publisher> <https://pragprog.com/>;
      <http://purl.org/dc/elements/1.1/title> "Adopting Elixir"@en .
    :ok
```

I've shown here a simple use case demonstrating how the `RDF.ex` package
can be used for working with the RDF data model in Elixir.

Specifically we've used `RDF.ex` to define a set of RDF vocabularies for
two schemas (`DC` and `BIBO`). We've also used these vocabularies to
build a simple RDF description for a book resource and shown how to
serialize this.

But it was more by way of providing the briefest of introductions into
how Elixir can be used for RDF processing. The real interest, however,
in using Elixir for semantic web applications, beyond any functional
programming best practice, is ultimately two fold: 1) fault tolerant
processing, especially where networks and federated queries are
involved, and 2) better management of distributed compute solutions.

### 5 November 2018 by Oleg G.Kapranov

[1]: https://www.w3.org/TR/rdf11-primer/
[2]: https://github.com/marcelotto/rdf-ex
[3]: https://hexdocs.pm/rdf/RDF.Serialization.html
[4]: https://medium.com/@tonyhammond/early-steps-in-elixir-and-rdf-5078a4ebfe0f
[5]: https://github.com/tonyhammond/examples/tree/master/test_vocab
