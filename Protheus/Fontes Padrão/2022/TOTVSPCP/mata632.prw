#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA630.CH"
#INCLUDE "FWADAPTEREAI.CH"

Static __lAutomacao := isBlind()

//---------------------------------------------------------------------
/*/{Protheus.doc} MATA632()
Roteiro de Operações
@author Leonardo Quintania
@since 05/10/2012
@version 1.0
@return NIL
/*/
//---------------------------------------------------------------------
Function MATA632()
Local oBrowse := FWMBrowse():New()        
Private lBrowse := .T.

oBrowse:SetCacheView(.F.)
oBrowse:SetAlias("SG2")
oBrowse:SetDescription(STR0006) //Roteiro de Operações

// Tela com aviso de descontinuação do programa
PCPMsgExp("MATA632", STR0088, "https://tdn.totvs.com/pages/viewpage.action?pageId=652585591", "https://tdn.totvs.com/pages/viewpage.action?pageId=382554596") // "Processo Produtivo (PCPA124) e Processo Produtivo Por Estrutura (PCPA129)"

oBrowse:Activate()

Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Quintania
@since 05/10/2012
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'ViewDef.MATA632' OPERATION OP_VISUALIZAR ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION 'ViewDef.MATA632' OPERATION OP_INCLUIR ACCESS 0 //Incluir
ADD OPTION aRotina TITLE STR0004 ACTION 'A632VldLst(1)' OPERATION OP_ALTERAR ACCESS 0 //Alterar
ADD OPTION aRotina TITLE STR0005 ACTION 'A632VldLst(2)' OPERATION OP_EXCLUIR ACCESS 0 //Excluir

//Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
If ExistBlock("MTA630MNU")
	ExecBlock("MTA630MNU",.F.,.F.)
EndIf

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Quintania
@since 05/10/2012
@version 1.0
@return oModel
/*/
//---------------------------------------------------------------------
Static Function ModelDef()
Local oModel                             	
Local oStruCab  := Nil
Local oStruSG2  := Nil
Local oStruSH3R := Nil
Local oStruSH3F := Nil
Local oStruSHJ  := Nil
Local oStruSGR	:= Nil
Local lUniLin	:= SuperGetMV("MV_UNILIN",.F.,.F.)     
Local cAddFields := ""

Default INCLUI := .T.

If ExistBlock("M632ADDFLD")
	cAddFields := ExecBlock("M632ADDFLD",.F.,.F.)
	If ValType(cAddFields) != "C"
		cAddFields := ""
	Else
		If !Empty(cAddFields)
			cAddFields := "|" + cAddFields
		EndIf
	EndIf
EndIf

If lUniLin
	oStruCab := FWFormStruct(1,"SG2",{|cCampo| AllTrim(cCampo) $ "G2_CODIGO|G2_PRODUTO|G2_REFGRD|G2_LINHAPR|G2_TPLINHA"+cAddFields})
	oStruSG2 := FWFormStruct(1,"SG2",{|cCampo| !AllTrim(cCampo) $ "G2_CODIGO|G2_PRODUTO"})
Else	
	oStruCab := FWFormStruct(1,"SG2",{|cCampo| AllTrim(cCampo) $ "G2_CODIGO|G2_PRODUTO|G2_REFGRD"+cAddFields})
	oStruSG2 := FWFormStruct(1,"SG2",{|cCampo| !AllTrim(cCampo) $ "G2_CODIGO|G2_PRODUTO"})
EndIf

oStruSH3R := FWFormStruct(1,"SH3") //-- Define estrutura de dados de recursos alternativos/secundarios
oStruSH3R:RemoveField("H3_FERRAM")
oStruSH3R:RemoveField("H3_DESCFER")

oStruSH3F := FWFormStruct(1,"SH3",{|cCampo| AllTrim(cCampo) == "H3_FERRAM" .Or. AllTrim(cCampo) == "H3_DESCFER" } )

oStruSHJ := FWFormStruct(1,"SHJ") //-- Define estrutura de dados de recursos restritivos (integracao Drummer)

oStruSGR := FWFormStruct(1,"SGR") //-- Define estrutura de dados de cheklist de operacao
oStruSGR:RemoveField("GR_OPERAC")
oStruSGR:RemoveField("GR_DESCOP")

CamposCab(.T.,@oStruCab,oModel) //-- Carrega campos de roteiro similar

oModel:= MPFormModel():New("MATA632",/*Premodel*/,{|oModel| A632PosMod(oModel)},{|oModel|A632Commit(oModel)},/*bCancel*/)

oModel:AddFields("MATA632_CAB",/*cOwner*/,oStruCab)
oModel:AddGrid("MATA632_SG2"  ,"MATA632_CAB",oStruSG2,,{|oModel| A632LinOk(oModel)})
oModel:AddGrid("MATA632_SH3_R","MATA632_SG2",oStruSH3R)
oModel:AddGrid("MATA632_SH3_F","MATA632_SG2",oStruSH3F)
oModel:AddGrid("MATA632_SHJ"  ,"MATA632_SG2",oStruSHJ)
oModel:AddGrid("MATA632_SGR"  ,"MATA632_SG2",oStruSGR)

If !INCLUI .And. Empty(SG2->G2_PRODUTO)
	oModel:SetRelation("MATA632_SG2"  ,{{"G2_FILIAL","xFilial('SG2')"},{"G2_PRODUTO","G2_PRODUTO"},{"G2_REFGRD","G2_REFGRD"},{"G2_CODIGO" ,"G2_CODIGO"}},SG2->(IndexKey(7)))
	oModel:SetRelation("MATA632_SH3_R",{{"H3_FILIAL","xFilial('SH3')"},{"H3_PRODUTO","G2_REFGRD" },{"H3_CODIGO" ,"G2_CODIGO"},{"H3_OPERAC","G2_OPERAC"},{"H3_RECPRIN","G2_RECURSO"}},SH3->(IndexKey(1)))
	oModel:SetRelation("MATA632_SH3_F",{{"H3_FILIAL","xFilial('SH3')"},{"H3_PRODUTO","G2_REFGRD" },{"H3_CODIGO" ,"G2_CODIGO"},{"H3_OPERAC","G2_OPERAC"}},SH3->(IndexKey(1)))
	oModel:SetRelation("MATA632_SHJ"  ,{{"HJ_FILIAL","xFilial('SHJ')"},{"HJ_ROTEIRO","G2_CODIGO" },{"HJ_PRODUTO","G2_REFGRD"},{"HJ_OPERAC","G2_OPERAC"},{"HJ_CTRAB","G2_CTRAB"}/*,{"HJ_RECURSO","G2_RECURSO"}*/},SHJ->(IndexKey(1)))
	oModel:SetRelation("MATA632_SGR"  ,{{"GR_FILIAL","xFilial('SGR')"},{"GR_ROTEIRO","G2_CODIGO" },{"GR_PRODUTO","G2_REFGRD"},{"GR_OPERAC","G2_OPERAC"}},SGR->(IndexKey(1)))
Else	
	oModel:SetRelation("MATA632_SG2"  ,{{"G2_FILIAL","xFilial('SG2')"},{"G2_PRODUTO","G2_PRODUTO"},{"G2_REFGRD","G2_REFGRD"},{"G2_CODIGO" ,"G2_CODIGO" }},SG2->(IndexKey(1)))
	oModel:SetRelation("MATA632_SH3_R",{{"H3_FILIAL","xFilial('SH3')"},{"H3_PRODUTO","G2_PRODUTO"},{"H3_CODIGO" ,"G2_CODIGO" },{"H3_OPERAC","G2_OPERAC"},{"H3_RECPRIN","G2_RECURSO"}},SH3->(IndexKey(1)))
	oModel:SetRelation("MATA632_SH3_F",{{"H3_FILIAL","xFilial('SH3')"},{"H3_PRODUTO","G2_PRODUTO"},{"H3_CODIGO" ,"G2_CODIGO" },{"H3_OPERAC","G2_OPERAC"}},SH3->(IndexKey(1)))
	oModel:SetRelation("MATA632_SHJ"  ,{{"HJ_FILIAL","xFilial('SHJ')"},{"HJ_ROTEIRO","G2_CODIGO" },{"HJ_PRODUTO","G2_PRODUTO"},{"HJ_OPERAC","G2_OPERAC"},{"HJ_CTRAB"  ,"G2_CTRAB"  }/*,{"HJ_RECURSO","G2_RECURSO"}*/},SHJ->(IndexKey(1)))
	oModel:SetRelation("MATA632_SGR"  ,{{"GR_FILIAL","xFilial('SGR')"},{"GR_ROTEIRO","G2_CODIGO" },{"GR_PRODUTO","G2_PRODUTO"},{"GR_OPERAC","G2_OPERAC"}},SGR->(IndexKey(1)))
EndIf

oModel:GetModel("MATA632_CAB"  ):SetDescription(STR0006)
oModel:GetModel("MATA632_SG2"  ):SetDescription(STR0059)
oModel:GetModel("MATA632_SH3_R"):SetDescription(STR0010)
oModel:GetModel("MATA632_SH3_F"):SetDescription(STR0058)
oModel:GetModel("MATA632_SHJ"  ):SetDescription(STR0038)
oModel:GetModel("MATA632_SGR"  ):SetDescription(STR0052)

oModel:GetModel("MATA632_SG2"  ):SetUniqueLine({"G2_OPERAC" })
oModel:GetModel("MATA632_SH3_R"):SetUniqueLine({"H3_RECALTE"})
oModel:GetModel("MATA632_SH3_F"):SetUniqueLine({"H3_FERRAM" })
oModel:GetModel("MATA632_SHJ"  ):SetUniqueLine({"HJ_RECURSO"})
oModel:GetModel("MATA632_SGR"  ):SetUniqueLine({"GR_ITCHK"})

oModel:GetModel("MATA632_SH3_R"):SetOptional(.T.)
oModel:GetModel("MATA632_SH3_F"):SetOptional(.T.)
oModel:GetModel("MATA632_SHJ"  ):SetOptional(.T.)
oModel:GetModel("MATA632_SGR"  ):SetOptional(.T.)

oModel:SetPrimaryKey({})
oModel:GetModel('MATA632_SH3_R'):SetLoadFilter({{'H3_RECALTE',"'"+CriaVar("H3_RECALTE")+"'",2}}) // MVC_LOADFILTER_NOT_EQUAL ----
oModel:GetModel('MATA632_SH3_F'):SetLoadFilter({{'H3_FERRAM' ,"'"+CriaVar("H3_FERRAM")+"'",2}}) // MVC_LOADFILTER_NOT_EQUAL ----

oModel:SetVldActivate({|oModel| A632SetVld(oModel)})
oModel:SetActivate({|oModel| A632SetAct(oModel)})

oModel:GetModel("MATA632_SG2"):SetUseOldGrid()
oModel:GetModel("MATA632_SH3_R"):SetUseOldGrid()
oModel:GetModel("MATA632_SH3_F"):SetUseOldGrid()
oModel:GetModel("MATA632_SHJ"):SetUseOldGrid()
oModel:GetModel("MATA632_SGR"):SetUseOldGrid()

Return oModel

