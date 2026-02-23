extends Reference
class_name SceneReader

static func read(path: String) -> Array:
	var file := File.new()
	if file.open(path, File.READ) != OK:
		return ["文件读取错误[%s]：%d" % [path, file.get_error()]]
	
	var result: JSONParseResult = JSON.parse(file.get_as_text())
	if result.error != OK:
		file.close()
		return ["文件解析错误[%s: %d]：%s" % [path, result.error_line, result.error_string]]
	
	var d = result.result
	if not d is Dictionary:
		file.close()
		return ["意外的JSON类型，期望为Dictionary。"]
	var data := d as Dictionary
	var variables: Dictionary = {}
	var scene: Array = []
	if data.has("variables"):
		if not data["variables"] is Dictionary:
			file.close()
			return ["意外的variables类型，期望为Dictionary。"]
		variables = data["variables"]
	if data.has("scene"):
		if not data["scene"] is Array:
			file.close()
			return ["意外的scene类型，期望为Array。"]
		scene = data["scene"]
	file.close()
	variables = parse_variables(variables)
	return ["", scene, variables]

static func parse_variables(variables: Dictionary) -> Dictionary:
	var res := {}
	
	var graph := {}
	var indegree := {}
	for variable in variables:
		if not indegree.has(variable):
			indegree[variable] = 0
		if not variables[variable] is String:
			continue
		var to := tokenize(variables[variable])
		indegree[variable] += to.size()
		for node in to:
			if not graph.has(node):
				graph[node] = []
			graph[node].push_back(variable)
	# topo sort
	var queue := []
	var visited := 0
	for node in indegree:
		if indegree[node] == 0:
			if variables[node] is String:
				eval_variable(node, variables[node], res)
			queue.push_back(node)
	while !queue.empty():
		var u: String = queue.front()
		queue.pop_front()
		visited += 1
		if not variables[u] is String:
			continue
		if not graph.has(u):
			continue
		for v in graph[u]:
			indegree[v] -= 1
			if indegree[v] == 0:
				eval_variable(v, variables[v], res)
				queue.push_back(v)
	if visited != variables.size():
		printerr("Bad variable relation, loop existed.")
		return {}
	return res

static func eval_variable(name: String, pattern: String, variables: Dictionary) -> void:
	var expr := Expression.new()
	expr.parse(pattern, variables.keys())
	variables[name] = expr.execute(variables.values())

static func tokenize(expr: String) -> Array:
	var begin := -1
	var res := []
	for i in range(expr.length() + 1):
		if begin == -1:
			if (i < expr.length() and expr[i].is_valid_identifier() and
				not (expr[i] >= '0' and expr[i] <= '9')):
				begin = i
		elif i == expr.length() or not expr[i].is_valid_identifier():
			res.push_back(expr.substr(begin, i - begin))
			begin = -1
	return filter(res, [
		"PI",
		"TAU",
		"asin",
		"sin",
		"sinh",
		"acos",
		"cos",
		"cosh",
		"atan",
		"atan2",
		"tan",
		"tanh",
		"pow",
		"log",
		"randi",
		"randf",
		"exp",
		"floor",
		"ceil",
		"abs",
	])

static func filter(arr: Array, filter: Array) -> Array:
	var res := []
	for item in arr:
		if not item in filter:
			res.append(item)
	return res

static func var2json(value):
	return JSON.print(var_convert(value), "\t")

static func var_convert(value):
	if value is String:
		var v = str2var(value)
		if v is Dictionary:
			return v
		return value
	elif value is Array:
		for i in value.size():
			value[i] = var_convert(value[i])
		return value
	elif value is Dictionary:
		for key in value:
			value[key] = var_convert(value[key])
		return value
	elif value is Object:
		return null
	else:
		return var2str(value)
