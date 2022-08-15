// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TodoList {
    struct Todo {
        string text;
        bool completed;
    }

    Todo[] public todos;

    function create(string calldata _text) external {
        todos.push(Todo(_text, false));
    }

    function updateText(uint256 _index, string calldata _text) external {
        todos[_index].text = _text;
    }

    function toggleCompleted(uint256 _index) external {
        todos[_index].completed = !todos[_index].completed;
    }

    function get(uint256 _index) external view returns (string memory, bool) {
        return (todos[_index].text, todos[_index].completed);
    }
}
