extends Marker2D

var customer: Customer
var customer_order: Array


func _ready() -> void:
	# happens when a customer enters the tree
    child_entered_tree.connect(_on_child_entered_tree)


func _on_child_entered_tree(node: Node) -> void:
    if node is Customer:
        customer = node
        # Connect once the customer is present in this slot
        customer.order_ready.connect(get_order_data)


func get_order_data() -> void:
    if customer:
        customer_order = customer.order
