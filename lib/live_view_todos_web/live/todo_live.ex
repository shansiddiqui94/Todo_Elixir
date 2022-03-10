defmodule LiveViewTodosWeb.TodoLive do
    use LiveViewTodosWeb, :live_view
    alias LiveViewTodos.Todos

    def mount(_params, _session, socket) do
        Todos.subscribe()
        {:ok, assign(socket, todos: Todos.list_todos())}
    end
    
    def handle_event("add", %{"todo"=> todo}, socket)do
        Todos.create_todo(todo)
        {:noreply, socket}
    end

    def handle_event("toggle_done", %{"id" => id}, socket) do 
        todo = Todos.get_todo!(id)
        Todos.update_todo(todo, %{done: !todo.done})
        {:noreply, socket}
    end

    def handle_event("delete", %{"id" => id}, socket)do
        todo = Todos.get_todo!(id)
    
        case Todos.delete_todo(todo, %{delete: todo.id}) do
         {:ok, _todo} -> 
            socket = update(socket, :todos, fn todos -> Enum.reject(todos, fn t -> t.id == todo.id end) end)
              {:noreply, socket}
          
            {:error, _} ->
              {:noreply, socket}
        end
    end

    def handle_info({Todos, [:todo | _], _}, socket) do
        {:noreply, fetch(socket)}
      end


    defp fetch(socket) do
        assign(socket, todos: Todos.list_todos())
    end
end