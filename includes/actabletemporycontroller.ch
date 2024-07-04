#ifdef SPANISH
	#define STR0001 'El ID es obligatorio.'
	#define STR0002 'El tipo es obligatorio'
	#define STR0003 'No se implementó el tipo informado.'
#else
	#ifdef ENGLISH
		#define STR0001 'The ID is mandatory.'
		#define STR0002 'The type is mandatory'
		#define STR0003 'Type not implemented.'
	#else
		#define STR0001 'O ID é obrigatório.'
		#define STR0002 'O tipo é obrigatório'
		#define STR0003 'O tipo informado não foi implementado.'
	#endif
#endif
