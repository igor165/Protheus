#INCLUDE "CTBC620.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
Static __cTRBQuad := ""
/*/{Protheus.doc} CTBC620
Auditoria de lançamentos por conta contábil
Rotina de consulta de auditoria de lançamentos por conta contábil.
Para executar essa rotina é necessario o cadastro de configuração de auditoria ( Config Audit)
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programador  ³ Data   ³ BOPS     ³  Motivo da Alteracao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glez³06/12/16³SERINN001-³Se modifica uso de tablas temporales  ³±±
±±³             ³        ³      1103³por motivo de limpieza de CTREE.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
@author	Alvaro Camillo Neto
@since		29/10/13
@version	MP11.90
		
/*/
Function CTBC620()
Local aArea		:= {}
Local oBrowse
Local lRet		:= .T.
PRIVATE cCadastro :=  STR0001//"Auditoria de lançamentos por conta contábil"  

aArea := GetArea()

If lRet .And. FindFunction("FWHASMVC") .And. FWHASMVC() 
	If AliasInDic("CWA") .And. AliasInDic('CWB') .And. AliasInDic("CWC")
		dbSelectArea("CWA")
		dbSelectArea('CWB')
		dbSelectArea("CWC")
					
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('CWA')
		oBrowse:SetDescription(STR0001) //"Auditoria de lançamentos por conta contábil"
		oBrowse:Activate()
	Else
		Help(" ",1,"CTBA620TAB",,STR0002, 1, 0 ) //"Dicionário de dados e RPO desatualizados. Essa funcionalidade deve ser utilizada a partir da versão 11.90 ou superior."
	EndIf
Else
	Help(" ",1,"CTBA620MVC",,STR0003, 1, 0 ) //"Ambiente desatualizado, por favor atualizar com o ultimo pacote da lib "
Endif

RestArea(aArea)
Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} CTBC620CON
Rotina de wizard de consulta da auditoria da conta

@author	Alvaro Camillo Neto
@since		25/09/2013
@version	MP11.90
		
/*/
//-------------------------------------------------------------------
Function CTBC620CON(cAlias,nReg,nOpc)

Local lRet 			:= .T.
Local aParam1		:= {}
Local aConfig1		:= {}
Local aArea			:= GetArea()
Local nOpcA			:= 0
Local nX			:= 0
Local aSelFil		:= {}

Private aTitulos:= {}
Private oTitulo	:= NIL
Private oBrowse	:= NIL
Private oWizard   := NIL
Private aOrder    := {}
Private oTmpTable

__cTRBQuad := "TRBCTBC620"+ALLTRIM(__cUserID)

If !LockByName(__cTRBQuad ,.F.,.F.)
	Help(" ",1,"CTBA620USER",,STR0019, 1, 0 ) //"A rotina já está sendo utilizada pelo usuário em outra janela"
	lRet := .F.
EndIf


If lRet
	
	If nOpc==3
		//Etapa1 -Wizard de Consulta de Auditoria de Contas - Parametros da consulta.

		Aadd( aConfig1 , FirstDay(dDataBase))
		Aadd( aConfig1 , dDataBase)
		Aadd( aConfig1 , CWA->CWA_COD )
		Aadd( aConfig1 , 2)
		Aadd( aConfig1 , '1' )
		
		aAdd(aParam1,{1,STR0007		,aConfig1[1],"","","",,60,.T.}) 						//"Data Inicial"
		aAdd(aParam1,{1,STR0008		,aConfig1[2],"","","",,60,.T.}) 						//"Data Final"
		aAdd(aParam1,{1,STR0009	,aConfig1[3],"@!","ExistCpo('CWA')","CWA",,60,.T.}) 	//"Config Auditoria"
		aAdd(aParam1,{3,STR0010,aConfig1[4],{STR0085,STR0086},120,"",.T.}) 			//"Seleciona Filial"###"Sim"###"Não"
		aAdd(aParam1,{1,STR0020,aConfig1[5],"@!","ExistCpo('SX5','SL'+MV_PAR05)","SLD",,60,.T.})//"Tipo de saldo"						//"Data Final"
		
		//Etapa1
		oWizard := APWizard():New(STR0011/*<chTitle>*/, ; //"Início"
		STR0011, STR0001,; //"Início"##"Auditoria de lançamentos por conta contábil" 
		STR0018,; //"Essa rotina ira gerar uma consulta dos lançamentos contábeis e as suas origens baseadas nas configurações de auditoria"
		{|| .T.}/*<bNext>*/, ;
			{|| .T.} /*<bFinish>*/,;
		/*<.lPanel.>*/ , , , /*<.lNoFirst.>*/)
		
		//Etapa2
		oWizard:NewPanel( STR0001/*<chTitle>*/,;  //"Auditoria de lançamentos por conta contábil"
		STR0012/*<chMsg>*/, ;  //"Informe os parâmetros de inicialização da auditoria contábil"
		{||.T.}/*<bBack>*/, ;
		{||.T.}/*<bNext>*/, ;
		{|| nOpcA := 1, .T. }/*<bFinish>*/,;
		.T./*<.lPanel.>*/,;
		{|| CTC620Par(aParam1,@aConfig1,oWizard:oMPanel[oWizard:nPanel])}/*<bExecute>*/ ) //"Filtro"
		
		oWizard:Activate( .T./*<.lCenter.>*/,;
		{||.T.}/*<bValid>*/, ;
		{||.T.}/*<bInit>*/, ;
		{||.T.}/*<bWhen>*/ ) 
	Endif
	
	
	If nOpcA == 1
		aConfig1 := AjRetParam(aConfig1,aParam1)
	
		If aConfig1[4] == 1
			aSelFil := AdmGetFil(.F.,.T.,"CT2")
			If Empty(aSelFil)
				Help(" ",1,"CTC620FIL",,STR0017, 1, 0 ) //"Selecione a filial para consulta" 
				lRet := .F.
			EndIf
		Else
			aSelFil := {cFilAnt}
		EndIf
		
		If lRet
			MsgRun(STR0015,STR0016,{|| lRet := CT620Tela(aConfig1[1],aConfig1[2],aConfig1[3],aSelFil,aConfig1[5]) })//"Selecionando registros..."
		EndIf
	Endif
EndIf

RestArea(aArea)
	
UnLockByName( __cTRBQuad, .F., .F. )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CTC620Par
Parametrização da rotina

@author	Alvaro Camillo Neto
@since		29/10/2013
@version	MP11.90
		
/*/
//-------------------------------------------------------------------
Static Function CTC620Par(aParam,aRet,oPanel)
Local lRet := .T.

lRet := ParamBox(aParam ,STR0013,aRet,,,.F.,120,3, oPanel ) //Filtro

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AjRetParam
Ajusta as repostas do aParambox  

@author	Alvaro Camillo Neto
@since		29/10/2013
@version	MP11.90
		
/*/
//-------------------------------------------------------------------
Static Function AjRetParam(aRet,aParamBox)

Local nX	:= 1

IF ValType(aRet) == "A" .AND. Len(aRet) == Len(aParamBox)
	For nX := 1 to Len(aParamBox)
		If aParamBox[nX][1] == 1
			aRet[nX] := aRet[nX]
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "C"
			aRet[nX] := aScan(aParamBox[nX][4],{|x| Alltrim(x) == aRet[nX]})
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "N"
			aRet[nX] := aRet[nX]
		Endif
	Next nX
ENDIF

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CT620Tela
Rotina que prepara o arquivo temporario e monta a tela 

@author	Alvaro Camillo Neto
@since		29/10/2013
@version	MP11.90
		
/*/
//-------------------------------------------------------------------

Static Function CT620Tela(dDataIni,dDataFim,cCodAud,aSelFil,cTpSaldo)
Local lRet 		:= .T.
Local aArea 		:= GetArea()
Local cTitulo		:= STR0084//"Auditoria Contábil" 
Local cPrograma	:= 'CTBC620'
Local nOperation	:= MODEL_OPERATION_UPDATE

//Cria o TRB
CWA->(dbSetOrder(1))//CWA_FILIAL+CWA_COD  

If CWA->(dbSeek(xFilial("CWA") + cCodAud )) 
	lRet := C620SelDados(dDataIni,dDataFim,cCodAud,aSelFil,cTpSaldo)
	
	If lRet
		nOpc := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )
	EndIf
EndIf

(__cTRBQuad)->(dbCloseArea())

If oTmpTable <> Nil   //jgr
	oTmpTable:Delete()  //jgr
	oTmpTable := Nil //jgr
Endif //jgr

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C620CriaTRB
Cria o arquivo temporário

@author	Alvaro Camillo Neto
@since		29/10/2013
@version	MP11.90
		
/*/
//-------------------------------------------------------------------
Static Function C620CriaTRB()
Local aStruSQL		:= {}
Local cChave			:= ""

