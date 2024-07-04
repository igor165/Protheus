#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "MSOLE.CH" 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GCPR008  ºAutor  ³ Totvs              º Data ³  20/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio Ata de Sistema de Registro de Preço              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GCPR008(cNumPro,cCodEdt)
Local aDados:= {}
Local aRet	:= {}
Local lRet	:= .T.
//-- Integracao Word
Local cArquivo	:= "GCP_ATAREGISTROPRECO"
Local cArqDest	:= "GCP_ATAREGPRE"
Local cArqDot	:= cArquivo+".DOT"     // Nome do Arquivo MODELO do Word
Local cPathDot	:= AllTrim(GETMV("MV_GCPDOT",,"\samples\documents\gcp\dot\")) // PATH DO ARQUIVO MODELO WORD
//NO SERVIDOR ; CONFIGURAR PATH ABAIXO DO ROOTPATH PROTHEUS E INFORMAR NO PARAMETRO
Local cPathDoc	:= AllTrim(GETMV("MV_GCPDOC",,"\samples\documents\gcp\doc\")) + AllTrim(cCodEdt)+"\" // PATH PARA GRAVACAO DOS ARQUIVO WORD GERADOS
Local cAliasCO2	:= ""
Local nCntFor	:= 0

Local cOrgLic	:= Space(30)
Local cSede		:= Space(30)
Local cCargo	:= Space(30)
Local cNomHom	:= Space(30)
Local cObjeto	:= Space(30)
Local aSldItem  := {}
Local nQtde		:= 0 

Private oWord
Private nCntLin := 0 ; nCntCol := 0
Private cPathEst:= Alltrim(GetNewPar("MV_GCPDEST","C:\WORDTMP\")) + AllTrim(cCodEdt)+"\" // PATH DO ARQUIVO A SER ARMAZENADO NA

Default cNumPro := CriaVar("CO1_NUMPRO",.T.)
Default cCodEdt	:= CriaVar("CO1_CODEDT",.T.)

If	Empty(cNumPro)
	lRet := ParamBox({{1,"Processo",cNumPro,"@!","","","",60,.T.},;
					  {1,"Edital"  ,cCodEdt,"@!","","","",60,.T.}},'Informe o no.Edital',aRet)
	If	lRet
		cNumPro := aRet[1]
		cCodEdt := aRet[2]
		CO1->(DbSetOrder(1))
		If	CO1->( ! DbSeek(xFilial("CO1")+cCodEdt+cNumPro) )

			lRet := .F.
		EndIf
	EndIf
	aRet := {}

EndIf

If	Empty(cOrgLic)
	lRet := ParamBox({{1,"Nome Orgão Licitante",cOrgLic,"@!","","","",60,.T.},;
					  {1,"Sede Orgão Licitante",cSede  ,"@!","","","",60,.T.},;
					  {1,"Autoridade"          ,cCargo ,"@!","","","",60,.T.},;
					  {1,"Ata Homologada por"  ,cNomHom,"@!","","","",60,.T.},;
					  {1,"Objeto"              ,cObjeto,"@!","","","",60,.T.}},"cabec ata",aRet)
	If	lRet
		cOrgLic := aRet[1]
		cSede	:= aRet[2]
		cCargo	:= aRet[3]
		cNomHom	:= aRet[4]
		cObjeto	:= aRet[5]
	EndIf
	aRet := {}
	
EndIf


If	lRet .And. !(CO1->CO1_SRP=="S" .Or. CO1->CO1_SRP=="1")
	Help("",1,"GCPR008",,"O Edital no. "+cCodEdt+" não pertence ao Sistema de Registro de Preços!",4,1)
	lRet := .F.
EndIf
//-- Se etapa igual a SR o registro de preco expirou
If	lRet .And. CO1->CO1_ETAPA=="AP" //"SR"
	Help("",1,"GCPR008",,"Registro de Preço expirou",4,1)
	lRet := .F.
EndIf

If	lRet

	If Empty(cArquivo)
		Return("")
	Endif
	oWord := OLE_CreateLink()
	
	If Empty(cPathEst)
		cPathEst := "C:\WORDTMP\" + AllTrim(cCodEdt)+"\"
	EndIf
		
	MontaDir(cPathEst)
	
	If !File(cPathDot + cArqDot) // Verifica a existencia do DOT no ROOTPATH Protheus / Servidor 
		cMsg := "Atencao... " + cPathDot + cArqDot + " nao encontrado no Servidor" 
		Help("",1,"GCPARQ","",cMsg,1,0)
		Return("")
	EndIf
	
	// Caso encontre arquivo ja gerado na estacao
	//com o mesmo nome apaga primeiramente antes de gerar a nova impressao
	If File( cPathEst + cArqDot )
		Ferase( cPathEst + cArqDot )
	EndIf
	
	CopiaArq(cPathDot,cPathEst,cArqDot)
	//CpyS2T(cPathDot,cPathEst,.T.) // Copia do Server para o Remote, eh necessario
	//para que o wordview e o proprio word possam preparar o arquivo para impressao e
	// ou visualizacao .... copia o DOT que esta no ROOTPATH Protheus para o PATH da
	// estacao , por exemplo C:\WORDTMP
	
	//Cria novo arquivo no Word na estacao
	OLE_NewFile( oWord, cPathEst + cArqDot)
	
	//Salva o arquivo com o novo nome na estacao
	OLE_SaveAsFile( oWord, cPathEst + cArqDest+".DOT", , , .F., oleWdFormatDocument )


	//-- Posiciona CO3
	GCPChkCO3("1",cCodEdt,cNumPro)

	//-- Obtem informacoes
	GCPChkCO3("2",cCodEdt,cNumPro,,CO1->CO1_MODALI,aRet)
	
	// Preenche Variaveis do .DOT
	// Verificar nomes de variaveis no .DOT via Word ... atraves da tecla ALT+F9
	OLE_SetDocumentVar(oWord, "cDesMod", Upper(Tabela("LF",CO1->CO1_MODALID,.F.)))
	OLE_SetDocumentVar(oWord, "cDesTip", Upper(Tabela("LG",CO1->CO1_TIPO,.F.)))
	OLE_SetDocumentVar(oWord, "cCodEdt", cCodEdt)
	OLE_SetDocumentVar(oWord, "cNumPro", cNumPro)
	OLE_SetDocumentVar(oWord, "nQtdSRP", Str(CO1->CO1_QTDSRP,3))
	//-- nro da ata
	OLE_SetDocumentVar(oWord, "cDiaExt"	, Extenso(Day(dDataBase),.T.,,,,.F.,.F.) )
	OLE_SetDocumentVar(oWord, "cMesExt"	, MesExtenso(Month(dDataBase)) )
	OLE_SetDocumentVar(oWord, "cAno"	, Year(dDataBase) )

	OLE_SetDocumentVar(oWord, "cOrgLic"	, AllTrim(cOrgLic)	)
	OLE_SetDocumentVar(oWord, "cSede"	, AllTrim(cSede)	)
	OLE_SetDocumentVar(oWord, "cCargo"	, AllTrim(cCargo)	)
	OLE_SetDocumentVar(oWord, "cNomHom"	, Alltrim(cNomHom)	)
	OLE_SetDocumentVar(oWord, "dDtSRP"	, dDataBase	)
	OLE_SetDocumentVar(oWord, "cObjeto"	, AllTrim(cObjeto)	)


	OLE_SetDocumentVar(oWord, "cNome"	, AllTrim(aRet[1]) )
	OLE_SetDocumentVar(oWord, "cCgc"	, AllTrim(aRet[2]) )
	OLE_SetDocumentVar(oWord, "cEnd"	, AllTrim(aRet[3]) )
	OLE_SetDocumentVar(oWord, "cNr_End"	, AllTrim(aRet[4]) )
	OLE_SetDocumentVar(oWord, "cBairro"	, AllTrim(aRet[5]) )
	OLE_SetDocumentVar(oWord, "cMun"	, AllTrim(aRet[6]) )
	OLE_SetDocumentVar(oWord, "cEst"	, AllTrim(aRet[7]) )
	OLE_SetDocumentVar(oWord, "cCep"	, AllTrim(aRet[8]) )
	OLE_SetDocumentVar(oWord, "cDDD"	, AllTrim(aRet[9]) )
	OLE_SetDocumentVar(oWord, "cTel"	, AllTrim(aRet[10]) )
	OLE_SetDocumentVar(oWord, "cEmail"	, AllTrim(aRet[11]) )
	
	
	
	//-- Monta os itens
	cAliasCO2 := GetNextAlias()
	
	BeginSQL Alias cAliasCO2
	
	SELECT CO2.R_E_C_N_O_ RecCO2
		
	FROM %table:CO2% CO2
		
	WHERE CO2.CO2_FILIAL = %xfilial:CO2%
		AND CO2.CO2_CODEDT = %exp:cCodEdt%
		AND CO2.CO2_NUMPRO = %exp:cNumPro%
		AND CO2.%NotDel%
	ORDER BY %Order:CO2%
			
	EndSql
	
	While (cAliasCO2)->(!Eof())
		CO2->(DbGoTo((cAliasCO2)->RecCO2))
		aRet := {}
		GCPValDesc(aRet)
		nQtde := CO2->CO2_QUANT
		aSldItem := {cCodEdt,cNumPro,CO2->CO2_CODPRO}
		GCPSldItem("3",aSldItem)
		//-- Se nao efetuou a entrega total, abate a quantidade ja entregue (CO2_QUANT - C7_QUJE)
		//-- Se efetuou a entrega total devera permanecer com a quantidade original CO2_QUANT
		If	aSldItem[1]<nQtde
			nQtde -= aSldItem[1]
		EndIf		
		
		AAdd(aDados,{CO2->CO2_ITEM,aRet[2],aRet[1],nQtde,CO2->CO2_VLESTI,nQtde*CO2->CO2_VLESTI,Iif(CO1->CO1_AVAL=="2",CO2->CO2_LOTE,"")})

		(cAliasCO2)->(DbSkip())
	EndDo
		
	(cAliasCO2)->(DbCloseArea())

	OLE_SetDocumentVar(oWord, "nTotItens", Str(Len(aDados)) )

	//-- Montagem das variaveis dos itens
	For nCntFor := 1 To Len(aDados)
	
		OLE_SetDocumentVar(oWord,"nItem"+AllTrim(Str(nCntFor)),aDados[nCntFor,1])
		OLE_SetDocumentVar(oWord,"cProduto"+AllTrim(Str(nCntFor)),aDados[nCntFor,2])
		OLE_SetDocumentVar(oWord,"cUM"+AllTrim(Str(nCntFor)),aDados[nCntFor,3])
		OLE_SetDocumentVar(oWord,"nQuant"+AllTrim(Str(nCntFor)),aDados[nCntFor,4])
		OLE_SetDocumentVar(oWord,"nVlrUni"+AllTrim(Str(nCntFor)),aDados[nCntFor,5])
		OLE_SetDocumentVar(oWord,"nVlrTot"+AllTrim(Str(nCntFor)),aDados[nCntFor,4]*aDados[nCntFor,5])
		OLE_SetDocumentVar(oWord,"cLote"+AllTrim(Str(nCntFor))	,aDados[nCntFor,7] )

	Next
	
	//-- Executa a macro de grid
	OLE_ExecuteMacro(oWord,"tabitens")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizando as variaveis do documento do Word                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	OLE_UpdateFields(oWord)
	OLE_SaveAsFile( oWord, cPathEst + cArqDest+".DOC", , , .F., oleWdFormatDocument )
	
	//-- Grava a Data da Emissao da Ata de Registro de Precos
	If !Empty(CO1->CO1_DTSRPA) .Or. (CO1->CO1_DTSRPA > CO1->CO1_DTSRP)
		RecLock("CO1",.F.)
		CO1->CO1_DTSRPA := dDataBase
		MsUnLock()
	Else
		RecLock("CO1",.F.)
		CO1->CO1_DTSRP := dDataBase
		MsUnLock()	
	EndIf
	
	// Alterado o MsgYesNo para Aviso, retirando a pergunta Sim ou Nao
	While .T.
		Aviso("Emissao Ata de SRP","Deseja fechar o documento ?",{"Sim"}) 
			OLE_CloseFile(oWord)	
			OLE_CloseLink(oWord)
			Exit
	EndDo
	
	If File(cPathEst + cArqDest+".DOT")
		FErase(cPathEst + cArqDest+".DOT")
	EndIf
	
	//Caso nao exista, cria o diretorio no servidor
	MontaDir(cPathDoc)
	
	// Caso encontre arquivo ja gerado no Servidor
	//com o mesmo nome apaga primeiramente antes de gerar a nova impressao
	If File( cPathDoc + cArqDest+".DOC" )
		Ferase( cPathDoc + cArqDest+".DOC" )
	EndIf
	
	//COPIA O ARQUIVO GERADO NO SERVIDOR
	CopiaArq(cPathEst,cPathDoc,cArqDest+".DOC")
	
EndIf


Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CopiaArq ºAutor  ³ Totvs              º Data ³  01/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a copia de arquivo do servidor para o remote       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CopiaArq(cAtuDir,cNomeDir,cArquivo)

cNomeDir := Alltrim(cNomeDir)
__COPYFILE(cAtuDir+cArquivo,cNomeDir+cArquivo)
	

Return .T.



Static Function GCPValDesc(aRet)

SB1->(DbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+CO2->CO2_CODPRO))
aRet := {SB1->B1_UM,SB1->B1_DESC}

If	SB5->(MsSeek(xFilial("SB5")+CO2->CO2_CODPRO))
	aRet[2]:=SB5->B5_CEME
EndIf

Return NIL


