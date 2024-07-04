#INCLUDE "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 17/01/01
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLER004()
Relatorio de Saldos Em Estoque por Almoxarifado, considerando
Data do ultimo fechamento e movimentacoes ate data base
Adaptação da função TDCER004
@author Antonio Cordeiro
@since 01/12/1999
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLER004()
Local I:=0, J:=0
Local nTamSX1   := Len(SX1->X1_GRUPO)

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CAREA,_NREC,_CIND,ATANQUE,TAMANHO,LIMITE")
SetPrvt("CDESC1,CDESC2,CDESC3,WNREL,NOMEPROG,NLASTKEY")
SetPrvt("CSTRING,ARETURN,LI,LCONTINUA,M_PAG,APERG")
SetPrvt("CPERG,TITULO,_CCAB2,_ASTRUC,ATAM")
SetPrvt("_FATOR,_HORA,_PERC,_DATA")
SetPrvt("_SALDO,NPOS,CABEC1,CABEC2,_CESSI,_TOTAL1")
SetPrvt("_TOTAL2,_TOTAL3,_TOTAL4,_TOTAL5,_TOTAL6,_TOTGER")
SetPrvt("ATOTPRO,ALMO,_DESCRI,_UN,TOT1,TOT2")
SetPrvt("TOT3,TOT4,TOT5,TOT6,TOT7,TOT8")
SetPrvt("TOT9,TOT10,TOT11,TOT12,TOT13,TOT14")
SetPrvt("TOT15,I,_SALIAS,AREGS,J,")

Private m_pag := 01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos Arqquivos.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cArea     := Alias()
_nRec      := Recno()
_cInd      := IndexOrd()
aTanque:={}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Vari veis Parametros                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas para parƒmetros              ³
//³ mv_par01  // Data Base                            ³
//³ mv_par02  // De Cessionario                       ³
//³ mv_par03  // Ate Cessionario                      ³
//³ mv_par04  // Produto de                           ³
//³ mv_par05  // Produto Ate.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Tamanho   := "G"
Limite    := 220
cDesc1    := PadC("Este programa tem como objetivo imprimir o relatorio de   ",74)
cDesc2    := PadC("Saldos em Estoque por Cessionario, partindo do ulimo fecha-",74)
cDesc3    := PadC("mento e considerando movimentacoes ate a data base. Par.01",74)
wnrel     := "CERR004"
nomeprog  := "DCLER004"
nLastkey  :=  0
cString   := "SD2"
aReturn   := {"Branco",1,"Comercial",2,2,1,"",1}
li        :=  66
lContinua := .T.
If !SuperGetMV("MV_DCLNEW",.F.,.F.)
	_cPerg    :="CERR004"
	
	pergunte(_cPerg,.F.)
	
	titulo := "Mapa Demonstrativo de Estoque por Cessionaria Para data de : " + DTOC(MV_PAR01)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//areturn[4]==formato
	//areturn[5]==m¡dia
	//areturn[7]==filtro
	//areturn[8]==ordem
	
	//wnrel
	// 8=.f.= desabilita dicionario de dados
	// 9=mostra ordem
	//10=comprimido/normal
	//11=tamanho da letra
	//12=habilita filtro
	
	//m_pag:=1.1  NAO IMPRIME PAGINA DE PARAMETROS
	
	wnrel := SetPrint(cString,wnrel,_cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho,,.F.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif
	_cCab2:=""
	//      ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//      ³ ImpressÆo do dados.                                      ³
	//      ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Processa({|| RunProc() }, "Processa")

EndIf

return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} RunProc
@author Antonio Cordeiro
@since 01/12/1999
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RunProc()
Local oTempTable:= NIL
Local cQuery	:= ""
Local lContinua	:= .T.

//Cria Arquivo de Trabalho TRB ³
_aStruc := {}

aTam := TamSX3("B2_COD")
AaDd(_aStruc,{ "COD" , "C" , aTam[1],aTam[2] })

aTam := TamSX3("B2_LOCAL")
AaDd(_aStruc,{ "LOCAL1" , "C" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "QINI" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "QENTF" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "QENTB" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "QSAIF" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "QSAIB" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "OENT" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "OSAI" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "EQ_R" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "EQ_D" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "BO_R" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "BO_D" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "DE_R" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "DE_D" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "PR_R" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "PR_D" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "AP_R" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "AP_D" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "TR_R" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "TR_D" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "Q022" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "SNTQ" , "N" , aTam[1],aTam[2] })

aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "NCONT" , "N" , aTam[1],aTam[2] })

oTempTable := FWTemporaryTable():New("TRBD")
oTempTable:SetFields( _aStruc )
oTempTable:AddIndex("A", {"LOCAL1","COD"} )
oTempTable:Create()

