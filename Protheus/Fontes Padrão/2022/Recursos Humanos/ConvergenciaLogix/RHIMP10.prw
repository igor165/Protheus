#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP10.CH"


/***###****************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP10.PRW Autor: Josias de Afelis  Data:04/03/2010 			***
***********************************************************************************
***Descrição..: Responsável pela importação de Afastamentos.					***
***********************************************************************************
***Uso........:        															***
***********************************************************************************
***Parâmetros.: cFileName, caractere, Nome do Arquivo                     	    ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***					Alterações feitas desde a construção inicial       	 		***
***********************************************************************************
***RESPONSÁVEL.|DATA....|CÓDIGO|BREVE DESCRIÇÃO DA CORREÇÃO.....................***
***********************************************************************************
***P. Pompeu...|17/03/16|TUSA71|Preencher R8_PER e R8_PROCES com valores válidos***
***P. Pompeu...|07/04/16|TUUEAS|Alteração no tratamento do Log e criação de     ***
***------------|--------|------|variáveis de memória para todos os campos.      ***
***P. Pompeu...|29/04/16|TUZASZ|Melhoria Perfomance, alteração p/ usar RecLock  ***
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP10
	Responsável pela importação de Afastamentos.
@author Josias de Afelis
@since 04/03/2010
@version P11
@param cFileName, caractere, Nome do Arquivo
@return ${return}, ${return_description}
/*/
User Function RHIMP10(cFileName,aRelac,oSelf)
	Local aAreas		:= {SRA->(GetArea()),SR8->(GetArea())}
	Local aTabelas		:= {"SRA","SR8"}	
	Local aFuncAux		:= {}	
	Local aLinha		:= {}
	Local aIndAux		:= {}
	Local cBuffer		:= ""
	Local cMatricula	:= ""
	Local cEmpresaArq	:= ""
	Local cFilialArq	:= ""
	Local lExiste		:= .F.
	Local lMudou		:= .F.	
	Local nTamMat		:= TamSX3('RA_MAT')[1]
	Local nTamTp		:= TamSx3("R8_TIPO")[1]
	Local nX			:= 0
	Local nJ			:= 0
	Local nPos			:= 0
	Local lExistFunc	:= .F.
	Local aErros 		:= {}
	Local cTabOrig		:= ''	
	Local aInitPad		:= {} 
	Local lInvalido		:= .F.
	Local lNew			:= .T.
	Local cChave		:= ""
	Local cTpAfa		:= ""
	Local nLinha		:= 0
	Local aTpAfInval	:= {}
	Local nSizeFile		:= ""
	Local cNumId		:= ""
	Private cLinha		:= ""
	Private nDuracao	:= 1
	Private cContaAfa	:= ""
	Private oHash		:= Nil
	
	DEFAULT aRelac		:= {}
	
	FT_FUSE(cFileName)	
	/*Seta tamanho da Regua*/
	nSizeFile := U_ImpRegua(oSelf)	
	FT_FGOTOP()
	
	nSizeFile := Len(cValToChar(nSizeFile))
	
	SX3->(DbSetOrder(1))
	RCM->(DbSetOrder(1))
	SRV->(DbSetOrder(1))
	
	if(!U_Proceed(17,Len(aLinha)))
		Return (.F.)
	Else
		aSize(aLinha,17)
	endIf
		
	While (!FT_FEOF() .And. !lStopOnErr)
		cBuffer:= FT_FREADLN()
		nLinha++
		cLinha := StrZero(nLinha,nSizeFile)		
		U_IncRuler("Linha",cLinha,cStart,/*lIgnore*/,/*lOnlyMsg*/,oSelf)
					
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		lInvalido	:= .F.					
		cEmpresaArq 	:= aLinha[1]
		cFilialArq		:= aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',@lMudou,@lExiste,"GPEA240",aTabelas,"GPE",@aErros,OemToAnsi(STR0001))		
		if(lExiste)
			If (cTabOrig != RetSqlname('SR8'))						
				cTabOrig := RetSqlname('SR8')								
				aInitPad := {}
				SX3->(dbSeek('SR8'))					
				While !SX3->(EOF()) .And. (SX3->X3_ARQUIVO == 'SR8')
					If !(SX3->X3_CAMPO $ "R8_FILIAL|R8_MAT|R8_DATAINI|R8_TIPO|R8_TIPOAFA") .And.  X3USO(SX3->X3_USADO) .and. !Empty(SX3->X3_RELACAO)
						aAdd(aInitPad,{AllTrim(SX3->X3_CAMPO),SX3->X3_RELACAO})
					EndIf
					SX3->(DbSkip())
				EndDo
				
				if(oHash != Nil)
					oHash:Clean()
					FreeObj(oHash)	
				endIf
				
				oHash := aToHM(aClone(aInitPad),1)
			EndIf			
			
			//Verifica existencia de DE-PARA
			If !Empty(aRelac)				
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					aCampos := U_fGetCpoMod("RHIMP10")
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
			
			cMatricula := PadR(aLinha[3],nTamMat)

			lExistFunc := ExistFunc(xFilial('SRA'), cMatricula)
			
			If !lExistFunc
				
				If aScan(aFuncAux,  { |x|  X[2]+X[3] == cFilialArq + cMatricula }) == 0
					aAdd(aFuncAux, {cEmpresaArq,cFilialArq,cMatricula,cLinha})
				EndIf
						
				lInvalido := .T.
			else			
				nDuracao := DateDiffDay(CToD(aLinha[6]),IIF(Empty(aLinha[7]),Date(),cToD(aLinha[7])))				
				cContaAfa:= aLinha[10]
				
				cTpAfa := TpAfast(aLinha[5])
				
				if(RCM->(DbSeek(xFilial("RCM") + cTpAfa)))										
					if(Empty(RCM->RCM_PD) .Or. !(SRV->(dbSeek(xFilial("SRV")+ RCM->RCM_PD))))
						aAdd(aErros,"[Linha "+ cLinha + "] Tipo de Afastamento sem verba cadastrada ou verba inválida -> "+ cTpAfa)
						lInvalido := .T.					
					endIf
				else
					aAdd(aErros,"[Linha "+ cLinha + "] Tipo de Afastamento não encontrado ->"+ cTpAfa)					
					lInvalido := .T.
				endIf
			EndIf						
			
			if(!lInvalido)				
				IF (Empty(aLinha[9]))
					SR8->(DbSetOrder(1))
					cChave := xFilial("SR8")
					cChave += SRA->RA_MAT
					cChave += DtoS(CToD(aLinha[6]))
					cChave += Space(nTamTp)
					lNew := !(SR8->(DbSeek(cChave)))					
				else
					SR8->(DbSetOrder(2))
					cChave := xFilial("SR8")
					cChave += SRA->RA_MAT
					cChave += aLinha[9]
					cChave += DtoS(CToD(aLinha[4]))
					cChave += RCM->RCM_TIPO					
					lNew := !(SR8->(DbSeek(cChave)))					
					
					if(lNew)/*Caso não tenha encontrado com a sequência, procura usando a data inicial*/
						SR8->(DbSetOrder(1))
						cChave := xFilial("SR8")
						cChave += SRA->RA_MAT
						cChave += DtoS(CToD(aLinha[6]))
						cChave += Space(nTamTp)
						lNew := !(SR8->(DbSeek(cChave)))
					endIf
				EndIf
				
				RecLock("SR8",lNew)
				
				if(lNew)
					SR8->R8_FILIAL	:= xFilial("SR8")
					SR8->R8_MAT 	:= SRA->RA_MAT
					SR8->R8_TIPO	:= Space(nTamTp)
					SR8->R8_TIPOAFA	:= RCM->RCM_TIPO
					SR8->R8_DATAINI	:= CToD(aLinha[6])
					
					cNumId := "SR8" + SRA->RA_MAT
					cNumId += RCM->RCM_PD
					cNumId	+= DtoS(SR8->R8_DATAINI) 
					
					SR8->R8_NUMID		:= cNumId
										
					aEval(aInitPad,{|x|SR8->&(x[1]) := InitPad(x[2])})
				endIf				
				
				SR8->R8_DATA 		:= GetValue(aLinha[4] ,'R8_DATA'		,{|x|CToD(x)})				
				SR8->R8_DATAFIM 	:= GetValue(aLinha[7] ,'R8_DATAFIM'	,{|x|CToD(x)})
				SR8->R8_SEQ 		:= GetValue(aLinha[9] ,'R8_SEQ', {|x| StrZero(Val(x),3)})
				SR8->R8_CONTAFA 	:= GetValue(aLinha[10],'R8_CONTAFA')
				SR8->R8_DIASEMP 	:= GetValue(aLinha[11],'R8_DIASEMP'	,{|x|Val(x)})
				SR8->R8_DPAGAR 		:= GetValue(aLinha[12],'R8_DPAGAR'	,{|x|Val(x)})
				SR8->R8_DURACAO		:= DateDiffDay( SR8->R8_DATAINI , SR8->R8_DATAFIM) + 1//R8_DURACAO				
				SR8->R8_TPEFD 		:= GetValue(aLinha[13]	,'R8_TPEFD')				
				
				if(Empty(SR8->R8_TPEFD))
					SR8->R8_TPEFD := RCM->RCM_TPEFD	
				endIf
				
				SR8->R8_TIPOAT 		:= GetValue(aLinha[14]	,'R8_TIPOAT')
				SR8->R8_NMMED 		:= GetValue(aLinha[15]	,'R8_NMMED')
				SR8->R8_UFCRM 		:= GetValue(aLinha[16]	,'R8_UFCRM')
				SR8->R8_CRMMED 		:= GetValue(aLinha[17]	,'R8_CRMMED')
				SR8->R8_PD 			:= RCM->RCM_PD
				SR8->R8_TPEFD		:= RCM->RCM_TPEFD
				SR8->R8_PROCES		:= SRA->RA_PROCES
				SR8->R8_PER 		:= AnoMes(SR8->R8_DATAINI) //R8_PER
				SR8->R8_NUMPAGO		:= "01"				
				
				IF !(Empty(SR8->R8_SEQ)) //R8_SEQ
					SR8->R8_CID := GetValue(aLinha[8],'R8_CID')					
				EndIf
								
				IF !(Empty(SR8->R8_CONTAFA)) //R8_CONTAFA
					SR8->R8_CONTINU := 1				
				EndIf
								
				SR8->(MsUnlock())
				
				/*Caso a verba não seja Diária, verificar quantidade de afastamentos...*/
				if(!(SRV->RV_LCTODIA == "S"))					
					Chk10xPd(aErros)
				endIf
			endIf
		
		endIf				
		
		/*Checa se deve parar o processamento.*/
		U_StopProc(aErros)
		FT_FSKIP()	
	EndDo
	FT_FUSE() /*Libera Arquivo*/
		
	if(Len(aFuncAux) > 0)
		/*Ex:[EMPRESA/FILIAL/MATRICULA - Linha X] Funcionário não encontrado, seus afastamentos não serão importados.*/
		aEval(aFuncAux,{|x|aAdd(aErros,'[' + x[1] + '/'+ x[2]+ '/'+ x[3] +' - Linha '+ x[4] +']'+ OemToAnsi(STR0002))})
	endIf	
	
	U_RIM01ERR(aErros)
	If(oHash != Nil)
		oHash:Clean()
		FreeObj(oHash)
	EndIf	
	aSize(aLinha,0)
	aLinha := Nil	
	aSize(aErros,0)
	aErros := Nil
	aSize(aFuncAux,0)	
	aFuncAux := Nil	
	aEval(aAreas,{|x|RestArea(x)})
