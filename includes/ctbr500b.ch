#ifdef SPANISH
	#define STR0001 "INVENTARIOS Y BALANCES - ESTADO DE RESULTADOS"
	#define STR0002 "Creando archivo temporal..."
	#define STR0003 "Descripcion"
	#define STR0004 "Semestre"
	#define STR0005 "Ejercicio/Periodo"
	#define STR0006 "Los informes contables deben tener obligatoriamente un plan de gestion asociado al libro. íVerifique la configuracion de libros elegida!"
	#define STR0007 "Responsables..."
	#define STR0008 "Detalle"
	#define STR0009 "¿Imprime Termino en la Proxima Pagina?"
	#define STR0010 "Funcion disponible solo para TReport, verificar parametro MV_TREPORT."
	#define STR0011 "Error al crear archivo TXT"
	#define STR0012 "Archivo TXT generado con éxito."
	#define STR0013 "Generando archivo ..."
#else
	#ifdef ENGLISH
		#define STR0001 "INVENTORY AND BALANCES - RESULT STATEMENT"
		#define STR0002 "Creating temporary register..."
		#define STR0003 "Description"
		#define STR0004 "Semester"
		#define STR0005 "Year/Period"
		#define STR0006 "The accounting reports must have a management plan associated to the record. Check the record configuration chosen."
		#define STR0007 "Responsible Parties"
		#define STR0008 "Detail"
		#define STR0009 "Print Term on Next Page?"
		#define STR0010 "Function available only for TReport. Check parameter MV_TREPORT."
		#define STR0011 "Error creating TXT file"
		#define STR0012 "TXT register generated successfully."
		#define STR0013 "Generating register..."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "INVENTARIOS Y BALANCES - ESTADO DE RESULTADOS", "INVENTÁRIOS E BALANÇOS - DEMONSTRAÇÃO DE RESULTADOS" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Creando archivo temporal...", "Criando cadastro temporal..." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Descripcion", "Descrição" )
		#define STR0004 "Semestre"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Ejercicio/Periodo", "Exercício/Período" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Los informes contables deben tener obligatoriamente un plan de gestion asociado al libro. íVerifique la configuracion de libros elegida!", "Os relatório contábeis devem ter obrigatoriamente um plano de gestão associado ao livro. Confira a configuração de livros elegida!" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Responsables...", "Responsáveis..." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Detalle", "Detalhe" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "¿Imprime Termino en la Proxima Pagina?", "Imprime Termo na Próxima Página?" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Funcion disponible solo para TReport, verificar parametro MV_TREPORT.", "Função disponível só para TReport. Verificar parâmetro MV_TREPORT." )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Error al crear archivo TXT", "Erro ao criar cadastro TXT" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Archivo TXT generado con éxito.", "Cadastro TXT gerado com sucesso." )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Generando archivo ...", "Gerando cadastro..." )
	#endif
#endif
