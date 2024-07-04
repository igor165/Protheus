#ifdef SPANISH
	#define STR0001 "Ult.Medicion"
	#define STR0002 "Reprogramaciones"
	#define STR0003 "Confirmar"
	#define STR0004 "Repetir"
	#define STR0005 "Salir"
	#define STR0006 "¿Reprograma?"
	#define STR0007 "Procesando..."
	#define STR0008 "Rev."
	#define STR0009 "Atencion"
	#define STR0010 "Ninguna calibracion encontrada."
	#define STR0011 "Justificación"
	#define STR0012 "Justificación obligatoria"
	#define STR0013 "Digite a continuación la justificación de los instrumentos que se reprogramarán"
	#define STR0014 "Confirmar"
	#define STR0015 "Anula"
#else
	#ifdef ENGLISH
		#define STR0001 "Last Measurement"
		#define STR0002 "Reprogrammings"
		#define STR0003 "Confirm "
		#define STR0004 "Retype  "
		#define STR0005 "Quit    "
		#define STR0006 "About Reprogramming     "
		#define STR0007 "Processing ..."
		#define STR0008 "Rev."
		#define STR0009 "Attention"
		#define STR0010 "No Calibration was found."
		#define STR0011 "Justification"
		#define STR0012 "Justification mandatory"
		#define STR0013 "Enter below the justification for instrument reprogramming"
		#define STR0014 "Confirm"
		#define STR0015 "Cancel"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Ult.medição", "Ult.Medicao" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Reprogramacoes", "Reprogramaçöes" )
		#define STR0003 "Confirma"
		#define STR0004 "Redigita"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Abandonar", "Abandona" )
		#define STR0006 "Quanto às reprogramaçöes"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "A processar...", "Processando..." )
		#define STR0008 "Rev."
		#define STR0009 "Atenção"
		#define STR0010 "Nenhuma calibração encontrada."
		#define STR0011 "Justificativa"
		#define STR0012 "Justificativa obrigatória"
		#define STR0013 "Digite abaixo a justificativa dos instrumentos serem reprogamados"
		#define STR0014 "Confirmar"
		#define STR0015 "Cancela"
	#endif
#endif
