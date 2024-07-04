#ifdef SPANISH
	#define STR0001 "Uno o más campos obligatorios no se completaron."
	#define STR0002 "Verifique los valores de los campos [VAR01], [VAR02], [VAR03], [VAR04] y [VAR05]. Por lo menos uno de estos debe haberse completado para que la línea se considere válida."
	#define STR0003 "Es necesario informar un valor para el campo [VAR01] o para el conjunto de campos [VAR02] y [VAR03]."
#else
	#ifdef ENGLISH
		#define STR0001 "One or more fields required are not filled out."
		#define STR0002 "Check the values of the fields [VAR01], [VAR02], [VAR03], [VAR04] e [VAR05]. At least, one of them must be completed so row is considered valid."
		#define STR0003 "Enter value for field [VAR01] or group of fields [VAR02] and [VAR03]."
	#else
		#define STR0001 "Um ou mais campos obrigatórios não foram preenchidos."
		#define STR0002 "Verifique os valores dos campos [VAR01], [VAR02], [VAR03], [VAR04] e [VAR05]. Ao menos um deles deve estar preenchido para que a linha seja considerada válida."
		#define STR0003 "É necessário informar um valor para o campo [VAR01] ou para o conjunto de campos [VAR02] e [VAR03]."
	#endif
#endif
