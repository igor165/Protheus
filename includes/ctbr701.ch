#ifdef SPANISH
	#define STR0001 "ESTADO DE CAMBIOS EN EL PATRIMONIO NETO"
	#define STR0002 "Este programa imprimirá el Estado de Cambios en el Patrimonio Neto"
	#define STR0003 "Se imprimirá de acuerdo con los Parámetros solicitados por el usuario."
	#define STR0004 "No hay datos por mostrarse"
	#define STR0005 "Ejecutando consulta"
	#define STR0006 "Seleccionando asientos..."
	#define STR0007 "Cuenta"
	#define STR0008 "Total"
	#define STR0009 "AL"
	#define STR0010 "Expresado en"
	#define STR0011 "GERENTE"
	#define STR0012 "CONTADOR"
	#define STR0013 "Plan de Gestión no asociado al libro. ¡Verifique la configuración elegida del libro! "
	#define STR0014 "Plan de Gestión  no registrado correctamente. Verifique "
	#define STR0015 "Enero"
	#define STR0016 "Febrero"
	#define STR0017 "Marzo"
	#define STR0018 "Abril"
	#define STR0019 "Mayo"
	#define STR0020 "Junio"
	#define STR0021 "Julio"
	#define STR0022 "Agosto"
	#define STR0023 "Septiembre"
	#define STR0024 "Octubre"
	#define STR0025 "Noviembre"
	#define STR0026 "Diciembre"
	#define STR0027 "Saldo al "
	#define STR0028 " de "
	#define STR0029 " del "
#else
	#ifdef ENGLISH
		#define STR0001 "STATEMENT OF CHANGES IN THE NET EQUITY"
		#define STR0002 "This program will print the Statement of Changes in the Net Equity"
		#define STR0003 "It is printed according to the parameters requested by the user."
		#define STR0004 "There are no data to display"
		#define STR0005 "Running query"
		#define STR0006 "Selecting entries..."
		#define STR0007 "Account"
		#define STR0008 "Total"
		#define STR0009 "AL"
		#define STR0010 "Expressed in"
		#define STR0011 "MANAGER"
		#define STR0012 "ACCOUNTANT"
		#define STR0013 "Management Plan not associated to record. Check configuration selected to record! "
		#define STR0014 "Management Plan not correclty registered. Check it "
		#define STR0015 "January"
		#define STR0016 "February"
		#define STR0017 "March"
		#define STR0018 "April"
		#define STR0019 "May"
		#define STR0020 "June"
		#define STR0021 "July"
		#define STR0022 "August"
		#define STR0023 "September"
		#define STR0024 "October"
		#define STR0025 "November"
		#define STR0026 "December"
		#define STR0027 "Balance on"
		#define STR0028 "from"
		#define STR0029 "from"
	#else
		#define STR0001 "DEMONSTRAÇÃO DAS MUTAÇÕES DO PATRIMÔNIO LÍQUIDO"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Este programa imprimira el Estado de Cambios en el Patrimonio Neto", "Este programa imprimirá o Demonstrativo de Alterações no Patrimônio Líquido" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Se imprimira de acuerdo con los Param. solicitados por el usuario.", "Será impresso conforme os Parâmetros solicitados pelo usuário." )
		#define STR0004 "Não existem dados a exibir"
		#define STR0005 "Executando consulta"
		#define STR0006 "Selecionando lançamentos..."
		#define STR0007 "Conta"
		#define STR0008 "Total"
		#define STR0009 "AL"
		#define STR0010 "Expresso em"
		#define STR0011 "GERENTE"
		#define STR0012 "CONTADOR"
		#define STR0013 "Plano Gerencial não associado ao livro. Verifique a configuracion selecionada para o livro! "
		#define STR0014 "Plano Gerencial não registrado corretamente. Verifique "
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Enero", "Janeiro" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Febrero", "Fevereiro" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Marzo", "Março" )
		#define STR0018 "Abril"
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Mayo", "Maio" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Junio", "Junho" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Julio", "Julho" )
		#define STR0022 "Agosto"
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Septiembre", "Setembro" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Octubre", "Outubro" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Noviembre", "Novembro" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Diciembre", "Dezembro" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Saldo al ", "Saldo em" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", " de ", "de" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", " del ", "de" )
	#endif
#endif
