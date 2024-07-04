#ifdef SPANISH
	#define STR0001 "[TAFJobRec] Empresa: "
	#define STR0002 " - Iniciando el proceso de monitoreo del TSS vs. TAF para validación del recibo (_PROTUL)"
	#define STR0003 "[TAFJobRec] **************** Entorno desactualizado. Ejecute el compatibilizador de diccionario de datos UPDTAF ****************"
	#define STR0004 "[TAFJobRec] ¡TSS no conectado!"
	#define STR0005 "[TAFJobRec] Existe(n) campos en en registro de la sucursal matriz del TAF que no están completados"
	#define STR0006 "[TAFJobRec] Final del proceso de monitoreo del TSS vs. TAF para validación del recibo (_PROTUL)"
	#define STR0007 "[TAFJobRec] No fue posible iniciar el Job, por favor, verifique el registro de empresas."
	#define STR0008 "Registro encontrado en el TSS y actualizado con éxito en la base TAF"
	#define STR0009 "Recibo no se encontró en el TSS, no fue posible actualizar el registro en el TAF. ¡Verifique!"
#else
	#ifdef ENGLISH
		#define STR0001 "[TAFJobRec] Company:"
		#define STR0002 "- Starting TSS x TAF monitoring process for validation of receipt (_PROTUL)"
		#define STR0003 "[TAFJobRec] **************** Outdated environment. Run data dictionary compatibility program UPDTAF ****************"
		#define STR0004 "[TAFJobRec] TSS not connected."
		#define STR0005 "[TAFJobRec] There are empty fields in the TAF main branch register."
		#define STR0006 "[TAFJobRec] End of TSS x TAF monitoring process for validation of receipt (_PROTUL)"
		#define STR0007 "[TAFJobRec] Unable to start Job. Check the company register."
		#define STR0008 "Record found in TSS and updated successfully in the TAF database."
		#define STR0009 "Receipt not found in TSS. Unable to uptade record in TAF. Check."
	#else
		#define STR0001 "[TAFJobRec] Empresa: "
		#define STR0002 " - Iniciando processo de monitoramento do TSS x TAF para validacao do recibo (_PROTUL)"
		#define STR0003 "[TAFJobRec] **************** Ambiente desatualizado. Execute o compatibilizador de dicionario de dados UPDTAF ****************"
		#define STR0004 "[TAFJobRec] TSS nao conectado!"
		#define STR0005 "[TAFJobRec] Existe(m) campos no cadastro da filial matriz do TAF que não estão preenchidos"
		#define STR0006 "[TAFJobRec] Fim do processo de monitoramento do TSS x TAF para validacao do recibo (_PROTUL)"
		#define STR0007 "[TAFJobRec] Não foi possível iniciar o Job, por favor, verifique o cadastro de empresas!"
		#define STR0008 "Registro encontrado no TSS e atualizado com sucesso na base TAF"
		#define STR0009 "Recibo não encontrado no TSS, não foi possível atualizar o registro no TAF. Verifique!"
	#endif
#endif
