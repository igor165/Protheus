#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP09.CH"

#XCOMMAND aKill <aVetor> => aSize(<aVetor>,0);<aVetor> := Nil

/*##*******************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP09.PRW Autor: Rafael Luis da Silva  Data:24/02/2010 		***
***********************************************************************************
***Descrição..: Responsável pela importação de Dependentes.						***
***********************************************************************************
***Uso........:        															***
***********************************************************************************
***Parâmetros.: cFileName, caractere, Nome do Arquivo                     	    ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***					ALTERAÇÕES FEITAS DESDE A CONSTRUÇÃO INICIAL       	 		***
***********************************************************************************
***RESPONSÁVEL.|DATA....|CÓDIGO|BREVE DESCRIÇÃO DA CORREÇÃO.....................***
***********************************************************************************
***P. Pompeu...|17/03/16|TUSAJP|Correção para importar a última linha do arquivo***
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP09
Responsável pela importação de Dependentes.
@author Rafael Luis da Silva
@since 24/02/2010
@version P11
@param cFileName, caractere, Nome do Arquivo
@return ${return}, ${return_description}
/*/
User Function RHIMP09(cFileName,aRelac,oSelf)
	Local cBuffer	:= ""
	Local cEmpresaArq	:= ""
	Local cFilialArq	:= ""
	Local aCab			:= {}
	Local aDependente	:= {}
	Local aItens        := {}
	Local aIndAux		:= {}
	Local lExistFunc	:= .F.
	Local cMatricula	:= ""
	Local lExiste		:= .T.
	Local aLog 			:= {}
	Local aErro 		:= {}
	Local aLinha		:= {}
	Local nTamMAt		:= TamSx3("RA_MAT")[1]
	Local nTamCOD		:= TamSx3("RB_COD")[1]
	Local nTamNome		:=	TamSX3("RB_NOME")[1]
	Local nTamLocNasc	:=	TamSX3("RB_LOCNASC")[1]
	Local lMudou		:= .T.
	Local cFilSRA		:= ''
	Local lToSkip		:= .T.
	Local lToSkip2		:= .T.
	Local nX			:= 0
	Local nY			:= 0
	Local nPos			:= 0
	Local dDtEntra
	Local cTemp	:= ''
	
	DEFAULT aRelac		:= {}
	
	If!(U_CanTrunk({'RB_NOME','RB_LOCNASC'}))
		Return (.T.)
	endIf
	
	FT_FUSE(cFileName)	
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)	
	FT_FGOTOP()
	SRA->(DbSetOrder(1))
	SRB->(DbSetOrder(1))
	While !(FT_FEOF()) .And. !lStopOnErr
		cBuffer := FT_FREADLN()
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		
		if(!U_Proceed(19,Len(aLinha)))
			Return (.F.)
		Else
			aSize(aLinha,19)
		endIf
		
		cEmpresaArq	:= aLinha[1]
		cFilialArq		:= aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf
				
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',,@lExiste,"GPEA020",{"SRB"},"GPE",@aErro,OemToAnsi(STR0001))
		if(lExiste)			
			cTemp := PadR(aLinha[3],nTamMAt)
			If !Empty(aRelac)
				cTemp := u_GetCodDP(aRelac,"RB_MAT",cTemp,"RA_MAT") //Busca DE-PARA
			EndIf			
			
			lMudou := ((cFilSRA <> xFilial('SRA')) .Or. (cMatricula <> cTemp))
			
			if(lMudou)
				if(Len(aCab)> 0 .And. Len(aItens) > 0)
					lMsErroAuto := .F.
					ASort(aItens,,,{|x,y|x[1,2]+x[2,2]+x[3,2] < y[1,2]+y[2,2]+y[3,2]})
					GravaDados(aCab,aItens)
					
					if lMsErroAuto
						aLog := GetAutoGrLog()
						aEval(aLog, { |x| aAdd(aErro, x)  } )
						aSize(aLog,0)
					endif
				endIf
				
				aCab:={}
				cFilSRA := xFilial('SRA')
				
				cMatricula := cTemp
				
				aAdd(aCab,{'RA_FILIAL'	,cFilSRA		,Nil})
				aAdd(aCab,{'RA_MAT'		,cMatricula	,Nil})
				aItens := {}
				lExistFunc := ExistFunc(xFilial('SRA'), cMatricula)
				
				if(!lExistFunc)
					aAdd(aErro,'['+cEmpresaArq+'/'+cFilialArq+'/'+cMatricula+']' + STR0002)
				endIf
			endIf
			
			if(lExistFunc)				
				aDependente := {}
				aAdd(aDependente,{'RB_FILIAL'	,aCab[1,2]		,Nil})
				aAdd(aDependente,{'RB_MAT'		,aCab[2,2]		,Nil})
				aAdd(aDependente,{'RB_COD'		,StrZero(Val(aLinha[4]), nTamCOD),Nil})
				aAdd(aDependente,{'RB_NOME'		,SubStr(aLinha[5],1,nTamNome)		,Nil})
				aAdd(aDependente,{'RB_DTNASC'	,CtoD(aLinha[6])	,Nil})
				aAdd(aDependente,{'RB_SEXO'		,aLinha[7]		,Nil})
				aAdd(aDependente,{'RB_GRAUPAR'	,aLinha[8]		,Nil})
				aAdd(aDependente,{'RB_TIPIR'	,aLinha[9]		,Nil})
				aAdd(aDependente,{'RB_TIPSF'	,aLinha[10]	,Nil})
				aAdd(aDependente,{'RB_LOCNASC'	,SubStr(aLinha[11],1,nTamLocNasc)	,Nil})
				aAdd(aDependente,{'RB_CARTORI'	,aLinha[12]	,Nil})
				aAdd(aDependente,{'RB_NREGCAR'	,aLinha[13]	,Nil})
				aAdd(aDependente,{'RB_NUMLIVR'	,aLinha[14]	,Nil})
				aAdd(aDependente,{'RB_NUMFOLH'	,aLinha[15]	,Nil})
				
				dDtEntra := CtoD(aLinha[16])
				
				if(Empty(dDtEntra) .Or. dDtEntra < SRA->RA_ADMISSA)
					dDtEntra := SRA->RA_ADMISSA
					If(dDtEntra < CtoD(aLinha[6]))
						dDtEntra := CtoD(aLinha[6])
					EndIf		
				endIf
								
				aAdd(aDependente,{'RB_DTENTRA'	,dDtEntra,Nil})
				aAdd(aDependente,{'RB_NUMAT'	,aLinha[17]	,Nil})
				aAdd(aDependente,{'RB_CIC'		,aLinha[18]	,Nil})				
				aAdd(aDependente,{'RB_TPDEP'	,IIF(Empty(aLinha[19]),GetTpDepen(aLinha[8]),aLinha[19]),Nil})				

				//Verifica existencia de DE-PARA
				If !Empty(aRelac)
					If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
						For nX := 1 to Len(aDependente)
							If aDependente[nX,1] <> "RB_MAT"
								For nY := 1 to Len(aRelac)
									If (nPos := (aScan(aRelac[nY],{|x| AllTrim(x) == AllTrim(aDependente[nX,1])}))) > 0
										aAdd(aIndAux,{nX,aRelac[nY,1]})
									EndIf 
								Next nY
							EndIf
						Next nX
					EndIf
					For nX := 1 to Len(aIndAux)
						aDependente[aIndAux[nX,1],2] := u_GetCodDP(aRelac,aDependente[aIndAux[nX,1],1],aDependente[aIndAux[nX,1],2],aIndAux[nX,2]) //Busca DE-PARA
					Next nX
				EndIf
				
				aAdd(aItens,aClone(aDependente))
				
				U_IncRuler(OemToAnsi(STR0001),(cMatricula +'/'+ aDependente[3,2]),cStart,(!lExistFunc),,oSelf)
			Else
				U_IncRuler(OemToAnsi(STR0001),(aLinha[3] +'/'),cStart,(!lExistFunc),,oSelf)
			endIf
		Else
			U_IncRuler(OemToAnsi(STR0001),'',cStart,(!lExiste),,oSelf)
		endIf		
		
		/*Checa se deve parar o processamento.*/
		U_StopProc(aErro)
		FT_FSKIP()
	EndDo
	FT_FUSE()
	
	/*Grava a última linha do arquivo!*/
	if(Len(aCab)> 0 .And. Len(aItens) > 0)
		lMsErroAuto := .F.
		ASort(aItens,,,{|x,y|x[1,2]+x[2,2]+x[3,2] < y[1,2]+y[2,2]+y[3,2]})
		GravaDados(aCab,aItens)
		
		if lMsErroAuto
			aLog := GetAutoGrLog()
			aEval(aLog, { |x| aAdd(aErro, x)  } )
			aSize(aLog,0)
		endif
	endIf
	
	aKill aLinha
	aKill aCab
	aKill aItens
	
	U_RIM01ERR(aErro)
	
	aKill aErro