//----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Leonardo Quintania
@since 05/10/2012
@version 1.0
@return oView
/*/
//----------------------------------------------------------------------
Static Function ViewDef()
Local oView 	:= Nil                  
Local oStruCab  := Nil
Local oStruSG2  := Nil
Local oStruSH3R	:= Nil
Local oStruSH3F	:= Nil
Local oStruSHJ	:= Nil
Local oStruSGR	:= Nil
Local oModel	    := FWLoadModel("MATA632")
Local oModelSG2  := oModel:GetModel('MATA632_SG2')
Local oModelSH3R := oModel:GetModel('MATA632_SH3_R')
Local oModelSH3F := oModel:GetModel('MATA632_SH3_F')
Local oStruct1 := FWFormStruct( 1, 'MATA632_SG2', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruct2 := FWFormStruct( 2, 'MATA632_SG2', /*bAvalCampo*/,/*lViewUsado*/ )
Local lUniLin	:= SuperGetMV("MV_UNILIN",.F.,.F.)
Local cAddFields := ""

If ExistBlock("M632ADDFLD")
	cAddFields := ExecBlock("M632ADDFLD",.F.,.F.)
	If ValType(cAddFields) != "C"
		cAddFields := ""
	Else
		If !Empty(cAddFields)
			cAddFields := "|" + cAddFields
		EndIf
	EndIf
EndIf

If lUniLin
	oStruCab := FWFormStruct(2,"SG2",{|cCampo| AllTrim(cCampo) $ "G2_CODIGO|G2_PRODUTO|G2_LINHAPR|G2_TPLINHA"+cAddFields}) 
	oStruSG2 := FWFormStruct(2,"SG2",{|cCampo| !AllTrim(cCampo) $ "G2_CODIGO|G2_PRODUTO"+cAddFields})
Else	
	oStruCab := FWFormStruct(2,"SG2",{|cCampo| AllTrim(cCampo) $ "G2_CODIGO|G2_PRODUTO"+cAddFields})
	oStruSG2 := FWFormStruct(2,"SG2",{|cCampo| !AllTrim(cCampo) $ "G2_CODIGO|G2_PRODUTO|G2_REFGRD"+cAddFields})
EndIf 	                                     

// Novos campos do PCPA124 - Projeto Novo PCP
If oStruSG2:HasField("G2_LISTA")
	oStruSG2:RemoveField("G2_LISTA")
EndIf
// ------------------------------------------

oStruSH3R := FWFormStruct(2,"SH3")
oStruSH3R:RemoveField("H3_FERRAM")
oStruSH3R:RemoveField("H3_DESCFER")

oStruSH3F := FWFormStruct(2,"SH3",{|cCampo| AllTrim(cCampo) == "H3_FERRAM" .Or. AllTrim(cCampo) == "H3_DESCFER"})

CamposCab(.F.,@oStruCab,oModel) //-- Carrega campos de roteiro similar       
	
oView := FWFormView():New()
oView:SetUseCursor(.F.)
oView:SetModel(oModel)
oView:EnableControlBar(.T.)

oView:AddField("HEADER_SG2",oStruCab ,"MATA632_CAB")  
oView:AddGrid ("GRID_SG2",oStruSG2,"MATA632_SG2")
oView:AddGrid ("GRID_SH3_R",oStruSH3R,"MATA632_SH3_R")
oView:AddGrid ("GRID_SH3_F",oStruSH3F,"MATA632_SH3_F")

If INCLUI
	oView:CreateHorizontalBox("CABEC",18)
	oView:CreateHorizontalBox("MEIO",52)
	oView:CreateHorizontalBox("INFERIOR",30)
Else 
    oView:CreateHorizontalBox("CABEC",10)
	oView:CreateHorizontalBox("MEIO",60)
	oView:CreateHorizontalBox("INFERIOR",30)
EndIf
	

// Cria Folder na view
oView:CreateFolder("PASTAS","INFERIOR")

// Cria pastas nas folders
oView:AddSheet("PASTAS","ABA01",STR0010) //-- Recursos Alternativos / Secundários
oView:AddSheet("PASTAS","ABA02",STR0058) //-- Ferramentas Alternativas
                   
// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("ABAS1",100,,,"PASTAS","ABA01")
oView:CreateHorizontalBox("ABAS2",100,,,"PASTAS","ABA02")

oView:SetOwnerView("HEADER_SG2","CABEC")
oView:SetOwnerView("GRID_SG2"  ,"MEIO" )
oView:SetOwnerView("GRID_SH3_R","ABAS1")
oView:SetOwnerView("GRID_SH3_F","ABAS2")

If SuperGetMV("MV_CHKOPER",.F.,.F.)
	oStruSGR := FWFormStruct(2,"SGR")
	oStruSGR:RemoveField("GR_OPERAC")
	oStruSGR:RemoveField("GR_DESCOP")
	oView:AddGrid("GRID_SGR",oStruSGR,"MATA632_SGR")
	oView:AddSheet("PASTAS","ABA03",STR0052) //-- CheckList
	oView:CreateHorizontalBox("ABAS3",100,,,"PASTAS","ABA03")
	oView:SetOwnerView("GRID_SGR","ABAS3")
EndIf

If TipoAps(.F.,"DRUMMER") 
	oStruSHJ := FWFormStruct(2,"SHJ")
	oView:AddGrid("GRID_SHJ",oStruSHJ,"MATA632_SHJ")
	oView:AddSheet("PASTAS","ABA04",STR0038) //-- Recursos Restritivos do Centro de Trabalho
	oView:CreateHorizontalBox("ABAS4",100,,,"PASTAS","ABA04")
	oView:SetOwnerView("GRID_SHJ","ABAS4")
EndIf

//-- Botao para exportar dados para EXCEL
If RemoteType() == 1
	oView:AddUserButton(PmsBExcel()[3],PmsBExcel()[1],{|| DlgToExcel({; 
									{"CABECALHO",STR0006,{STR0007,STR0008},{FwFldGet("G2_CODIGO"),FwFldGet("G2_PRODUTO")}},;
									{"GETDADOS",STR0036,oModelSG2:aHeader,oModelSG2:aCols},;
									{"GETDADOS",STR0010,oModelSH3R:aHeader,oModelSH3R:aCols},;
									{"GETDADOS",STR0058,oModelSH3F:aHeader,oModelSH3F:aCols}})},;
									PmsBExcel()[2])
EndIf              
Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} A632LinOk(oModel)
Valida linha da grid principal da operacao preenchida.
@author Leonardo Quintania
@since 05/10/2012
@version 1.0
@return lRet ( Continua )
/*/
//---------------------------------------------------------------------
Static Function A632LinOk(oModel)
Local aArea    := GetArea()
Local aRecno   := {}
Local cAlias   := GetNextAlias()
Local cOperNew := FwFldGet("G2_OPERAC")
Local cOperOld := ''
Local lIntSfc  := FindFunction( 'ExisteSFC' ) .And. ExisteSFC("SG2") .And. !IsInCallStack("AUTO650")
Local lRet     := .T.
Local nI       := 0
Local nOpc     := oModel:GetOperation()
       
If !oModel:IsDeleted()
	If Empty(FwFldGet("G2_TEMPAD"))
		Help(" ",1,"A630SEMTMP")
		lRet := .F.			
	EndIf
	If lRet .And. Empty(cOperNew)
		Help(" ",1,"A630VZ")
		lRet := .F.			
	EndIf
	If lRet .And. Empty(FwFldGet("G2_TEMPSOB"))
		If !Empty(FwFldGet("G2_TPSOBRE"))
			If FwFldGet("G2_TPSOBRE") != "1" .Or. (FwFldGet("G2_TPSOBRE") == "1" .And. SuperGetMV("MV_APS",.F.,"") == "TOTVS")
				Help(" ",1,"A630TIPSOB")
				lRet := .F.
			EndIf
		EndIf		
	EndIf
	If lRet .And. Empty(FwFldGet("G2_TPSOBRE"))
		If !Empty( FwFldGet("G2_TEMPSOB"))
			Help(" ",1,"A630TMPSOB")
			lRet := .F.
		EndIf			
	EndIf
	If lRet .And. Empty(FwFldGet("G2_TEMPDES"))
		If !Empty( FwFldGet("G2_TPDESD"))
			Help(" ",1,"A630TIPDES")
			lRet := .F.
		EndIf			
	EndIf
	If lRet .And. Empty(FwFldGet("G2_TPDESD"))
		If !Empty( FwFldGet("G2_TEMPDES"))
			Help(" ",1,"A630TMPDES")
			lRet := .F.
		EndIf			
	EndIf
	If lRet .And. (TipoAps(.F.,"DRUMMER") .Or. SuperGetMV("MV_APS",.F.,"") == "TOTVS" .Or. IntegraSFC()) .And. Empty(oModel:GetValue("G2_CTRAB"))
		Help(" ",1,"OBRIGAT2",,RetTitle("G2_CTRAB"),04,01)
		lRet := .F.
	EndIf
		
	If lRet .And. !Empty(FwFldGet("G2_DTINI")) .And. !Empty(FwFldGet("G2_DTFIM")) ;
           .And. FwFldGet("G2_DTINI") > FwFldGet("G2_DTFIM")
		Help( ,, 'Help',, STR0072, 1, 0 ) //"Data de validade inicial não pode ser maior que a data de validade final."
		lRet := .F.
	EndIf
	
	if nOpc == 4
		if oModel:IsUpdated()
			BeginSql Alias cAlias
			    	
				SELECT * FROM %Table:SG2% SG2
					WHERE SG2.G2_FILIAL=%xFilial:SG2% AND 
						  SG2.R_E_C_N_O_=%Exp:oModel:ADATAMODEL[oModel:GetLine()][4]%
			EndSql
			
			While (cAlias)->(!EOF())
				cOperOld := (cAlias)->G2_OPERAC
			
				dbSelectArea('SGF')
				SGF->(dbSetOrder(1))
				IF SGF->(dbSeek(xFilial('SGF')+FwFldGet("G2_PRODUTO")+FwFldGet("G2_CODIGO")+(cAlias)->G2_OPERAC))
					While SGF->(!EOF()) .AND. SGF->GF_FILIAL == xFilial('SGF') .AND. SGF->GF_PRODUTO == (cAlias)->G2_PRODUTO .AND.;
					                          SGF->GF_ROTEIRO == (cAlias)->G2_CODIGO .AND. SGF->GF_OPERAC == (cAlias)->G2_OPERAC
					                          
						aadd(aRecno,SGF->(RecNo()))
					                          
						SGF->(dbSkip())
					End
				Endif
			
				Exit
			End
			
			(cAlias)->(dbCloseArea())
			
			For nI := 1 to Len(aRecno)
				SGF->(dbGoTo(aRecno[nI]))
				
				RecLock('SGF',.F.)
						
				SGF->GF_OPERAC := cOperNew
				
				SGF->(MsUnLock())
			Next
		Endif
	Endif
		
	if lIntSfc .AND. (nOpc == 3 .OR. nOpc == 4)
		// Validar se a máquina informado pertence ao CT da operação
		if ALLTRIM(POSICIONE('SH1',1,xFilial('SH1')+oModel:GetValue('G2_RECURSO'),'H1_CTRAB')) != ALLTRIM(oModel:GetValue("G2_CTRAB"))
			Help(" ",1,"A632RECCT")
	
			lRet := .F.
		Endif
		
		// Validar se foi informado roteiro alternativo
		if !Empty(oModel:GetValue("G2_ROTALT"))
			Help(" ",1,"MATA632_SFCRTA")
		
			lRet := .F.
		Endif
	Endif
Else
	//-- Valida se a operacao podera ser deletada
	lRet := A630ValDel(oModel:GetValue("G2_PRODUTO"),oModel:GetValue("G2_CODIGO"))
EndIf

RestArea(aArea)

Return lRet             

//---------------------------------------------------------------------
/*/{Protheus.doc} A632PosMod()
Pos validacao de estrutura
@author Leonardo Quintania
@since 29/12/2011
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function A632PosMod(oModel)
	Local lRet			:= .T.  
	Local aSaveLines	:= FWSaveRows(oModel)
	Local aArea		:= GetArea()
	Local cProduto	:= FwFldGet("G2_PRODUTO")
	Local oGridSG2	:= oModel:GetModel("MATA632_SG2")
	Local oGridSH3	:= oModel:GetModel('MATA632_SH3_R')
	Local cRoteiro	:= FwFldGet("G2_CODIGO")
	Local lIntSfc   := FindFunction('ExisteSFC') .And. ExisteSFC("SG2") .And. !IsInCallStack("AUTO650")
	Local nI        := 0
	Local nJ        := 0
	Local nOpc      := oModel:GetOperation()
	Local lIntgMES := PCPIntgPPI()
	Local lOpOrd   := SuperGetMV("MV_APS",.F.,"") == "TOTVS" .Or. lIntSFC .OR. SuperGetMV("MV_PCPATOR",.F.,.F.) == .T.

	Private cTipoTemp := GetMV("MV_TPHR") //Usada na A690HoraCt

	IF nOpc == 5 //Validação de exclusão do roteiro.
		If !a632VldDel(cProduto, cRoteiro)
			Help( ,, 'Help',, STR0085, 1, 0 ) //"Este roteiro está associado a Ordens de Produção e não pode ser excluído."
			lRet := .F.
		EndIf
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacoes do Quality³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. IntQIP(cProduto) .And. nOpc == 5
		lRet := QIPValDOpr(cProduto,cRoteiro,NIL,oGridSG2:Length(.T.))
	EndIf
	
	IF lIntSfc .AND. (nOpc == 3 .OR. nOpc == 4)
			
		// Validar os recursos alternativos e secundários. Devem possuir o mesmo CT da operação.
		For nI := 1 to oGridSG2:GetQtdLine()
			oGridSG2:GoLine(nI)
			
			if !oGridSG2:IsDeleted()
			
				For nJ := 1 to oGridSH3:GetQtdLine() 
					oGridSH3:GoLine(nJ)
				
					if !oGridSH3:IsDeleted() .AND. !Empty(oGridSH3:GetValue('H3_RECALTE'))
						if ALLTRIM(POSICIONE('SH1',1,xFilial('SH1')+oGridSH3:GetValue('H3_RECALTE'),'H1_CTRAB')) != ALLTRIM(oGridSG2:GetValue("G2_CTRAB"))
							Help(" ",1,"A632RECALTCT")
						
							lRet := .F.
							Exit
						Endif
					Endif
				Next
			Endif
		Next
	Endif
		
	If lRet .And. nOpc == 5 //Se for exclusão, já realiza a integração.
		If lIntgMES
			If !MATA632PPI(, AllTrim(cRoteiro)+"+"+AllTrim(cProduto), .T., .T., .T.)
				MSGINFO(STR0082 + AllTrim(oModel:GetValue("MATA632_CAB","G2_CODIGO")) + STR0083,"MATA632")
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
	FWRestRows(aSaveLines)