//Cria a tabela do Banco
aStruSQL := C620MDStr()

	//Creacion de la tabla
	aOrder	:=	{"DATAMOV","VALORMOV","CHAVEMOV"} //jgr
	oTmpTable := FWTemporaryTable():New(__cTRBQuad) //jgr
	oTmpTable:SetFields( aStruSQL ) //jgr
	oTmpTable:AddIndex("I01", aOrder) //jgr
	oTmpTable:Create() //jgr

dbSetOrder(1)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} C620SelDados
Monta a tabela temporaria para o processamento

@author	Alvaro Camillo Neto
@since		29/10/2013
@version	MP11.90
		
/*/
//-------------------------------------------------------------------
Static Function C620SelDados(dDataIni,dDataFim,cCodAud,aSelFil,cTpSaldo)
Local lRet 		:= .T.
Local aArea 		:= GetArea()
Local aSelConta	:= {}
Local aSelRelac	:= {}
Local aSelMov		:= {}
Local cConta		:= ""
Local nX			:= 0
Local nPos			:= 0

Local cEntConta 	:= "" 
Local cCpoConta 	:= ""
Local cOrdem		:= ""
Local cEntMov		:= ""
Local aChave		:= {}
Local cFiltro		:= ""
Local cValor		:= ""
Local cData			:= ""
Local cMoeda		:= ""
Local aChvConta		:= {}
Local aChvMOV 		:= {}
Local aSelDep		:= {}
Local aRet			:= {}
Local nCont		:= 0
Local aSelRef		:= {}
Local aSelRefRel	:= {}

C620CriaTRB()

aRet := CTC620Conf(cCodAud)

If !Empty(aRet)
	cConta		:= aRet[1]
	aSelConta	:= aRet[2]
	aSelRelac	:= aRet[3]
	aSelMov	:= aRet[4]
	cMoeda		:= aRet[5]
	aSelDep	:= aRet[6]
	aSelRef	:= aRet[7]
	aSelRefRel	:= aRet[8]
	
	For nX := 1 to Len(aSelMov)
		aChvConta	:= {}
		aChvMOV 	:= {}
		
		cEntConta := aSelConta[1][1] 
		cCpoConta := aSelConta[1][3]
		
		cOrdem		:= aSelMov[nX][1]
		cEntMov	:= aSelMov[nX][2]
		aChave		:= aSelMov[nX][3]
		cFiltro	:= aSelMov[nX][4]
		cValor		:= aSelMov[nX][5]
		cData		:= aSelMov[nX][6]
		
		nPos := aScan(aSelRelac,{|aItem| aItem[1] == cEntConta .And. aItem[3] == cEntMov  })
		
		If nPOS > 0
			aChvConta	:= aSelRelac[nPos][2]
			aChvMOV 	:= aSelRelac[nPos][4]
		EndIf
		
		C620OriTRB(cConta,cEntConta,cCpoConta,cOrdem,cEntMov,aChave,cFiltro,cValor,cData,aChvConta,aChvMOV,dDataIni,dDataFim,aSelFil,cCodAud,cMoeda,aSelRef,aSelRefRel)
	
	Next nX
	
	//Realiza a conciliação com o movimento contábil.
	C620CT2TRB(cConta,dDataIni,dDataFim,aSelFil,cMoeda,cTpSaldo,cCodAud)
	
	//Preenche o status dos demais registros do arquivo temporário
	C620UPDST()
	
	//Grava as dependencias entre os registros
	C620UPDDEP(aSelDep)
	
EndIf

nCont := C620RecCount()

If nCont <=0 .Or. nCont > 9990
	Help(" ",1,"C620REC",, STR0021,1,0)//"Seleção dos dados incorreta. Por favor verifique as configurações"
	lRet := .F. 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTC620Conf
Função que retorna as configurações da auditoria

@author alvaro.camillo

@since 30/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CTC620Conf(cCodAud)
Local aRet			:= {}
Local aArea		:= GetArea()
Local aSelConta	:= {}
Local aSelRelac	:= {}
Local aSelMov		:= {}
Local cConta		:= ""
Local aAux			:= {}
Local aAux2		:= {}
Local cMoeda		:= ""
Local aSelDep		:= {}
Local nPos			:= 0
Local aSelRef		:= {}
Local aSelRefRel	:= {}

CWA->(dbSetOrder(1))//CWA_FILIAL+CWA_COD  
CWB->(dbSetOrder(1))//CWB_FILIAL+CWB_CDAUDT+CWB_ITEM    
CWC->(dbSetOrder(1))//CWC_FILIAL+CWC_CDAUDT+CWC_ITEM

If CWA->(dbSeek( xFilial("CWA") + cCodAud ))
	cConta := CWA->CWA_CONTA
	cMoeda	:= CWA->CWA_MOEDA
	
	If CWB->(dbSeek( xFilial("CWB") + cCodAud ))
		While CWB->(!EOF()) .And. CWB->(CWB_FILIAL+CWB_CDAUDT) == xFilial("CWB") + cCodAud
			If CWB->CWB_TIPO == '1'
				aAux := CTC620Key(CWB->CWB_KEY)
				aAdd(aSelConta,{CWB->CWB_ENT,aClone(aAux),Alltrim(CWB->CWB_VALOR)})
			ElseIf  CWB->CWB_TIPO == '2'
				aAux := CTC620Key(CWB->CWB_KEY)
				aAdd(aSelMov,{CWB->CWB_ORDEM,CWB->CWB_ENT,aClone(aAux),Alltrim(CWB->CWB_FILTRO),Alltrim(CWB->CWB_VALOR),Alltrim(CWB->CWB_DATA)})
			ElseIf  CWB->CWB_TIPO == '3' 
				aAdd(aSelRef,{CWB->CWB_ENT,Alltrim(CWB->CWB_FILTRO)})
			EndIf
			
			CWB->(dbSkip())
		EndDo
	EndIf
	
	
	If CWC->(dbSeek( xFilial("CWC") + cCodAud ))
		CWB->(dbSetOrder(2))//CWB_FILIAL+CWB_CDAUDT+CWB_ENT

		While CWC->(!EOF()) .And. CWC->(CWC_FILIAL+CWC_CDAUDT) == xFilial("CWC") + cCodAud
			aAux := CTC620Key(CWC->CWC_KEYORI)
			aAux2 := CTC620Key(CWC->CWC_KEYDES)
			If CWB->(dbSeek( xFilial("CWB") + cCodAud + CWC->CWC_ENTORI))
				If CWB->CWB_TIPO == '1'
					aAdd(aSelRelac,{CWC->CWC_ENTORI,aClone(aAux),CWC->CWC_ENTDES,aClone(aAux2)})
				ElseIf CWB->CWB_TIPO == '3'
					aAdd(aSelRefRel,{CWC->CWC_ENTORI,aClone(aAux),CWC->CWC_ENTDES,aClone(aAux2)})
				Else
					aAdd(aSelDep,{CWC->CWC_ENTORI,aClone(aAux),CWC->CWC_ENTDES,aClone(aAux2)})
				EndIf 
			EndIf
			
			
			CWC->(dbSkip())
		EndDo
	EndIf
EndIf

If !Empty(aSelConta)  .And. !Empty(aSelMov)
	
	ASort(aSelMov,,,{|x,y| x[1] < y[1] })
	
	aAdd(aRet,cConta)
	aAdd(aRet,aClone(aSelConta))
	aAdd(aRet,aClone(aSelRelac))
	aAdd(aRet,aClone(aSelMov))
	aAdd(aRet,cMoeda)
	aAdd(aRet,aClone(aSelDep))
	aAdd(aRet,aClone(aSelRef))
	aAdd(aRet,aClone(aSelRefRel))
EndIf 

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C620OriTRB
Função que carrega a tabela temporaria com a configuracao contábil correspondente.

@author alvaro.camillo

@since 30/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function C620OriTRB(cConta,cEntConta,cCpoConta,cOrdem,cEntMov,aChave,cFiltro,cValor,cData,aChvConta,aChvMOV,dDataIni,dDataFim,aSelFil,cCodAud,cMoeda,aSelRef,aSelRefRel)
Local aArea 		:= GetArea()
Local cQuery		:= ""
Local cTabQry		:= "CTBC620QRY"
Local nX			:= 0
Local nY			:= 0
Local cCpoFilial	:= PrefixoCpo(cEntMov)+"_FILIAL"
Local cAux			:= ""
Local cTmpFil		:= ""
Local cEntRef		:= ""
Local nPos			:= 0
Local aChRef 		:= {}
Local aChRefMov 	:= {}

If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf
 
cQuery	+= " SELECT " + CRLF

For nX := 1 to Len(aChave)
	cQuery	+= aChave[nX] + ", " + CRLF
Next nX

cQuery	+= cCpoConta + ", " + CRLF
cQuery	+= cValor	 + ", " + CRLF

if !(cCpoFilial $ cQuery)
	cQuery	+= cCpoFilial	 + ", " + CRLF
endif

cQuery	+= cEntMov	 + ".R_E_C_N_O_ RECMOV , " + CRLF
cQuery	+= cData + CRLF

cQuery	+= " FROM " + CRLF

cQuery	+= " " + RetSQLName(cEntMov) + " " + cEntMov + " "  + CRLF

If cEntConta != cEntMov
	
	cQuery	+= " INNER JOIN " + RetSQLName(cEntConta) + " " + cEntConta + " ON " + CRLF
	
	cAux := " "
	
	For nX := 1 to Len(aChvConta)
		If nX <= Len(aChvMOV)
			cAux	+= " " + aChvMOV[nX] + " = " + aChvConta[nX] + " AND"
		EndIf	
	Next nX

	cQuery	+= cAux + " " + CRLF
	cQuery	+= cEntConta + ".D_E_L_E_T_ = ' ' " + CRLF

EndIf
//Referencia

For nX := 1 to Len(aSelRef)
	cEntRef 		:= aSelRef[nX][1]
	cFiltroRef		:= aSelRef[nX][2]
	nPos := aScan(aSelRefRel,{|aItem| aItem[1] == cEntRef .And. aItem[3] == cEntMov  })
	
	If nPos > 0
		aChRef 	:= aSelRefRel[nPos][2]
		aChRefMov 	:= aSelRefRel[nPos][4]
		
		cQuery	+= " INNER JOIN " + RetSQLName(cEntRef) + " " + cEntRef + " ON " + CRLF
		
		cAux := " "
		For nY := 1 to Len(aChRef)
			If nY <= Len(aChRefMov)
				cAux	+= " " + aChRefMov[nY] + " = " + aChRef[nY] + " AND"
			EndIf	
		Next nY

		cQuery	+= cAux + " " + CRLF
		cQuery	+= cEntRef + ".D_E_L_E_T_ = ' ' " + CRLF
		
		If !Empty(cFiltroRef)
			cQuery	+= " AND " + cFiltroRef + CRLF	
		EndIf
		
	EndIf

	
Next nX

cQuery	+= " WHERE " + CRLF

cQuery += cCpoFilial  + " " + GetRngFil( aSelFil , cEntMov , .T., @cTmpFil ) + " AND " + CRLF
cQuery	+= cData + " >= '"+DTOS(dDataIni)+"' AND " + CRLF
cQuery	+= cData + " <= '"+DTOS(dDataFim)+"' AND " + CRLF
cQuery	+= cCpoConta + " = '"+cConta+"' AND " + CRLF
cQuery	+= cEntMov + ".D_E_L_E_T_ = ' '  " + CRLF

If !Empty(cFiltro)
	cQuery	+= " AND " + cFiltro
EndIf

cQuery	+= " ORDER BY "

cAux := " "
For nX := 1 to Len(aChave)
	cAux	+= aChave[nX] + ","
Next nX

cAux := Left(cAux,Len(cAux)-1)

cQuery	+= cAux

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabQry,.T.,.T.)

TcSetField(cEntMov,cValor,"N",TamSX3(cValor)[1],TamSX3(cValor)[2])

While (cTabQry)->(!EOF())
	RecLock(__cTRBQuad,.T.)
	
	(__cTRBQuad)->FILIALMOV := (cTabQry)->&(cCpoFilial)
	(__cTRBQuad)->CODAUD 	:= cCodAud     
	(__cTRBQuad)->ENTMOV 	:= cEntMov    
	(__cTRBQuad)->ENTDESC 	:= C620X2Nome(cEntMov)
	
	cAux := ""
	
	For nX := 1 to Len(aChave)
		 	cAux += (cTabQry)->&(aChave[nX])
	Next nX	     
	
	(__cTRBQuad)->CHAVEMOV 	:= cAux     
	(__cTRBQuad)->DATAMOV 	:= STOD((cTabQry)->&(cData))     
	(__cTRBQuad)->VALORMOV 	:= (cTabQry)->&(cValor)
	(__cTRBQuad)->CONTA 	:= (cTabQry)->&(cCpoConta)
	(__cTRBQuad)->MOEDA 	:= cMoeda
	(__cTRBQuad)->RECMOV	:= (cTabQry)->RECMOV
	(__cTRBQuad)->ORDEM	:= cOrdem
	
	MsUnLock()
	
	RecLock(__cTRBQuad,.F.)
		(__cTRBQuad)->RECTRB	:= (__cTRBQuad)->(Recno())
	MsUnLock()	
	
	(cTabQry)->(dbSkip())
EndDo

If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf

CtbTmpErase(cTmpFil)

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C620UPDDEP
Função que preenche o relacionamento de dependencia entre os registros do temporário

@author alvaro.camillo

@since 30/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function C620UPDDEP(aSelDep)
Local aArea 		:= GetArea()
Local cQuery		:= ""
Local cTabQry		:= "CTCDEP01620"
Local nRecDep		:= 0

If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf

cQuery := " SELECT ENTMOV,RECMOV,RECTRB "
cQuery += " FROM " + oTmpTable:GetRealName()
cQuery += " WHERE " 
cQuery += " STATUS = '3'  " 
cQuery += " ORDER BY ORDEM DESC  " 

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabQry,.T.,.T.)

While (cTabQry)->(!EOF())
	nRecDep := GetRecDep(aSelDep,(cTabQry)->ENTMOV,(cTabQry)->RECMOV)
	
	If nRecDep > 0
		(__cTRBQuad)->(dbGoTo((cTabQry)->RECTRB))
		RecLock(__cTRBQuad,.F.)
			(__cTRBQuad)->RECDEP := nRecDep
		MsUnLock()
	EndIf
	(cTabQry)->(dbSkip())
EndDo

If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRecDep
Retorna o registro de relação do TRB

@author alvaro.camillo

@since 30/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetRecDep(aSelDep,cEntidade,nRecMov)
Local aArea 		:= GetArea()
Local cQuery		:= ""
Local cTabQry		:= "CTCDEP02620"
Local nX			:= 0
Local nY			:= 0
Local cAux			:= ""
Local nRecDep		:= 0
Local aDepChav		:= 0
Local aChaveOri		:= {}
Local aCpoOri		:= {}
Local cEntDes		:= ""
Local aCpoDes		:= {}

dbSelectArea(cEntidade)
For nX := 1 to Len(aSelDep)
	aCpoOri 		:= aSelDep[nX][2]
	aCpoDes 		:= aSelDep[nX][4]
	cEntDes 		:= aSelDep[nX][3]
	aChaveOri		:= {}
	If Alltrim(aSelDep[nX][1]) == Alltrim(cEntidade)
		(cEntidade)->(dbGoto(nRecMov))
		
		For nY := 1 to Len(aCpoOri)
			aAdd(aChaveOri, (cEntidade)->&(aCpoOri[nY]) )
		Next nY 
		
		cQuery	:= " SELECT RECTRB " + CRLF 
		cQuery	+= " FROM " + oTmpTable:GetRealName() + " " + __cTRBQuad +  CRLF
		cQuery	+= " INNER JOIN " + RetSQLName(cEntDes) + " " + cEntDes + " ON " + CRLF 
		cQuery	+= " " + cEntDes + ".R_E_C_N_O_ = RECMOV  AND " + CRLF 
		cQuery	+= " ENTMOV = '" + cEntDes + "'  AND " + CRLF 
		cQuery	+= " RECDEP = 0 " + CRLF 
		cQuery	+= " WHERE  " + CRLF 
		
		For nY := 1 to Len(aCpoDes)
			If  nY<= Len(aChaveOri)
				cQuery	+= " " + aCpoDes[nY] + " = '" + aChaveOri[nY] + "' AND " + CRLF 
			EndIf
		Next nY 
		
		cQuery	+= " " + cEntDes + ".D_E_L_E_T_ = ' '  AND " + CRLF 
		cQuery	+= " " + __cTRBQuad + ".D_E_L_E_T_ = ' ' " + CRLF 
		
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabQry,.T.,.T.)
		
		If (cTabQry)->(!EOF())
			nRecDep := (cTabQry)->RECTRB  
		EndIf
		
		If nRecDep > 0
			Exit
		EndIf
		
	EndIf
	
	If Select(cTabQry) > 0
		(cTabQry)->(dbCloseArea())
	EndIf
Next nX


If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf

RestArea(aArea)
Return nRecDep

//-------------------------------------------------------------------
/*/{Protheus.doc} C620UPDST
Função que preenche o status dos demais registros do arquivo temporário

