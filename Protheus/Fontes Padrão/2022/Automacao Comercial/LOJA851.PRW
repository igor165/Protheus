#INCLUDE "LOJA851.CH"
#INCLUDE "PROTHEUS.CH"

Static nCasas := SuperGetMv("MV_CENT", , 0) //Numero de casas decimais

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³LOJA851   ³ Autor ³Vendas Clientes        ³ Data ³26.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta da Conta Corrente                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LOJA851()

Local lR5		:= GetRpoRelease ("R5") // Release 11.5
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro	:=	STR0004 	  // "Consulta Conta Corrente"
Private aRotina 	:= MenuDef()  

If ! lR5
	Return NIL
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros 					³
//³ MV_PAR01		  // Emissao De          	   	        ³
//³ MV_PAR02		  // Emissao Ate                     	³
//³ MV_PAR03		  // Vencimento De                      ³
//³ MV_PAR04		  // Vencimento Ate                		³
//³ MV_PAR05		  // Do Prefixo                       	³
//³ MV_PAR06		  // At‚ Prefixo                      	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona o Cadastro de Clientes.            			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(DbSetOrder(1))

mBrowse( 6, 1,22,75,"SA1")

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Vendas Clientes       ³ Data ³28/11/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Private aRotina	:=	{	{STR0001, "AxPesqui" , 0 , 1},; 	//"Pesquisar"
						{STR0002, "AxVisual" , 0 , 2},;  	//"Visualizar"
						{STR0003, "LJ851CON" , 0 , 2}}  	//"Consultar"

Return(aRotina)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LJ851CON  ³ Autor ³ Vendas Clientes       ³ Data ³25.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta de Conta Corrente                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ851CON()

Local aArea			:= GetArea()		// Bk da Area
Local aAreaSC5		:= SC5->(GetArea())	// Bk da Area
Local aAreaSC6		:= SC6->(GetArea())	// Bk da Area
Local aAreaSC9		:= SC9->(GetArea())	// Bk da Area
Local aAreaSF4		:= SF4->(GetArea())	// Bk da Area
Local aStru			:= {}				// Estrutura
Local aQuery		:= {}							// Query
Local aSay			:= {"","","","","","","",""}	// Label
Local oGetDb		:= Nil  //Objeto de Tela
Local oScrPanel 	:= Nil  //Objeto de Tela
Local oBold			:= Nil  //Objeto de Tela
Local oDlg			:= Nil  //Objeto de Tela
Local oBtn			:= Nil  //Objeto de Tela
Local bVisual		:= Nil  //Objeto de Tela	
Local bWhile		:= Nil  //Objeto de Tela
Local bFiltro		:= Nil  //Objeto de Tela
Local cAlias		:= "" 	// ALias de baixa
Local cArquivo		:= ""	// Arquivo de Baixa
Local cCadastro		:= ""	// Titulo de cadastro
Local cPerg			:= "LOJC851" // Pergunt usado 
#IFDEF TOP
	Local cQuery	:= "" 		// Amazena a Query
#ENDIF	
Local cQry			:= ""			// Amazena a Query
Local cChave		:= ""			// Chave
Local lQuery		:= .F.			// Se FAz Query
Local nCntFor		:= 0			// Cont Fornecedor
Local nTotAbat		:= 0			// Total Abatimento
Local nTaxaM		:= 0			// Taxa Monetaria
Local nMoeda		:= 0			// Moeda
Local oTipo			:= Nil			// Objeto de Tela
Local nTipo			:= 1			// Numero de tipo
Local nAscan		:= 0			// Procura no array
Local nTotalRec		:= 0			// Total de recebimento
Local aSize			:= MsAdvSize( .F. )	// Array com tamanho da variavel
Local aPosObj1		:= {}              	// Posicionamento de Tela
Local aObjects		:= {}               // Posicionamento de Tela        
Local cOrdem		:= ""   			// ordem
Local cTipoTit 		:= "FI"				// Tipo dos Títulos que serão considerados
Local cNatCCor		:= SuperGetMv( "MV_NATCCOR" , .F. , "OUTROS" ,  )	//Natureza referente a Conta Corrente	 
Local cQryBkp		:= ""              // Backup de Query
Local oTempTable	:= Nil //Objeto tabela temporaria

If ! pergunte(cPerg,.T.)
	Return( Nil )
EndIf

Private aHeader	:= {}

aGet := {"","","","","","","",""}

