#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

#DEFINE  PSAY SAY

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA004
Tela de encerramento de tanque e impressao do mapaoEqualiza notas fiscais 
de saida de acordo com fator 
 
@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCLEA004()

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de variaveis utilizadas no programa atraves da funcao    Ё
//Ё SetPrvt, que criara somente as variaveis definidas pelo usuario,    Ё
//Ё identificando as variaveis publicas do sistema utilizadas no codigo Ё
//Ё Incluido pelo assistente de conversao do AP5 IDE                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetPrvt("_CAREA,_NREC,_CIND,_DTBASE,_PRODUTO,_QTDENT")
SetPrvt("_QTDSAI,_ETRANS,_STRANS,_TVOL20,_TVOL20P,_SAI19")
SetPrvt("_SAI20,_ENT19,_ENT20,_SAI,NPOS,_SAI07")
SetPrvt("_ENT07,_SAI08,_ENT08,_ENT09,_SAI09,_ENT10")
SetPrvt("_SAI10,_ASTRUC,ATAM,_CARQTRB,APERG,CPERG")
SetPrvt("_DATAINI,_DESGARGA,_DESCARGA,CQUERY,_PROD,_VAL1")
SetPrvt("_VAL2,_VAL3,_VAL4,_OBS1,_OBS2,_OBS3")
SetPrvt("_COD,TAMANHO,LIMITE,CDESC1,CDESC2,CDESC3")
SetPrvt("WNREL,NOMEPROG,NLASTKEY,CSTRING,ARETURN,LI")
SetPrvt("LCONTINUA,M_PAG,TITULO,CABEC1,CABEC2,_ACUMU1")
SetPrvt("_ACUMU2,_ACUMU3,_ACUMU4,_SALDO,_PROXSALDO,_ULTIMO")
SetPrvt("_LOCAL,_DIFER,LAJUSTOU,LJATEM,_SALIAS,AREGS")
SetPrvt("I,J,")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salva a integridade dos Arqquivos.                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
_cArea     := Alias()
_nRec      := Recno()
_cInd      := IndexOrd()


_DTBASE	:= DDATABASE
_PRODUTO	:= ""
_QTDENT	:= 0  // Total Entradas
_QTDSAI	:= 0  // Total Saidas
_ETRANS	:= 0
_STRANS	:= 0
_TVOL20	:= 0  // Volume Total a 20 Graus
_TVOL20P	:= 0 // Volume total a 20 Graus proximo dia
_Sai19		:= 0
_Sai20		:= 0
_Ent19		:= 0
_Ent20		:= 0
_Sai		:= "N"
nPos		:= 0
_QTDENT	:= 0
_Sai07		:= 0
_Ent07		:= 0
_Sai08		:= 0
_Ent08		:= 0
_Ent09		:= 0
_Sai09		:= 0
_Ent10		:= 0
_Sai10		:= 0
aTam		:= TamSX3("D3_NFORP")
nTamD3XNF	:= aTam[1]
_Local		:= GETMV("MV_BASEALM",.F.,"")

// CRIA TEMPORARIO PARA ARMAZENAR OS DADOS
_aStruc := {}
aTam := TamSX3("DH6_TANQUE")
AaDd(_aStruc,{ "TANQUE" , "C" , aTam[1],aTam[2] })
aTam := TamSX3("B1_COD")
AaDd(_aStruc,{ "COD" , "C" , aTam[1],aTam[2] })
AaDd(_aStruc,{ "ALTPRO" , "N" ,14,2 })
aTam := TamSX3("DH7_ALTAGU")
AaDd(_aStruc,{ "ALTAGU" , "N" , aTam[1],aTam[2] })
aTam := TamSX3("DH7_VOLAGU")
AaDd(_aStruc,{ "VOLAGU" , "N" , aTam[1],aTam[2] })
aTam := TamSX3("DH7_TEMP")
AaDd(_aStruc,{ "TEMP" , "N" , aTam[1],aTam[2] })
aTam := TamSX3("DH7_AMTEMP")
AaDd(_aStruc,{ "AMTEMP" , "N" , aTam[1],aTam[2] })
AaDd(_aStruc,{ "AMDENS" , "N" ,6,4 })
AaDd(_aStruc,{ "DENS20" , "N" ,6,4 })
AaDd(_aStruc,{ "FATCOR", "N" ,6,4 })
aTam := TamSX3("DH7_VOLPRO")
AaDd(_aStruc,{ "VOLPRO" , "N" , aTam[1],aTam[2] })
aTam := TamSX3("DH6_VOLTUB")
AaDd(_aStruc,{ "VOLTUB" , "N" , aTam[1],aTam[2] })
AaDd(_aStruc,{ "DATA1" , "D" ,8,0 })
aTam := TamSX3("DH4_QTD20G")
AaDd(_aStruc,{ "RECEB" , "N" , aTam[1],aTam[2] })
aTam := TamSX3("DH3_QTD1")
AaDd(_aStruc,{ "VENDAS" , "N" , aTam[1],aTam[2] })
aTam := TamSX3("DH3_QTD1")
AaDd(_aStruc,{ "ETRANS" , "N" , aTam[1],aTam[2] })
aTam := TamSX3("DH3_QTD1")
AaDd(_aStruc,{ "STRANS" , "N" , aTam[1],aTam[2] })
AaDd(_aStruc,{ "OBS" , "C" , 255,0 })

_cArqTrb := Criatrab(_aStruc,.T.)
dbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)
IndRegua("TRB",_cArqTrb,"TANQUE+DTOS(DATA1)+COD",,,"Selecionando Registros...")

_cPerg:="CEA004"
_aRegs:={}

IF ! PERGUNTE(_cPerg,.T.)
	DBSELECTAREA("TRB")
	DBCLOSEAREA()
	Ferase(_cArqTrb+OrdBagExt())
	Ferase(_cArqTrb+".DBF")
	RETURN
ENDIF

SET CENTURY ON
IF MV_PAR03==2
	_DATAINI:=CTOD("01/"+STRZERO(MONTH(DDATABASE),2)+"/"+STRZERO(YEAR(DDATABASE),4))
ELSE
	_DATAINI:=DDATABASE
ENDIF
SET CENTURY OFF

