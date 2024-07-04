#ifdef SPANISH
	#define STR0001 "Benefícios Adicionais"
	#define STR0002 "Pesquisar"
	#define STR0003 "Visualizar"
	#define STR0004 "Manutenção"
	#define STR0005 "Excluir"
	#define STR0006 "Cadastro Benefícios Adicionais"
	#define STR0007 "Funcionários"
#else
	#ifdef ENGLISH
		#define STR0001 "Benefícios Adicionais"
		#define STR0002 "Pesquisar"
		#define STR0003 "Visualizar"
		#define STR0004 "Manutenção"
		#define STR0005 "Excluir"
		#define STR0006 "Cadastro Benefícios Adicionais"
		#define STR0007 "Funcionários"
	#else
		Static STR0001 := "Benefícios Adicionais"
		Static STR0002 := "Pesquisar"
		Static STR0003 := "Visualizar"
		Static STR0004 := "Manutenção"
		Static STR0005 := "Excluir"
		Static STR0006 := "Cadastro Benefícios Adicionais"
		Static STR0007 := "Funcionários"
	#endif
#endif

#ifndef SPANISH
#ifndef ENGLISH
	STATIC uInit := __InitFun()

	Static Function __InitFun()
	uInit := Nil
	If Type('cPaisLoc') == 'C'

		If cPaisLoc == "ANG"
			STR0001 := "Benefícios Adicionais"
			STR0002 := "Pesquisar"
			STR0003 := "Visualizar"
			STR0004 := "Manutenção"
			STR0005 := "Excluir"
			STR0006 := "Cadastro Benefícios Adicionais"
			STR0007 := "Funcionários"
		ElseIf cPaisLoc == "PTG"
			STR0001 := "Benefícios Adicionais"
			STR0002 := "Pesquisar"
			STR0003 := "Visualizar"
			STR0004 := "Manutenção"
			STR0005 := "Excluir"
			STR0006 := "Cadastro Benefícios Adicionais"
			STR0007 := "Funcionários"
		EndIf
		EndIf
	Return Nil
#ENDIF
#ENDIF