cCadastro := STR0004
cAlias    := GetNextAlias()//"LJ851QRY01"
aSay[1]   := STR0005 //"Qtd.Tit."
aSay[2]   := STR0006 //"Principal"
aSay[3]   := STR0007 //"Saldo a Receber"
aSay[4]   := STR0008 //"Juros"
aSay[5]   := STR0009 //"Acresc."
aSay[6]   := STR0010 //"Decresc."
aSay[7]   := STR0011 //"Abatimentos"
aSay[8]   := STR0012 //"Tot.Geral"	
bVisual   := {|| Lj851Visua((cAlias)->XX_RECNO) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Titulo em Aberto                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aHeader,{"",	"XX_LEGEND","@BMP",10,0,"","","C","",""})
Aadd(aStru,{"XX_LEGEND","C",12,0})
SX3->(DbSetOrder(2))

SX3->(DbSeek("E1_LOJA"))
//aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_PREFIXO"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_NUM"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_PARCELA"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_TIPO"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_CLIENTE"))
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_EMISSAO"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_VENCTO"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_BAIXA"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_VENCREA"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		
SX3->(DbSeek("E1_MOEDA"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
	
SX3->(DbSeek("E1_VALOR"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	
SX3->(DbSeek("E1_VLCRUZ"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

aadd(aHeader,{STR0011,"E1_ABT","@E 999,999,999.99",14,2,"","","N","","V" } ) //"Abatimentos"
aadd(aStru ,{"E1_ABT","N",14,2})

SX3->(DbSeek("E1_SDACRES"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_SDDECRE"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_VALJUR"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_SALDO"))
aadd(aHeader,{STR0026,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )	//"Saldo a Receber"
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

aadd(aHeader,{ STR0025,"E1_SALDO2",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } ) // "Saldo na moeda tit"
aadd(aStru ,{"E1_SALDO2",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_NATUREZ"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_PORTADO"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})		

SX3->(DbSeek("E1_NUMBCO"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

SX3->(DbSeek("E1_NUMLIQ"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})


SX3->(DbSeek("E1_HIST"))
aadd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

aadd(aHeader,{STR0024,"E1_ATR","9999999999",10,0,"","","N","","V" } ) //"Atraso"
aadd(aStru ,{"E1_ATR","N",10,0})

SX3->(DbSeek("E1_CHQDEV"))
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

//Utilizado para demonstrar a situação de cobranca do titulo
//A tabela FRV substitui a tabela 07 do SX5
SX3->(dbSeek("E1_SITUACA"))
aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
Aadd(aStru,{"FRV_DESCRI","C",25,0})
Aadd(aHeader,{STR0013,"FRV_DESCRI","@!",25,0,"","","C","FRV","" } ) //"Situacao"					

aadd(aStru,{"XX_RECNO","N",12,0})
aadd(aStru,{"E1_MOEDA","N",02,0})

aadd(aQuery,{"E1_PORCJUR","N",12,4})
aadd(aQuery,{"E1_MOEDA","N",02,0})
aadd(aQuery,{"E1_VALOR","N",16,2})

If cPaisLoc == "BRA"
	aadd(aQuery,{"E1_TXMOEDA","N",17,4})
Endif	

SX3->(dbSetOrder(1))

If ( Select(cAlias) ==	0 )
	cArquivo := CriaTrab(,.F.)			
	aadd(aStru,{"FLAG","L",01,0})
	//Cria tabela temporaria	
	oTempTable := LjCrTmpTbl(cAlias, aStru)
	IndRegua(cAlias,cArquivo,"E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")

	#IFDEF TOP
		If ( TcSrvType()!="AS/400" )
			lQuery := .T.
			cQuery := ""
			aEval(aQuery,{|x| cQuery += ","+AllTrim(x[1])})
			cQuery := "SELECT "+SubStr(cQuery,2)
			cQuery +=         ",SE1.R_E_C_N_O_ SE1RECNO"
			cQuery +=         ",FRV.FRV_DESCRI "								
			cQuery += "FROM "+RetSqlName("SE1")+" SE1,"
			cQuery +=         RetSqlName("FRV")+" FRV "
			cQuery += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
			cQuery +=       "SE1.E1_CLIENTE='"+SA1->A1_COD+"' AND "
			cQuery +=       "SE1.E1_LOJA='"+SA1->A1_LOJA+"' AND "
			cQuery +=       "SE1.E1_EMISSAO>='"+Dtos(MV_PAR01)+"' AND "
			cQuery +=       "SE1.E1_EMISSAO<='"+Dtos(MV_PAR02)+"' AND "
			cQuery +=       "SE1.E1_VENCREA>='"+Dtos(MV_PAR03)+"' AND "
			cQuery +=       "SE1.E1_VENCREA<='"+Dtos(MV_PAR04)+"' AND "
			cQuery += "SE1.E1_PREFIXO>='"+MV_PAR05+"' AND "
			cQuery += "SE1.E1_PREFIXO<='"+MV_PAR06+"' AND " 
			cQuery += "SE1.E1_SALDO > 0 AND "
			
			cQuery +=		"SE1.D_E_L_E_T_<>'*' AND "
			cQuery +=       "FRV.FRV_FILIAL='"+xFilial("FRV")+"' AND "
			cQuery +=		"FRV.FRV_CODIGO=SE1.E1_SITUACA AND "
			cQuery +=		"FRV.D_E_L_E_T_<>'*' "
			cQuery	+=		" AND SE1.E1_SITUACA = '0'  "
			cQuery	+=		" AND SE1.E1_ORIGEM  IN ('LOJA701','LOJA010')  "
			

			cQryBkp:=  cQuery 

			cQuery	+=		" AND SE1.E1_TIPO    = '" + cTipoTit			+ "' AND "
			cQuery	+=		" SE1.E1_NATUREZ = '" + cNatCCor			+ "'  UNION ALL "+ cQryBkp
			cQuery += "AND SE1.E1_TIPO LIKE '__-'"
			
			If UPPER(TcGetDb()) != "INFORMIX"
				cQuery   += " ORDER BY  " + SqlOrder("E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+SE1RECNO")
			Endif	
                                                                                                       
			cQuery := ChangeQuery(cQuery)
			cQry   := cArquivo+"A"

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)

			aEval(aQuery,{|x| If(x[2]!="C",TcSetField(cQry,x[1],x[2],x[3],x[4]),Nil)})
		Else
	#ENDIF
		cQry := "SE1"
	#IFDEF TOP
		EndIf
	#ENDIF
	dbSelectArea(cQry)
	If ( !lQuery )   
			
		SE1->(dbSetOrder(2))
		SE1->(dbSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA))
		bWhile := {|| !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
									SA1->A1_COD    == SE1->E1_CLIENTE .And.;
									SA1->A1_LOJA   == SE1->E1_LOJA }
									
									
		bFiltro:= {|| !(SE1->E1_TIPO $ MVABATIM) .And.;
							SE1->E1_EMISSAO >= MV_PAR01 .And.;
							SE1->E1_EMISSAO <= MV_PAR02 .And.;
							SE1->E1_VENCREA >= MV_PAR03 .And.;
							SE1->E1_VENCREA <= MV_PAR04 .And.;
							SE1->E1_PREFIXO >= MV_PAR05 .And.;
							SE1->E1_PREFIXO <= MV_PAR06 .And.;
							Alltrim(SE1->E1_TIPO) $ cTipoTit		 .And.;							
							Alltrim(SE1->E1_NATUREZ) == cNatCCor .And.;														
							SE1->E1_SITUACA == '0' 		 .And.;								
							( Alltrim(SE1->E1_ORIGEM) == 'LOJA701' .OR. Alltrim(SE1->E1_ORIGEM) == 'LOJA010' ) .And.;															
							SE1->E1_SALDO   > 0  }
							
	Else

		bWhile := {|| !Eof() }
		bFiltro:= {|| .T. }							
					
	Endif 
	
	While ( Eval(bWhile) )				
		If ( Eval(bFiltro) )	//SITCOB
			dbSelectArea(cAlias)
			(cAlias)->(DbSetOrder(1))
			cChave := (cQry)->(E1_CLIENTE)+(cQry)->(E1_LOJA) +;
						 (cQry)->(E1_PREFIXO)+(cQry)->(E1_NUM)+;
						 (cQry)->(E1_PARCELA)
			cChave += If((cQry)->(E1_TIPO)	$ MVABATIM, "",;
			              (cQry)->(E1_TIPO))
			If ( !(cAlias)->(DbSeek(cChave)) )
				RecLock(cAlias,.T.)						
			Else
				RecLock(cAlias,.F.)
			EndIf
			DbSetOrder(1)
			nTotAbat := 0
			For nCntFor := 1 To Len(aStru)
				Do Case
				//Utilizado para demonstrar a situação de cobranca do titulo
				//A tabela FRV substitui a tabela 07 do SX5
				Case ( AllTrim(aStru[nCntFor][1])=="FRV_DESCRI" )
					If !( (cQry)->(E1_TIPO)	$ MVABATIM )
						If ( lQuery )
							(cAlias)->FRV_DESCRI := Capital(FN022SITCB((cQry)->E1_SITUACA)[9])	
						Else
							(cAlias)->FRV_DESCRI := FN022SITCB(SE1->E1_SITUACA)[9]	
						EndIf
					Endif	
					
				Case ( AllTrim(aStru[nCntFor][1])=="E1_VALJUR" )
				Case ( AllTrim(aStru[nCntFor][1])=="E1_ABT" )
					If cPaisLoc == "BRA"
						nTaxaM := (cQry)->E1_TXMOEDA
					Else
						nTaxaM:=round((cQry)->E1_VLCRUZ / (cQry)->E1_VALOR,4)  // Pegar a taxa da moeda usada qdo da inclusão do titulo
					Endif
					If ( (cQry)->(E1_TIPO)	$ MVABATIM )
						(cAlias)->E1_ABT += (nTotAbat := xMoeda((cQry)->(E1_SALDO),(cQry)->(E1_MOEDA),1,(cQry)->(E1_EMISSAO),,nTaxaM))
					Endif
					If ( !lQuery )
						(cAlias)->E1_ABT := (nTotAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA))
					Endif
				
				Case ( AllTrim(aStru[nCntFor][1])=="E1_SALDO" )
					If cPaisLoc == "BRA"
						nTaxaM := (cQry)->E1_TXMOEDA
					Else
						nTaxaM:=round((cQry)->E1_VLCRUZ / (cQry)->E1_VALOR,4)  // Pegar a taxa da moeda usada qdo da inclusão do titulo
					Endif	
					If ( (cQry)->(E1_TIPO)	$ MVABATIM )
						If MV_PAR07 == 2	 // mv_par07 = 2 : Considera juros e taxa de pernamencia na visualizacao de titulos em aberto.
							(cAlias)->E1_SALDO -= nTotAbat
						Endif
					Else
						(cAlias)->E1_SALDO += xMoeda((cQry)->(E1_SALDO),(cQry)->(E1_MOEDA),1,dDataBase,,ntaxaM)
						If MV_PAR07 == 2   // mv_par07 = 2 : Considera juros e taxa de pernamencia na visualizacao de titulos em aberto.
							(cAlias)->E1_SALDO += xMoeda((cQry)->(E1_SDACRES) - (cQry)->(E1_SDDECRE),(cQry)->(E1_MOEDA),1,dDataBase,,ntaxaM)
							(cAlias)->E1_SALDO += xMoeda(FaJuros((cQry)->E1_VALOR,(cQry)->E1_SALDO,(cQry)->E1_VENCTO,(cQry)->E1_VALJUR,(cQry)->E1_PORCJUR,(cQry)->E1_MOEDA,(cQry)->E1_EMISSAO,,If(cPaisLoc=="BRA",(cQry)->E1_TXMOEDA,0),,(cQry)->E1_VENCREA),(cQry)->E1_MOEDA,1,,,If(cPaisLoc=="BRA",(cQry)->E1_TXMOEDA,0))
						Endif
					EndIf
					If ( !lQuery )
						If MV_PAR07 == 2   // mv_par07 = 2 : Considera juros e taxa de pernamencia na visualizacao de titulos em aberto.	
							(cAlias)->E1_SALDO -= nTotAbat
						Endif
					EndIf
				Case ( AllTrim(aStru[nCntFor][1])=="E1_SALDO2" )
					If ( (cQry)->(E1_TIPO)	$ MVABATIM )
						If MV_PAR07 == 2   // mv_par07 = 2 : Considera juros e taxa de pernamencia na visualizacao de titulos em aberto.	
							(cAlias)->E1_SALDO2 -= nTotAbat
						Endif
					Else
						(cAlias)->E1_SALDO2 += (cQry)->(E1_SALDO)
						(cAlias)->E1_VALJUR := xMoeda(FaJuros((cQry)->E1_VALOR,(cAlias)->E1_SALDO2,(cQry)->E1_VENCTO,(cQry)->E1_VALJUR,(cQry)->E1_PORCJUR,(cQry)->E1_MOEDA,(cQry)->E1_EMISSAO,,If(cPaisLoc=="BRA",(cQry)->E1_TXMOEDA,0),,(cQry)->E1_VENCREA),(cQry)->E1_MOEDA,1,,,If(cPaisLoc=="BRA",(cQry)->E1_TXMOEDA,0))
						If MV_PAR07 == 2   // mv_par07 = 2 : Considera juros e taxa de pernamencia na visualizacao de titulos em aberto.	
							(cAlias)->E1_SALDO2 += (cAlias)->E1_SDACRES - (cAlias)->E1_SDDECRE
							(cAlias)->E1_SALDO2 += xMoeda((cAlias)->E1_VALJUR,1,(cQry)->(E1_MOEDA),dDataBase,,ntaxaM) 
						Endif
					EndIf
					If ( !lQuery )
						If MV_PAR07 == 2   // mv_par07 = 2 : Considera juros e taxa de pernamencia na visualizacao de titulos em aberto.	
							(cAlias)->E1_SALDO2 -= nTotAbat
						Endif
					EndIf		
				Case ( AllTrim(aStru[nCntFor][1])=="XX_RECNO" )
					If !( (cQry)->(E1_TIPO)	$ MVABATIM )
						If ( lQuery )
							(cAlias)->XX_RECNO := (cQry)->SE1RECNO
						Else
							(cAlias)->XX_RECNO := SE1->(RecNo())
						EndIf
					Endif
				Case (  AllTrim(aStru[nCntFor][1])=="XX_LEGEND" )
					If (cQry)->E1_CHQDEV == "1"
						(cAlias)->XX_LEGEND := 	"BR_AMARELO"
					Else
						If !((cQry)->E1_TIPO $ MVABATIM)
							(cAlias)->XX_LEGEND := If(ROUND((cQry)->E1_SALDO,2) != ROUND((cQry)->E1_VALOR,2),"BR_AZUL","BR_VERDE")
						EndIf
					Endif
				Case ( AllTrim(aStru[nCntFor][1])=="E1_TIPO" )
					If ( Empty((cAlias)->E1_TIPO) )
						(cAlias)->E1_TIPO := (cQry)->E1_TIPO
					EndIf
				Case ( AllTrim(aStru[nCntFor][1])=="E1_ATR" )
					//Se o título estiver atrasado, faz o calculo dos dias de atraso
					If !((cQry)->E1_TIPO $ MVABATIM)					
						If dDataBase > (cQry)->E1_VENCREA
							If (((cAlias)->E1_TIPO) $ MVRECANT+"/"+MV_CRNEG)
								(cAlias)->E1_ATR := 0
							Else	
								(cAlias)->E1_ATR := dDataBase - (cQry)->E1_VENCREA
							EndIf	
						Else 
							(cAlias)->E1_ATR := dDataBase - DataValida((cQry)->E1_VENCREA,.T.)
						Endif
					Endif
				Case ( AllTrim(aStru[nCntFor][1])=="FLAG" )
				
				Case ( AllTrim(aStru[nCntFor][1])=="E1_VLCRUZ" )
					If !((cQry)->(E1_TIPO)	$ MVABATIM)
						(cAlias)->E1_VLCRUZ := xMoeda((cQry)->(E1_VALOR),(cQry)->(E1_MOEDA),1,dDataBase,,If(cPaisLoc=="BRA",(cQry)->E1_TXMOEDA,0))
					Endif
				Case ( AllTrim(aStru[nCntFor][1])=="E1_VLMULTA" )
						(cAlias)->E1_VLMULTA := xMoeda(If(Empty((cQry)->(E1_BAIXA)) .and. dDataBase > (cQry)->(E1_VENCREA), (cQry)->(E1_VLMULTA), (cQry)->(E1_MULTA)),(cQry)->(E1_MOEDA),1,dDataBase,,ntaxaM)						
				OtherWise							
					If !( (cQry)->(E1_TIPO)	$ MVABATIM )
						(cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
					Endif	
				EndCase
			Next nCntFor
			dbSelectArea(cAlias)
			If nTotAbat = 0
				If ( (cAlias)->E1_SALDO <= 0 )
					dbDelete()
				EndIf
			Endif						
			MsUnLock()
		EndIf
		dbSelectArea(cQry)
		dbSkip()				
	EndDo
	If ( lQuery )
		dbSelectArea(cQry)
		dbCloseArea()
	EndIf
	cOrdem := "DTOS(E1_VENCREA)"
				
	dbSelectArea(cAlias)
	IndRegua(cAlias,cArquivo,cOrdem)
	
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Totais da Consulta                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aGet[1] := 0
aGet[2] := 0
aGet[3] := 0
aGet[4] := 0
aGet[5] := 0
aGet[6] := 0
aGet[7] := 0
aGet[8] := 0
aTotRec := {{0,1,0,0}} // Totalizador de titulos a receber por moeda
(cAlias)->(DbGotop())
While !(cAlias)->(EOF())
 	aGet[1]++
	//Calcular o abatimento para visualização em tela
 	If (cAlias)->E1_ABT > 0
 		(cAlias)->E1_SALDO2 := xMoeda((cAlias)->E1_SALDO,(cAlias)->E1_MOEDA,1,dDataBase,,ntaxaM)
 	Endif		 	
 	
	aGet[2] += (cAlias)->E1_VLCRUZ
	aGet[3] += (cAlias)->E1_SALDO
	aGet[4] += (cAlias)->E1_VALJUR
	aGet[7] += (cAlias)->E1_ABT
	nAcresc := nDecres := 0
	nAcresc := xMoeda((cAlias)->E1_SDACRES,(cAlias)->E1_MOEDA,1,dDataBase,,ntaxaM)
	nDecres := xMoeda((cAlias)->E1_SDDECRE,(cAlias)->E1_MOEDA,1,dDataBase,,ntaxaM)
	aGet[5] += nAcresc
	aGet[6] += nDecres
	If MV_PAR07 == 1 //Saldo sem correcao
		aGet[8] += (cAlias)->E1_SALDO-(cAlias)->E1_ABT+(cAlias)->E1_VALJUR+nAcresc-nDecres
	Else
		aGet[8] += (cAlias)->E1_SALDO
	Endif
	(cAlias)->(DbSkip())
Enddo		 	

aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,0))
aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,nCasas))
aGet[3] := TransForm(aGet[3],Tm(aGet[3],16,nCasas))
aGet[4] := TransForm(aGet[4],Tm(aGet[4],16,nCasas))
aGet[5] := TransForm(aGet[5],Tm(aGet[5],16,nCasas))
aGet[6] := TransForm(aGet[6],Tm(aGet[6],16,nCasas))
aGet[7] := TransForm(aGet[7],Tm(aGet[7],16,nCasas))		
aGet[8] := TransForm(aGet[8],Tm(aGet[8],16,nCasas))	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe os dados Gerados                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
(cAlias)->(DbGotop())
If ( !(cAlias)->(EOF()) )
		
	aObjects := {} 
	AAdd( aObjects, { 100, 35,  .t., .f., .t. } )
	AAdd( aObjects, { 100, 100 , .t., .t. } )
	AAdd( aObjects, { 100, 50 , .t., .f. } )
	
	aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObj1 := MsObjSize( aInfo, aObjects) 
	
	DEFINE FONT oBold    NAME "Arial" SIZE 0, -12 BOLD

	DEFINE MSDIALOG oDlg FROM	aSize[7],0 TO aSize[6],aSize[5] TITLE cCadastro OF oMainWnd PIXEL
	@ aPosObj1[1,1], aPosObj1[1,2] MSPANEL oScrPanel PROMPT "" SIZE aPosObj1[1,3],aPosObj1[1,4] OF oDlg LOWERED

	@ 04,004 SAY OemToAnsi(STR0014) SIZE 025,07          OF oScrPanel PIXEL //"Codigo"
	@ 12,004 SAY SA1->A1_COD  SIZE 060,09  OF oScrPanel PIXEL FONT oBold
      
	@ 04,067 SAY OemToAnsi(STR0015) SIZE 020,07          OF oScrPanel PIXEL //"Loja"
	@ 12,067 SAY SA1->A1_LOJA SIZE 021,09 OF oScrPanel PIXEL FONT oBold

	@ 04,090 SAY OemToAnsi(STR0016) SIZE 025,07 OF oScrPanel PIXEL //"Nome"
	@ 12,090 SAY SA1->A1_NOME SIZE 165,09 OF oScrPanel PIXEL FONT oBold

	oGetDb:=MsGetDB():New(aPosObj1[2,1],aPosObj1[2,2],aPosObj1[2,3],aPosObj1[2,4],2,"",,,.F.,,,.F.,,cAlias,,,,,,.T.)
	oGetdb:lDeleta:=NIL
	dbSelectArea(cAlias)
	dbGotop()

	@ aPosObj1[3,1]+04,005 SAY aSay[1] SIZE 025,07 OF oDlg PIXEL
	@ aPosObj1[3,1]+04,175 SAY aSay[2] SIZE 025,07 OF oDlg PIXEL
	@ aPosObj1[3,1]+15,005 SAY aSay[3] SIZE 055,07 OF oDlg PIXEL
	@ aPosObj1[3,1]+15,175 SAY aSay[4] SIZE 025,07 OF oDlg PIXEL
	@ aPosObj1[3,1]+26,005 SAY aSay[5] SIZE 025,07 OF oDlg PIXEL
	@ aPosObj1[3,1]+26,175 SAY aSay[6] SIZE 025,07 OF oDlg PIXEL

	@ aPosObj1[3,1]+04,060 SAY aGet[1] SIZE 060,07 OF oDlg PIXEL
	@ aPosObj1[3,1]+04,215 SAY aGet[2] SIZE 060,07 OF oDlg PIXEL
	@ aPosObj1[3,1]+15,060 SAY aGet[3] SIZE 060,07 OF oDlg PIXEL
	@ aPosObj1[3,1]+15,215 SAY aGet[4] SIZE 060,07 OF oDlg PIXEL
	@ aPosObj1[3,1]+26,060 SAY aGet[5] SIZE 060,07 OF oDlg PIXEL
	@ aPosObj1[3,1]+26,215 SAY aGet[6] SIZE 060,07 OF oDlg PIXEL

	Lj851Legenda(oDlg,aPosObj1,aSay,aGet)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria botoes do menu 										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	@ aPosObj1[3,1]+20.5, aPosObj1[1,3]-180	BUTTON STR0027  SIZE 50, 12 OF oDlg PIXEL ACTION ( oDlg:End() ) //"OK"
	@ aPosObj1[3,1]+20.5, aPosObj1[1,3]-120	BUTTON STR0028 	SIZE 50, 12 OF oDlg PIXEL ACTION ( Lj851Excel(cAlias,aHeader) ) //"Exel"	
	@ aPosObj1[3,1]+20.5, aPosObj1[1,3]-60		BUTTON STR0002 	SIZE 50, 12 OF oDlg PIXEL ACTION ( Lj851Visua((cAlias)->XX_RECNO)  ) //"Visualizar"		

	ACTIVATE MSDIALOG oDlg
Else
	Help(" ",1,"REGNOIS")	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Integridade dos Dados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If( ValType(oTempTable) == "O")
  oTempTable:Delete()
  FreeObj(oTempTable)
  oTempTable := Nil
EndIf

RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSC9)
RestArea(aAreaSF4)
RestArea(aArea)
Return(aHeader)
			
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Fc010Legen³ Autor ³ Claudio Donizete Souza³ Data ³13.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe legenda de titulos baixados parcial ou totalmente     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function Lj851Legenda(oDlg,aPosObj1,aSay,aGet)
	@ aPosObj1[3,1]+37,005 SAY aSay[7] SIZE 035,07 OF oDlg PIXEL  //Total Geral
	@ aPosObj1[3,1]+37,060 SAY aGet[7] SIZE 060,07 OF oDlg PIXEL

	@ aPosObj1[3,1]+4, 300 BITMAP oBmp RESNAME "BR_AZUL" SIZE 16,16 NOBORDER OF oDlg PIXEL
	@ aPosObj1[3,1]+4, 310 SAY STR0017 OF oDlg PIXEL // "Baixado parcial"
			
	@ aPosObj1[3,1]+20.5, 300 BITMAP oBmp1 RESNAME "BR_VERDE" SIZE 16,16 NOBORDER OF oDlg PIXEL
	@ aPosObj1[3,1]+20.5, 310 SAY STR0018 OF oDlg PIXEL // "Sem baixas"

	@ aPosObj1[3,1]+37, 300 BITMAP oBmp RESNAME "BR_AMARELO" SIZE 16,16 NOBORDER OF oDlg PIXEL
	@ aPosObj1[3,1]+37, 310 SAY STR0019 OF oDlg PIXEL   //"Titulo c/ Cheque Devolvido"

Return Nil		
		
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj851Excel ³ Autor ³ Mauricio Pequim Jr   ³ Data ³ 31.03.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para exportatacao de dados para Excel               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpA2 : Array com as Descricoes do Cabecalho               ³±±
±±³          ³ ExpA3 : Array com os parametros (perguntes) da rotina      ³±±
±±³          ³ ExpN4 : Opcao executada                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj851Excel(cAlias,aHeader)

Local aItem			:= {}	// Array de Itens
Local aItenXCel		:= {}	// Array 
Local aStruD		:= {}	// Estrutura de
Local aStruX		:= {}	// Estrutura de
Local aArea			:= (cAlias)->(GetArea())   // Backup da Area
Local lLoja			:= .T.						// Loja
Local nDel			:= 0						// Se deleta
Local nX			:= 0						// Contador
Local cTexto		:= ""						// Texto para planilha

DEFAULT cAlias	:= "SE1"
DEFAULT aHeader:= {}

If Len(aHeader) > 0 

	cCliente := SA1->A1_COD + " - " + SA1->A1_LOJA + " - " + SA1->A1_NREDUZ

	
	If ! ApOleClient( 'MsExcel' ) 
		MsgAlert( STR0020)  //'MsExcel nao instalado'
	Else
		(cAlias)->(DbGoTop())
	
		//Montagem dos dados a serem exportados para Excel
		For nX := 1 to Len(aHeader)
			//------------------------------------
			//aHeader
			//01 AllTrim(X3Titulo())
			//02 SX3->X3_CAMPO
			//03 SX3->X3_PICTURE
			//04 SX3->X3_TAMANHO
			//05 SX3->X3_DECIMAL
			//06 SX3->X3_VALID
			//07 SX3->X3_USADO
			//08 SX3->X3_TIPO
			//09 SX3->X3_ARQUIVO
			//10 SX3->X3_CONTEXT
			//------------------------------------
	
			If !("XX_" $ aHeader[nX][2]) .and. !(If(lLoja,("_LOJA" $ aHeader[nX][2]),.F.))
				aADD(aStruD,{aHeader[nX][1],aHeader[nX][8],aHeader[nX][4],aHeader[nX][5]})
				aADD(aStruX,{aHeader[nX][2],aHeader[nX][8],aHeader[nX][4],aHeader[nX][5]})
			Endif
		Next
	
		AADD(aStruD,{"","C",1,0})
		AADD(aStruX,{"","C",1,0})
	
	
		WHILE (cAlias)->(!EOF())
	 						
			aItem := Array(Len(aStruX))
			For nX := 1 to Len(aStruX)
				IF nX == Len(aStruX)  // Coluna de compatibilizacao com a abertura no EXCEL
					aItem[nX] := CHR(160)
				ELSEIF aStruX[nX][2] == "C"
					aItem[nX] := CHR(160)+(cAlias)->&(aStruX[nX][1])
				ELSE
					aItem[nX] := (cAlias)->&(aStruX[nX][1])
				ENDIF
			Next nX 
			AADD(aItenXcel,aItem)
			aItem := {}
			(cAlias)->(dbSkip())
		Enddo
	
		cTexto := STR0021 +cCLiente //"Consulta Titulos em Aberto do Cliente - "
	
		MsgRun(STR0022, STR0023,{||DlgToExcel({{"GETDADOS",cTexto,aStruD,aItenXcel}})}) //"Favor Aguardar....."###"Exportando os Registros para o Excel"
	
	EndIf

Endif

RestArea(aArea)

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj851Visua³ Autor ³Vendas clientes		³ Data ³04/01/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de Visualizacao dos Títulos a Receber referente a    ³±±
±±³          ³Conta Corrente                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Lj851Visua()        						     			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1		: Recno do Arquivo principal                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA851													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj851Visua(nRecno)

Local aArea := GetArea()								// Backup da Area
Local aAreaSE1 := SE1->(GetArea())						// Backup do Se1
Local aSavAhead:= If(Type("aHeader")=="A",aHeader,{})	// Salva Cab
Local aSavAcol := If(Type("aCols")=="A",aCols,{})		// Saval linhas
Local nSavN    := If(Type("N")=="N",N,0)				// Salva linha da planilha
Local cFilBkp  := cFilAnt 								// Backup da filial

SE1->(MsGoto(nRecno))
// Modifica a filial para visualizacao atraves da funcao AxVisual
cFilAnt := IIf(cFilAnt <> SE1->E1_FILIAL .And. !Empty(cFilAnt),SE1->E1_FILIAL,cFilAnt)	
SE1->(AxVisual("SE1",nRecNo,2))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Integridade dos Dados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt := cFilBkp
aHeader := aSavAHead
aCols   := aSavACol
N       := nSavN

RestArea(aAreaSE1)
RestArea(aArea)
Return(.T.)	