//³ GRAVA SALDO DE FECHAMENTO                     ³
DBSELECTAREA("SB9")
SB9->(DbSetOrder(2))
IF SB9->(DbSeek(xFilial("SB9") + DTOS(MV_PAR06)))
	ProcRegua(RecCount())
	WHILE xFilial("SB9") == SB9->B9_FILIAL .AND. DTOS(SB9->B9_DATA) == DTOS(MV_PAR06) .AND. ! EOF()
		IncProc(" Processando Arquivo de Fechamento Estoque SB9")
		SB1->(DBSEEK(xFilial("SB1")+SB9->B9_COD))
		IF SB9->B9_LOCAL < MV_PAR02 .OR. SB9->B9_LOCAL > MV_PAR03;
			.OR. SB9->B9_COD < MV_PAR04 .OR. SB9->B9_COD > MV_PAR05 .or. !FiltrarDBF(SB9->B9_COD)
			DBSKIP()
			LOOP
		ENDIF
		
		DBSELECTAREA("TRBD")
		IF ! DBSEEK(SB9->B9_LOCAL+SB9->B9_COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=SB9->B9_LOCAL
			TRBD->COD  := SB9->B9_COD
			TRBD->QINI := SB9->B9_QINI
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->QINI :=TRBD->QINI + SB9->B9_QINI
		ENDIF
		MSUNLOCK()
		DBSELECTAREA("SB9")
		DBSKIP()
	ENDDO
ELSE
	MsgAlert("Nao Existe Fechamento na Data " + dtoc(MV_PAR06) + " Especificada  Verificar !!!")
	lContinua := .F.
ENDIF

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio da Apuracao das notas fiscais de saidas               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MONTA QUERY PARA CONSULTA SF2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TEMP1") > 0     // Verificando se o alias esta em uso
		dbSelectArea("TEMP1")
		dbCloseArea()
	EndIf

	cQuery := "SELECT SF2.F2_EMISSAO EMISSAO,SF2.F2_EMISSAO DATA1, "
	cQuery += " SD2.D2_LOCAL LOCAL1,SD2.D2_COD COD, SUM(SD2.D2_QUANT) QUANT, "
	cQuery += " SUM(DH3.DH3_QTD1) QTD1, SUM(DH3.DH3_QTD2) QTD2, SUM(DH3.DH3_QTD3) QTD3  "
	cQuery += " FROM " +	RetSqlName("SF2") + " SF2, "
	cQuery += 				RetSqlName("SD2") + " SD2, "
	cQuery += 				RetSqlName("SF4") + " SF4 ,"
	cQuery += 				RetSqlName("SB1") + " SB1 ,"
	cQuery += 				RetSqlName("DH3") + " DH3 "
	cQuery += " WHERE SF2.F2_EMISSAO >= '"+DTOS(MV_PAR06-4)+"' AND "
	cQuery += "       SF2.F2_EMISSAO <= '"+DTOS(MV_PAR01+3)+"' AND "
	cQuery += "       SF2.F2_FILIAL  = '"+xFilial("SF2")+"' AND "
	cQuery += "       SF2.F2_FILIAL   = SD2.D2_FILIAL AND "
	cQuery += "       SF2.F2_DOC      = SD2.D2_DOC AND "
	cQuery += "       SF2.F2_SERIE    = SD2.D2_SERIE AND "
	cQuery += "       SD2.D2_COD     >= '"+MV_PAR04+"' AND "
	cQuery += "       SD2.D2_COD     <= '"+MV_PAR05+"' AND "
	cQuery += "       SD2.D2_LOCAL   >= '"+MV_PAR02+"' AND "
	cQuery += "       SD2.D2_LOCAL   <= '"+MV_PAR03+"' AND "
	cQuery += "       SD2.D2_TES      = SF4.F4_CODIGO AND "
	cQuery += "       SD2.D2_FILIAL		= DH3.DH3_FILIAL AND "
	cQuery += "       SD2.D2_DOC		= DH3.DH3_DOCD2 AND "
	cQuery += "       SD2.D2_SERIE		= DH3.DH3_SERIE AND "
	cQuery += "       SD2.D2_CLIENTE	= DH3.DH3_CLIENT AND "
	cQuery += "       SD2.D2_LOJA		= DH3.DH3_LOJA AND "
	cQuery += "       SD2.D2_ITEM		= DH3.DH3_ITEM AND "
	cQuery += "       SF4.F4_ESTOQUE  = 'S' "
	cQuery += "       AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += "       AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += "       AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "       AND DH3.D_E_L_E_T_ = ' ' "
	cQuery += FiltrarSql("SD2.D2_COD")
	cQuery += " GROUP BY SF2.F2_EMISSAO,SF2.F2_HORA,SD2.D2_LOCAL,SD2.D2_COD "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery) , "TEMP1", .T., .F. )

	DBSELECTAREA("TEMP1")
	DBGOTOP()
	ProcRegua(Reccount())
	WHILE ! EOF()
		IncProc()
		DH5->(dbSeek(xFilial("DH5")+TEMP1->COD))
		IF TEMP1->EMISSAO > DTOS(MV_PAR06) .AND. TEMP1->EMISSAO <= DTOS(MV_PAR01)
			DBSELECTAREA("TRBD")
			IF ! DBSEEK(TEMP1->LOCAL1+TEMP1->COD)
				RECLOCK("TRBD",.T.)
				TRBD->LOCAL1:=TEMP1->LOCAL1
				TRBD->COD   :=TEMP1->COD
				TRBD->QSAIF :=TEMP1->QUANT
			ELSE
				RECLOCK("TRBD",.F.)
				TRBD->QSAIF :=TRBD->QSAIF + TEMP1->QUANT
			ENDIF
			MSUNLOCK()
		ENDIF
	
		IF TEMP1->DATA1 > DTOS(MV_PAR06) .AND. TEMP1->DATA1 <= DTOS(MV_PAR01)
			IF DH5->DH5_PREQUI<>"S"
				DBSELECTAREA("TRBD")
				IF ! DBSEEK(TEMP1->LOCAL1+TEMP1->COD)
					RECLOCK("TRBD",.T.)
					TRBD->LOCAL1:=TEMP1->LOCAL1
					TRBD->COD   :=TEMP1->COD
					TRBD->QSAIB :=TEMP1->QTD1
				ELSE
					RECLOCK("TRBD",.F.)
					TRBD->QSAIB :=TRBD->QSAIB + TEMP1->QTD1
				ENDIF
				MSUNLOCK()
			ELSE
				/*/
				DBSELECTAREA("TRBD")
				IF ! DBSEEK(TEMP1->LOCAL1+TEMP1->COD)
					RECLOCK("TRBD",.T.)
					TRBD->LOCAL1:=TEMP1->LOCAL1
					TRBD->COD   :=TEMP1->COD
					TRBD->QSAIB :=TEMP1->QUANT
				ELSE
					RECLOCK("TRBD",.F.)
					TRBD->QSAIB :=TRBD->QSAIB + TEMP1->QUANT
				ENDIF
				MSUNLOCK()
				/*/
				DBSELECTAREA("SG1")
				SG1->(DbSetOrder(5))//G1_FILIAL+G1_COD+DTOS(G1_FIM)+G1_TRT
				SG1->(DBSEEK(xFilial("SG1")+TEMP1->COD+TEMP1->DATA1,.T.))
				dFim:=SG1->G1_FIM
				WHILE TEMP1->COD == SG1->G1_COD .AND. ! EOF() .AND. dFim == SG1->G1_FIM
					DBSELECTAREA("TRBD")
					_SEQ:=SUBSTR(SG1->G1_TRT,3,1)
					If !(_SEQ $ "1|2|3") .Or. !FiltrarDBF(SG1->G1_COMP)
						DBSELECTAREA("SG1")
						DBSKIP()
						Loop
					EndIf
					_QTD:="TEMP1->QTD"+_SEQ
					DBSELECTAREA("TRBD")
					IF ! DBSEEK(TEMP1->LOCAL1+SG1->G1_COMP)
						RECLOCK("TRBD",.T.)
						TRBD->LOCAL1 :=TEMP1->LOCAL1
						TRBD->COD    :=SG1->G1_COMP
						TRBD->QSAIB  :=&(_QTD)
					ELSE
						RECLOCK("TRBD",.F.)
						TRBD->QSAIB :=TRBD->QSAIB + &(_QTD)
					ENDIF
					MSUNLOCK()
					DBSELECTAREA("SG1")
					DBSKIP()
				ENDDO
			ENDIF
		ENDIF
		DBSELECTAREA("TEMP1")
		DBSKIP()
	ENDDO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio da apuracao das Notas Fiscais de Entrada              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MONTA QUERY PARA CONSULTA SD1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TEMP2") > 0     // Verificando se o alias esta em uso
		dbSelectArea("TEMP2")
		dbCloseArea()
	EndIf

	cQuery := "SELECT SD1.D1_DTDIGIT DTDIGIT,SD1.D1_LOCAL LOCAL1, SD1.D1_COD COD,SD1.D1_TES TES, SUM(SD1.D1_QUANT) QUANT,  "
	cQuery += " 		DH4.DH4_TANQUE TANQUE,DH4.DH4_TDCARG VIATRAN,SUM(DH4.DH4_QTD20G) QTD1 "
	cQuery += " FROM " + RetSqlName("SD1") + " SD1, "
	cQuery += 				RetSqlName("SF4") + " SF4, "
	cQuery += 				RetSqlName("DH4") + " DH4, "
	cQuery += 				RetSqlName("SB1") + " SB1 "
	cQuery += " WHERE SD1.D1_DTDIGIT >= '"+DTOS(MV_PAR06+1)+"' AND "
	cQuery += "       SD1.D1_DTDIGIT <= '"+DTOS(MV_PAR01)+"' AND "
	cQuery += "       SD1.D1_FILIAL  = '"+xFilial("SD1")+"' AND "
	cQuery += "       SD1.D1_COD     >= '"+MV_PAR04+"' AND "
	cQuery += "       SD1.D1_COD     <= '"+MV_PAR05+"' AND "
	cQuery += "       SD1.D1_LOCAL   >= '"+MV_PAR02+"' AND "
	cQuery += "       SD1.D1_LOCAL   <= '"+MV_PAR03+"' AND "
	cQuery += "       SD1.D1_TES      = SF4.F4_CODIGO AND "
	cQuery += "       SF4.F4_ESTOQUE  = 'S' AND "
	cQuery += "       SD1.D1_FILIAL		= DH4.DH4_FILIAL AND "
	cQuery += "       SD1.D1_DOC		= DH4.DH4_DOC AND "
	cQuery += "       SD1.D1_SERIE		= DH4.DH4_SERIE AND "
	cQuery += "       SD1.D1_FORNECE	= DH4.DH4_FORNEC AND "
	cQuery += "       SD1.D1_LOJA		= DH4.DH4_LOJA AND "
	cQuery += "       SD1.D1_ITEM		= DH4.DH4_ITEM "
	cQuery += "       AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += "       AND DH4.D_E_L_E_T_ = ' ' "
	cQuery += "       AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += FiltrarSql("SD1.D1_COD")
	cQuery += " GROUP BY SD1.D1_DTDIGIT,DH4.DH4_TANQUE,SD1.D1_LOCAL,SD1.D1_COD,DH4.DH4_TDCARG,SD1.D1_TES "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery) , "TEMP2", .T., .F. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apuracao das  Movimentacoes Internas                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DBSELECTAREA("TEMP2")
	DBGOTOP()
	ProcRegua(Reccount())
	WHILE ! EOF()
		IncProc()
	
		DBSELECTAREA("TRBD")
		IF ! DBSEEK(TEMP2->LOCAL1+TEMP2->COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=TEMP2->LOCAL1
			TRBD->COD  :=TEMP2->COD
			TRBD->QENTF :=TEMP2->QUANT
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->QENTF :=TRBD->QENTF + TEMP2->QUANT
		ENDIF
	
		IF EMPTY(TEMP2->VIATRAN)
			DBSELECTAREA("TEMP2")
			DBSKIP()
			LOOP
		ENDIF
	
		DBSELECTAREA("TRBD")
		IF ! DBSEEK(TEMP2->LOCAL1+TEMP2->COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=TEMP2->LOCAL1
			TRBD->COD   :=TEMP2->COD
			TRBD->QENTB :=TEMP2->QTD1
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->QENTB := TRBD->QENTB + TEMP2->QTD1
		ENDIF
	
		MSUNLOCK()
		DBSELECTAREA("TEMP2")
		DBSKIP()
	ENDDO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio da Apuracao das notas fiscais saidas nao baixadas     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MONTA QUERY PARA CONSULTA SF2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TEMP3") > 0     // Verificando se o alias esta em uso
		dbSelectArea("TEMP3")
		dbCloseArea()
	EndIf

	cQuery := "SELECT SD2.D2_LOCAL LOCAL1,SD2.D2_COD COD, SUM(SD2.D2_QUANT) QUANT "
	cQuery += " FROM "+RetSqlName("SF2")+" SF2, " 
	cQuery += 			RetSqlName("SF4")+" SF4, "
	cQuery += 			RetSqlName("SD2")+" SD2, "
	cQuery += 			RetSqlName("SB1")+" SB1 "
	cQuery += " WHERE SF2.F2_EMISSAO >= '"+DTOS(MV_PAR06+1)+"' AND "
	cQuery += "       SF2.F2_EMISSAO <= '"+DTOS(MV_PAR01)+"' AND "
	cQuery += "       SF2.F2_FILIAL  = '"+xFilial("SF2")+"' AND "
	cQuery += "( SF2.F2_EMISSAO > '"+DTOS(MV_PAR01)+"' OR SF2.F2_EMISSAO = '      ' ) AND "
	cQuery += "       SF2.F2_FILIAL   = SD2.D2_FILIAL AND "
	cQuery += "       SF2.F2_DOC     = SD2.D2_DOC AND "
	cQuery += "       SF2.F2_SERIE   = SD2.D2_SERIE AND "
	cQuery += "       SD2.D2_COD     >= '"+MV_PAR04+"' AND "
	cQuery += "       SD2.D2_COD     <= '"+MV_PAR05+"' AND "
	cQuery += "       SD2.D2_LOCAL   >= '"+MV_PAR02+"' AND "
	cQuery += "       SD2.D2_LOCAL   <= '"+MV_PAR03+"' AND "
	cQuery += "       SD2.D2_TES      = SF4.F4_CODIGO AND "
	cQuery += "       SF4.F4_ESTOQUE  = 'S' "
	cQuery += "       AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += "       AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "       AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += FiltrarSql("SD2.D2_COD")
	cQuery += " GROUP BY SD2.D2_LOCAL,SD2.D2_COD "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery) , "TEMP3", .T., .F. )

	DBSELECTAREA("TEMP3")
	DBGOTOP()
	ProcRegua(Reccount())
	WHILE ! EOF()
		IncProc()
		DBSELECTAREA("TRBD")
		IF ! DBSEEK(TEMP3->LOCAL1+TEMP3->COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL1:=TEMP3->LOCAL1
			TRBD->COD   :=TEMP3->COD
			TRBD->SNTQ  :=TEMP3->QUANT
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->SNTQ :=TRBD->SNTQ + TEMP3->QUANT
		ENDIF
		MSUNLOCK()
		DBSELECTAREA("TEMP3")
		DBSKIP()
	
	ENDDO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PROCESSAMENTO DAS ENTRADAS NAO BAIXADAS       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TEMP4") > 0     // Verificando se o alias esta em uso
		dbSelectArea("TEMP4")
		dbCloseArea()
	EndIf

	cQuery := "SELECT SD1.D1_TES TES,SD1.D1_LOCAL LOCAL, SD1.D1_COD COD, SUM(SD1.D1_QUANT) QUANT "
	cQuery += " FROM " + RetSqlName("SD1") + " SD1, "
	cQuery += 				RetSqlName("SF4") + " SF4, " 
	cQuery += 				RetSqlName("DH4") + " DH4, " 
	cQuery += 				RetSqlName("SB1") + " SB1 " 
	cQuery += " WHERE SD1.D1_DTDIGIT >= '"+DTOS(MV_PAR06+1)+"' AND "
	cQuery += "       SD1.D1_DTDIGIT <= '"+DTOS(MV_PAR01)+"' AND "
	cQuery += "       SD1.D1_FILIAL  = '"+xFilial("SD1")+"' AND "
	cQuery += "       SD1.D1_COD     >= '"+MV_PAR04+"' AND "
	cQuery += "       SD1.D1_COD     <= '"+MV_PAR05+"' AND "
	cQuery += "       SD1.D1_LOCAL   >= '"+MV_PAR02+"' AND "
	cQuery += "       SD1.D1_LOCAL   <= '"+MV_PAR03+"' AND "
	cQuery += "       SD1.D1_TES      = SF4.F4_CODIGO AND "
	cQuery += "       DH4.DH4_ATUTNQ	<> 'S' AND "
	cQuery += "       SF4.F4_ESTOQUE  = 'S' AND "
	cQuery += "       SD1.D1_FILIAL		= DH4.DH4_FILIAL AND "
	cQuery += "       SD1.D1_DOC		= DH4.DH4_DOC AND "
	cQuery += "       SD1.D1_SERIE		= DH4.DH4_SERIE AND "
	cQuery += "       SD1.D1_FORNECE	= DH4.DH4_FORNEC AND "
	cQuery += "       SD1.D1_LOJA		= DH4.DH4_LOJA AND "
	cQuery += "       SD1.D1_ITEM		= DH4.DH4_ITEM "
	cQuery += "       AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += "       AND DH4.D_E_L_E_T_ = ' ' "
	cQuery += "       AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += FiltrarSql("SD1.D1_COD")
	cQuery += " GROUP BY SD1.D1_TES,SD1.D1_LOCAL,SD1.D1_COD "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery) , "TEMP4", .T., .F. )

	DBSELECTAREA("TEMP4")
	DBGOTOP()
	ProcRegua(Reccount())
	WHILE ! EOF()
		IncProc()
		DBSELECTAREA("TRBD")
		IF ! DBSEEK(TEMP4->LOCAL+TEMP4->COD)
			RECLOCK("TRBD",.T.)
			TRBD->LOCAL:=TEMP4->LOCAL
			TRBD->COD  :=TEMP4->COD
			TRBD->SNTQ := -TEMP4->QUANT
		ELSE
			RECLOCK("TRBD",.F.)
			TRBD->SNTQ :=TRBD->SNTQ - TEMP4->QUANT
		ENDIF
		MSUNLOCK()
		DBSELECTAREA("TEMP4")
		DBSKIP()
	ENDDO
	dbSelectArea("TEMP1")
	dbCloseArea()

	dbSelectArea("TEMP2")
	dbCloseArea()

	dbSelectArea("TEMP3")
	dbCloseArea()

	dbSelectArea("TEMP4")
	dbCloseArea()

	DBSelectArea("DH7")
	DBSETORDER(1)
	DBSEEK(xFilial("DH7")+DTOS(MV_PAR01+1),.T.)
	_DATA:=DH7->DH7_DATAME
	WHILE _DATA == DH7->DH7_DATAME .AND. ! EOF()
		DH6->(DBSEEK(xFilial("DH7")+DH7->DH7_TANQUE))
		_SALDO:=((DH7->DH7_VOLPRO-DH7->DH7_VOLAGU)+DH6->DH6_VOLTUB)*DH7->DH7_FATCOR
		nPos := aScan(aTANQUE,{ |X| X[1] == DH7->DH7_CODPRO })
		if nPos == 0
			Aadd(aTANQUE,{DH7->DH7_COD,_SALDO})
		else
			aTANQUE[nPos,2] := aTANQUE[nPos,2] + _SALDO
		Endif
		DBSKIP()
	ENDDO


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PROCESSAMENTO MOV. INTERNA                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DBSELECTAREA("SD3")
	ProcRegua(RecCount())
	DBSETORDER(6)
	DBSEEK(xFilial("SD3")+DTOS(MV_PAR06+1),.T.)
	WHILE DTOS(SD3->D3_EMISSAO) <= DTOS(MV_PAR01) .and. xFilial("SD3") == SD3->D3_FILIAL .AND. ! eof()
		IncProc(" Processando Mov. Interna ")
		IF SD3->D3_LOCAL < MV_PAR02 .OR. SD3->D3_LOCAL > MV_PAR03;
			.OR. SD3->D3_COD < MV_PAR04 .OR. SD3->D3_COD > MV_PAR05 .OR. SD3->D3_ESTORNO=="S" .Or. !FiltrarDBF(SD3->D3_COD)
			DBSKIP()
			LOOP
		ENDIF
	
		DBSELECTAREA("TRBD")
		SF5->(DBSEEK(xFilial("SF5")+SD3->D3_TM))
		IF SF5->F5_MOVTANQ $ "EQ/BO/DE/PR/AP/TR"
			IF ! DBSEEK(SD3->D3_LOCAL+SD3->D3_COD)
				RECLOCK("TRBD",.T.)
				TRBD->LOCAL1:=SD3->D3_LOCAL
				TRBD->COD  :=SD3->D3_COD
			
				IF SD3->D3_TM>"500"
					IF SF5->F5_MOVTANQ == "EQ"
						TRBD->EQ_R:=SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "BO"
						TRBD->BO_R:=SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "DE"
						TRBD->DE_R:=SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "PR"
						TRBD->PR_R:=SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "AP"
						TRBD->AP_R:=SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "TR"
						TRBD->TR_R:=SD3->D3_QUANT
					ENDIF

				ELSE
					IF SF5->F5_MOVTANQ == "EQ"
						TRBD->EQ_D:=SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "BO"
						TRBD->BO_D:=SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "DE"
						TRBD->DE_D:=SD3->D3_QUANT
					ENDIF

					IF SF5->F5_MOVTANQ == "PR"
						TRBD->PR_D:=SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "AP"
						TRBD->AP_D:=SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "TR"
						TRBD->TR_D:=SD3->D3_QUANT
					ENDIF

				ENDIF
			ELSE
				RECLOCK("TRBD",.F.)
				IF SD3->D3_TM>"500"
					IF SF5->F5_MOVTANQ == "EQ"
						TRBD->EQ_R:=TRBD->EQ_R+SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "BO"
						TRBD->BO_R:=TRBD->BO_R+SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "DE"
						TRBD->DE_R:=TRBD->DE_R+SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "PR"
						TRBD->PR_R:=TRBD->PR_R+SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "AP"
						TRBD->AP_R:=TRBD->AP_R+SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "TR"
						TRBD->TR_R:=TRBD->TR_R+SD3->D3_QUANT
					ENDIF

				ELSE
					IF SF5->F5_MOVTANQ == "EQ"
						TRBD->EQ_D:=TRBD->EQ_D+SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "BO"
						TRBD->BO_D:=TRBD->BO_D+SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "DE"
						TRBD->DE_D:=TRBD->DE_D+SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "PR"
						TRBD->PR_D:=TRBD->PR_D+SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "AP"
						TRBD->AP_D:=TRBD->AP_D+SD3->D3_QUANT
					ENDIF
					IF SF5->F5_MOVTANQ == "TR"
						TRBD->TR_D:=TRBD->TR_D+SD3->D3_QUANT
					ENDIF

				ENDIF
			ENDIF
		ELSE
			IF ! DBSEEK(SD3->D3_LOCAL+SD3->D3_COD)
				RECLOCK("TRBD",.T.)
				TRBD->LOCAL1:=SD3->D3_LOCAL
				TRBD->COD   :=SD3->D3_COD
				IF SD3->D3_TM>"500"
					TRBD->OSAI :=SD3->D3_QUANT
				ELSE
					TRBD->OENT :=SD3->D3_QUANT
				ENDIF
			ELSE
				RECLOCK("TRBD",.F.)
				IF SD3->D3_TM>"500"
					TRBD->OSAI :=TRBD->OSAI + SD3->D3_QUANT
				ELSE
					TRBD->OENT :=TRBD->OENT + SD3->D3_QUANT
				ENDIF
			ENDIF
		ENDIF
		MSUNLOCK()
		DBSELECTAREA("SD3")
		DBSKIP()
	ENDDO

	RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 17/01/01 ==>    RptStatus({|| Execute(RptDetail)})

