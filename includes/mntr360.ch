#ifdef SPANISH
	#define STR0001 "MTBF y MTTR"
	#define STR0002 "El usuario puede seleccionar los campos que deberan exhibirse,"
	#define STR0003 "asi como informar los parametros de seleccion para la impresion."
	#define STR0004 "A Rayas"
	#define STR0005 "Administracion"
	#define STR0006 "Centro de costo Descripción C.Trabajo Descripción"
	#define STR0007 "Familia Descripción Bien Descripción MTBF MTTR"
	#define STR0008 "Procesando Archivo..."
	#define STR0009 "Normal"
	#define STR0012 "C. Costo"
	#define STR0013 "Descripc."
	#define STR0014 "C. Trabajo"
	#define STR0015 "Familia"
	#define STR0016 "Bien"
	#define STR0018 "MTBF"
	#define STR0019 "MTTR"
	#define STR0020 "Familias"
	#define STR0022 "Bien Descripción Centro Costo Descripción Familia descripción MTBF MTTR"
	#define STR0023 "Promedio General:"
	#define STR0024 'Atención'
	#define STR0025 '¡No existen datos para impresión!'
	#define STR0040 "Observación: En los casos en los cuales el bien tuviera una o menos fallas en el período consultado, impidiendo la realización del cálculo, se mostrará un guión ( - ) en su respectivo indicador."
	#define STR0041 "Horas Días"
	#define STR0042 "--------------Horas--------------"
	#define STR0043 "--------------Días--------------"
	#define STR0044 'MTBF/Hrs'
	#define STR0045 'MTTR/Hrs'
	#define STR0046 'MTBF/Días'
	#define STR0047 'MTTR/Días'
#else
	#ifdef ENGLISH
		#define STR0001 "MTBF and MTTR"
		#define STR0002 "The user can select which field will be shown, as well as "
		#define STR0003 "inform selection parameters for printing."
		#define STR0004 "Z.Form"
		#define STR0005 "Management"
		#define STR0006 "Cost Center          Description                  Description Work Center"
		#define STR0007 "Family Description                Asset             Description                                 MTBF                MTTR"
		#define STR0008 "Processing File..."
		#define STR0009 "Regular"
		#define STR0012 "Cost Center"
		#define STR0013 "Descript."
		#define STR0014 "Work Center"
		#define STR0015 "Family"
		#define STR0016 "Asst"
		#define STR0018 "MTBF"
		#define STR0019 "MTTR"
		#define STR0020 "Families"
		#define STR0022 "Asset               Description                 Cost Center         Description             Family Description                        MTBF               MTTR"
		#define STR0023 "General Average:"
		#define STR0024 'Attention'
		#define STR0025 'No data to print.'
		#define STR0040 "Note: In cases where the asset has one or fewer flaws in the period consulted, preventing the calculation from being carried out, a dash (-) will be displayed in its respective indicator."
		#define STR0041 "Hours                    Days"
		#define STR0042 "--------------Hours--------------"
		#define STR0043 "--------------Days--------------"
		#define STR0044 'MTBF/Hrs'
		#define STR0045 'MTTR/Hrs'
		#define STR0046 'MTBF/Days'
		#define STR0047 'MTTR/Days'
	#else
		#define STR0001 "MTBF e MTTR"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "O utilizador pode seleccionar quais os campos que deverão ser mostrados,", "O usuario pode selecionar quais os campos que deverao ser mostrados," )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Bem como introduzir parâmetros de selecção para a impressão.", "bem como informar parametros de selecao para a impressao." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Administração", "Administracao" )
		#define STR0006 "Centro Custo          Descrição                   C.Trabalho Descrição"
		#define STR0007 "Família Descrição                Bem              Descrição                                 MTBF                MTTR"
		#define STR0008 "Processando Arquivo..."
		#define STR0009 "Normal"
		#define STR0012 "C. Custo"
		#define STR0013 "Descrição"
		#define STR0014 "C. Trabalho"
		#define STR0015 "Família"
		#define STR0016 "Bem"
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Mtbf", "MTBF" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Mttr", "MTTR" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Famílias", "Familias" )
		#define STR0022 "Bem               Descrição                 Centro Custo         Descrição             Família Descrição                        MTBF               MTTR"
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Média geral:", "Média Geral:" )
		#define STR0024 'Atenção'
		#define STR0025 'Não há dados para a impressão!'
		#define STR0040 "Observação: Nos casos onde o bem possuir uma ou menos falhas no período consultado, impedindo a realização do cálculo, será apresentando uma traço ( - ) em seu respectivo indicador."
		#define STR0041 "Horas                  Dias"
		#define STR0042 "--------------Horas--------------"
		#define STR0043 "--------------Dias--------------"
		#define STR0044 'MTBF/Hrs'
		#define STR0045 'MTTR/Hrs'
		#define STR0046 'MTBF/Dias'
		#define STR0047 'MTTR/Dias'
	#endif
#endif
