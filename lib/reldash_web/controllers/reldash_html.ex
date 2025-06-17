defmodule ReldashWeb.ReldashHTML do
  @moduledoc """
  This module contains pages rendered by ReldashController.

  See the `reldash_html` directory for all templates available.
  """
  use ReldashWeb, :html

  embed_templates "reldash_html/*"
end
