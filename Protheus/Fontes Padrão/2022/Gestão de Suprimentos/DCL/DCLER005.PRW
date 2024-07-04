#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLER005()
Relatorio Kardex movimento de estoque Fiscal X Tanque
Adaptação da função TDCER005
@author Antonio Cordeiro
@since 01/12/1999
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLER005()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas para parƒmetros              ³
//³ mv_par01  // Data Base                            ³
//³ mv_par02  // De Cessionario                       ³
//³ mv_par03  // Ate Cessionario                      ³
//³ mv_par04  // Produto de                           ³
//³ mv_par05  // Produto Ate.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private Tamanho   := "M"
Private Limite    := 132
Private cDesc1    := PadC("Este programa tem como objetivo imprimir o relatorio de   ",74)
Private cDesc2    := PadC("Saldos em Estoque por Cessionario, partindo do ulimo fecha-",74)
Private cDesc3    := PadC("mento e considerando movimentacoes ate a data base. Par.01",74)
Private wnrel     := "CER005"
Private nomeprog  := "TDCER005"
Private nLastkey  :=  0
Private cString   := "SD2"
Private aReturn   := {"Branco",1,"Comercial",2,2,1,"",1}
Private li        :=  66
Private lContinua := .T.
Private m_pag     := 1
Private titulo    := "Relatorio Kardex Movimento de Estoque : "
Private Cabec1    := ""
Private Cabec2    := ""

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

nSalant:=0
aProduto:={}
_cPerg    :="CER005"
_aRegs    :={}
pergunte(_cPerg,.F.)

wnrel := SetPrint(cString,wnrel,_cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.F.,Tamanho,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif

Processa({|| RunProc() }, "Processa")

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} RunProc
@author Antonio Cordeiro
@since 01/12/1999
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RunProc()
Local oTempTable

//Cria Arquivo de Trabalho TRB
_aStruc := {}
aTam := TamSX3("B2_LOCAL")
AaDd(_aStruc,{ "LOCAL1" , "C" , aTam[1],aTam[2] })
aTam := TamSX3("B2_COD")
AaDd(_aStruc,{ "COD"  ,"C" , aTam[1],aTam[2] })
aTam := TamSX3("B9_DATA")
AaDd(_aStruc,{ "DATA1" , "D" , aTam[1],aTam[2] })
AaDd(_aStruc,{ "TIPO" ,"C" , 1,0 })
AaDd(_aStruc,{ "DADOS","C" , 42,0})
aTam := TamSX3("B2_QATU")
AaDd(_aStruc,{ "QTDSF" , "N" , aTam[1],aTam[2] })
AaDd(_aStruc,{ "QTDST" , "N" , aTam[1],aTam[2] })
AaDd(_aStruc,{ "QTDEF" , "N" , aTam[1],aTam[2] })
AaDd(_aStruc,{ "QTDET" , "N" , aTam[1],aTam[2] })
AaDd(_aStruc,{ "QTDI"  , "N" , aTam[1],aTam[2] })

oTempTable := FWTemporaryTable():New( "TRBDCL" )
oTempTable:SetFields(_aStruc)
oTempTable:AddIndex("Ind01", {"LOCAL1","COD","DATA1","TIPO"} )
oTempTable:Create()

aSubtraS:={}