@author alvaro.camillo

@since 30/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function C620UPDST()
Local aArea 		:= GetArea()
Local cQuery		:= ""
Local cStatus		:= ""

//Atualiza os registros originais que não possuem registro contábil
cStatus	:= "3"
cQuery 	:= "UPDATE " + oTmpTable:GetRealName()
cQuery 	+= "	SET STATUS = '"+cStatus+"' "
cQuery 	+= " WHERE STATUS = ' ' AND "
cQuery 	+= " RECMOV <> 0 AND "
cQuery 	+= " RECCT2 = 0 "

If TcSqlExec( cQuery ) <> 0 
	Help(" ",1,"C620NOTAB",, STR0022,1,0) //"Erro ao aplicar seleção!"
EndIf

//Atualiza os registros CTB que não possuem registro Original
cStatus	:= "4"
cQuery 	:= "UPDATE " + oTmpTable:GetRealName()
cQuery 	+= "	SET STATUS = '"+cStatus+"' "
cQuery 	+= " WHERE STATUS = ' ' AND "
cQuery 	+= " RECMOV = 0 AND "
cQuery 	+= " RECCT2 <> 0 "

If TcSqlExec( cQuery ) <> 0 
	Help(" ",1,"C620NOTAB",, STR0022,1,0) //"Erro ao aplicar seleção!"
