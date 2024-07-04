#ifdef SPANISH
	#define STR0001 "Facturas de crédito"
	#define STR0002 "Naturaleza de rendimiento"
	#define STR0003 "¿Desea aplicar alguna suspensión DE TRIBUTOS en este documento?"
	#define STR0004 "Proceso informado, pero sin base/valor de suspensión"
	#define STR0005 "Proceso no existe en el archivo de procesos referenciados (CCF)"
	#define STR0006 "No es posible informar una suspensión, sin informar el proceso referente al impuesto"
	#define STR0007 "Valor de la base suspendida es mayor que la base del impuesto."
	#define STR0008 "Valor de la suspensión es mayor que el valor del impuesto."
	#define STR0009 "Proceso no informado, mas base/valor de suspensión informado"
#else
	#ifdef ENGLISH
		#define STR0001 "Trade Note"
		#define STR0002 "Income Nature"
		#define STR0003 "Do you want to enforce any TAX suspension here?"
		#define STR0004 "Process informed but no suspension value/base"
		#define STR0005 "This process does not exist in the referenced process register (CCF)."
		#define STR0006 "Unable to inform a suspension without informing the tax process"
		#define STR0007 "Amount of suspended base is greater than tax base."
		#define STR0008 "Amount of suspension is greater than tax amount."
		#define STR0009 "Process not entered but suspension value/base entered"
	#else
		#define STR0001 "Duplicatas"
		#define STR0002 "Natureza de Rendimento"
		#define STR0003 "Deseja aplicar alguma suspensão DE TRIBUTOS neste documento?"
		#define STR0004 "Processo informado, mas sem base/valor de suspensão"
		#define STR0005 "Processo não existe no cadastro de processos referenciados (CCF)"
		#define STR0006 "Não é possivel informar uma suspensão, sem informar o processo referente ao imposto"
		#define STR0007 "Valor da base suspensa é maior que a base do imposto."
		#define STR0008 "Valor da suspensão é maior que valor do imposto."
		#define STR0009 "Processo não informado, mas base/valor de suspensão informado"
	#endif
#endif
