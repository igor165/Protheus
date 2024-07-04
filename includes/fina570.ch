#ifdef SPANISH
	#define STR0001 "Un momento por favor..."
	#define STR0002 "Rec�lculo de los saldos de caja chica"
	#define STR0003 "Este programa recalcula los saldos de las cajas chicas"
	#define STR0004 "en abierto, considerando los comprobantes de reembolso"
	#define STR0005 "y de anticipo."
	#define STR0006 "Efectuando rec�lculo de los saldos de caja chica..."
	#define STR0007 "Par�metros"
	#define STR0008 "El modo compartido de las tablas FIJ y SET est�n diferentes. Acceda al Configurador > Base de datos y ajuste el modo compartido."
	#define STR0009 "Finalizado"
	#define STR0010 "�Procesado con �xito!"
	#define STR0011 "Finalizar"
	#define STR0012 "No procesado"
	#define STR0013 "Ocurrencia"
	#define STR0014 "No fue posible efectuar el rec�lculo de caja chica."
	#define STR0015 "Posibles causas"
	#define STR0016 "No se encontraron registros en las tablas SET y SEU."
	#define STR0017 "El saldo de caja chica no puede ser negativo."
	#define STR0018 "La rutina no efect�a el rec�lculo de saldo de cajas chicas con la situaci�n de cerrado."
	#define STR0019 "Para m�s informaci�n acceda a:"
	#define STR0020 "Rec�lculo caja chica - FINA570"
	#define STR0021 "https://tdn.totvs.com/x/TwB0Ig"
	#define STR0022 "Rec�lculo caja chica"
	#define STR0023 "HELP - NOPROCESS"
#else
	#ifdef ENGLISH
		#define STR0001 "Wait a moment, please..."
		#define STR0002 "Petty Cash Balances calculation"
		#define STR0003 "This program calculates Open Petty Cash balances,"
		#define STR0004 "considering the refund and advancement "
		#define STR0005 "documents."
		#define STR0006 "Executing Petty Cash balances calculation..."
		#define STR0007 "Parameters"
		#define STR0008 "The sharing of tables FIJ and SET are different. Access Configurator > Data Base and adjust the sharing."
		#define STR0009 "Finished"
		#define STR0010 "Processed successfully"
		#define STR0011 "Close"
		#define STR0012 "Not processed"
		#define STR0013 "Event"
		#define STR0014 "Recalculation of petty cash not allowed."
		#define STR0015 "Possible causes"
		#define STR0016 "No records found in SET and SEU tables."
		#define STR0017 "The balance of the petty cash cannot be negative."
		#define STR0018 "The routine does not recalculate the petty cash balances with closed status."
		#define STR0019 "For further information, go to:"
		#define STR0020 "Petty cash recalculation - FINA570"
		#define STR0021 "https://tdn.totvs.com/x/TwB0Ig"
		#define STR0022 "Petty cash recalculation"
		#define STR0023 "HELP - NOPROCESS"
	#else
		#define STR0001 "Um momento por favor..."
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Repeti��o Do C�lculo Dos Saldos Do Utilizador", "Rec�lculo dos Saldos do Caixinha" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Este Programa Recalcula Os Saldos Das Caixas", "Este programa recalcula os saldos dos Caixinhas" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Em aberto, a considerar os comprovativos de reembolso", "em aberto, considerando os comprovantes de reembolso" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "E de adiantamento.", "e de adiantamento." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "A Executar O Rec�lculo Dos Saldos Das Caixas...", "Executando o rec�lculo dos Saldos dos Caixinhas..." )
		#define STR0007 "Par�metros"
		#define STR0008 "O compartilhamento das tabelas FIJ e SET est�o diferentes. Acesse o Configurador > Base de Dados e ajuste o compartilhamento."
		#define STR0009 "Finalizado"
		#define STR0010 "Processado com sucesso !"
		#define STR0011 "Fechar"
		#define STR0012 "N�o processado"
		#define STR0013 "Ocorr�ncia"
		#define STR0014 "N�o foi possivel efetuar o recalculo do caixinha."
		#define STR0015 "Possiveis causas"
		#define STR0016 "N�o foi encontrado registros nas tabelas SET e SEU. "
		#define STR0017 "O saldo do caixinha n�o pode ser negativo."
		#define STR0018 "A rotina n�o efetua o rec�lculo de saldo dos caixinhas com a situa��o de fechado."
		#define STR0019 "Para maiores informa��es acesse:"
		#define STR0020 "Rec�lculo do caixinha - FINA570"
		#define STR0021 "https://tdn.totvs.com/x/TwB0Ig"
		#define STR0022 "Rec�lculo do caixinha"
		#define STR0023 "HELP - NOPROCESS"
	#endif
#endif