EndIf


RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C620RecCount
Retorna a quantidade de registros

@author alvaro.camillo

@since 30/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function C620RecCount()
Local nCount := 0
Local aArea 		:= GetArea()
Local cQuery		:= ""
Local cTabQry		:= "C620CONQRY"

(__cTRBQuad)->(dbSetOrder(1)) //DTOS(DATAMOV)+STR(VALORMOV)+CHAVEMOV

If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf

// Procura conciliacao com a chave completa
cQuery	:= " SELECT " + CRLF
cQuery	+= " COUNT(R_E_C_N_O_) TRBCONT " + CRLF

cQuery	+= " FROM " + CRLF
cQuery	+= " " + oTmpTable:GetRealName() + " TRB "  + CRLF

cQuery	+= " WHERE " + CRLF

cQuery	+= " D_E_L_E_T_ = ' '  " + CRLF

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabQry,.T.,.T.)

If (cTabQry)->(!EOF())
	nCount := (cTabQry)->TRBCONT
EndIf


If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf

RestArea(aArea)

Return nCount

//-------------------------------------------------------------------
/*/{Protheus.doc} C620CT2TRB
Função que carrega a tabela temporaria com as informações de lançamento padrão.

@author alvaro.camillo

@since 30/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function C620CT2TRB(cConta,dDataIni,dDataFim,aSelFil,cMoeda,cTpSaldo,cCodAud)
Local aArea 		:= GetArea()
Local cQuery		:= ""
Local cTabQry		:= "C620CT2QRY"
Local cTmpFil		:= ""
Local cStatus		:= ""
Local cDc			:= ""

cQuery	+= " SELECT " + CRLF
cQuery	+= " CT2_FILIAL , " + CRLF  
cQuery	+= " CT2_DEBITO , " + CRLF  
cQuery	+= " CT2_CREDIT , " + CRLF  
cQuery	+= " CT2_SEQLAN , " + CRLF  
cQuery	+= " CT2_EMPORI , " + CRLF  
cQuery	+= " CT2_FILORI , " + CRLF  
cQuery	+= " CT2_MOEDLC , " + CRLF  
cQuery	+= " CT2_DATA , " + CRLF  
cQuery	+= " CT2_LOTE , " + CRLF 
cQuery	+= " CT2_SBLOTE , " + CRLF
cQuery	+= " CT2_DOC , " + CRLF
cQuery	+= " CT2_VALOR , " + CRLF
cQuery	+= " CT2_LINHA , " + CRLF
cQuery	+= " CT2_KEY , " + CRLF
cQuery	+= " CT2_CONFST , " + CRLF
cQuery	+= "CT2.R_E_C_N_O_ CT2REC " + CRLF

cQuery	+= " FROM " + CRLF
cQuery	+= " " + RetSQLName("CT2") + " CT2 "  + CRLF

cQuery	+= " WHERE " + CRLF

cQuery	+= " ( CT2_DEBITO = '"+cConta+"' OR CT2_CREDIT = '"+cConta+"' ) AND "
cQuery += " CT2_FILIAL " + GetRngFil( aSelFil , "CT2" , .T., @cTmpFil ) + " AND " + CRLF
cQuery	+= " CT2_DATA >= '"+DTOS(dDataIni)+"' AND " + CRLF
cQuery	+= " CT2_DATA <= '"+DTOS(dDataFim)+"' AND " + CRLF
cQuery	+= " CT2_MOEDLC  = '"+cMoeda+"' AND " + CRLF
cQuery	+= " CT2_TPSALD  = '"+cTpSaldo+"' AND " + CRLF
cQuery	+= " CT2.D_E_L_E_T_ = ' '  " + CRLF

cQuery	+= " ORDER BY "
cQuery	+= " CT2_FILIAL ,  " 
cQuery	+= " CT2_DATA , " + CRLF  
cQuery	+= " CT2_LOTE , " + CRLF 
cQuery	+= " CT2_SBLOTE , " + CRLF
cQuery	+= " CT2_DOC , " + CRLF
cQuery	+= " CT2_DC , " + CRLF
cQuery	+= " CT2_VALOR " + CRLF

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabQry,.T.,.T.)

TcSetField("CT2","CT2_VALOR","N",TamSX3("CT2_VALOR")[1],TamSX3("CT2_VALOR")[2])

While (cTabQry)->(!EOF())
	
	cStatus 	:= ""
	cDc			:= ""	
	nRecBusca := GetRecTrb((cTabQry)->CT2_DATA, (cTabQry)->CT2_VALOR , (cTabQry)->CT2_KEY, @cStatus )
	
	cHist		:= GetHist620( (cTabQry)->CT2_FILIAL ,(cTabQry)->CT2_DATA,(cTabQry)->CT2_LOTE,(cTabQry)->CT2_SBLOTE,(cTabQry)->CT2_DOC,(cTabQry)->CT2_SEQLAN,(cTabQry)->CT2_EMPORI,(cTabQry)->CT2_FILORI,(cTabQry)->CT2_MOEDLC )
	
	If Alltrim((cTabQry)->CT2_DEBITO) == Alltrim(cConta)
		cDc	:= STR0087 //"Débito"
	ElseIf Alltrim((cTabQry)->CT2_CREDIT) == Alltrim(cConta)
		cDc	:= STR0088//"Crédito"
	EndIf
	
	If Empty(nRecBusca) 
		RecLock(__cTRBQuad,.T.)
	Else
		(__cTRBQuad)->(dbGoTo(nRecBusca))
		RecLock(__cTRBQuad,.F.)
		(__cTRBQuad)->FILIALMOV 	:= (cTabQry)->CT2_FILIAL
	EndIf
			
	(__cTRBQuad)->DATACTB 	:= STOD((cTabQry)->CT2_DATA)
	(__cTRBQuad)->LOTE 		:= (cTabQry)->CT2_LOTE     
	(__cTRBQuad)->SBLOTE 	:= (cTabQry)->CT2_SBLOTE    
	(__cTRBQuad)->LINHA 		:= (cTabQry)->CT2_LINHA
	(__cTRBQuad)->DC 			:= cDc
	(__cTRBQuad)->DOC 		:= (cTabQry)->CT2_DOC
	(__cTRBQuad)->VALORCTB 	:= (cTabQry)->CT2_VALOR
	(__cTRBQuad)->HIST 		:= cHist
	(__cTRBQuad)->RECCT2 	:= (cTabQry)->CT2REC
	(__cTRBQuad)->CODAUD 	:= cCodAud
	(__cTRBQuad)->STATUS 	:= IIf(!Empty((cTabQry)->CT2_CONFST) ,'5' ,cStatus ) 
	MsUnLock()
	
	RecLock(__cTRBQuad,.F.)
		(__cTRBQuad)->RECTRB	:= (__cTRBQuad)->(Recno())
	MsUnLock()	
	
	(cTabQry)->(dbSkip())
EndDo

If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf

CtbTmpErase(cTmpFil)

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRecTrb
Retorna o recno do arquivo temporário para conciliação

@author alvaro.camillo

@since 30/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetRecTrb(cData, nValor , cKey, cStatus )
Local aArea 		:= GetArea()
Local nRec			:= 0
Local cQuery		:= ""
Local cTabQry		:= "C620RECQRY"
Local lAchou := .F.

(__cTRBQuad)->(dbSetOrder(1)) //DTOS(DATAMOV)+STR(VALORMOV)+CHAVEMOV

If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf

// Procura conciliacao com a chave completa
cQuery	:= " SELECT " + CRLF
cQuery	+= " R_E_C_N_O_ RECTRB " + CRLF

cQuery	+= " FROM " + CRLF
cQuery	+= " " + oTmpTable:GetRealName() + " TRB "  + CRLF

cQuery	+= " WHERE " + CRLF

cQuery	+= " DATAMOV = '"+cData+"' AND  " + CRLF
cQuery	+= " VALORMOV = "+STR(nValor)+" AND  " + CRLF
cQuery	+= " CHAVEMOV = '"+Alltrim(cKey)+"' AND  " + CRLF
cQuery	+= " STATUS = ' ' AND  " + CRLF
cQuery	+= " D_E_L_E_T_ = ' '  " + CRLF

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabQry,.T.,.T.)

If (cTabQry)->(!EOF())
	lAchou := .T.
	cStatus := "2"
	nRec := (cTabQry)->RECTRB
EndIf

If !lAchou 
	//Tenta a conciliação parcial
	If Select(cTabQry) > 0
		(cTabQry)->(dbCloseArea())
	EndIf

	cQuery	:= " SELECT " + CRLF
	cQuery	+= " R_E_C_N_O_ RECTRB " + CRLF
	
	cQuery	+= " FROM " + CRLF
	cQuery	+= " " + oTmpTable:GetRealName() + " TRB "  + CRLF
	
	cQuery	+= " WHERE " + CRLF
	
	cQuery	+= " DATAMOV = '"+cData+"' AND  " + CRLF
	cQuery	+= " VALORMOV = "+STR(nValor)+" AND  " + CRLF
	cQuery	+= " STATUS = ' ' AND  " + CRLF
	cQuery	+= " D_E_L_E_T_ = ' '  " + CRLF
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabQry,.T.,.T.)
	
	If (cTabQry)->(!EOF())
		lAchou := .T.
		nRec := (cTabQry)->RECTRB
		cStatus := "1"
	EndIf	
EndIf

If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf

RestArea(aArea)

Return nRec

//-------------------------------------------------------------------
/*/{Protheus.doc} GetHist620
Função que retorna o historico do lançamento.

