#INCLUDE "rwmake.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA007
Rateia perdas sobras cessionarias e emite relatorios  
@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCLEA007()
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

SetPrvt("_CAREA,_NREC,_CIND,AMES,AESTRU")
SetPrvt("ATAM,OTEMPTAB1,OTEMPTAB2,OTEMPTAB3")
SetPrvt("TAMANHO,LIMITE,CDESC1,CDESC2,CDESC3,WNREL")
SetPrvt("NOMEPROG,NLASTKEY,CSTRING,ARETURN,LI,LCONTINUA")
SetPrvt("M_PAG,TITULO,APERG,_MES,_ANO,_PAR02")
SetPrvt("_PAR01,CABEC2,CABEC1,_JAFECHOU,_NDIESEL,_NGASOL")
SetPrvt("_NALHIDR,_NALANID,_AMESES,_NDIA,_NANO,_CMES")
SetPrvt("APERBOM,APERARM,ATOTBOM,ATOTARM,NPOS,_TOTS1")
SetPrvt("_TOTS2,_TOTS3,_TOTS4,_TOTS5,_TOTS6,_TOTS7")
SetPrvt("_TOTS8,_TOTS9,_TOTS10,_PERDA,NPOS1,NPOS2")
SetPrvt("NPOS3,NPOS4,_BASE,_TEXTO,_BRANCO,_CESSI")
SetPrvt("_TOT1,_TOT2,_TOT3,_TOT4,_TOT5,_TOT6")
SetPrvt("_PERDIDO,_PRODUTO,_JAFOI,_LOCAL,_TOTT1,_TOTT2")
SetPrvt("_TOTT3,_TOTT4,_COD,_TRANSP,_FORNECE,_SALIAS")
SetPrvt("AREGS,I,J,aTotProd,nn")
ntperda:=0
nperda:=0
aSdAnt:={}
_Sdant:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos Arquivos.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cArea     := Alias()
_nRec      := Recno()
_cInd      := IndexOrd()
CHKTEMPLATE("DCLEST")
aMES:={}
AaDd(aMES,"Janeiro")
AaDd(aMES,"Fevereiro")
AaDd(aMES,"Marco")
AaDd(aMES,"Abril")
AaDd(aMES,"Maio")
AaDd(aMES,"Junho")
AaDd(aMES,"Julho")
AaDd(aMES,"Agosto")
AaDd(aMES,"Setembro")
AaDd(aMES,"Outubro")
AaDd(aMES,"Novembro")
AaDd(aMES,"Dezembro")


aEstru := {}
AADD(aEstru,{"CCESSI    ","C",30,2})
AADD(aEstru,{"PRODUTO   ","C",30,2})
AADD(aEstru,{"TIPO      ","C",01,0})
AADD(aEstru,{"TOTENT    ","N",14,3})
AADD(aEstru,{"TOTCESSI  ","N",14,3})
AADD(aEstru,{"NPERC     ","N",10,3})
AADD(aEstru,{"TOTPERD   ","N",14,3})
AADD(aEstru,{"NPERDCIA  ","N",14,3})
AADD(aEstru,{"NPERDMAX  ","N",14,3})
AADD(aEstru,{"NVOLCOB   ","N",14,3})
AADD(aEstru,{"NVALCOB   ","N",14,3})

oTempTab1 := FWTemporaryTable():New("TMP1")
oTempTab1:SetFields( aEstru )
oTempTab1:Create()

aEstru := {}
AADD(aEstru,{"LOCAL1","C",02,0})
AADD(aEstru,{"COD    ","C",15,0})
aTam := TamSX3("D1_QUANT")
AaDd(aEstru,{ "BOMBEIO" , "N" , 14,2})
AADD(aEstru,{"CAMINHAO","N",14,2})

oTempTab2 := FWTemporaryTable():New("TMP2")
oTempTab2:SetFields( aEstru )
oTempTab2:AddIndex("A", {"COD","LOCAL1"} )
oTempTab2:AddIndex("B", {"LOCAL1","COD"} )
oTempTab2:Create()

aEstru := {}
AADD(aEstru,{"TRANSP    ","C",06,0})
AADD(aEstru,{"FORNECE   ","C",06,0})
AADD(aEstru,{"DOC       ","C",09,0})
AADD(aEstru,{"DTDIGIT   ","D",08,0})
AADD(aEstru,{"COD       ","C",15,0})
AADD(aEstru,{"LOCAL1    ","C",02,0})
AADD(aEstru,{"QUANT     ","N",12,2})
AADD(aEstru,{"QTCONV    ","N",12,2})
AADD(aEstru,{"QTDECV    ","N",12,2})

oTempTab3 := FWTemporaryTable():New("TMP3")
oTempTab3:SetFields( aEstru )
oTempTab3:AddIndex("C", {"COD","TRANSP","FORNECE","DTDIGIT"} )
oTempTab3:Create()

cDesc1    := PadC(" Relatorio de Fechamento dos Tanques ",74)
cDesc2    := ""
cDesc3    := ""
wnrel     := "DCEA007"
nomeprog  := "DCLEA007"
nLastkey  :=  0
cString   := "SD1"
aReturn   := {"Branco",1,"Comercial",2,2,1,"",1}
li        :=  66
lContinua := .T.
m_pag     := 1
Titulo    := PadC("Rateio de Perdas em Armazenagem e Bombeios ",74)

_cPerg:="DCEA007"
_aRegs    :={}
aPerda    :={}


For i:=1 to Len(_aRegs)
	If ! SX1->(dbSeek(PADR(_cPerg,nTamSX1)+_aRegs[i,2]))
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(_aRegs[i])
				FieldPut(j,_aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next



//CHKTEMPLATE("PETROEST")
PERGUNTE(_cPerg,.F.)

IF MV_PAR03 <> 3
	Tamanho   := "G"
	Limite    := 220
ELSE
	Tamanho   := "M"
	Limite    := 132
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ IMPRESSAO DOS DADOS FILTRADOS  NO VETOR                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,wnrel,_cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.F.,Tamanho,.F.)
//8   9  10  11    12
IF ! MV_PAR01 $ "01/02/03/04/05/06/07/08/09/10/11/12"
	ALERT(" Mes Informado Incorreto: "+MV_PAR01)

	oTempTab1:Delete()

	oTempTab2:Delete()

	oTempTab3:Delete()
	
	RETURN
ENDIF

IF VAL(MV_PAR02) > YEAR(DDATABASE) .OR. VAL(MV_PAR02)+1 < YEAR(DDATABASE)
	ALERT(" Ano Informado Incorreto: "+MV_PAR02)
	oTempTab1:Delete()
	
	oTempTab2:Delete()
	
	oTempTab3:Delete()
	
	RETURN
ENDIF

_MES:=MV_PAR01
_ANO:=MV_PAR02

IF MV_PAR01=="12"
	_PAR02:=CTOD("01/"+"01/"+STR(VAL(_ANO)+1,4)) - 1
