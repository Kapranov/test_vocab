defmodule TestVocab do
  @moduledoc """
  Test module used in "Early steps in Elixir and RDF"
  """

  use RDF.Vocabulary.Namespace

  defvocab DC,
    base_iri: "http://purl.org/dc/elements/1.1/",
    file: "dc.ttl"
end
