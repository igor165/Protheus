#ifdef SPANISH
	#define STR0001 "Benef�cios Adicionais"
	#define STR0002 "Pesquisar"
	#define STR0003 "Visualizar"
	#define STR0004 "Manuten��o"
	#define STR0005 "Excluir"
	#define STR0006 "Cadastro Benef�cios Adicionais"
	#define STR0007 "Funcion�rios"
#else
	#ifdef ENGLISH
		#define STR0001 "Benef�cios Adicionais"
		#define STR0002 "Pesquisar"
		#define STR0003 "Visualizar"
		#define STR0004 "Manuten��o"
		#define STR0005 "Excluir"
		#define STR0006 "Cadastro Benef�cios Adicionais"
		#define STR0007 "Funcion�rios"
	#else
		Static STR0001 := "Benef�cios Adicionais"
		Static STR0002 := "Pesquisar"
		Static STR0003 := "Visualizar"
		Static STR0004 := "Manuten��o"
		Static STR0005 := "Excluir"
		Static STR0006 := "Cadastro Benef�cios Adicionais"
		Static STR0007 := "Funcion�rios"
	#endif
#endif

#ifndef SPANISH
#ifndef ENGLISH
	STATIC uInit := __InitFun()

	Static Function __InitFun()
	uInit := Nil
	If Type('cPaisLoc') == 'C'

		If cPaisLoc == "ANG"
			STR0001 := "Benef�cios Adicionais"
			STR0002 := "Pesquisar"
			STR0003 := "Visualizar"
			STR0004 := "Manuten��o"
			STR0005 := "Excluir"
			STR0006 := "Cadastro Benef�cios Adicionais"
			STR0007 := "Funcion�rios"
		ElseIf cPaisLoc == "PTG"
			STR0001 := "Benef�cios Adicionais"
			STR0002 := "Pesquisar"
			STR0003 := "Visualizar"
			STR0004 := "Manuten��o"
			STR0005 := "Excluir"
			STR0006 := "Cadastro Benef�cios Adicionais"
			STR0007 := "Funcion�rios"
		EndIf
		EndIf
	Return Nil
#ENDIF
#ENDIF