@author alvaro.camillo

@since 30/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetHist620( cFilCT2 ,cData,cLote,cSubLote,cDoc,cSeqLan,cEmpOri,cFilOri,cMoeda )
Local aArea 		:= GetArea()
Local cHist		:= ""
Local cQuery		:= ""
Local cTabQry		:= "C620HISTQRY"

CT2->(dbSetOrder(10))

cQuery	+= " SELECT " + CRLF
cQuery	+= " CT2_HIST, " + CRLF
cQuery	+= " CT2_SEQHIS " + CRLF

cQuery	+= " FROM " + CRLF
cQuery	+= " " + RetSQLName("CT2") + " CT2 "  + CRLF

cQuery	+= " WHERE " + CRLF

cQuery	+= " CT2_FILIAL = '"+cFilCT2+"' AND  " + CRLF
cQuery	+= " CT2_DATA = '"+cData+"' AND  " + CRLF
cQuery	+= " CT2_LOTE = '"+cLote+"' AND  " + CRLF
cQuery	+= " CT2_SBLOTE = '"+cSubLote+"' AND  " + CRLF
cQuery	+= " CT2_DOC = '"+cDoc+"' AND  " + CRLF
cQuery	+= " CT2_SEQLAN = '"+cSeqLan+"' AND  " + CRLF
cQuery	+= " CT2_EMPORI = '"+cEmpOri+"' AND  " + CRLF
cQuery	+= " CT2_FILORI = '"+cFilOri+"' AND  " + CRLF
cQuery	+= " CT2_MOEDLC = '"+cMoeda+"'  AND  " + CRLF
cQuery	+= " CT2.D_E_L_E_T_ = ' '  " + CRLF

cQuery	+= " ORDER BY "
cQuery	+= " CT2_SEQHIS " 

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabQry,.T.,.T.)

While (cTabQry)->(!EOF())
	cHist += Alltrim((cTabQry)->CT2_HIST) + " "
	If Len(cHist) >= 950
		Exit
	EndIf 
	(cTabQry)->(dbSkip())
EndDo


If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf

RestArea(aArea)

Return cHist

//-------------------------------------------------------------------
/*/{Protheus.doc} C620X2Nome
Retorna a descrição da tabela

@author alvaro.camillo

@since 30/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function C620X2Nome(cTabela) 
Local aArea := GetArea()
Local cNome := ""

SX2->(dbSetOrder(1)) 

If SX2->(dbSeek( cTabela )) 
	cNome := SX2->(X2Nome())
EndIf

RestArea(aArea)

Return cNome

//-------------------------------------------------------------------
/*/{Protheus.doc} CTC620Key
Função que transforma a chave em um array

@author alvaro.camillo

@since 30/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CTC620Key(cChave)
Local aChave := {}

cChave := Alltrim(cChave)

aChave := STRTOKARR(cChave,"+")

Return aCHave

//-------------------------------------------------------------------
/*/{Protheus.doc} C620MDStr
Retorna a estrutura da tabela que será criada para o processamento da auditoria

@author alvaro.camillo

@since 30/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function C620MDStr()
Local aStruSQL 		:= {}
Local oModel		:= ModelDef()
Local oModelItem	:= oModel:GetModel("LANCDETAIL")
Local aFields		:= oModelItem:GetStruct():GetFields()
Local nX			:= 0

For nX := 1 to Len(aFields)
	If Alltrim(aFields[nX][4]) != 'L'
		AADD(aStruSQL,{Alltrim(aFields[nX][3])	,Alltrim(aFields[nX][4]) ,aFields[nX][5],aFields[nX][6]} )
	EndIf
Next nX

Return aStruSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author alvaro.camillo

@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStr1:= FWFormStruct(1,'CWA')
Local oStr2:= mldoStr2Str()
Local oStr3:= mldoStr3Str()

oModel := MPFormModel():New('CTBC620',,,{|oModel| CTC620Grv(oModel) } )
oModel:SetDescription(STR0023)//'Auditoria de Lançamento por conta'

oStr1:SetProperty('*',MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, " .F." )  )
oStr2:SetProperty('*',MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, " .F." ))
oStr3:SetProperty('*',MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, " .F." ))
oStr2:SetProperty('OK',MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, " .T." ))
oStr2:SetProperty('OK',MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "CTC620VdOK()" ) )

oModel:addFields('CWAMASTER',,oStr1)
oModel:addGrid('LANCDETAIL','CWAMASTER',oStr2,/*bPreLin*/,,,, {|oModel| CTC620LLoad(oModel)})
oModel:addGrid('DEPDETAIL','LANCDETAIL',oStr3,/*bPreLin*/,,,,  {|oModel| CTC620DLoad(oModel)})

oModel:SetRelation('LANCDETAIL', { { 'CODAUD', 'CWA_COD' } }, '' )
oModel:SetRelation('DEPDETAIL', { { 'RECTRB', 'RECTRB' } }, '' )

oModel:getModel('CWAMASTER'):SetDescription(STR0024)//'Cabecalho Auditoria'
oModel:getModel('LANCDETAIL'):SetDescription(STR0025)//'Lancamento X Movimento'
oModel:getModel('DEPDETAIL'):SetDescription(STR0026)//'Dependência'
oModel:getModel('LANCDETAIL'):SetMaxLine(10000)
oModel:getModel('DEPDETAIL'):SetMaxLine(10000)

oModel:getModel('LANCDETAIL'):SetNoDeleteLine(.T.)
oModel:getModel('DEPDETAIL'):SetNoDeleteLine(.T.)
oModel:getModel('LANCDETAIL'):SetNoInsertLine(.T.)
oModel:getModel('DEPDETAIL'):SetNoInsertLine(.T.)


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} CTC620Grv
Dados da grid da model de dependencias

@author alvaro.camillo

