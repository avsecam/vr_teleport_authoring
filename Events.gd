extends Node


signal teleport_node_selected(node: TeleportNode)
signal teleport_node_drag_started(node: TeleportNode)
signal teleport_node_add_requested(node: TeleportNode)
signal teleport_node_delete_requested(node: TeleportNode)
signal teleport_node_edit_requested(node: TeleportNode)
signal teleport_node_edit_confirm_requested(node: TeleportNode)
signal teleport_node_connection_add_requested(from: TeleportNode, to: TeleportNode)
