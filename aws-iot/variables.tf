variable "thing_name" {
  description = "IoT Thing Name"
}

variable "lambda_function_name" {
  description ="Lambda Function Name"
}

variable "lambda_handler" {
  description = "py filename . function name Example: If filename is lambda_function.py and handler function is lambda_function, handler would be lambda_function.lambda_handler"
  default = "lambda_function.lambda_handler"
}



