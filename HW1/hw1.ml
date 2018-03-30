
let rec subset a b = match a with
	| [] -> true
	| h::t -> 
		if List.mem h b 
			then subset t b 
		else false;;

let equal_sets a b = 
	subset a b && subset b a;;

let rec set_union a b = match a with
	| [] -> b
	| h::t -> 
		if List.mem h b 
			then set_union t b 
		else (set_union t b) @ [h];;

let rec set_intersection a b = match a with
	| [] -> []
	| h::t -> 
		if List.mem h b 
			then (set_intersection t b) @ [h] 
		else set_intersection t b;;

let set_diff a b = 	
	List.filter (fun x -> not(List.mem x b)) a;;

let rec computed_fixed_point eq f x  = 
	if eq (f x) x 
		then x 
	else computed_fixed_point eq f (f x);;

let rec loop f p x = match p with
	| 1 -> (f x)
	| _ -> (f (loop f (p-1) x));;

let rec computed_periodic_point eq f p x = match p with
	| 0 -> x
	| 1 -> computed_fixed_point eq f x
	| _ -> 
		if (eq (loop f p x) x)
			then x
		else (computed_periodic_point eq f p (f x));;

let rec while_away s p x =
	if not (p x)
		then []
	else x::while_away s p (s x);;

let rec add_char l p = match l with
	| 0 -> []
	| _ -> p::(add_char (l-1) p);;

let rec rle_decode lp = match lp with
	| [] -> []
	| (l,p)::t -> (add_char l p)  @ rle_decode t;;

(*REAL WORK*)

type ('nonterminal, 'terminal) symbol =
| N of 'nonterminal
| T of 'terminal

(*check if terminal*)
let terminal symbol terminal_list = match symbol with
	| T _ -> true
	| N s -> List.mem s terminal_list;;

(*make sure the pairs are valid*)
let rec valid rule rule_list = match rule with
	| [] -> true
	| h::t -> 
		if (terminal h rule_list) 
			then (valid t rule_list)
		else false;;

(*finds the rules that we want to keep, then*)
let rec grammar_wrapper (terminal_list, original) =
	let rec grammar original terminal_list = match original with
		| [] -> terminal_list
		| (sym, expr)::t -> 
			if (valid expr terminal_list) && not (List.mem sym terminal_list) 
				then (grammar t (sym::terminal_list))
			else (grammar t terminal_list) in
	(grammar original terminal_list ), original;;

let rec filter new_grammar original = match original with
	| [] -> []
	| h::t -> 	
		if (valid (snd h) new_grammar) 
			then h::(filter new_grammar t)
		else (filter new_grammar t);;

let filter_blind_alleys g = match g with
	(start, rules) ->(start, (filter (fst (computed_fixed_point (fun (a, _) (b, _) -> equal_sets a b) grammar_wrapper ([], rules))) rules));;

(*External Sources: https://caml.inria.fr/pub/docs/oreilly-book/html/book-ora016.html*)