Return lRet
//---------------------------------------------------------------------
/*Apresenta um grid com todas OPs abertas para seleção do que será
ou não regerada operações do roteiro*/
//---------------------------------------------------------------------
Static Function GridOPAbertas(aOPs,cProduto,cRoteiro,oGridSG2)
	Local oDlgUpd, nI, oBtnCancelar, oBtnAvanca, oTexto, oBtnDetalhar, oList, oCheckBoxOP, oPanel3
	Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
	Local oNOk		:= LoadBitmap( GetResources(), "LBNO" )
	Local aOPGrid 	:= {}
	
	Public lToggleCheckBoxOP
		
	For nI := 1 To Len(aOPs)
		aAdd(aOPGrid,{.T.,AllTrim(aOPs[nI][1]),AllTrim(POSICIONE("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC")),AllTrim(cRoteiro),aOPs[nI][3],aOPs[nI][2]})
	Next
	
	If ExistBlock("M632GOPABR")
		If ExecBlock("M632GOPABR",.F.,.F.)
			GeraOperac(aOPGrid,cProduto,cRoteiro)
		EndIf
	Else
		If !__lAutomacao
			DEFINE DIALOG oDlgUpd TITLE STR0064 FROM 0, 0 TO 22, 75 SIZE 550, 350 PIXEL//"Ordens de Produção do Roteiro Alterado"
		
			@ 005,005 GET oTexto VAR (STR0071 + " " + AllTrim(Str(Len(aOPs))) + " " + STR0066) OF oDlgUpd MEMO PIXEL SIZE 270,20 NO BORDER //"Este roteiro possui x ordens de produção com situação ''Em Aberto'' associadas. Selecione as ordens de produção que deverão ser atualizadas?"
			oTexto:lReadOnly := .T.
	
			oPanel3 := TPanel():New( 25, 05, ,oDlgUpd, , , , , , 270, 120, .F.,.T. )	
	
			oList := TWBrowse():New( 05, 05, 260, 110,,{"",STR0067,STR0008,STR0006,STR0068},,oPanel3,,,,,,,,,,,,.F.,,.T.,,.F.,,,)//"Ordens de Produção","Produto","Roteiro de Operações","Data Entrega"
	
			@ 8, 6 CHECKBOX oCheckBoxOP VAR lToggleCheckBoxOP PROMPT "" WHEN PIXEL OF oPanel3 SIZE 015,015 MESSAGE ""
			oCheckBoxOP:bChange := {|| MarcaTodos(oList, lToggleCheckBoxOP)}
			lToggleCheckBoxOP := .T.	
	
			oList:SetArray(aOPGrid)
			oList:bLine := {|| {If(aOPGrid[oList:nAT,1],oOk,oNOK),aOPGrid[oList:nAt,2],aOPGrid[oList:nAT,3],aOPGrid[oList:nAT,4],aOPGrid[oList:nAT,5]}}
			oList:bLDblClick := {|| aOPGrid[oList:nAt,1] := !aOPGrid[oList:nAt,1], controlCheckAllState(oCheckBoxOP, aOPGrid)}
	
			@ 155,005 BUTTON oBtnDetalhar PROMPT STR0070 SIZE 60,14 ACTION AbreA650b(aOPGrid,oList) OF oDlgUpd PIXEL//"Detalhar"
			@ 155,140 BUTTON oBtnCancelar PROMPT STR0024 SIZE 60,14 ACTION oDlgUpd:End() OF oDlgUpd PIXEL//"Cancelar"
			@ 155,210 BUTTON oBtnAvanca   PROMPT STR0069 SIZE 60,14 ACTION {|| GeraOperac(aOPGrid,cProduto,cRoteiro),oDlgUpd:End()} OF oDlgUpd PIXEL//"Confirmar"
	
			ACTIVATE DIALOG oDlgUpd CENTER
		EndIf
	EndIf
Return Nil
//--------------------------------------------------------------
Static Function GeraOperac(aOPGrid,cProduto,cRoteiro)
	Local lIntSFC := FindFunction('ExisteSFC') .And. ExisteSFC("SC2") .And. !IsInCallStack("AUTO650")
	Local lProces := SuperGetMV("MV_APS",.F.,"") == "TOTVS" .Or. lIntSFC .OR. SuperGetMV("MV_PCPATOR",.F.,.F.) == .T. 
	Local nI
	Local lRet
	Local lIntegPPI   := PCPIntgPPI()
	Local cMsg := ""
	Local cNameFile := "OPER-" + Dtos(Date()) + ".log"

	Private _lErrSFC := .F.
	Private _nHndSFC := FCreate(cNameFile)
	Private aIntegPPI := {}
	
	dbSelectArea("SC2")
	SC2->(dbSetOrder(1))
	For nI := 1 To Len(aOPGrid)
		//Se a ordem de produção tiver sido marcada
		If  aOPGrid[nI][1]
			SC2->(dbSeek(xFilial("SC2")+aOPGrid[nI][2]))
			lRet := .T.
			Begin Transaction
				// Atualizar operações do SD4
				dbSelectArea('SD4')
				SD4->(dbSetOrder(2))
				If SD4->(dbSeek(xFilial('SD4')+Padr(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),Tamsx3('D4_OP')[1])))
					While SD4->(!EOF()) .AND. SD4->D4_OP == Padr(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),Tamsx3('D4_OP')[1])
						dbSelectArea('SGF')
						SGF->(dbSetOrder(2))
						if SGF->(dbSeek(xFilial('SGF')+SC2->C2_PRODUTO+cRoteiro+SD4->D4_COD+SD4->D4_TRT))
							RecLock('SD4',.F.)
							SD4->D4_ROTEIRO := cRoteiro
							SD4->D4_OPERAC  := SGF->GF_OPERAC
							SD4->(MsUnLock())
						Else
							RecLock('SD4',.F.)
							SD4->D4_ROTEIRO := ''
							SD4->D4_OPERAC  := ''
							SD4->(MsUnLock())
						Endif
					
						SD4->(dbSkip())
					End						
				Endif
				
				If lProces
					SC2->(TAPSOperac(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD,cProduto,cRoteiro,C2_QUANT))
				
					If lIntSFC
						lRet = A650IntSFC(4,2) //Evento 2 - Geracao das Operacoes
						lRet = A650IntSFC(4,3) //Evento 3 - Geracao das necessidades
					Endif
				EndIf

				If !lRet
					DisarmTransaction()
				EndIf
			End Transaction
			//Integração PCFactory
			If lIntegPPI
				mata650PPI( , , .T., .T., .F.)
			EndIf
		EndIf
	Next
	
	//Se ocorreram erros na integração com o PCFactory, exibe quais foram as ordens em que ocorreu erro.
	If lIntegPPI .And. Len(aIntegPPI) > 0
		cMsg := STR0076 + CHR(10) //"Ocorreram erros na integração com o TOTVS MES."
		For nI := 1 To Len(aIntegPPI)
			cMsg += STR0077 + AllTrim(aIntegPPI[nI,1]) + " - " + AllTrim(aIntegPPI[nI,2]) + CHR(10) //"OP: "
		Next nI
		Aviso(STR0078,cMsg,{"Ok"},3) //"ERRO"
	EndIf
	
	If _lErrSFC
		FClose(_nHndSFC)
		Alert(STR0079 + cNameFile + STR0080) // "Algumas das ordens geradas no SIGASFC(Chão de Fábrica) não possuem operação reportada e portanto foi trocado o parametro das ordens para reporte por operação. Um log(" ##
	EndIf
	
