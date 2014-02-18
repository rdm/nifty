require 'regex'
cocurrent 'nifexpr'

NB. translate a python expression to a J expression
NB. this is necessarily a heuristic with limited power
NB. 

verpat=: rxcomp '\d+\.\d+\.\d+\.\d+'
fixexpr=:3 :0
  expr=. ('<=';'<:';'>=';'>:';'==';'=';'||';'+.';'&&';'*.';'!';'-.';'&';' bAnd ';'|';' bOr ') stringreplace (;y) -.' '
  ('(',')',~])^:(0<#) verpat ('(vton ''',''')',~]) rxapply expr
)

NB. inherit or duplicate these:
bAnd=: 17 b.
bOr=:  23 b.

