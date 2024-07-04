#ifdef SPANISH
	#define STR0001 'La sucursal es obligatoria.'
	#define STR0002 "no fue posible devolver el listado de cierre debido a la inconsistencia en la query"
#else
	#ifdef ENGLISH
		#define STR0001 'Branch is required.'
		#define STR0002 "Unable to return the closing list due to a query inconsistency"
	#else
		#define STR0001 'A filial é obrigatório.'
		#define STR0002 "não foi possivel retornar a listagem de fechamento devido a inconsistencia na query"
	#endif
#endif
