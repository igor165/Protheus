#ifdef SPANISH
	#define STR0001 "[#1] Problema al efectuar el #2: #3"
	#define STR0002 "[#1] Reenvío realizado, pero el error persiste: #2"
	#define STR0003 "[#1] Devolución desconocida, en la operación #2: #3"
	#define STR0004 "Proveedor no encontrado en la base de datos del Protheus, tabla (SA2), código del proveedor:"
	#define STR0005 "- código de la tienda:"
	#define STR0006 "Cliente no encontrado en la base de datos del Protheus, tabla (SA1), código del cliente:"
	#define STR0007 "Producto no encontrado en la base de datos del Protheus, tabla (SB1), código del producto:"
	#define STR0008 "No existen productos por enviar en la factura de entrada."
	#define STR0009 "No existen productos por enviarse en la factura de salida."
#else
	#ifdef ENGLISH
		#define STR0001 "[#1] Problem executing #2: #3"
		#define STR0002 "[# 1] Resending done, but error persists: #2"
		#define STR0003 "[#1] Unknown return in operation #2: #3"
		#define STR0004 "Supplier is not found in the database of Protheus, table (SA2), supplier code:"
		#define STR0005 "- store code:"
		#define STR0006 "Customer is not found in the database of Protheus, table (SA1), customer code:"
		#define STR0007 "Product is not found in the database of Protheus, table (SB1), product code:"
		#define STR0008 "No products to be sent in the incoming invoice."
		#define STR0009 "No products to be sent in the outgoing invoice."
	#else
		#define STR0001 "[#1] Problema ao efetuar o #2: #3"
		#define STR0002 "[#1] Reenvio já foi feito, mas erro persiste: #2"
		#define STR0003 "[#1] Retorno desconhecido, na operação #2: #3"
		#define STR0004 "Fornecedor não encontrado na base de dados do Protheus, tabela (SA2), código do fornecedor: "
		#define STR0005 " - código da loja: "
		#define STR0006 "Cliente não encontrado na base de dados do Protheus, tabela (SA1), código do cliente: "
		#define STR0007 "Produto não encontrado na base de dados do Protheus, tabela (SB1), código do produto: "
		#define STR0008 "Não existem produtos a serem enviados na nota de entrada!"
		#define STR0009 "Não existem produtos a serem enviados na nota de saída!"
	#endif
#endif
