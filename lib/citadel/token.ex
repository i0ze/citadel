defmodule Citadel.Token do
  @doc """
  Генерирует URL-безопасный случайный токен.

  По умолчанию генерирует токен на основе 32 случайных байт,
  что дает строку длиной 43 символа. Этого более чем достаточно,
  чтобы избежать коллизий и подбора.

  ## Examples

      iex> Citadel.Token.generate()
      "xY8zN3p7qR1wV6bL9kH0gF2sT5uJ8mC4oP1dE3fA"

      iex> Citadel.Token.generate(16)
      "aB1cD2eF3gH4iJ5k"

  """
  def generate(byte_length \\ 32) do
    byte_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end
end
