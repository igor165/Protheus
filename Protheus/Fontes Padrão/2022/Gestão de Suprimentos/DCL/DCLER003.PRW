#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"   

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLER003()
Confronta Valores de Tanque com Valores de entrada de nota fiscal
AdaptaГЦo da funГЦo TDCER003
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLER003()
Local oTempTable

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
SetPrvt("_DATAINI,CQUERY,SOBRA1,_DESGARGA,_DESCARGA,_PROD")
SetPrvt("TAMANHO,LIMITE,CDESC1,CDESC2,CDESC3,WNREL")
SetPrvt("NOMEPROG,NLASTKEY,CSTRING,ARETURN,LI,LCONTINUA")
SetPrvt("M_PAG,TITULO,CABEC1,CABEC2,TOT1,TOT2")
SetPrvt("TOT3,TOT4,TOT5,TOT6,TOT7,TOT8")
SetPrvt("TOT9,TOT10,TOT11,_TANQUE,_SALIAS,AREGS")
SetPrvt("I,J,")


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salva a integridade dos Arqquivos.                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
_cArea     := Alias()
_nRec      := Recno()
_cInd      := IndexOrd()


_DTBASE:=DDATABASE
_PRODUTO:=""
_QTDENT:=0  // Total Entradas
_QTDSAI:=0  // Total Saidas
_ETRANS:=0
_STRANS:=0
_TVOL20:=0  // Volume Total a 20 Graus
_TVOL20P:=0 // Volume total a 20 Graus proximo dia
_Sai19:=0
_Sai20:=0
_Ent19:=0
_Ent20:=0
_Sai:="N"
nPos:=0
_QTDENT:=0
_Sai07     := 0
_Ent07     := 0
_Sai08     := 0
_Ent08     := 0
_Ent09     := 0
_Sai09     := 0
_Ent10     := 0
_Sai10     := 0
aTanque    :={}

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
aTam := TamSX3("DH7_ENTRAD")
AaDd(_aStruc,{ "RECEB" , "N" , aTam[1],aTam[2] })
aTam := TamSX3("DH7_SAIDA")
AaDd(_aStruc,{ "VENDAS" , "N" , aTam[1],aTam[2] })
aTam := TamSX3("DH7_SAIDA")
AaDd(_aStruc,{ "BOMBEIO" , "N" , aTam[1],aTam[2] })
aTam := TamSX3("DH7_ETRANS")
AaDd(_aStruc,{ "ETRANS" , "N" , aTam[1],aTam[2] })
aTam := TamSX3("DH7_STRANS")
AaDd(_aStruc,{ "STRANS" , "N" , aTam[1],aTam[2] })
aTam := TamSX3("DH7_SOBRA")
AaDd(_aStruc,{ "NSOBRA" , "N" , aTam[1],aTam[2] })
AaDd(_aStruc,{ "OBS" , "C" , 255,0 })

oTempTable := FWTemporaryTable():New( "TRBDCL" )
oTempTable:SetFields(_aStruc)
oTempTable:AddIndex("Ind01", {"COD","DATA1"} )
oTempTable:Create()

_DATAINI:=CTOD("01/"+STRZERO(MONTH(DDATABASE),2)+"/"+STRZERO(YEAR(DDATABASE),4))
SET CENTURY OFF

RptStatus({|| RptDetail()})