Return (.T.)

/*/{Protheus.doc} ExistFunc
@author PHILIPE.POMPEU
@since 06/07/2015
@version P12
@param cFil, character, (Descrição do parâmetro)
@param cMat, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function ExistFunc(cFil,cMat)	 
	Local lResult	:= .F.
	
	SRA->(DbSetOrder(1))	
	lResult := SRA->(DbSeek(cFil + cMat))	
Return (lResult)

/*/{Protheus.doc} GetValue
@author philipe.pompeu
@since 23/07/2015
@version P12
@param uValue, variável, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param bConv, booleano, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function GetValue(uValue,cField,bConv)	
	Local uResult	:= Nil
	Local cType	:= 'U'	
	Default bConv := Nil
	
	if(Empty(uValue))		
		if!(HMGet(oHash,cField,@uResult))
			uResult := CriaVar(cField,.T.,'L',.F.)
		Else					
			uResult := InitPad(uResult[1,2]) 
		endIf
	Else
		if(bConv == Nil)
			uResult :=  uValue
		Else
			uResult :=  eVal(bConv,uValue)
		endIf
	endIf		
Return (uResult)

/*/{Protheus.doc} TpAfast
@author philipe.pompeu
@since 23/07/2015
@version P12
@param cTp, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function TpAfast(cTp)
	Local cTipo	:= ''
	Do Case
		Case cTp == "F"			
			cTipo := "001"			
		Case (cTp) == "D"			
			cTipo := "002"			
		Case (cTp) == "O"			
			cTipo := "003"			
		Case (cTp) == "P"			
			cTipo := "004"			
		Case (cTp) == "R"			
			cTipo := "005"			
		Case (cTp == "Q" .And. SRA->RA_CATFUNC $ "P|A")			
			cTipo := "007"			
		Case (cTp == "Q" .And. nDuracao >= 60 .And. !Empty(cContaAfa))			
			cTipo := "008"			
		Case (cTp) == "Q"			
			cTipo := "006"			
		Case (cTp) == "B"			
			cTipo := "010"			
		Case (cTp) == "6"			
			cTipo := "011"			
		Case (cTp) == "7"			
			cTipo := "012"			
		Case (cTp) == "W"			
			cTipo := "013"			
		Case (cTp) == "X"			
			cTipo := "014"			
		Case (cTp) == "8"			
			cTipo := "015"			
		Case (cTp $ "Y|V")			
			cTipo := "016"			
		Case (cTp $ "1|U")			
			cTipo := "017"
		Case Len(AllTrim(cTp)) == 3 //Nas implementações CMNET e demais o código pode ser enviado já de acordo com o tipo de ausencia da P12.
			cTipo := cTp
		Otherwise
			cTipo := "016"
	End Case
Return (cTipo)

/*/{Protheus.doc} Chk10xPd
	Confere se existem mais de 9 registros de ausências para mesma verba/tipo de ausência
