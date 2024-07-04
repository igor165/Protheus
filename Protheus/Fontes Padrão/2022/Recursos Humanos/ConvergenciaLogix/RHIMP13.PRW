#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RHIMP13.CH"

/****************************##****************************************************
***********************************************************************************
***********************************************************************************
***Funcão..: RHIMP13.PRW Autor: Leandro Drumond Data: 02/11/2012                ***
***********************************************************************************
***Descrição..:Importacao do Histórico de	Transferências(SRE) do Funcionário    ***
***********************************************************************************
***Uso........:        																   ***
***********************************************************************************
***Parâmetros.:cFileName, caractere, Nome do Arquivo 		            		   ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***********************************************************************************
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/
/*/{Protheus.doc} RHIMP13
Responsavel em Processar a Importacao do historico de transferencia dos funcionarios. Tabela SRE
@author Leandro Drumond
@since 02/11/2012
@version P11
@param cFileName, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
User Function RHIMP13(cFileName,aRelac,oSelf)
	Local aAreas	:= {SRA->(GetArea()),SRE->(GetArea()),CTT->(GetArea()),SQB->(GetArea())}	
	Local aTabelas 		:= {"SRA","SRE","CTT","SQB"}
	Local aFuncOri		:= {}
	Local aFuncDest		:= {}
	Local aDeptoImp		:= {}
	Local aCCImp		:= {}
	Local aItemImp		:= {}
	Local aIndAux		:= {}
	Local cBuffer       := ""
	Local cEmpresaArq   := ""
	Local cFilialArq    := ""
	Local cMatOri		:= ""
	Local cCCOri		:= ""
	Local cCCDest		:= ""
	Local cDeptoOri		:= ""
	Local cDeptoDest	:= ""
	Local cDataTrans	:= ""
	Local lBuscaAux		:= .F.
	Local lTransfEmp	:= .F.
	Local lDeleta		:= .T.
	Local nTamMat		:= TAMSX3('RA_MAT')[1]
	Local nTamCC		:= TAMSX3('CTT_CUSTO')[1]
	Local nTamDepto		:= TAMSX3('QB_DEPTO')[1]
	Local nPosAux		:= 0
	Local nX			:= 0
	Local nJ			:= 0
	Local nPos			:= 0
	Local nTamFilial	:= TAMSX3('RA_FILIAL')[1]
	LOCAL lExiste       := .F.	
	Local aErro 		:= {}
	Local lItemClVl 	:= SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "13"
	Local aLinha		:= {}
	
	DEFAULT aRelac		:= {}
	
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	/*Ordem dos campos no array que sera montado com base na linha do TXT
	01 - RE_DATA    - Data de Transferencia
	02 - RE_EMPD 	- Empresa Origem
	03 - RE_FILIALD	- Filial Origem
	04 - RE_MATD	- Matrícula Origem
	05 - RE_CCD 	- Centro de Custos Origem
	06 - RE_EMPP	- Empresa Destino
	07 - RE_FILIALP	- Filial Destino
	08 - RE_MATP 	- Matricula Destino
	09 - RE_CCP 	- Centro de Custos Destino
	10 - RE_DEPTOD 	- Departamento Origem
	11 - RE_DEPTOP 	- Departamento Destino
	12 - RE_ITEMD 	- Item Contabil Origem
	13 - RE_ITEMP	- Item Contabil Destino
	*/
	
	While !FT_FEOF() .And. !lStopOnErr
		
		/*Checa se deve parar o processamento.*/
		U_StopProc(aErro)
		U_StopProc(aFuncOri)
		U_StopProc(aItemImp)
		U_StopProc(aFuncDest)
		U_StopProc(aCCImp)
		U_StopProc(aDeptoImp)
		
		cBuffer := FT_FREADLN()
		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		
		cEmpresaArq	:= AllTrim(aLinha[2])
		cFilialArq	:= AllTrim(aLinha[3])
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[7],"FILIAL",aLinha[6],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[7],"FILIAL",aLinha[6],.T.,.F.) //Busca a Filial no DE-PARA
			aLinha[6] := cEmpresaArq 
			aLinha[7] := cFilialArq
					
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[3],"FILIAL",aLinha[2],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[3],"FILIAL",aLinha[2],.T.,.F.) //Busca a Filial no DE-PARA
			aLinha[2] := cEmpresaArq 
			aLinha[3] := cFilialArq
		EndIf		
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',.F.,@lExiste,"GPEA250",aTabelas,"GPE",@aErro,OemToAnsi(STR0001))
		
		If lDeleta
			fDelSRE()
			lDeleta := .F.
		EndIf
		
		If lExiste

			//Verifica existencia de DE-PARA
			If !Empty(aRelac)				
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					aCampos := U_fGetCpoMod("RHIMP13")
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

			lTransfEmp := !(aLinha[2] == aLinha[6])
			
			cMatOri	 	:=	PadR(aLinha[4],nTamMat)
			cDataTrans 	:= aLinha[1]
			
			U_IncRuler(OemToAnsi(STR0001),cMatOri,cStart,.F.,,oSelf)
			
			If !(SRA->(DbSeek(aLinha[3]+cMatOri)))
				If !Empty(aFuncOri)
					If aScan(aFuncOri,  { |x|  X[1]+X[2]+X[3] == cEmpresaArq + cFilialArq + cMatOri}) == 0
						aAdd(aFuncOri, {cEmpresaArq,cFilialArq,cMatOri})
					EndIf
				Else
					aAdd(aFuncOri,{cEmpresaArq,cFilialArq,cMatOri})
				EndIf
				FT_FSKIP()
				Loop
			EndIf
			If lItemClVl
				If Empty(aLinha[12])
					If !Empty(aItemImp)
						If aScan(aItemImp,  { |x|  X[1]+X[2]+X[3]+x[4] == cEmpresaArq + xFilial("CTD",Sra->ra_Filial) + cMatOri + cDataTrans}) == 0
							aAdd(aItemImp, {cEmpresaArq,xFilial("CTD",Sra->ra_Filial),cMatOri,cDataTrans,"O"})
						EndIf
					Else
						aAdd(aItemImp,{cEmpresaArq,xFilial("CTD",Sra->ra_Filial),cMatOri,cDataTrans,"O"})
					EndIf
					FT_FSKIP()
					Loop
				ElseIf Empty(aLinha[13])
					If !Empty(aItemImp)
						If aScan(aItemImp,  { |x|  X[1]+X[2]+X[3]+x[4] == cEmpresaArq + xFilial("CTD",SRA->RA_FILIAL) + cMatOri + cDataTrans}) == 0
							aAdd(aItemImp, {cEmpresaArq,xFilial("CTD",SRA->RA_FILIAL),cMatOri,cDataTrans,"D"})
						EndIf
					Else
						aAdd(aItemImp,{cEmpresaArq,xFilial("CTD",SRA->RA_FILIAL),cMatOri,cDataTrans,"D"})
					EndIf
					FT_FSKIP()
					Loop
				EndIf
			EndIf
			
			If lTransfEmp				
				If !Empty(aFuncDest)
					If ( nPosAux := aScan(aFuncDest,  { |x|  X[1]+X[2]+X[3] == aLinha[6] + substr(aLinha[7],1,nTamFilial) + aLinha[8] }) ) > 0
						If !aFuncDest[nPosAux,5]
							FT_FSKIP()
							Loop
						EndIf						
					EndIf
				EndIf
				
				If fChkCpo('SRA',aLinha[6],substr(aLinha[7],1,nTamFilial),'RA_MAT',aLinha[8])//Tabela,Empresa,Filial,Campo,Chave
					aAdd(aFuncDest, {aLinha[6],substr(aLinha[7],1,nTamFilial),aLinha[8],aLinha[1],.T.})
				Else
					aAdd(aFuncDest, {aLinha[6],substr(aLinha[7],1,nTamFilial),aLinha[8],aLinha[1],.F.})
					FT_FSKIP()
					Loop
				EndIf
				
			EndIf
			
			cMatOri	 :=	PadR(aLinha[8],nTamMat)
			
			If !(SRA->(DbSeek(substr(aLinha[7],1,nTamFilial)+cMatOri)))
				If !Empty(aFuncDest)
					If aScan(aFuncDest,  { |x|  X[1]+X[2]+X[3] == cEmpresaArq + substr(aLinha[7],1,nTamFilial) + aLinha[8] }) == 0
						aAdd(aFuncDest, {cEmpresaArq,substr(aLinha[7],1,nTamFilial),aLinha[8],aLinha[1],.F.})
					EndIf
				Else
					aAdd(aFuncDest,{cEmpresaArq,substr(aLinha[7],1,nTamFilial),aLinha[8],aLinha[1],.F.})
				EndIf
				FT_FSKIP()
				Loop
			EndIf
			
			cCCOri := PadR(aLinha[5],nTamCC)
			cCCDest:= PadR(aLinha[9],nTamCC)
			
			If !CTT->(DbSeek(xFilial("CTT",SRA->RA_FILIAL)+cCCOri))
				If !Empty(aCCImp)
					If aScan(aCCImp,  { |x|  X[1]+X[2]+X[3]+x[4] == cEmpresaArq + xFilial("CTT",sra->ra_filial) + cCCOri + cDataTrans}) == 0
						aAdd(aCCImp, {cEmpresaArq,xFilial("CTT",sra->ra_filial),cCCOri,cDataTrans,"O",.F.})
					EndIf
				Else
					aAdd(aCCImp,{cEmpresaArq,xFilial("CTT",SRA->RA_FILIAL),cCCOri,cDataTrans,"O",.F.})
				EndIf
				FT_FSKIP()
				Loop
			EndIf
			
			cDeptoOri := PadR(aLinha[10],nTamDepto)
			cDeptoDest:= PadR(aLinha[11],nTamDepto)
			
			If !Empty(cDeptoOri)
				If !SQB->(DbSeek(xFilial("SQB",SRA->RA_FILIAL)+cDeptoOri))
					If !Empty(aDeptoImp)
						If aScan(aDeptoImp,  { |x|  X[1]+X[2]+X[3]+X[4] == cEmpresaArq + xFilial("SQB",sra->ra_filial) + cDeptoOri + cDataTrans }) == 0
							aAdd(aDeptoImp, {cEmpresaArq,xFilial("SQB",sra->ra_filial),cDeptoOri,cDataTrans,"O",.F.})
						EndIf
					Else
						aAdd(aDeptoImp,{cEmpresaArq,xFilial("SQB",sra->ra_filial),cDeptoOri,cDataTrans,"O",.F.})
					EndIf
					FT_FSKIP()
					Loop
				EndIf
			EndIf			
			
			If lTransfEmp
				
				If !Empty(aDeptoImp)
					If ( nPosAux := aScan(aDeptoImp,  { |x|  X[1]+X[2]+X[3] == aLinha[6] + xFilial("SQB",sra->ra_filial) + cDeptoDest }) ) > 0
						If !aDeptoImp[nPosAux,6]
							FT_FSKIP()
							Loop
						EndIf						
					EndIf
				EndIf
				
				
				If fChkCpo('SQB',aLinha[6],xFilial("SQB",sra->ra_filial),'QB_DEPTO',cDeptoDest)//Tabela,Empresa,Filial,Campo,Chave
					aAdd(aDeptoImp, {aLinha[6],xFilial("SQB",sra->ra_filial),cDeptoDest,aLinha[1],"D",.T.})
				Else
					aAdd(aDeptoImp, {aLinha[6],xFilial("SQB",sra->ra_filial),cDeptoDest,aLinha[1],"D",.F.})
					FT_FSKIP()
					Loop
				EndIf
								
				
				If !Empty(aCCImp)
					If ( nPosAux := aScan(aCCImp,  { |x|  X[1]+X[2]+X[3] == aLinha[6] +xFilial("CTT",sra->ra_filial) + cCCDest }) ) > 0
						If !aCCImp[nPosAux,6]
							FT_FSKIP()
							Loop
						EndIf						
					EndIf
				EndIf
				
				If fChkCpo('CTT',aLinha[6],xFilial("CTT",SRA->RA_FILIAL),'CTT_CUSTO',cCCDest)//Tabela,Empresa,Filial,Campo,Chave
					aAdd(aCCImp, {aLinha[6],xFilial("CTT",SRA->RA_FILIAL),cCCDest,aLinha[1],"D",.T.})
				Else
					aAdd(aCCImp, {aLinha[6],xFilial("CTT",SRA->RA_FILIAL),cCCDest,aLinha[1],"D",.F.})
					FT_FSKIP()
					Loop
				EndIf				
			EndIf
			
			If !Empty(cDeptoDest)
				If !SQB->(DbSeek(xFilial("SQB",SRA->RA_FILIAL)+cDeptoDest))
					If !Empty(aDeptoImp)
						If aScan(aDeptoImp,  { |x|  X[1]+X[2]+X[3]+X[4] == aLinha[6] + xFilial("SQB",sra->ra_filial) + cDeptoDest + cDataTrans }) == 0
							aAdd(aDeptoImp, {aLinha[6],xFilial("SQB",sra->ra_filial),cDeptoDest,cDataTrans,"D",.F.})
						EndIf
					Else
						aAdd(aDeptoImp,{aLinha[6],xFilial("SQB",sra->ra_filial),cDeptoDest,cDataTrans,"D",.F.})
					EndIf
					FT_FSKIP()
					Loop
				EndIf
			EndIf
			
			If !CTT->(DbSeek(xFilial("CTT",SRA->RA_FILIAL)+cCCDest))
				If !Empty(aCCImp)
					If aScan(aCCImp,  { |x|  X[1]+X[2]+X[3]+x[4] == aLinha[6] + aLinha[7] + cCCDest + cDataTrans}) == 0
						aAdd(aCCImp, {aLinha[6],substr(aLinha[7],1,nTamFilial),cCCDest,cDataTrans,"D",.F.})
					EndIf
				Else
					aAdd(aCCImp,{aLinha[6],substr(aLinha[7],1,nTamFilial),cCCDest,cDataTrans,"D",.F.})
				EndIf
				FT_FSKIP()
				Loop
			EndIf
						
			Begin Transaction
				RecLock('SRE',.T.)
				SRE->RE_FILIAL	:= xFilial('SRE')
				SRE->RE_DATA		:= CtoD(aLinha[1])
				SRE->RE_EMPD		:= aLinha[2]				
				SRE->RE_FILIALD	:= SubStr(PadR(aLinha[3],nTamFilial),1,nTamFilial)
				SRE->RE_MATD		:= aLinha[4]
				SRE->RE_CCD		:= aLinha[5]
				SRE->RE_EMPP		:= aLinha[6]				
				SRE->RE_FILIALP	:= SubStr(PadR(aLinha[7],nTamFilial),1,nTamFilial)
				SRE->RE_MATP		:= aLinha[8]
				SRE->RE_CCP		:= aLinha[9]
				SRE->RE_DEPTOD	:= aLinha[10]
				SRE->RE_DEPTOP	:= aLinha[11]
				SRE->RE_ITEMD		:= aLinha[12]
				SRE->RE_ITEMP		:= aLinha[13]
				SRE->(MSUnLock())
			End Transaction						
		Else
			U_IncRuler(OemToAnsi(STR0001),aLinha[4],cStart,.T.,,oSelf)
		EndIf		
		FT_FSKIP()		
	EndDo
	FT_FUSE()
	
	if(Len(aFuncOri) > 0)		
		aSort(aFuncOri ,,, { |x,y| x[1]+x[2]+X[3] < y[1]+Y[2]+Y[3] })
		aEval(aFuncOri,{|x|aAdd(aErro,'['+x[1]+'/'+x[2]+'/'+x[3]+']' + StrTran(OemToAnsi(STR0004),'@1',OemToAnsi(STR0002)) +  OemToAnsi(STR0006))})
	endIf
	if(Len(aFuncDest) > 0)		
		aSort( aFuncDest ,,, { |x,y| x[1]+x[2]+X[3]+X[4] < y[1]+Y[2]+Y[3]+Y[4] } )
		aEval(aFuncDest,{|x|aAdd(aErro,'['+x[1]+'/'+x[2]+'/'+x[3]+']' + StrTran(OemToAnsi(STR0004),'@1',OemToAnsi(STR0003)) +  OemToAnsi(STR0006))})
	endIf

	if(Len(aCCImp) > 0)
		aSort(aCCImp ,,, { |x,y| x[1]+x[2]+X[3]+X[4] < y[1]+Y[2]+Y[3]+Y[4] } )
		
		aEvaL(aCCImp,{|x|aAdd(aErro,'['+x[1]+'/'+x[2]+'/'+x[3]+']' + ;
		StrTran(OemToAnsi(STR0005),'@1',IIF(x[5]=='O',OemToAnsi(STR0002),OemToAnsi(STR0003))) +  OemToAnsi(STR0006))})		
	endIf	
	
	if(Len(aDEPTOImp) > 0)
		aSort( aDeptoImp ,,, { |x,y| x[1]+x[2]+X[3]+X[4] < y[1]+Y[2]+Y[3]+Y[4] } )
		
		aEvaL(aDEPTOImp,{|x|aAdd(aErro,'['+x[1]+'/'+x[2]+'/'+x[3]+']' + ;
		StrTran(OemToAnsi(STR0007),'@1',IIF(x[5]=='O',OemToAnsi(STR0002),OemToAnsi(STR0003))) +  OemToAnsi(STR0006))})		
	endIf
	
	if(Len(aItemImp) > 0 )
		aSort( aItemImp ,,, { |x,y| x[1]+x[2]+X[3]+X[4] < y[1]+Y[2]+Y[3]+Y[4] } )
		aEvaL(aItemImp,{|x|aAdd(aErro,'['+x[1]+'/'+x[2]+'/'+x[3]+']' + ;
		StrTran(OemToAnsi(STR0008),'@1',IIF(x[5]=='O',OemToAnsi(STR0002),OemToAnsi(STR0003))) +  OemToAnsi(STR0006))})
	endIf
	
	U_RIM01ERR(aErro)
	
	aSize(aErro,0)
	aErro := Nil
	aSize(aItemImp,0)
	aItemImp := Nil
	aSize(aDEPTOImp,0)
	aDEPTOImp := Nil
	aSize(aCCImp,0)
	aCCImp := Nil
	aSize(aFuncDest,0)
	aFuncDest := Nil
	aSize(aFuncOri,0)
	aFuncOri := Nil	
	aSize(aTabelas,0)
	aTabelas := Nil
	aEval(aAreas,{|x|RestArea(x)})
