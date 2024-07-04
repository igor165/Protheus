#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "FWBROWSE.CH"
#Include "ApWizard.ch"
#Include "fina771.ch"

STATIC cArqTrab	:= GetNextAlias()
Static _oFINA7711
Static __lF771IND := ExistBlock("F771IND")
Static __lF771BRW := ExistBlock("F771BRW")

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA771
Retirada Manual
@author lucas.oliveira
@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function FINA771()
Local oBrowse		:= Nil
Local cQuery		:= ""
Local cChave		:= ""
Local aColumns		:= {}
Local nX			:= 0
Local aStru			:= {} 
Local cTitulo		:= STR0001
Local cPrograma		:= "FINA771"
Local nOperation	:= MODEL_OPERATION_UPDATE
Local aCpoFW9		:= {}

If cPaisLoc == "BRA"

	aStru	:= FW9->(DBSTRUCT())

	cQuery += "SELECT * FROM "+ RetSqlName("FW9") +" FW9, "+ RetSqlName("FWA") +" FWA "
	cQuery += "WHERE FW9.FW9_FILIAL = '" + xFilial("FW9") + "' "
	cQuery += "AND FW9.FW9_FILIAL = FWA.FWA_FILIAL "
	cQuery += "AND FW9.FW9_IDDOC = FWA.FWA_IDDOC "
	cQuery += "AND FW9.D_E_L_E_T_ = ' ' "
	cQuery += "AND FWA.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY "+ SqlOrder(FW9->(IndexKey()))
	
	cChave := FW9->(IndexKey())
	Aadd(aStru, {"FWA_STATUS","C",1,0})
	
	If _oFINA7711 <> Nil
		_oFINA7711:Delete()
		_oFINA7711	:= Nil
	EndIf
	
	//Cria o Objeto do FwTemporaryTable
	_oFINA7711 := FwTemporaryTable():New(cArqTrab)
	
	//Cria a estrutura do alias temporario
	_oFINA7711:SetFields(aStru)
	
	//Adiciona o indicie na tabela temporaria
	_oFINA7711:AddIndex("1",{"FWA_STATUS"})

	//Ponto de Entrada para adicionar indices a tabela temporária
	If __lF771IND
		ExecBlock("F771IND",.f.,.f.,{_oFINA7711})
	EndIf
	aCpoFW9:= F771RetFW9(aStru)
	//Criando a Tabela Temporaria
	_oFINA7711:Create()
	
	Processa({||SqlToTrb(cQuery, aStru, cArqTrab)})	// Cria arquivo temporario
	DbSetOrder(0) // Fica na ordem da query
	
	//Browse
	For nX := 1 To Len(aStru)
		If	!aStru[nX][1] $ "FW9_IDDOC|FWA_IDDOC|FWA_STATUS"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1]))
			aColumns[Len(aColumns)]:SetSize(aStru[nX][3])
			aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
			aColumns[Len(aColumns)]:SetPicture(/*Iif( aStru[nX][1] != "FWA_STATUS", */PesqPict("FW9",aStru[nX][1])/*, PesqPict("FWA",aStru[nX][1]) )*/ )  
		EndIf
	Next nX
	
	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias(cArqTrab)
	oBrowse:SetDescription(cTitulo)
	oBrowse:AddLegend("FWA_STATUS $ '3|7|8'", "GREEN", STR0002 )
	oBrowse:AddLegend("!FWA_STATUS $ '3|7|8'", "RED", STR0003)
	oBrowse:SetMenuDef("")
	oBrowse:AddButton(STR0004, {|| F771Ret(cTitulo, cPrograma, nOperation, cArqTrab, oBrowse)},,2) //Confirmar
	oBrowse:SetColumns(aColumns)
	oBrowse:DisableDetails()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetUseCaseFilter(.T.)
	oBrowse:SetFieldFilter(aCpoFW9)
	
	//Ponto de Entrada para alterar propriedades do oBrowse
	If __lF771BRW
		ExecBlock("F771BRW",.f.,.f.,{oBrowse})
	EndIf
	oBrowse:Activate()

Else
	MsgStop(OemToAnsi(STR0019)) //"Função disponível apenas para o Brasil."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author lucas.oliveira
@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	:= FWLoadModel("FINA771")
Local oView		:= FWFormView():New()
Local oStruFW9	:= FWFormStruct(2,"FW9")
Local oStruFWA	:= FWFormStruct(2,"FWA")
Local oStruFWB	:= FWFormStruct(2,"FWB")

oView:SetModel(oModel)

oView:AddField("VIEW_FW9",	oStruFW9, "MASTERFW9")
oView:AddGrid("VIEW_FWA",	oStruFWA, "SITTITFWA")

oView:CreateHorizontalBox("BOXFW9", 40)
oView:CreateHorizontalBox("BOXFWA", 60)

oView:SetOwnerView("VIEW_FW9", "BOXFW9")
oView:SetOwnerView("VIEW_FWA", "BOXFWA")