@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CTC620Grv(oModel)
Local aArea		:= GetArea()
Local nX			:= 0
Local oModelItem	:= oModel:GetModel('LANCDETAIL')
Local nRecCT2		:= 0

For nX := 1 to oModelItem:Length()
	oModelItem:GoLine(nX)
	If oModelItem:GetValue("OK")
		nRecCT2 := oModelItem:GetValue("RECCT2")
		If nRecCT2 > 0
			CT2->(dbGoTo(nRecCT2))
			RecLock("CT2",.F.)
			CT2->CT2_CONFST	:= "1"
			CT2->CT2_USRCNF	:= cUserName
			CT2->CT2_DTCONF	:= MSDate()
			CT2->CT2_HRCONF	:= Time()	
			MsUnLock()
		EndIf
	EndIf
Next nX

RestArea(aArea)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CTC620VdOK
Dados da grid da model de dependencias

@author alvaro.camillo

@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function CTC620VdOK()
Local lRet 		:= .T.
Local oModel	:= FWModelActive()
Local oModelItem:= oModel:GetModel('LANCDETAIL')
Local cStatus 	:= oModelItem:GetValue("STATUS")

If !(cStatus $ '1/2')
	lRet := .F.
	Help(" ",1,"CTBASTATUS",,STR0027, 1, 0 )//"Esse status não permite a confirmação da conciliação. " 	
 	oModelItem:LoadValue("OK",.F.)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTC620DLoad
Dados da grid da model de dependencias

@author alvaro.camillo

@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CTC620DLoad(oModelItem)
Local aLoad 		:= {}
Local oModel		:= oModelItem:GetModel()
Local oModelLanc	:= oModel:GetModel("LANCDETAIL")
Local aFields		:= oModelItem:GetStruct():GetFields()
Local nY			:= 0
Local aCpoLanc	:= {}
Local aAux			:= {}
Local cCampo		:= ""
Local nX			:= 0
Local cItem		:= "0000"
Local aArea 		:= GetArea()
Local cTabQry		:= "C620LOAD2"
Local cQuery		:= ""
Local nRecTrb		:= oModelLanc:GetValue("RECTRB")

If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf

cQuery	+= " SELECT * " + CRLF
cQuery	+= " FROM " + oTmpTable:GetRealName()  + CRLF
cQuery	+= " WHERE " + CRLF
cQuery	+= " RECDEP = " +cValTochar(nRecTrb) + "  AND " + CRLF
cQuery	+= " D_E_L_E_T_ = ' '  " + CRLF
cQuery	+= " ORDER BY "
cQuery	+= " RECDEP "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabQry,.T.,.T.)

TcSetField(cTabQry,"DATAMOV"  ,"D", 8,0)
TcSetField(cTabQry,"DATACTB"  ,"D", 8,0)

// Posição no Array - Atenção a ordem deve ser a mesma do model
For nY := 1 to Len(aFields)
	aAdd(aCpoLanc, { Alltrim(aFields[nY][3]) , Alltrim(aFields[nY][4])}  )
Next nY

If (cTabQry)->(!EOF())
	While (cTabQry)->(!EOF())
		aAux := Nil
		aAux := Array(Len(aCpoLanc))
		
		cItem 	:= Soma1(cItem)
	
		For nX := 1 to Len(aCpoLanc)
			cCampo   := aCpoLanc[nX][1]
			If cCampo == 'RECTRB'
				aAux[nX] := (cTabQry)->RECDEP
			ElseIf cCampo == 'CHAVEMOV'
				aAux[nX] := Alltrim((cTabQry)->CHAVEMOV)
			ElseIf cCampo == 'ITEMDEP'
				aAux[nX] := cItem
			Else
				aAux[nX] := (cTabQry)->&(cCampo)
			EndIf
		Next nX
		
		aAdd(aLoad,{0 ,aAux })
	
		(cTabQry)->(dbSkip())
	EndDo
Else
	aAux := Nil
	aAux := Array(Len(aCpoLanc))

	For nX := 1 to Len(aCpoLanc)
		cCampo   := aCpoLanc[nX][1]
		cTipo    := aCpoLanc[nX][2]
	
		If cCampo == 'RECTRB'
			aAux[nX] := nRecTrb
		ElseIf cCampo == 'ITEMDEP'
			aAux[nX] := "0001"
		ElseIf cTipo == "C"
			aAux[nX] := ""
		ElseIF cTipo == "D"
			aAux[nX] := CTOD("")
		ElseIF cTipo == "L"
			aAux[nX] := .F.
		ElseIF cTipo == "N"
			aAux[nX] := 0
		EndIf
	Next nX


	aAdd(aLoad,{0 ,aAux })
EndIf

If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf


Return aLoad
//-------------------------------------------------------------------
/*/{Protheus.doc} CTC620LLoad
Dados da grid da model de lançamentos

@author alvaro.camillo

@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function CTC620LLoad(oModelItem)
Local aLoad 		:= {}
Local aFields		:= oModelItem:GetStruct():GetFields()
Local nY			:= 0
Local aCpoLanc	:= {}
Local aAux			:= {}
Local cCampo		:= ""
Local nX			:= 0
Local cItem		:= "0000"
Local aArea 		:= GetArea()
Local cTabQry		:= "C620LOAD"
Local cQuery		:= ""

If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf


cQuery	+= " SELECT * " + CRLF
cQuery	+= " FROM " + oTmpTable:GetRealName()  + CRLF
cQuery	+= " WHERE " + CRLF
cQuery	+= " RECDEP = 0  AND " + CRLF
cQuery	+= " D_E_L_E_T_ = ' '  " + CRLF
cQuery	+= " ORDER BY "
cQuery	+= " R_E_C_N_O_ " 

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabQry,.T.,.T.)
TcSetField(cTabQry,"DATAMOV"  ,"D", 8,0)
TcSetField(cTabQry,"DATACTB"  ,"D", 8,0)

// Posição no Array - Atenção a ordem deve ser a mesma do model
For nY := 1 to Len(aFields)
	aAdd(aCpoLanc, Alltrim(aFields[nY][3]) )
Next nY

While (cTabQry)->(!EOF())
	aAux := Nil
	aAux := Array(Len(aCpoLanc))
	
	cItem := Soma1(cItem)
	
	For nX := 1 to Len(aCpoLanc)
		cCampo   := aCpoLanc[nX]
		If cCampo == 'COR'
			aAux[nX] := CBC620COR((cTabQry)->STATUS)
		ElseIf cCampo == 'CHAVEMOV'
			aAux[nX] := Alltrim((cTabQry)->CHAVEMOV)
		ElseIf cCampo == 'ITEMLAN'
			aAux[nX] := cItem
		ElseIf cCampo == 'OK'
			aAux[nX] := .F.
		ElseIf cCampo == 'HIST'
			(__cTRBQuad)->(dbGoto((cTabQry)->R_E_C_N_O_))
			aAux[nX] := (__cTRBQuad)->HIST
		Else 
			aAux[nX] := (cTabQry)->&(cCampo)
		EndIf
	Next nX
	
	aAdd(aLoad,{0 ,aAux })

	(cTabQry)->(dbSkip())
EndDo

If Select(cTabQry) > 0
	(cTabQry)->(dbCloseArea())
EndIf

Return aLoad

//-------------------------------------------------------------------
/*/{Protheus.doc} F473COR
Função que retorna a cor da legenda

@author alvaro.camillo

@since 03/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CBC620COR(cStatus)
Local cCor := ""

IF cStatus == '1'
	cCor:= "BR_AZUL"
ElseIf cStatus == '2'
	cCor := "BR_VERDE"
ElseIf cStatus == '3'
	cCor := "BR_AMARELO"
ElseIf cStatus == '4'
	cCor := "BR_VERMELHO"
ElseIf cStatus == '5'
	cCor := "BR_CINZA"
EndIf

Return cCor

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author alvaro.camillo

@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'CWA')
Local oStr2:= viewoStr2Str()
Local oStr3:= viewoStr3Str()

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('FORM1' , oStr1,'CWAMASTER' )
oView:AddGrid('FORM3' , oStr2,'LANCDETAIL')
oView:AddGrid('FORM5' , oStr3,'DEPDETAIL')   
oView:CreateHorizontalBox( 'BOXFORM1', 20)
oView:CreateHorizontalBox( 'BOXFORM3', 60)
oView:CreateHorizontalBox( 'BOXFORM5', 20)
oView:SetOwnerView('FORM1','BOXFORM1')
oView:SetOwnerView('FORM3','BOXFORM3')
oView:SetOwnerView('FORM5','BOXFORM5')

