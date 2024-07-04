#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RHIMP12.CH"

/*********###**********************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP12.PRW Autor: Leandro Drumond  Data:27/10/2012 	     	***
***********************************************************************************
***Descrição..: Responsável pela importação da Folha de Pagamento.				***
***********************************************************************************
***Uso........:        															***
********************************************************************************#**
***Parâmetros.: cFileName, caractere, Nome do Arquivo                     	    ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***					Alterações feitas desde a construção inicial       	 		***
***********************************************************************************
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP12
	Responsável pela importação da Folha de Pagamento.	
@author Leandro Drumond
@since 27/10/2012
@version P11
@param cFileName, caractere, Nome do Arquivo
@return ${return}, ${return_description}
/*/
User Function RHIMP12(cFileName,aRelac,oSelf)
	Local aFuncImp		:= {}
	Local aPDImp		:= {}
	Local aIndAux		:= {}
	Local cDatarq		:= ""
	Local cBuffer       := ""
	Local aLinha		:= {}
	Local cEmpresaArq   := ""
	Local cFilialArq    := ""
	Local cDescErro		:= ""
	Local cMatImp		:= ""
	Local cVerbImp		:= ""
	Local cDataAux 		:= ""
	Local cCC 			:= ""
	Local cItem 		:= ""
	Local cClVl			:= Space(TamSX3("RD_CC")[1])
	Local lIncluiu 		:= .F.
	Local lNew			:= .T.
	Local aTabelas 	 	:= {"SRD","SRC","SRA","SRV"}
	Local cSemana		:= "01"
	Local cRoteiro		:= ""
	Local lExiste		:= .F.
	Local lApag 		:= .T.
	Local aPeriodo		:= {}
	Local nTamMAT 		:= TamSx3('RA_MAT')[1]
	Local nTamRvCod 	:= TamSx3('RV_COD')[1]
	Local nTamCC 		:= TamSX3("RD_CC")[1]
	Local nTamItem 		:= TamSX3("RD_ITEM")[1]
	Local aErros 		:= {}
	Local aSeqPd		:= {}
	Local nPos			:= 0
	Local nX			:= 0
	Local nJ			:= 0
	Local lDoSkip		:= .T.
	Local cSequencia	:= ''
	
	DEFAULT aRelac		:= {}
	
	FT_FUSE(cFileName)	
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	/*Ordem dos campos no array que sera montado com base na linha do TXT
	01 - * - Empresa Protheus
	02 - RD_FILIAL 	- Filial Protheus
	03 - RD_MAT 	- Matrícula
	04 - RD_PD 		- Verba
	05 - RD_DATARQ 	- Data de Referência
	06 - RD_CC 		- Centro de Custo
	07 - RD_TIPO1 	- Tipo da Verba
	08 - RD_HORAS 	- Quantidade
	09 - RD_VALOR 	- Valor
	10 - RD_DATPGT 	- Data de Pagamento
	11 - RD_DEPTO 	- Departamento
	12 - RD_ITEM    - Item Contabil
	13 - RD_INSS 	- Incidência de INSS
	14 - RD_IR 		- Incidência de IR
	15 - RD_FGTS 	- Incidência de FGTS
	16 - RD_TIPO2 	- Tipo de Processamento
	*/
	SRV->(DbSetOrder(1))
	cBuffer := FT_FREADLN()		
	aLinha := {}
	aLinha := StrTokArr2(cBuffer,"|",.T.)		
	
	While !FT_FEOF() .And. !lStopOnErr
		
		cEmpresaArq  := aLinha[1]
		cFilialArq   := aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
			aLinha[1] := cEmpresaArq
			aLinha[2] := cFilialArq
		EndIf		
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',@lIncluiu,@lExiste,"GPEA250",aTabelas,"GPE",@aErros,OemToAnsi(STR0001))

		SRD->(DbSetOrder(RetOrder("SRD","RD_FILIAL+RD_MAT+RD_CC+RD_ITEM+RD_CLVL+RD_DATARQ+RD_PD+RD_SEQ+RD_PERIODO+RD_SEMANA+RD_ROTEIR+DTOS(RD_DTREF)")))
		
		IF lApag
			if(ExistReg())				
				If MsgYesNo(OemToAnsi(STR0005))
					fDelMov('SRC')	//Exclui todos os registros tipo C e A (RC_TIPO2) da SRD
					fDelMov('SRD')  //Exclui todos os registros tipo C e A (RD_TIPO2) da SRD
				Endif
			endIf
			lApag := .F.
		EndIf
		
		lDoSkip := .T.

		If lExiste		

			//Verifica existencia de DE-PARA
			If !Empty(aRelac)				
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					aCampos := U_fGetCpoMod("RHIMP12")
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
			
			cMatImp := PadR(aLinha[3],nTamMAT)			
			If !(SRA->(DbSeek(xFilial("SRA")+cMatImp)))
				If !Empty(aFuncImp)
					If aScan(aFuncImp,  { |x|  X[1]+X[2]+X[3] == cEmpresaArq + cFilialArq + cMatImp }) == 0
						aAdd(aFuncImp, {cEmpresaArq,cFilialArq,cMatImp})
					EndIf
				Else
					aAdd(aFuncImp,{cEmpresaArq,cFilialArq,cMatImp})
				EndIf
				U_IncRuler(OemToAnsi(STR0001),cMatImp + '/01',cStart,.T.,,oSelf)		
				cBuffer := FT_FREADLN()
				aLinha := {}
				aLinha := StrTokArr2(cBuffer,"|",.T.)						
				FT_FSKIP()
				Loop	
			EndIf
			
			cDataAux := ""
			
			While(cEmpresaArq   == aLinha[1] .And. cFilialArq   == aLinha[2] .And. cMatImp == PadR(aLinha[3],nTamMAT)) .And. !lStopOnErr

				If cDataAux <> aLinha[5]									
					cDataAux := aLinha[5]					
					aSeqPd := SeqSRC2(cMatImp,cDataAux)					
				EndIf
				
				cVerbImp := PadR(aLinha[4],nTamRvCod)
				
				nPos := aScan(aSeqPd,{|x|x[1] == cVerbImp})
				if(nPos == 0)
					aAdd(aSeqPd,{cVerbImp,1})
					nPos := Len(aSeqPd)
				EndIf
				
				If aSeqPd[nPos,2] > 9
					aAdd(aErros,'[' + cEmpresaArq + '/'+ cFilialArq+ '/'+ cMatImp + '/' + cVerbImp + ']'+ " Excedeu o limite de lançamentos da verba.")						
				ElseIf !SRV->(DbSeek(xFilial("SRV")+cVerbImp)) 
					If !Empty(aPDImp)
						If aScan(aPDImp,  { |x|  X[1]+X[2]+X[3] == cEmpresaArq + cFilialArq + aLinha[4] }) == 0
							aAdd(aPDImp, {cEmpresaArq,cFilialArq,aLinha[4]})
						EndIf
					Else
						aAdd(aPDImp,{cEmpresaArq,cFilialArq,aLinha[4]})
					EndIf										
					U_IncRuler(OemToAnsi(STR0001),cMatImp + '/1',cStart,.T.,,oSelf)
				Else				
					If(SubStr(aLinha[5],5,2) == '13') .OR. aLinha[16] == "S"
						cRoteiro := '132'	
					ElseIf aLinha[16] == "P"
						cRoteiro := "131"
					Else
						If(AllTrim(Upper(aLinha[16])) == 'A')
							cRoteiro := 'ADI'
						ElseIf(Upper(AllTrim(SRA->RA_CATFUNC)) == 'P')
							cRoteiro := 'AUT'
						Else
							cRoteiro := 'FOL'
						EndIf
					EndIf
					
					cSequencia := cValToChar(aSeqPd[nPos,2])
					
					cDatarq := aLinha[5]
					cCC 	:= Padr(aLinha[6],nTamCC)
					cItem 	:= Padr(aLinha[12],nTamItem)
					lNew := !(SRD->(DbSeek(FwxFilial('SRD') + cMatImp + cCC + cItem + cClVl + aLinha[5] + cVerbImp + cSequencia + SubStr(aLinha[5],1,6) + "01" + cRoteiro)))

					RecLock('SRD',lNew)
					SRD->RD_FILIAL := FwxFilial('SRD')
					SRD->RD_MAT    := cMatImp
					SRD->RD_PD     := cVerbImp
					SRD->RD_DATARQ := aLinha[5]
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
					SRD->RD_SEQ	 := cSequencia
					
					If((SRA->RA_FILIAL = xFilial('SRA')) .And. (SRA->RA_MAT = cMatImp))
						SRD->RD_PROCES	:= SRA->RA_PROCES
					Else
						SRD->RD_PROCES	:= ''
					EndIf

					SRD->RD_PERIODO:= SubStr(aLinha[5],1,6)
					SRD->RD_ROTEIR := cRoteiro
					SRD->RD_SEMANA := '01'
					
					SRD->(MsUnLock())
					
					U_IncRuler(OemToAnsi(STR0001),cMatImp + '/'+ cSequencia,cStart,.F.,,oSelf)
											
					aSeqPd[nPos,2]++
				EndIf
				lDoSkip := .F.
				FT_FSKIP()	
				cBuffer := FT_FREADLN()
				aLinha := {}
				aLinha := StrTokArr2(cBuffer,"|",.T.)
				
				If !Empty(aRelac) .and. !FT_FEOF()
					oSelf:IncRegua2("")
					If u_RhImpFil()
						cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
						cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
						aLinha[1] := cEmpresaArq
						aLinha[2] := cFilialArq
					EndIf
					For nX := 1 to Len(aIndAux)
						aLinha[aIndAux[nX,1]] := u_GetCodDP(aRelac,aCampos[aIndAux[nX,1],1],aLinha[aIndAux[nX,1]],aIndAux[nX,2]) //Busca DE-PARA
					Next nX
				EndIf
				/*Checa se deve parar o processamento.*/
				U_StopProc(aPDImp)
				U_StopProc(aFuncImp)
			EndDo			
		Else		
			U_IncRuler(OemToAnsi(STR0001),cMatImp + '/1',cStart,.T.,,oSelf)
		EndIf
		
		if(lDoSkip)			
			cBuffer := FT_FREADLN()
			aLinha := {}
			aLinha := StrTokArr2(cBuffer,"|",.T.)
			/*Checa se deve parar o processamento.*/
			U_StopProc(aErros)								
			FT_FSKIP()	
		endIf		
	EndDo
	FT_FUSE()	
	
	if(Len(aFuncImp) > 0)
		/*Ex:[EMPRESA/FILIAL/MATRICULA] Funcionário não encontrado, seus afastamentos não serão importados.*/
		aEval(aFuncImp,{|x|aAdd(aErros,'[' + x[1] + '/'+ x[2]+ '/'+ x[3] +']'+ OemToAnsi(STR0002))})
	endIf	
	
	if(Len(aPDImp) > 0)		
		aEval(aPDImp,{|x|aAdd(aErros,'[' + x[1] + '/'+ x[2]+ '/'+ x[3] +']'+ OemToAnsi(STR0003))})
	endIf
		
	aPeriodo := u_PerInval()
	if(Len(aPeriodo) > 0)		
		aEval(aPeriodo,{|x|aAdd(aErros,'[' + x[1] + '/'+ x[2] +']'+ OemToAnsi(STR0004))})
	endIf
	
	U_RIM01ERR(aErros)	
	
	aSize(aErros,0)
	aErros:= Nil
	aSize(aPeriodo,0)
	aPeriodo:= Nil
	aSize(aPDImp,0)
	aPDImp:= Nil
	aSize(aFuncImp,0)
	aFuncImp:= Nil