ELSE
	_PAR02:=CTOD("01/"+STRZERO(VAL(_MES)+1,2)+"/"+_ANO)  - 1
ENDIF
_PAR01:=CTOD("01/"+_MES+"/"+_ANO)

If nLastKey == 27
	oTempTab1:Delete()
	
	oTempTab2:Delete()
	
	oTempTab3:Delete()
	
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
	oTempTab1:Delete()
	
	oTempTab2:Delete()
	
	oTempTab3:Delete()
	
	Return
Endif


DBSELECTAREA("SB9")
dbSetOrder(2)
IF DBSEEK(xFilial("SB9")+DTOS(_PAR01-1))
	WHILE xFilial("SB9") == SB9->B9_FILIAL .AND. DTOS(SB9->B9_DATA) == DTOS(_PAR01-1) .AND. ! EOF()
		nPos := aScan(aSDANT,{ |X| X[1] == SB9->B9_LOCAL+SB9->B9_COD})
		if nPos == 0
			Aadd(aSDAnt,{SB9->B9_LOCAL+SB9->B9_COD,SB9->B9_QINI})
		ELSE
			aSDANT[nPos,2] := aSDANT[nPos,2] + SD9->B9_QINI
		Endif
		DBSELECTAREA("TMP2")
		RECLOCK("TMP2",.T.)
		TMP2->COD:=SB9->B9_COD
		TMP2->LOCAL1:=SB9->B9_LOCAL
		MSUNLOCK()
		DBSELECTAREA("SB9")
		DBSKIP()
	ENDDO
ENDIF


Cabec2:="                          |               B  O  M  B  E  I  O              |        A  R  M  A  Z  E  N  A  G  E  M          |                         T   O  T  A  I  S                       |"
Cabec1:="Cessionaria               |  Vol.Rec.P/Cia   (%)Part.  Perdas-Ganhos/Cia.  |   Vol.Rec.P/Cia   (%)Part.  Perdas-Ganhosl/Cia. |     Total Liq.   Perda Maxima      Vol Cobrar    Valor a Cobrar |"
//XX -XXXXXXXXXXXXXXXXXXXX  |  9,999,999,999     999        9,999,999,999    |   9,999,999,999     999        9,999,999,999    | 9,999,999,999   9,999,999,999   9,999,999,999      9,999,999,99 |                                                              |
//1   5                      28                     51            65               82              99              115
li:=60
RptStatus({|| RptDetail()})
Return


Static Function RptDetail()
Local I := 0
_JaFechou :=.F.
IF _PAR02  <= GETMV("MV_ULMES")
	MsgAlert("Nao Vai Atualizar Faturamento -> Mes Ja Fechado","Mes Ja Fechado")
	_JaFechou := .T.
ENDIF

IF ! _JaFechou .AND. MV_PAR04==1
	DBSELECTAREA("D38")
	DBSETORDER(1)
	WHILE DBSEEK(XFILIAL("D38")+DTOS(_PAR02)+"A")
		RECLOCK("D38",.F.)
		DELETE RECORD(RECNO())
		MSUNLOCK()
	ENDDO
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Leitura da Notas fiscais de Entrada                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_aMeses := {"Janeiro","Fevereiro","Marco","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
_nDia   := Day(_PAR01)
_nAno   := Year(_PAR01)
_cMes   := _aMeses[Month(_PAR01)]

aPerBom:={}
aPerArm:={}
aTotBom:={}
aTotArm:={}
aTotais:={}

DBSELECTAREA("SD1")
SetRegua((_PAR02-_PAR01)+2)
DBSETORDER(6)
DBSEEK(XFILIAL("SD1")+DTOS(_PAR01),.T.)
SetRegua(RecCount())
WHILE ! EOF() .AND. dtos(SD1->D1_DTDIGIT) <= DTOS(_PAR02) .AND. xFilial("SD1") == SD1->D1_FILIAL
	DH4->(DBSELECTAREA("DH4"))
	DH4->(DBSETORDER(6))
	DH4->(DBSEEK(XFILIAL("DH4")+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM),.T.))
	
	IncRegua()
	IF DH4->DH4_ATUTNQ<>'S'
		DBSELECTAREA("SD1")
		DbSkip()
		Loop
	Endif
	IF ! SF4->(DBSEEK(XFILIAL("SF4")+SD1->D1_TES)) .OR. SF4->F4_ESTOQUE<>'S'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao Atualiza Estoque Vai para o Proximo                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DBSELECTAREA("SD1")
		DBSKIP()
		LOOP
	ENDIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apuracao do Diesel e Gasolina para Nota de Entrada           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SD1->D1_X_VIA=="02"
		
		DBSELECTAREA("TMP2")
		IF ! DBSEEK(SD1->D1_COD+SD1->D1_LOCAL)
			RECLOCK("TMP2",.T.)
			TMP2->LOCAL1	:= SD1->D1_LOCAL
			TMP2->COD		:= SD1->D1_COD
			TMP2->BOMBEIO	:= DH4->DH4_QTD20G
		ELSE
			RECLOCK("TMP2",.F.)
			TMP2->BOMBEIO:=TMP2->BOMBEIO + DH4->DH4_QTD20G
		ENDIF
		MSUNLOCK()
		
	ELSE
		
		DBSELECTAREA("TMP2")
		IF ! DBSEEK(SD1->D1_COD+SD1->D1_LOCAL)
			RECLOCK("TMP2",.T.)
			TMP2->LOCAL1	:= SD1->D1_LOCAL
			TMP2->COD		:= SD1->D1_COD
			TMP2->CAMINHAO:= DH4->DH4_QTD20G
		ELSE
			RECLOCK("TMP2",.F.)
			TMP2->CAMINHAO  := TMP2->CAMINHAO + DH4->DH4_QTD20G
		ENDIF
		MSUNLOCK()
		IF SD1->D1_LOCAL == GETMV("MV_X_LBASE")
			DBSELECTAREA("TMP3")
			RECLOCK("TMP3",.T.)
			TMP3->TRANSP  :=DH4->DH4_TRANS
			TMP3->FORNECE :=SD1->D1_FORNECE
			TMP3->LOCAL1  :=SD1->D1_LOCAL
			TMP3->COD     :=SD1->D1_COD
			TMP3->DOC     :=SD1->D1_DOC
			TMP3->DTDIGIT :=SD1->D1_DTDIGIT
			TMP3->QUANT   :=SD1->D1_QUANT
			TMP3->QTDECV  :=DH4->DH4_QTD20G
			TMP3->QTCONV  :=DH4->DH4_QTDAPU
			MSUNLOCK()
		ENDIF
	ENDIF
	
	DBSELECTAREA("SD1")
	DBSKIP()
