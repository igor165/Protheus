#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RHIMP11.CH"

/************##********************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....:   RHIMP11          Autor  Leandro Drumond     Data:20/10/2012   ***
***********************************************************************************
***Descrição..:Responsável em Processar a Importacao dos historico salarial dos ***
***          funcionarios. Tabelas SR3 e SR7                                    ***
***********************************************************************************
***Uso........:Integracao do Modulo de RH dos Sistemas Logix X Protheus.        ***
***********************************************************************************
***Parâmetros.:cFileName  - Nome do Arquivo 						            ***
***********************************************************************************
***Retorno....:                                                                 ***
***********************************************************************************
***********************************************************************************
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP11
Responsável em Processar a Importacao dos historico salarial dos funcionarios. Tabelas SR3 e SR7 
@author Leandro Drumond
@since 20/10/2012
@version P11
@param cFileName, caractere, Nome do Arquivo
@return ${return}, ${return_description}
/*/
User Function RHIMP11(cFileName,aRelac,oSelf)
	Local aAreas		:= {SRA->(GetArea()),SX5->(GetArea()),SR3->(GetArea()),SR7->(GetArea())}
	Local aTabelas 	 	:= {"SRA","SR3","SR7"}
	Local aMotivos		:= GetMotivos()
	Local aIndAux		:= {}
	Local aErrMotivo	:= {}	
	Local aFuncImp		:= {}
	Local cBuffer       := ""
	Local cEmpresaArq   := ""
	Local cFilialArq    := ""
	Local cDescErro		:= ""
	Local cMatImp		:= ""
	Local cTipoImp		:= ""
	Local lEnvChange 	:= .F.
	Local nCount        := 0
	Local nX			:= 0
	Local nJ			:= 0
	Local nPos			:= 0
	Local lExiste		:= .F.
	Local aErro  		:= {}
	Local aLinha		:= {}
	
	Private nTamMat  	:= TamSX3('R3_MAT')[1]
	Private nTamTipo 	:= TamSX3('R3_TIPO')[1]

	DEFAULT aRelac		:= {}
	
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
		
	SR3->(DbSetOrder(2))
	SR7->(DbSetOrder(2))
	
	While !FT_FEOF() .And. !lStopOnErr
		cBuffer:= FT_FREADLN()
		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)		
		
		cEmpresaArq  := aLinha[1]		
		cFilialArq   := aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',@lEnvChange,@lExiste,"GPEA250",aTabelas,"GPE",@aErro,OemToAnsi(STR0001))		
		
		if(lEnvChange)
			SR3->(DbSetOrder(2))
			SR7->(DbSetOrder(2))
			aMotivos := GetMotivos()	
		endIf
		
		If lExiste	
			
			//Verifica existencia de DE-PARA
			If !Empty(aRelac)				
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					aCampos := U_fGetCpoMod("RHIMP11")
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
			
			If !(SRA->(DbSeek(xFilial("SRA")+cMatImp)))
				If !Empty(aFuncImp)
					If aScan(aFuncImp,  { |x|  X[1]+X[2] == cFilialArq + cMatImp }) == 0
						aAdd(aFuncImp, {cFilialArq,cMatImp})
					EndIf
				Else
					aAdd(aFuncImp,{cFilialArq,cMatImp})
				EndIf
				U_IncRuler(OemToAnsi(STR0001),cMatImp,cStart,.T.,,oSelf)
				FT_FSKIP()
				Loop
			EndIf
			
			cTipoImp := PadR(aLinha[6],nTamTipo)	
				
			If !((aScan(aMotivos,cTipoImp) > 0))
				If !Empty(aErrMotivo)
					If aScan(aErrMotivo,  { |x|  X == cTipoImp }) == 0
						aAdd(aErrMotivo, cTipoImp)
					EndIf
				Else
					aAdd(aErrMotivo, cTipoImp)
				EndIf
				U_IncRuler(OemToAnsi(STR0001),cMatImp,cStart,.T.,,oSelf)
				FT_FSKIP()
				Loop
			EndIf
			U_IncRuler(OemToAnsi(STR0001),cMatImp,cStart,.F.,,oSelf)			
			fGrvSr3Sr7(aLinha)			
		Else
			U_IncRuler(OemToAnsi(STR0001),aLinha[3],cStart,.T.,,oSelf)
		EndIf
				
		/*Checa se deve parar o processamento.*/
		U_StopProc(aErro)	
		U_StopProc(aFuncImp)
		U_StopProc(aErrMotivo)		
		FT_FSKIP()
	EndDo
	FT_FUSE()
	
	if(Len(aFuncImp) > 0)
		aEval(aFuncImp,{|x|aAdd(aErro,'[' + x[1]+'/'+ x[2] + ']' + OemToAnsi(STR0002))})
	endIf
	
	if(Len(aErrMotivo) > 0)		
		aEval(aErrMotivo,{|x|aAdd(aErro,'[' + x + ']' + OemToAnsi(STR0003))})	
	endIf	
	
	U_RIM01ERR(aErro)
	aEval(aAreas,{|x|RestArea(x)})	
