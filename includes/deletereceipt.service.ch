#ifdef SPANISH
	#define STR0001 "Contiene cheque liquidado y no se permite el borrado."
	#define STR0002 "El recibo seleccionado no puede ser borrado."
#else
	#ifdef ENGLISH
		#define STR0001 "It contains a settled check and cannot be deleted."
		#define STR0002 "The selected receipt cannot be deleted."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Contiene cheque liquidado y no se permite el borrado.", "Contém cheque quitado e não é possível excluir." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "El recibo seleccionado no puede ser borrado.", "O recibo selecionado não pode ser excluído." )
	#endif
#endif
