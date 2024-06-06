extends Node

# Teleport Author
signal teleport_node_selected(node: TeleportNode)
signal teleport_node_drag_started(node: TeleportNode)
signal teleport_node_add_requested(node: TeleportNode, internal_name: String)
signal teleport_node_delete_requested(node: TeleportNode)
signal teleport_node_edit_requested(node: TeleportNode)
signal teleport_node_edit_confirm_requested(node: TeleportNode)
signal teleport_node_connection_add_requested(to: TeleportNode)

signal teleport_node_enter_requested(node: TeleportNode)
signal teleport_node_exit_requested(node: TeleportNode)
signal teleporter_add_requested(node: TeleportNode, teleporter: Teleporter)

signal connection_entry_select_requested(entry: ConnectionEntry)
signal connection_entry_delete_requested(entry: ConnectionEntry)

# Event Author

# Demo
signal demo_requested(start_node: TeleportNode)
signal demo_exit_requested()

# Common
signal switch_requested()

signal export_requested()
signal save_requested()
signal save_finished()
signal load_requested(file_path: String)
