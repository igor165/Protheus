#ifdef SPANISH
	#define STR0001 "Reversión de cálculo de Ajuste por inflación"
	#define STR0002 "Esta rutina tiene como objetivo revertir el ultimo cálculo"
	#define STR0003 " de ajuste por inflación"
	#define STR0004 "No se encontró ningún período ajustado para este ejercicio"
	#define STR0005 "Se anulará la secuencia de ajuste "
	#define STR0006 " que comprende los asientos entre las fechas "
	#define STR0007 " y "
	#define STR0008 "Período para anular"
	#define STR0009 "No se encontraron asientos para revertir." + chr ( 13 ) + "Desea continuar?"
	#define STR0010 "Espere la selección de archivos."
	#define STR0011 "Confirma Ejecuc. "
	#define STR0012 "Atenc. "
#else
	#ifdef ENGLISH
		#define STR0001 "Reversal of adjustment calculation due to inflaction"
		#define STR0002 "This routine will reverse the last adjustment"
		#define STR0003 " calculation due to inflaction"
		#define STR0004 "Couldn´t find any period adjusted for this year"
		#define STR0005 "The system will cancel the adjustment sequence "
		#define STR0006 " that comprises all entries posted between "
		#define STR0007 " and "
		#define STR0008 "Period to cancel"
		#define STR0009 " Couldn´t find any entries to reverse." + chr ( 13 ) + "Would you like to continue?"
		#define STR0010 "Please wait for the record selection."
		#define STR0011 "Confirm Performance"
		#define STR0012 "Warning"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Devolução de cálculo de acerto por inflação", "Estorno de cálculo de Ajuste por inflação" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Esto procedimento tem como objectivo estornar o último cálculo", "Esta rotina tem como objetivo estornar o último cálculo" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", " de acerto por inflacção", " de ajuste por inflação" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Não foi encontrado nenhum período acertado para este exercício", "Não foi achado nenhum período ajustado para este exercício" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Será cancelada a sequência de acerto ", "Será cancelada a sequência de ajuste " )
		#define STR0006 " que compreende os lançamentos entre as datas "
		#define STR0007 " e "
		#define STR0008 "Período a cancelar"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Não foram localizados lançamentos para estornar" + chr ( 13 ) + "Deseja continuar com a estorno?", "Não foram localizados movimentos para estorno." + chr ( 13 ) + "Deseja continuar com a reversão?" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Aguardar a selecção dos registos.", "Aguarde a seleção dos registros." )
		#define STR0011 "Confirma Execução"
		#define STR0012 "Atenção"
	#endif
#endif