oTempTable:Delete()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RptDetail()
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RptDetail()
	
	IF SUBSTR(RDDNAME(),1,6) <> 'DBFCDX'
		
		//здддддддддддддддддддддддддддддд©
		//Ё MONTA QUERY PARA CONSULTA SD3Ё
		//юдддддддддддддддддддддддддддддды
		If Select("TMP1") > 0     // Verificando se o alias esta em uso
			dbSelectArea("TMP1")
			dbCloseArea()
		EndIf
		
		cQuery := "SELECT SD3.D3_EMISSAO EMISSAO,SD3.D3_TM TM,SD3.D3_TANQUE TANQUE,SD3.D3_COD COD, SUM(SD3.D3_QUANT) QUANT "
		cQuery := cQuery + " FROM "+RetSqlName("SD3")+" SD3, "+RetSqlName("SB1")+" SB1 "
		cQuery := cQuery + " WHERE SD3.D3_EMISSAO >= '"+DTOS(_DATAINI)+"' AND "
		cQuery := cQuery + "       SD3.D3_EMISSAO <= '"+DTOS(DDATABASE)+"' AND "
		cQuery := cQuery + "       SD3.D3_ESTORNO <> 'S'  AND "
		cQuery := cQuery + "       SB1.B1_COD      = SD3.D3_COD AND "
		cQuery := cQuery + "       SD3.D3_FILIAL  = '"+xFilial("SD3")+"' AND "
		cQuery := cQuery + "       SD3.D_E_L_E_T_  <> '*' "
		cQuery := cQuery + " GROUP BY SD3.D3_EMISSAO,SD3.D3_TM,SD3.D3_TANQUE,SD3.D3_COD"
		MEMOWRIT("TMP1.SQL",cQuery)
		TCQUERY cQuery NEW ALIAS "TMP1"
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Apuracao das  Movimentacoes Internas                         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DBSELECTAREA("TMP1")
		DBGOTOP()
		SetRegua(Reccount())
		WHILE ! EOF()
			IncRegua()
			SF5->(DBSEEK(XFILIAL()+TMP1->TM))
			IF SF5->F5_CODIGO <= '500'
				IF SF5->F5_MOVTANQ =='TR'
					_ETRANS := TMP1->QUANT + _ETRANS
				ELSEIF SF5->F5_MOVTANQ =='PR'
					_QTDENT := TMP1->QUANT + _QTDENT
				ELSEIF SF5->F5_MOVTANQ =='BO'
					_QTDENT := TMP1->QUANT + _QTDENT
				ELSEIF SF5->F5_MOVTANQ =='DE'
					_QTDENT := TMP1->QUANT + _QTDENT
				ELSEIF SF5->F5_MOVTANQ =='EQ'
					_QTDSAI := _QTDSAI - TMP1->QUANT
				ENDIF
			ELSE
				IF SF5->F5_MOVTANQ =='TR'
					_STRANS := TMP1->QUANT + _STRANS
				ELSEIF SF5->F5_MOVTANQ =='PR'
					_QTDSAI := TMP1->QUANT + _QTDSAI
				ELSEIF SF5->F5_MOVTANQ =='BO'
					_QTDENT := _QTDENT - TMP1->QUANT
				ELSEIF SF5->F5_MOVTANQ =='DE'
					_QTDENT := _QTDENT - TMP1->QUANT
				ELSEIF SF5->F5_MOVTANQ =='EQ'
					_QTDSAI := _QTDSAI + TMP1->QUANT
				ENDIF
			ENDIF
			
			IF !EMPTY(_QTDENT).OR.!EMPTY(_QTDSAI).OR.!EMPTY(_ETRANS).OR.!EMPTY(_STRANS).OR.!EMPTY(TRBDCL->NSOBRA);
				.OR. SF5->F5_MOVTANQ=='PR'.OR. SF5->F5_MOVTANQ=='AP'
				DBSELECTAREA("TRBDCL")
				IF ! DBSEEK(TMP1->COD+TMP1->EMISSAO)
					RECLOCK("TRBDCL",.T.)
					TRBDCL->COD    :=TMP1->COD
					TRBDCL->DATA1   :=CTOD(SUBSTR(TMP1->EMISSAO,7,2)+"/"+SUBSTR(TMP1->EMISSAO,5,2)+"/"+SUBSTR(TMP1->EMISSAO,3,2))
					TRBDCL->ETRANS:=_ETRANS
					TRBDCL->STRANS:=_STRANS
					TRBDCL->RECEB  :=_QTDENT
					TRBDCL->VENDAS :=_QTDSAI
					TRBDCL->VENDAS :=_QTDSAI
					IF SF5->F5_MOVTANQ=='PR'
						TRBDCL->BOMBEIO:=TMP1->QUANT
					ENDIF
					IF SF5->F5_MOVTANQ=='AP'
						TRBDCL->NSOBRA:=IIF(SF5->F5_CODIGO <= '500',TMP1->QUANT,-TMP1_QUANT)
					ENDIF
					
				ELSE
					DBSELECTAREA("TRBDCL")
					RECLOCK("TRBDCL",.F.)
					TRBDCL->ETRANS:=_ETRANS +TRBDCL->ETRANS
					TRBDCL->STRANS:=_STRANS +TRBDCL->STRANS
					TRBDCL->RECEB  :=_QTDENT  +TRBDCL->RECEB
					TRBDCL->VENDAS :=_QTDSAI  +TRBDCL->VENDAS
					IF SF5->F5_MOVTANQ=="PR"
						TRBDCL->BOMBEIO:=TRBDCL->BOMBEIO+TMP1->QUANT
					ENDIF
					IF SF5->F5_MOVTANQ=='AP'
						TRBDCL->NSOBRA:=IIF(SF5->F5_CODIGO <= '500',TMP1->QUANT,-TMP1_QUANT) + TRBDCL->NSOBRA
					ENDIF
				ENDIF
				
				_QTDENT:=0  // Total Entradas
				_QTDSAI:=0  // Total Saidas
				_ETRANS:=0 // Entr. Transf
				_STRANS:=0    // SAIDA TRANSF.
				MSUNLOCK()
			ENDIF
			
			DBSELECTAREA("TMP1")
			DBSKIP()
		ENDDO
	ELSE
		DBSELECTAREA("SD3")
		DBSETORDER(6)
		DBSEEK(XFILIAL()+DTOS(_DATAINI),.T.)
		SetRegua(Reccount())
		WHILE ! EOF() .AND. SD3->D3_EMISSAO <= DDATABASE .AND. SD3->D3_FILIAL == xFilial("SD3")
			
			IncRegua()
			IF SD3->D3_ESTORNO == 'S'
				DBSKIP()
				LOOP
			ENDIF
			SF5->(DBSEEK(XFILIAL()+SD3->D3_TM))
			IF SF5->F5_CODIGO <= '500'
				IF SF5->F5_MOVTANQ=='TR'
					_ETRANS := SD3->D3_QUANT + _ETRANS
				ELSEIF SF5->F5_MOVTANQ =='PR'
					_QTDENT := SD3->D3_QUANT + _QTDENT
				ELSEIF SF5->F5_MOVTANQ =='BO'
					_QTDENT := SD3->D3_QUANT + _QTDENT
				ELSEIF SF5->F5_MOVTANQ =='DE'
					_QTDENT := SD3->D3_QUANT + _QTDENT
				ELSEIF SF5->F5_MOVTANQ =='EQ'
					_QTDSAI := _QTDSAI - SD3->D3_QUANT
				ENDIF
			ELSE
				IF SF5->F5_MOVTANQ =='TR'
					_STRANS := SD3->D3_QUANT + _STRANS
				ELSEIF SF5->F5_MOVTANQ =='PR'
					_QTDSAI := SD3->D3_QUANT + _QTDSAI
				ELSEIF SF5->F5_MOVTANQ =='BO'
					_QTDENT := _QTDENT - SD3->D3_QUANT
				ELSEIF SF5->F5_MOVTANQ =='DE'
					_QTDENT := _QTDENT - SD3->D3_QUANT
				ELSEIF SF5->F5_MOVTANQ =='EQ'
					_QTDSAI := _QTDSAI + SD3->D3_QUANT
				ENDIF
			ENDIF
			
			IF !EMPTY(_QTDENT).OR.!EMPTY(_QTDSAI).OR.!EMPTY(_ETRANS).OR.!EMPTY(_STRANS).OR.SF5->F5_MOVTANQ=='AP'
				DBSELECTAREA("TRBDCL")
				IF ! DBSEEK(SD3->D3_COD+DTOS(SD3->D3_EMISSAO))
					RECLOCK("TRBDCL",.T.)
					TRBDCL->COD    :=SD3->D3_COD
					TRBDCL->DATA1   :=SD3->D3_EMISSAO
					TRBDCL->ETRANS:=_ETRANS
					TRBDCL->STRANS:=_STRANS
					TRBDCL->RECEB  :=_QTDENT
					TRBDCL->VENDAS :=_QTDSAI
					IF SD3->D3_MOVTANQ=='PR'
						TRBDCL->BOMBEIO:=SD3->D3_QUANT
					ENDIF
					IF SD3->D3_MOVTANQ=='AP'
						TRBDCL->NSOBRA:=IIF(SF5->F5_CODIGO <= '500',SD3->D3_QUANT,-SD3->D3_QUANT)
					ENDIF
					
				ELSE
					DBSELECTAREA("TRBDCL")
					RECLOCK("TRBDCL",.F.)
					TRBDCL->ETRANS:=_ETRANS +TRBDCL->ETRANS
					TRBDCL->STRANS:=_STRANS +TRBDCL->STRANS
					TRBDCL->RECEB  :=_QTDENT  +TRBDCL->RECEB
					TRBDCL->VENDAS :=_QTDSAI  +TRBDCL->VENDAS
					IF SD3->D3_MOVTANQ=="PR"
						TRBDCL->BOMBEIO:=TRBDCL->BOMBEIO+SD3->D3_QUANT
					ENDIF
					IF SD3->D3_MOVTANQ=='AP'
						TRBDCL->NSOBRA:=TRBDCL->NSOBRA + IIF(SF5->F5_CODIGO <= '500',SD3->D3_QUANT,-SD3->D3_QUANT)
					ENDIF
				ENDIF
				
				_QTDENT:=0  // Total Entradas
				_QTDSAI:=0  // Total Saidas
				_ETRANS:=0 // Entr. Transf
				_STRANS:=0    // SAIDA TRANSF.
				MSUNLOCK()
			ENDIF
			
			DBSELECTAREA("SD3")
			DBSKIP()
		ENDDO
		
	ENDIF
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fim da apuracao das movimentacoes internas                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	
	IF SUBSTR(RDDNAME(),1,6) <> 'DBFCDX'
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicio da apuracao das Notas Fiscais de Entrada              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		//здддддддддддддддддддддддддддддд©
		//Ё MONTA QUERY PARA CONSULTA SD1Ё
		//юдддддддддддддддддддддддддддддды
		If Select("TMP2") > 0     // Verificando se o alias esta em uso
			dbSelectArea("TMP2")
			dbCloseArea()
		EndIf
		
		cQuery := "SELECT "
		cQuery += "	SD1.D1_COD COD,SUM(SD1.D1_QUANT) QUANT, "
		cQuery += "	DH4.DH4_DTENT DTBOMB,DH4.DH4_TANQUE TANQUE,DH4.DH4_TDCARG VIATRAN, SUM(DH4.DH4_QTD20G) QTDECV "
		cQuery += " FROM " + RetSqlName("SD1") + " SD1 ," + RetSqlName("DH4") + " DH4 "	
		cQuery += " WHERE DH4.DH4_DTENT >= '" + DTOS(_DATAINI) + "' AND "
		cQuery += "       DH4.DH4_DTENT <= '" + DTOS(DDATABASE) + "' AND "
		cQuery += "       SD1.D1_FILIAL  = '" + xFilial("SD1") + "' AND "
		cQuery += "       DH4.DH4_FILIAL  = '" + xFilial("DH4") + "' AND "
		cQuery += "       SD1.D_E_L_E_T_  = ' ' AND "
		cQuery += "       DH4.D_E_L_E_T_  = ' ' "
		cQuery += " GROUP BY DH4.DH4_DTENT,DH4.DH4_TANQUE,SD1.D1_COD,DH4.DH4_TDCARG"
		MEMOWRIT("TMP2.SQL",cQuery)
		TCQUERY cQuery NEW ALIAS "TMP2"
		
		DBSELECTAREA("TMP2")
		DBGOTOP()
		SetRegua(Reccount())
		WHILE ! EOF()
			IncRegua()
			_QTDENT:=_QTDENT+TMP2->QUANT
			DBSELECTAREA("TRBDCL")
			IF ! DBSEEK(TMP2->COD+TMP2->DTBOMB)
				RECLOCK("TRBDCL",.T.)
				TRBDCL->COD    :=TMP2->COD
				TRBDCL->DATA1   :=CTOD(SUBSTR(TMP2->DTBOMB,7,2)+"/"+SUBSTR(TMP2->DTBOMB,5,2)+"/"+SUBSTR(TMP2->DTBOMB,3,2))
				TRBDCL->RECEB  :=_QTDENT
			ELSE
				RECLOCK("TRBDCL",.F.)
				TRBDCL->RECEB  :=_QTDENT  +TRBDCL->RECEB
			ENDIF
			MSUNLOCK()
			_QTDENT:=0  // Total Entradas
			DBSELECTAREA("TMP2")
			DBSKIP()
		ENDDO
	ELSE
		DBSELECTAREA("SD1")
		DBSETORDER(6)
		DBSEEK(XFILIAL()+DTOS(_DATAINI),.T.)
		SetRegua(Reccount())
		DbSelectArea("DH4")
		DH4->(DbSetorder(1))
		If DH4->(DbSeek(xFilial("DH4") + SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM )))
			WHILE ! EOF() .AND. SD1->D1_DTDIGIT <= DDATABASE .AND. SD1->D1_FILIAL == xFilial("SD1")
				IncRegua()
				DBSELECTAREA("TRBDCL")
				IF ! DBSEEK(SD1->D1_COD + DTOS(DH4->DH4_DTENT) )
					RECLOCK("TRBDCL",.T.)
					TRBDCL->COD	:=SD1->D1_COD
					TRBDCL->DATA1	:=DH4->DH4_DTENT
					TRBDCL->RECEB	:=SD1->D1_QUANT //SD1->D1_X_QTD1
				ELSE
					RECLOCK("TRBDCL",.F.)
					TRBDCL->RECEB	:=TRBDCL->RECEB+SD1->D1_QUANT // SD1->D1_X_QTD1
				ENDIF
				MSUNLOCK()
				DBSELECTAREA("SD1")
				DBSKIP()
			ENDDO
		EndIf
	ENDIF
	
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fim da apuracao das notas fiscais de Entrada                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicio da Apuracao das notas fiscais de saidas               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	//здддддддддддддддддддддддддддддд©
	//Ё MONTA QUERY PARA CONSULTA SD2Ё
	//юдддддддддддддддддддддддддддддды
	IF SUBSTR(RDDNAME(),1,6) <> 'DBFCDX'
		If Select("TMP3") > 0     // Verificando se o alias esta em uso
			dbSelectArea("TMP3")
			dbCloseArea()
		EndIf
		
		cQuery := " SELECT 	SF2.F2_EMISSAO DATA1,SD2.D2_COD COD, SUM(SD2.D2_QUANT) QUANT, "
		cQuery += " 		DH3.DH3_TANQ1 TANQUE1,DH3.DH3_TANQ2 TANQUE2, SUM(DH3.DH3_QTD1) QTD1, SUM(DH3.DH3_QTD2) QTD2 "
		cQuery += " FROM "+RetSqlName("DH3")+" DH3, "+RetSqlName("SF2")+" SF2, "+RetSqlName("SD2")+" SD2 "
		cQuery += " WHERE SF2.F2_EMISSAO >= '"+DTOS(_DATAINI)+"' AND "
		cQuery += "       SF2.F2_EMISSAO <= '"+DTOS(DDATABASE)+"' AND "
		cQuery += "       SF2.F2_FILIAL  = '"+xFilial("SF2")+"' AND "
		cQuery += "       SF2.F2_DOC      = SD2.D2_DOC AND "
		cQuery += "       SF2.F2_SERIE    = SD2.D2_SERIE AND "
		cQuery += "       SF2.F2_FILIAL   = SD2.D2_FILIAL AND "
		cQuery += "       SF2.F2_FILIAL   = DH3.DH3_FILIAL AND "
		cQuery += "       SF2.F2_DOC      = DH3.DH3_DOCD2 AND "
		cQuery += "       SF2.F2_SERIE    = DH3.DH3_SERIE AND "
		cQuery += "       DH3.D_E_L_E_T_  = ' ' AND "
		cQuery += "       SF2.D_E_L_E_T_  = ' ' AND "
		cQuery += "       SD2.D_E_L_E_T_  = ' ' "
		cQuery += " GROUP BY SF2.F2_EMISSAO,SD2.D2_COD,DH3.DH3_TANQ1,DH3.DH3_TANQ2,DH3.DH3_FILIAL "
		MEMOWRIT("TMP3.SQL",cQuery)
		TCQUERY cQuery NEW ALIAS "TMP3"
		
		DBSELECTAREA("TMP3")
		DBGOTOP()
		SetRegua(Reccount())
		WHILE ! EOF()
			IncRegua()
			DBSELECTAREA("TRBDCL")
			SB1->(DBSEEK(XFILIAL()+TMP3->COD))
	        DH5->(DbSetOrder(1))
	        If DH5->(DbSeek(xFilial("DH5") + SB1->B1_COD))
	            If DH5->DH5_PREQUI <> "S"
					IF ! DBSEEK(TMP3->COD+TMP3->DATA1)
						RECLOCK("TRBDCL",.T.)
						TRBDCL->COD		:=TMP3->COD
						TRBDCL->DATA1	:=CTOD(SUBSTR(TMP3->DATA1,7,2)+"/"+SUBSTR(TMP3->DATA1,5,2)+"/"+SUBSTR(TMP3->DATA1,3,2))
						TRBDCL->VENDAS	:=TMP3->QUANT
					ELSE
						RECLOCK("TRBDCL",.F.)
						TRBDCL->VENDAS  :=TMP3->QUANT +TRBDCL->VENDAS
					ENDIF
					MSUNLOCK()
				ELSE
					
					DBSELECTAREA("SG1")
					DBORDERNICKNAME("DCLSG1_01")
					DBSEEK(XFILIAL()+TMP3->COD+TMP3->DATA1,.T.)
					dFim:=SG1->G1_FIM
					WHILE TMP3->COD == SG1->G1_COD .AND. ! EOF() .AND. dFim == SG1->G1_FIM
						DBSELECTAREA("TRBDCL")
						IF ! DBSEEK(SG1->G1_COMP+TMP3->DATA1)
							RECLOCK("TRBDCL",.T.)
							TRBDCL->COD    :=SG1->G1_COMP
							TRBDCL->DATA1  :=CTOD(SUBSTR(TMP3->DATA1,7,2)+"/"+SUBSTR(TMP3->DATA1,5,2)+"/"+SUBSTR(TMP3->DATA1,3,2))
							TRBDCL->VENDAS :=(SG1->G1_QUANT * TMP3->QUANT)
						ELSE
							RECLOCK("TRBDCL",.F.)
							TRBDCL->VENDAS :=TRBDCL->VENDAS + (SG1->G1_QUANT * TMP3->QUANT)
						ENDIF
						MSUNLOCK()
						DBSELECTAREA("SG1")
						DBSKIP()
					ENDDO
				ENDIF
			EndIf
			DBSELECTAREA("TMP3")
			DBSKIP()
		ENDDO
	ELSE
		DBSELECTAREA("SD2")
		DBSETORDER(5)
		DBSEEK(XFILIAL()+DTOS(_DATAINI),.T.)
		SetRegua(Reccount())
		WHILE ! EOF() .AND. SD2->D2_EMISSAO <= DDATABASE .AND. SD2->D2_FILIAL == xFilial("SD2")
			IncRegua()
			DBSELECTAREA("TRBDCL")
			SB1->(DBSEEK(XFILIAL()+SD2->D2_COD))
			DH5->(DbSetOrder(1))
	        If DH5->(DbSeek(xFilial("DH5") + SB1->B1_COD))
	            If DH5->DH5_PREQUI <> "S"
					IF ! DBSEEK(SD2->D2_COD+DTOS(SD2->D2_EMISSAO))
						RECLOCK("TRBDCL",.T.)
						TRBDCL->COD    :=SD2->D2_COD
						TRBDCL->DATA1  :=SD2->D2_EMISSAO
						TRBDCL->VENDAS :=SD2->D2_QUANT
					ELSE
						RECLOCK("TRBDCL",.F.)
						TRBDCL->VENDAS  :=SD2->D2_QUANT +TRBDCL->VENDAS
					ENDIF
					MSUNLOCK()
				ELSE
					
					DBSELECTAREA("SG1")
					SG1->(DbSetOrder(5))//G1_FILIAL+G1_COD+DTOS(G1_FIM)+G1_TRT
					SG1->(DBSEEK(XFILIAL()+SD2->D2_COD+DTOS(SD2->D2_EMISSAO),.T.))
					dFim:=SG1->G1_FIM
					WHILE SD2->D2_COD == SG1->G1_COD .AND. ! EOF() .AND. dFim == SG1->G1_FIM
						DBSELECTAREA("TRBDCL")
						IF ! DBSEEK(SG1->G1_COMP+DTOS(SD2->D2_EMISSAO))
							RECLOCK("TRBDCL",.T.)
							TRBDCL->COD    :=SG1->G1_COMP
							TRBDCL->DATA1  :=SD2->D2_EMISSAO
							TRBDCL->VENDAS :=SD2->D2_QUANT*SG1->G1_QUANT
						ELSE
							RECLOCK("TRBDCL",.F.)
							TRBDCL->VENDAS  :=TRBDCL->VENDAS + (SD2->D2_QUANT*SG1->G1_QUANT)
						ENDIF
						MSUNLOCK()
						DBSELECTAREA("SG1")
						DBSKIP()
					ENDDO
				ENDIF
			EndIf
			DBSELECTAREA("SD2")
			DBSKIP()
		ENDDO
	ENDIF
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fim da Apuracao das notas fiscais de saidas                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	IF SUBSTR(RDDNAME(),1,6) <> 'DBFCDX'
		If Select("TMP1") > 0     // Verificando se o alias esta em uso
			dbSelectArea("TMP1")
			dbCloseArea()
		EndIf
		
		If Select("TMP2") > 0     // Verificando se o alias esta em uso
			dbSelectArea("TMP2")
			dbCloseArea()
		EndIf
		
		If Select("TMP3") > 0     // Verificando se o alias esta em uso
			dbSelectArea("TMP3")
			dbCloseArea()
		EndIf
	ENDIF
	
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Impressao do relatorio na impressora                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Tamanho   := "G"
	Limite    := 220
	cDesc1    := PadC(" Relatorio Comparativo Tanque x NFS. Mov. Entrada /Saida ",74)
	cDesc2    := ""
	cDesc3    := ""
	wnrel     := "CER003"
	nomeprog  := "TDCER003"
	nLastkey  :=  0
	cString   := "DH6"
	aReturn   := {"Branco",1,"Comercial",2,2,1,"",1}
	li        :=  66
	lContinua := .T.
	m_pag     := 1
	Titulo    := PadC("Fechamento de Tanques Data Base: "+Dtoc(_DTBASE),74)
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё IMPRESSAO DOS DADOS FILTRADOS  NO VETOR                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	wnrel := SetPrint(cString,wnrel,,Titulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.F.,Tamanho,.F.)
	
	If nLastKey == 27
		Return
	Endif	
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	Cabec1:="                             ||    R E C E B I M E N T O S    ||       S  A  I  D  A  S        ||    TRANSFERENCIA ENTRADA      ||      TRANSFERENCIA SAIDA      || PERDA/SOBRA ARMAZENAGEM ||                            || "
	Cabec2:="DATA      TANQUE   PRODUTO   ||       Apurado          Tanque ||       Apurado           Tanque||       Apurado         Tanque  ||       Apurado          Tanque || Apurado        Tanque   || Bombeio Nao Baixado        || "
	
	//                            ||    R E C E B I M E N T O S    ||       S  A  I  D  A  S        ||    TRANSFERENCIA ENTRADA      ||      TRANSFERENCIA SAIDA      ||                ||                ||                 ||
	//ATA      TANQUE   PRODUTO   ||         Mapao        Apurado  ||         Mapao         Apurado ||         Mapao         Apurado ||         Mapao         Apurado || Per/Sobr Arm.  || Per/Sobr Bomb. ||  Bomb.N/Baixado ||
	//9/99/99  XXXXXX    XXXX     || 9.999.999.999  9.999.999.999  || 9.999.999.999   9.999.999.999 || 9.999.999.999   9.999.999.999 || 9.999.999.999   9.999.999.999 || 9.999.999.999  || 9.999.999.999  ||   9.999.999.999 ||
	//         11        21       29 33             48             62 66              82            95 99              115          128 132             148           161              179               197                 216
	//                                                                                                                                                                   164               182                 202
	Titulo    := PadC(" Comparativo Tanque x Mov. Entrada e Saida ",74)
	li:=66
	DBSELECTAREA("TRBDCL")
	DBGOTOP()
	SetRegua(RecCount())
	_COD:=TRBDCL->COD
	TOT1:=TOT2:=TOT3:=TOT4:=TOT5:=TOT6:=TOT7:=TOT8:=TOT9:=TOT10:=TOT11:=0
	WHILE ! EOF()
		IF EMPTY(TRBDCL->COD)
			DBSKIP()
			_COD:=TRBDCL->COD
			LOOP
		ENDIF
		SB1->(DBSEEK(XFILIAL()+TRBDCL->COD))
		IncRegua()
		IF li > 60
			li :=1
			li :=cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
			li:=li+1
			@ li,00 PSAY " PRODUTO: "+TRBDCL->COD+" / "+SB1->B1_DESC
			li:=li+1
		ENDIF
		DBSELECTAREA("DH7")
		DH7->(DBSETORDER(1))
		_RECEB:=_VENDAS:=STRANS:=_ETRANS:=_NSOBRA:=0
		IF DBSEEK(XFILIAL()+DTOS(TRBDCL->DATA1)+TRBDCL->COD)
			WHILE TRBDCL->DATA1 == DH7->DH7_DATAMED .AND. TRBDCL->COD == DH7->DH7_CODPRO
				_RECEB  :=DH7->DH7_ENTRAD + _RECEB
				_VENDAS :=DH7->DH7_SAIDA  + _VENDAS
				_STRANS :=DH7->DH7_STRANS + _STRANS
				_ETRANS :=DH7->DH7_ETRANS + _ETRANS
				_NSOBRA :=DH7->DH7_SOBRA + _NSOBRA
				DBSKIP()
			ENDDO
			IF TRBDCL->COD  <> _COD
				li:=li+1
				@ LI,033 PSAY TOT1  PICTURE  "@E 9,999,999,999"
				@ LI,048 PSAY TOT2  PICTURE  "@E 9,999,999,999"
				@ LI,066 PSAY TOT3  PICTURE  "@E 9,999,999,999"
				@ LI,082 PSAY TOT4  PICTURE  "@E 9,999,999,999"
				@ LI,099 PSAY TOT5  PICTURE  "@E 9,999,999,999"
				@ LI,115 PSAY TOT6  PICTURE  "@E 9,999,999,999"
				@ LI,132 PSAY TOT7  PICTURE  "@E 9,999,999,999"
				@ LI,148 PSAY TOT8  PICTURE  "@E 9,999,999,999"
	            @ LI,164 PSAY TOT9  PICTURE  "@E 999,999,999"
	            @ LI,176 PSAY TOT10 PICTURE  "@E 999,999,999"
				@ LI,192 PSAY TOT11 PICTURE  "@E 9,999,999,999"
				TOT1:=TOT2:=TOT3:=TOT4:=TOT5:=TOT6:=TOT7:=TOT8:=TOT9:=TOT10:=TOT11:=0
				li:=li+1
				@ LI,00 PSAY REPLIC("-",220)
				li:=li+1
				@ li,00 PSAY " PRODUTO: "+TRBDCL->COD+" / "+SB1->B1_DESC
				li:=li+1
			ENDIF
			
			@ LI,001 PSAY DTOC(TRBDCL->DATA1)
			IF TRBDCL->RECEB <> _RECEB
				@ li,013 PSAY "1"
			ENDIF
			IF TRBDCL->VENDAS <> _VENDAS
				@ li,016 PSAY "2"
			ENDIF
			IF TRBDCL->ETRANS<> _ETRANS
				@ li,019 PSAY "3"
			ENDIF
			IF TRBDCL->STRANS<> _STRANS
				@ li,022 PSAY "4"
			ENDIF
			
			IF TRBDCL->NSOBRA<> _NSOBRA
				@ li,025 PSAY "5"
			ENDIF
			
			IF TRBDCL->BOMBEIO<> 0
				@ li,028 PSAY "6"
			ENDIF
			
			@ li,029 PSAY "||"
			@ li,033 PSAY TRBDCL->RECEB PICTURE "@E 9,999,999,999"
			@ li,048 PSAY _RECEB PICTURE "@E 9,999,999,999"
			@ li,062 PSAY "||"
			TOT1:=TOT1+ TRBDCL->RECEB
			TOT2:=TOT2+ _RECEB
			
			@ li,066 PSAY TRBDCL->VENDAS PICTURE "@E 9,999,999,999"
			@ li,082 PSAY _VENDAS PICTURE "@E 9,999,999,999"
			@ li,095 PSAY "||"
			TOT3:=TOT3+ TRBDCL->VENDAS
			TOT4:=TOT4+ _VENDAS
			
			@ li,099 PSAY TRBDCL->ETRANS PICTURE "@E 9,999,999,999"
			@ li,115 PSAY _ETRANS PICTURE "@E 9,999,999,999"
			@ li,128 PSAY "||"
			TOT5:=TOT5+ TRBDCL->ETRANS
			TOT6:=TOT6+ _ETRANS
			
			@ li,132 PSAY TRBDCL->STRANS PICTURE "@E 9,999,999,999"
			@ li,148 PSAY _STRANS PICTURE "@E 9,999,999,999"
			@ li,161 PSAY "||"
			TOT7:=TOT7+ TRBDCL->STRANS
			TOT8:=TOT8+ _STRANS
			
			@ li,164 PSAY TRBDCL->NSOBRA    PICTURE "@E 999,999,999"
			@ li,176 PSAY _NSOBRA PICTURE "@E 999,999,999"
			@ li,188 PSAY "||"
			TOT10:=TOT10+TRBDCL->NSOBRA
			TOT9:=TOT9+ _NSOBRA
			
			@ li,192 PSAY TRBDCL->BOMBEIO PICTURE "@E 9,999,999,999" //202
			@ li,218 PSAY "||"
			TOT11:=TOT11+ TRBDCL->BOMBEIO
			_COD:=TRBDCL->COD
		ENDIF
		DBSELECTAREA("TRBDCL")
		DBSKIP()
		li:=li+1
	ENDDO
	
	li:=li+1
	@ LI,033 PSAY TOT1  PICTURE  "@E 9,999,999,999"
	@ LI,048 PSAY TOT2  PICTURE  "@E 9,999,999,999"
	@ LI,066 PSAY TOT3  PICTURE  "@E 9,999,999,999"
	@ LI,082 PSAY TOT4  PICTURE  "@E 9,999,999,999"
	@ LI,099 PSAY TOT5  PICTURE  "@E 9,999,999,999"
	@ LI,115 PSAY TOT6  PICTURE  "@E 9,999,999,999"
	@ LI,132 PSAY TOT7  PICTURE  "@E 9,999,999,999"
	@ LI,148 PSAY TOT8  PICTURE  "@E 9,999,999,999"
	@ LI,164 PSAY TOT9  PICTURE  "@E 999,999,999"
	@ LI,176 PSAY TOT10 PICTURE  "@E 999,999,999"
	@ LI,192 PSAY TOT11 PICTURE  "@E 9,999,999,999"
	
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
	
RETURN