Return Nil

/*/{Protheus.doc} fGrvSr3Sr7
@author Leandro Drumond 
@since 21/10/12
@version P11
@param aLinha, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function fGrvSr3Sr7(aLinha)	
	Local dDataImp	:= IIF(Empty(aLinha[4]),CtoD(''),Ctod(aLinha[4]))
	Local cMatAux		:= PadR(aLinha[3],nTamMat)
	Local cTipoAux 	:= PadR(aLinha[6],nTamTipo)	
	Local IsInsert	:= .T.
	Begin Transaction	
		/*Composição do Indice : R3_FILIAL+R3_MAT+DTOS(R3_DATA)+R3_SEQ+R3_TIPO+R3_PD*/
		IsInsert := !(SR3->(DbSeek(xFilial('SR3')+cMatAux+DtoS(dDataImp)+aLinha[5]+cTipoAux+"000")))
		
		RecLock('SR3',IsInsert)		
		
		SR3->R3_FILIAL	:= xFilial('SR3')
		SR3->R3_MAT		:= cMatAux
		SR3->R3_DATA	:= dDataImp
		SR3->R3_SEQ		:= aLinha[5]
		SR3->R3_TIPO	:= cTipoAux
		SR3->R3_PD		:= '000'
		SR3->R3_DESCPD	:= "SALARIO BASE"
		SR3->R3_VALOR	:= U_VldValue(aLinha[7])
		
		SR3->(MsUnLock())		
		
		/*R7_FILIAL+R7_MAT+DTOS(R7_DATA)+R7_SEQ+R7_TIPO*/
		IsInsert := !(SR7->(DbSeek(xFilial('SR7')+cMatAux+DtoS(dDataImp)+aLinha[5]+cTipoAux)))
		
		RecLock('SR7',IsInsert)		
		
		SR7->R7_FILIAL	:= xFilial('SR7')
		SR7->R7_MAT		:= cMatAux
		SR7->R7_DATA	:= dDataImp
		SR7->R7_SEQ		:= aLinha[5]
		SR7->R7_TIPO	:= cTipoAux
		SR7->R7_FUNCAO	:= aLinha[8]
		SR7->R7_DESCFUN	:= aLinha[9]
		SR7->R7_TIPOPGT	:= "M"
		SR7->R7_CATFUNC	:= aLinha[10]
		SR7->R7_CARGO	:= ""
		SR7->R7_DESCCAR	:= ""
		SR7->R7_USUARIO	:= aLinha[11]
		
		SR7->(MsUnLock())		
	End Transaction	
Return Nil

/*/{Protheus.doc} GetMotivos
@author philipe.pompeu
@since 23/07/2015
@version P12
@return ${return}, ${return_description}
/*/
Static Function GetMotivos()
	Local aResult	:= {}
	Local cMyAlias:= GetNextAlias()
	Local cQuery	:= ''
	
	cQuery := "SELECT X5_CHAVE FROM " + RetSqlName('SX5')+ " WHERE X5_FILIAL ='"+ FwXFilial('SX5') +"' AND X5_TABELA = '41' AND D_E_L_E_T_ = ' '"
	cQuery	:= ChangeQuery(cQuery)				
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cMyAlias, .F., .T.)
	
	while ( (cMyAlias)->(!Eof()) )		
		aAdd(aResult,(cMyAlias)->X5_CHAVE)
		(cMyAlias)->(dbSkip())
	End	

	(cMyAlias)->(dbCloseArea())
Return (aResult)
