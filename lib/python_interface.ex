defmodule SnakeOil.PythonInterface do
  use GenServer
  require Logger

  @moduledoc """
  GenServer for interfacing with Python code.
  """

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    python_directory = Keyword.get(opts, :python_directory, __DIR__ <> "/../src/python") |> to_charlist()
    python_executable = Keyword.get(opts, :python_executable, "python3")

    Logger.info("Starting Python interface with python_directory: #{python_directory} and python_executable: #{python_executable}")

    :python.start([{:python_path, python_directory}, {:python, python_executable}])
  end

  def call_function(module, function, args \\ []) do
    GenServer.call(__MODULE__, {:call_function, module, function, args})
  end

  def call_with_timeout(module, function_name, timeout, args \\ []) do
    GenServer.call(__MODULE__, {:call_function, module, function_name, args}, timeout)
  end

  def handle_call({:call_function, module, function, args}, _from, pid) do
    py_result = :python.call(pid, module, function, args)
    {:reply, py_result, pid}
  end

  def handle_info({:timeout, _ref, _function_name, _args}, pid) do
    :python.stop(pid)
    {:stop, :timeout, pid}
  end

  def terminate(_, pid) do
    :python.stop(pid)
  end
end
