%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%kenken shared functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
length_flipped(Integer, List) :- length(List, Integer).

% SWI-Prolog's transpose
transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).

element([I|J], T, Value) :- nth(I, T, Row), nth(J, Row, Value).      

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% kenken/3
% N, nonnegative int, num_cells
% C, list of constraints 
% T, list of list of int (rep sol_grid)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
kenken(N, C, T) :-
    valid_matrix(N, T),
    validate_constraints(C,T),
    maplist(fd_labeling, T).

valid_matrix(N, T) :- 
    %checks row & col lengths
    length(T, N),
    maplist(length_flipped(N), T),
    %check domain for all rows
    maplist(domain(N), T),
    maplist(fd_all_different, T),
    %check domain for all cols
    transpose(T, TT),
    maplist(domain(N), TT),
    maplist(fd_all_different, TT).

%Validator "helpers"
domain(N, Vars) :- 
    fd_domain(Vars, 1, N).
validate_constraints([], _).
validate_constraints([Head|Tail], T) :- 
    constraint(Head, T), validate_constraints(Tail, T).

% Constraint definitions
constraint(+(S, L),T) :- add(S, L, T, 0).
constraint(*(P, L),T) :- mult(P, L, T, 1).
constraint(-(D, J, K),T) :- sub(D, J, K, T).
constraint(/(Q, J, K),T) :- div(Q, J, K, T).

add(Sum, [], _, Sum).
add(Sum, [Head|Tail], T, Temp) :- 
    element(Head, T, Value), 
    Curr #= Temp + Value, 
    add(Sum, Tail, T, Curr). 

mult(Prod, [], _, Prod).
mult(Prod, [Head|Tail], T, Temp) :-
    element(Head, T, Value),
    Curr #= Temp * Value,
    mult(Prod, Tail, T, Curr).

sub(Diff, J, K, T) :-
    element(J, T, Value1),
    element(K, T, Value2),
    (Diff #= Value1-Value2; Diff #=Value2-Value1).

div(Quot, J, K, T) :-
    element(J, T, Value1),
    element(K, T, Value2),
    (Quot #= Value1/Value2; Quot #=Value2/Value1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plain_kenken/3
%see above
%no fd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plain_kenken(N, C, T) :-
  p_valid_matrix(N, T),
  p_validate_constraints(C,T).

p_valid_matrix(N, T) :- 
  length(T, N), 
  maplist(length_flipped(N), T),
  check_domain(N,T),
  maplist(different, T),
  transpose(T, TT),
  check_domain(N,TT),
  maplist(different, TT).

check_domain(N,T) :-
  findall(Num, between(1, N, Num), L),
  maplist(permutation(L), T).

different(X) :-
    sort(X, Sorted),
    length(X, OriginalLength),
    length(Sorted, SortedLength),
    OriginalLength == SortedLength.

% Constraints (Plain)
p_validate_constraints([], _).
p_validate_constraints([Head|Tail], T) :- 
    p_constraint(Head, T), p_validate_constraints(Tail, T).

% Constraints
p_constraint(+(S, L),T) :- p_add(S, L, T, 0).
p_constraint(-(D, J, K),T) :- p_sub(D, J, K, T).
p_constraint(/(Q, J, K),T) :- p_div(Q, J, K, T).
p_constraint(*(P, L),T) :- p_mult(P, L, T, 1).

p_add(Sum, [], _, Sum).
p_add(Sum, [Head|Tail], T, Temp) :- 
    element(Head, T, Value), 
    Curr is Temp + Value, 
    p_add(Sum, Tail, T, Curr). 

p_mult(Prod, [], _, Prod).
p_mult(Prod, [Head|Tail], T, Temp) :-
    element(Head, T, Value),
    Curr is Temp * Value,
    p_mult(Prod, Tail, T, Curr).

p_sub(Diff, J, K, T) :-
    element(J, T, Value1),
    element(K, T, Value2),
    (Diff is Value1-Value2; Diff is Value2-Value1).

p_div(Quot, J, K, T) :-
    element(J, T, Value1),
    element(K, T, Value2),
    (Quot is Value1/Value2; Quot is Value2/Value1).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Testcases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
kenken4(
  4,
  [
   +(6, [[1|1], [1|2], [2|1]]),
   *(96, [[1|3], [1|4], [2|2], [2|3], [2|4]]),
   -(1, [3|1], [3|2]),
   -(1, [4|1], [4|2]),
   +(8, [[3|3], [4|3], [4|4]]),
   *(2, [[3|4]])
  ]
 ).

kenken_testcase(
  6,
  [
   +(11, [[1|1], [2|1]]),
   /(2, [1|2], [1|3]),
   *(20, [[1|4], [2|4]]),
   *(6, [[1|5], [1|6], [2|6], [3|6]]),
   -(3, [2|2], [2|3]),
   /(3, [2|5], [3|5]),
   *(240, [[3|1], [3|2], [4|1], [4|2]]),
   *(6, [[3|3], [3|4]]),
   *(6, [[4|3], [5|3]]),
   +(7, [[4|4], [5|4], [5|5]]),
   *(30, [[4|5], [4|6]]),
   *(6, [[5|1], [5|2]]),
   +(9, [[5|6], [6|6]]),
   +(8, [[6|1], [6|2], [6|3]]),
   /(2, [6|4], [6|5])
  ]
).