@author PHILIPE.POMPEU
@since 02/05/2016
@version P12
@param aErros, vetor, erros serão guardados nesse vetor
/*/
Static Function Chk10xPd(aErros)
	Local aArea	:= GetArea()
	Local cMyAlias := GetNextAlias()
	Local cQuery	:= ''
	Local cMax		:= ""
	Local cMsg		:= ''	
	Default aErros := {}

	if(Empty(SRV->RV_QTDLANC))
		cMax := "9"
	else
		cMax := cValToChar(SRV->RV_QTDLANC)
	endIf
		
	cQuery := "SELECT R8_PER, COUNT(R8_SEQ) AS TOTAL FROM "
	cQuery += RetSqlName( "SR8" )
	cQuery += " WHERE D_E_L_E_T_ = '' AND R8_MAT='"+ SRA->RA_MAT + "'"
	cQuery += " AND R8_FILIAl = '"+ xFilial("SR8") + "' AND R8_TIPOAFA='"+ RCM->RCM_TIPO + "'" 
	cQuery += " GROUP BY R8_PER"	
	cQuery += " HAVING COUNT(R8_SEQ) > "+ cMax
	
	cQuery	:= ChangeQuery(cQuery)				
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cMyAlias, .F., .T.)
	
	if((cMyAlias)->(! Eof()))	
		while ((cMyAlias)->(!Eof()))				
			
			cMsg := "[ Linha " + cLinha + "]" 
			cMsg += "["+ SRA->RA_FILIAL + "/" + SRA->RA_MAT + "] Registro importado com a seguinte ressalva: "
			cMsg += "Existem " + cValToChar((cMyAlias)->TOTAL) + " Ausências para o Período ["
			cMsg += (cMyAlias)->R8_PER + "] com a verba [" + RCM->RCM_PD + "]."
			cMsg += " Certifique-se de alterá-la para permitir Lançamento Diário(RV_LCTODIA)."   
			aAdd(aErros,cMsg)
									
			(cMyAlias)->(dbSkip())
		End				
	EndIf
		
	(cMyAlias)->(dbCloseArea())
	RestArea(aArea)
Return nil
