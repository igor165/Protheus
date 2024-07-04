#ifdef SPANISH
	#define STR0001 "No se encontraron registros para generación de archivo plano de Retención de IGV "
	#define STR0002 "Aviso"
	#define STR0003 "Archivo plano de Retención de IGV en ruta "
	#define STR0004 " generado con éxito."
#else
	#ifdef ENGLISH
		#define STR0001 "No records found for the generation of IGV Withholding plan file"
		#define STR0002 "Warning"
		#define STR0003 "IGV Withholding plan file in route"
		#define STR0004 "successfully generated."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "No se encontraron registros para generación de archivo plano de Retención de IGV ", "Não foram encontrados os registros para a geração do arquivo plano de Retenção de IGV" )
		#define STR0002 "Aviso"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Archivo plano de Retención de IGV en ruta ", "Arquivo plano de Retenção de IGV em rota" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", " generado con éxito.", "gerado com sucesso." )
	#endif
#endif