RptStatus({|| RptDetail()})
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RptDetail
 
@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function RptDetail()
Local cAreaTmp	:= GetNextAlias()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Apuracao das  Movimentacoes Internas                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
IF MV_PAR03<>2
	DBSELECTAREA("SD3")
	DBSETORDER(6)
	DBSEEK(XFILIAL('SD3')+DTOS(_DATAINI),.T.)
	SetRegua(Reccount())
	WHILE SD3->D3_FILIAL == XFILIAL('SD3') .AND. SD3->D3_EMISSAO <= DDATABASE .AND. ! EOF()
		IncRegua()
		IF SD3->D3_ESTORNO=="S"
			DbSkip()
			Loop
		Endif
		SB1->(DBSEEK(XFILIAL('SB1')+SD3->D3_COD))
		IF ! EMPTY(SD3->D3_TPMOVAJ) .AND. ! EMPTY(SD3->D3_TANQUE)
			IF VAL(SD3->D3_TM) <=500
				IF ALLTRIM(SD3->D3_TPMOVAJ)=="TR"
					_ETRANS := SD3->D3_QUANT + _ETRANS
				ELSEIF SD3->D3_TPMOVAJ $ "PR"
					_QTDENT := _QTDENT + SD3->D3_QUANT
				ELSEIF SD3->D3_TPMOVAJ $ "BO" .AND. SD3->D3_FATCOR<>0
					_QTDENT := _QTDENT + SD3->D3_QUANT
				ELSE
					DBSELECTAREA("SD3")
					DbSkip()
					Loop
				ENDIF
			ELSE
				IF ALLTRIM(SD3->D3_TPMOVAJ)=="TR"
					_STRANS := SD3->D3_QUANT + _STRANS
				ELSEIF SD3->D3_TPMOVAJ $ "PR"
					_QTDSAI := _QTDSAI + SD3->D3_QUANT
				ELSEIF SD3->D3_TPMOVAJ $ "BO" .AND. SD3->D3_FATCOR<>0
					_QTDENT := _QTDENT - SD3->D3_QUANT
				ELSE
					DBSELECTAREA("SD3")
					DbSkip()
					Loop
				ENDIF
			ENDIF
		ELSE
			DBSELECTAREA("SD3")
			DbSkip()
			Loop
		ENDIF
		
		DBSELECTAREA("TRB")
		IF ! DBSEEK(SD3->D3_TANQUE+DTOS(SD3->D3_EMISSAO)+SD3->D3_COD)
			RECLOCK("TRB",.T.)
			TRB->TANQUE	:= SD3->D3_TANQUE
			TRB->COD		:= SD3->D3_COD
			TRB->DATA1		:= SD3->D3_EMISSAO
			TRB->ETRANS	:= _ETRANS
			TRB->STRANS	:= _STRANS
			TRB->RECEB		:= _QTDENT
			TRB->VENDAS	:= _QTDSAI
		ELSE
			DBSELECTAREA("SD3")
			DBSELECTAREA("TRB")
			RECLOCK("TRB",.F.)
			TRB->ETRANS:=_ETRANS +TRB->ETRANS
			TRB->STRANS:=_STRANS +TRB->STRANS
			TRB->RECEB  :=_QTDENT  +TRB->RECEB
			TRB->VENDAS :=_QTDSAI  +TRB->VENDAS
		ENDIF
		
		_QTDENT:=0  // Total Entradas
		_QTDSAI:=0  // Total Saidas
		_ETRANS:=0 // Entr. Transf
		_STRANS:=0    // SAIDA TRANSF.
		DBUNLOCK()
		DBSELECTAREA("SD3")
		DBSKIP()
	ENDDO
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fim da apuracao das movimentacoes internas                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicio da apuracao das Notas Fiscais de Entrada              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DBSELECTAREA("DH4")
	DBsetorder(6)
	DBSEEK(XFILIAL('DH4')+DTOS(_DATAINI),.T.)
	SetRegua(Reccount())
	WHILE DH4->DH4_DTENT  <= DDATABASE .AND. ! EOF() .AND. DH4->DH4_FILIAL == XFILIAL('DH4')
		IncRegua()
		
		DBSELECTAREA("TRB")
		IF ! DBSEEK(DH4->DH4_TANQUE+DTOS(DH4->DH4_DTENT)+DH4_->DH4_CODPRO)
			RECLOCK("TRB",.T.)
			TRB->TANQUE	:= DH4->DH4_TANQUE
			TRB->COD		:= DH4->DH4_CODPRO
			TRB->DATA1		:= DH4->DH4_DTENT
			TRB->RECEB		:= DH4->DH4_QTD20G
		ELSE
			RECLOCK("TRB",.F.)
			TRB->RECEB  :=DH4->DH4_QTD20G + TRB->RECEB
		ENDIF
		MSUNLOCK()
		
		MSUNLOCK()
		_QTDENT:=0  // Total Entradas
		_QTDSAI:=0  // Total Saidas
		_ETRANS:=0 // Entr. Transf
		_STRANS:=0 // Saida Transf.
		DBSELECTAREA("SD1")
		DBSKIP()
	ENDDO
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fim da apuracao das notas fiscais de Entrada                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicio da Apuracao das notas fiscais de saidas               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	//здддддддддддддддддддддддддддддд©
	//Ё MONTA QUERY PARA CONSULTA SD2Ё
	//юдддддддддддддддддддддддддддддды

	cQuery := " Select SF2.F2_EMISSAO DATA1,DH3.DH3_TANQ1 TQ1,DH3.DH3_TANQ2 TQ2,DH3.DH3_TANQ3 TQ3,SD2.D2_COD COD, SUM(DH3.DH3_QTD1) QTD1, SUM(DH3.DH3_QTD2) QTD2, SUM(DH3.DH3_QTD3) QTD3 " 
	cQuery += " FROM " + RetSqlName("SF2")+ " SF2 " 
	cQuery += " Inner Join " + RetSqlName("SD2")+ " SD2 " 
	cQuery += " 	On SF2.F2_FILIAL = SD2.D2_FILIAL and SF2.F2_DOC = SD2.D2_DOC and SF2.F2_SERIE = SD2.D2_SERIE and SF2.F2_EMISSAO = SD2.D2_EMISSAO "
	cQuery += " Inner Join " + RetSqlName("DH3")+ " DH3 " 
	cQuery += " 	On SD2.D2_FILIAL = DH3.DH3_FILIAL and SD2.D2_DOC = DH3.DH3_DOCD2 and SD2.D2_SERIE = DH3.DH3_SERIE and SD2.D2_ITEM = DH3.DH3_ITEM "
 	cQuery += " WHERE SF2.F2_EMISSAO >= '"+DTOS(DDATABASE)+"' AND  SF2.F2_EMISSAO <= '"+DTOS(DDATABASE)+"' AND "
	cQuery += "       SF2.F2_FILIAL  = '"+xFilial("SF2")+"' AND "
	cQuery += "       SF2.D_E_L_E_T_  <> '*' AND  SD2.D_E_L_E_T_  <> '*'  AND  DH3.D_E_L_E_T_  <> '*' "
	cQuery += " GROUP BY SF2.F2_EMISSAO,DH3.DH3_TANQ1,DH3.DH3_TANQ2,DH3.DH3_TANQ3,SD2.D2_COD "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAreaTmp, .T., .T. )
	
		
	DBGOTOP()
	SetRegua(Reccount())
	WHILE ! EOF()
		IncRegua()
		SB1->(DBSEEK(XFILIAL('SB1')+(cAreaTmp)->COD))
		IF SB1->B1_X_REQUI <> "S"
			DBSELECTAREA("TRB")
			IF ! DBSEEK((cAreaTmp)->TQ1+(cAreaTmp)->DATA1+(cAreaTmp)->COD)
				RECLOCK("TRB",.T.)
				TRB->TANQUE :=(cAreaTmp)->TQ1
				TRB->COD    :=(cAreaTmp)->COD
				TRB->DATA1   :=CTOD(SUBSTR((cAreaTmp)->DATA1,7,2)+"/"+SUBSTR((cAreaTmp)->DATA1,5,2)+"/"+SUBSTR((cAreaTmp)->DATA1,3,2))
				TRB->VENDAS :=(cAreaTmp)->QTD1
			ELSE
				RECLOCK("TRB",.F.)
				TRB->VENDAS  :=(cAreaTmp)->QTD1 + TRB->VENDAS
			ENDIF
			MSUNLOCK()
		ELSE
			DBSELECTAREA("SG1")
			Dbsetorder(5)
			DBSEEK(XFILIAL('SG1')+(cAreaTmp)->COD+(cAreaTmp)->DATA1,.T.)
			dFim:=SG1->G1_FIM
			WHILE (cAreaTmp)->COD == SG1->G1_COD .AND. ! EOF() .AND. dFim == SG1->G1_FIM .AND. SG1->G1_FILIAL = XFILIAL('SG1')
				DBSELECTAREA("TRB")
				_SEQ:=SUBSTR(SG1->G1_TRT,3,1)
				_Tanque:="(cAreaTmp)->TQ"+_SEQ
				_QTD:="(cAreaTmp)->QTD"+_SEQ
				IF ! DBSEEK(&(_Tanque)+(cAreaTmp)->DATA1+SG1->G1_COMP)
					RECLOCK("TRB",.T.)
					TRB->TANQUE :=&(_Tanque)
					TRB->VENDAS :=&(_QTD)
					TRB->COD    :=SG1->G1_COMP
					TRB->DATA1   :=CTOD(SUBSTR((cAreaTmp)->DATA1,7,2)+"/"+SUBSTR((cAreaTmp)->DATA1,5,2)+"/"+SUBSTR((cAreaTmp)->DATA1,3,2))
				ELSE
					RECLOCK("TRB",.F.)
					TRB->VENDAS :=&(_QTD) + TRB->VENDAS
				ENDIF
				MSUNLOCK()
				DBSELECTAREA("SG1")
				DBSKIP()
			ENDDO
		ENDIF
		DBSKIP()
	ENDDO
		
	// Fim da Apuracao das notas fiscais de saidas  

	(cAreaTmp)->(dbCloseArea())

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Busca Medicoes Diarias                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DBSELECTAREA("DH7")  // MEDICOES DIARIAS
	SetRegua(Reccount())
	DBSETORDER(1)
	DBSEEK(XFILIAL('DH7')+DTOS(_DATAINI),.T.)
	WHILE DH7->DH7_DATAME <= DDATABASE .AND. ! EOF() .AND. DH7->DH7_FILIAL == XFILIAL('DH7')
		IncRegua()
		DBSELECTAREA("DH6")
		DBSETORDER(1)
		DBSEEK(XFILIAL('DH6')+DH7->DH7_TANQUE)
		
		DBSELECTAREA("TRB")
		IF ! DBSEEK(DH7->DH7_TANQUE+DTOS(DH7->DH7_DATAME))
			RECLOCK("TRB",.T.)
			TRB->TANQUE	:=DH7->DH7_TANQUE
			TRB->COD		:=DH7->DH7_CODPRO
			TRB->DATA1		:=DH7->DH7_DATAME
			TRB->ALTPRO	:=DH7->DH7_ALTPRO
			TRB->ALTAGU	:=DH7->DH7_ALTAGU
			TRB->VOLAGU	:=DH7->DH7_VOLAGU
			TRB->TEMP		:=DH7->DH7_TEMP
			TRB->AMTEMP	:=DH7->DH7_AMTEMP
			TRB->AMDENS	:=DH7->DH7_AMDENS
			TRB->DENS20	:=DH7->DH7_DENS20
			TRB->FATCOR	:=DH7->DH7_FATCOR
			TRB->VOLPRO	:=DH7->DH7_VOLPRO
			TRB->VOLTUB	:=DH6->DH6_VOLTUB
			TRB->OBS		:=DH7->DH7_OBS
			DBUNLOCK()
		ELSE
			RECLOCK("TRB",.F.)
			TRB->TANQUE	:=DH7->DH7_TANQUE
			TRB->COD		:=DH7->DH7_CODPRO
			TRB->DATA1		:=DH7->DH7_DATAME
			TRB->ALTPRO	:=DH7->DH7_ALTPRO
			TRB->ALTAGU	:=DH7->DH7_ALTAGU
			TRB->VOLAGU	:=DH7->DH7_VOLAGU
			TRB->TEMP		:=DH7->DH7_TEMP
			TRB->AMTEMP	:=DH7->DH7_AMTEMP
			TRB->AMDENS	:=DH7->DH7_AMDENS
			TRB->DENS20	:=DH7->DH7_DENS20
			TRB->FATCOR	:=DH7->DH7_FATCOR
			TRB->VOLPRO	:=DH7->DH7_VOLPRO
			TRB->VOLTUB	:=DH6->DH6_VOLTUB
			TRB->ETRANS	:=_ETRANS +TRB->ETRANS
			TRB->STRANS	:=_STRANS +TRB->STRANS
			TRB->RECEB		:=_QTDENT  +TRB->RECEB
			TRB->VENDAS	:=_QTDSAI  +TRB->VENDAS
			TRB->OBS		:=DH7->DH7_OBS
			DBUNLOCK()
		ENDIF
		DBSELECTAREA("DH7")
		DBSKIP()
	ENDDO
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fim da busca medicoes diarias                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё ALIMENTA TANQUES QUE DESATIVADOS                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DBSELECTAREA("DH6")
	DBSETORDER(1)
	IF DBSEEK(XFILIAL('DH6')+MV_PAR01)
		SetRegua(RecCount())
		WHILE DH6->(!EOF()) .AND. DH6->DH6_FILIAL == XFILIAL('DH6') .AND. DH6->DH6_TANQUE >= MV_PAR01 .AND. DH6->DH6_TANQUE <= MV_PAR02
			IncRegua()
			DBSELECTAREA("TRB")
			IF ! DBSEEK(DH6->DH6_TANQUE)
				RECLOCK("TRB",.T.)
					TRB->TANQUE	:= DH6->DH6_TANQUE
					TRB->COD		:= DH6->DH6_CODPRO
					TRB->DATA1		:= _DATAINI
				MSUNLOCK()
			ENDIF
			DH6->(DBSKIP())
		ENDDO
	ENDIF