ENDDO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Leitura das Movimentacoes Internas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DBSELECTAREA("SD3")
SetRegua(RecCount())
DBSETORDER(6)
DBSEEK(XFILIAL("SD3")+DTOS(_PAR01),.T.)
WHILE ! EOF() .AND. DTOS(SD3->D3_EMISSAO) <= DTOS(_PAR02) .AND. xFilial("SD3") == SD3->D3_FILIAL
	
	IncRegua()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apuracao do Diesel e Gasolina para Movimentacao Interna      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SF5->(DBSEEK(XFILIAL("SF5")+SD3->D3_TM))
	IF SF5->F5_MOVTANQ=='BO' .AND. SD3->D3_ESTORNO <> "S" .AND. SF5->F5_TIPO=='D'
		nPos := aScan(aPerBom,{ |X| X[1] == SD3->D3_COD})
		if nPos == 0
			Aadd(aPerBom,{SD3->D3_COD,SD3->D3_QUANT})
		ELSE
			aPerBom[nPos,2] := aPerBom[nPos,2] + SD3->D3_QUANT
		Endif
		
	ELSEIF SF5->F5_MOVTANQ=='BO' .AND. SD3->D3_ESTORNO <> "S" .AND. SF5->F5_TIPO=='R'
		nPos := aScan(aPerBom,{ |X| X[1] == SD3->D3_COD})
		if nPos == 0
			Aadd(aPerBom,{SD3->D3_COD,-SD3->D3_QUANT})
		else
			aPerBom[nPos,2] := aPerBom[nPos,2] - SD3->D3_QUANT
		Endif
		
		MSUNLOCK()
		
	ELSEIF SF5->F5_MOVTANQ=='AP' .AND. SD3->D3_ESTORNO <> "S" .AND. SF5->F5_TIPO=='D'
		nPos := aScan(aPerArm,{ |X| X[1] == SD3->D3_COD})
		if nPos == 0
			Aadd(aPerArm,{SD3->D3_COD,SD3->D3_QUANT})
		ELSE
			aPerArm[nPos,2] := aPerArm[nPos,2] + SD3->D3_QUANT
		Endif
		
	ELSEIF SF5->F5_MOVTANQ=='AP' .AND. SD3->D3_ESTORNO <> "S" .AND. SF5->F5_TIPO=='R'
		nPos := aScan(aPerArm,{ |X| X[1] == SD3->D3_COD})
		if nPos == 0
			Aadd(aPerArm,{SD3->D3_COD,-SD3->D3_QUANT})
		ELSE
			aPerArm[nPos,2] := aPerArm[nPos,2] - SD3->D3_QUANT
		ENDIF
		
	ENDIF
	DBSELECTAREA("SD3")
	DBSKIP()
ENDDO
nTotArm:=0
DBSELECTAREA("TMP2")
DBGOTOP()
WHILE ! EOF()
	(D35->(DBSEEK(XFILIAL("D35")+TMP2->LOCAL1)))
	_SdAnt:=0
	IF D35->D35_SAPERD=="S"
		nPos := aScan(aSDANT,{ |X| X[1] == TMP2->LOCAL1+TMP2->COD})
		if nPos <> 0
			_SdAnt:=aSdAnt[nPos,2]
		Endif
	ENDIF
	
	nPos := aScan(aTotBom,{ |X| X[1] == TMP2->COD})
	if nPos == 0
		Aadd(aTotBom,{TMP2->COD,TMP2->BOMBEIO})
	ELSE
		aTotBom[nPos,2] := aTotBom[nPos,2] + TMP2->BOMBEIO
	Endif
	
	nPos := aScan(aTotArm,{ |X| X[1] == TMP2->COD})
	if nPos == 0
		Aadd(aTotArm,{TMP2->COD,TMP2->CAMINHAO+TMP2->BOMBEIO+_SDANT})
	ELSE
		aTotArm[nPos,2] := aTotArm[nPos,2] + TMP2->CAMINHAO+TMP2->BOMBEIO+_SDANT
	Endif
	IF TMP2->LOCAL1 <> GETMV("MV_X_LBASE")
		nTotArm:=nTotArm+((TMP2->CAMINHAO+TMP2->BOMBEIO+_SDANT)/1000)
	ENDIF
	DBSKIP()
