type param_t = Id  | Lon of string | Lat of string | OtherParam 

module type Callbacks = sig	
	val node : param_t list -> unit
end