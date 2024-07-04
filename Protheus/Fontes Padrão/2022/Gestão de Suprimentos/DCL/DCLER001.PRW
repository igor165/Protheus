#INCLUDE "PROTHEUS.ch"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLER001()
Relatorio de Saldos Em Estoque por Almoxarifado, considerando a
Data do ultimo fechamento e movimentacoes ate data base
Adaptação da função TDCER001
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLER001()
Local nI		:= 0
Local aArea		:= GetArea()
Local cPerg		:= "CER001"

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

SetPrvt("_CAREA,_NREC,_CIND,TAMANHO,LIMITE,CDESC1")
SetPrvt("CDESC2,CDESC3,WNREL,NOMEPROG,NLASTKEY,CSTRING")
SetPrvt("ARETURN,LI,LCONTINUA,M_PAG")
SetPrvt("TITULO,_CCAB2,_ASTRUC,ATAM,OTEMPTABLE,ASUBTRAS")
SetPrvt("CQUERY,CABEC2,CABEC1,_CESSI,_TOTAL1,_TOTAL2")
SetPrvt("_TOTAL3,_TOTAL4,_TOTAL5,_TOTAL6,_TOTGER,ATOTPRO")
SetPrvt("ALMO,_DESCRI,_UN,_TOT1,_TOT2,_TOT3")
SetPrvt("_TOT4,_TOT5,_TOT6,NPOS,I,_SALIAS")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Variaveis utilizadas para parametros              ?
//?mv_par01  // Data Base                            ?
//?mv_par02  // De Cessionario                       ?
//?mv_par03  // Ate Cessionario                      ?
//?mv_par04  // Produto de                           ?
//?mv_par05  // Produto Ate.                         ?
//?mv_par06  // Imprime parametros                   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

Tamanho   := "M"
Limite    := 132
cDesc1    := PadC("Este programa tem como objetivo imprimir o relatorio de   ",74)
cDesc2    := PadC("Saldos em Estoque por Cessionario, partindo do ulimo fecha-",74)
cDesc3    := PadC("mento e considerando movimentacoes ate a data base. Par.01",74)
wnrel     := "CER001"
nomeprog  := "DCLER001"
nLastKey  :=  0
cString   := "SB1"
aReturn   := {"Branco",1,"Comercial",2,2,1,"",1}
li        :=  66
lContinua := .T.
m_pag     := 1

Pergunte(cPerg,.F.)

Titulo    := PadC("Estoque por Cessionario",74)

MV_PAR06 := GetMV("MV_ULMES")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Envia controle para a funcao SETPRINT                        ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//areturn[4]==formato
//areturn[5]==m?ia
//areturn[7]==filtro
//areturn[8]==ordem

//wnrel
// 8=.f.= desabilita dicionario de dados
// 9=mostra ordem
//10=comprimido/normal
//11=tamanho da letra
//12=habilita filtro

//m_pag:=1.1  NAO IMPRIME PAGINA DE PARAMETROS
wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.F.,Tamanho,.F.)

If nLastKey == 27
	RestArea(aArea)
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
	RestArea(aArea)
	Return
Endif
_cCab2:=""

//Impressao do dados
Processa({|| RunProc() }, "Processando")// Substituido pelo assistente de conversao do AP5 IDE em 21/01/01 ==>    Processa({|| Execute(RunProc) }, "Atualiza Notas Entrada")

RestArea(aArea)


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEE006()
Substituido pelo assistente de conversao do AP5 IDE em 21/01/01 ==>
Processa(|| Execute(RunProc) , "Atualiza Notas Entrada")
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RunProc()
Local nI	:= 0
Local aArea	:= GetArea()

//Cria Arquivo de Trabalho TRBD
_aStruc := {}

aTam := TamSX3("B2_COD")
AaDd(_aStruc,{ "COD" , "C" , aTam[1],aTam[2] })

aTam := TamSX3("B2_LOCAL")
AaDd(_aStruc,{ "LOCAL1" , "C" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "QINI" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "QENT" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "QSAI" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "QSB2" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "NSAI" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "NENT" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "ENTQ" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "SNTQ" , "N" , aTam[1],aTam[2] })

oTempTable := FWTemporaryTable():New("TRBD")
oTempTable:SetFields( _aStruc )
oTempTable:AddIndex("A", {"LOCAL1","COD"} )
oTempTable:Create()