Return Nil
//---------------------------------------------------------------------
/* A função terá comportamento de toggle se o lFixedBool não foi informado.*/
Static Function MarcaTodos( oBrw, lFixedBool )

	Local bSeek := {|x| x[1] == .F. }
	Local lSet  := .F.
	
	Default lFixedBool := Nil
	
	If lFixedBool != Nil
		lSet := lFixedBool
	ElseIf aScan(@oBrw:aArray, bSeek) > 0
		lSet := .T.
	EndIf
	
	If !__lAutomacao
		aEval(@oBrw:aArray, {|x| x[1] := lSet})
		oBrw:Refresh()
	EndIf

Return NIL
//---------------------------------------------------------------------
/* Controladora do estado de checkbox */
Static Function controlCheckAllState(oCheckBox,aArray)
	
	Local bSeek := {|x| x[1] == .F. }
		
	If !__lAutomacao
		@lToggleCheckBoxOP := If(aScan(aArray, bSeek) > 0, .F., .T.)
		oCheckBox:Refresh()
	EndIf
	
Return Nil
//---------------------------------------------------------------------
/*Abre View do programa MATA650b para visualizar os detalhes da OP
apartir de seleção do grid da função GridOPAbertas*/
//---------------------------------------------------------------------
Static Function AbreA650b(aOPGrid,oList)
	dbSelectArea("SC2")
	SC2->(dbSetOrder(1))
	If !__lAutomacao
		SC2->(dbSeek(xFilial("SC2") + aOPGrid[oList:nAT,2]))
		ViA650b()
	EndIf
Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} A632Commit()
Atualiza o valor da primeira linha do Grid
@author Leonardo Quintania
@since 29/12/2011
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function A632Commit(oModel)
	Local nOperation	:= oModel:GetOperation()      
	Local aSaveLines	:= FWSaveRows(oModel)   
	Local cProduto		:= oModel:GetValue("MATA632_CAB","G2_PRODUTO")
	Local cCodigo		:= oModel:GetValue("MATA632_CAB","G2_CODIGO")
	Local nX			:= 0
	Local lQipMat		:= IntQIP(FwFldGet("G2_PRODUTO")) // Indica a Integracao com o Inspecao de Processos (SIGAQIP)
	Local lRefer		:= .F.
	Local aDelQQK 		:= {}
	Local oGridSG2		:= oModel:GetModel("MATA632_SG2")
	Local lIntSFC		:= FindFunction('ExisteSFC') .And. ExisteSFC("SC2") .And. !IsInCallStack("AUTO650")
	Local lProces		:= SuperGetMV("MV_APS",.F.,"") == "TOTVS" .Or. lIntSFC .OR. SuperGetMV("MV_PCPATOR",.F.,.F.) == .T. .Or. PCPIntgPPI()
	Local aOPs			:= {}
	Local aArea       := SG2->(GetArea())
	Local cSC2OP
	Local lMovInt,lMovProd,lOPAberta,lOPPrevis
	Local lIntgMES := PCPIntgPPI()
	Local lRet     := .T.

	//-- Se referencia de grade, troca produto com referencia
	If (nOperation == 3 .Or. nOperation == 4) .And. (lRefer := MatGrdPrrf(@cProduto,.T.) .And. AllTrim(FwFldGet("G2_PRODUTO")) == AllTrim(cProduto))
		For nX := 1 To oModel:GetModel("MATA632_SG2"):Length()
			oModel:GetModel("MATA632_SG2"):GoLine(nX)
			oModel:LoadValue("MATA632_CAB","G2_REFGRD",PadR(cProduto,TamSX3("G2_REFGRD")[1]))
		Next nX
		oModel:LoadValue("MATA632_CAB","G2_PRODUTO",CriaVar("G2_PRODUTO",.F.))		
	Else
		cProduto := oModel:GetValue("MATA632_CAB","G2_PRODUTO")
	EndIf
	
	BeginTran()
		If FWFormCommit(oModel)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inclusao ou Alteração da Integracao PCP x QIP			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOperation == 4
				For nX := 1 To oModel:GetModel("MATA632_SG2"):Length()
					oModel:GetModel("MATA632_SG2"):GoLine(nX)
					If oModel:GetModel("MATA632_SG2"):IsDeleted()
						AADD(aDelQQK, {oModel:GetValue("MATA632_CAB","G2_CODIGO"), oModel:GetValue("MATA632_SG2","G2_OPERAC")})
					EndIf
				Next nX
			EndIf
	
			If lQipMat .And. (nOperation == 3 .Or. nOperation == 4)
				QAtuMatQIP(cProduto,Nil,FwFldGet("G2_CODIGO"),"PCP",Nil,"1",Nil,aDelQQK)
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclusao da Integracao PCP x QIP						 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lQipMat .And. nOperation == 5
				QAtuMatQIP(cProduto,,FwFldGet("G2_CODIGO"),"PCP",.T.)
			EndIf
	
			//-- Atualizacao do campo B1_OPERPAD
			If nOperation == 3 .And. SuperGetMV("MV_G2ATUB1",.F.,.F.)
				If lRefer
					cProduto := AllTrim(cProduto) //-- Remove brancos para atualizar todos os itens da referencia
				EndIf
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+cProduto))
				While !SB1->(EOF()) .And. SB1->(B1_FILIAL+PadR(B1_COD,Len(cProduto))) == xFilial("SB1")+cProduto
					RecLock("SB1",.F.)
					SB1->B1_OPERPAD := FwFldGet("G2_CODIGO")
					SB1->(MsUnLock())
	
					SB1->(dbSkip())
				End
			EndIf
	
			//Verifica operações
			If (nOperation == 4 .Or. nOperation == 5) .And. (SD4->(FieldPos('D4_ROTEIRO')) > 0 .OR. SD4->(FieldPos('D4_ROTEIRO')) == 0 .AND. lProces)
				dbSelectArea("SC2")
				SC2->(dbSetOrder(11))
				dbSelectArea("SD3")
				SD3->(DbSetOrder(1))
				dbSelectArea("SH6")
				SH6->(DbSetOrder(1))
				//Verifica se possui OPs com situação das regras abaixo.
				If SC2->(dbSeek( xFilial("SC2")+cProduto+cCodigo))
			   		While SC2->( !EOF() ) .AND. SC2->C2_FILIAL == xFilial( "SC2" ) .AND. SC2->C2_PRODUTO == cProduto .AND. SC2->C2_ROTEIRO == cCodigo
			   			//Atribui as informações do indice na variavel
						cSC2OP := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
	
						//Verifica as movimentações de produção da OP
						lMovProd	:= (SH6->(MsSeek(xFilial('SH6')+cSC2OP)))
						//Verifica se a OP esta aberta
						lOPAberta	:= (SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (Max(dDataBase - SC2->C2_DATPRI,0) < If(SC2->C2_DIASOCI==0,1,SC2->C2_DIASOCI)))
						//Verifica se a OP esta prevista
						lOPPrevis	:= SC2->C2_TPOP == "P"
	
						If !lMovProd .And. (lOPAberta .OR. lOPPrevis)
	
							//Verifica as movimentações internas da OP
							lMovInt := .F.
							If(SD3->(dbSeek(xFilial('SD3')+cSC2OP)))
								While SD3->( !EOF() ) .And. xFilial("SD3")+SD3->D3_OP  == xFilial('SD3')+cSC2OP
									If SD3->D3_ESTORNO != 'S'
										lMovInt := .T.
										Exit
									EndIf
									SD3->(dbSkip())
								End
							EndIf
	
							//Se não houver movimentações internas, de produção e a OP estiver aberta adiciona no Array
							If !lMovInt
								aAdd(aOPs,{cSC2OP,SC2->C2_QUANT,SC2->C2_DATPRF})
							EndIf
	
						EndIf
	
						SC2->(dbSkip())
			   		End
				EndIf
			EndIf
			//Integração Totvs MES
			If lIntgMES .And. nOperation != 5 //A exclusão é processada na pós validação do model.
				lRet := MATA632PPI(, AllTrim(oModel:GetValue("MATA632_CAB","G2_CODIGO"))+"+"+AllTrim(oModel:GetValue("MATA632_CAB","G2_PRODUTO")), .F., .T., .T.)
				If !lRet
					lRet := .T.
					Help( ,, 'Help',, STR0082 + AllTrim(oModel:GetValue("MATA632_CAB","G2_CODIGO")) + STR0083, 1, 0 ) //"Não foi possível realizar a integração com o TOTVS MES para o roteiro 'XX'. Foi gerada uma pendência de integração para este roteiro."
				EndIf
			EndIf
			
			//Se encontrou alguma OP apresenta Grid
			If lRet .And. Len(aOPs) > 0
				aArea := SG2->(GetArea())
				GridOPAbertas(aOPs,cProduto,cCodigo,oGridSG2)
				
				RestArea(aArea)
			EndIf
	
		EndIf
	EndTran()
	//SG2->(RestArea(aArea))

	FWRestRows(aSaveLines)
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A632VldPrd()
Valida produto digitado quando nao referencia de grade
@author TOTVS S/A
@since 29/12/2011
@version 1.0
/*/
//---------------------------------------------------------------------
Function A632VldPrd()
Local lRet     	:= .T.
Local oModel   	:= FWModelActive()
Local cRefGrd		:= oModel:GetValue("MATA632_CAB","G2_PRODUTO")
Local aSaveArea 	:= GetArea()

If A093IsGrade(cRefGrd) .And. AllTrim(cRefGrd) == AllTrim(A093VldBase(cRefGrd)) .And. Aviso(STR0045,STR0046,{STR0047,STR0048}) == 2 //O código digitado é referência de uma família de produtos. Deseja cadastrar para qual entidade?
	A093Prod()
EndIf

If MatGrdPrrf(@cRefGrd) .And. AllTrim(cRefGrd) == AllTrim(oModel:GetValue("MATA632_CAB","G2_PRODUTO"))
	lRet := ExistChav("SG2",PadR(cRefGrd,TamSX3("G2_REFGRD")[1])+FwFldGet("G2_CODIGO"),7)
Else
	lRet := Vazio() .Or. ExistCpo("SB1")
EndIf

If SG2->(dbSeek(xFilial("SG2")+FwFldGet("G2_PRODUTO")+FwFldGet("G2_CODIGO")))
	Help(" ",1,"JAGRAVADO")
	lRet:= .F.
EndIf

//Se a variável private não tiver sido declarada, atribui padrão .F.
lBrowse := If(Type("lBrowse")=="U", .F., lBrowse)

If lBrowse .And. FindFunction('IsProdProt') .And. IsProdProt(FwFldGet("G2_PRODUTO"))
	lRet := .F.
	Help(" ",1,"ISPRODPROT") //-- Este produto é um protótipo e de uso reservado do módulo Desenvolvedor de Produtos (DPR).
EndIf

//-- Gatilha descricao
If lRet
	oModel:LoadValue("MATA632_CAB","CDESCPROD",PadR(A632IniDes(cRefGrd,.T.),TamSX3("B1_DESC")[1]))
EndIf

RestArea(aSaveArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A632Recur()
Realiza busca no cadastro de Recurso alternativo e verifica se existe alguma ocorrencia do mesmo recurso.
@author TOTVS S/A
@since 29/12/2011
@version 1.0
/*/
//---------------------------------------------------------------------
Function A632Recur()
Local oModel	:= FWModelActive()
Local oGridSH3	:= oModel:GetModel("MATA632_SH3_R")
Local nX		:= 0
Local lRet		:= .T.
Local aSaveLines:= FWSaveRows(oModel) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Recurso Principal j  foi cadastrado como Alternativo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To oGridSH3:Length(.T.)
	oGridSH3:GoLine(nX) 
	If FwFldGet("G2_RECURSO") == oGridSH3:GetValue("H3_RECALTE") 
		If oGridSH3:GetValue("H3_TIPO") == "S"
			Help(" ",1,"A630JAS")
		Else
			Help(" ",1,"A630JAA")
		EndIf
		lRet:=.F.
		Exit
	EndIf