//GRAVA SALDO DE FECHAMENTO
DBSELECTAREA("SB9")
SB9->(DbSetOrder(2))
IF DBSEEK(xFilial("SB9") + DTOS(MV_PAR06))
	ProcRegua(RecCount())
	WHILE xFilial("SB9") == SB9->B9_FILIAL .AND. DTOS(SB9->B9_DATA) == DTOS(MV_PAR06) .AND. ! EOF()
		IncProc(" Processando Arquivo de Fechamento Estoque SB9")
		SB1->(DBSEEK(XFILIAL()+SB9->B9_COD))
		IF SB9->B9_LOCAL < MV_PAR02 .OR. SB9->B9_LOCAL > MV_PAR03;
			.OR. SB9->B9_COD < MV_PAR04 .OR. SB9->B9_COD > MV_PAR05
			DBSKIP()
			LOOP
		ENDIF
		RECLOCK("TRBDCL",.T.)
		TRBDCL->LOCAL1:=SB9->B9_LOCAL
		TRBDCL->COD  := SB9->B9_COD
		TRBDCL->DATA1:= SB9->B9_DATA
		TRBDCL->DADOS:= "SALDO INICIAL"
		IF MV_PAR07==1
			TRBDCL->TIPO := "1"
        ENDIF
		TRBDCL->QTDI := SB9->B9_QINI
		MSUNLOCK()
		DBSELECTAREA("SB9")
		DBSKIP()
	ENDDO
ELSE
	MsgAlert("Nao Existe Fechamento na Data "+dtoc(MV_PAR06)+" Especificada  Verificar !!!")
ENDIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PROCESSAMENTO NOTAS DE SAIDA                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSELECTAREA("SD2")
DBSETORDER(5)
ProcRegua(Reccount())
DBSEEK(XFILIAL()+DTOS(MV_PAR01),.T.)
WHILE ! EOF() .AND. SD2->D2_EMISSAO <= DDATABASE .AND. SD2->D2_FILIAL == xFilial("SD2")
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
	IF SD2->D2_TIPO == 'D' .OR. SD2->D2_TIPO == 'B'
		SA2->(DBSEEK(XFILIAL()+SD2->D2_CLIENTE+SD2->D2_LOJA))
		cCli:=SA2->A2_NREDUZ
	ELSE
		SA1->(DBSEEK(XFILIAL()+SD2->D2_CLIENTE+SD2->D2_LOJA))
		cCli:=SA1->A1_NREDUZ
	ENDIF
	SF2->(DBSETORDER(1))
	(SF2->(DBSEEK(XFILIAL()+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)))
	DBSELECTAREA("TRBDCL")
	
	DbSelectArea("DH3")
	DH3->(DbSetorder(1))
	DH3->(DbSeek(xFilial("DH3") + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_ITEM)))
	
	IF MV_PAR07==1
		RECLOCK("TRBDCL",.T.)
		TRBDCL->LOCAL1:= SD2->D2_LOCAL
		TRBDCL->COD   := SD2->D2_COD
		TRBDCL->DATA1 := SD2->D2_EMISSAO
		
		TRBDCL->TIPO  := "4"
		TRBDCL->DADOS := SD2->D2_DOC+" - "+SD2->D2_SERIE+" / "+cCli
		TRBDCL->QTDSF := SD2->D2_QUANT
		TRBDCL->QTDST := DH3->DH3_QTD1+DH3->DH3_QTD2+DH3->DH3_QTD3
	ELSE
		IF DBSEEK(SD2->D2_LOCAL+SD2->D2_COD+DTOS(SD2->D2_EMISSAO))
			DbSelectArea("DH3")
			DH3->(DbSetorder(1))
			If DH3->(DbSeek(xFilial("DH3") + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_ITEM)))
				RECLOCK("TRBDCL",.F.)
				TRBDCL->QTDSF := TRBDCL->QTDSF+SD2->D2_QUANT
				TRBDCL->QTDST := TRBDCL->QTDST+DH3->DH3_QTD1+DH3->DH3_QTD2+DH3->DH3_QTD3
			EndIf
		ELSE
			RECLOCK("TRBDCL",.T.)
			TRBDCL->LOCAL1:= SD2->D2_LOCAL
			TRBDCL->COD   := SD2->D2_COD
			TRBDCL->DATA1 := SD2->D2_EMISSAO
			TRBDCL->QTDSF := SD2->D2_QUANT
			TRBDCL->QTDST := DH3->DH3_QTD1+DH3->DH3_QTD2+DH3->DH3_QTD3
		ENDIF
	ENDIF
	MSUNLOCK()
	DBSELECTAREA("SD2")
	DBSKIP()
