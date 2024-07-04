#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Incluir"
	#define STR0004 "Modificar"
	#define STR0005 "Borrar"
	#define STR0006 "Informe"
	#define STR0007 "Atribucion de Debitos del Siniestro"
	#define STR0008 "�Fecha de Apertura no podra ser mayor que Fecha de Conclusion!"
	#define STR0009 "Atencion"
	#define STR0010 "A rayas"
	#define STR0011 "Administracion"
	#define STR0012 "Numero APD:"
	#define STR0013 "Nueva"
	#define STR0014 "En Proceso"
	#define STR0015 "Rechazada"
	#define STR0016 "Anulada"
	#define STR0017 "Concluida"
	#define STR0018 "Estatus:"
	#define STR0019 "Informaciones del Conductor"
	#define STR0020 "Conductor:"
	#define STR0021 "Centro Costo:"
	#define STR0022 "Cargo:"
	#define STR0023 "Sucursal:"
	#define STR0024 "Tipo de APD:"
	#define STR0025 "Informaciones Sobre Valores"
	#define STR0026 "Valor Estimado: R$"
	#define STR0027 "Por Extenso:"
	#define STR0028 "Descripcion de los Hechos"
	#define STR0029 "Descripcion de los hechos:"
	#define STR0030 "Dictamen Juridico:"
	#define STR0031 "Documentos"
	#define STR0032 "No fueron encontrados documentos registrados para el siniestro referente al APD."
	#define STR0033 "Dictamen del Responsable"
	#define STR0034 "-> Usted esta de acuerdo con los hechos de la forma en que fueron narrados?"
	#define STR0035 "-> Por que: "
	#define STR0036 "-> Ante los hechos y las pruebas anteriores, usted se declara responsable de los danos ocurridos?"
	#define STR0037 "-> Hay algun procedimiento que usted quiera sugerir o alguna prueba para presentar?"
	#define STR0038 "-> Descripcion: "
	#define STR0039 "Dictamen del Gerente"
	#define STR0040 "Debitar para:"
	#define STR0041 "Forma: "
	#define STR0042 "Cuotas: "
	#define STR0043 "Firma del colaborador"
	#define STR0044 "Firma del gerente"
	#define STR0045 "Recusa de Firma"
	#define STR0046 "Testigo 1: "
	#define STR0047 "Testigo 2: "
	#define STR0048 "DNI: "
	#define STR0049 "CPF: "
	#define STR0050 "�Desea generar una notificacion del APD?"
	#define STR0051 " no podra ser inferior a "
	#define STR0052 "APD esta relacionado a un Siniestro!"
	#define STR0053 "Si"
	#define STR0054 "No"
	#define STR0055 "-> Si esta de acuerdo, autoriza el descuento en su Planilla de haberes de los valores anteriormente citados?"
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View"
		#define STR0003 "Add"
		#define STR0004 "Edit"
		#define STR0005 "Delete"
		#define STR0006 "Report"
		#define STR0007 "Damage Debit Allocation"
		#define STR0008 "Opening Date cannot be later than Finishing Date!"
		#define STR0009 "Attention"
		#define STR0010 "Z-form"
		#define STR0011 "Administration"
		#define STR0012 "APD Number: "
		#define STR0013 "New"
		#define STR0014 "In Progress"
		#define STR0015 "Rejected"
		#define STR0016 "Cancelled"
		#define STR0017 "Finished"
		#define STR0018 "Status: "
		#define STR0019 "Information about Driver"
		#define STR0020 "Driver: "
		#define STR0021 "Cost Center: "
		#define STR0022 "Position: "
		#define STR0023 "Branch: "
		#define STR0024 "APD Type: "
		#define STR0025 "Information on Values"
		#define STR0026 "Estimated Amount: R$ "
		#define STR0027 "Not Shortened: "
		#define STR0028 "Event Description"
		#define STR0029 "Event description: "
		#define STR0030 "Legal Opinion: "
		#define STR0031 "Documents"
		#define STR0032 "No documents registered for damage relating to APD."
		#define STR0033 "Responsible Person Opinion"
		#define STR0034 "-> Do you agree with facts the way they were reported?"
		#define STR0035 "-> Why: "
		#define STR0036 "-> Before facts and evidences aforementioned, do you plea yourself responsible for damages caused?"
		#define STR0037 "-> Is there any procedure you want to suggest or any evidence to present?"
		#define STR0038 "-> Description: "
		#define STR0039 "Manager Opinion"
		#define STR0040 "Charge to: "
		#define STR0041 "Mode: "
		#define STR0042 "Installments: "
		#define STR0043 "Employee signature"
		#define STR0044 "Manager signature"
		#define STR0045 "Rejection of Signature"
		#define STR0046 "Witness 1: "
		#define STR0047 "Witness 2: "
		#define STR0048 "RG "
		#define STR0049 "CPF: "
		#define STR0050 "Do you want to generate an APD notification?"
		#define STR0051 " cannot be lower than "
		#define STR0052 "APD is related to a Claim!"
		#define STR0053 "Yes"
		#define STR0054 "No"
		#define STR0055 "-> If you agree with it, do you authorize the discount of values aforementioned in your payroll?"
	#else
		#define STR0001 "Pesquisar"
		#define STR0002 "Visualizar"
		#define STR0003 "Incluir"
		#define STR0004 "Alterar"
		#define STR0005 "Excluir"
		#define STR0006 "Relat�rio"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Adequa��o De D�bitos Do Sinistro", "Apropria��o de D�bitos do Sinistro" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "A Data De Abertura N�o Poder� Ser Posterior � Data Da Conclus�o!", "Data de Abertura n�o poder� ser maior que Data de Conclus�o!" )
		#define STR0009 "Aten��o"
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "C�digo de barras", "Zebrado" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Administra��o", "Administracao" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "N�mero apd: ", "N�mero APD: " )
		#define STR0013 "Nova"
		#define STR0014 "Em Processo"
		#define STR0015 "Rejeitada"
		#define STR0016 "Cancelada"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Conclu�da", "Concluida" )
		#define STR0018 "Status: "
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Informa��es Do Condutor", "Informa��es do Motorista" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Condutor : ", "Motorista: " )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Centro  de custo: ", "Centro Custo: " )
		#define STR0022 "Cargo: "
		#define STR0023 "Filial: "
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Tipo de apd: ", "Tipo de APD: " )
		#define STR0025 "Informa��es Sobre Valores"
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Valor estimado: � ", "Valor Estimado: R$ " )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Por extenso: ", "Por Extenso: " )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Descri��o Dos Factos", "Descri��o dos Fatos" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Descri��o dos factos", "Descri��o dos fatos: " )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Parecer jur�dico: ", "Parecer Jur�dico: " )
		#define STR0031 "Documentos"
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "N�o Foram Encontrados Documentos Registados Para O Sinistro Referente Ao Apd.", "N�o foram encontrados documentos cadastrados para o sinistro referente ao APD." )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Parecer Do Respons�vel", "Parecer do Respons�vel" )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "-> Voc� concorda com os factos da forma em que foram narrados?", "-> Voc� concorda com os fatos da forma em que foram narrados?" )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "-> porque: ", "-> Por que: " )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "-> Diante dos factos e das provas acima, voc� se declara respons�vel pelos danos ocorridos?", "-> Diante dos fatos e das provas acima, voc� se declara respons�vel pelos danos ocorridos?" )
		#define STR0037 "-> H� algum procedimento que voc� queira sugerir ou alguma prova a apresentar?"
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "-> descri��o: ", "-> Descri��o: " )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Parecer Do Gerente", "Parecer do Gerente" )
		#define STR0040 "Debitar para: "
		#define STR0041 "Forma: "
		#define STR0042 "Parcelas: "
		#define STR0043 "Assinatura do colaborador"
		#define STR0044 "Assinatura do gerente"
		#define STR0045 If( cPaisLoc $ "ANG|PTG", "Recusa De Assinatura", "Recusa de Assinatura" )
		#define STR0046 "Testemunha 1: "
		#define STR0047 "Testemunha 2: "
		#define STR0048 If( cPaisLoc $ "ANG|PTG", "Rg: ", "RG: " )
		#define STR0049 If( cPaisLoc $ "ANG|PTG", "Nr.contrib: ", "CPF: " )
		#define STR0050 If( cPaisLoc $ "ANG|PTG", "Deseja criar uma notifica��o do apd?", "Deseja gerar uma notifica��o do APD?" )
		#define STR0051 If( cPaisLoc $ "ANG|PTG", " n�o poder� ser menor do que ", " n�o poder� ser menor que " )
		#define STR0052 "APD est� relacionado a um Sinistro!"
		#define STR0053 "Sim"
		#define STR0054 "N�o"
		#define STR0055 "-> Se concorda, autoriza o desconto em sua folha de pagamento dos valores acima citados?"
	#endif
#endif
