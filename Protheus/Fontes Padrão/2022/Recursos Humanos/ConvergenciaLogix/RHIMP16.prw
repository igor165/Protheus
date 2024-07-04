#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RHIMP16.CH"

/********************************************************************************##
***********************************************************************************
***********************************************************************************
***Funcão..: RHIMP16.prw Autor:Leandro Drumond Data: 08/12/2012                 ***
***********************************************************************************
***Descrição..:Responsável pela importação de 13º Salário						***
***********************************************************************************
***Uso........:        															***
***********************************************************************************
***Parâmetros.:		cFileName, caractere, nome do arquivo       	      		***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***********************************************************************************
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP16
Responsável pela importação de 13º Salário.
@author Leandro Drumond
@since 08/12/2012
@version P11
@param cFileName, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
User Function RHIMP16(cFileName,aRelac,oSelf)
	Local aAreas		:= {SRA->(GetArea()),SRV->(GetArea()),SRH->(GetArea()),SRR->(GetArea()),SRF->(GetArea())}
	Local aFuncImp		:= {}
	Local aPeriodo		:= {}
	Local aPDImp		:= {}
	Local aIndAux		:= {}
	Local cBuffer       := ""
	Local cEmpAux   	:= ""
	Local cFilAux    	:= ""
	Local cMatImp		:= ""
	Local cDatarq		:= " "
	Local cEmpOri    	:= "##"
	Local lChangeEnv 	:= .F.
	Local nSeqSRD		:= 0
	Local cRot1			:= ""
	Local cRot2			:= ""
	Local cRoteiro		:= cRot1
	Local cSemana		:= "01"
	Local aTabelas 		:= {"SRA","SRV","SRD"}
	Local lExiste		:= .F.
	Local nTamMat		:= TamSX3('RA_MAT')[1]
	Local nTamRvCod		:= TamSX3('RV_COD')[1]
	Local aTemp			:= {} 
	Local nI			:= 0
	Local nX			:= 0
	Local nJ			:= 0
	Local nPos			:= 0
	Local aLinha		:= {}	
	Local aEmpresas		:= {}
	Local lApag			:= .F.
	Local lApagMov		:= .F.
	Local lPergApag		:= .T.
	
	DEFAULT aRelac		:= {}	
	
	PRIVATE aErro 		:= {}
	
	/*Ordem dos campos no array
	01 - * - Empresa Protheus
	02 - RD_FILIAL 	- Filial Protheus
	03 - RD_MAT 	- Matrícula
	04 - RD_PD		- Verba
	05 - RD_DATARQ	- Data de Referencia
	06 - RD_CC		- Centro de Custos
	07 - RD_TIPO1	- Tipo de Verba
	08 - RD_HORAS 	- Quantidade Calculada
	09 - RD_VALOR 	- Valor da Verba
	10 - RD_DATPGT  - Data de Processamento
	11 - RD_DEPTO   - Departamento
	12 - RD_ITEM    - ITEM
	13 - RD_INSS 	- Incidencia INSS
	14 - RD_IR   	- Incidencia IR
	15 - RD_FGTS	- Incidencia FGTS
	16 - RD_TIPO2	- Tipo de Processamento
	*/
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	SRV->(DbSetOrder(1))
	SRA->(DbSetOrder(1))
	
	While !FT_FEOF() .And. !lStopOnErr		
		cBuffer := FT_FREADLN()
		
		/*Checa se deve parar o processamento.*/				
		U_StopProc(aErro)
		U_StopProc(aFuncImp)
		U_StopProc(aPDImp)
		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.) //Distribui os itens no array
		
		cEmpAux   := aLinha[1]
		cFilAux   := aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpAux := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilAux	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf
		
		If !Empty(cDatarq) .and. cDatarq <> aLinha[5]
			cDatarq := aLinha[5]
		EndIf
		
		U_RHPREARE(cEmpAux,cFilAux,'','',@lChangeEnv,@lExiste,"GPEA250",aTabelas,"GPE",@aErro,OemToAnsi(STR0001))
		If lChangeEnv			
			
			if(cEmpOri != cEmpAux)
				lApag := .T.
				cEmpOri := cEmpAux
				aAdd(aEmpresas,cEmpOri)
			endIf
						
			cDatarq  := aLinha[5]
			cRot1 := fGetCalcRot("5")
			cRot2 := fGetCalcRot("6")
		EndIf
		
		If(lApag) .and. ExistReg(cRot1, cRot2)
			If lApagMov .or. ( lPergApag .and. MsgYesNo(OemToAnsi(STR0002))) // Apaga Movimentação Anterior?
				fDelMov('SRD',cRot1,cRot2)  //Exclui todos os registros tipo S e P (RD_TIPO2) da SRD
				lApagMov := .T.
			Else
				lPergApag := .F.
			EndIf
		EndIf
		
		lApag := .F.
		
		If lExiste
			//Verifica existencia de DE-PARA
			If !Empty(aRelac)
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					aCampos := U_fGetCpoMod("RHIMP16")
					For nX := 1 to Len(aCampos)
						For nJ := 1 to Len(aRelac)
							If (nPos := (aScan(aRelac[nJ],{|x| AllTrim(x) == AllTrim(aCampos[nX,1])}))) > 0
								aAdd(aIndAux,{nX,aRelac[nJ,1]})
							EndIf 
						Next nJ
					Next nX
				EndIf
				For nX := 1 to Len(aIndAux)
					aLinha[aIndAux[nX,1]] := u_GetCodDP(aRelac,aCampos[aIndAux[nX,1],1],aLinha[aIndAux[nX,1]],aIndAux[nX,2]) //Busca DE-PARA
				Next nX
			EndIf	
		
			cMatImp	 := PadR(aLinha[3],nTamMat)
			U_IncRuler(OemToAnsi(STR0001),cMatImp + '-' +  SubStr(aLinha[5],5,2),cStart,.F.,,oSelf)					
			
			if!(FuncExiste(cMatImp))
				If !Empty(aFuncImp)
					If aScan(aFuncImp,  { |x|  X[1]+X[2]+X[3] == cEmpAux + cFilAux + cMatImp }) == 0
						aAdd(aFuncImp, {cEmpAux,cFilAux,cMatImp})
					EndIf
				Else
					aAdd(aFuncImp,{cEmpAux,cFilAux,cMatImp})
				EndIf
				FT_FSKIP()
				Loop
			endIf						
			
			cVerbImp := PadR(aLinha[4],nTamRvCod)
			
			if!(VerbaExist(cVerbImp))
				If !Empty(aPDImp)
					If aScan(aPDImp,  { |x|  X[1]+X[2]+X[3] == cEmpAux + cFilAux + aLinha[4] }) == 0
						aAdd(aPDImp, {cEmpAux,cFilAux,aLinha[4]})
					EndIf
				Else
					aAdd(aPDImp,{cEmpAux,cFilAux,aLinha[4]})
				EndIf
				FT_FSKIP()
				Loop
			endIf			
				
			If aLinha[16] == "P"
				cRoteiro := cRot1
			ElseIf aLinha[16] == "S"
				cRoteiro := cRot2
			Else
				cRoteiro := cRot1
			EndIf
						
			nSeqSRD := fFindSeqSRD(cFilAux,cVerbImp,cMatImp,aLinha[5])						
			
			RecLock('SRD',.T.)			
			SRD->RD_FILIAL := FwXFilial('SRD')
			SRD->RD_MAT    := cMatImp
			SRD->RD_PD     := cVerbImp			
			SRD->RD_DATARQ := aLinha[5]	//sempre grava a data que vier no arquivo					
			SRD->RD_MES    := SubStr(aLinha[5],5,2)
			SRD->RD_CC     := aLinha[6]
			SRD->RD_TIPO1  := aLinha[7]
			SRD->RD_HORAS  := U_VldValue(aLinha[8])
			SRD->RD_VALOR  := U_VldValue(aLinha[9])
			SRD->RD_DATPGT := CtoD(aLinha[10])
			SRD->RD_DTREF  := CtoD(aLinha[10])
			SRD->RD_DEPTO  := aLinha[11]
			SRD->RD_ITEM   := aLinha[12]
			SRD->RD_INSS   := aLinha[13]
			SRD->RD_IR     := aLinha[14]
			SRD->RD_FGTS   := aLinha[15]
			SRD->RD_TIPO2  := aLinha[16]
			SRD->RD_SEQ    := AllTrim(STR(nSeqSRD))
			SRD->RD_PERIODO:= AnoMes(StoD(aLinha[5]+"01"))
			SRD->RD_PROCES := SRA->RA_PROCES
			SRD->RD_ROTEIR := cRoteiro
			SRD->RD_SEMANA := cSemana
			
			SRD->(MsUnLock())
		Else
			U_IncRuler(OemToAnsi(STR0001),aLinha[3] + '-' +  SubStr(aLinha[5],5,2),cStart,.T.,,oSelf)		
		EndIf		
		FT_FSKIP()
	EndDo
	FT_FUSE()
	
	If !(Empty(aFuncImp))
		aSort( aFuncImp ,,, { |x,y| x[1]+x[2]+X[3] < y[1]+Y[2]+Y[3] } )		
		aEval(aFuncImp,{|x|aAdd(aErro,'[' + x[1]+'/'+ x[2] + '/' + x[3] +']' + OemToAnsi(STR0003))})		
	EndIf
	
	If !Empty(aPDImp)
		aSort( aPDImp ,,, { |x,y| x[1]+x[2]+X[3] < y[1]+Y[2]+Y[3] } )
		aEval(aPDImp,{|x|aAdd(aErro,'['+ x[1] + '/' + x[2] + '/' + x[3] + ']' + OemToAnsi(STR0004))})
	EndIf
	
	cEmpOri := cEmpAnt	
	for nI:= 1 to Len(aEmpresas)
		cEmpAnt := aEmpresas[nI]		
		aTemp := u_PerInval()		
		aEval(aTemp,{|x|aAdd(aPeriodo,{cEmpAnt,x[1],x[2]})})
		aTemp := {}
	next nI	
	cEmpAnt := cEmpOri
	
	if(Len(aPeriodo) > 0)		
		aEval(aPeriodo,{|x|aAdd(aErro,'['+x[1]+'/'+x[2]+'/'+x[3]+']'+ OemToAnsi(STR0005))})
	endIf	
	
	U_RIM01ERR(aErro)
	
	aSize(aErro,0)
	aErro:= Nil
	aSize(aTemp,0)
	aTemp := Nil
	aSize(aPDImp,0)
	aPDImp := Nil
	aSize(aEmpresas,0)
	aEmpresas := Nil
	aSize(aFuncImp,0)
	aFuncImp := Nil	
	aSize(aPeriodo,0)
	aPeriodo := Nil
	
	aEval(aAreas,{|x|RestArea(x)})
	aSize(aAreas,0)
	aAreas := Nil
Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fDelMov   ºAutor  ³Leandro Drumond     º Data ³  22/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Apaga os dados da SRD.			                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fDelMov(cAlias,cRot1, cRot2)
	Local cQuery := ''
	
	cQuery := " DELETE FROM " + InitSqlName(cAlias) + " "
	If cAlias == "SRD"
		cQuery += " WHERE RD_ROTEIR IN ('" + cRot1 + "','" + cRot2 + "') AND RD_FILIAL = '" + xFilial("SRD") + "' "
	EndIf
	
	TcSqlExec( cQuery )
	
	TcRefresh( InitSqlName(cAlias) )
	