oView:EnableTitleView('FORM5' , STR0028)//'Dependências' 
oView:EnableTitleView('FORM3' , STR0029 )//'Lançamento X Movimento' 
oView:EnableTitleView('FORM1' , STR0030 )//'Configuração de Auditoria' 

oView:AddUserButton( STR0070, 'FORM', {|oView| CTC620Leg() } ) //'Legenda'
oView:AddUserButton( STR0071, 'FORM', {|oView| CTC620Print(oView) } ) //'Imprimir Consulta'

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CTC620Print()
Impressão do cadastro

@author alvaro.camillo

@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CTC620Print(oView)
Local oModel := oView:GetModel()
Local oReport
Local aSaveLines 	:= FWSaveRows()

oReport := C620RptDef(oModel)
oReport:PrintDialog()

FWRestRows(aSaveLines)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} mldoStr2Str()
Retorna estrutura do tipo FWformModelStruct.

@author alvaro.camillo

@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
static function mldoStr2Str()
Local oStruct := FWFormModelStruct():New()
oStruct:AddTable('LANC',,STR0031 )//'Lancamento X Movimento'
oStruct:AddField(STR0032,STR0032 , 'FILIALMOV', 'C',TAMSX3("CT2_FILIAL")[1] )//'Filial'##'Filial'
oStruct:AddField(STR0033,STR0033 , 'OK', 'L',1,,,,,,,,.F.,.T. )//'Marcacao'##'Marcacao'
oStruct:AddField(STR0034,STR0034 , 'STATUS', 'C',1 )//'Status'
oStruct:AddField(STR0035,STR0036 , 'CODAUD', 'C',6 )//'Cod Audt'##'Código da Auditoria'
oStruct:AddField(STR0037,STR0037 , 'ITEMLAN', 'C',4 )//'Item'
oStruct:AddField(STR0038,STR0039 , 'ENTMOV', 'C',3 )//'Entidade'##'Entidade Movimento'
oStruct:AddField(STR0040,STR0041 , 'ENTDESC', 'C',30 )//'Descricao'##'Entidade Movimento'
oStruct:AddField(STR0042,STR0043 , 'CHAVEMOV', 'C',TAMSX3("CT2_KEY")[1] )//'Chave Mov'##'Chave do Movimento'
oStruct:AddField(STR0044,STR0045 , 'DATAMOV', 'D',8 )//'Data Mov'##'Data do Movimento'
oStruct:AddField(STR0046,STR0047 , 'VALORMOV', 'N',16,2 )//'Valor Mov'##'Valor do Movimento'
oStruct:AddField(STR0048,STR0048 , 'CONTA', 'C',TAMSX3("CT1_CONTA")[1],0 )//'Conta'
oStruct:AddField(STR0049,STR0049 , 'MOEDA', 'C',2,0 )//'Moeda'
oStruct:AddField(STR0050,STR0050 , 'RECMOV', 'N',10,0 )//'Recno Mov'
oStruct:AddField(STR0051,STR0051 , 'RECTRB', 'N',10,0 )//'Recno Trb'##'Recno Trb'
oStruct:AddField(STR0052,STR0052 , 'COR', 'C',30,,,{|| .F.} ,,,,,.T.,.T. )//'Cor'##'Cor'

oStruct:AddField(STR0053,STR0054 , 'DATACTB', 'D',8 )//'Data CTB'##'Data Contábil'
oStruct:AddField(STR0055,STR0055 , 'LOTE', 'C',TAMSX3("CT2_LOTE")[1] )//'Lote'##'Lote'
oStruct:AddField(STR0056,STR0056 , 'SBLOTE', 'C',TAMSX3("CT2_SBLOTE")[1] )//'SubLote'##'SubLote'
oStruct:AddField(STR0057,STR0057 , 'DOC', 'C',TAMSX3("CT2_DOC")[1] )//'Documento'##'Documento'
oStruct:AddField(STR0058,STR0058 , 'LINHA', 'C',TAMSX3("CT2_LINHA")[1] )//'Linha'
oStruct:AddField(STR0059,STR0059 , 'DC', 'C',10 )//'Partida'
oStruct:AddField(STR0060,STR0061 , 'VALORCTB', 'N',16,2 )//'Valor CTB'##'Valor Contábil'
oStruct:AddField(STR0062,STR0062 , 'HIST', 'M',40 )//'Histórico'##'Histórico'
oStruct:AddField(STR0063,STR0063 , 'RECCT2', 'N',10,0 )//'Recno CT2'
oStruct:AddField(STR0072,STR0072 , 'RECDEP', 'N',10,0 )//"Rec Relac"
oStruct:AddField(STR0073,STR0073 , 'ORDEM', 'C',04,0 )//"Ordem de Busca"

return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} mldoStr3Str()
Retorna estrutura do tipo FWformModelStruct.

@author alvaro.camillo

@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
static function mldoStr3Str()
Local oStruct := FWFormModelStruct():New()
oStruct:AddTable('DEPEN',,STR0074)//'Dependencia'

oStruct:AddField(STR0051,STR0051 , 'RECTRB', 'N',10,0 )//'Recno Trb'##'Recno Trb'
oStruct:AddField(STR0037,STR0037 , 'ITEMDEP', 'C',4 )//'Item'
oStruct:AddField(STR0038,STR0039 , 'ENTMOV', 'C',3 )//'Entidade'##'Entidade Movimento'
oStruct:AddField(STR0040,STR0041 , 'ENTDESC', 'C',30 )//'Descricao'##'Entidade Movimento'
oStruct:AddField(STR0044,STR0045 , 'DATAMOV', 'D',8 )//'Data Mov'##'Data do Movimento'
oStruct:AddField(STR0042,STR0043 , 'CHAVEMOV', 'C',TAMSX3("CT2_KEY")[1] )//'Chave Mov'##'Chave do Movimento'
oStruct:AddField(STR0046,STR0047 , 'VALORMOV', 'N',16,2 )//'Valor Mov'##'Valor do Movimento'

return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} viewoStr2Str()
Retorna estrutura do tipo FWFormViewStruct.

@author alvaro.camillo

@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
static function viewoStr2Str()
Local oStruct := FWFormViewStruct():New()

oStruct:AddField( 'OK'			,'01',''		,''			,, 'Check' )
oStruct:AddField( 'COR'			,'02',STR0034,STR0034			,, 'Get','@BMP',,,.F.,,,,,,.T.,,,35 ) //Status
oStruct:AddField( 'ITEMLAN'		,'03',STR0037	,STR0037 	,, 'Get' )//'Item'
oStruct:AddField( 'FILIALMOV'	,'04',STR0032	,STR0032	,, 'Get' )//'Filial'##'Filial'
oStruct:AddField( 'ENTDESC'		,'05',STR0038	,STR0039	,, 'Get' )//'Entidade'##'Entidade Movimento'
oStruct:AddField( 'CHAVEMOV'	,'06',STR0042	,STR0043	,, 'Get' ,,,,,,,,,,,,,200)//'Chave Mov'##'Chave do Movimento'
oStruct:AddField( 'DATAMOV'		,'07',STR0044	,STR0045	,, 'Get','@D' )//'Data Mov'##'Data do Movimento'
oStruct:AddField( 'VALORMOV'	,'08',STR0046	,STR0047	,, 'Get','@E 9,999,999,999,999.99' )//'Valor Mov'##'Valor do Movimento'
oStruct:AddField( 'DATACTB'		,'09',STR0053	,STR0054	,, 'Get','@D' )//'Data CTB'##'Data Contábil'
oStruct:AddField( 'LOTE'			,'10',STR0055	,STR0055	,, 'Get' )//'Lote'##'Lote'
oStruct:AddField( 'SBLOTE'		,'11',STR0056	,STR0056 	,, 'Get' )//'SubLote'##'SubLote'
oStruct:AddField( 'DOC'			,'12',STR0057	,STR0057 	,, 'Get' )//'Documento'##'Documento'
oStruct:AddField( 'DC'			,'13',STR0059	,STR0059	,, 'Get' )//'Partida'
oStruct:AddField( 'VALORCTB'	,'14',STR0060	,STR0061	,, 'Get','@E 9,999,999,999,999.99' )//'Valor CTB'##'Valor Contábil'
oStruct:AddField( 'HIST'			,'15',STR0062	,STR0062	,, 'Get' )//'Histórico'##'Histórico'

return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} viewoStr3Str()
Retorna estrutura do tipo FWFormViewStruct.

@author alvaro.camillo

@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

static function viewoStr3Str()
Local oStruct := FWFormViewStruct():New()  