ENDIF

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Impressao do relatorio em tela                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
IF MV_PAR03 == 1
	#IFDEF WINDOWS
		DBSELECTAREA("TRB")
		DBGOTOP()
		WHILE ! EOF()
			IF EMPTY(TRB->TANQUE)
				DBSKIP()
				LOOP
			ENDIF
			
			@ 060,74 To 400,574 Dialog tela Title OemToAnsi("Tela Encerrerramento de Tanques     Data: "+DTOC(_DTBASE))
			@ 3,4 To 25,243
			@  10,10 SAY "TANQUE.....: "+TRB->TANQUE SIZE 200,50
			DBSELECTAREA("SB1")
			DBSETORDER(1)
			DBSEEK(XFILIAL('SB1')+TRB->COD)
			DBSELECTAREA("TRB")
			_Val1:=0
			_Val2:=0
			_Val3:=0
			_Val4:=0
			_OBS1:=SUBSTR(TRB->OBS,1,85)
			_OBS2:=SUBSTR(TRB->OBS,86,85)
			_OBS3:=SUBSTR(TRB->OBS,171,85)
			
			@  10,100 SAY "PRODUTO...: "+ALLTRIM(TRB->COD)+" - "+SB1->B1_DESC SIZE 200,50
			@  30,10  SAY " 1 - Vol. a 20 Graus na Data Base.....: " SIZE 200,50
			@  30,120 SAY ((TRB->VOLPRO-TRB->VOLAGU)+TRB->VOLTUB)*TRB->FATCOR PICTURE "@E 999,999,999.99" SIZE 200,50
			@  45,10 SAY " 2 - Total de Entradas.........................: " SIZE 200,50
			@  45,120 SAY TRB->RECEB+TRB->ETRANS PICTURE "@E 999,999,999.99" SIZE 200,50
			@  60,10 SAY " 3 - Total de Saidas............................: " SIZE 200,50
			@  60,120 SAY TRB->STRANS + TRB->VENDAS PICTURE "@E 999,999,999.99" SIZE 200,50
			@  75,10 SAY " 4 - Vol. a 20 Graus no Proximo Dia...: " SIZE 200,50
			
			_Val1:=((TRB->VOLPRO-TRB->VOLAGU)+TRB->VOLTUB)*TRB->FATCOR
			_Val2:=TRB->RECEB+TRB->ETRANS
			_Val3:=TRB->STRANS + TRB->VENDAS
			
			_TVOL20P:=0
			
			DBSELECTAREA("DH6")
			DBSETORDER(1)
			DBSEEK(XFILIAL('DH6')+TRB->TANQUE+TRB->COD)
			DBSELECTAREA("DH7")
			DBSETORDER(1)
			IF DBSEEK(XFILIAL('DH7')+DTOS(TRB->DATA1)+TRB->COD+TRB->TANQUE)
				SD3->(DbSetorder(16))
				IF SD3->(DBSEEK(XFILIAL('SD3')+SPACE(nTamD3XNF)+"AP"+" "+DTOS(DH7->DH7_DATAME)+DH6->DH6_CODPRO+_LOCAL+DH6->DH6_TANQUE))
					WHILE XFILIAL('SD3')==SD3->D3_FILIAL .AND.;
						SD3->D3_X_TMT == 'AP' .AND.;
						SD3->D3_EMISSAO == DH7->DH7_DATAME .AND.;
						SD3->D3_COD == DH6->DH6_CODPRO .AND.;
						SD3->D3_LOCAL == _LOCAL .AND.;
						SD3->D3_X_TQ  == DH6->DH6_TANQUE
						IF SD3->D3_ESTORNO <> 'S'
							_Gravado:=IIF(SD3->D3_TM>"500",-SD3->D3_QUANT,SD3->D3_QUANT)
							EXIT
						ENDIF
						SD3->(DBSKIP())
					ENDDO
				ELSE
					_Gravado:=0
				ENDIF
				
				_TVOL20:=(DH7->DH7_VOLPRO - DH7->DH7_VOLAGU + DH6->DH6_VOLTUB) * DH7->DH7_FATCOR
				DBSKIP()
				WHILE ! EOF()
					IF TRB->TANQUE == DH7->DH7_TANQUE .AND. DH7->DH7_CODPRO == TRB->COD
						_TVOL20P:=(DH7->DH7_VOLPRO - DH7->DH7_VOLAGU + DH6->DH6_VOLTUB) * DH7->DH7_FATCOR
						EXIT
					ENDIF
					DBSKIP()
				ENDDO
			Else
				SD3->(DbSetOrder(16))
				IF SD3->(DBSEEK(XFILIAL('SD3')+SPACE(nTamD3XNF)+"AP"+" "+DTOS(DDATABASE)+DH6->DH6_CODPRO + _LOCAL + DH6->DH6_TANQUE))
					WHILE XFILIAL('SD3')==SD3->D3_FILIAL .AND.;
						SD3->D3_X_TMT == 'AP' .AND.;
						SD3->D3_EMISSAO == DDATABASE .AND.;
						SD3->D3_COD == DH6->DH6_COD .AND.;
						SD3->D3_LOCAL == _LOCAL .AND.;
						SD3->D3_X_TQ  == DH6->DH6_TANQUE
						IF SD3->D3_ESTORNO<>'S'
							_Gravado:=IIF(SD3->D3_TM>"500",-SD3->D3_QUANT,SD3->D3_QUANT)
							EXIT
						ENDIF
						SD3->(DBSKIP())
					ENDDO
				ELSE
					_Gravado:=0
				ENDIF
				
				DBSEEK(XFILIAL('SD3')+DTOS(TRB->DATA1+1)+ TRB->TANQUE + TRB->COD,.T.)
				WHILE ! EOF()
					IF DH7->DH7_TANQUE == TRB->TANQUE .AND. DH7->DH7_COD == TRB->COD
						_TVOL20P:=(DH7->DH7_VOLPRO - DH7->DH7_VOLAGU + DH6->DH6_VOLTUB) * DH7->DH7_FATCOR
						EXIT
					ENDIF
					DBSKIP()
				ENDDO
			ENDIF
			
			_VAL4:=_TVOL20P
			@ 75,120 SAY _TVOL20P PICTURE "@E 999,999,999.99" SIZE 200,50
			@  90,10 SAY " 5 - SOBRA PERDA( 4 - (1+2-3)): " SIZE 200,50
			@  90,120 SAY (_Val4-(_Val1+_Val2-_Val3))  PICTURE "@E 999,999,999.99" SIZE 200,50
			
			@ 105,10 SAY " Quant. do ajuste gravado para o dia : " SIZE 200,50
			@ 105,122 SAY _GRAVADO PICTURE "@E 999,999,999.99" SIZE 200,50
			

			@ 030,195 BUTTON "Prox ->" SIZE 35,15 ACTION Proximo()// Substituido pelo assistente de conversao do AP5 IDE em 21/01/01 ==> 	    @ 050,195 BUTTON "Prox ->" SIZE 35,15 ACTION Execute(Proximo)
			@ 050,195 BUTTON "Ant <- " SIZE 35,15 ACTION Anterior()// Substituido pelo assistente de conversao do AP5 IDE em 21/01/01 ==> 	    @ 070,195 BUTTON "Ant <- " SIZE 35,15 ACTION Execute(Anterior)
			@ 070,200 BmpButton Type 2 Action Abandona()// Substituido pelo assistente de conversao do AP5 IDE em 21/01/01 ==> 	    @ 090,200 BmpButton Type 2 Action Execute(Abandona)
			@ 090,200 BmpButton Type 1 Action Grava()// Substituido pelo assistente de conversao do AP5 IDE em 21/01/01 ==> 	    @ 030,200 BmpButton Type 1 Action Execute(Grava)
			
			
			@ 135,10 SAY "OBS:"
			@ 135,30 GET _OBS1
			@ 145,30 GET _OBS2
			@ 155,30 GET _OBS3
			Activate Dialog tela
			DBSELECTAREA("TRB")
		ENDDO
	#ENDIF
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Impressao do relatorio Mapao  Na impressora                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ELSE
	
	Tamanho   := "G"
	Limite    := 220
	cDesc1    := PadC(" Relatorio de Movimento dos Tanques ",74)
	cDesc2    := ""
	cDesc3    := ""
	wnrel     := "CEA004"
	nomeprog  := "DCLEA004"
	nLastkey  :=  0
	cString   := "DH6"
	aReturn   := {"Branco",1,"Comercial",2,2,1,"",1}
	li        :=  66
	lContinua := .T.
	m_pag     := 1
	Titulo    := PadC("Movimento de Tanques Data Base: "+Dtoc(_DTBASE),74)
	
	wnrel := SetPrint(cString,wnrel,_cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.F.,Tamanho,.F.)
	If nLastKey == 27
		DBSELECTAREA("TRB")
		DBCLOSEAREA()
		Ferase(_cArqTrb+OrdBagExt())
		Ferase(_cArqTrb+".DBF")
		Return
	Endif
	
	SetDefault(aReturn,cString)
	If nLastKey == 27
		DBSELECTAREA("TRB")
		DBCLOSEAREA()
		Ferase(_cArqTrb+OrdBagExt())
		Ferase(_cArqTrb+".DBF")
		Return
	Endif

	Cabec1:="Dt|Med(mm)|    |Temp. |Vol. |    Amostra   |Dens. |Ft.Cr.|   ESTOQUE FISICO INICIAL (Litros)   |       E N T R A D A S (Litros)     |     S A I D A S (Litros)            | Saldo   |            PERDAS/SOBRAS              |"
	Cabec2:="  |Al.Tot.|Agua|Media |Agua | Temp.   Dens.|20  G | Vol. | No Tanque  Na Tub. Tot.Amb. Tot.20G | Receb.  Tranf.  Total     Acumul.  | Vendas    Transf.   Total    Acumul.| Teorio  |  No Dia     Acuml.    %Dia    %Acuml. |"		


	li:=66
	DBSELECTAREA("DH6")
	DBSETORDER(1)
	DBSEEK(XFILIAL('DH6')+MV_PAR01)
	
	WHILE DH6->DH6_FILIAL == XFILIAL('DH6') .AND. DH6->DH6_TANQUE <= MV_PAR02 .AND. ! EOF()
		
		li:=1
		SB1->(DBSEEK(XFILIAL('SB1')+DH6->DH6_CODPRO))
		Titulo    := PadC("Movimento dos Tanques-> " +DH6->DH6_TANQUE+" Data Base: "+Dtoc(_DTBASE)+" Produto "+ALLTRIM(DH6->DH6_CODPRO)+" "+SUBSTR(SB1->B1_DESC,1,20),74)
		li :=cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
		LI:=li+1
		_acumu1:=0
		_acumu2:=0
		_acumu3:=0
		_acumu4:=0
		
		DBSELECTAREA("DH7")  // MEDICOES DIARIAS
		SetRegua(Reccount())
		DBSETORDER(2)
		DBSEEK(XFILIAL('DH7')+DH6->DH6_TANQUE+DH6->DH6_CODPRO+DTOS(_DATAINI),.T.)
		WHILE DH7->DH7_TANQUE == DH6->DH6_TANQUE .AND. DH7->DH7_CODPRO == DH6->DH6_CODPRO .AND. DH7->DH7_DATAME <= DDATABASE .AND. DH7->DH7_FILIAL ==XFILIAL('DH7')
			
			Titulo    := PadC("Movimento dos Tanque-> " +DH6->DH6_TANQUE+" Data Base: "+Dtoc(_DTBASE)+" Produto "+ALLTRIM(TRB->COD)+" "+SUBSTR(SB1->B1_DESC,1,20),74)
			Cabec1:="Dt|Med(mm)|    |Temp. |Vol. |    Amostra   |Dens. |Ft.Cr.|   ESTOQUE FISICO INICIAL (Litros)   |       E N T R A D A S (Litros)     |     S A I D A S (Litros)            | Saldo   |            PERDAS/SOBRAS              |"
			Cabec2:="  |Al.Tot.|Agua|Media |Agua | Temp.   Dens.|20  G | Vol. | No Tanque  Na Tub. Tot.Amb. Tot.20G | Receb.  Tranf.  Total     Acumul.  | Vendas    Transf.   Total    Acumul.| Teorio  |  No Dia     Acuml.    %Dia    %Acuml. |"		

			
			IncRegua()
			If li > 60
				li :=1
				SB1->(DBSEEK(XFILIAL('SB1')+DH6->DH6_COD))
				DBSELECTAREA("DH7")
				Titulo    := PadC("Movimento dos Tanques-> " +DH6->DH6_TANQUE+" Data Base: "+Dtoc(_DTBASE)+" Produto "+ALLTRIM(TRB->COD)+" "+SUBSTR(SB1->B1_DESC,1,20),74)
				li :=cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
				LI:=li+1
				_acumu1:=0
				_acumu2:=0
				_acumu3:=0
				_acumu4:=0
			EndIf
			
			_ACUMU1:=_ACUMU1+DH7->DH7_ENTRAD+DH7->DH7_ETRANS
			_ACUMU2:=_ACUMU2+DH7->DH7_SAIDA+DH7->DH7_STRANS
			
			@ LI,000 PSAY STRZERO(DAY(DH7->DH7_DATAME),2)
			@ li,002 PSAY "|"
			@ li,003 PSAY DH7->DH7_ALTPRO+DH7->DH7_ALTAGU PICTURE "@E 9999.99"
			@ li,010 PSAY "|"
		 	@ li,011 PSAY DH7->DH7_ALTAGU PICTURE "@E 9999"
			@ li,015 PSAY "|"
   			@ li,016 PSAY DH7->DH7_TEMP PICTURE "@E 999.99"
			@ li,022 PSAY "|"
			@ li,023 PSAY DH7->DH7_VOLAGU PICTURE "@E 99999"
			@ li,028 PSAY "|"
			@ li,029 PSAY DH7->DH7_AMTEMP PICTURE "@E 999.99"
			@ li,037 PSAY DH7->DH7_AMDENS PICTURE "@E 9.9999"
			@ li,043 PSAY "|"
			@ li,044 PSAY DH7->DH7_DENS20 PICTURE "@E 9.9999"
			@ li,050 PSAY "|"
			@ li,051 PSAY DH7->DH7_FATCOR PICTURE "@E 9.9999"
			@ li,057 PSAY "|"
			@ li,058 PSAY DH7->DH7_VOLPRO - DH7->DH7_VOLAGU PICTURE "@E 9,999,999"
			@ li,068 PSAY DH6->DH6_VOLTUB PICTURE "@E 9999,999"
			@ li,077 PSAY (DH7->DH7_VOLPRO-DH7->DH7_VOLAGU)+DH6->DH6_VOLTUB  PICTURE "@E 9999,999"
			@ li,086 PSAY ((DH7->DH7_VOLPRO-DH7->DH7_VOLAGU)+DH6->DH6_VOLTUB)*DH7->DH7_FATCOR PICTURE "@E 9999,999"
			_Saldo:=(((DH7->DH7_VOLPRO-DH7->DH7_VOLAGU)+DH6->DH6_VOLTUB)*DH7->DH7_FATCOR)+(DH7->DH7_ENTRAD+DH7->DH7_ETRANS) - (DH7->DH7_STRANS + DH7->DH7_SAIDA)
			dbskip()
			IF ! EOF()
				_ProxSaldo:=0
				_ultimo:="N"
				IF DH7->DH7_TANQUE == DH6->DH6_TANQUE .AND. DH6->DH6_COD == DH6->DH6_COD
					_ProxSaldo:=((DH7->DH7_VOLPRO-DH7->DH7_VOLAGU)+DH6->DH6_VOLTUB)*DH7->DH7_FATCOR
				ELSE
					_ultimo:="S"
				ENDIF
				dbskip(-1)
			ELSE
				_ultimo:="S"
			ENDIF
			IF _ULTIMO <> "S"
				@ li,095 PSAY "|"
				@ li,096 PSAY DH7->DH7_ENTRAD PICTURE "@E 9999,999"
				@ li,105 PSAY DH7->DH7_ETRANS PICTURE "@E 999999"
				@ li,112 PSAY DH7->DH7_ENTRAD+DH7->DH7_ETRANS PICTURE "@E 9999,999"
				@ li,121 PSAY _ACUMU1 PICTURE "@E 99,999,999"
				@ li,132 PSAY "|"
				@ li,133 PSAY DH7->DH7_SAIDA  PICTURE "@E 9999,999"
				@ li,142 PSAY DH7->DH7_STRANS PICTURE "@E 999,999"
				@ li,150 PSAY DH7->DH7_STRANS + DH7->DH7_SAIDA PICTURE "@E 9999,999"
				@ li,159 PSAY _ACUMU2 PICTURE "@E 99,999,999"
				@ li,170 PSAY "|"
				@ li,171 PSAY (((DH7->DH7_VOLPRO-DH7->DH7_VOLAGU)+DH6->DH6_VOLTUB)*DH7->DH7_FATCOR)+(DH7->DH7_ENTRAD+DH7->DH7_ETRANS)-(DH7->DH7_STRANS + DH7->DH7_SAIDA) PICTURE "@E 99999,999"
				_acumu3:=_acumu3+(_ProxSaldo - _Saldo)
				@ li,180 PSAY "|"
				@ li,181 PSAY (_ProxSaldo - _Saldo) PICTURE "@E 99999,999"
	   			@ li,191 PSAY _acumu3 PICTURE  "@E 99999999"
				_totper1:=IIF(DH7->DH7_STRANS+DH7->DH7_SAIDA<>0,((_ProxSaldo - _Saldo)/(DH7->DH7_STRANS+DH7->DH7_SAIDA))*100,0)
				_totper2:=IIF(_ACUMU2<>0,(_ACUMU3/_ACUMU2)*100,0)
				@ li,200 PSAY IIF(_TOTPER1>0,_TOTPER1,_TOTPER1*-1) PICTURE "@E 999999.99"
				@ li,210 PSAY IIF(_TOTPER2>0,_TOTPER2,_TOTPER2*-1) PICTURE "@E 999999.99"
				
			ENDIF
			DBSKIP()
			LI:=li+1
			@LI,00 PSAY REPLIC("-",220)
			LI:=li+1
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё IMPRESSAO DAS OBSERVACOES DIARIAS DOS MAPAS                               Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			
			IF (_ULTIMO == "S" .OR. DH7->DH7_DATAME > DDATABASE .OR. EOF()) .AND. MV_PAR04 == 1
				DBSELECTAREA("DH7")  // MEDICOES DIARIAS
				SetRegua(Reccount())
				DBSETORDER(2)
				DBSEEK(XFILIAL('DH7')+DH6->DH6_TANQUE+DH6->DH6_COD+DTOS(_DATAINI),.T.)
				
				li:=61
				WHILE DH7->DH7_TANQUE == DH6->DH6_TANQUE .AND. DH7->DH7_COD == DH6->DH6_COD .AND. DH7->DH7_DATAME <= DDATABASE .AND. ! EOF() .AND. DH7->DH7_FILIAL == XFILIAL('DH7')
					Cabec1:= "  Detalhamento das observacoes Diarias do tanque em questao "
					Cabec2:=""
					
					If li > 60
						li :=1
						li :=cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
						LI:=li+1
					EndIf
					
					@ li,00 PSAY DTOC(DH7->DH7_DATAME)+" - "+ALLTRIM(SUBSTR(DH7->DH7_OBS,1,85))+" "+ALLTRIM(SUBSTR(DH7->DH7_OBS,86,85))+" "+ALLTRIM(SUBSTR(DH7->DH7_OBS,171,85))
					li:=li+1
					@ li,00 PSAY REPLIC("_",220)
					li:=li+1
					DBSKIP()
					
				ENDDO
				Cabec1:="Dt|Med(mm)|    |Temp. |Vol. |    Amostra   |Dens. |Ft.Cr.|   ESTOQUE FISICO INICIAL (Litros)   |       E N T R A D A S (Litros)     |     S A I D A S (Litros)            | Saldo   |            PERDAS/SOBRAS              |"
				Cabec2:="  |Al.Tot.|Agua|Media |Agua | Temp.   Dens.|20  G | Vol. | No Tanque  Na Tub. Tot.Amb. Tot.20G | Receb.  Tranf.  Total     Acumul.  | Vendas    Transf.   Total    Acumul.| Teorio  |  No Dia     Acuml.    %Dia    %Acuml. |"				
				LI:=61
			ENDIF
			
			IF _ULTIMO == "S"
				li:=61
				EXIT
			ENDIF
		ENDDO
		DBSELECTAREA("DH6")
		DBSKIP()
	ENDDO
	
	Roda(0," ",Tamanho)
	Set device to Screen
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se em disco, desvia para Spool                                            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif
	ms_flush()