ENDDO


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da apuracao das Notas Fiscais de Entrada              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSELECTAREA("SD1")
DBSETORDER(6)
ProcRegua(Reccount())
DBSEEK(XFILIAL()+DTOS(MV_PAR01),.T.)
WHILE ! EOF() .AND. SD1->D1_DTDIGIT <= DDATABASE .AND. SD1->D1_FILIAL == xFilial("SD1")
	IncProc(" Processando Entradas ")
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
	IF SD1->D1_TIPO == 'D'
		SA1->(DBSEEK(XFILIAL()+SD1->D1_FORNECE+SD1->D1_LOJA))
		cCli:=SA1->A1_NREDUZ
	ELSE
		SA2->(DBSEEK(XFILIAL()+SD1->D1_FORNECE+SD1->D1_LOJA))
		cCli:=SA2->A2_NREDUZ
	ENDIF
	
	DbSelectArea("DH4")
	DH4->(DbSetorder(1))
	DH4->(DbSeek(xFilial("DH4") + SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_ITEM))) //DH4_FILIAL+DH4_DOC+DH4_SERIE+DH4_FORNEC+DH4_LOJA+DH4_ITEM
	
	DBSELECTAREA("TRBDCL")
	IF MV_PAR07==1
		RECLOCK("TRBDCL",.T.)
		TRBDCL->LOCAL1:= SD1->D1_LOCAL
		TRBDCL->COD   := SD1->D1_COD
		TRBDCL->DATA1 := SD1->D1_DTDIGIT
		TRBDCL->TIPO  := "2"
		TRBDCL->DADOS := SD1->D1_DOC+" - "+SD1->D1_SERIE+" / "+cCli
		TRBDCL->QTDEF := SD1->D1_QUANT
		TRBDCL->QTDET := DH4->DH4_QTDAPU
	ELSE
		IF DBSEEK(SD1->D1_LOCAL+SD1->D1_COD+DTOS(SD1->D1_DTDIGIT))
			RECLOCK("TRBDCL",.F.)
			TRBDCL->QTDEF := TRBDCL->QTDEF + SD1->D1_QUANT
			TRBDCL->QTDET := TRBDCL->QTDET + DH4->DH4_QTDAPU
		ELSE
			RECLOCK("TRBDCL",.T.)
			TRBDCL->LOCAL1:= SD1->D1_LOCAL
			TRBDCL->COD   := SD1->D1_COD
			TRBDCL->DATA1 := SD1->D1_DTDIGIT
			TRBDCL->QTDEF := SD1->D1_QUANT
			TRBDCL->QTDET := DH4->DH4_QTDAPU
		ENDIF
	ENDIF
	MSUNLOCK()
	DBSELECTAREA("SD1")
	DBSKIP()
