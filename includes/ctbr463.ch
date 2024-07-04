#ifdef SPANISH
	#define STR0001 "Libro de inventario y balances"
	#define STR0002 "Detalles de saldo de la cuenta"
	#define STR0003 "Informacion del proveedor"
	#define STR0004 "Saldo Total"
	#define STR0005 "Tipo"
	#define STR0006 "Numero"
	#define STR0007 "Razon Social"
	#define STR0008 "Descripcion de la obligacion"
	#define STR0009 "Fecha de emision"
	#define STR0010 "Total de la cuenta"
	#define STR0011 "Pendiente de pago"
	#define STR0012 "Doc. Identidad"
	#define STR0013 "Nombre"
	#define STR0014 "Denominacion"
	#define STR0015 "por pagar"
	#define STR0016 "comprobante de pago"
	#define STR0017 "Informacion de terceros"
	#define STR0018 "Valor"
	#define STR0019 "Apellido"
	#define STR0020 "Fecha inicial"
	#define STR0021 "de la operacion"
	#define STR0022 "Total general "
	#define STR0023 "Factura / Serie"
	#define STR0024 "Valor"
	#define STR0025 "Saldo total"
	#define STR0026 "Descripci�n"
	#define STR0027 "Descripci�n"
	#define STR0028 "Ocurri� un error al crear el archivo Txt."
	#define STR0029 "Archivo Txt generado con �xito."
	#define STR0030 "�Generar archivo TXT?"
	#define STR0031 "Generando archivo..."
#else
	#ifdef ENGLISH
		#define STR0001 "Inventory and Balance Records"
		#define STR0002 "Account balance detail"
		#define STR0003 "This program will print Costumers Statement"
		#define STR0004 "Final Total Balance"
		#define STR0005 "Type"
		#define STR0006 "Number"
		#define STR0007 "Company Name"
		#define STR0008 "Bill Value"
		#define STR0009 "Issue Date"
		#define STR0010 "Account total"
		#define STR0011 "Pending payment"
		#define STR0012 "ID card"
		#define STR0013 "Name"
		#define STR0014 "Branch: "
		#define STR0015 "payable"
		#define STR0016 "paymt receipt"
		#define STR0017 "Third party information"
		#define STR0018 "Value"
		#define STR0019 "Surname"
		#define STR0020 "Start date"
		#define STR0021 "of the operation"
		#define STR0022 "Grand Total "
		#define STR0023 "Invoice / Serial"
		#define STR0024 "Value"
		#define STR0025 "Total Balance"
		#define STR0026 "Description"
		#define STR0027 "Description"
		#define STR0028 "Error creating txt file "
		#define STR0029 "TXT file successfully generated"
		#define STR0030 "Generate TXT register?"
		#define STR0031 "Generating File..."
	#else
		#define STR0001 "Livro de invent�rio e balan�os"
		#define STR0002 "Detalhes de saldo da conta"
		#define STR0003 "Informa��o do fornecedor"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Saldo total", "Saldo Total" )
		#define STR0005 "Tipo"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "N�mero", "Numero" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Raz�o social", "Razao Social" )
		#define STR0008 "Descri��o da obriga��o"
		#define STR0009 "Data de Emissao"
		#define STR0010 "Total da conta"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Pendente de pgt.", "Pendente de pagto" )
		#define STR0012 "Doc. Identidade"
		#define STR0013 "Nome"
		#define STR0014 "Denomina��o"
		#define STR0015 "a pagar"
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "comprovante de pgt.", "comprovante de pagto" )
		#define STR0017 "Informa��o de terceiros"
		#define STR0018 "Valor"
		#define STR0019 "Sobrenome"
		#define STR0020 "Data de in�cio"
		#define STR0021 "da opera��o"
		#define STR0022 "Total Geral "
		#define STR0023 "Fatura / Serie"
		#define STR0024 "Valor"
		#define STR0025 "Saldo Total"
		#define STR0026 "Descri��o"
		#define STR0027 "Descri��o"
		#define STR0028 "Ocorreu um erro ao criar o arquivo Txt. "
		#define STR0029 "Arquivo Txt Gerado com �xito."
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "�Generar archivo TXT?", "Gerar cadastro TXT?" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Generando archivo...", "Gerando arquivo..." )
	#endif
#endif