oView:EnableTitleView("VIEW_FW9", STR0005)
oView:EnableTitleView("VIEW_FWA", STR0006)

oStruFW9:RemoveField( "FW9_IDDOC" )
oStruFWA:RemoveField( "FWA_IDDOC" )

oStruFW9:SetProperty( "*" , MVC_VIEW_CANCHANGE, .F.)
oStruFWA:SetProperty( "*" , MVC_VIEW_CANCHANGE, .F.)
oStruFWB:SetProperty( "*" , MVC_VIEW_CANCHANGE, .F.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author lucas.oliveira
@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= Nil
Local oStruFW9	:= FWFormStruct(1,"FW9")
Local oStruFWA	:= FWFormStruct(1,"FWA")
Local oStruFWB	:= FWFormStruct(1,"FWB")
Local aFWARel	:= {}
Local aFWBRel	:= {}

oModel := MPFormModel():New("FINA771",/*PreValidacao*/,/*PosValidacao*/, {|oModel| F771Grava(oModel)}/*bCommit*/)

oStruFW9:AddField(	STR0007,; //Título do campo
					"",; //cToolTip
					"FWB_DCERRO",;// Id do Campo
					"C",; //cTipo
					20,; //Tamanho do Campo	
					0,;//Decimal
					{||.F.},;//
					{||.F.})//

oModel:AddFields("MASTERFW9", /*cOwner*/, oStruFW9, /*bPreVld*/, /*bPosVld*/, /*bLoad*/)
oModel:SetDescription(STR0008)
oModel:GetModel("MASTERFW9"):SetDescription(STR0005)
oModel:AddGrid("SITTITFWA", "MASTERFW9", oStruFWA)
oModel:AddGrid("MOVTITFWB", "MASTERFW9", oStruFWB)

Aadd(aFWARel,{"FWA_FILIAL","xFilial('FWA')"})
Aadd(aFWARel,{"FWA_IDDOC","FW9_IDDOC"})
oModel:setrelation("SITTITFWA", aFWARel, FWA->(IndexKey(1)))

Aadd(aFWBRel,{"FWB_FILIAL","xFilial('FWB')"})
Aadd(aFWBRel,{"FWB_LOTE","FW9_LOTE"})
Aadd(aFWBRel,{"FWB_IDDOC","FW9_IDDOC"})
oModel:setrelation("MOVTITFWB", aFWBRel, FWB->(IndexKey(1)))

oModel:SetActivate( {|oModel| F771Load(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} F771Ret
@author lucas.oliveira
@since 18/06/2015
@version 12.1.6
@return aRotina Array com as configurações necessárias para criação do menu de opções
/*/
//-------------------------------------------------------------------
Function F771Ret(cTitulo , cPrograma, nOperation, cArqTrab, oBrowse)
Local lRet	:= .T.

//Valido se o arquivo de trabalho que preenche o browse está vazio
If (cArqTrab)->(Eof())
	Help( ,,"F771ArqVazio",,STR0012, 1, 0 )
	lRet := .F.
EndIf

If FW9->(DbSeek(xFilial("FW9")+(cArqTrab)->(FW9_LOTE+FW9_IDDOC))) .AND. (cArqTrab)->FWA_STATUS $ '3|7|8'
	lRet := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/,/*aButtons*/, /*bCancel */, /*cOperatId*/, /*cToolBar, oModel */)
	oBrowse:refresh()
ElseIf lRet
	Help( ,,"F771RetManu",,STR0009, 1, 0 )
	lRet := .F.	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F771PosVld

@author lucas.oliveira
@since 18/06/2015
@version 12.1.6
@return lRet 
/*/
//-------------------------------------------------------------------
Function F771Load(oModel)
Local oFW9		:= Nil
Local oFWA		:= Nil
Local oFWB		:= Nil
Local cNumSeq	:= ""
Local lRet		:= .F.

dbSelectArea("FWB")	
FWB->(dbSetOrder(1))

oFW9	:= oModel:GetModel("MASTERFW9")
oFWA	:= oModel:GetModel("SITTITFWA")
oFWB	:= oModel:GetModel("MOVTITFWB")	
	
If oFWA:GetValue("FWA_STATUS") $ '3|7|8'
	
	If !oFWB:IsEmpty()
		cNumSeq := Soma1(oFWB:GetValue("FWB_SEQ"))
		
		While FWB->(DbSeek(xFilial("FWB")+oFWA:GetValue("FWA_IDDOC")+cNumSeq))
			cNumSeq := SOMA1(cNumSeq)
		EndDo
		
		oFWB:AddLine()
	EndIf
	
	oFWB:SetValue( "FWB_LOTE"	, oFW9:GetValue("FW9_LOTE") )	//	Código do Lote Serasa
	oFWB:SetValue( "FWB_IDDOC"	, oFW9:GetValue("FW9_IDDOC") )	//	Chave do titulo (FK7_IDDOC)
	oFWB:SetValue( "FWB_SEQ"		, cNumSeq )						//	Sequência de registro para o título.
	oFWB:SetValue( "FWB_OCORR"	, "0" )							//	0 - Retirada manual do Serasa.
	oFWB:SetValue( "FWB_DESCR"	, STR0011)							//	Descrição da ocorrência
	oFWB:SetValue( "FWB_DTOCOR"	, dDatabase )						//	Data da ocorrência (Protheus)
	oFWB:SetValue( "FWB_VALOR"	, oFW9:GetValue("FW9_VALOR"))	//	Saldo do título no momento do envio
	oFWB:SetValue( "FWB_CODERR"	, "  ")							//	<vazia>
	oFWB:SetValue( "FWB_DTSERA"	, CTOD("//") )					//	<vazia>
	
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F771Grava
Atualiza o status e sequencia da FWA e
cria um novo registro de ocorrência na FWB se Baixa ou Renegociação do título.
@author lucas.oliveira
@since  16/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F771Grava(oModel,lAuto,aTit)
Local oFW9	:= Nil
Local oFWA	:= Nil
Local oFWB	:= Nil
Local lRet	:= .F.
Local aAlt	:= {}

If !lAuto
	
	oFW9 := oModel:GetModel("MASTERFW9")
	oFWA := oModel:GetModel("SITTITFWA")
	oFWB := oModel:GetModel("MOVTITFWB")	
		
	If oFWA:GetValue("FWA_STATUS") $ '3|7|8'
		oFWA:LoadValue("FWA_SEQ", oFWB:GetValue("FWB_SEQ"))
		oFWA:LoadValue("FWA_STATUS", "0" )
		( cArqTrab )->FWA_STATUS := "0"
	EndIf
	
	lRet := FwFormCommit( oModel )
	
	If lRet
		SE1->( DbSetOrder(1) )
		SE1->( DbSeek(xFilial("SE1") + oFW9:GetValue("FW9_PREFIX") + oFW9:GetValue("FW9_NUM") + oFW9:GetValue("FW9_PARCEL") + oFW9:GetValue("FW9_TIPO")) )
		aadd( aAlt,{ STR0008,'','','',STR0010 })//"RETIRADA MANUAL SERASA"#"Retirada manual de título no Serasa."
		///chamada da Função que cria o Histórico de Cobrança
		FinaCONC(aAlt)
	EndIf
	
	oModel:DeActivate()
	oModel:Destroy()
	oModel := Nil
Else
	SE1->(DbSetOrder(1)) // pref + num + parc + tp
	SE1->(DbSeek(xFilial("SE1")+aTit[1,1]+aTit[1,2]+aTit[1,3]+aTit[1,4]))
	aadd( aAlt,{ STR0008,'','','',STR0010 })//"RETIRADA MANUAL SERASA"#"Retirada manual de título no Serasa."
	///chamada da Função que cria o Histórico de Cobrança
	FinaCONC(aAlt)
	
	FWA->(DbSetOrder(2)) // pref + num + parc + tp + cleinte + loja
	FWA->(DbSeek(xFilial("FWA")+aTit[1,1]+aTit[1,2]+aTit[1,3]+aTit[1,4]+aTit[1,5]+aTit[1,6]))
		
	Reclock("FWA", .F.)
 		FWA->FWA_STATUS := "0"
 	MsUnlock()	
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F771RetCpo
Retorna o valor dos campos virtuais de forma dinamica

@author TOTVS
@since  05/04/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function F771RetCpo(cTabela,cCampo)
Local xRet := Nil

If cTabela == "SA1"
	xRet := GetAdvFval("SA1",cCampo,XFILIAL("SA1",FWA->FWA_FILORI)+FWA->FWA_CLIENT+FWA->FWA_LOJA,1,CriaVar(cCampo,.F.))
ElseIf cTabela == "SE1"
	xRet := GetAdvFval("SE1",cCampo,XFilial("SE1",FWA->FWA_FILORI)+FWA->FWA_PREFIX+FWA->FWA_NUM+FWA->FWA_PARCEL+FWA->FWA_TIPO,1,CriaVar(cCampo,.F.))
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F771RetFW9
Retorna os campos da tabela FW9 para composição do filtro de Browse

@author Pâmela Bernardo
@since  23/04/2021
@version 12
/*/
//-------------------------------------------------------------------
Static Function F771RetFW9(aStru) as Array
	Local aCpoRet 	As Array
	Local nX		As Numeric
	Local nTamStru	As Numeric

	Default aStru := {}

	aCpoRet := {}
	nX		:= 0
	nTamStru:= len(aStru)

	For nx := 1 to nTamStru
		Aadd(aCpoRet,{aStru[nx][1]   , RetTitle(aStru[nx][1])     , aStru[nx][2]  , aStru[nx][3]  , aStru[nx][4]  ,PesqPict("FW9",aStru[nx][1]) })
	Next nx

Return aCpoRet