Return (.T.)

/*/{Protheus.doc} fChkCpo
	Procura dados em outra empresa.
@author Leandro Drumond
@since 03/11/12
@version P11
@param cAlias, character, (Descrição do parâmetro)
@param cEmpresaArq, character, (Descrição do parâmetro)
@param cFilialArq, character, (Descrição do parâmetro)
@param cCampo, character, (Descrição do parâmetro)
@param cChave, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function fChkCpo(cAlias,cEmpresaArq,cFilialArq,cCampo,cChave)//Tabela,Empresa,Filial,Campo,Chave
	Local cAliasAux := "QTABAUX"
	Local cTabAux   := "%" + cAlias + cEmpresaArq + "0" + "%"
	Local lRet	    := .F.
	 
	cCampo 	:= "%" + cCampo + "%"
	
	BeginSql alias cAliasAux
		SELECT COUNT(%exp:cCampo%) AS TOTALREG
		FROM %exp:cTabAux%
		WHERE  %exp:cCampo% = %exp:cChave%
	EndSql
	
	If (cAliasAux)->TOTALREG > 0
		lRet := .T.
	EndIf
	
	(cAliasAux)->(DbCloseArea())
	
Return lRet

/*/{Protheus.doc} fDelSRE
Exclui dados da SRE
@author Leandro Drumond
@since 03/11/12
@version P11
@return Nil, Valor Nulo
/*/
Static Function fDelSRE()	
	Local cQuery := ''
	Local cAlias := 'SRE'
	
	cQuery := " DELETE FROM " + InitSqlName(cAlias) + " "
	
	TcSqlExec( cQuery )
	
	TcRefresh( InitSqlName(cAlias) )
	
Return Nil
