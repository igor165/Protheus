#INCLUDE "FINR222.CH"
#INCLUDE "PROTHEUS.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Finr222	³ Autor ³ José Lucas                  ³ Data ³ 26.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Recebimentos recusados pela Administradora de CC.		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                 ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±± PROGRAMADOR ³ DATA   ³    BOPS    ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   Marco A. ³16/04/18³ DMINA-2310 ³Se remueven sentencias CriaTrab y se apli-³±±
±±³            ³        ³            ³ca FWTemporaryTable(), para el manejo de  ³±±
±±³            ³        ³            ³las tablas temporales.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINR222()

	Private dFinalA		:= CtoD("  /  /  ")
	Private dFinal		:= CtoD("  /  /  ")
	Private nomeprog	:= "FINR222"
	Private dPeriodo0	:= CtoD("  /  /  ")
	Private oReport		:= Nil
	
	If TRepInUse()
		FINR222R4()
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FINR222R4 ³ Auto ³ José Lucas            ³ Data ³ 08.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Informe de Declaración de Retención de Impuesto de Rentas. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINR222R4												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FINR222R4()

	Private cPerg := "FIN222"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte( cPerg, .F. )
	
	oReport := ReportDef()
	
	If VALTYPE( oReport ) == "O"
		oReport :PrintDialog()
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ José Lucas            ³ Data ³ 08.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao tem como objetivo definir as secoes, celulas,   ³±±
±±³          ³totalizadores do relatorio que poderao ser configurados     ³±±
±±³          ³pelo relatorio.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local aArea	   	:= GetArea()
Local CREPORT	:= "FINR222"
Local CTITULO	:= OemToAnsi(STR0001)				// TITULOS A RECEBER RECUSADOS
Local CDESC		:= OemToAnsi(STR0002) + ; 			//"Este programa  irá imprimir o relatório de Titulos"
	   			   OemToAnsi(STR0003) + ;			//"a Receber que tiveram os pagamentos recusados pela"
	   			   OemToAnsi(STR0004) 				//"Administradora de Cartões de Crédito."

Local aTamPrefix := TamSX3("FRB_PREFIX")
Local aTamTitulo := TamSX3("FRB_NUM")
Local aTamParcel := TamSX3("FRB_PARCEL")
Local aTamTipo	 := TamSX3("FRB_TIPO")
Local aTamClient := TamSX3("FRB_CLIENT")
Local aTamLoja   := TamSX3("FRB_LOJA")
Local aTamStatus := TamSX3("FRB_STATUS")
Local aTamMotivo := TamSX3("FRB_MOTIVO")
Local aTamCartao := TamSX3("FRB_NUMCAR")
Local aTamValid  := TamSX3("FRB_DATVAL")
Local aTamAdmin  := TamSX3("AE_DESC")
Local aTamValor  := TamSX3("FRB_VALOR")
Local aTamValRec := TamSX3("FRB_VALREC")

