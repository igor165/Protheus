#ifdef SPANISH
	#define STR0001 "Archivo de Restricciones de Visitas y Entregas"
	#define STR0002 "bUscar"
	#define STR0003 "Visualizar"
	#define STR0004 "Incluir"
	#define STR0005 "Modificar"
	#define STR0006 "Borrar"
	#define STR0007 "El contacto no debe completarse en esta situación."
	#define STR0008 "Complete el contacto solamente si el alcance fuera diferente de 'Entrega'"
#else
	#ifdef ENGLISH
		#define STR0001 "Deliveries and Visits Restrictions Register"
		#define STR0002 "Search"
		#define STR0003 "View"
		#define STR0004 "Insert"
		#define STR0005 "Edit"
		#define STR0006 "Delete"
		#define STR0007 "The contact cannot be completed in this status."
		#define STR0008 "Enter contact only if cover is different than 'Delivery'"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Registo De Restrições De Visitas E Entregas", "Cadastro de Restricoes de Visitas e Entregas" )
		#define STR0002 "Pesquisar"
		#define STR0003 "Visualizar"
		#define STR0004 "Incluir"
		#define STR0005 "Alterar"
		#define STR0006 "Excluir"
		#define STR0007 "O contato não deve ser preenchido nesta situação."
		#define STR0008 "Preencha o contato somente se a abrangência for diferente de 'Entrega'"
	#endif
#endif