Return Nil


Static Function fFindSeqSRD(cFilAux,cPdAux,cMatAux, cDtArqAx)
	Local cAliasAux := "QTABAUX"
	Local cWhere	:= ''
	Local nRet 		:= 0
	
	cWhere += "%"
	cWhere += " SRD.RD_FILIAL     = 	'" + cFilAux    + "' "
	cWhere += " AND SRD.RD_PD     = 	'" + cPdAux     + "' "
	cWhere += " AND SRD.RD_MAT    = 	'" + cMatAux    + "' "
	cWhere += " AND SRD.RD_DATARQ = 	'" + cDtArqAx   + "' "
	cWhere += "%"
	
	BeginSql alias cAliasAux
		SELECT MAX(RD_SEQ) SEQMAX
		FROM %table:SRD% SRD
		WHERE 		%exp:cWhere% AND
		SRD.%NotDel%
	EndSql
	
	If Val((cAliasAux)->SEQMAX) > 0
		nRet := Val((cAliasAux)->SEQMAX) + 1
	Else
		nRet := 1
	EndIf
	
	(cAliasAux)->(DbCloseArea())
	
Return nRet

Static Function VerbaExist(cCod)	
	Local lResult	:= .F.	
	lResult := (SRV->(DbSeek(FwXFilial('SRV')+cCod)))	