aSubtraS:={}

//?GRAVA SALDO DE FECHAMENTO                     ?
DbSelectArea("SB9")
DbSetOrder(2)
IF SB9->(DbSeek(xFilial("SB9")+DTOS(MV_PAR06)))
	ProcRegua(RecCount())
	WHILE xFilial("SB9") == SB9->B9_FILIAL .AND. DTOS(SB9->B9_DATA) == DTOS(MV_PAR06) .AND. ! EOF()
		IncProc(" Processando Arquivo de Fechamento Estoque SB9")

		IF SB9->B9_LOCAL < MV_PAR02 .OR. SB9->B9_LOCAL > MV_PAR03;
			.OR. SB9->B9_COD < MV_PAR04 .OR. SB9->B9_COD > MV_PAR05
			DBSKIP()
			LOOP
		ENDIF

		DbSelectArea("TRBD")
		IF ! (TRBD->(DBSEEK(SB9->B9_LOCAL+SB9->B9_COD)))
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=SB9->B9_LOCAL
			TRBD->COD  :=SB9->B9_COD
			TRBD->QINI :=SB9->B9_QINI
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->QINI :=TRBD->QINI + SB9->B9_QINI
		ENDIF
		TRBD->(MSUNLOCK())
		DbSelectArea("SB9")
		SB9->(DBSKIP())
	ENDDO
ELSE
	MsgAlert("Nao Existe Fechamento na Data " + dtoc(mv_par06) + " Especificada  Verificar !!!")
	
	oTempTable:Delete()
	
	RestArea(aArea)
	RETURN
ENDIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Inicio da Apuracao das notas fiscais de saidas               ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF SUBSTR(RDDNAME(),1,6) <> 'DBFCDX'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?MONTA QUERY PARA CONSULTA SF2?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TMP1") > 0     // Verificando se o alias esta em uso
		DbSelectArea("TMP1")
		dbCloseArea()
	EndIf

	cQuery := "SELECT SD2.D2_LOCAL LOCAL1,SD2.D2_COD COD, SUM(SD2.D2_QUANT) QUANT "
	cQuery := cQuery + " FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SF4") + " SF4 "
	cQuery := cQuery + " WHERE SD2.D2_EMISSAO >= '" + DTOS(MV_PAR06 + 1) + "' AND "
	cQuery := cQuery + "       SD2.D2_EMISSAO <= '" + DTOS(MV_PAR01) + "' AND "
	cQuery := cQuery + "       SD2.D2_FILIAL  = '" + xFilial("SD2") + "' AND "
	cQuery := cQuery + "       SD2.D2_COD     >= '" + MV_PAR04 + "' AND "
	cQuery := cQuery + "       SD2.D2_COD     <= '" + MV_PAR05 + "' AND "
	cQuery := cQuery + "       SD2.D2_LOCAL   >= '" + MV_PAR02 + "' AND "
	cQuery := cQuery + "       SD2.D2_LOCAL   <= '" + MV_PAR03 + "' AND "
	cQuery := cQuery + "       SD2.D2_TES      = SF4.F4_CODIGO AND "
	cQuery := cQuery + "       SF4.F4_ESTOQUE  = 'S' AND "
	cQuery := cQuery + "       SD2.D_E_L_E_T_  <> '*' AND "
	cQuery := cQuery + "       SF4.D_E_L_E_T_  <> '*' "
	cQuery := cQuery + " GROUP BY SD2.D2_LOCAL,SD2.D2_COD "
	MEMOWRIT("TMP1.SQL",cQuery)
	TCQUERY cQuery NEW ALIAS "TMP1"

	DbSelectArea("TMP1")
	DBGOTOP()
	ProcRegua(Reccount())
	WHILE ! EOF()
		IncProc()
		DbSelectArea("TRBD")
		IF ! DBSEEK(TMP1->LOCAL1+TMP1->COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=TMP1->LOCAL1
			TRBD->COD  :=TMP1->COD
			TRBD->QSAI :=TMP1->QUANT
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->QSAI :=TRBD->QSAI + TMP1->QUANT
		ENDIF
		MSUNLOCK()
		DbSelectArea("TMP1")
		DBSKIP()
	ENDDO
ELSE
	DbSelectArea("SD2")
	DBSETORDER(5)
	ProcRegua(Reccount())
	DBSEEK(XFILIAL()+DTOS(MV_PAR06+1),.T.)
	WHILE ! EOF() .AND. SD2->D2_EMISSAO <= MV_PAR01 .AND. SD2->D2_FILIAL == xFilial("SD2")
		IncProc(" Processando Saidas ")
		IF SD2->D2_COD < MV_PAR04 .OR. SD2->D2_COD > MV_PAR05
			DBSKIP()
			LOOP
		ENDIF
		IF SD2->D2_LOCAL < MV_PAR02 .OR. SD2->D2_LOCAL > MV_PAR03
			DBSKIP()
			LOOP
		ENDIF
		IF (SF4->(DBSEEK(XFILIAL()+SD2->D2_TES))) .AND. SF4->F4_ESTOQUE == 'S'
		ELSE
			DBSKIP()
			LOOP
		ENDIF
		DbSelectArea("TRBD")
		IF ! DBSEEK(SD2->D2_LOCAL+SD2->D2_COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=SD2->D2_LOCAL
			TRBD->COD  :=SD2->D2_COD
			TRBD->QSAI :=SD2->D2_QUANT
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->QSAI :=TRBD->QSAI + SD2->D2_QUANT
		ENDIF
		MSUNLOCK()
		DbSelectArea("SD2")
		DBSKIP()
	ENDDO
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Inicio da Apuracao das notas fiscais nao baixadas            ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF SUBSTR(RDDNAME(),1,6) <> 'DBFCDX'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?MONTA QUERY PARA CONSULTA SF2?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TMP4") > 0     // Verificando se o alias esta em uso
		DbSelectArea("TMP4")
		dbCloseArea()
	EndIf

	cQuery := "SELECT SD2.D2_PEDIDO PEDIDO,SD2.D2_LOCAL LOCAL1,SD2.D2_COD COD, SD2.D2_QUANT QUANT "
	cQuery := cQuery + " FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SF4")+" SF4, "+RetSqlName("SD2")+" SD2 "
	cQuery := cQuery + " WHERE SF2.F2_EMISSAO >= '"+DTOS(MV_PAR06+1)+"' AND "
	cQuery := cQuery + "       SF2.F2_EMISSAO <= '"+DTOS(MV_PAR01)+"' AND "
	cQuery := cQuery + "       SF2.F2_FILIAL  = '"+xFilial("SF2")+"' AND "
	cQuery := cQuery + "( SF2.F2_EMISSAO > '"+DTOS(MV_PAR01)+"' OR SF2.F2_EMISSAO = '      ' ) AND "
	cQuery := cQuery + "       SF2.F2_FILIAL  = SD2.D2_FILIAL AND "
	cQuery := cQuery + "       SF2.F2_DOC     = SD2.D2_DOC AND "
	cQuery := cQuery + "       SF2.F2_SERIE   = SD2.D2_SERIE AND "
	cQuery := cQuery + "       SD2.D2_COD     >= '"+MV_PAR04+"' AND "
	cQuery := cQuery + "       SD2.D2_COD     <= '"+MV_PAR05+"' AND "
	cQuery := cQuery + "       SD2.D2_LOCAL   >= '"+MV_PAR02+"' AND "
	cQuery := cQuery + "       SD2.D2_LOCAL   <= '"+MV_PAR03+"' AND "
	cQuery := cQuery + "       SD2.D2_TES      = SF4.F4_CODIGO AND "
	cQuery := cQuery + "       SF4.F4_ESTOQUE  = 'S' AND "
	cQuery := cQuery + "       SD2.D_E_L_E_T_  <> '*' AND "
	cQuery := cQuery + "       SF4.D_E_L_E_T_  <> '*' AND "
	cQuery := cQuery + "       SF2.D_E_L_E_T_  <> '*' "
	//cQuery := cQuery + " GROUP BY SD2.D2_LOCAL,SD2.D2_COD "
	MEMOWRIT("TMP4.SQL",cQuery)
	TCQUERY cQuery NEW ALIAS "TMP4"

	DbSelectArea("TMP4")
	DBGOTOP()
	ProcRegua(Reccount())
	WHILE ! EOF()
		IncProc()
		DbSelectArea("TRBD")
		IF ! DBSEEK(TMP4->LOCAL1+TMP4->COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=TMP4->LOCAL1
			TRBD->COD  :=TMP4->COD
			TRBD->SNTQ :=TMP4->QUANT
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->SNTQ :=TRBD->SNTQ + TMP4->QUANT
		ENDIF
		MSUNLOCK()
		DbSelectArea("TMP4")
		DBSKIP()
	ENDDO
ELSE
	DbSelectArea("SD2")
	DBSETORDER(5)
	ProcRegua(Reccount())
	DBSEEK(XFILIAL()+DTOS(MV_PAR06+1),.T.)
	WHILE ! EOF() .AND. SD2->D2_EMISSAO <= MV_PAR01 .AND. SD2->D2_FILIAL == xFilial("SD2")
		IncProc(" Processando Saidas ")
		IF SD2->D2_COD < MV_PAR04 .OR. SD2->D2_COD > MV_PAR05
			DBSKIP()
			LOOP
		ENDIF
		IF SD2->D2_LOCAL < MV_PAR02 .OR. SD2->D2_LOCAL > MV_PAR03
			DBSKIP()
			LOOP
		ENDIF
		IF (SF4->(DBSEEK(XFILIAL()+SD2->D2_TES))) .AND. SF4->F4_ESTOQUE == 'S'
		ELSE
			DBSKIP()
			LOOP
		ENDIF
		SF2->(DBSETORDER(1))
		IF (SF2->(DBSEEK(XFILIAL()+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))) .AND. (SF2->F2_EMISSAO>MV_PAR01.OR.EMPTY(SF2->F2_EMISSAO))
		ELSE
			DBSKIP()
			LOOP
		ENDIF

		DbSelectArea("TRBD")
		IF ! DBSEEK(SD2->D2_LOCAL+SD2->D2_COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=SD2->D2_LOCAL
			TRBD->COD  :=SD2->D2_COD
			TRBD->SNTQ :=SD2->D2_QUANT
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->SNTQ :=TRBD->SNTQ + SD2->D2_QUANT
		ENDIF
		MSUNLOCK()
		DbSelectArea("SD2")
		DBSKIP()
	ENDDO

ENDIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?PROCESSAMENTO DAS ENTRADAS NAO BAIXADAS       ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
IF SUBSTR(RDDNAME(),1,6) <> 'DBFCDX'

	If Select("TMP5") > 0     // Verificando se o alias esta em uso
		DbSelectArea("TMP5")
		dbCloseArea()
	EndIf

	cQuery := "SELECT SD1.D1_TES TES,SD1.D1_LOCAL LOCAL1,SD1.D1_COD COD, SUM(SD1.D1_QUANT) QUANT "
	cQuery := cQuery + " FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF4")+" SF4 "
	cQuery := cQuery + " WHERE SD1.D1_DTDIGIT >= '"+DTOS(MV_PAR06+1)+"' AND "
	cQuery := cQuery + "       SD1.D1_DTDIGIT <= '"+DTOS(MV_PAR01)+"' AND "
	cQuery := cQuery + "       SD1.D1_FILIAL  = '"+xFilial("SD1")+"' AND "
	cQuery := cQuery + "       SD1.D1_COD     >= '"+MV_PAR04+"' AND "
	cQuery := cQuery + "       SD1.D1_COD     <= '"+MV_PAR05+"' AND "
	cQuery := cQuery + "       SD1.D1_LOCAL   >= '"+MV_PAR02+"' AND "
	cQuery := cQuery + "       SD1.D1_LOCAL   <= '"+MV_PAR03+"' AND "
	cQuery := cQuery + "       SD1.D1_TES      = SF4.F4_CODIGO AND "
	cQuery := cQuery + "       SD1.D1_X_ATUTQ  = 'N' AND "
	cQuery := cQuery + "       SF4.F4_ESTOQUE  = 'S' AND "
	cQuery := cQuery + "       SD1.D_E_L_E_T_  <> '*' AND "
	cQuery := cQuery + "       SF4.D_E_L_E_T_  <> '*' "
	cQuery := cQuery + " GROUP BY SD1.D1_TES,SD1.D1_LOCAL,SD1.D1_COD "

	MEMOWRIT("TMP5.SQL",cQuery)
	TCQUERY cQuery NEW ALIAS "TMP5"

	DbSelectArea("TMP5")
	DBGOTOP()
	ProcRegua(Reccount())
	WHILE ! EOF()
		IncProc()
		DbSelectArea("TRBD")
		IF ! DBSEEK(TMP5->LOCAL1+TMP5->COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=TMP5->LOCAL1
			TRBD->COD  :=TMP5->COD
			TRBD->ENTQ :=TMP5->QUANT
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->ENTQ :=TRBD->ENTQ + TMP5->QUANT
		ENDIF
		MSUNLOCK()
		DbSelectArea("TMP5")
		DBSKIP()
	ENDDO
ELSE
	DbSelectArea("SD1")
	DBSETORDER(6)
	ProcRegua(Reccount())
	DBSEEK(XFILIAL()+DTOS(MV_PAR06+1),.T.)
	WHILE ! EOF() .AND. SD1->D1_DTDIGIT <= MV_PAR01 .AND. SD1->D1_FILIAL == xFilial("SD1")
		IncProc(" Processando Entradas ")
		IF SD1->D1_COD < MV_PAR04 .OR. SD1->D1_COD > MV_PAR05
			DBSKIP()
			LOOP
		ENDIF

		IF SD1->D1_X_ATUTQ=='S'
			DBSKIP()
			LOOP
		ENDIF

		IF SD1->D1_LOCAL < MV_PAR02 .OR. SD1->D1_LOCAL > MV_PAR03
			DBSKIP()
			LOOP
		ENDIF
		IF (SF4->(DBSEEK(XFILIAL()+SD1->D1_TES))) .AND. SF4->F4_ESTOQUE == 'S'
		ELSE
			DBSKIP()
			LOOP
		ENDIF
		DbSelectArea("TRBD")
		IF ! DBSEEK(SD1->D1_LOCAL+SD1->D1_COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=SD1->D1_LOCAL
			TRBD->COD  :=SD1->D1_COD
			TRBD->ENTQ :=SD1->D1_QUANT
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->ENTQ :=TRBD->ENTQ + SD1->D1_QUANT
		ENDIF

		MSUNLOCK()
		DbSelectArea("SD1")
		DBSKIP()
	ENDDO

ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?PROCESSAMENTO DAS ENTRADAS                    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
IF SUBSTR(RDDNAME(),1,6) <> 'DBFCDX'
	If Select("TMP2") > 0     // Verificando se o alias esta em uso
		DbSelectArea("TMP2")
		dbCloseArea()
	EndIf

	cQuery := "SELECT SD1.D1_TES TES,SD1.D1_LOCAL LOCAL1,SD1.D1_COD COD, SUM(SD1.D1_QUANT) QUANT "
	cQuery := cQuery + " FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF4")+" SF4 "
	cQuery := cQuery + " WHERE SD1.D1_DTDIGIT >= '"+DTOS(MV_PAR06+1)+"' AND "
	cQuery := cQuery + "       SD1.D1_DTDIGIT <= '"+DTOS(MV_PAR01)+"' AND "
	cQuery := cQuery + "       SD1.D1_FILIAL  = '"+xFilial("SD1")+"' AND "
	cQuery := cQuery + "       SD1.D1_COD     >= '"+MV_PAR04+"' AND "
	cQuery := cQuery + "       SD1.D1_COD     <= '"+MV_PAR05+"' AND "
	cQuery := cQuery + "       SD1.D1_LOCAL   >= '"+MV_PAR02+"' AND "
	cQuery := cQuery + "       SD1.D1_LOCAL   <= '"+MV_PAR03+"' AND "
	cQuery := cQuery + "       SD1.D1_TES      = SF4.F4_CODIGO AND "
	cQuery := cQuery + "       SF4.F4_ESTOQUE  = 'S' AND "
	cQuery := cQuery + "       SD1.D_E_L_E_T_  <> '*' AND "
	cQuery := cQuery + "       SF4.D_E_L_E_T_  <> '*' "
	cQuery := cQuery + " GROUP BY SD1.D1_TES,SD1.D1_LOCAL,SD1.D1_COD "

	MEMOWRIT("TMP2.SQL",cQuery)
	TCQUERY cQuery NEW ALIAS "TMP2"

	DbSelectArea("TMP2")
	DBGOTOP()
	ProcRegua(Reccount())
	WHILE ! EOF()
		IncProc()
		DbSelectArea("TRBD")
		IF ! DBSEEK(TMP2->LOCAL1+TMP2->COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=TMP2->LOCAL1
			TRBD->COD  :=TMP2->COD
			TRBD->QENT :=TMP2->QUANT
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->QENT :=TRBD->QENT + TMP2->QUANT
		ENDIF
		MSUNLOCK()
		DbSelectArea("TMP2")
		DBSKIP()
	ENDDO
ELSE
	DbSelectArea("SD1")
	DBSETORDER(6)
	ProcRegua(Reccount())
	DBSEEK(XFILIAL()+DTOS(MV_PAR06+1),.T.)
	WHILE ! EOF() .AND. SD1->D1_DTDIGIT <= MV_PAR01 .AND. SD1->D1_FILIAL == xFilial("SD1")
		IncProc(" Processando Saidas ")
		IF SD1->D1_COD < MV_PAR04 .OR. SD1->D1_COD > MV_PAR05
			DBSKIP()
			LOOP
		ENDIF
		IF SD1->D1_LOCAL < MV_PAR02 .OR. SD1->D1_LOCAL > MV_PAR03
			DBSKIP()
			LOOP
		ENDIF
		IF (SF4->(DBSEEK(XFILIAL()+SD1->D1_TES))) .AND. SF4->F4_ESTOQUE == 'S'
		ELSE
			DBSKIP()
			LOOP
		ENDIF

		DbSelectArea("TRBD")
		IF ! DBSEEK(SD1->D1_LOCAL+SD1->D1_COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=SD1->D1_LOCAL
			TRBD->COD  :=SD1->D1_COD
			TRBD->QENT :=SD1->D1_QUANT
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->QENT :=TRBD->QENT + SD1->D1_QUANT
		ENDIF

		MSUNLOCK()
		DbSelectArea("SD1")
		DBSKIP()
	ENDDO

ENDIF
IF SUBSTR(RDDNAME(),1,6) <> 'DBFCDX'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?PROCESSAMENTO MOV. INTERNA                    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If Select("TMP3") > 0     // Verificando se o alias esta em uso
		DbSelectArea("TMP3")
		dbCloseArea()
	EndIf

	cQuery := "SELECT SD3.D3_TM TM,SD3.D3_LOCAL LOCAL1,SD3.D3_COD COD, SUM(SD3.D3_QUANT) QUANT "
	cQuery := cQuery + " FROM "+RetSqlName("SD3")+" SD3 "
	cQuery := cQuery + " WHERE SD3.D3_EMISSAO >= '"+DTOS(MV_PAR06+1)+"' AND "
	cQuery := cQuery + "       SD3.D3_EMISSAO <= '"+DTOS(MV_PAR01)+"' AND "
	cQuery := cQuery + "       SD3.D3_FILIAL  = '"+xFilial("SD3")+"' AND "
	cQuery := cQuery + "       SD3.D3_COD     >= '"+MV_PAR04+"' AND "
	cQuery := cQuery + "       SD3.D3_COD     <= '"+MV_PAR05+"' AND "
	cQuery := cQuery + "       SD3.D3_LOCAL   >= '"+MV_PAR02+"' AND "
	cQuery := cQuery + "       SD3.D3_LOCAL   <= '"+MV_PAR03+"' AND "
	cQuery := cQuery + "       SD3.D_E_L_E_T_  <> '*' "
	cQuery := cQuery + " GROUP BY SD3.D3_TM,SD3.D3_LOCAL,SD3.D3_COD "
	MEMOWRIT("TMP3.SQL",cQuery)
	TCQUERY cQuery NEW ALIAS "TMP3"

	DbSelectArea("TMP3")
	DBGOTOP()
	ProcRegua(Reccount())
	WHILE ! EOF()
		IncProc()
		DbSelectArea("TRBD")
		IF ! DBSEEK(TMP3->LOCAL1+TMP3->COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=TMP3->LOCAL1
			TRBD->COD  :=TMP3->COD
			IF TMP3->TM>"499"
				TRBD->QSAI :=TMP3->QUANT
			ELSE
				TRBD->QENT :=TMP3->QUANT
			ENDIF
		ELSE
			RECLOCK("TRBD",.F.)
			IF TMP3->TM>"499"
				TRBD->QSAI :=TRBD->QSAI + TMP3->QUANT
			ELSE
				TRBD->QENT :=TRBD->QENT + TMP3->QUANT
			ENDIF
		ENDIF

		MSUNLOCK()
		DbSelectArea("TMP3")
		DBSKIP()
	ENDDO
ELSE
	DbSelectArea("SD3")
	DBSETORDER(6)
	ProcRegua(Reccount())
	DBSEEK(XFILIAL()+DTOS(MV_PAR06+1),.T.)
	WHILE ! EOF() .AND. SD3->D3_EMISSAO <= MV_PAR01 .AND. SD3->D3_FILIAL == xFilial("SD3")
        IF SD3->D3_LOCAL < MV_PAR02 .OR. SD3->D3_LOCAL > MV_PAR03;
           .OR. SD3->D3_COD < MV_PAR04 .OR. SD3->D3_COD > MV_PAR05
           DBSKIP()
           LOOP
        ENDIF
		DbSelectArea("TRBD")
		IF ! DBSEEK(SD3->D3_LOCAL+SD3->D3_COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=SD3->D3_LOCAL
			TRBD->COD  :=SD3->D3_COD
			IF SD3->D3_TM>"499"
				TRBD->QSAI :=SD3->D3_QUANT
			ELSE
				TRBD->QENT :=SD3->D3_QUANT
			ENDIF
		ELSE
			RECLOCK("TRBD",.F.)
			IF SD3->D3_TM>"499"
				TRBD->QSAI :=TRBD->QSAI + SD3->D3_QUANT
			ELSE
				TRBD->QENT :=TRBD->QENT + SD3->D3_QUANT
			ENDIF
		ENDIF
		MSUNLOCK()
		DbSelectArea("SD3")
		DBSKIP()
	ENDDO
ENDIF

IF SUBSTR(RDDNAME(),1,6) <> 'DBFCDX'

	DbSelectArea("TMP1")
	dbCloseArea()

	DbSelectArea("TMP2")
	dbCloseArea()

	DbSelectArea("TMP3")
	dbCloseArea()

	DbSelectArea("TMP4")
	dbCloseArea()

	DbSelectArea("TMP5")
	dbCloseArea()
ENDIF

#IFDEF WINDOWS
	RptStatus({|| RptDetail()})
	RestArea(aArea)
	Return
	Static Function RptDetail()
		Local nI:=0
#ENDIF

Local lFiltro := .F.
Local aArea		:= GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?IMPRESSAO DOS DADOS FILTRADOS                                ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := "Abertura de Estoque por Cessionaria Para data de : "+DTOC(MV_PAR01+1)
cabec2:=""
Cabec1:="Local                     Produto                     Sd.Fiscal Dt.Base    Entr.Nao Baixadas   Saidas N.Baixadas  Sd.Fisico Dt.Base"
//XX - XXXXXXXXXXXXXXXXX    XXXX - XXXXXXXXXXXXXXXXXXXX   999,999,999,999     999,999,999,999   999,999,999,999      999,999,999,999            999,999,999,999        999,999,999,999
//1    6                    27     34                     57                  77                95                   116                 136    143


DbSelectArea("TRBD")
DBGOTOP()
_CESSI:=""
li:=60
_TOTAL1:=0
_TOTAL2:=0
_TOTAL3:=0
_TOTAL5:=0
_TOTGER:=0
aTotPro:={}
SetRegua(RecCount())
WHILE ! EOF()
	IF (TRBD->QINI+TRBD->QENT-TRBD->QSAI) < 1
		DBSKIP()
		LOOP
	ENDIF

	IncRegua()
	If li > 55
		li :=1
		cabec(titulo,Cabec1,cabec2,nomeprog,tamanho)
		LI:=li+1
	EndIf

	DbSelectArea("D35")
	DBSETORDER(1)
	IF DBSEEK(XFILIAL()+TRBD->LOCAL1)
	   _CESSI:=D35->D35_NREDUZ
	ELSE
	   _CESSI:=""
	ENDIF

	DbSelectArea("TRBD")
	@LI,00 PSAY TRBD->LOCAL1+"- "+_CESSI
	ALMO:=TRBD->LOCAL1

	WHILE ALMO==TRBD->LOCAL1 .AND. ! EOF()
		SB1->(DBSEEK(XFILIAL()+TRBD->COD))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Validacao do filtro do usuario (SB1)	                               ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aReturn[7]) .And. ! SB1->( &(aReturn[7]) )
			lFiltro := .T.
		EndIf

		If !lFiltro
			DbSelectArea("TRBD")
			If li > 55
				li :=1
				cabec(titulo,Cabec1,cabec2,nomeprog,tamanho)
				LI:=li+1
				@LI,00 PSAY TRBD->LOCAL1+"/"+_CESSI
			EndIf

			@LI,027 PSAY ALLTRIM(TRBD->COD)+" - "+ALLTRIM(SUBSTR(SB1->B1_DESC,1,20))
			@LI,057 PSAY (TRBD->QINI+TRBD->QENT-TRBD->QSAI) PICTURE "@E 999,999,999,999"
			@LI,077 PSAY TRBD->ENTQ    PICTURE "@E 999,999,999,999"
			@LI,095 PSAY TRBD->SNTQ    PICTURE "@E 999,999,999,999"
			@LI,116 PSAY (TRBD->QINI+TRBD->QENT-TRBD->QSAI) - TRBD->ENTQ + TRBD->SNTQ PICTURE "@E 999,999,999,999"

			_TOTAL1:=_TOTAL1+(TRBD->QINI+TRBD->QENT-TRBD->QSAI)
			_TOTAL2:=_TOTAL2+TRBD->ENTQ
			_TOTAL3:=_TOTAL3+TRBD->SNTQ
			_TOTAL5:=_TOTAL5+(TRBD->QINI+TRBD->QENT-TRBD->QSAI) - TRBD->ENTQ + TRBD->SNTQ

			_TOT1:=(TRBD->QINI+TRBD->QENT-TRBD->QSAI)
			_TOT2:=TRBD->ENTQ
			_TOT3:=TRBD->SNTQ
			_TOT5:=(TRBD->QINI+TRBD->QENT-TRBD->QSAI) - TRBD->ENTQ + TRBD->SNTQ

			nPos := aScan(aTotPro,{ |X| X[1] == TRBD->COD })
			if nPos == 0
				Aadd(aTotPro,{TRBD->COD,SB1->B1_DESC,_TOT1,_TOT2,_TOT3,_TOT5})
			else
				aTotPro[nPos,3] := aTotPro[nPos,3] + _TOT1
				aTotPro[nPos,4] := aTotPro[nPos,4] + _TOT2
				aTotPro[nPos,5] := aTotPro[nPos,5] + _TOT3
				aTotPro[nPos,6] := aTotPro[nPos,6] + _TOT5
			Endif

			_TOT1:=0
			_TOT2:=0
			_TOT3:=0
			_TOT5:=0
			LI:=li+1
		EndIf

		lFiltro := .F.
		DbSelectArea("TRBD")
		DBSKIP()
	ENDDO

	LI:=li+1
	@LI,27  PSAY "TOTAL"
	@LI,57  PSAY _TOTAL1 PICTURE "@E 999,999,999,999"
	@LI,77  PSAY _TOTAL2 PICTURE "@E 999,999,999,999"
	@LI,95  PSAY _TOTAL3 PICTURE "@E 999,999,999,999"
	@LI,116 PSAY _TOTAL5 PICTURE "@E 999,999,999,999"
	_TOTAL1:=0
	_TOTAL2:=0
	_TOTAL3:=0
	_TOTAL5:=0
	LI:=li+2
ENDDO

@li,000 PSAY "Totais"
for nI := 1 to len(aTotPro)
	@LI,10  PSAY ALLTRIM(SUBSTR(aTotPro[nI,1],1,10)+" - "+ALLTRIM(aTotPro[nI,2]))
	@LI,57  PSAY aTotPro[nI,3] PICTURE "@E 999,999,999,999"
	@LI,77  PSAY aTotPro[nI,4] PICTURE "@E 999,999,999,999"
	@LI,95  PSAY aTotPro[nI,5] PICTURE "@E 999,999,999,999"
	@LI,116 PSAY aTotPro[nI,6] PICTURE "@E 999,999,999,999"
	LI := li + 1
next
LI:=li+1

Roda(0," ",Tamanho)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Deleta arquivos temporarios e Retorna Indices   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

Set device to Screen
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Se em disco, desvia para Spool                                            ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif
ms_flush()

oTempTable:Delete()

RestArea(aArea)

RETURN