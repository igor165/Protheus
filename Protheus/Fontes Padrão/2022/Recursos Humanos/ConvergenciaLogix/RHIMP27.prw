#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RHIMP27.CH"

/**********************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP27.PRW  Autor: PHILIPE.POMPEU  Data:20/01/2016 			   ***
***********************************************************************************
***Descrição..:	Importa o arquivo de Histórico de Plano de Saude          	   ***
***********************************************************************************
***Uso........:        																   ***
***********************************************************************************
***Parâmetros.:		${param}, ${param_type}, ${param_descr}					   ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                           	   ***
***********************************************************************************
***					Alterações feitas desde a construção inicial               	   ***
***********************************************************************************
***Chamado....:                                                                 ***
**********************************************************************************/
/*/{Protheus.doc} RHIMP27
	Função responsável pela importação do arquivo de Historico de Plano de Saude;
@author PHILIPE.POMPEU
@since 20/01/2016
@version P11
@param cDiretorio, caractere, arquivo para ser importado(caminho completo, ex: "C:\logix\arquivo.unl")
@return nil, Nulo
/*/
User Function RHIMP27(cArquivo)	
	Local aLinha 		:= {}
	Local aDePara		:= {}
	Local aFunc		:= {}		
	Local cBuffer 	:= ""
	Local cEmpresa 	:= ""
	Local cFil 		:= ""
	Local cChave		:= ""	
	Local cCgcForn	:= ""	
	Local lProcede 	:= .F.
	Local lInvalido	:= .F.
	Local lNew 		:= .T.
	Local lAssMed 	:= .T.
	Local lDependente	:= .F.		
	Local nNumLinha 	:= 0
	Local cCompPla	:= ''
	Local cArqDePara	:= ''
	Local xTotal := 0	
	Local cDiretorio:= ''
	Local cAliasPL	:= ''
	Local nTamCodigo	:= TamSX3('RHS_CODIGO')[1]
	Local nSeqDep		:= 0
	Private cNumLinha 	:= ""
	Private aErros 		:= {}
		
	cDiretorio := SubStr(cArquivo,1,RAt(IIF(IsSrvUnix(), "/", "\" ),cArquivo))
			
	cArqDePara := cDiretorio
	cArqDePara += 'vdp_dpara_geral.unl' 
	if!(File(cArqDePara))		
		/*Arquivo necessário para o processamento não encontrado*/
		U_RIM01ERR(OemToAnsi(STR0001) + '[' + cArqDePara + ']')
		Return
	else
		aDePara := CarDePara(cArqDePara)
		FT_FUSE(cArquivo)
		xTotal := FT_FLASTREC()
		ProcRegua(xTotal)
		xTotal := cValToChar(xTotal)
		FT_FGOTOP()	
	endIf
		
	SRA->(DbSetOrder(1))
	RHS->(DbSetOrder(1))
	RHK->(DbSetOrder(1))
	RHL->(DbSetOrder(1))
	
	lInvalido:= .F.
	
	While !FT_FEOF()
		nNumLinha++
		cNumLinha := cValToChar(nNumLinha)		
		
		IncProc(OemToAnsi(STR0002) +"["+ cNumLinha + "/" + xTotal +"]...")/*Processando linha*/

		cBuffer 	:= FT_FREADLN()
		aLinha 	:= Separa(cBuffer,'|')/*Tamanho 13*/			
		aFunc 		:= findFunc(aLinha[1],StrTran(aLinha[2],'.'),aDePara)
		
		If Empty(aFunc)/*Se não encontrar no De/Para procurar no Protheus*/
			aAdd(aFunc,cEmpAnt)
			aAdd(aFunc,cFilAnt)
			aAdd(aFunc,StrTran(aLinha[2],'.'))
		EndIf
		
		cEmpresa 	:= aFunc[1]
		cFil 		:= aFunc[2]		
					
		U_RHPREARE(cEmpresa,cFil,'','',.F.,@lProcede,"RHIMP27",{'RCC','RHL','RHK'},"GPE",@aErros,OemToAnsi(STR0008))			
		
		if(cCompPla != xFilial("RHS"))					
			DelPLA()
			cCompPla := xFilial("RHS")		
		endIf
		
					
		If(lProcede)			
			nSeqDep := Val(aLinha[11])
			lDependente := (nSeqDep != 0)			
			
			If cCgcForn != aLinha[9]
				lInvalido := .F.
				cCgcForn := aLinha[9]
								
				cCodFor := FornByCgc(cCgcForn, @lAssMed) 
				
				if(Empty(cCodFor))				
					/*Nenhum fornecedor encontrado com o CNPJ:*/
					AddErroMsg(OemToAnsi(STR0003) + '[' + cCgcForn + ']')
					lInvalido := .T.
				endIf
			EndIf
						
			cAliasPL := IIF(lDependente,"RHL","RHK")			
			cChave := xFilial(cAliasPL) + aFunc[3]
			If !((cAliasPL)->(DbSeek(cChave)))
				/*Plano Ativo do dependente não encontrado*/
				AddErroMsg(OemToAnsi(IIF(lDependente,STR0005,STR0004)) + '[' + xFilial(cAliasPL) + '/' + aFunc[3] +']')
				lInvalido := .T.
			EndIf
			
			if(Empty(aFunc[3]) .Or. !SRA->(dbSeek(xFilial("SRA") + aFunc[3])))				
				AddErroMsg(OemToAnsi(STR0006) + '[' + xFilial("SRA") + '/' + aFunc[3] +']')				
				lInvalido := .T.
			endIf
			
			If !lInvalido
				/*RHS_FILIAL+RHS_MAT+RHS_COMPPG+RHS_ORIGEM+RHS_CODIGO+RHS_TPLAN+RHS_TPFORN+RHS_CODFOR+RHS_TPPLAN+RHS_PLANO+RHS_PD*/			
				cChave := xFilial("RHS") + aFunc[3] + AnoMes(ConvDtLg(aLinha[3])) //FILIAL+ MAT + COMPPG			
				cChave += IIF(lDependente,"2","1")/*ORIGEM*/			
				cChave += IIF(lDependente,StrZero(nSeqDep,nTamCodigo),Space(nTamCodigo))/*CODIGO*/		 
				cChave += aLinha[5]/*TPLAN*/
				cChave += IIF(lAssMed,"1","2") + cCodFor/*TPFORN + RHS_CODFOR*/				
				
				lNew := !RHS->(DbSeek(cChave))
			
				Begin Sequence
					RecLock("RHS",lNew)					
					
					RHS->RHS_FILIAL	:= xFilial("RHS")				
					RHS->RHS_MAT		:= aFunc[3]
					RHS->RHS_DATA		:= ConvDtLg(aLinha[3])
					RHS->RHS_ORIGEM	:= If(lDependente,"2","1")
					RHS->RHS_CODIGO	:= IIF(lDependente,StrZero(nSeqDep,nTamCodigo),Space(nTamCodigo))/*CODIGO*/
					RHS->RHS_TPLAN	:= aLinha[5]
					RHS->RHS_TPFORN	:= If(lAssMed,"1","2")
					RHS->RHS_CODFOR	:= cCodFor
					RHS->RHS_TPPLAN	:= If(lDependente,RHL->RHL_TPPLAN,RHK->RHK_TPPLAN)
					RHS->RHS_PLANO	:= If(lDependente,RHL->RHL_PLANO,RHK->RHK_PLANO)
					RHS->RHS_PD		:= aLinha[8]
					RHS->RHS_VLRFUN	:= Val(aLinha[14])
					RHS->RHS_VLREMP	:= 0
					RHS->RHS_COMPPG	:= AnoMes(RHS->RHS_DATA)				
					RHS->RHS_DATPGT	:= ConvDtLg(aLinha[4])
					RHS->RHS_TIPO		:= ""
									
					RHS->(MsUnlock())					
				End Sequence
				
			EndIf
					
		EndIf
		
		FT_FSKIP()			
	EndDo
	FT_FUSE()/*Libera o Arquivo.*/
	
	U_RIM01ERR(aErros)
Return

/*/{Protheus.doc} ConvDtLg
	Converte uma data do formato Logix p/ um valor data válido.
@author PHILIPE.POMPEU
@since 03/11/2016
@version P12.1.07
@param cData, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function ConvDtLg(cData)
	Local dDate
	Local cTemp :=""
	
	cTemp := SubStr(cData,1,10)
	cTemp := StrTran(cTemp,'-')
	dDate := StoD(cTemp)
Return dDate

/*/{Protheus.doc} CarDePara
	Carrega um vetor de De/Para baseado num arquivo.
@author philipe.pompeu
@since 03/11/2016
@version P12.1.07
@param cFile, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function CarDePara(cFile)
	Local cBuffer := ""
	Local aLinha 	:= {}	
	Local aPara	:= {}
	Local aDePara := {}
	
	if(File(cFile))
		FT_FUSE(cFile)	
		FT_FGOTOP()
		While !FT_FEOF()
			cBuffer 	:= FT_FREADLN()
			aLinha 	:= Separa(cBuffer,'|')
			
			aSize(aPara,0)
			aAdd(aPara,StrTran(aLinha[6],"\\",""))
			aAdd(aPara,StrTran(aLinha[7],"\\",""))
			aAdd(aPara,aLinha[8])
			
			aAdd(aDePara,{SubStr(aLinha[3],1,2),StrTran(aLinha[4],'.'),aClone(aPara)})
			FT_FSKIP()	
		EndDo	
	endIf
	
Return (aDePara)

/*/{Protheus.doc} FindFunc
	Retorna o funcionário Protheus encontrado com base na
	empresa e na matrícula do Logix
@author philipe.pompeu
@since 03/11/2016
@version 12.1.07
@param cEmp, character, (Descrição do parâmetro)
@param cMat, character, (Descrição do parâmetro)
@param aLook, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function FindFunc(cEmp,cMat,aLook)
	Local nIndex := 0
	
	nIndex := aScan(aLook,{|x|x[1]==cEmp .And. x[2] == cMat})
	If(nIndex > 0)
		Return aLook[nIndex,3]
	Else
		Return {}
	EndIf
	
Return nil

/*/{Protheus.doc} DelPLA
	Deleta logicamente os registros na tabela RHS.
@author PHILIPE.POMPEU
@since 03/11/2016
@version 12.1.07
@return ${return}, ${return_description}
/*/
Static Function DelPLA()
	Local aArea	:= GetArea()	
	Local cCommand := ''
	
	cCommand := " UPDATE " + InitSqlName("RHS") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
	cCommand += " WHERE RHS_FILIAL='"+ xFilial("RHS") + "'" 
	
	TcSqlExec(cCommand)
	TcRefresh(InitSqlName("RHS"))	
	RestArea(aArea)
Return nil


/*/{Protheus.doc} AddErroMsg
	Adiciona a mensagem contida em <cMensagem> no vetor <aMensagens>
	informando na frente da mensagem o numero da linha contida em <cLinha>
@author philipe.pompeu
@since 03/11/2016
@version P12.1.07
@param cMensagem, character, (Descrição do parâmetro)
@param aMensagens, array, (Descrição do parâmetro)
@param cLinha, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function AddErroMsg(cMensagem,aMensagens,cLinha)
	Default cMensagem := ''
	Default aMensagens := aErros
	Default cLinha := cNumLinha	
	
	if!(Empty(cMensagem))
		/*[Linha XX] Mensagem*/
		cMensagem := '['+ OemToAnsi(STR0007) +' '+ cLinha + ']' + cMensagem
		aAdd(aMensagens,cMensagem)
	endIf	
Return nil

/*/{Protheus.doc} FornByCgc
	Retorna o código de um fornecedor de plano de saude(S016) ou plano odontologico(S017);
@author philipe.pompeu
@since 03/11/2016
@version P12
@param cCgcForn, caractere, CNPJ do Fornecedor
@param lAssMed, logico, preenche com <.T.> caso seja fornecedor de ass. medica
@return cCodFor, código do fornecedor
/*/
Static Function FornByCgc(cCgcForn,lAssMed)
	Local nPosTab		:= 0
	Local cCodFor		:= ''
	Default lAssMed := .F.
	Default cCgcForn:= ''
	
	nPosTab := fPosTab( "S016",cCgcForn,"==",6)
	If nPosTab > 0
		cCodFor := fTabela("S016",nPosTab,4)
		lAssMed := .T.
	Else
		nPosTab := fPosTab( "S017",cCgcForn,"==",6)
		If nPosTab > 0
			cCodFor := fTabela("S017",nPosTab,4)
			lAssMed := .F.					
		EndIf
	EndIf	
Return cCodFor