ENDDO
*----------------------------------------------------------------------------
TITULO:= " Demonstrativo Rateio de Perdas Entre Cessionarias Mes de: "+aMes[Val(mv_par01)]
_TOTS1:=_TOTS2:=_TOTS3:=_TOTS4:=_TOTS5:=_TOTS6:=_TOTS7:=_TOTS8:=_TOTS9:=_TOTS10:=0
DBSELECTAREA("TMP2")
DBGOTOP()
_PRODUTO :=""
WHILE ! EOF()
	_Perda:=0
	nPos1 := aScan(aPerBom,{ |X| X[1] == TMP2->COD })
	nPos2 := aScan(aPerArm,{ |X| X[1] == TMP2->COD })
	nPos3 := aScan(aTotBom,{ |X| X[1] == TMP2->COD })
	nPos4 := aScan(aTotArm,{ |X| X[1] == TMP2->COD })
	
	IF nPos1 <> 0 .OR. nPos2 <> 0
		IF nPos1<>0
			_Perda:=_Perda+aPerBom[nPos1,2]
		ENDIF
		IF nPos2<>0
			_Perda:=_Perda+aPerArm[nPos2,2]
		ENDIF
	ENDIF
	_BASE :=0
	IF nPos1 <> 0 .OR. nPos2 <> 0
		IF _Perda < 0
			_Texto:="Perda"
		ELSE
			_Texto:="Ganho"
		ENDIF
		DBSELECTAREA("SB1")
		DBSETORDER(1)
		IF DBSEEK(xFilial("SB1")+TMP2->COD)
			DH5->(DBSELECTAREA("DH5"))
			DH5->(DBSETORDER(1))
			DH5->(DBSEEK(xFilial("DH5")+TMP2->COD))
			_Prod1:="Produto: "+ALLTRIM(SB1->B1_COD)+" - "+SB1->B1_DESC
		ELSE
			_PROD1:="Produto: PRODUTO NAO ENCONTRADO"
		ENDIF
		IF li > 55
			li :=1
			li :=cabec(titulo,cabec2,cabec1,nomeprog,tamanho)
			li:=li+2
		ENDIF
		IF _PRODUTO <> TMP2->COD
			@ LI,00 PSAY _PROD1
			_PRODUTO := TMP2->COD
			li:=li+2
		ENDIF
		IF (D35->(DBSEEK(XFILIAL("D35")+TMP2->LOCAL1)))
			_Branco := .F.
			_Cessi  :=D35->D35_NREDUZ
		ELSE
			_Branco := .T.
			_Cessi:="CESSIONARIA NAO CAD. EM D35"
		ENDIF
		_SdAnt:=0
		IF D35->D35_SAPERD=="S"
			nPos := aScan(aSDANT,{ |X| X[1] == TMP2->LOCAL1+TMP2->COD})
			if nPos <> 0
				_SdAnt:=aSdAnt[nPos,2]
			Endif
		ENDIF
		_TOT1:=TMP2->BOMBEIO
		_TOT2:=(TMP2->BOMBEIO/aTotbom[nPos3,2])*100
		_TOT3:=IIF(NPOS1<>0,(TMP2->BOMBEIO/aTotbom[nPos3,2])*aPerBom[nPos1,2],0)
		
		
		_TOT4:=(TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)
		_TOT5:=((TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)/aTotArm[nPos4,2])*100
		_TOT6:=IIF(NPOS2<>0,((TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)/aTotArm[nPos4,2])*aPerArm[nPos2,2],0)
		_MAXIMO:=IIF(DH5->DH5_PPMAX == 0,D35->D35_MAXIMO,DH5->DH5_PPMAX)

			@ LI,000 PSAY TMP2->LOCAL1+" - "+_Cessi
			@ LI,027 PSAY "|"
			@ LI,030 PSAY _TOT1 PICTURE "@E 99,999,999.99"
			@ LI,048 PSAY _TOT2 PICTURE "@E 999"
			@ LI,059 PSAY _TOT3 PICTURE "@E 99,999,999.99"
			@ LI,076 PSAY "|"
			@ LI,080 PSAY _TOT4 PICTURE "@E 99,999,999.99"
			@ LI,098 PSAY _TOT5 PICTURE "@E 999"
			@ LI,109 PSAY _TOT6 PICTURE "@E 99,999,999.99"
			@ LI,126 PSAY "|"
			@ LI,128 PSAY (_TOT6+_TOT3) PICTURE "@E 99,999,999.99"
			@ LI,144 PSAY (_TOT4*(_MAXIMO/100)) PICTURE "@E 99,999,999.99"

		_Perdido:=0
		IF (_TOT6+_TOT3) < 0
			_Perdido:=(_TOT6+_TOT3) * -1

				@ LI,160 PSAY IIF((_TOT4*(_MAXIMO/100))<_Perdido,(_TOT4*(_MAXIMO/100)),_Perdido) PICTURE "@E 99,999,999.99"
				@ LI,179 PSAY IIF((_TOT4*(_MAXIMO/100))<_Perdido,(_TOT4*(_MAXIMO/100))*DH5->DH5_PRCPE,_Perdido*DH5->DH5_PRCPE) PICTURE "@E 9,999,999.99" //2=B1_CONVTER

		ENDIF

			@ LI,192 PSAY "|"

		_TOTS1:=_TOTS1+_TOT1
		_TOTS2:=_TOTS2+_TOT2
		_TOTS3:=_TOTS3+_TOT3
		_TOTS4:=_TOTS4+_TOT4
		_TOTS5:=_TOTS5+_TOT5
		_TOTS6:=_TOTS6+_TOT6
		_TOTS7:=_TOTS7+(_TOT6+_TOT3)
		_TOTS8:=_TOTS8+(_TOT4*(_MAXIMO/100))
		_TOTS9:=_TOTS9+IIF((_TOT4*(_MAXIMO/100))<_Perdido,(_TOT4*(_MAXIMO/100)),_Perdido)
		IF TMP2->LOCAL1 ==GETMV("MV_X_LBASE")
			_BASE:=IIF((_TOT4*(_MAXIMO/100))<(_TOT6+_TOT3),(_TOT4*(_MAXIMO/100)),(_TOT6+_TOT3))
		ENDIF
		_TOTS10:=_TOTS10+IIF((_TOT4*(_MAXIMO/100))<_Perdido,(_TOT4*(_MAXIMO/100))*DH5->DH5_PRCPE,_Perdido*DH5->DH5_PRCPE)
		
		IF ! _JaFechou .AND. _Perdido > 0 .AND. TMP2->LOCAL1<>GETMV("MV_X_LBASE") .AND. MV_PAR04==1
			DBSELECTAREA("D38")
			DBSETORDER(2)
			RECLOCK("D38",.T.)
			D38->D38_FILIAL := xFilial("D38")
			D38->D38_DATA   := _PAR02
			D38->D38_TIPO   := "A"
			D38->D38_LOCAL  :=TMP2->LOCAL1
			D38->D38_CESSI  :=_CESSI
			D38->D38_CODPRO :=TMP2->COD
			D38->D38_DESC	  :=SB1->B1_DESC
			D38->D38_QUANT  :=IIF((_TOT4*(_MAXIMO/100))<_Perdido,(_TOT4*(_MAXIMO/100)),_Perdido)
			D38->D38_VALOR  :=IIF((_TOT4*(_MAXIMO/100))<_Perdido,(_TOT4*(_MAXIMO/100))*DH5->DH5_PRCPE,_Perdido*DH5->DH5_PRCPE) //2=B1_CONVTER
			D38->D38_MOTIVO :="PERDAS-> "+SUBSTR(SB1->B1_DESC,1,20)
			MSUNLOCK()
		ENDIF
		IF _PERDIDO > 0
			nPQuant:=IIF((_TOT4*(_MAXIMO/100))<_Perdido,(_TOT4*(_MAXIMO/100)),_Perdido)
			nPerda :=IIF((_TOT4*(_MAXIMO/100))<_Perdido,(_TOT4*(_MAXIMO/100))*DH5->DH5_PRCPE,_Perdido*DH5->DH5_PRCPE) //2=B1_CONVTER
			nPos := aScan(aTotais,{ |X| X[1] == "PERDAS"})
			IF ALLTRIM(GETMV("MV_X_LBASE"))<>TMP2->LOCAL1
				if nPos == 0
					Aadd(aTotais,{"PERDAS",nPerda,0})
				ELSE
					aTotais[nPos,2] := aTotais[nPos,2] + nPerda
				Endif
			ENDIF
			Aadd(aPerda,{TMP2->LOCAL1+TMP2->COD,nPQuant,nPerda,"RATEIO DE PERDAS "+ALLTRIM(TMP2->COD)+"-"+ALLTRIM(SB1->B1_DESC)})
		ENDIF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ GRAVA OS DADOS EM UM ARQUIVO TMP                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if _Perdido > 0
			If _Branco == .F.
				dbselectarea("TMP1")
				RECLOCK("TMP1",.T.)
				TMP1->cCessi     :=   _Cessi
				TMP1->Produto    :=   SB1->B1_DESC
				TMP1->Tipo       :=   " "
				TMP1->nPerc      :=   _TOT5
				TMP1->nPerdCia   :=   _TOT3
				TMP1->nPerdMax   :=   (_TOT4*(_MAXIMO/100))
				TMP1->nVolCob    :=   IIF((_TOT4*(_MAXIMO/100))<_Perdido,(_TOT4*(_MAXIMO/100)),_Perdido)
				TMP1->nValCob    :=   IIF((_TOT4*(_MAXIMO/100))<_Perdido,(_TOT4*(_MAXIMO/100))*DH5->DH5_PRCPE,_Perdido*DH5->DH5_PRCPE)  //2=B1_CONVTER
				TMP1->totent     :=   aTotArm[nPos3,2]
				TMP1->totcessi   :=   _TOT4
				TMP1->totperd    :=   _Perdido
				MSUNLOCK()
			endif
		Endif
		
		LI:=LI+1
		
		DBSELECTAREA("TMP2")
		_SDANT:=0
		_PRODUTO:=TMP2->COD
		DBSKIP()
		IF _PRODUTO <> TMP2->COD .OR. EOF()
			LI:=LI+1