EndIf

oTempTable:Delete()

dbSelectArea(_cArea)
dbSetOrder(_cInd)
dbGoto(_nRec)

Return

/*/{Protheus.doc} RptDetail
//TODO Descrição auto-gerada.
@author reynaldo
@since 15/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function RptDetail()
Local I:=0, LI:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ IMPRESSAO DOS DADOS FILTRADOS                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := "Mapa Demonstrativo de Estoque por Cessionaria Para data de : "+DTOC(MV_PAR01)
IF MV_PAR07 == 1
	Cabec1:="...............................|      NOTAS ENTRADAS     |     NOTAS SAIDAS         |                MOVIMENTO INTERNO(LIQ. DEVOLUCAO - REQUISICAO )                            |   S A L D O  |"
	Cabec2:="Produto          Saldo Inicial | Fiscal       20Graus    | Fiscal       20 Graus    | Apuracao     Dif_bombeio  Descarga     Equalizacao  Provisorio  Transferencia  Outros     |              |"
ELSE
	Cabec1:="...............................|      NOTAS ENTRADAS     |     NOTAS SAIDAS         |                MOVIMENTO INTERNO(LIQ. DEVOLUCAO - REQUISICAO )                            |   S A L D O  |"
	Cabec2:="Produto          Saldo Inicial | Fiscal       20Graus    | Fiscal       20 Graus    | Apuracao     Dif_bombeio  Descarga     Equalizacao  Provisorio  Transferencia  Outros     |              |"
ENDIF
//                            |      NOTAS ENTRADAS     |     NOTAS SAIDAS         |                MOVIMENTO INTERNO(LIQ. DEVOLUCAO - REQUISICAO )                            |   S A L D O  |
//roduto        Saldo Inicial | Fiscal       20Graus    | Fiscal       20 Graus    | Apuracao     Dif_bombeio  Descarga     Equalizacao  Provisorio  Transferencia  Outros     |              |
//X               999,999,999 | 999,999,999 999,999,999 | 999,999,999  999,999,999 | 999,999,999  999,999,999  999,999,999  999,999,999  999,999,999   999,999,999  999,999,999| 999,999,999  |
//                19          3133          45          5759           72          8486           99           112          125          138           152          165        176             
DBSELECTAREA("TRBD")                                                                              
DBGOTOP()
_CESSI:=""
li:=60

_TOTAL1:=0
_TOTAL2:=0
_TOTAL3:=0
_TOTAL4:=0
_TOTAL5:=0
_TOTAL6:=0
_TOTGER:=0
aTotPro:={}
SetRegua(RecCount())
WHILE ! EOF()
	
	IncRegua()
	IF MV_PAR08 == 2 .OR. MV_PAR08 == 1
		IF MV_PAR07 == 1
			If li > 55
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,If(aReturn[4]==1,15,18),NIL,.T.)
				LI := 9
			EndIf
		ELSE
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,If(aReturn[4]==1,15,18),NIL,.T.)
			LI := 9 
		ENDIF
	ENDIF
	IF (D35->(dbSeek(xFilial("D35")+TRBD->LOCAL1)))
		_Cessi:=D35->D35_NREDUZ
	ELSE
		_Cessi:="Cessionaria não cadastrada"
	ENDIF
	DBSELECTAREA("TRBD")
	ALMO:=TRBD->LOCAL1
	
	IF MV_PAR08 == 2 .OR. MV_PAR08 == 1
		@LI,00 PSAY TRBD->LOCAL1+" - "+Alltrim(_CESSI)
		LI:=LI+1
	ENDIF
	
	WHILE Almo==TRBD->LOCAL1 .AND. ! EOF()
		IF MV_PAR08 == 2 .OR. MV_PAR08 == 1
			If li > 55
				//li :=1
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,If(aReturn[4]==1,15,18),NIL,.T.)
				LI:=9
				@LI,00 PSAY TRBD->LOCAL1+" - "+Alltrim(_CESSI)
			EndIf
			
			DBSELECTAREA("SB1")
			DBSETORDER(1)
			IF DBSEEK(xFilial("SB1")+TRBD->COD)
				_Descri:=SB1->B1_DESC
				_UN:=SB1->B1_UM
			ELSE
				_Descri:="Produto não Encontrado"
				_UN:=" "
			ENDIF
			@LI,00 PSAY SubStr(Alltrim(TRBD->COD) +"-"+ AllTrim(_DESCRI),1,18)
			@LI,019 PSAY TRBD->QINI   PICTURE "@E 999,999,999"
			@LI,031 PSAY "|"
			@LI,033 PSAY TRBD->QENTF  PICTURE "@E 999,999,999"
			@LI,045 PSAY TRBD->QENTB PICTURE "@E 999,999,999"
			@LI,057 PSAY "|"
			@LI,059 PSAY -TRBD->QSAIF   PICTURE "@E 999,999,999"
			@LI,072 PSAY -TRBD->QSAIB PICTURE "@E 999,999,999"
			@LI,084 PSAY "|"
			@LI,086 PSAY (TRBD->AP_D-TRBD->AP_R)  PICTURE "@E 999,999,999"
			@LI,099 PSAY (TRBD->BO_D-TRBD->BO_R)  PICTURE "@E 999,999,999"
			@LI,112 PSAY (TRBD->DE_D-TRBD->DE_R)  PICTURE "@E 999,999,999"
			@LI,125 PSAY (TRBD->EQ_D-TRBD->EQ_R)  PICTURE "@E 999,999,999"
			@LI,138 PSAY (TRBD->PR_D-TRBD->PR_R)  PICTURE "@E 999,999,999"
			@LI,152 PSAY (TRBD->TR_D-TRBD->TR_R)  PICTURE "@E 999,999,999"
			@LI,165 PSAY (TRBD->OENT-TRBD->OSAI)  PICTURE "@E 999,999,999"
			@LI,176 PSAY "|"
			@LI,178 PSAY (TRBD->QINI+TRBD->QENTF-TRBD->QSAIF)+;   
                          (TRBD->AP_D-TRBD->AP_R)+;
                          (TRBD->BO_D-TRBD->BO_R)+;
                          (TRBD->DE_D-TRBD->DE_R)+;
                          (TRBD->EQ_D-TRBD->EQ_R)+;
                          (TRBD->PR_D-TRBD->PR_R)+;
                          (TRBD->TR_D-TRBD->TR_R)+;
                          (TRBD->OENT-TRBD->OSAI) PICTURE "@E 999,999,999"			
			@LI,191 PSAY "|"
			DBSELECTAREA("TRBD")
		ENDIF
		tot01:=TRBD->QINI  
		tot02:=TRBD->QENTF 
		tot03:=TRBD->QENTB 
		tot04:=TRBD->QSAIF 
		tot05:=TRBD->QSAIB 
		tot06:=(TRBD->AP_D-TRBD->AP_R) 
		tot07:=(TRBD->BO_D-TRBD->BO_R) 
		tot08:=(TRBD->DE_D-TRBD->DE_R) 
		tot09:=(TRBD->EQ_D-TRBD->EQ_R) 
		tot10:=(TRBD->PR_D-TRBD->PR_R) 
		tot11:=(TRBD->TR_D-TRBD->TR_R) 
		tot12:=(TRBD->OENT-TRBD->OSAI) 
		tot13:=(TRBD->QINI+TRBD->QENTF-TRBD->QSAIF)+;  
                          (TRBD->AP_D-TRBD->AP_R)+;
                          (TRBD->BO_D-TRBD->BO_R)+;
                          (TRBD->DE_D-TRBD->DE_R)+;
                          (TRBD->EQ_D-TRBD->EQ_R)+;
                          (TRBD->PR_D-TRBD->PR_R)+;
                          (TRBD->TR_D-TRBD->TR_R)+;
                          (TRBD->OENT-TRBD->OSAI) 
		DBSELECTAREA("TRBD")
		nPos := aScan(aTotPro,{ |X| X[1] == TRBD->COD})
		if nPos == 0
			Aadd(aTotpro,{TRBD->COD,tot01,tot02,tot03,tot04,tot05,tot06,tot07,tot08,tot09,tot10,tot11,tot12,tot13})
		else
			aTotpro[nPos,2] := aTotpro[nPos,2] + tot01
			aTotpro[nPos,3] := aTotpro[nPos,3] + tot02
			aTotpro[nPos,4] := aTotpro[nPos,4] + tot03
			aTotpro[nPos,5] := aTotpro[nPos,5] + tot04
			aTotpro[nPos,6] := aTotpro[nPos,6] + tot05
			aTotpro[nPos,7] := aTotpro[nPos,7] + tot06
			aTotpro[nPos,8] := aTotpro[nPos,8] + tot07
			aTotpro[nPos,09] := aTotpro[nPos,09]+ tot08
			aTotpro[nPos,10] := aTotpro[nPos,10] +tot09
			aTotpro[nPos,11] := aTotpro[nPos,11] + tot10
			aTotpro[nPos,12] := aTotpro[nPos,12] + tot11
			aTotpro[nPos,13] := aTotpro[nPos,13] + tot12
			aTotpro[nPos,14] := aTotpro[nPos,14] + tot13
		Endif
		
		
		DBSKIP()
		LI:=li+1
		
	ENDDO
	LI:=li+2
ENDDO


aTotPro := aSort(aTotPro,,,{ |x,y| x[1]<y[1]})  // Ordenar a Matriz

IF MV_PAR08 == 2 .OR. MV_PAR08 == 1
	@li,000 PSAY "TOTAL DOS PRODUTOS:"
	li += 1
	for i:=1 to len(aTotPro)
		@LI,000 PSAY alltrim(aTotpro[i,1])
		
		@LI,019 PSAY aTotpro[i,2] PICTURE "@E 999,999,999"
		@LI,031 PSAY "|"
		@LI,033 PSAY aTotpro[i,3] PICTURE "@E 999,999,999"
		@LI,045 PSAY aTotpro[i,4] PICTURE "@E 999,999,999"
		@LI,057 PSAY "|"
		@LI,059 PSAY aTotpro[i,5] PICTURE "@E 999,999,999"
		@LI,072 PSAY aTotpro[i,6] PICTURE "@E 999,999,999"
		@LI,084 PSAY "|"
		@LI,086 PSAY aTotpro[i,7] PICTURE "@E 999,999,999"
		@LI,099 PSAY aTotpro[i,8] PICTURE "@E 999,999,999"
		@LI,112 PSAY aTotpro[i,9] PICTURE "@E 999,999,999"
		@LI,125 PSAY aTotpro[i,10] PICTURE "@E 999,999,999"
		@LI,138 PSAY aTotpro[i,11] PICTURE "@E 999,999,999"
		@LI,152 PSAY aTotpro[i,12] PICTURE "@E 999,999,999"
		@LI,165 PSAY aTotpro[i,13] PICTURE "@E 999,999,999"
		@LI,176 PSAY "|"
		@LI,178 PSAY aTotpro[i,14] PICTURE "@E 999,999,999"
		@LI,191 PSAY "|"
		LI:=li+1
	next
	LI:=li+1
ENDIF

IF MV_PAR08 == 1 .OR. MV_PAR08 == 3
	titulo := " Comparativo estoque Fiscal X Estoque de Tanque : "+DTOC(MV_PAR01)
	li:=60
	Cabec1:="Produto                  Saldo Tanque       Saldo Fiscal         Diferenca"
	//XXXX -XXXXXXXXXXXXXXX    9,999,999,999     9,999,999,999     9,999,999,999
	//0                        26                44                62
	Cabec2:=""
	
	FOR I:=1 TO LEN(aTANQUE)
		IF li > 55
			// li :=1
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,If(aReturn[4]==1,15,18),NIL,.T.)
			LI:=9
		ENDIF
		SB1->(DBSEEK(xFilial("SB1")+aTANQUE[I,1]))
		@LI,000 PSAY ALLTRIM(aTANQUE[I,1])+" -"+SUBSTR(SB1->B1_DESC,1,15)
		@LI,026 PSAY aTANQUE[I,2] PICTURE "@E 9,999,999,999"
		nPos := aScan(aTotPro,{ |X| X[1] == SB1->B1_COD})
		if nPos<>0
			@LI,044 PSAY aTotPro[nPos,14] PICTURE "@E 9,999,999,999"
			@LI,062 PSAY (aTANQUE[I,2]-aTotPro[nPos,14]) PICTURE "@E 9,999,999,999"
		endif
		li:=li+1
	NEXT
ENDIF

Roda(0," ",Tamanho)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta arquivos temporarios e Retorna Indices   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Set device to Screen
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif
ms_flush()


RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} FiltrarDBF
// Quando o Produto estiver nas condicoes filtro devolve Verdadeiro
// Quando não tiver filtro devolve verdadeiro
@author Antonio Cordeiro
@since 01/12/1999
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function FiltrarDBF(cProduto)
Local lRet := .T.
Local aArea := GetArea()

MakeAdvplExp("CERR004")
DbSelectArea("SB1")
If SB1->(DBSeek(xFilial("SB1")+cProduto))
	If !Empty(MV_PAR09)
		lRet := &(MV_PAR09)
	EndIf
	If lRet .And. !Empty(MV_PAR10)
		lRet := &(MV_PAR10)
	EndIf
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FiltrarSql
//Filtro Para SQL
@author Antonio Cordeiro
@since 01/12/1999
@version 1.0
@return cRet
/*/
//-------------------------------------------------------------------
Static Function FiltrarSql(cCampo)
Local cRet := " AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = '" +cCampo + "' AND SB1.D_E_L_E_T_ = ' ' "

MakeSqlExp("CERR004")
If !Empty(MV_PAR09)
	cRet += " AND " + Alltrim(MV_PAR09)
EndIf
If !Empty(MV_PAR10)
	cRet += " AND " + Alltrim(MV_PAR10)
EndIf

Return cRet
