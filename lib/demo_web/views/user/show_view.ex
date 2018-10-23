defmodule DemoWeb.User.ShowView do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias DemoWeb.Router.Helpers, as: Routes
  alias Demo.Accounts
  alias Phoenix.LiveView.Socket

  def render(assigns) do
    ~E"""
    <h2>Show User</h2>
    <ul>
      <li><b>Username:</b> <%= @user.username %></li>
      <li><b>Email:</b> <%= @user.email %></li>
      <li><b>Phone:</b> <%= @user.phone_number %></li>
    </ul>
    <span><%= link "Edit", to: Routes.user_path(DemoWeb.Endpoint, DemoWeb.User.EditView, @user) %></span>
    <span><%= link "Back", to: Routes.user_path(DemoWeb.Endpoint, DemoWeb.User.IndexView) %></span>
    """
  end

  def upgrade(_conn, %{"id" => id}) do
    {:ok, %{id: id}}
  end

  def prepare(%{id: id}, socket) do
    {:ok, fetch(assign(socket, id: id))}
  end

  def init(socket) do
    Demo.Accounts.subscribe(socket.assigns.id)
    {:ok, socket}
  end

  defp fetch(%Socket{assigns: %{id: id}} = socket) do
    assign(socket, user: Accounts.get_user!(id))
  end

  def handle_info({Accounts, [:user, :updated], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info({Accounts, [:user, :deleted], _}, socket) do
    socket
    |> put_flash(:error, "This user has been deleted from the system")
    |> redirect(to: Routes.user_path(DemoWeb.Endpoint, DemoWeb.User.IndexView))
  end
end