Next nX

FWRestRows(aSaveLines)
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A632RecAlt()
Verifica se Recurso Alternativo j  foi cadastrado como Principal.
@author TOTVS S/A
@since 29/12/2011
@version 1.0
/*/
//---------------------------------------------------------------------
Function A632RecAlt()
Local oModel	:= FWModelActive()
Local oGridSG2	:= oModel:GetModel("MATA632_SG2")
Local oGridSH3	:= oModel:GetModel("MATA632_SH3_R")
Local nX		:= 0
Local lRet		:= .T.
Local aSaveLines:= FWSaveRows(oModel) 
Local OperAtu   := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Recurso Alternativo j  foi cadastrado como Principal.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OperAtu := oGridSG2:GetValue("G2_OPERAC")

For nX := 1 To oGridSH3:Length(.T.)
	oGridSH3:GoLine(nX) 
	If FwFldGet("H3_RECALTE") == oGridSG2:GetValue("G2_RECURSO") .And. OperAtu == oGridSG2:GetValue("G2_OPERAC")  
		If oGridSH3:GetValue("H3_TIPO") == "S"
			Help(" ",1,"A630JAS")
		Else
			Help(" ",1,"A630JAA")
		EndIf
			lRet:=.F.
		Exit
	EndIf
Next nX 


FWRestRows(aSaveLines)

//-- Inicializa descricao do recurso
If !__lAutomacao
	If lRet
		oGridSH3:SetValue("H3_DESC",PadR(Posicione("SH1",1,xFilial("SH1")+FwFldGet("H3_RECALTE"),"H1_DESCRI"),TamSX3("H3_DESC")[1]))
	EndIf
EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A632Ferram()
Efetua validações da ferramenta informada
@author TOTVS S/A
@since 29/12/2011
@version 1.0
/*/
//---------------------------------------------------------------------
Function A632Ferram()
Local oModel	:= FWModelActive()
Local oGridSH3	:= oModel:GetModel("MATA632_SH3_F")
Local nX		:= 0
Local lRet		:= .T.
Local aSaveLines:= FWSaveRows(oModel) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Ferramenta Principal j  foi cadastrada como Alternativa.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To oGridSH3:Length(.T.)
	oGridSH3:GoLine(nX)
	If !Empty(oGridSH3:GetValue("H3_FERRAM")) .And. FwFldGet("G2_FERRAM") == oGridSH3:GetValue("H3_FERRAM") 
		Help(" ",1,"A630FERJA")
		lRet:=.F.
		Exit
	EndIf
Next nX

FWRestRows(aSaveLines)
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A632FerAlt()
Efetua validações da ferramenta informada
@author TOTVS S/A
@since 29/12/2011
@version 1.0
/*/
//---------------------------------------------------------------------
Function A632FerAlt()
Local oModel	:= FWModelActive()
Local oGridSG2	:= oModel:GetModel("MATA632_SG2")
Local oGridSH3	:= oModel:GetModel("MATA632_SH3_F")
Local nX		:= 0
Local lRet		:= .T.
Local aSaveLines:= FWSaveRows(oModel) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Ferramenta Principal j  foi cadastrada como Alternativa.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To oGridSG2:Length(.T.)
	oGridSG2:GoLine(nX)
	If FwFldGet("H3_FERRAM") == oGridSG2:GetValue("G2_FERRAM") 
		Help(" ",1,"A630FERJA")
		lRet:=.F.
		Exit
	EndIf
Next nX

FWRestRows(aSaveLines)

//-- Inicializa descricao da ferramenta
If lRet
	oGridSH3:SetValue("H3_DESCFER",PadR(Posicione("SH4",1,xFilial("SH4")+FwFldGet("H3_FERRAM"),"H4_DESCRI"),TamSX3("H3_DESCFER")[1]))
EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A632TPFer()
Valida campo que define o tipo de alocacao da ferramenta
@author TOTVS S/A
@since 29/12/2011
@version 1.0
/*/
//---------------------------------------------------------------------
Function A632TPFer()
Local lRet := .T.

If Empty(FwFldGet("G2_FERRAM"))
	If !IsBlind()
		Help(" ",1,"VAZIO",,STR0035,1) //"O campo ferramenta nao foi informado"
	EndIf
	lRet := .F.
EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A632TpLin()
Valida campo G2_TPLINHA
@author TOTVS S/A
@since 29/12/2011
@version 1.0
/*/
//---------------------------------------------------------------------
Function A632TpLin()
Local lRet	 := .T.
Local oModel := FWModelActive()
Local oModSG2:= oModel:GetModel("MATA632_SG2")

If FwFldGet("G2_TPLINHA") == "D"
	If !SuperGetMV("MV_UNILIN",.F.,.F.) .And. oModSG2:nLine # 1
		If Empty(oModSG2:GetValue("G2_LINHAPR",oModSG2:nLine - 1))
			Help(" ",1,"A630TPLIND")
			lRet := .F.
		Else
			oModSG2:SetValue("G2_LINHAPR",oModSG2:GetValue("G2_LINHAPR",oModSG2:nLine - 1))
		EndIf
	ElseIf Empty(FwFldGet("G2_LINHAPR"))
		Help(" ",1,"A630TPLINO")
		lRet := .F.
	EndIf
ElseIf FwFldGet("G2_TPLINHA") $ "OP"
	If Empty(FwFldGet("G2_LINHAPR"))
		Help(" ",1,"A630TPLINO")
		lRet := .F.
	EndIf
EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A632SetAct()
Bloco executado ao iniciar o formulario MVC para 
alteracao, exclusao e visualizacao quando possui grade de produtos
@author TOTVS S/A
@since 07/12/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function A632SetAct(oModel)
Local oCab		:= oModel:GetModel("MATA632_CAB")
Local nOperation:= oModel:GetOperation()  
Local lRet 		:= .T.

If nOperation # 3 .And. Empty(oCab:GetValue("G2_PRODUTO")) .And. nOperation # 5
	oCab:LoadValue("G2_PRODUTO",PadR(SG2->G2_REFGRD,TamSX3("G2_PRODUTO")[1]))
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CamposCab()
Monta estrutura de campo para modelo e view.
@author Leonardo Quintania
@since 29/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CamposCab(lModel,oStru,oModel)

Default INCLUI := .T.

If lModel //-- Instancia de modelo
	//-- Campo descricao produto
	oStru:AddField(RetTitle("B1_DESC") ,;	// [01]  C   Titulo do campo  - Produto
					RetTitle("B1_DESC")	,;	// [02]  C   ToolTip do campo - Código do Produto
					"CDESCPROD"		   	,;	// [03]  C   Id do Field
					"C"						,;	// [04]  C   Tipo do campo
					TamSX3("B1_DESC")[1]	,;	// [05]  N   Tamanho do campo
					0						,;	// [06]  N   Decimal do campo
					NIL						,;	// [07]  B   Code-block de validação do campo
					NIL				   		,;	// [08]  B   Code-block de validação When do campo
					NIL						,; 	// [09]  A   Lista de valores permitido do campo
					.F.						,; 	// [10]  L   Indica se o campo tem preenchimento obrigatório
					{|| A632IniDes()}		,;	// [11]  B   Code-block de inicializacao do campo
					NIL						,;	// [12]  L   Indica se trata-se de um campo chave
					NIL						,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.						)  // [14]  L   Indica se o campo é virtual  
	  If INCLUI   				
     	 //-- Campo roteiro similar
	     oStru:AddField(OemToAnsi(STR0009) ,;	// [01]  C   Titulo do campo  - Produto
						OemToAnsi(STR0009)	,;	// [02]  C   ToolTip do campo - Código do Produto
						"CCODAUX"		   	,;	// [03]  C   Id do Field
						"C"						,;	// [04]  C   Tipo do campo
						TamSX3("G2_CODIGO")[1]	,;	// [05]  N   Tamanho do campo
						0						,;	// [06]  N   Decimal do campo
						{|| A632RSCod()}	   	,;	// [07]  B   Code-block de validação do campo
						NIL				   		,;	// [08]  B   Code-block de validação When do campo
						NIL						,; 	// [09]  A   Lista de valores permitido do campo
						.F.						,; 	// [10]  L   Indica se o campo tem preenchimento obrigatório
						NIL		                ,;	// [11]  B   Code-block de inicializacao do campo
						NIL						,;	// [12]  L   Indica se trata-se de um campo chave
						NIL						,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.						)  // [14]  L   Indica se o campo é virtual					
						
		 oStru:AddField(OemToAnsi(STR0009)      ,;	// [01]  C   Titulo do campo  - Produto
						OemToAnsi(STR0009)	    ,;	// [02]  C   ToolTip do campo - Código do Produto
						"CPRODAUX"		   	    ,;	// [03]  C   Id do Field
						"C"						,;	// [04]  C   Tipo do campo
						TamSX3("G2_PRODUTO")[1]	,;	// [05]  N   Tamanho do campo
						0						,;	// [06]  N   Decimal do campo
						{|| A632RSProd() }		,;	// [07]  B   Code-block de validação do campo
						NIL				   		,;	// [08]  B   Code-block de validação When do campo
						NIL						,; 	// [09]  A   Lista de valores permitido do campo
						.F.						,; 	// [10]  L   Indica se o campo tem preenchimento obrigatório
						NIL		                ,;	// [11]  B   Code-block de inicializacao do campo
						NIL						,;	// [12]  L   Indica se trata-se de um campo chave
						NIL						,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.						)  // [14]  L   Indica se o campo é virtual					
	  EndIf 				
Else	//-- Instancia de view
	//-- Campo descricao produto
	oStru:AddField("CDESCPROD"			    ,;	// [01]  C   Nome do Campo
					"04"					,;	// [02]  C   Ordem
					RetTitle("B1_DESC")     ,;	// [03]  C   Titulo do campo
					RetTitle("B1_DESC")	    ,;	// [04]  C   Descricao do campo
					NIL						,;	// [05]  A   Array com Help
					"C"						,; 	// [06]  C   Tipo do campo
					""						,;	// [07]  C   Picture
					NIL						,;	// [08]  B   Bloco de Picture Var
					NIL						,;	// [09]  C   Consulta F3
					.F.						,;	// [10]  L   Indica se o campo é alteravel
					NIL						,;	// [11]  C   Pasta do campo
					NIL						,;	// [12]  C   Agrupamento do campo
					NIL						,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL						,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL						,;	// [15]  C   Inicializador de Browse
					.T.						,;	// [16]  L   Indica se o campo é virtual
					NIL						,;	// [17]  C   Picture Variavel
					NIL						)	// [18]  L   Indica pulo de linha após o campo
     If INCLUI 
		//-- Campo roteiro similar
		oStru:AddField("CCODAUX"		    	,;	// [01]  C   Nome do Campo
						"05"					,;	// [02]  C   Ordem
						OemToAnsi(STR0009)      ,;	// [03]  C   Titulo do campo
						OemToAnsi(STR0009)      ,;	// [04]  C   Descricao do campo
						NIL						,;	// [05]  A   Array com Help
						"C"						,; 	// [06]  C   Tipo do campo
						""						,;	// [07]  C   Picture
						NIL						,;	// [08]  B   Bloco de Picture Var
						"SG2CP"			     	,;	// [09]  C   Consulta F3
						.T.						,;	// [10]  L   Indica se o campo é alteravel
						NIL						,;	// [11]  C   Pasta do campo
						NIL						,;	// [12]  C   Agrupamento do campo
						NIL						,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL						,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL						,;	// [15]  C   Inicializador de Browse
						.T.						,;	// [16]  L   Indica se o campo é virtual
						NIL						,;	// [17]  C   Picture Variavel
						NIL						)	// [18]  L   Indica pulo de linha após o campo				
					
		oStru:AddField("CPRODAUX"		    	,;	// [01]  C   Nome do Campo
						"06"					,;	// [02]  C   Ordem
						" "                     ,;	// [03]  C   Titulo do campo
						" "                     ,;	// [04]  C   Descricao do campo
						NIL						,;	// [05]  A   Array com Help
						"C"						,; 	// [06]  C   Tipo do campo
						PesqPict("SB1","B1_COD"),;	// [07]  C   Picture
						NIL						,;	// [08]  B   Bloco de Picture Var
						"SB1"    		     	,;	// [09]  C   Consulta F3
						.T.						,;	// [10]  L   Indica se o campo é alteravel
						NIL						,;	// [11]  C   Pasta do campo
						NIL						,;	// [12]  C   Agrupamento do campo
						NIL						,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL						,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL						,;	// [15]  C   Inicializador de Browse
						.T.						,;	// [16]  L   Indica se o campo é virtual
						NIL						,;	// [17]  C   Picture Variavel
  						NIL						)	// [18]  L   Indica pulo de linha após o campo								
  	 EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A632IniDes()
Inicializa campo da descricao do produto
@author Andre Anjos
@since 29/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A632IniDes(cProduto,lIniProd)
Local cRet 		:= ""
Default lIniProd	:= .F.

If lIniProd
	If MatGrdPrrf(ALlTrim(cProduto)) //-- Referencia
		cRet := MaGetDescGrd(cProduto)
	Else	//-- Produto
		cRet := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
	EndIf
ElseIf !Inclui
	If MatGrdPrrf(AllTrim(SG2->G2_REFGRD)) //-- Referencia
		cRet := MaGetDescGrd(SG2->G2_REFGRD)
	Else	//-- Produto
		cRet := Posicione("SB1",1,xFilial("SB1")+SG2->G2_PRODUTO,"B1_DESC")
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A632VldCod()
Valida a digitacao do código do roteiro
@author Andre Anjos
@since 29/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function A632VldCod()
Local lRet := .T.

If !Empty(FwFldGet("G2_PRODUTO"))
	lRet := Vazio() .Or. ExistChav("SG2",FwFldGet("G2_PRODUTO")+FwFldGet("G2_CODIGO"),1)
EndIf

/* Não existe necessidade de validar o código do Roteiro, mesmo que a intenção fosse 
   validar o produto, já é validado no próprio campo
   
If	FindFunction('IsProdProt') .And. IsProdProt(AllTrim(FwFldGet("G2_CODIGO"))) .And. !IsInCallStack("DPRA340INT")
	Help(" ",1,"ISPRODPROT") //-- Este produto é um protótipo e de uso reservado do módulo Desenvolvedor de Produtos (DPR).
	lRet := .F.
EndIf*/

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A632PreMod()
Valida a edicao do modelo de dados
@author Andre Anjos
@since 29/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A632SetVld(oModel)
Local lRet := .T.
Local aSaveArea := GetArea()