Return (lResult)

Static Function FuncExiste(cCod)	
	Local lResult	:= .F.	
	lResult := (SRA->(DbSeek(FwXFilial('SRA') + cCod)))	
Return (lResult)

/*/{Protheus.doc} ExistReg
	Função que verifica se existe registros antes de perguntar se deseja limpar a tabela!
@author philipe.pompeu
@since 16/09/2015
@version P12
@return lResult,lógico,verdadeiro se existe registros nas tabelas
/*/
Static Function ExistReg(cRot1, cRot2)
	Local aArea		:= GetArea()
	Local cAliasAux := GetNextAlias()
	Local cWhere	:= ""
	Local lResult 	:= .F.

	cWhere += "%"
	cWhere += " SRD.RD_ROTEIR IN ('" + cRot1 + "','" + cRot2 + "')"
	cWhere += "%"
	
	BeginSql alias cAliasAux
		SELECT COUNT(*) AS TOTAL
		FROM %table:SRD% SRD 
		WHERE
		%exp:cWhere% AND RD_FILIAL = %xFilial:SRD% AND SRD.%NotDel%
	EndSql
	
	lResult := (cAliasAux)->TOTAL > 0  
		
	(cAliasAux)->(DbCloseArea())
	
	RestArea(aArea)
	
Return (lResult)
