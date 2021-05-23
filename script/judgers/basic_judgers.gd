extends Node

const region_judgers = [
	'judge_region_squares'
]

func judge_all(validator: Validation.Validator):
	var ok = true
	for region in validator.regions:
		ok = ok and judge_region(validator, region, true)
	return ok
	
	
func judge_region(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	var ok = true
	for region_judger in region_judgers:
		ok = ok and call(region_judger, validator, region, require_errors)
		if (!ok and !require_errors):
			return false
	return ok
	
func judge_region_squares(validator: Validation.Validator, region: Validation.Region, require_errors: bool):
	if (!('square' in region.decorator_dict)):
		return true
	var color = null
	var ok = true
	for decorator_id in region.decorator_dict['square']:
		var response = validator.decorator_responses[decorator_id]
		if (response.decorator.color != color):
			if (color == null):
				color = response.decorator.color
			else:
				ok = false
	if (require_errors and !ok):
		for decorator_id in region.decorator_dict['square']:
			var response = validator.decorator_responses[decorator_id]
			response.state = Validation.DecoratorResponse.ERROR
	return ok

	
