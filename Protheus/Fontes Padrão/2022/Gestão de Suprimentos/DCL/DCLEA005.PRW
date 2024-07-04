#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA005
Cadastro de Tanques  
 
@author TOTVS
@since 09/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCLEA005()
Local nReceb	:= 0
Local nSaida	:= 0
Local nAbertu	:= 0
Local cFilOri	:= cFilAnt
Local cAreaTmp	:= GetNextAlias()

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

DH6->(dbGoTop())
WHILE DH6->(!EOF())	
	cFilAnt := DH6->DH6_FILIAL
	SD3->(dbSetOrder(6))
	SD3->(dbSeek(xFilial("SD3")+DTOS(DDATABASE),.T.))
	WHILE SD3->D3_EMISSAO == DDATABASE .AND. SD3->(!EOF())
		IF SD3->D3_ESTORNO=="S"
			SD3->(dbSkip())
			Loop
		Endif
		SB1->(dbSeek(xFilial("SB1")+SD3->D3_COD))
		IF ! EMPTY(SD3->D3_TPMOVAJ) .AND. SD3->D3_TANQUE == DH6->DH6_TANQUE	
			IF VAL(SD3->D3_TM) <=500
				IF ALLTRIM(SD3->D3_TPMOVAJ)=="TR"
					nReceb:=nReceb + SD3->D3_QUANT
				ELSEIF SD3->D3_TPMOVAJ $ "PR"
					nReceb:=nReceb + SD3->D3_QUANT
				ELSE
					SD3->(dbSkip())
					Loop
				ENDIF
			ELSE
				IF ALLTRIM(SD3->D3_TPMOVAJ)=="TR"
					nSaida:=nSaida + SD3->D3_QUANT
				ELSEIF SD3->D3_TPMOVAJ $ "PR"
					nSaida:=nSaida + SD3->D3_QUANT
				ELSE
					SD3->(dbSkip())
					Loop
				ENDIF
			ENDIF
		ELSE
			SD3->(dbSkip())
			Loop
		ENDIF
		SD3->(dbSkip())
	ENDDO
	
	DH4->(dbSetOrder(6))
	DH4->(dbSeek(xFilial("DH4")+DTOS(DDATABASE),.T.))
	WHILE DH4->DH4_DTENT  == DDATABASE .AND. DH4->(!EOF()) .AND. DH4->DH4_FILIAL == xFilial("DH4")
		IF DH4->DH4_TANQUE == DH6->DH6_TANQUE
			nReceb  := nReceb + DH4->DH4_QTD20G
		ENDIF
		DH4->(dbSkip())
	ENDDO
	
	// Fim da apuracao das notas fiscais de Entrada     
	
	//Inicio da Apuracao das notas fiscais de saidas  

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


	WHILE (cAreaTmp)->(!EOF())
		DH5->(DBSEEK(xFilial("DH5")+(cAreaTmp)->COD))
		IF DH5->DH5_PREQUI <> "S"
			IF (cAreaTmp)->TQ1 == LB2->LB2_TANQUE
				nSaida:=nSaida + (cAreaTmp)->QTD1
			ENDIF
		ELSE
			SG1->(dbsetOrder(5))
			SG1->(dbSeek(xFilial("SG1")+(cAreaTmp)->COD+(cAreaTmp)->DATA1,.T.))
			dFim:=SG1->G1_FIM
			WHILE (cAreaTmp)->COD == SG1->G1_COD .AND. SG1->(!EOF()) .AND. dFim == SG1->G1_FIM
				_SEQ:=SUBSTR(SG1->G1_TRT,3,1)
				_Tanque:="(cAreaTmp)->TQ"+_SEQ
				_QTD:="(cAreaTmp)->QTD"+_SEQ
				IF &(_Tanque) == LB2->LB2_TANQUE
					nSaida:=nSaida+&(_QTD)
				ENDIF
				SG1->(dbSkip())
			ENDDO
		ENDIF
		(cAreaTmp)->(DBSKIP())
	ENDDO
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Fim da Apuracao das notas fiscais de saidas                  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	(cAreaTmp)->(dbCloseArea())
		
	DH7->(dbSetorder(1))
	IF DH7->(dbSeek(xFilial("DH7")+DTOS(DDATABASE)+DH6->DH6_CODPRO+DH6->DH6_TANQUE))
		nAbertu:=DH7->DH7_VOL20
	ELSE
		nAbertu:=0
	ENDIF
	RECLOCK("DH6",.F.)
	DH6->DH6_ABERTU	:= nAbertu
	DH6->DH6_TRECEB	:= nReceb
	DH6->DH6_SAIDA	:= nSaida
	DH6->DH6_VDISPO	:= DH6->DH6_CAPTOT - nAbertu - nReceb + nSaida
	MSUNLOCK()
	nSaida:=0
	nReceb:=0
	nAbertu:=0
	DH6->(dbSkip())
ENDDO

cFilAnt := cFilOri
//AxCadastro("DH6","CADASTRO DE TANQUE",".T.",".T.")
ProtheusMVC("DH6", /*cModelID*/)

Return(nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Quintania
@since 29/03/2017
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()  

Local aRotina := {} //Array utilizado para controlar opcao selecionada

ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.PROTHEUSMVC" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.PROTHEUSMVC" OPERATION MODEL_OPERATION_INSERT ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.PROTHEUSMVC" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.PROTHEUSMVC" OPERATION MODEL_OPERATION_DELETE ACCESS 0

Return aRotina