ENDDO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PROCESSAMENTO MOV. INTERNA                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSELECTAREA("SD3")
ProcRegua(RecCount())
DBSETORDER(6)
DBSEEK(XFILIAL()+DTOS(MV_PAR01),.T.)
WHILE DTOS(SD3->D3_EMISSAO) <= DTOS(DDATABASE) .and. xFilial("SD3") == SD3->D3_FILIAL .AND. ! eof()
	IncProc(" Processando Mov. Interna ")
	IF SD3->D3_LOCAL < MV_PAR02 .OR. SD3->D3_LOCAL > MV_PAR03;
		.OR. SD3->D3_COD < MV_PAR04 .OR. SD3->D3_COD > MV_PAR05 .OR. SD3->D3_ESTORNO=="S"
		DBSKIP()
		LOOP
	ENDIF
	SF5->(DBSEEK(XFILIAL()+SD3->D3_TM))
	DBSELECTAREA("TRBDCL")
	IF MV_PAR07==1
		RECLOCK("TRBDCL",.T.)
		TRBDCL->LOCAL1:= SD3->D3_LOCAL
		TRBDCL->COD   := SD3->D3_COD
		TRBDCL->DATA1 := SD3->D3_EMISSAO
		TRBDCL->DADOS := SD3->D3_TM+"-"+SF5->F5_TEXTO+" / "+SD3->D3_CODFOR+" / "+SD3->D3_LOJAFOR
		TRBDCL->QTDEF := SD3->D3_QUANT
		IF SD3->D3_TM <= "500"
			IF  SD3->D3_TPMOVAJ=="PR" .OR. SD3->D3_TPMOVAJ=="TR"
				TRBDCL->QTDET := SD3->D3_QUANT
			ENDIF
			TRBDCL->QTDEF := SD3->D3_QUANT
			TRBDCL->TIPO:="3"
		ELSE
			TRBDCL->TIPO:="5"
			TRBDCL->QTDSF := SD3->D3_QUANT
			IF  SD3->D3_TPMOVAJ=="PR" .OR. SD3->D3_TPMOVAJ=="TR"
				TRBDCL->QTDST := SD3->D3_QUANT
			ENDIF
		ENDIF
	ELSE
		IF DBSEEK(SD3->D3_LOCAL+SD3->D3_COD+DTOS(SD3->D3_EMISSAO))
			RECLOCK("TRBDCL",.F.)
			IF SD3->D3_TM <= "500"
				TRBDCL->QTDEF := TRBDCL->QTDEF + SD3->D3_QUANT
				IF  SD3->D3_TPMOVAJ=="PR" .OR. SD3->D3_TPMOVAJ=="TR"
					TRBDCL->QTDET := TRBDCL->QTDET + SD3->D3_QUANT
				ENDIF
			ELSE
				TRBDCL->QTDSF := TRBDCL->QTDSF + SD3->D3_QUANT
				IF  SD3->D3_TPMOVAJ=="PR" .OR. SD3->D3_TPMOVAJ=="TR"
					TRBDCL->QTDST := TRBDCL->QTDST + SD3->D3_QUANT
				ENDIF
			ENDIF
		ELSE
			RECLOCK("TRBDCL",.T.)
			TRBDCL->LOCAL1:= SD3->D3_LOCAL
			TRBDCL->COD   := SD3->D3_COD
			TRBDCL->DATA1 := SD3->D3_EMISSAO
			IF SD3->D3_TM <= "500"
				TRBDCL->QTDEF := SD3->D3_QUANT
				IF  SD3->D3_TPMOVAJ=="PR" .OR. SD3->D3_TPMOVAJ=="TR"
					TRBDCL->QTDET := SD3->D3_QUANT
				ENDIF
			ELSE
				TRBDCL->QTDSF := SD3->D3_QUANT
				IF  SD3->D3_TPMOVAJ=="PR" .OR. SD3->D3_TPMOVAJ=="TR"
					TRBDCL->QTDST := SD3->D3_QUANT
				ENDIF
			ENDIF
		ENDIF
	ENDIF
	MSUNLOCK()
	
	DBSELECTAREA("SD3")
	DBSKIP()
ENDDO

RptStatus({|| RptDetail()})

oTempTable:Delete()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RptDetail
@author Antonio Cordeiro
@since 01/12/1999
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RptDetail()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ IMPRESSAO DOS DADOS FILTRADOS                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := "Relatorio Kardex Movimento de Estoque : "+DTOC(DDATABASE)
IF MV_PAR07==1
	Cabec1:="Local               Produto                         Data        Identificacao                              Qtd. Fiscal    Qtd.Tanque"
ELSE
    Cabec1:="Local               Produto                         Data       Saldo Inicial       Entrada         Saida    Saldo Final"
ENDIF
//Cabec1:="Local               Produto                         Data       Saldo Inicial       Entrada         Saida    Saldo Final"
// XXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99/99/99   999,999,999    999,999,999  999,999,999    999,999,999
//0                   21                              53         64              80            94             109

