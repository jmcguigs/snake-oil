defmodule SnakeOilTest do
  use ExUnit.Case, async: true
  doctest SnakeOil

  setup do
    {:ok, pid} = SnakeOil.PythonInterface.start_link([python_directory: __DIR__ <> "/python", python_executable: 'python3'])
    {:ok, pid: pid}
  end

  test "test python genserver" do
    assert SnakeOil.PythonInterface.call_function(:test, :add, [3, 4]) == 7
  end
end
