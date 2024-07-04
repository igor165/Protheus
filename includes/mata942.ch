#ifdef SPANISH
	#define STR0001 "Salir"
	#define STR0002 "Confirmar"
	#define STR0003 "Buscar"
	#define STR0004 "Visualizar"
	#define STR0005 "Incluir"
	#define STR0006 "Modificar"
	#define STR0007 "Borrar"
	#define STR0008 "Actualizacion del Registro de Provincias"
	#define STR0009 "¿Con respecto al borrado?"
	#define STR0010 "Atención"
	#define STR0011 "Debe completarse el campo CCO_CODPRO o CCO_DESCPR."
	#define STR0012 "Debe informarse el tipo percepción"
	#define STR0013 "Tipo de percepción debe estar en blanco"
	#define STR0014 "Para Agente de percepción el tipo debe ser I, V o X."
	#define STR0015 "El estado de entrega en el archivo de empresa ( SMO) no esta rellenado. Por favor, ajuste el registro."
	#define STR0016 "Debe informarse un tipo de retención "
	#define STR0017 "Tipo de retención debe quedar en blanco"
	#define STR0018 "1=Siempre;"
	#define STR0019 "2=Dev. Total;"
	#define STR0020 "3=FC/NC Mismo Periodo;"
	#define STR0021 "4= Dev. Total y FC/NC Mismo Per.;"
	#define STR0022 "5=No Calcula;"
	#define STR0023 "6=Importe Máximo;"
	#define STR0024 "7=FC/NC Misma Quincena;"
	#define STR0025 "8=FC/NC Misma Quincena Dev. Total;"
	#define STR0026 "9=FC/NC Dentro 3 meses;"
	#define STR0027 "0=FC/NC Dentro 3 meses Dev. Total;"
	#define STR0028 "A=FC/NC Dentro 2 meses;"
	#define STR0029 "B=FC/NC Dentro 2 meses - Dev total"
#else
	#ifdef ENGLISH
		#define STR0001 "Abort"
		#define STR0002 "Confirm"
		#define STR0003 "Search"
		#define STR0004 "View"
		#define STR0005 "Add"
		#define STR0006 "Change"
		#define STR0007 "Delete"
		#define STR0008 "Update of Municipalities File"
		#define STR0009 "As to exclusion?"
		#define STR0010 "Attention"
		#define STR0011 "Field CCO_CODPRO o CCO_DESCPR must be filled in."
		#define STR0012 "Enter type of perception "
		#define STR0013 "Type of Perception must be blank"
		#define STR0014 "For Perception Agent, type must be I, V or X."
		#define STR0015 "Delivery status in company file (SMO) was not filled out. Please adjust register."
		#define STR0016 "You must inform a withholding type. "
		#define STR0017 "Withholding type must be blank."
		#define STR0018 "1=Always"
		#define STR0019 "2=Total Return"
		#define STR0020 "3=FC/NC Same period"
		#define STR0021 "4=Total Return and FC/NC Same Per."
		#define STR0022 "5=Do not calculate"
		#define STR0023 "6=Maximum value"
		#define STR0024 "7=FC/NC Mesma quinzena"
		#define STR0025 "8=FC/NC Same fifteen days Total Return"
		#define STR0026 "9=FC/NC Within 3 months"
		#define STR0027 "0=FC/NC Within 3 months Total Ret."
		#define STR0028 "A=FC/NC Within 2 months"
		#define STR0029 "B=FC/NC Within 2 months - Total Ret."
	#else
		#define STR0001 "Abandonar"
		#define STR0002 "Confirmar"
		#define STR0003 "Pesquisar"
		#define STR0004 "Visualizar"
		#define STR0005 "Incluir"
		#define STR0006 "Alterar"
		#define STR0007 "Excluir"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Actualização do Registo de Províncias", "Atualizacao do Cadastro de Provincias" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Quanto à exclusão?", "Quanto a exclusao?" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Atenção", "Atencao" )
		#define STR0011 "O campoCCO_CODPRO o CCO_DESCPR deve ser preenchido"
		#define STR0012 "Deve-se  informar o  tipo percepção "
		#define STR0013 "Tipo de Percepção deve ficar em branco"
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Para Agente de percepción el tipo debe ser I, V o X.", "Para Agente de Percepção o tipo deve ser I, V ou X." )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "O estado de entrega no ficheiro de empresa ( SMO) não foi preenchido, por favor ajuste o registo.", "O estado de entrega no arquivo de empresa ( SMO) não foi preenchido, por favor ajuste o cadastro." )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Deve-se informar um tipo de retenção. ", "Deve-se informar um tipo de retenção " )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Tipo de retenção deve ficar em branco", "Tipo de Retenção deve ficar em branco" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "1=Siempre;", "1=Sempre" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "2=Dev. Total;", "2=Dev. Total" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "3=FC/NC Mismo Periodo;", "3=FC/NC Mesmo período" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "4= Dev. Total y FC/NC Mismo Per.;", "4= Dev. Total y FC/NC Mesmo Per." )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "5=No Calcula;", "5=Não calcula" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "6=Importe Máximo;", "6=Valor máximo" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "7=FC/NC Misma Quincena;", "7=FC/NC Mesma quinzena" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "8=FC/NC Misma Quincena Dev. Total;", "8=FC/NC Mesma quinzena Dev. Total" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "9=FC/NC Dentro 3 meses;", "9=FC/NC Dentro de 3 meses" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "0=FC/NC Dentro 3 meses Dev. Total;", "0=FC/NC Dentro de 3 meses Dev. Total" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "A=FC/NC Dentro 2 meses;", "A=FC/NC Dentro de 2 meses" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "B=FC/NC Dentro 2 meses - Dev total", "B=FC/NC Dentro de 2 meses - Dev total" )
	#endif
#endif