CABEC2:=""
DBSELECTAREA("TRBDCL")
DBGOTOP()
li:=60
SetRegua(RecCount())
WHILE ! EOF()
	If li > 55
		li :=1
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
		LI:=li+1
	EndIf
	D35->(DBSEEK(XFILIAL()+TRBDCL->LOCAL1))
	cLocal:=TRBDCL->LOCAL1
	@LI,00 PSAY SUBSTR(TRBDCL->LOCAL1+"-"+D35->D35_NREDUZ,1,18)
	WHILE cLocal == TRBDCL->LOCAL1
		SB1->(DBSEEK(XFILIAL()+TRBDCL->COD))
		cCod:=TRBDCL->COD
		@LI,21 PSAY SUBSTR(TRBDCL->COD+"-"+SB1->B1_DESC,1,30)
		WHILE cCod == TRBDCL->COD .AND. cLocal == TRBDCL->LOCAL1
			dDAta:=TRBDCL->DATA1
			@LI,53 PSAY DTOC(TRBDCL->DATA1)
			IF MV_PAR07==1
				WHILE TRBDCL->DATA1==dDAta .AND. cCod == TRBDCL->COD .AND. cLocal == TRBDCL->LOCAL1
					cTipo:=TRBDCL->TIPO
					WHILE cTipo == TRBDCL->TIPO .AND. TRBDCL->DATA1==dDAta .AND. cCod == TRBDCL->COD .AND. cLocal == TRBDCL->LOCAL1
						@ LI,064 PSAY TRBDCL->DADOS
						IF cTipo == "1"
							@ LI,108 PSAY TRBDCL->QTDI  PICTURE "@E 999,999,999"
						ELSEIF cTipo == "2"
							@ LI,108 PSAY TRBDCL->QTDEF PICTURE "@E 999,999,999"
							@ LI,120 PSAY TRBDCL->QTDET PICTURE  "@E 999,999,999"
						ELSEIF cTipo == "3"
							@ LI,108 PSAY TRBDCL->QTDEF PICTURE "@E 999,999,999"
						ELSEIF cTipo == "4"
							@ LI,108 PSAY -TRBDCL->QTDSF PICTURE "@E 999,999,999"
							@ LI,120 PSAY  TRBDCL->QTDST PICTURE "@E 999,999,999"
						ELSEIF cTipo == "5"
							@ LI,108 PSAY -TRBDCL->QTDSF PICTURE "@E 999,999,999"
						ELSE
							
						ENDIF
						LI:=LI+1
						DBSKIP()
						If li > 55
							li :=1
							cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
							LI:=li+1
						EndIf
					ENDDO
				ENDDO
			ELSE
				IF TRBDCL->DATA1==GETMV("MV_ULMES") .OR. EMPTY(TRBDCL->DATA1)
				   @ LI,064 PSAY TRBDCL->QTDI  PICTURE "@E 999,999,999"
		           nSalAnt:=TRBDCL->QTDI
		        ELSE
   				   @ LI,064 PSAY nSalAnt  PICTURE "@E 999,999,999"
		        ENDIF
		        @ LI,080 PSAY TRBDCL->QTDEF PICTURE "@E 999,999,999"
				@ LI,094 PSAY -TRBDCL->QTDSF PICTURE "@E 999,999,999"
                @ LI,109 PSAY nSalAnt+TRBDCL->QTDEF-TRBDCL->QTDSF PICTURE "@E 999,999,999"			
                nSalAnt:=nSalAnt+TRBDCL->QTDEF-TRBDCL->QTDSF
			    DBSKIP()
                IF TRBDCL->COD <> cCod
			       nSalAnt:=0
			    ENDIF   
			    LI:=LI+1
				If li > 55
					li :=1
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
					LI:=li+1
				EndIf
			ENDIF
		ENDDO
	    LI:=LI+1
	ENDDO
    @LI,00 PSAY REPLIC("-",132)
    LI:=LI+1
ENDDO

Roda(0," ",Tamanho)
Set device to Screen
If aReturn[5] == 1
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif
ms_flush()

RETURN