//Se a variável private não tiver sido declarada, atribui padrão .F.
lBrowse := If(Type("lBrowse")=="U", .F., lBrowse)

If lBrowse .And. (oModel:GetOperation() == 4 .Or. oModel:GetOperation() = 5) .And. FindFunction('IsProdProt') .And. IsProdProt(SG2->G2_PRODUTO)
	lRet := .F.
	Help(" ",1,"ISPRODPROT") //-- Este produto é um protótipo e de uso reservado do módulo Desenvolvedor de Produtos (DPR).
EndIf

RestArea(aSaveArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A632DPCod()
Codigo que retorna o proximo numero de roteiro disponivel conforme o produto
@author Leonardo Quintania
@since 25/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A632DPCod(cProduto)
Local cCodigo	:= '01'

BeginSql Alias "TMPSG2"

	SELECT MAX (G2_CODIGO) G2_CODIGO
	FROM 
		%TABLE:SG2% SG2 
	WHERE 
		SG2.G2_FILIAL = %xFilial:SG2% AND 
		G2_PRODUTO = %Exp:cProduto% AND 
		SG2.%notDel% 

EndSql

If !Eof()
	cCodigo:= Soma1(TMPSG2->G2_CODIGO)
EndIf

TMPSG2->(dbCloseArea())

Return cCodigo

//-------------------------------------------------------------------
/*/{Protheus.doc} A632RSProd()
Valida a edicao do modelo de dados
@author Vivian Beatriz de Almeida Nogueira
@since 27/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
function A632RSProd()
Local oModel   := FwModelActive()
Local oStruSG2 := oModel:Getmodel("MATA632_SG2")
Local oStruSH3R := oModel:GetModel("MATA632_SH3_R")
Local oStruSH3F := oModel:GetModel("MATA632_SH3_F")
Local oStruSGR := oModel:GetModel("MATA632_SGR")
Local oStruSHJ := oModel:GetModel("MATA632_SHJ")
Local aStructSG2 := {} 
Local aStructSH3 := {}     
Local aStructSGR := {}
Local aStructSHJ := {}
Local nI := 1
Local nX := 1
Local nR := 1
Local nF := 1         
Local nC := 1
Local nD := 1
Local nS := 0
Local nS1 := 0
Local campoTam
Local nHasList := 0
            
For nS := 1 To oStruSG2:getqtdline()
	oStruSG2:GoLine(nS)
	if !Empty(oStruSG2:GetValue('G2_OPERAC'))	    
    	If !__lAutomacao
			oStruSG2:DeleteLine()
		EndIf
 	Endif     
 	For nS1 := 1 To oStruSH3R:getqtdline()
    	oStruSH3R:GoLine(nS1)
	    if !Empty(oStruSH3R:GetValue('H3_RECALTE'))	    
		   	oStruSH3R:DeleteLine()
		Endif
    Next
    For nS1 := 1 To oStruSH3F:getqtdline()
    	oStruSH3F:GoLine(nS1)
	    if !Empty(oStruSH3F:GetValue('H3_FERRAM'))	    
		   	oStruSH3F:DeleteLine()
		Endif
    Next
    If SuperGetMV("MV_CHKOPER",.F.,.F.)
	    For nS1 := 1 To oStruSGR:getqtdline()
	    	oStruSGR:GoLine(nS1)
		    if !Empty(oStruSGR:GetValue('GR_ITCHK'))	    
			   	oStruSGR:DeleteLine()
			Endif
	    Next                                 
	EndIf    
	If !TipoAps(.F.,"DRUMMER")
	    For nS1 := 1 To oStruSHJ:getqtdline()
	    	oStruSHJ:GoLine(nS1)
		    if !Empty(oStruSHJ:GetValue('HJ_RECURSO'))	    
			   	oStruSHJ:DeleteLine()
			Endif
	    Next                                 
	EndIf    
Next

nS := oStruSG2:GetLine()                

cProdAux := oModel:GetValue("MATA632_CAB","CPRODAUX")
cCodAux := oModel:GetValue("MATA632_CAB","CCODAUX")

//Pega estrutura da tabela Filho
aStructSG2 := SG2->(dbStruct())
aStructSH3 := SH3->(dbStruct())
aStructSGR := SGR->(dbStruct())
aStructSHJ := SHJ->(dbStruct())

//Faz a consulta na tabela filho
dbSelectArea( "SG2" )

If !Empty(cProdAux) .And. !Empty(cCodAux)
	If SG2->(ColumnPos("G2_LISTA")) > 0
		SG2->(dbSetOrder(1))
		//variavel haslist é alimentada caso os itens do roteiro similar tenham listas de operações,
		// caso sim, não realiza a inclusão do roteiro similar
		If SG2->(dbSeek(xFilial('SG2')+cProdAux+cCodAux))
			While SG2->(!EOF()) .AND. SG2->G2_FILIAL == xFilial('SG2') .AND. cProdAux == SG2->G2_PRODUTO .AND. cCodAux == SG2->G2_CODIGO
				If !Empty(SG2->G2_LISTA)
					nHasList++
					Exit
				EndIf
				SG2->(dbSkip())
			End
		EndIf
	EndIf
	If nHasList > 0 
		Help( ,, 'Help',, STR0087, 1, 0 )
		oModel:LoadValue("MATA632_CAB","CCODAUX","")
		oModel:LoadValue("MATA632_CAB","CPRODAUX","")

	Else
		if MatGrdPrrf(cProdAux) //verifica se o produto é refência grade
			DbSetOrder(7)
			campoTam := TamSX3("G2_REFGRD")[1]
		else
			SG2->( DbSetOrder(1) )
			campoTam := TamSX3("G2_PRODUTO")[1]
		EndIf	

		If SG2->( dbSeek( xFilial( "SG2" )+PadR(cProdAux,campoTam)+cCodAux))
			nX := nS
			If nX != 1
				nX++
			EndIf
				
			//Enquanto houver registros filhos, vai adicionando no grid
			While SG2->(!Eof()) .and. xFilial("SG2") == SG2->G2_FILIAL .and. (cProdAux == SG2->G2_PRODUTO .Or. PadR(cProdAux,campoTam) == SG2->G2_REFGRD) .and. cCodAux == SG2->G2_CODIGO
				//Verifica se precisa gerar mais um linha(se for a primeira não precisa) 
				If !Empty(oStruSG2:GetValue('G2_OPERAC')) .OR. oStruSG2:IsDeleted()
					nS++
					oStruSG2:AddLine()
				EndIf
					
				//Adiciona o valor pra cada campo do grid
				For nI := 1 To Len(aStructSG2)   
					If aStructSG2[nI][1] != "G2_FILIAL" .and. aStructSG2[nI][1] != "G2_PRODUTO" .and. aStructSG2[nI][1] != "G2_CODIGO" .and. aStructSG2[nI][1] != "G2_REVIPRD" .And. oStruSG2:HasField(aStructSG2[nI][1]) 
						oStruSG2:LoadValue(aStructSG2[nI][1],SG2->&(aStructSG2[nI][1]))
					EndIf  
				Next
					
				If !oStruSG2:VldLineData()
					MsgStop(STR0084 +oModel:GetErrorMessage()[6],'') // "Não foi possível incluir a operação. Motivo: "    
					Exit
				EndIf

				//Carrega SH3 - recursos e ferramentas alternativs
				dbSelectArea( "SH3" )
				SH3->( DbSetOrder(1) )           
					
				nR := 1
				nF := 1
					
				If SH3->( dbSeek( xFilial( "SH3" )+cProdAux+cCodAux+SG2->G2_OPERAC))
					//Enquanto houver registros filhos, vai adicionando no grid
					While SH3->(!Eof()) .and. xFilial("SH3") == SH3->H3_FILIAL .and. cProdAux == SH3->H3_PRODUTO .and. cCodAux == SH3->H3_CODIGO .and. SG2->G2_OPERAC == SH3->H3_OPERAC
						if alltrim(SH3->H3_FERRAM) == ""
							//Verifica se precisa gerar mais um linha(se for a primeira não precisa) 
							If nR != 1
								oStruSH3R:AddLine()
							EndIf
									
							//Adiciona o valor pra cada campo do grid
							For nI := 1 To Len(aStructSH3)   
								If aStructSH3[nI][1] != "H3_FILIAL" .and. aStructSH3[nI][1] != "H3_PRODUTO" .and. aStructSH3[nI][1] != "H3_CODIGO" .and. aStructSH3[nI][1] != "H3_OPERAC" .and. aStructSH3[nI][1] != "H3_FERRAM" .and. aStructSH3[nI][1] != "H3_DESCFER" .and. aStructSH3[nI][1] != "H3_RECPRIN" 
									oStruSH3R:LoadValue(aStructSH3[nI][1],SH3->&(aStructSH3[nI][1]))
									//Carrega descrição do recurso
									oStruSH3R:SetValue("H3_DESC",PadR(Posicione("SH1",1,xFilial("SH1")+FwFldGet("H3_RECALTE"),"H1_DESCRI"),TamSX3("H3_DESC")[1]))
								EndIf         
							Next
							nR++
						else         
							//Verifica se precisa gerar mais um linha(se for a primeira não precisa) 
							If nF != 1
								oStruSH3F:AddLine()
							EndIf
							//Adiciona o valor pra cada campo do grid
							For nI := 1 To Len(aStructSH3)   
								If aStructSH3[nI][1] != "H3_FILIAL" .and. aStructSH3[nI][1] != "H3_PRODUTO" .and. aStructSH3[nI][1] != "H3_CODIGO" .and. aStructSH3[nI][1] != "H3_OPERAC" .and. aStructSH3[nI][1] != "H3_RECPRIN" .and. aStructSH3[nI][1] != "H3_RECALTE" .and. aStructSH3[nI][1] != "H3_TIPO" .and. aStructSH3[nI][1] != "H3_EFICIEN" .and. aStructSH3[nI][1] != "H3_DESC"
									oStruSH3F:LoadValue(aStructSH3[nI][1],SH3->&(aStructSH3[nI][1]))
									//Carrega descrição da ferramenta
									oStruSH3F:SetValue("H3_DESCFER",PadR(Posicione("SH4",1,xFilial("SH4")+FwFldGet("H3_FERRAM"),"H4_DESCRI"),TamSX3("H3_DESCFER")[1]))
								EndIf                            
							Next
							nF++
						endif   
						//Pula pro próximo registro filho
						SH3->(DbSkip())
					EndDo
				EndIf       
					
				//Carrega SGR - Checklist das operações
				If SuperGetMV("MV_CHKOPER",.F.,.F.)
					dbSelectArea( "SGR" )
					SGR->( DbSetOrder(1) )           
						
					nC := 1
						
					If SGR->( dbSeek( xFilial( "SGR" )+cProdAux+cCodAux+SG2->G2_OPERAC))
						//Enquanto houver registros filhos, vai adicionando no grid
						While SGR->(!Eof()) .and. xFilial("SGR") == SGR->GR_FILIAL .and. cProdAux == SGR->GR_PRODUTO .and. cCodAux == SGR->GR_ROTEIRO .and. SG2->G2_OPERAC == SGR->GR_OPERAC
							//Verifica se precisa gerar mais um linha(se for a primeira não precisa) 
							If nC != 1
								oStruSGR:AddLine()
							EndIf
							//Adiciona o valor pra cada campo do grid
							For nI := 1 To Len(aStructSGR)   
								If aStructSGR[nI][1] != "GR_FILIAL" .and. aStructSGR[nI][1] != "GR_ROTEIRO" .and. aStructSGR[nI][1] != "GR_PRODUTO" .and. aStructSGR[nI][1] != "GR_OPERAC" .and. aStructSGR[nI][1] != "GR_DESCOP" 
									oStruSGR:LoadValue(aStructSGR[nI][1],SGR->&(aStructSGR[nI][1]))
								EndIf         
							Next
							nC++
							//Pula pro próximo registro filho
							SGR->(DbSkip())
						EndDo
					EndIf         
				EndIf
					
				//Carrega SHJ - Integração com o Drummer
				If TipoAps(.F.,"DRUMMER")
					dbSelectArea( "SHJ" )
					SHJ->( DbSetOrder(1) )           
						
					nD := 1
						
					If SHJ->( dbSeek( xFilial( "SHJ" )+cCodAux+cProdAux+SG2->G2_OPERAC))
						//Enquanto houver registros filhos, vai adicionando no grid
						While SHJ->(!Eof()) .and. xFilial("SHJ") == SHJ->HJ_FILIAL .and. cProdAux == SHJ->HJ_PRODUTO .and. cCodAux == SHJ->HJ_ROTEIRO .and. SG2->G2_OPERAC == SHJ->HJ_OPERAC
							//Verifica se precisa gerar mais um linha(se for a primeira não precisa) 
							If nD != 1
								oStruSHJ:AddLine()
							EndIf
							//Adiciona o valor pra cada campo do grid
							For nI := 1 To Len(aStructSHJ)   
								If aStructSHJ[nI][1] != "HJ_FILIAL" .and. aStructSHJ[nI][1] != "HJ_ROTEIRO" .and. aStructSHJ[nI][1] != "HJ_PRODUTO" .and. aStructSHJ[nI][1] != "HJ_OPERAC" .and. aStructSHJ[nI][1] != "HJ_CTRAB" 
									oStruSHJ:LoadValue(aStructSHJ[nI][1],SHJ->&(aStructSHJ[nI][1]))
									oStruSHJ:SetValue("HJ_DESCREC",PadR(Posicione("SH1",1,xFilial("SH1")+FwFldGet("HJ_RECURSO"),"H1_DESCRI"),TamSX3("HJ_DESCREC")[1]))
								EndIf         
							Next
							nD++
							//Pula pro próximo registro filho
							SHJ->(DbSkip())
						EndDo
					EndIf         
				EndIf
					
				//Pula pro próximo registro filho
				SG2->(DbSkip())
			EndDo
		EndIf                       

		oStruSG2:GoLine(nX)

	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A632RotSim()
Valida a edicao do modelo de dados
@author Vivian Beatriz de Almeida Nogueira
@since 27/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A632RSCod()
	
	A632RSProd()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A632FilRec()
Filtro de Recursos
@author Vivian Beatriz de Almeida Nogueira
@since 27/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A632FilRec(cGrupo)
Local cRecursos, cFiltro
If TipoAps()
	cGrupo   := If(cGrupo=Nil, A610FieldCol("G2_GRUPREC"), cGrupo)
	cRecursos:= A632RecGru(cGrupo)
	cFiltro  := 'H1_CODIGO $ "' + cRecursos + '"'
	If ! Empty(cGrupo) .And. ! Empty(cRecursos)
		SH1->(dbSetFilter({|| &cFiltro}, cFiltro))
	Endif
Endif
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} A632RecGru()
Filtro de Recursos
@author Vivian Beatriz de Almeida Nogueira
@since 27/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A632RecGru(cGrupo)
Local cSeek := xFilial("SG6") + cGrupo
Local cRecursos := ""
Local aSave := {SG6->(RecNo()), SG6->(IndexOrd()), Alias()}
dbSelectArea("SG6")
dbSetOrder(1)
dbSeek(cSeek)
do While ! Eof() .And. G6_FILIAL + G6_GRUPO == cSeek
	cRecursos += If(Empty(cRecursos), "", "; ") + G6_RECURSO
	dbSkip()
Enddo
dbGoto(aSave[1])
dbSetOrder(aSave[2])
dbSelectArea(aSave[3])
Return(cRecursos)

//-------------------------------------------------------------------
/*/{Protheus.doc} A632ValOpe()
Função para verificar se o código da operação já está cadastrado.
@author Lucas Pereira
@since 16/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A632ValOpe()
Local aArea  := GetArea()
Local cProd  := FWFldGet("G2_PRODUTO")
Local cCod   := FWFldGet("G2_CODIGO")
	
	DbSelectArea("SG2")
	if MatGrdPrrf(cProd)
		DbSetOrder(7)
		If dbSeek(xFilial("SG2")+PadR(cProd,TamSX3("G2_REFGRD")[1])+cCod+M->G2_OPERAC) .And. (SG2->G2_OPERAC == M->G2_OPERAC)
			Help(" ",1,"JAGRAVADO")
			Return .F.		
		EndIf
	else
		DbSetOrder(1)
		If dbSeek(xFilial("SG2")+PadR(cProd,TamSX3("G2_PRODUTO")[1])+cCod+M->G2_OPERAC) .And. (SG2->G2_OPERAC == M->G2_OPERAC)
			Help(" ",1,"JAGRAVADO")
			Return .F.		
		EndIf
	EndIf
	
RestArea(aArea)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A632Tempo()
@author Lucas Pereira
@since 18/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A632Tempo()
Local nDec, nPosTpOper,nPosTemPad,nPosSetup,nPosTempEnd, nx, ind
Local nVal := FwFldGet("G2_TEMPAD")
Local nPrecisao := GetMV("MV_PRECISA")
Local cCampo := ReadVar()
Local cTipo := GetMV("MV_TPHR")
Local oModel	    := FWLoadModel("MATA632")
Local oModelSG2  := oModel:GetModel('MATA632_SG2')

nDec := ( nVal - Int( nVal ) ) * 100
nPrecisao := 60 / nPrecisao
	
	If !Vazio("G2_TPOPER")
		For nx = 1 To Len(aHeader)
			If Trim(aHeader[nx][2]) == "G2_TPOPER"
				nPosTpOper:=nx
			ElseIf Trim(aHeader[nx][2]) == "G2_TEMPAD"
				nPosTemPad:=nx
			ElseIf Trim(aHeader[nx][2]) == "G2_SETUP"
				nPosSetUp:=nx
			ElseIf Trim(aHeader[nx][2]) == "G2_TEMPEND"
				nPosTempEnd:=nx
			EndIf
		Next nx

		If cTipo == "N"
			If nVal < 1
				nDec += (aCols[n,nPosSetUp] - Int(aCols[n,nPosSetUp])) * 100
				If NoRound(nDec,2) < NoRound(nPrecisao,2)
					Help(" ",1,"MENORPREC")
					aCols[n,nPosTemPad]:=nVal
					If (aCols[n][nPosTpOper]) == "2" .Or. (aCols[n][nPosTpOper]) == "3"
						Return .F.
					EndIf
				EndIf
			EndIf
		ElseIf cTipo == "C"
			If nVal < 1
				nDec := (nVal - Int(nVal)) * 60
				nDec += (aCols[n,nPosSetUp] - Int(aCols[n,nPosSetUp])) * 60
				If NoRound(nDec,2) < NoRound(nPrecisao,2)
					Help(" ",1,"MENORPREC")
					aCols[n,nPosTemPad]:=nVal
					If (aCols[n][nPosTpOper]) == "2" .Or. (aCols[n][nPosTpOper]) == "3"
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATA632PPI

Realiza a integração com o PC-Factory - PPI Multitask

@param cXml      - XML que será enviado. Caso não seja passado esse parametro, será realizada
                   a chamada do Adapter para criação do XML.
                   Se for passado esse parâmetro, não será exibida a mensagem de erro caso exista,
                   nem será considerado o filtro da tabela SOE. 
@param cRotProd  - Obrigatório quando utilizado o parâmetro cXml. Contém o código do produto e o código do roteiro. (RR+PRODUTO)
@param lExclusao - Indica se está chamando para rotina de exclusão de produto.
@param lFiltra   - Identifica se será realizado ou não o filtro do registro.
@param lPendAut  - Indica se será gerada a pendência sem realizar a pergunta para o usuário, caso ocorra algum erro.

@author  Lucas Konrad França
@version P118
@since   12/04/2016
@return  lRet  - Indica se a integração com o PC-Factory foi realizada. 
           .T. -> Integração Realizada
           .F. -> Integração não realizada.
/*/
//-------------------------------------------------------------------------------------------------
Function MATA632PPI(cXml, cRotProd, lExclusao, lFiltra, lPendAut)
   Local aArea     := GetArea()
   Local aAreaSG2  := SG2->(GetArea())
   Local lRet      := .T.
   Local aRetXML   := {}
   Local aRetWS    := {}
   Local aRetData  := {}
   Local aRetArq   := {}
   Local cNomeXml  := ""
   Local cProduto  := ""
   Local cRoteiro  := ""
   Local cGerouXml := ""
   Local cOperacao := ""
   Local lProc     := .F.
   
   //Variável utilizada para identificar que está sendo executada a integração para o PPI dentro do MATI200.
   Private lRunPPI := .T.
   
   Default cXml      := ""
   Default cRotProd  := ""
   Default lExclusao := .F.
   Default lFiltra   := .T.
   Default lPendAut  := .F.

   If Empty(cXml)
      If lExclusao 
         cOperacao := Lower(STR0005) //"excluir"
      Else
         If INCLUI
            cOperacao := Lower(STR0003) //"incluir"
         Else
            cOperacao := Lower(STR0004) //"alterar"
         EndIf
      EndIf
   Else
      If PCPEvntXml(cXml) == "delete"
         lExclusao := .T.
      EndIf
   EndIf

   If Empty(cXml)
      cProduto := SG2->G2_PRODUTO
      cRoteiro := SG2->G2_CODIGO
   Else
      cRoteiro := PadR(StrTokArr(cRotProd,"+")[1], TAMSX3("G2_CODIGO")[1])
      cProduto := PadR(StrTokArr(cRotProd,"+")[2], TAMSX3("G2_PRODUTO")[1])
   EndIf

   //Realiza filtro na tabela SOE, para verificar se o produto entra na integração.
   //If !Empty(cXml) .Or. !lFiltra
      If lFiltra
         //Faz o filtro posicionando em todas as operações. Se qualquer operação
         //entrar na integração, será realizado o processamento.
         SG2->(dbSetOrder(1))
         If SG2->(dbSeek(xFilial("SG2")+cProduto+cRoteiro))
            While SG2->(!Eof()) .And. xFilial("SG2")+cProduto+cRoteiro == SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO)
               If PCPFiltPPI("SG2", AllTrim(cRoteiro)+"+"+AllTrim(cProduto), "SG2")
                  lProc := .T.
                  Exit
               EndIf
               SG2->(dbSkip())
            End
            SG2->(RestArea(aAreaSG2))
         EndIf
      Else
         lProc := .T.
      EndIf
      If lProc
         //Adapter para criação do XML
         If Empty(cXml)
            aRetXML := MATI632("", TRANS_SEND, EAI_MESSAGE_BUSINESS)
         Else
            aRetXML := {.T.,cXml}
         EndIf
         /*
            aRetXML[1] - Status da criação do XML
            aRetXML[2] - String com o XML
         */
         If aRetXML[1]
            //Retira os caracteres especiais
            aRetXML[2] := EncodeUTF8(aRetXML[2])
         
            //Busca a data/hora de geração do XML
            aRetData := PCPxDtXml(aRetXML[2])
            /*
               aRetData[1] - Data de geração AAAAMMDD
               aRetData[1] - Hora de geração HH:MM:SS
            */
         
            //Envia o XML para o PCFactory
            aRetWS := PCPWebsPPI(aRetXML[2])
            /*
               aRetWS[1] - Status do envio (1 - OK, 2 - Pendente, 3 - Erro.)
               aRetWS[2] - Mensagem de retorno do PPI
            */
         
            If aRetWS[1] != "1" .And. Empty(cXml)
               If lPendAut
                  lRet := .T.
               Else
	               //"Atenção! Ocorreram erros na integração com o TOTVS MES. Erro: "
	               // XXXXXX
	               // XXXXXX
	               // "Deseja incluir/alterar/excluir a estrutura no protheus e gerar pendência para integração?"
	               If !MsgYesNo(STR0073 + AllTrim(aRetWS[2]) + CHR(10)+;
	                            STR0074 + AllTrim(cOperacao) + STR0075)
	                  lRet := .F.
	               EndIf
	            EndIf
            EndIf
            
            If lRet
               //Cria o XML fisicamente no diretório parametrizado
               aRetArq := PCPXmLPPI(aRetWS[1],"SG2",AllTrim(cRoteiro)+"+"+AllTrim(cProduto),aRetData[1],aRetData[2],aRetXML[2])
               /*
                  aRetArq[1] Status da criação do arquivo. .T./.F.
                  aRetArq[2] Nome do XML caso tenha criado. Mensagem de erro caso não tenha criado o XML.
               */
               If !aRetArq[1]
                  If Empty(cXml) .And. !lPendAut
                     Alert(aRetArq[2])
                  EndIf
               Else
                  cNomeXml := aRetArq[2]
               EndIf
               If Empty(cNomeXml)
                  cGerouXml := "2"
               Else
                  cGerouXml := "1"
               EndIf
               //Cria a tabela SOF
               PCPCriaSOF("SG2",AllTrim(cRoteiro)+"+"+AllTrim(cProduto),aRetWS[1],cGerouXml,cNomeXml,aRetData[1],aRetData[2],__cUserId,aRetWS[2],aRetXML[2])
               //Array com os componentes que tiveram erro.
               If Type('aIntegPPI') == "A"
                  If aRetWS[1] != "1"
                     aAdd(aIntegPPI,{cProduto,aRetWS[2]})
                  EndIf
               EndIf
            EndIf
         EndIf
      EndIf
   //EndIf
   //Tratativa para retornar .F. mesmo quando é pendência automática;
   //Utilizado apenas para o programa de sincronização.
   If (AllTrim(FunName()) $ "PCPA111|MATA632") .And. Len(aRetWs) > 0 .And. aRetWS[1] != "1"
      lRet := .F.
   EndIf
   RestArea(aArea)
   SG2->(RestArea(aAreaSG2))
Return lRet	

//---------------------------------------------------------------------
/*/{Protheus.doc} A632RecRest()
Efetua validações do recurso restritivo
@author TOTVS S/A
@since 29/12/2011
@version 1.0
/*/
//---------------------------------------------------------------------
Function A632RecRest()
Local oModel	:= FWModelActive()
Local oGridSG2	:= oModel:GetModel("MATA632_SG2")
Local oGridSHJ	:= oModel:GetModel("MATA632_SHJ")
Local nX		:= 0

//-- Inicializa descricao do recurso
oGridSHJ:SetValue("HJ_DESCREC",PadR(Posicione("SH1",1,xFilial("SH1")+FwFldGet("HJ_RECURSO"),"H1_DESCRI"),TamSX3("HJ_DESCREC")[1]))

Return .T.


//---------------------------------------------------------------------
/*/{Protheus.doc} A632VldLst()
Valida posisbilidade de alteracao/exclusao do registro caso exista lista de operações no roteiro
@author TOTVS S/A
@since 17/10/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function A632VldLst(nOperac)
	Local nHasList := 0
	Local cProduto := SG2->G2_PRODUTO
	Local cCodAux  := SG2->G2_CODIGO
	Local aArea		:= GetArea()
	
	If SG2->(ColumnPos("G2_LISTA")) > 0
		dbSelectArea('SG2')
		SG2->(dbSetOrder(1))
		If SG2->(dbSeek(xFilial('SG2')+SG2->G2_PRODUTO+SG2->G2_CODIGO))
			While SG2->(!EOF()) .AND. SG2->G2_FILIAL == xFilial('SG2') .AND. cProduto == SG2->G2_PRODUTO .AND.  cCodAux == SG2->G2_CODIGO
				If !Empty(SG2->G2_LISTA)
					nHasList++
					Exit
				EndIf
				SG2->(dbSkip())
			End
		EndIf
		RestArea(aArea)
	EndIf
	If nHasList > 0 
		Help( ,, 'Help',, STR0086, 1, 0 )
	Else
		If !__lAutomacao
			If nOperac == 1
				lRet := FWExecView(STR0004, "MATA632",OP_ALTERAR , /*oDlg*/, {|| .T. }, /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, ) 
			ElseIf nOperac == 2
				lRet := FWExecView(STR0005, "MATA632",OP_EXCLUIR , /*oDlg*/, {|| .T. }, /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, ) 
			EndIf
		EndIf
	EndIf