//			IF MV_PAR03 == 1
				@ li,000 PSAY " TOTAIS "
				@ LI,030 PSAY _TOTS1  PICTURE "@E 99,999,999.99"
				@ LI,048 PSAY _TOTS2  PICTURE "@E 999"
				@ LI,059 PSAY _TOTS3  PICTURE "@E 99,999,999.99"
				@ LI,080 PSAY _TOTS4  PICTURE "@E 99,999,999.99"
				@ LI,098 PSAY _TOTS5  PICTURE "@E 999"
				@ LI,109 PSAY _TOTS6  PICTURE "@E 99,999,999.99"
				@ LI,128 PSAY _TOTS7  PICTURE "@E 99,999,999.99"
				@ LI,144 PSAY _TOTS8  PICTURE "@E 99,999,999.99"
				IF _TOTS7<0
					@ LI,160 PSAY _TOTS9  PICTURE "@E 99,999,999.99"
					@ LI,179 PSAY _TOTS10 PICTURE "@E 99,999,999.99"
					LI:=LI+2
					@ LI,00 PSAY "Tot.Perda Recuperada............-> "
					@ LI,35 PSAY (_TOTS9) PICTURE "@E 99,999,999.99"
				ELSE
					LI:=LI+2
					@ LI,00 PSAY "Tot.Ganho Liquido Apurado.......-> "
					@ LI,35 PSAY (_TOTS9-_BASE) PICTURE "@E 99,999,999.99"
				ENDIF
			LI:=LI+2
			_TOTS1:=_TOTS2:=_TOTS3:=_TOTS4:=_TOTS5:=_TOTS6:=_TOTS7:=_TOTS8:=_TOTS9:=_TOTS10:=0
			_Perda:=0
			_BASE:=0
			_SDANT:=0
		ENDIF
	ELSE
		DBSELECTAREA("TMP2")
		DBSKIP()
	ENDIF
ENDDO


// ---------------------C   A   R    T   A   S --------------------------

IF MV_PAR03 == 3
	li:=60
	DBSELECTAREA("TMP2")
	DBSETORDER(2)
	DBGOTOP()
	TITULO:= " Demonstrativo Rateio de Perdas Entre Cessionarias Mes de: "+aMes[Val(mv_par01)]
	Cabec1:="Produto                   |  Total Geral   |   Total Entrada  |   (%)   |  Total Perdas  |   Total Perdas  |  Perda    |    Perda a|"
	Cabec2:="                          |      Entrada   |   p/Cessionaria  | Partic. |       Apurada  |  p/Cessionaria  |  Maxima   |     Cobrar|"
	
	WHILE ! EOF()
		
		IF (D35->(DBSEEK(XFILIAL("D35")+TMP2->LOCAL1)))
			_Branco := .F.
			_Cessi  :=D35->D35_NREDUZ
		ELSE
			_Branco := .T.
			_Cessi:="NAO CAD.TAB. CESSIONARIAS D35"
		ENDIF
		
		DBSELECTAREA("TMP2")
		li :=1
		li :=cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
		li:=li+5
		@ LI,00 PSAY "Cessionaria: "+ALLTRIM(TMP2->LOCAL1)+" - "+_CESSI
		li:=li+5
		_LOCAL := TMP2->LOCAL1
		aPreco:={}
		WHILE _LOCAL == TMP2->LOCAL1 .AND. ! EOF()
			_SdAnt:=0
			IF D35->D35_SAPERD=="S"
				nPos := aScan(aSDANT,{ |X| X[1] == TMP2->LOCAL1+TMP2->COD})
				if nPos <> 0
					_SdAnt:=aSdAnt[nPos,2]
				Endif
			ENDIF
			
			nPos1 := aScan(aPerBom,{ |X| X[1] == TMP2->COD })
			nPos2 := aScan(aPerArm,{ |X| X[1] == TMP2->COD })
			nPos3 := aScan(aTotBom,{ |X| X[1] == TMP2->COD })
			nPos4 := aScan(aTotArm,{ |X| X[1] == TMP2->COD })
			_TOT3:=IIF(NPOS1<>0,(TMP2->BOMBEIO/aTotbom[nPos3,2])*aPerBom[nPos1,2],0)
			_TOT6:=IIF(NPOS2<>0,((TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)/aTotArm[nPos4,2])*aPerArm[nPos2,2],0)
			_Perda:=0
			IF _TOT3+_TOT6>0
				DBSELECTAREA("TMP2")
				DBSKIP()
				LOOP
			ELSE
				_Perda:=(_TOT3+_TOT6)*-1
			ENDIF
			
			SB1->(DBSEEK(XFILIAL("SB1")+TMP2->COD))
			DH5->(DBSEEK(XFILIAL("DH5")+TMP2->COD))
			_MAXIMO:=IIF(DH5->DH5_PPMAX == 0,D35->D35_MAXIMO,DH5->DH5_PPMAX)
			@ LI,00 PSAY ALLTRIM(SB1->B1_COD)+" - "+SUBSTR(SB1->B1_DESC,1,18)
			nPos1 := aScan(aPreco,{ |X| X[1] == TMP2->COD })
			if nPos == 0
				Aadd(aPreco,{TMP2->COD,SB1->B1_DESC,DH5->DH5_PRCPE})
			Endif
			
			@ LI,27 PSAY "|"
			@ LI,30 PSAY aTotArm[nPos4,2] PICTURE "@E 9999,999.99"
			@ LI,44 PSAY "|"
			@ LI,50 PSAY TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT  PICTURE "@E 9999,999.99"
			@ LI,63 PSAY "|"
			@ LI,66 PSAY ((TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)/aTotArm[nPos4,2])*100  PICTURE "@E 99.99"
			@ LI,73 PSAY "|"
			@ LI,77 PSAY _Perda/((TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)/aTotArm[nPos4,2])  PICTURE "@E 9999,999.99"
			@ LI,90 PSAY "|"
			@ LI,95 PSAY _Perda PICTURE "@E 9999,999.99"
			@ LI,108 PSAY "|"
			@ LI,109 PSAY (TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT) * (_MAXIMO/100)  PICTURE "@E 999,999.99"
			@ LI,120 PSAY "|"
			@ LI,122 PSAY IIF((TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT) * (_MAXIMO/100)< _Perda,(TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT) * (_MAXIMO/100),_Perda) PICTURE "@E 99,999.99"
			@ LI,131 PSAY "|"
			
			LI:=LI+1
			DBSELECTAREA("TMP2")
			DBSKIP()
		ENDDO
		LI:=LI+5
		@ LI,00 PSAY "PRECO POR LITRO "
		LI:=LI+1
		@ LI,00 PSAY "----------------"
		LI:=LI+1
		FOR I:=1 TO LEN(aPreco)
			@ LI,00 PSAY ALLTRIM(aPreco[I,1])+" - "+ SUBSTR(aPreco[I,2],1,18)
			@ LI,35 PSAY aPreco[i,3] PICTURE "@E 99.9999"
			LI:=LI+1
		NEXT
		LI:=LI+5
		@LI,00  PSAY " Depto. de Operacoes "
		LI:=LI+3
		@ LI,00 PSAY "---------------------"
	ENDDO
