defmodule PhoenixApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias PhoenixApi.Repo

  alias PhoenixApi.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(params) when is_map(params) do
    import Ecto.Query, warn: false
    alias PhoenixApi.Repo
    alias PhoenixApi.Accounts.User

    params = normalize_params(params)

    User
    |> apply_filters(params)
    |> apply_sort(params)
    |> Repo.all()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  defp normalize_params(params) do
    %{
      "first_name" => blank_to_nil(params["first_name"]),
      "last_name" => blank_to_nil(params["last_name"]),
      "gender" => blank_to_nil(params["gender"]),
      "birthdate_from" => parse_date(params["birthdate_from"]),
      "birthdate_to" => parse_date(params["birthdate_to"]),
      "sort_by" => params["sort_by"] || "id",
      "sort_dir" => params["sort_dir"] || "asc"
    }
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(v), do: v

  defp parse_date(nil), do: nil
  defp parse_date(""), do: nil
  defp parse_date(v) do
    case Date.from_iso8601(v) do
      {:ok, d} -> d
      _ -> nil
    end
  end

  defp apply_filters(query, params) do
    import Ecto.Query, warn: false

    query
    |> maybe_where_ilike(:first_name, params["first_name"])
    |> maybe_where_ilike(:last_name, params["last_name"])
    |> maybe_where_eq(:gender, params["gender"])
    |> maybe_where_date_gte(:birthdate, params["birthdate_from"])
    |> maybe_where_date_lte(:birthdate, params["birthdate_to"])
  end

  defp maybe_where_ilike(query, _field, nil), do: query
  defp maybe_where_ilike(query, field, value) do
    where(query, [u], ilike(field(u, ^field), ^"%#{value}%"))
  end

  defp maybe_where_eq(query, _field, nil), do: query
  defp maybe_where_eq(query, field, value) do
    where(query, [u], field(u, ^field) == ^value)
  end

  defp maybe_where_date_gte(query, _field, nil), do: query
  defp maybe_where_date_gte(query, field, date) do
    where(query, [u], field(u, ^field) >= ^date)
  end

  defp maybe_where_date_lte(query, _field, nil), do: query
  defp maybe_where_date_lte(query, field, date) do
    where(query, [u], field(u, ^field) <= ^date)
  end

  @allowed_sort_fields ~w(id first_name last_name birthdate gender inserted_at updated_at)a
  defp apply_sort(query, %{"sort_by" => sort_by, "sort_dir" => sort_dir}) do
    import Ecto.Query, warn: false

    field_atom =
      case sort_by do
        s when is_binary(s) ->
          try do
            String.to_existing_atom(s)
          rescue
            _ -> :id
          end

        _ -> :id
      end

    field_atom = if field_atom in @allowed_sort_fields, do: field_atom, else: :id
    dir = if sort_dir == "desc", do: :desc, else: :asc

    order_by(query, [u], [{^dir, field(u, ^field_atom)}])
  end

end
