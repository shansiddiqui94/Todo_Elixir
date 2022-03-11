# this file is the View in our this is where the magic happens
defmodule LiveViewTodosWeb.TodoLive do
  use LiveViewTodosWeb, :live_view
  alias LiveViewTodos.Todos

  def mount(_params, _session, socket) do
    Todos.subscribe()
    {:ok, assign(socket, todos: Todos.list_todos())}
  end

  def handle_event("add", %{"todo" => todo}, socket) do
    Todos.create_todo(todo)
    {:noreply, socket}
  end

  def handle_event("toggle_done", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    Todos.update_todo(todo, %{done: !todo.done})
    {:noreply, socket}
  end

  def handle_event("clear", _params, socket) do
    # Todos.remove_all()
    socket = assign(socket, :todos, [])
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)

    case Todos.delete_todo(todo) do
      {:ok, deleted_todo} ->
        socket =
          update(socket, :todos, fn todos ->
            Enum.reject(todos, &(&1.id == deleted_todo.id))
          end)

        {:noreply, put_flash(socket, :info, "Todo '#{deleted_todo.id}' deleted")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "An error occured while deleting a todo")}
    end
  end

  def handle_info({Todos, [:todo | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, todos: Todos.list_todos())
  end
end