ENDIF


// -----------------F  A  T  U  R  A   M  E  N  T  O --------------------
IF MV_PAR03 == 4 .OR. MV_PAR03 == 5
	li:=60
	DBSELECTAREA("TMP2")
	DBSETORDER(2)
	aTotProd := {}
	nn:=0
	TMP2->(DbGotop())
	Do While !TMP2->(Eof())

		_SdAnt:=0
		IF Posicione("D35",1,XFILIAL("D35")+TMP2->LOCAL1,"D35_SAPERD")=="S"
			nPos := aScan(aSDANT,{ |X| X[1] == TMP2->LOCAL1+TMP2->COD})
			if nPos <> 0
				_SdAnt:=aSdAnt[nPos,2]
			Endif
        EndIf
		nn := aScan(aTotProd,{|x| x[1] == TMP2->LOCAL1})
		If nn == 0
			aAdd(aTotProd,{TMP2->LOCAL1,((TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)/1000)})
		Else
			aTotProd[nn,2] +=((TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)/1000)
		EndIf
		TMP2->(DbSkip())	
	EndDo
	TMP2->(DbGotop())

	IF MV_PAR03 == 4 
		TITULO:= " Valores a Faturar para Cessionarias por Produto - "+aMes[Val(mv_par01)]
    Else
		TITULO:= " Valores a Faturar para Cessionarias por Total - "+aMes[Val(mv_par01)]
	EndIf
	Cabec1  := "Alm  -  Cessionaria                                            Codigo Produto                                          Quantidade      Custo Armaz       Valor Armaz. "
	Cabec2  := "                                                                                                                       Entrada-M3        p/ M3              em  R$    "

	DBSELECTAREA("D35")
	DBGOTOP()
	DBSETORDER(1)
	WHILE ! EOF()
		IF D35->D35_LOCAL=GETMV("MV_X_LBASE")
			DBSKIP()
			LOOP
		ENDIF
		
		SA2->(DBSEEK(XFILIAL("SA2")+D35->D35_COD+D35->D35_LOJA))
		_Cessi:=SA2->A2_NREDUZ
		_LOCAL:=D35->D35_LOCAL
		nValAlug := D35->D35_ALUGUE
		IF li > 55
			li :=1
			li :=cabec(titulo,cabec2,cabec1,nomeprog,tamanho)
			li:=li+2
		ENDIF
		_tot1:=0
		_tot2:=0
		nQtdeArm :=0
		DBSELECTAREA("TMP2")
		IF DBSEEK(_LOCAL) //.AND. (TMP2->BOMBEIO<>0 .OR. TMP2->CAMINHAO<>0 .OR. _SDANT<>0)
			@ LI,00 PSAY TMP2->LOCAL1+" "+" - "+_Cessi
			WHILE _LOCAL == TMP2->LOCAL1 .AND. ! EOF()
				SB1->(DBSEEK(XFILIAL("SB1")+TMP2->COD))
				_SdAnt:=0
				IF D35->D35_SAALUG=="S"
					nPos := aScan(aSDANT,{ |X| X[1] == TMP2->LOCAL1+TMP2->COD})
					if nPos <> 0
						_SdAnt:=aSdAnt[nPos,2]
					Endif
				ENDIF
				
				IF li > 55
					li :=1
					li :=cabec(titulo,cabec2,cabec1,nomeprog,tamanho)
					li:=li+2
					@ LI,00 PSAY TMP2->LOCAL1+" "+" - "+_Cessi
				ENDIF
				@LI,064 PSAY ALLTRIM(TMP2->COD)+" - "+SUBSTR(SB1->B1_DESC,1,30)
				//@LI,115 PSAY INT(((TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)/1000)) PICTURE "@E 9999,999.99"
				@LI,115 PSAY ((TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)/1000) PICTURE "@E 9999,999.99999"

				//QtdArmaz:=((TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)/1000)
				If MV_PAR03 == 5
					nn := aScan(aTotProd,{|x| x[1] == TMP2->LOCAL1})
					nQtdArmaz := aTotProd[nn,2]
				Else
					nQtdArmaz :=((TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)/1000)
				EndIf

				IF nQtdArmaz >= 0 .AND. nQtdArmaz < D35->D35_VOL1
					nValAcum:=D35->D35_VAL1
				ELSEIF nQtdArmaz >= D35->D35_VOL1 .AND. nQtdArmaz < D35->D35_VOL2
					nValAcum:=D35->D35_VAL2
				ELSEIF nQtdArmaz>=D35->D35_VOL2 .AND. nQtdArmaz<D35->D35_VOL3
					nValAcum:=D35->D35_VAL3
				ELSE
					nValAcum:=0
				ENDIF
				nQtdArmaz :=((TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)/1000)
				
				@LI,138  PSAY nValAcum                PICTURE "@E 99.99"
				//@LI,146  PSAY INT(nQtdArmaz) * nValAcum    PICTURE "@E 999,999,999.99"
				@LI,150  PSAY nQtdArmaz * nValAcum    PICTURE "@E 999,999,999.99"
				//nQtdeArm:=nQtdeArm+int(nQtdArmaz)
				nQtdeArm:=nQtdeArm+nQtdArmaz
				LI:=LI+1
				_tot1:=_tot1+(TMP2->BOMBEIO+TMP2->CAMINHAO+_SDANT)/1000
				_tot2:=_tot2+nQtdArmaz * nValAcum
				
				nPos := aScan(aTotais,{ |X| X[1] == "ALUG.TANQUES"})
				if nPos == 0
					Aadd(aTotais,{"ALUG.TANQUES",nQtdArmaz * nValAcum,nQtdArmaz})
				ELSE
					aTotais[nPos,2] := aTotais[nPos,2] +nQtdArmaz * nValAcum
					aTotais[nPos,3] := aTotais[nPos,3] +nQtdArmaz 
				Endif

				DBSELECTAREA("D38")
				DBSETORDER(2)
				IF MV_PAR04==1 .AND. ! _Jafechou
					RECLOCK("D38",.T.)
					D38->D38_FILIAL := xFilial("D38")
					D38->D38_DATA   := _PAR02
					D38->D38_TIPO   := "A"
					D38->D38_LOCAL  :=TMP2->LOCAL1
					D38->D38_CESSI  :=_CESSI
					D38->D38_COD    :=TMP2->COD
					D38->D38_DESC   :=SB1->B1_DESC
					D38->D38_QUANT  :=nQtdArmaz
					D38->D38_VALOR  :=nQtdArmaz * nValAcum
					D38->D38_MOTIVO :="ALUG TANQUES "+SUBSTR(SB1->B1_DESC,1,18)
					MSUNLOCK()
				ENDIF
				DBSELECTAREA("TMP2")
				DBSKIP()
			ENDDO
			ntotarm:=iif(ntotarm==0,1,ntotarm)
			nSeguro := Round( (D35->D35_SEGURO / nTotArm ) * nQtdeArm,2)
			@LI,064 PSAY "SEGURO"
			@LI,150 PSAY Round(nSeguro,2)                  PICTURE "@E 999,999,999.99"
			DBSELECTAREA("D38")
			DBSETORDER(2)
			IF MV_PAR04==1.AND. ! _Jafechou
				RECLOCK("D38",.T.)
				D38->D38_FILIAL := xFilial("D38")
				D38->D38_DATA   := _PAR02
				D38->D38_TIPO   := "A"
				D38->D38_LOCAL  := _LOCAL
				D38->D38_CESSI  := _CESSI
				D38->D38_CODPRO := SB1->B1_COD
				D38->D38_QUANT  := nQtdeArm
				D38->D38_VALOR  := Round(nSeguro,2)
				D38->D38_MOTIVO :="SEGURO"
				MSUNLOCK()
			ENDIF
			
			_tot2:=_tot2+nSeguro
			
			nPos := aScan(aTotais,{ |X| X[1] == "SEGURO"})
			if nPos == 0
				Aadd(aTotais,{"SEGURO",nSeguro,0})
			ELSE
				aTotais[nPos,2] := aTotais[nPos,2] + nSeguro
			Endif
			
			IF nValAlug<>0
				LI := LI + 1
				@LI,064 PSAY "ALUGUEL SALAS"
				@LI,150 PSAY nValAlug                          PICTURE "@E 999,999,999.99"
				_tot2:=_tot2+nValAlug
				nPos := aScan(aTotais,{ |X| X[1] == "ALUGUEL SALAS"})
				if nPos == 0
					Aadd(aTotais,{"ALUGUEL SALAS",nValAlug,0})
				ELSE
					aTotais[nPos,2] := aTotais[nPos,2] + nValAlug
				Endif
				DBSELECTAREA("D38")
				DBSETORDER(2)
				IF MV_PAR04==1.AND. ! _Jafechou
					RECLOCK("D38",.T.)
					D38->D38_FILIAL := xFilial("D38")
					D38->D38_DATA   := _PAR02
					D38->D38_TIPO   := "A"
					D38->D38_LOCAL  := _LOCAL
					D38->D38_CESSI  := _CESSI
					D38->D38_QUANT  := 1
					D38->D38_VALOR  := nValAlug
					D38->D38_MOTIVO := "ALUGUEL DE SALAS"
					MSUNLOCK()
				ENDIF
				
				
			ENDIF
			LI := LI + 1
			
			FOR I:=1 TO LEN(aPerda)
				IF _LOCAL == SUBSTR(aPerda[I,1],1,2)
					@LI,064 PSAY aPerda[I,4]   //ALLTRIM(LB5->LB5_MOTIVO)  //+" "+ALLTRIM(LB5->LB5_DESC)
					@LI,150 PSAY aPerda[I,3] PICTURE "@E 999,999,999.99"  //LB5->LB5_VALOR PICTURE "@E 999,999,999.99"
					LI:=LI+1
					_tot2:=_tot2+aPerda[I,3]
				ENDIF
			NEXT
			
			DBSELECTAREA("D38")
			DBSETORDER(2)
			IF DBSEEK(XFILIAL("D38")+DTOS(_PAR02)+_LOCAL,.T.)
				WHILE D38->D38_DATA == _PAR02 .AND. _LOCAL==D38->D38_LOCAL .AND. ! EOF()
					IF D38->D38_TIPO == "M"
						@LI,064 PSAY ALLTRIM(D38->D38_MOTIVO)
						@LI,150 PSAY D38->D38_VALOR PICTURE "@E 999,999,999.99"
						_tot2:=_tot2+D38->D38_VALOR
						LI:=LI+1
						nPos := aScan(aTotais,{ |X| X[1] == "LANC. MANUAL"})
						if nPos == 0
							Aadd(aTotais,{"LANC. MANUAL",D38->D38_VALOR,0})
						ELSE
							aTotais[nPos,2] := aTotais[nPos,2] + D38->D38_VALOR
						Endif
					ENDIF
					DBSKIP()
				ENDDO
			ENDIF
			
			LI:=LI+1
			@ LI,115 PSAY "------------------"
			@ LI,150 PSAY "------------------"
			LI:=LI+1
			@ LI,112 PSAY _TOT1 PICTURE "@E 999,999,999.99999"
			@ LI,150 PSAY _TOT2 PICTURE "@E 999,999,999.99"
			Tperda:=nTperda+nPerda
			_TOT1:=_TOT2:=0
			LI:=LI+3
		ELSE
			IF nValAlug <> 0
				LI := LI + 1
				@ LI,00 PSAY D38->D38_COD + "/" + D38->D38_LOJA + " - " + SA2->A2_NREDUZ
				@LI,064 PSAY "ALUGUEL SALAS"
				@LI,150 PSAY nValAlug                          PICTURE "@E 999,999,999.99"
				LI:=LI+1
				@LI,150 PSAY "------------------"
				LI:=LI+1
				_tot2:=_tot2+nValAlug
				@ LI,150 PSAY _TOT2 PICTURE "@E 999,999,999.99"
				LI := LI + 1
				nPos := aScan(aTotais,{ |X| X[1] == "ALUGUEL SALAS"})
				if nPos == 0
					Aadd(aTotais,{"ALUGUEL DE SALAS",nValAlug,0})
				ELSE
					aTotais[nPos,2] := aTotais[nPos,2] + nValAlug
				Endif
				LI := LI + 1
				DBSELECTAREA("D38")
				DBSETORDER(2)
				IF MV_PAR04==1.AND. ! _Jafechou
					RECLOCK("D38",.T.)
					D38->D38_FILIAL := xFilial("D38")
					D38->D38_DATA   := _PAR02
					D38->D38_TIPO   := "A"
					D38->D38_LOCAL  := _LOCAL
					D38->D38_CESSI  := _CESSI
					D38->D38_QUANT  := 1
					D38->D38_VALOR  := nValAlug
					D38->D38_MOTIVO := "ALUGUEL DE SALAS"
					MSUNLOCK()
				ENDIF
			ENDIF
		ENDIF
		DBSELECTAREA("D35")
		DBSKIP()
	ENDDO
	IF li > 55
		li :=1
		li :=cabec(titulo,cabec2,cabec1,nomeprog,tamanho)
		li:=li+2
	ENDIF
	_TOTGER:=0
	LI:=LI+2
	@ LI,00 PSAY REPLIC("-",220)
	LI:=LI+2
	@ LI,00 PSAY " TOTAIS "
	FOR I:=1 TO LEN(aTotais)
		@LI,64 PSAY aTotais[I,1]+"..........."
		@LI,088 PSAY aTotais[I,2] PICTURE "@E 999,999,999.99"
		IF aTotais[I,3]<>0
		   @LI,108 PSAY "(Qtd.M3)"
		   @LI,115 PSAY aTotais[I,3] PICTURE "@E 999,999,999.99"
        ENDIF
		_TOTGER:=_TOTGER+aTotais[I,2]
		LI:=LI+1
	NEXT
	@LI,088 PSAY " ---------------"
	LI:=LI+1
	@LI,088 PSAY _TOTGER PICTURE "@E 999,999,999.99"
	LI:=LI+2
	@ LI,00 PSAY REPLIC("-",220)