Return (.T.)

/*/{Protheus.doc} fDelMov
	Apaga os dados da SRD e SRC.
@author Leandro Drumond
@since 27/10/12
@version P11
@param cAlias, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function fDelMov(cAlias)
	Local cQuery := ''
	
	cQuery := " DELETE FROM " + InitSqlName(cAlias) + " "
	If cAlias == "SRD"
		cQuery += " WHERE RD_TIPO2 IN ('C','A','K') AND RD_FILIAL = '" + xFilial("SRD") + "' "
	EndIf
	If cAlias == "SRC"
		cQuery += " WHERE RC_FILIAL = '" + xFilial("SRC") + "' "
	EndIf
	
	TcSqlExec( cQuery )
	
	TcRefresh( InitSqlName(cAlias) )
	
Return Nil

/*/{Protheus.doc} SeqSRC2
@author philipe.pompeu
@since 30/07/2015
@version P11
@param cMatAux, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function SeqSRC2(cMatAux,cData)
	Local cAliasAux := GetNextAlias()
	Local aRet 		:= {}
	
	BeginSql alias cAliasAux
		SELECT RD_MAT,RD_PD,MAX(RD_SEQ) AS SEQMAX
		FROM %table:SRD% SRD
		INNER JOIN %table:SRV% SRV ON(RV_FILIAL = %XFilial:SRV% AND SRV.%NotDel% AND RV_COD = RD_PD)
		WHERE
		RD_FILIAL = %xFilial:SRD%
		AND
		RD_MAT = %exp:cMatAux%
		AND
		RD_DATARQ = %exp:cData%
		AND
		SRD.%NotDel%
		GROUP BY RD_MAT,RD_PD
	EndSql
	
	While ((cAliasAux)->(!Eof()) )
		aAdd(aRet,{(cAliasAux)->RD_PD,VAL((cAliasAux)->SEQMAX) + 1})
		(cAliasAux)->(dbSkip())
	EndDo
		
	(cAliasAux)->(DbCloseArea())	