Return 

/*/{Protheus.doc} a632VldDel
Verifica se o roteiro poderá ser excluído, de acordo com o relacionamento com a SC2
@type  Static Function
@author lucas.franca
@since 15/01/2019
@version 12
@param cProduto, character, Código do produto
@param cRoteiro, character, Código do roteiro
@return lRet, Logical, Indica se o roteiro poderá ser excluído
/*/
Static Function a632VldDel(cProduto, cRoteiro)
	Local lRet      := .T.
	Local cQuery    := ""
	Local cAliasQry := "VLDSG2SC2"
	Local aArea     := GetArea()

	cQuery := " SELECT COUNT(*) TOTAL "
	cQuery +=   " FROM " + RetSqlName("SC2") + " SC2 "
	cQuery +=  " WHERE SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SC2.C2_PRODUTO = '" + cProduto + "' "
	cQuery +=    " AND SC2.C2_ROTEIRO = '" + cRoteiro + "' "
	cQuery +=    " AND NOT EXISTS ( SELECT 1 "
	cQuery +=                       " FROM " + RetSqlName("SHY") + " SHY "
	cQuery +=                      " WHERE SHY.HY_FILIAL  = '" + xFilial("SHY") + "' "
	cQuery +=                        " AND SHY.D_E_L_E_T_ = ' ' " 
	cQuery +=                        " AND SHY.HY_OP      = SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD ) "
	
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	If (cAliasQry)->(TOTAL) > 0
		lRet := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)
Return lRet
