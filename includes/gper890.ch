#ifdef SPANISH
	#define STR0001 "Ajuste de Parametros"
	#define STR0002 "Rutina para generacion de archivo magnetico AFP"
	#define STR0003 "El sistema generara el archivo de acuerdo con los parametros informados."
	#define STR0004 "¡El archivo de nombre"
	#define STR0005 " no pudo crearse! Verifique los parametros."
	#define STR0006 "¡Atencion!"
	#define STR0007 "Procesando..."
	#define STR0008 "Ocurrio un error en la grabacion del archivo. ¿Continua?"
	#define STR0009 "Procesando Información..."
	#define STR0010 "Filial - Matricula"
	#define STR0011 "Aportaciones de AFP (Administradoras de Fondos de Pensión)"
	#define STR0012 "AFP"
	#define STR0013 "Fil."
	#define STR0014 "Mat."
	#define STR0015 "Sec."
	#define STR0016 "CUSPP"
	#define STR0017 "Tp.Doc"
	#define STR0018 "Nr.Doc.Ident"
	#define STR0019 "Apel.Paterno"
	#define STR0020 "Apel.Materno"
	#define STR0021 "Nombres"
	#define STR0022 "RL"
	#define STR0023 "RL.Ini"
	#define STR0024 "RL.Fin"
	#define STR0025 "Exc.Apr"
	#define STR0026 "Rem.Aseg"
	#define STR0027 "Apr.Vol"
	#define STR0028 "Apr.Sn.Pr"
	#define STR0029 "Apr.Emp"
	#define STR0030 "Tp.Trab"
	#define STR0031 "No se encontro información con los parametros asignados"
	#define STR0032 "Total de Registros"
#else
	#ifdef ENGLISH
		#define STR0001 "Parameter Adjustment"
		#define STR0002 "Routine for generation of AFP magnetic file"
		#define STR0003 "System generates a file according to the parameters entered."
		#define STR0004 "File name"
		#define STR0005 " cannot be created! Check parameters."
		#define STR0006 "Attention!"
		#define STR0007 "Processing..."
		#define STR0008 "There was an error when saving the file. Continue?"
		#define STR0009 "Processing information..."
		#define STR0010 "Branch - Registration Number"
		#define STR0011 "AFP contributions (Pension Funds Administrators)"
		#define STR0012 "AFP"
		#define STR0013 "Branch"
		#define STR0014 "Reg."
		#define STR0015 "Sec."
		#define STR0016 "CUSPP"
		#define STR0017 "Doc.Tp."
		#define STR0018 "Ident.Doc.No."
		#define STR0019 "Paternal Surname"
		#define STR0020 "Maternal Surname"
		#define STR0021 "Names"
		#define STR0022 "RL"
		#define STR0023 "St.RL"
		#define STR0024 "End.RL"
		#define STR0025 "Exc.Apr"
		#define STR0026 "Rem.Seg"
		#define STR0027 "Vol.Contrib."
		#define STR0028 "Contrib.Sn.Pr"
		#define STR0029 "Comp.Contrib."
		#define STR0030 "Wk.Tp."
		#define STR0031 "No information found with the parameters defined"
		#define STR0032 "Total records"
	#else
		#define STR0001 "Ajuste de Parâmetros"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Rotina para geração de ficheiro magnético AFP", "Rotina para geração de arquivo magnético AFP" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "O sistema irá gerar o ficheiro de acordo com os parâmetros informados.", "O sistema irá gerar o arquivo de acordo com os parâmetros informados." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "O ficheiro de nome", "O arquivo de nome" )
		#define STR0005 " não pode ser criado! Verifique os parâmetros."
		#define STR0006 "Atenção!"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "A processar...", "Processando..." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Ocorreu um erro na gravação do ficheiro. Continua?", "Ocorreu um erro na gravação do arquivo. Continua?" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Procesando Información...", "Processando Informação..." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Filial - Matricula", "Filial - Matrícula" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Aportaciones de AFP (Administradoras de Fondos de Pensión)", "Contribuições de AFP (Administradoras de Fundos de Pensão)" )
		#define STR0012 "AFP"
		#define STR0013 "Fil."
		#define STR0014 "Mat."
		#define STR0015 "Sec."
		#define STR0016 "CUSPP"
		#define STR0017 "Tp.Doc"
		#define STR0018 "Nr.Doc.Ident"
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Apel.Paterno", "Sobren.Paterno" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Apel.Materno", "Sobren.Materno" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Nombres", "Nomes" )
		#define STR0022 "RL"
		#define STR0023 "RL.Ini"
		#define STR0024 "RL.Fin"
		#define STR0025 "Exc.Apr"
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Rem.Aseg", "Rem.Seg" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Apr.Vol", "Contrib.Vol" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Apr.Sn.Pr", "Contrib.Sn.Pr" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Apr.Emp", "Contrib.Emp" )
		#define STR0030 "Tp.Trab"
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "No se encontro información con los parametros asignados", "Não foi encontrada informação com os parâmetros definidos" )
		#define STR0032 "Total de Registros"
	#endif
#endif
