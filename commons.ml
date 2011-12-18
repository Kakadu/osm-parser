let (|>) x f = f x
let (>>) f g x = g (f x)
let flip f x y = f y x
external identity : 'a -> 'a = "%identity"
