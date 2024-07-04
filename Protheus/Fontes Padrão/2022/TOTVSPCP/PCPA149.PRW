#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA149.CH"
#INCLUDE "FWBROWSE.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA149
Função para cadastro dos termos PCP
@author  Thiago kobi Zoppi
@since   03/12/2019
/*/
//-------------------------------------------------------------------
Function PCPA149() 
	Local n,nTam
	Local cAliasQry  := GetNextAlias()
	Local lOk        := .T.
	Private cUser    := RetCodUsr()
	Private aTermos  := {}
	Private nLin     := 0
	Private aSize    := {}
	Private aObjects := {}
	Private aInfo    := {}
	Static oDlg
	// Obtém a a área de trabalho e tamanho da dialog
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 100, .T., .T. } ) // Dados da Enchoice 
	AAdd( aObjects, { 200, 100, .T., .T. } ) // Dados da getdados 
	AAdd( aObjects, { 300, 100, .T., .T. } ) // Dados da getdados 
	// Dados da área de trabalho e separação
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	// Chama MsObjSize e recebe array e tamanhos
	aPosObj := MsObjSize( aInfo, aObjects,.T.) 	

	//Query para selecionar todos os termos vigentes.
	BeginSql Alias cAliasQry
		
		SELECT
			HWH_TITULO,HWH_CODIGO,HWH_DESCRI,HWH_DTFIM
		FROM %table:HWH% HWH
		WHERE HWH_FILIAL = %xFilial:HWH%
			AND (HWH.HWH_DATA <= HWH.HWH_DTFIM OR HWH.HWH_DTFIM = '' )
			AND HWH.%notDel%
				
	EndSql
	
	While !(cAliasQry)->(Eof())
		
		If EMPTY((cAliasQry)->HWH_DTFIM) .OR. STOD((cAliasQry)->HWH_DTFIM) >= DDATABASE
		
			Aadd(aTermos,{cUser,(cAliasQry)->HWH_CODIGO ,.F.,(cAliasQry)->HWH_DESCRI,Nil }) // Array para controle dos termos
			nLin := len(aTermos)

			DBSelectArea("HWI")
			HWI->(DBSetOrder(1))

			IF ! HWI->(DBSEEK(xFilial("HWI")+cUser+(cAliasQry)->HWH_CODIGO))
				PCPA149A((cAliasQry)->HWH_CODIGO ) 
			Else 
				aTermos[nLin][3] := .T. 
				aTermos[nLin][5] := HWI->HWI_DATA
			EndIf
		Endif

		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(Dbclosearea())
	
	//Validação final para verificar se ficou algum aceite pendente. 
	nTam := LEN(aTermos)
	IF nTam > 0 
		For n := 1 to nTam
			IF ! aTermos[n][3] 
				HELP(' ',1,STR0001 ,,STR0002 ,2,0,,,,,, {STR0003})	//"Termo de consentimento" //"Existem termos sem o aceite!!" //"Verificar os termos pendentes."
				lOk := .F.
				Exit
			EndIf
		Next n

		IF lOk
			IF MSGYESNO( STR0004, STR0001 )
				PCPA149B()
			EndIf 
		Else 
			PCPA149B()
		EndIf
	Endif 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA149A
Monta a tela para o usuário confirmar os termos
@author  Thiago kobi Zoppi
@since   04/12/2019
/*/
//-------------------------------------------------------------------
Function PCPA149A(cCodTermo,lvisualiza )                        
	Local oCheckBo1
	Local oGet1
	Local oMemo1
	Local ctermo 
	Local oPanel1
	Local oSay1
	Local oSay2
	Local oFont1       := TFont():New("MS Sans Serif",,020,,.T.,,,,,.F.,.F.)
	Local cNomeUser    := UsrFullName( RetCodUsr( ) )
	Private lCheckBo1  := .F.
	Default lvisualiza := .F.

	DbselectArea("HWH")
	DBSetOrder(1)
	DBSEEK(xFilial("HWH")+cCodTermo)
	ctermo	:= HWH->HWH_TERMO  
	ctitulo := HWH->HWH_TITULO  
	
  	DEFINE MSDIALOG oDlg TITLE STR0001 FROM aSize[7],0 TO aSize[6],aSize[5]  COLORS 0, 16777215 PIXEL

		@ 015, 000 MSPANEL oPanel1 SIZE aSize[6] - 5,aSize[5]-5   OF oDlg COLORS 0, 16777215 RAISED
		oDlg:lMaximized := .F.
		@ 016, 003 SAY oSay1 PROMPT STR0005 SIZE 025, 007 OF oPanel1 COLORS 0, 16777215 PIXEL // "Usuário"
		@ 025, 003 MSGET oGet1 VAR cNomeUser SIZE 118, 010 OF oPanel1 COLORS 0, 16777215 READONLY PIXEL
		@ 045, 003 SAY oSay2 PROMPT cTitulo SIZE 392, 011 OF oPanel1 FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 059, 001 GET oMemo1 VAR ctermo  OF oPanel1 MEMO PIXEL SIZE aPosObj[3,4] ,aPosObj[3,3] -100   NO BORDER 
		
		oMemo1:lReadOnly := .T.
		IF !lvisualiza
			@ aPosObj[3,3]- 35 , aPosObj[3,4]- 110 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT STR0006 SIZE 103, 007 OF oPanel1 COLORS 0, 16777215 FONT oFont1 PIXEL //"Sim, li e aceito o termo"
		EndIf

		EnchoiceBar(oDlg, {||IF(!lvisualiza,(IF(Confirm(ctermo,cCodTermo),Odlg:end(),Odlg:refresh())),Odlg:end())}, {||Odlg:end()},,)

	ACTIVATE MSDIALOG oDlg CENTERED 

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA149B
Confirma o aceite do Usuário logado
@author  Thiago kobi Zoppi
@since   04/12/2019
/*/
//-------------------------------------------------------------------
Static Function Confirm(ctermo,cCodTermo)
	Local lRet	:= .T. 

	IF ! lCheckBo1 
		HELP(' ',1,STR0001 ,,STR0007,2,0,,,,,, {STR0008}) //"Termo de consentimento" //"Aceite não marcado!"
														  //"Para confirmar o aceite, será necessário aceitar, clicando no Checkbox no final do Termo!!"
		Return .F. 
	EndIf

	DBSelectArea("HWI")
	DBSetOrder(1)

	RecLock("HWI", .T.)
		Replace HWI_FILIAL	WITH xFilial("HWI")
		Replace HWI_CODUSER	WITH RetCodUsr()
		Replace HWI_CODTER	WITH cCodTermo
		Replace HWI_CONFIR	WITH "S"
		Replace HWI_DATA	WITH DATE()
		
	MsUnlock()
		
		aTermos[nLin][3] := .T.
		aTermos[nLin][5] := DATE()
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA149B
Tela que mostrar o termos do Usuário Logado
@author  Thiago kobi Zoppi
@since   04/12/2019
/*/
//-------------------------------------------------------------------
Static Function PCPA149B()
Local oBrowse
Static oDlg

    DEFINE MSDIALOG oDlg TITLE STR0009 FROM aSize[7],0 TO aSize[6],aSize[5]  COLORS 0, 16777215 PIXEL // "Termos"
		oBrowse :=  FWBrowse():New()
		oBrowse:SetOwner( oDlg )
		oBrowse:SetDataArray()
		oBrowse:SetDescription(STR0009)  // "Termos"
		oBrowse:SetDBFFilter()
		oBrowse:SetUseFilter()
		oBrowse:SetArray( aTermos ) // Define Fwbrowse para receber um Array.
		oBrowse:SetDoubleClick( {|| PCPA149C(aTermos,oBrowse) } )
		oBrowse:AddLegend( { || aTermos[oBrowse:nAt][3]  } ,"GREEN",STR0010)    //"Termo Aceito"
		oBrowse:AddLegend( { || !aTermos[oBrowse:nAt][3] } ,"RED"  ,STR0011)   //"Termo Pendente"
		oBrowse:SetColumns( {{ STR0012 , { || UsrFullName(aTermos[oBrowse:nAt][1])},"C",,,030,0,.F.,,.F.,                    }}) //"Usuario"
		oBrowse:SetColumns( {{ STR0013 , { || aTermos[oBrowse:nAt][4]             },"C",,,TAMSX3("HWH_DESCRI")[1],0,.F.,,.F.,}}) //"Termo"
		oBrowse:SetColumns( {{ STR0014 , { || aTermos[oBrowse:nAt][5]             },"D",,,TAMSX3("HWI_DATA")[1]  ,0,.F.,,.F.,}}) //"Data"
		oBrowse:Activate()	

		
    ACTIVATE MSDIALOG oDlg CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA149C
Duplo Click 
@author  Thiago kobi Zoppi
@since   05/11/2019
/*/
//-------------------------------------------------------------------
Static FUNCTION PCPA149C(aTermos,oBrowse)
	Local lvisualiza	:= aTermos[oBrowse:nAt][3]	// Valida se caso o termo for aceito, somente ira visualizar.

	PCPA149A(aTermos[oBrowse:nAt][2], lvisualiza ) 
	oBrowse:Refresh() 

Return
