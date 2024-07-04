#ifdef SPANISH
	#define STR0001 "Empresa"
	#define STR0002 "Sucursal"
	#define STR0003 "Configuracion invalida de Sucursal"
	#define STR0004 "Verificar Empresa/Sucursal en los Jobs"
	#define STR0005 "Iniciando el Workflow"
	#define STR0006 "Fecha"
	#define STR0007 "Hora"
	#define STR0008 "No se encontro el archivo"
	#define STR0009 "Multas Vencidas/Por Vencer"
	#define STR0010 "(INICIO)Proceso: "
	#define STR0011 "Multa"
	#define STR0012 "Matricula"
	#define STR0013 "Bien"
	#define STR0014 "Descripcion"
	#define STR0015 "Infraccion"
	#define STR0016 "Fch. Vencimiento"
	#define STR0017 "Valor"
	#define STR0018 "�Workflow enviado!"
	#define STR0019 "�No existen datos para enviar el workflow!"
	#define STR0020 "Verifique los par�metros de configuraci�n: "
	#define STR0021 "MV_RELAUSR y MV_RELAUTH."
	#define STR0022 "�Atenci�n!"
	#define STR0023 " Por favor, verifique el par�metro MV_RELACNT"
	#define STR0024 " Por favor, verifique si el empleado tiene el E-mail registrado en el sistema."
	#define STR0025 " �Env�o de e-mail anulado!"
	#define STR0026 "Destinatario del e-mail no informado."
	#define STR0027 "�Servidor SMTP no informado! Por favor, verifique el par�metro MV_RELSERV."
#else
	#ifdef ENGLISH
		#define STR0001 "Company"
		#define STR0002 "Branch"
		#define STR0003 "Invalid Branch Configuration"
		#define STR0004 "Check Company/Branch in Jobs"
		#define STR0005 "Starting Workflow"
		#define STR0006 "Date"
		#define STR0007 "Time"
		#define STR0008 "File not found"
		#define STR0009 "Past due/To be due Fine"
		#define STR0010 "(START)Process: "
		#define STR0011 "Fine"
		#define STR0012 "License Plate"
		#define STR0013 "Asset"
		#define STR0014 "Description"
		#define STR0015 "Violation"
		#define STR0016 "Due Date"
		#define STR0017 "Value"
		#define STR0018 "Workflow sent!"
		#define STR0019 "There are no data to send the workflow!"
		#define STR0020 "Check configuration parameters: "
		#define STR0021 "MV_RELAUSR and MV_RELAUTH."
		#define STR0022 "Attention!"
		#define STR0023 " Please, check parameter MV_RELACNT"
		#define STR0024 " Please, check whether employee has e-mail registered in the system."
		#define STR0025 " E-mail sending canceled!"
		#define STR0026 "E-mail addressee not entered."
		#define STR0027 "SMTP server not configured. Please, check parameter MV_RELSERV."
	#else
		#define STR0001 "Empresa"
		#define STR0002 "Filial"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Configura��o inv�lida de Filial", "Configura��o invalida de Filial" )
		#define STR0004 "Verificar Empresa/Filial nos Jobs"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "A iniciar o Workflow", "Iniciando o Workflow" )
		#define STR0006 "Data"
		#define STR0007 "Hora"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "N�o foi encontrado o ficheiro", "Nao foi encontrado o arquivo" )
		#define STR0009 "Multas Vencidas/A Vencer"
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "(IN�CIO)Processo: ", "(INICIO)Processo: " )
		#define STR0011 "Multa"
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Matr�cula", "Placa" )
		#define STR0013 "Bem"
		#define STR0014 "Descri��o"
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Infrac��o", "Infra��o" )
		#define STR0016 "Dt. Vencimento"
		#define STR0017 "Valor"
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Workflow enviado.", "Workflow enviado!" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "N�o existem dados para enviar o workflow.", "N�o existem dados para enviar o workflow!" )
		#define STR0020 "Verifique os par�metros de configura��o: "
		#define STR0021 "MV_RELAUSR e MV_RELAUTH."
		#define STR0022 "Aten��o!"
		#define STR0023 " Favor, verificar par�metro MV_RELACNT"
		#define STR0024 " Favor, verifique se o funcion�rio possui E-mail cadastrado no sistema."
		#define STR0025 " Envio de E-mail cancelado!"
		#define STR0026 "Destinat�rio do E-mail n�o informado."
		#define STR0027 "Servidor SMTP n�o informado! Favor, verificar par�metro MV_RELSERV."
	#endif
#endif