ENDIF

DBSELECTAREA("TRB")
DBCLOSEAREA()
Ferase(_cArqTrb+OrdBagExt())
Ferase(_cArqTrb+".DBF")
RETURN



//-------------------------------------------------------------------
/*/{Protheus.doc} GRAVA

@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Static FUNCTION GRAVA()
lOk:=.T.
DBSELECTAREA("SF5")
Dbsetorder(2)
IF ! DBSEEK(XFILIAL('SF5')+"AP"+"R")
	MsgBox("Movimentos Internos Requisicao para Apuracao nao cadastrado","Atencao","info")
	lOk:=.F.
ELSE
	_TMR:=SF5->F5_CODIGO
ENDIF

IF ! DBSEEK(XFILIAL('SF5')+"AP"+"D")
	MsgBox("Movimentos Internos Devolucao para Apuracao nao cadastrado","Atencao","info")
	lOk:=.F.
ELSE
	_TMD:=SF5->F5_CODIGO
ENDIF
DBSELECTAREA("SF5")
DBSETORDER(1)

Begin Transaction

IF lOk
	IF MsgYesNo(" Confirma Fechamento do Tanque ") .AND. lOk
		IF DDATABASE > GETMV("MV_ULMES",.F.,CtoD(""))
			DBSELECTAREA("DH7")
			DBSETORDER(1)
			IF DBSEEK(XFILIAL('DH7')+DTOS(TRB->DATA1)+TRB->COD+TRB->TANQUE)
				RECLOCK("DH7",.F.)
				DH7->DH7_OBS:=_OBS1+_OBS2+_OBS3
				MSUNLOCK()
				DBSELECTAREA("SD3")
				Dbsetorder(16)
				_Local := GETMV("MV_BASEALM",.F.,"")
				_DIFER:=(_Val4-(_Val1+_Val2-_Val3))
				IF SD3->(DBSEEK(XFILIAL('SD3')+SPACE(nTamD3XNF)+"AP"+" "+DTOS(DDATABASE)+DH7->DH7_CODPRO+_LOCAL+DH7->DH7_TANQUE))
					
					SF5->(DBSEEK(XFILIAL('SF5')+SD3->D3_TM))
					_QUANT:=IIF(SF5->F5_TIPO=='R',-SD3->D3_QUANT,SD3->D3_QUANT)
					IF _QUANT <> _DIFER
						IF MSGYESNO(" Tanque ja Encerrado neste Dia !!! Confirma Alteracao de Valores ??")
							DBSELECTAREA("DH7")
							RECLOCK("DH7",.F.)
							DH7->DH7_ENTRAD	:=TRB->RECEB
							DH7->DH7_SAIDA	:=TRB->VENDAS
							DH7->DH7_ETRANS	:=TRB->ETRANS
							DH7->DH7_STRANS	:=TRB->STRANS
							
							IF (_Val4-(_Val1+_Val2-_Val3))<>0
									LB3->LB3_SOBRA  :=(_Val4-(_Val1+_Val2-_Val3))
								ELSE
									LB3->LB3_SOBRA  :=0
								ENDIF
								MSUNLOCK()
								
								lMsErroAuto:=.F.
								aVetor :=	{{"D3_NUMSEQ"	,SD3->D3_NUMSEQ	,NIL},;
											 {"D3_CHAVE"	,SD3->D3_CHAVE	,NIL},;
											 {"D3_COD"		,SD3->D3_COD		,NIL},;
						           		 {"INDEX"		,4					,NIL}}
								MSExecAuto({|x,y| MATA240(x,y)},aVetor,5) // Estorno
								If lMsErroAuto
									MOSTRAERRO()
									DisarmTransaction()
								EndIf

								lMsErroAuto:=.F.
								SB1->(DBSEEK(XFILIAL('SB1')+LB3->LB3_COD))
								
								aVetor:={ {"D3_TM"     ,IIF(_Difer>0,_TMD,_TMR),NIL},;
								{"D3_COD"    ,LB3->LB3_COD,NIL},;
								{"D3_QUANT"  ,IIF(_Difer<0,(_Difer*-1),_Difer),NIL},;
								{"D3_LOCAL"  ,_LOCAL,NIL},;
								{"D3_X_TQ"  ,LB3->LB3_TANQUE,NIL},;
								{"D3_X_TMT"  ,"AP",NIL},;
								{"D3_DOC"  ,NextNumero("SD3",2,"D3_DOC",.T.),NIL},;
								{"D3_EMISSAO",DDATABASE,NIL}}
								MSExecAuto({|x,y| mata240(x,y)},aVetor,3) //Inclusao
								If lMsErroAuto
									MOSTRAERRO()
									DisarmTransaction()
								Endif
							//End Transaction
						ENDIF
					ENDIF
				ELSE
					DBSELECTAREA("DH7")
					RECLOCK("DH7",.F.)
					DH7->DH7_ENTRAD	:=TRB->RECEB
					DH7->DH7_SAIDA	:=TRB->VENDAS
					DH7->DH7_ETRANS	:=TRB->ETRANS
					DH7->DH7_STRANS	:=TRB->STRANS
					
					IF (_Val4-(_Val1+_Val2-_Val3))<>0
						DH7->DH7_SOBRA  :=(_Val4-(_Val1+_Val2-_Val3))
					ELSE
						DH7->DH7_SOBRA  :=0
					ENDIF
					MSUNLOCK()
					
					IF _DIFER<>0
						lMsErroAuto:=.F.
						SB1->(DBSEEK(XFILIAL('SB1')+DH7->DH7_COD))
						DBSELECTAREA("SD3")
						aVetor:={ {"D3_TM"     ,IIF(_Difer>0,_TMD,_TMR),NIL},;
						{"D3_COD"    ,DH7->DH7_COD,NIL},;
						{"D3_QUANT"  ,IIF(_Difer<0,(_Difer*-1),_Difer),NIL},;
						{"D3_LOCAL"  ,_LOCAL,NIL},;
						{"D3_TANQUE"  ,DH7->DH7_TANQUE,NIL},;
						{"D3_TPMOVAJ"  ,"AP",NIL},;
						{"D3_DOC"  ,NextNumero("SD3",2,"D3_DOC",.T.),NIL},;
						{"D3_EMISSAO",DDATABASE,NIL}}
						MSExecAuto({|x,y| mata240(x,y)},aVetor,3) //Inclusao
						If lMsErroAuto
							MOSTRAERRO()
     						DisarmTransaction()
						Endif
					ENDIF
				ENDIF
			ENDIF
			Close(Tela)
			DBSELECTAREA("TRB")
			DBSKIP()
		ELSE
			MsgBox("Nao vai Gravar","Fechamento ja Promovido em: " + DTOC(GETMV("MV_ULMES",.F.,CTOD(""))) ,"Atencao","Info")
		ENDIF
	ENDIF
ELSE
	MsgInfo("Cadastre os movimentos")
	Close(Tela)
ENDIF

End Transaction

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Abandona

@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function Abandona()
Close(Tela)
dbselectarea("TRB")
dbgobottom()
DBSKIP()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proximo

@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function Proximo()
DBSELECTAREA("DH7")
DBSETORDER(1)
IF DBSEEK(XFILIAL('DH7')+DTOS(TRB->DATA1)+TRB->TANQUE+TRB->COD)
	RECLOCK("DH7",.F.)
	DH7->DH7_OBS:=_OBS1+_OBS2+_OBS3
	MSUNLOCK()
ENDIF

Close(Tela)
dbselectarea("TRB")
DBSKIP()
IF EOF()
	DBSKIP(-1)
ENDIF
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Anterior

@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function Anterior()
Close(Tela)
dbselectarea("TRB")
IF ! BOF()
	DBSKIP(-1)
ENDIF

Return