Return aRet

/*/{Protheus.doc} ExistReg
	Função que verifica se existe registros antes de perguntar se deseja limpar a tabela!
@author philipe.pompeu
@since 16/09/2015
@version P12
@return lResult,lógico,verdadeiro se existe registros nas tabelas
/*/
Static Function ExistReg()
	Local aArea	:= GetArea()
	Local cAliasAux := GetNextAlias()
	Local lResult := .F.
	
	BeginSql alias cAliasAux
		SELECT SUM(SOMA) AS TOTAL from(
		SELECT COUNT(RD_TIPO2) AS SOMA
		FROM %table:SRD% SRD 
		WHERE
		RD_TIPO2 IN ('C','A','K') AND RD_FILIAL = %xFilial:SRD% AND SRD.%NotDel%
		
		UNION
		
		SELECT COUNT(RC_TIPO2) AS SOMA
		FROM %table:SRC% SRC 
		WHERE
		RC_FILIAL = %xFilial:SRC% AND SRC.%NotDel%
		) RESULTADO
	EndSql
	
	lResult := (cAliasAux)->(!Eof())
	
	if(lResult)
		lResult := (cAliasAux)->TOTAL > 0  
	endIf
		
	(cAliasAux)->(DbCloseArea())
	
	RestArea(aArea)
Return (lResult)
