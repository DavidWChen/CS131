type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

(*Convert Grammer From HW1 to HW2*)
let rec convert_rules nt rule1 = 
	match rule1 with
		| [] -> []
		| (sym, expr)::t ->
			if sym = nt
				then expr::(convert_rules nt t)
			else convert_rules nt t;;

let convert_grammar gram1 = 
	match gram1 with
		| (start, rules) -> 
			(start, function term -> (convert_rules term rules));;


(*REAL WORK*)
let rec match_path rules rule accept derivation frag = 
	match rule with
        | [] -> (accept derivation frag)
        | (N nterm)::rhs -> 
            let accept_mod = 
                match_path rules rhs accept in
            (matcher nterm rules (rules nterm) (accept_mod) derivation frag)
        | (T term)::rhs-> match frag with
        	| [] -> None
        	| fh::ft ->
                if fh = term 
                	then (match_path rules rhs accept derivation ft) 
                else 
                	None
and matcher start rules start_rules accept derivation frag = 
	match start_rules with
    | [] -> None
    | h::t -> 
    	let check_path = 
        		(match_path rules h accept (derivation @ [start, h]) frag) in 
        if (check_path = None)
			then matcher start rules t accept derivation frag
        else 
        	check_path;;

let parse_prefix gram accept frag = 
	match gram with
		| (start, rules)->
			(matcher start rules (rules start) accept [] frag);;