ENDIF




// -----------------T R A N S P O R T A D O R A S  --------------------

IF MV_PAR03 == 2
	*----------------------------------------------------------------------------
	TITULO:= " Valores a Faturar para Transportadoras  "+aMes[Val(mv_par01)]
	Cabec2:=""
	Cabec1:="Transportadora           Fornecedor                Nr.Nota   Dt.Digit.   AL     Qtd.Fiscal   Qtd.Apurada     Qtd.a 20 Graus     Diferenca"
	//Transportadora           Fornecedor                Nr.Nota   Dt.Digit.   AL     Qtd.Fiscal   Qtd.Apururada   Qtd.a 20 Graus     Diferenca"
	//XXXXXX-XXXXXXXXXXXXXXX   XXXXXX-XXXXXXXXXXXXXXX    XXXXXX    99/99/99    XX  9999,999,999    9999,999,999     9999,999,999    9999,999,999
	//0                        26                        52        62          74  78              94               111             127
	li:=56
	_Tot1:=0
	_Tot2:=0
	_Tot3:=0
	_Tot4:=0
	_TotT1:=0
	_TotT2:=0
	_TotT3:=0
	_TotT4:=0
	DBSELECTAREA("TMP3")
	DBGOTOP()
	WHILE ! EOF()
		li :=1
		li :=cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
		li:=li+1
		SB1->(DBSEEK(XFILIAL("SB1")+TMP3->COD))
		@ LI,00 PSAY ALLTRIM(TMP3->COD)+" - "+SB1->B1_DESC
		li:=li+1
		_COD   :=TMP3->COD
		_TRANSP:=TMP3->TRANSP
		SA4->(DBSEEK(XFILIAL("SA4")+TMP3->TRANSP))
		@ LI,00 PSAY SA4->A4_COD+"-"+SUBSTR(SA4->A4_NREDUZ,1,15)
		WHILE _TRANSP == TMP3->TRANSP .AND. ! EOF() .AND. TMP3->COD == _COD
			_FORNECE:=TMP3->FORNECE
			SA2->(DBSEEK(XFILIAL("SA2")+TMP3->FORNECE))
			@ LI,26 PSAY SA2->A2_COD+"-"+SUBSTR(SA2->A2_NREDUZ,1,15)
			WHILE _FORNECE == TMP3->FORNECE .AND. ! EOF() .AND. _TRANSP == TMP3->TRANSP .AND. TMP3->COD == _COD
				@ LI,52 PSAY TMP3->DOC
				@ LI,62 PSAY DTOC(TMP3->DTDIGIT)
				@ LI,74 PSAY TMP3->LOCAL1
				@ LI,78 PSAY TMP3->QUANT   PICTURE "@E 9999,999,999"
				@ LI,94 PSAY TMP3->QTCONV  PICTURE "@E 9999,999,999"
				@ LI,111 PSAY TMP3->QTDECV PICTURE "@E 9999,999,999"
				@ LI,127 PSAY (TMP3->QTDECV - TMP3->QUANT) PICTURE "@E 9999,999,999"
				_TOT1:=_TOT1+ TMP3->QUANT
				_TOT2:=_TOT2+ TMP3->QTCONV
				_TOT3:=_TOT3+ TMP3->QTDECV
				_TOT4:=_TOT4+ (TMP3->QTDECV-TMP3->QUANT)
				li:=li+1
				IF LI > 55
					li :=1
					li :=cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
					li:=li+1
					SB1->(DBSEEK(XFILIAL("SB1")+TMP3->COD))
					@ LI,00 PSAY ALLTRIM(TMP3->COD)+" - "+SB1->B1_DESC
					li:=li+1
					SA4->(DBSEEK(XFILIAL("SA4")+TMP3->TRANSP))
					@ LI,00 PSAY SA4->A4_COD+"-"+SUBSTR(SA4->A4_NREDUZ,1,15)
					SA2->(DBSEEK(XFILIAL("SA2")+TMP3->FORNECE))
					@ LI,26 PSAY SA2->A2_COD+"-"+SUBSTR(SA2->A2_NREDUZ,1,15)
				ENDIF
				DBSELECTAREA("TMP3")
				DBSKIP()
			ENDDO
			li:=li+2
			@ LI,26 PSAY " TOTAIS FORNECEDOR "
			@ LI,78 PSAY  _TOT1 PICTURE "@E 9999,999,999"
			@ LI,94 PSAY  _TOT2 PICTURE "@E 9999,999,999"
			@ LI,111 PSAY _TOT3 PICTURE "@E 9999,999,999"
			@ LI,127 PSAY _TOT4 PICTURE "@E 9999,999,999"
			_TOTT1:=_TOTT1 + _TOT1
			_TOTT2:=_TOTT2 + _TOT2
			_TOTT3:=_TOTT3 + _TOT3
			_TOTT4:=_TOTT4 + _TOT4
			_Tot1:=0
			_Tot2:=0
			_Tot3:=0
			_Tot4:=0
			li:=li+2
		ENDDO
		li:=li+2
		@ LI,00 PSAY " TOTAIS TRANSPORTADORA "
		@ LI,78 PSAY  _TOTT1 PICTURE "@E 9999,999,999"
		@ LI,94 PSAY  _TOTT2 PICTURE "@E 9999,999,999"
		@ LI,111 PSAY _TOTT3 PICTURE "@E 9999,999,999"
		@ LI,127 PSAY _TOTT4 PICTURE "@E 9999,999,999"
		_TotT1:=0
		_TotT2:=0
		_TotT3:=0
		_TotT4:=0
		LI:=LI+1
		@ LI,00 PSAY REPLIC("-",220)
		LI:=LI+1
	ENDDO
	li:=li+2
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif
ms_flush()

oTempTab1:Delete()

oTempTab2:Delete()

oTempTab3:Delete()

RETURN