Return

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
	lResult := SRA->(DbSeek(cFil + cMat))
Return (lResult)

/*/{Protheus.doc} GravaDados
@author PHILIPE.POMPEU
@since 19/08/2015
@version P12
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*/
Static Function GravaDados(aCab,aItens)
	Local aArea	:= GetArea()
	Local oModel,oSubModel
	Local cFil	:= ''
	Local cMat	:= ''
	Local nPos		:= 0
	Local cCampo	:= ''
	Local nI := 0
	Local cCod	:= ''
	Local lEdicao	:= .F.
	Local nJ := 0
	Local lRet := .T.
	Local aErro := {}
	Local lFieldExist := .T.
	Local lHouveErro:= .F.
	
	nPos := AScan (aCab, {|x|x[1]=='RA_FILIAL'})
	if(nPos > 0)
		cFil := aCab[nPos,2]
	endIf
	nPos := AScan (aCab, {|x|x[1]=='RA_MAT'})
	if(nPos > 0)
		cMat := aCab[nPos,2]
	endIf
	
	if(SRA->(dbSeek(cFil + cMat)))
		
		Gp020SetAuto(.T.)
		
		oModel 	:= FWLoadModel("GPEA020")
		
		oModel:SetOperation(4)
		oModel:Activate()
		oSubModel	:= oModel:GetModel("GPEA020_SRB")
		
		for nI:= 1 to Len(aItens)
			nPos := AScan (aItens[nI], {|x|x[1]=='RB_COD'})
			if(nPos > 0)
				cCod := aItens[nI,nPos,2]
				oSubModel:GoLine(1)
				lEdicao := ((oSubModel:SeekLine({{'RB_COD',cCod}})))
			Else
				cCod := StrZero(oSubModel:GetQtdLine(),2)
				lEdicao := .F.
			endIf
			
			if(!lEdicao) .And. (nI > 1)
				oSubModel:AddLine()
			EndIf
			
			for nJ:= 1 to Len(aItens[nI])
				cCampo := aItens[nI,nJ,1]
				xValor := aItens[nI,nJ,2]
				
				if(!lEdicao) .Or. (lEdicao .And. !(cCampo $"RB_FILIAL|RB_MAT|RB_COD"))
					lFieldExist:= (oSubModel:GetIdField(cCampo) > 0)
					
					if(lFieldExist .And. !Empty(xValor))
						if!(oSubModel:SetValue(cCampo,xValor))
							aErro := oModel:GetErrorMessage()
							aEval(aErro,{|x|IIF(Empty(x),,AutoGrLog(cFil +'/'+ cMat+'/'+ cCod +' : ' + cValToChar(x)))})
							
							lHouveErro := .T.
							Exit //Sai do Loop
						endIf
					endIf
					
				endIf
			next nJ
		next nI
		
		If (oModel:VldData())
			oModel:CommitData()
			lMsErroAuto := lHouveErro
		Else
			aErro := oModel:GetErrorMessage()
			if(len(aErro) > 0)
				aEval(aErro,{|x|IIF(Empty(x),,AutoGrLog(cFil +'/'+ cMat+'/'+ cCod +' : ' + cValToChar(x)))})
			endIf
			lMsErroAuto := .T.
		EndIf
		
		oModel:Deactivate()
		oModel:Destroy()
		oModel:= nil
	endIf
	
	aSize(aErro,0)
	RestArea(aArea)
Return (nil)

Static Function GetTpDepen(cGrauPar)
	Local cTpDepen := ''	
	Do Case
		Case (Empty(cGrauPar) .Or. cGrauPar == 'C') /*Conjugue*/
			cTpDepen := '01'
		Case (cGrauPar $ 'F|O') /*Filho ou Agregado*/
			cTpDepen := '03'
		OtherWise
			cTpDepen := '01'
	EndCase
Return cTpDepen