cTitulo	:= OemToAnsi(STR0001)	//Titulos a Receber Recusados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport	:= TReport():New( cReport,cTitulo,cPerg, { |oReport| Pergunte(cPerg , .F. ), If(! ReportPrint( oReport )  , oReport:CancelPrint(), .T. ) }, cDesc )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New( oReport, STR0001, {"TRB"},, .F., .F. )
TRCell():New( oSection1, "PREFIXO"	,"",STR0005				/*Titulo*/,/*Picture*/,aTamPrefix[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "TITULO"	,"",STR0006				/*Titulo*/,/*Picture*/,aTamTitulo[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "PARCELA"	,"",STR0007				/*Titulo*/,/*Picture*/,aTamParcel[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CLIENTE"	,"",STR0008				/*Titulo*/,/*Picture*/,aTamClient[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "LOJA"		,"",STR0009				/*Titulo*/,/*Picture*/,aTamLoja[1]			/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "STATUS"	,"",STR0010				/*Titulo*/,/*Picture*/,aTamStatus[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "MOTIVO"	,"",STR0011				/*Titulo*/,/*Picture*/,aTamMotivo[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CARTAO"	,"",STR0012				/*Titulo*/,/*Picture*/,aTamCartao[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "VALIDADE"	,"",STR0013				/*Titulo*/,/*Picture*/,aTamValid[1]			/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "ADMINIST"	,"",STR0014				/*Titulo*/,/*Picture*/,aTamAdmin[1]			/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "VALOR"	,"",STR0015				/*Titulo*/,/*Picture*/,aTamValor[1]+aTamValor[2]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "VALREC"	,"",STR0016				/*Titulo*/,/*Picture*/,aTamValRec[1]+aTamValRec[2]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
oSection1:SetHeaderPage()
oSection1:SetTotalInLine(.F.)

oSection2 := TRSection():New( oReport, STR0001, {"TRB"},, .F., .F. )
TRCell():New( oSection2, "PREFIXO"	,"",STR0005				/*Titulo*/,/*Picture*/,aTamPrefix[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "TITULO"	,"",STR0006				/*Titulo*/,/*Picture*/,aTamTitulo[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "PARCELA"	,"",STR0007				/*Titulo*/,/*Picture*/,aTamParcel[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "CLIENTE"	,"",STR0008				/*Titulo*/,/*Picture*/,aTamClient[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "LOJA"		,"",STR0009				/*Titulo*/,/*Picture*/,aTamLoja[1]			/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "STATUS"	,"",STR0010				/*Titulo*/,/*Picture*/,aTamStatus[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "MOTIVO"	,"",STR0011				/*Titulo*/,/*Picture*/,aTamMotivo[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "CARTAO"	,"",STR0012				/*Titulo*/,/*Picture*/,aTamCartao[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "VALIDADE"	,"",STR0013				/*Titulo*/,/*Picture*/,aTamValid[1]			/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "ADMINIST"	,"",STR0014				/*Titulo*/,/*Picture*/,aTamAdmin[1]			/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "VALOR"	,"",STR0015				/*Titulo*/,/*Picture*/,aTamValor[1]+aTamValor[2]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection2, "VALREC"	,"",STR0016				/*Titulo*/,/*Picture*/,aTamValRec[1]+aTamValRec[2]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
oSection2:SetTotalInLine(.F.)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ José Lucas           ³ Data ³ 08.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o relatorio definido pelo usuario de acordo com as  ³±±
±±³          ³secoes/celulas criadas na funcao ReportDef definida acima.  ³±±
±±³          ³Nesta funcao deve ser criada a query das secoes se SQL ou   ³±±
±±³          ³definido o relacionamento e filtros das tabelas em CodeBase.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportPrint(oReport)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPO1: Objeto do relatório                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport )

Local oSection1		:= oReport:Section(1)
Local oSection2		:= oReport:Section(2)
Local lin			:= 3001
Local cArqTmp		:= ""
Local cPicture		:= ""
Local lFirstPage	:= .T.
Local nTraco		:= 0
Local nSaldo		:= 0
Local nTamLin		:= 2350
Local aPosCol		:= { 1740, 2045 }
Local nPosCol		:= 0
Local lTotGeral		:= .F.
Local cAliasFRB		:= "FRB"
Local aCampos		:= {}
Local aTamPrefix	:= TamSX3("FRB_PREFIX")
Local aTamTitulo	:= TamSX3("FRB_NUM")
Local aTamParcel	:= TamSX3("FRB_PARCEL")
Local aTamTipo		:= TamSX3("FRB_TIPO")
Local aTamClient	:= TamSX3("FRB_CLIENT")
Local aTamLoja		:= TamSX3("FRB_LOJA")
Local aTamStatus	:= TamSX3("FRB_STATUS")
Local aTamMotivo	:= TamSX3("FRB_MOTIVO")
Local aTamCartao	:= TamSX3("FRB_NUMCAR")
Local aTamValid		:= TamSX3("FRB_DATVAL")
Local aTamAdmin		:= TamSX3("AE_DESC")
Local aTamValor		:= TamSX3("FRB_VALOR")
Local aTamValRec	:= TamSX3("FRB_VALREC")
Local aOrdem		:= {}	

Local dDataIni		:= mv_par01
Local dDataFinal	:= mv_par02
Local cClientIni	:= mv_par03
Local cClientFim	:= mv_par04
Local cAdminIni		:= mv_par05
Local cAdminFim		:= mv_par06

Local nTotValor		:= 0.00
Local nTotValRec	:= 0.00
Local aPicture		:= Array(4)

Private oTmpTable	:= Nil

aPicture[1] := PesqPict("FRB","FRB_NUMCAR", 19)
aPicture[2] := PesqPict("FRB","FRB_DATVAL", 05)
aPicture[3] := PesqPict("FRB","FRB_VALOR" , 17)
aPicture[4] := PesqPict("FRB","FRB_VALREC", 17)

AADD(aCampos,{"PREFIXO" ,"C",aTamPrefix[1],0})
AADD(aCampos,{"TITULO"  ,"C",aTamTitulo[1],0})
AADD(aCampos,{"PARCELA" ,"C",aTamParcel[1],0})
AADD(aCampos,{"TIPO"    ,"C",aTamTipo[1],0})
AADD(aCampos,{"CLIENTE" ,"C",aTamClient[1],0})
AADD(aCampos,{"LOJA"    ,"C",aTamLoja[1],0})
AADD(aCampos,{"STATUS"  ,"C",aTamStatus[1],0})
AADD(aCampos,{"MOTIVO"  ,"C",aTamMotivo[1],0})
AADD(aCampos,{"CARTAO"  ,"C",aTamCartao[1],0})
AADD(aCampos,{"VALIDADE","C",aTamValid[1],0})
AADD(aCampos,{"ADMINIST","C",aTamAdmin[1],0})
AADD(aCampos,{"VALOR"   ,"N",aTamValor[1],aTamValor[2]})
AADD(aCampos,{"VALREC"  ,"N",aTamValRec[1],aTamValRec[2]})

If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
	cPicture := ""
Endif

dbSelectArea("FRB")
dbSelectArea("FR0")

If Select("TRB") > 0
	TRB->(dbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Gera arquivo temporario          |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aOrdem := {"PREFIXO", "TITULO", "PARCELA", "TIPO", "CLIENTE", "LOJA"}

oTmpTable := FWTemporaryTable():New("TRB")
oTmpTable:SetFields(aCampos)
oTmpTable:AddIndex("I1", aOrdem)

oTmpTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | FINR222Ger(oMeter,oText,oDlg,@lEnd,cArqTmp,dDataIni,dDataFinal,cClientIni,cClientFim,cAdminIni,cAdminFim)},STR0018, STR0001) //"Criando Arquivo Temporario..."

dbSelectArea("TRB")
TRB->(DBSetOrder(1))
TRB->(dbGoTop())

oReport:SetMeter( RecCount() )

oReport:SetPageNumber(1)

While !Eof() .And. !oReport:Cancel()

	If oReport:Cancel()
		Exit
	EndIf

	oReport:IncMeter()

	oSection1:Cell("PREFIXO" ):SetBlock( { || If(TRB->PREFIXO=="ZZZ","TOTAL:",If(TRB->PREFIXO=="ZZX","",TRB->PREFIXO)) } )
 	oSection1:Cell("TITULO"  ):SetBlock( { || TRB->TITULO   } )
	oSection1:Cell("PARCELA" ):SetBlock( { || TRB->PARCELA  } )
	oSection1:Cell("CLIENTE" ):SetBlock( { || TRB->CLIENTE  } )
	oSection1:Cell("LOJA"	 ):SetBlock( { || TRB->LOJA	    } )
	oSection1:Cell("STATUS"	 ):SetBlock( { || TRB->STATUS   } )
	oSection1:Cell("MOTIVO"	 ):SetBlock( { || TRB->MOTIVO   } )
	oSection1:Cell("CARTAO"	 ):SetBlock( { || Transform(TRB->CARTAO,aPicture[1])} )
	oSection1:Cell("VALIDADE"):SetBlock( { || If(Empty(TRB->VALIDADE),"",Transform(TRB->VALIDADE,aPicture[2])) } )
	oSection1:Cell("ADMINIST"):SetBlock( { || TRB->ADMINIST } )
	oSection1:Cell("VALOR"	 ):SetBlock( { || If(TRB->PREFIXO=="ZZX","",Transform(TRB->VALOR,aPicture[3])) } )
	oSection1:Cell("VALREC"	 ):SetBlock( { || If(TRB->PREFIXO=="ZZX","",Transform(TRB->VALREC,aPicture[4]))  } )

	oSection1:Init()
 	oSection1:Print()
 	oSection1:Finish()

	TRB->(dbSkip())
End

If oTmpTable <> Nil
	oTmpTable:Delete()
	oTmpTable := Nil
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FINR222Ger³ Autor ³ José Lucas              ³ Data ³ 26.04.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processar Query e gerar arquivo de trabalho.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FINR222Ger(oMeter,oText,oDlg,lEnd,cArqTmp,dDataIni,dDataFinal)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                        ³±±
±±³          ³ ExpC1 = Descricao da moeda sendo impressa                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FINR222Ger(oMeter,oText,oDlg,lEnd,cArqTmp,dDataIni,dDataFinal,cClientIni,cClientFim,cAdminIni,cAdminFim)
Local aArea      := GetArea()
Local cQuery     := ""
Local cFiltro    := ""
Local aTamValor  := TamSX3("FRB_VALOR")
Local aTamValRec := TamSX3("FRB_VALREC")
Local nTotValor  := 0.00
Local nTotValRec := 0.00

cFiltro := ""

//Variaveis para atualizar a regua desde as rotinas de geracao do arquivo temporario
Private oMeter1 	:= oMeter
Private oText1 		:= oText

#IFDEF TOP
	If Select( "QRYFRB" ) > 0
		dbSelectArea( "QRYFRB" )
		QRYFRB->( dbCloseArea() )
	Endif

	cQuery := "SELECT DISTINCT "
	cQuery += "FRB_PREFIX, "
	cQuery += "FRB_NUM, "
	cQuery += "FRB_PARCEL, "
	cQuery += "FRB_TIPO, "
	cQuery += "FRB_CLIENT, "
	cQuery += "FRB_LOJA, "
	cQuery += "FRB_STATUS, "
	cQuery += "FRB_MOTIVO, "
	cQuery += "FRB_NUMCAR, "
	cQuery += "FRB_DATVAL, "
	cQuery += "AE_DESC, "
	cQuery += "FRB_VALOR, "
	cQuery += "FRB_VALREC "
	cQuery += " FROM "
	cQuery += RetSqlName("FRB") + " FRB, "
	cQuery += RetSqlName("SAE") + " SAE "
	cQuery += " WHERE FRB.FRB_FILIAL = '"+xFilial("FRB")+"' "
	cQuery += "  AND FRB.FRB_DATTEF BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFinal) + "' "
	cQuery += "  AND FRB.FRB_CLIENT BETWEEN '" + cClientIni + "' AND '" + cClientFim + "' "
	cQuery += "  AND FRB.FRB_CODADM BETWEEN '" + cAdminIni + "' AND '" + cAdminFim + "' "
	cQuery += "  AND FRB.FRB_CODADM = SAE.AE_COD "
	cQuery += "  AND FRB.FRB_STATUS IN ('03','04') "
	cQuery += "	 AND FRB.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYFRB",.T.,.F.)

	TcSetField( "QRYFRB", "FRB_VALOR" 	, "N", aTamValor[1]	, aTamValor[2] )
	TcSetField( "QRYFRB", "FRB_VALREC" 	, "N", aTamValRec[1], aTamValRec[2] )
#ELSE
	cFiltro := "FRB_FILIAL = xFilial('FRB') "
	cFiltro += ".and. FRB_DATTEF >= DTOS(dDataIni) .and. FRB_DATREF <= DTOS(dDataFinal) "
	cFiltro += ".and. FRB_CLIENT >= cClientIni .and. FRB_CLIENT <= cClientFim "
	cFiltro += ".and. FRB_CODADM >= cAdminIni .and. FRB_CODADM <= cAdminFim "
	cFiltro += ".and. FRB_STATUS $ '03|04' "
	cFiltro += ".and. FRB_CODADM == SAE.AE_COD "
#ENDIF

dbSelectArea("QRYFRB")
dbGoTop()

While ! QRYFRB->(Eof())

	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	TRB->PREFIXO  := QRYFRB->FRB_PREFIX
	TRB->TITULO   := QRYFRB->FRB_NUM
	TRB->PARCELA  := QRYFRB->FRB_PARCEL
	TRB->TIPO	  := QRYFRB->FRB_TIPO
	TRB->CLIENTE  := QRYFRB->FRB_CLIENT
	TRB->LOJA	  := QRYFRB->FRB_LOJA
	TRB->STATUS   := QRYFRB->FRB_STATUS
	TRB->MOTIVO   := QRYFRB->FRB_MOTIVO
	TRB->CARTAO   := QRYFRB->FRB_NUMCAR
	TRB->VALIDADE := QRYFRB->FRB_DATVAL
	TRB->ADMINIST := QRYFRB->AE_DESC
	TRB->VALOR    := QRYFRB->FRB_VALOR
	TRB->VALREC   := QRYFRB->FRB_VALREC
	MsUnLock()
	nTotValor += QRYFRB->FRB_VALOR
	nTotValRec += QRYFRB->FRB_VALREC
	QRYFRB->(dbSkip())
End
If nTotValor > 0
	RecLock("TRB",.T.)
	TRB->PREFIXO  := "ZZX"
	TRB->VALOR    := 0.00
	TRB->VALREC   := 0.00
	MsUnLock()

	RecLock("TRB",.T.)
	TRB->PREFIXO  := "ZZZ"
	TRB->VALOR    := nTotValor
	TRB->VALREC   := nTotValRec
	MsUnLock()
EndIf
RestArea(aArea)
Return