oStruct:AddField( 'ITEMDEP'	,'01',STR0037,STR0037	,, 'Get' )//'Item'
oStruct:AddField( 'ENTDESC'	,'02',STR0038,STR0039	,, 'Get' )//'Entidade'##'Entidade Movimento'
oStruct:AddField( 'DATAMOV'	,'03',STR0044,STR0045	,, 'Get' ,'@D')//'Data Mov'##'Data do Movimento'
oStruct:AddField( 'CHAVEMOV','04',STR0042,STR0043	,, 'Get' ,,,,,,,,,,,,,200)//'Chave Mov'##'Chave do Movimento'
oStruct:AddField( 'VALORMOV','05',STR0046,STR0047	,, 'Get','@E 9,999,999,999,999.99' )//'Valor Mov'##'Valor do Movimento'

return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} CTC620Leg()
Mostra Legenda da Reconciliacao   

@author alvaro.camillo

@since 03/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function CTC620Leg()
Local oDlg2
Local nOpca2 	:= 0
Local lRet		:= .T.
Local oModel		:= FWModelActive()

DEFINE MSDIALOG oDlg2 FROM  69,70 TO 220,331 TITLE  STR0064 PIXEL  //"Legenda"
@ 05 , 5 BITMAP NAME "BR_AZUL"	 			SIZE 8,8 of Odlg2 PIXEL
@ 15 , 5 BITMAP NAME "BR_VERDE" 			SIZE 8,8 of Odlg2 PIXEL
@ 25 , 5 BITMAP NAME "BR_AMARELO" 			SIZE 8,8 of Odlg2 PIXEL
@ 35 , 5 BITMAP NAME "BR_VERMELHO" 			SIZE 8,8 of Odlg2 PIXEL
@ 45 , 5 BITMAP NAME "BR_CINZA" 			SIZE 8,8 of Odlg2 PIXEL
@ 05 , 19 SAY  STR0065  	SIZE 115, 7 OF oDlg2 PIXEL  //"Lançamento conciliado Parcialmente"
@ 15 , 19 SAY  STR0066	SIZE 100, 7 OF oDlg2 PIXEL  //"Lançamento conciliado "
@ 25 , 19 SAY  STR0067  	SIZE 100, 7 OF oDlg2 PIXEL  //"Movimento de origem sem lançamento"
@ 35 , 19 SAY  STR0068   	SIZE 100, 7 OF oDlg2 PIXEL  //"Lançamento sem movimento de origem"
@ 45 , 19 SAY  STR0069   	SIZE 100, 7 OF oDlg2 PIXEL  //"Movimento conciliado anteriormente"

DEFINE SBUTTON FROM 60, 100 TYPE 1 ENABLE ACTION (oDlg2:End()) OF oDlg2
ACTIVATE MSDIALOG oDlg2 CENTERED

oModel:GetModel("LANCDETAIL"):GoLine(1)
oModel:GetModel("DEPDETAIL"):GoLine(1)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C620RptDef()
Relatório da conferencia

@author alvaro.camillo

@since 03/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function C620RptDef(oModel)

Local oReport
Local oSecItem
Local cReport 	:= "CTBC620"
Local aCampos		:= {} 
Local cDesc		:= Alltrim(oModel:GetValue("CWAMASTER","CWA_DESC"))
Local cConta		:= Alltrim(oModel:GetValue("CWAMASTER","CWA_CONTA"))
Local cDescCont 	:= Alltrim( GetAdvFval("CT1","CT1_DESC01",xFilial("CT1") + cConta ,1 ) )
Local oModelItem	:= oModel:GetModel("LANCDETAIL")
Local aFields		:= oModelItem:GetStruct():GetFields()
Local nX			:= 0
Local nPos			:= 0
Local cTitulo 	:=	OemToAnsi(STR0075 +  cDesc +" "+ cConta + " " + STR0076 + cDescCont )//"Auditoria Contábil - "##" - Conta: "	
Local cDescri 	:=	STR0077
Local aOrd	  		:= {}
Local bReport 	:= {}

aAdd(aCampos,"STATUS")
aAdd(aCampos,"FILIALMOV")
aAdd(aCampos,"ENTDESC")
aAdd(aCampos,"CHAVEMOV")
aAdd(aCampos,"DATAMOV")
aAdd(aCampos,"VALORMOV")
aAdd(aCampos,"DATACTB")     
aAdd(aCampos,"LOTE")     
aAdd(aCampos,"SBLOTE")   
aAdd(aCampos,"DOC")   
aAdd(aCampos,"LINHA")    
aAdd(aCampos,"DC")  
aAdd(aCampos,"VALORCTB")
aAdd(aCampos,"HIST")

bReport := { |oReport|	oReport:SetTitle(cTitulo), PrintRel( oReport,oModelItem,aCampos ) }

oReport  := TReport():New( cReport, cTitulo, "", bReport, cDescri )

oSecItem := TRSection():New( oReport, STR0078 ,{}, aOrd ) // "Itens Auditoria"

For nX := 1 to Len( aCampos )
	nPos := aScan(aFields,{|x| Alltrim(x[3]) == aCampos[nX] })
	If nPos > 0
		cPicture := IIF(aCampos[nX] == "VALORCTB" .Or. aCampos[nX] == "VALORMOV" , '@E 9,999,999,999,999.99',"")
		
		If aCampos[nX] == "STATUS"
			nTamanho := 25
		ElseIf aCampos[nX] == "CHAVEMOV"
			nTamanho := 20
		ElseIf aCampos[nX] == "HIST"
			nTamanho := 20
		ElseIf aCampos[nX] == "ENTDESC"
			nTamanho := 20
		ElseIf aCampos[nX] == "DATACTB" .Or. aCampos[nX] == "DATAMOV"
			nTamanho := 15
		Else
			nTamanho := aFields[nPos][5] 
		EndIf
		If aCampos[nX] == "HIST" .Or. aCampos[nX] == "CHAVEMOV"  .Or. aCampos[nX] == "ENTDESC"
			TRCell():New( oSecItem, aFields[nPos][3]	, "", aFields[nPos][1], cPicture, nTamanho,/*lPixel*/,/*{|| code-block de impressao }*/,,.T.,,,,.T.)
		Else
			TRCell():New( oSecItem, aFields[nPos][3]	, "", aFields[nPos][1], cPicture, nTamanho,/*lPixel*/,/*{|| code-block de impressao }*/)
		EndIf
	EndIf
Next nX
oSecItem:SetHeaderPage(.T.)

oReport:SetLandScape()
oReport:ParamReadOnly()
oReport:DisableOrientation()

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintRel()
Controla a impressão do relatório

@author alvaro.camillo

@since 03/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PrintRel( oReport,oModelItem,aCampos )
Local oSecItem 	:= oReport:Section(1)
Local nX		:= 0
Local nY		:= 0
Local cConteudo	:= ""
Local cCampo	:= ""
Local nRec		:= 0

For nX := 1 To oModelItem:Length()
	oModelItem:GoLine(nX)
	oSecItem:Init()
		
	For nY := 1 to Len(aCampos)
		
		cCampo  	:= aCampos[nY]
		If cCampo == "STATUS"
			cConteudo 	:= C620StaDesc(oModelItem:GetValue("STATUS"))
		ElseIf cCampo == "DATAMOV" .Or. cCampo == "DATACTB"
			dData 	:= oModelItem:GetValue(cCampo)
			cConteudo := DTOC(dData)
		ElseIf cCampo == "HIST"
			nRec := oModelItem:GetValue("RECTRB")
			If nRec > 0 
				(__cTRBQuad)->(dbGoto(nRec))
				cConteudo 	:= (__cTRBQuad)->HIST 
			Else
				cConteudo 	:= ""
			EndIf
		Else
			cConteudo 	:= oModelItem:GetValue(cCampo)
		EndIf
		
		oSecItem:Cell(cCampo):SetValue(cConteudo)
	Next nY
	
	oSecItem:PrintLine()
	oSecItem:Finish()
	
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C620StaDesc()
Retorna a descrição do Status

@author alvaro.camillo

@since 03/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function C620StaDesc(cStatus)
Local cDesc := ""

If cStatus == '1'
	cDesc := STR0079//"Conciliado Parcialmente"
ElseIf cStatus == '2'
	cDesc := STR0080 //"Lançamento conciliado "
ElseIf cStatus == '3'
	cDesc := STR0081 //"Origem sem lançamento"
ElseIf cStatus == '4'
	cDesc := STR0082 //"Lançamento sem origem"
ElseIf cStatus == '5'
	cDesc := STR0083 //"Conciliado anteriormente"
EndIf

Return cDesc
