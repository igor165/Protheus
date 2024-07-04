#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSA191.CH"

#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW		2  

/*{Protheus.doc} TMSA191

Função para a criação do MDF-e para o Serie 3

@author Fabio Marchiori Sampaio	
@since 11/08/14
@version 1.0
*/

Function TMSA191()
                                  	
Local oBrowse
Private cAliasMDF	:= ''

/*If !__lPyme
	Help( "", 1, "TMSA19101" ) // Esta funcionalidade esta disponivel somente para o Protheus Serie 3
	Return(Nil)
EndIf*/

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("DTX")								// Alias da tabela utilizada
oBrowse:SetMenuDef("TMSA191")						// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0008)						// Descrição do browse Manifesto Eletronico - MDF-e
oBrowse:Activate()                                       

Return(Nil)
  
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel		:=	Nil
	Local oStructDTX	:= FWFormStruct(1,"DTX")	
	Local oStructDJ1	:= FWFormStruct(1,"DJ1")	
	Local oStructDT6 	:= T191StrCTe(TYPE_MODEL,{	"DT6_FILDOC","DT6_DOC","DT6_SERIE","DT6_QTDVOL","DT6_PESO","DT6_PESCOB","DT6_VALMER","DT6_TIPFRE","DT6_FILDES"}) 
	Local oStructRES 	:= T191StrCTe(TYPE_MODEL,{	"DT6_TIPFRE","DT6_VALMER","DT6_VALFAT","F2_VALICM","DT6_QTDVOL","DT6_PESO","DT6_PESCOB","DT6_VALFAT","F2_BASEICM"})

	oStructRES:AddField( "Qtd. CTe" ,"","XXX_QTDCTE","N",4,/*nDecimal*/,/*bValid*/,/*bWHen*/,/*aValues*/,/*lObrigat*/,/*bInit*/,/*lkey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/ )
	oStructRES:SetProperty( 'DT6_TIPFRE' , MODEL_FIELD_TAMANHO,8)
	
	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("TMSA191" /*cID*/, /*bPreValid*/, /*bPostValid*/, {|oModel|TMSA191GRV(oModel)} /*bCommit*/, /*bCancel*/)
  
	oModel:SetVldActivate({|oModel| TMSA191PRE(oModel)})
	oModel:SetActivate({|oModel| TMSA191POS(oModel)})
	
	oModel:AddFields("TMSA191_01", Nil,oStructDTX , /*bPre*/, /*bPost*/, /*bLoad*/)

	oModel:AddGrid( 'DETAIL_CTE'		, 'TMSA191_01', oStructDT6, 	/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, { | oModel, lLoad | TMSA191CTE( oModel, lLoad, 1 ) } /*BLoad*/ )
 	oModel:AddGrid( 'DETAIL_RES'		, 'TMSA191_01', oStructRES, 	/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, { | oModel, lLoad | TMSA191RES( oModel, lLoad, 1 ) }/*BLoad*/ )
  	oModel:AddGrid( 'DETAIL_PER'		, 'TMSA191_01', oStructDJ1, 	/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, { | oModel, lLoad | TMSA191DJ1( oModel, lLoad, 1) } /*BLoad*/ )

	oModel:SetDescription("Parâmetros")
	oModel:GetModel("TMSA191_01"):SetDescription("Manifesto - MDFe")
	oModel:GetModel("DETAIL_CTE"):SetDescription("CTe")
	oModel:GetModel("DETAIL_RES"):SetDescription("Resuno")                                                                  
	oModel:GetModel("DETAIL_PER"):SetDescription("Percurso")

	oModel:SetPrimaryKey({"DTX_FILIAL", "DTX_MANIFE"})
                                                 
	oModel:GetModel( 'DETAIL_CTE' ):SetOnlyQuery ( .T. ) // para não salvar esse modelo
	oModel:GetModel( 'DETAIL_RES' ):SetOnlyQuery ( .T. ) // para não salvar esse modelo
	oModel:GetModel( 'DETAIL_PER' ):SetOnlyQuery ( .T. ) // para não salvar esse modelo
	
	oModel:GetModel( 'DETAIL_PER' ):SetOptional( .T. )

Return oModel

//------------------------------------------------------------------------------------------------

Static Function ViewDef()
  
	Local oView   		:= Nil 
	Local oStructDTX	:= FWFormStruct(2,"DTX")
	Local oStructDJ1	:= FWFormStruct(2,"DJ1")
	Local oModel  		:= FWLoadModel("TMSA191") 
	Local oStructDT6 	:= T191StrCTe(TYPE_VIEW,{	"DT6_FILDOC", "DT6_DOC","DT6_SERIE","DT6_QTDVOL","DT6_PESO","DT6_PESCOB","DT6_VALMER","DT6_TIPFRE","DT6_FILDES"}) 
	Local oStructRES 	:= T191StrCTe(TYPE_VIEW,{	"DT6_TIPFRE","DT6_VALMER","DT6_VALFAT","F2_VALICM","DT6_QTDVOL","DT6_PESO","DT6_PESCOB","DT6_VALFAT","F2_BASEICM"})

	oStructDJ1:RemoveField( "DJ1_FILIAL" )

	oStructRES:AddField("XXX_QTDCTE","4","Qtd. CTe","Qtd. CTe",,"N","",/*BPICTVAR*/,,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBROW*/,.T./*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructDTX:RemoveField( 'DTX_VIAGEM' )
	oStructDTX:SetProperty( 'DTX_NUMROM' , MVC_VIEW_ORDEM, "05")
	oStructDTX:SetProperty( 'DTX_TIPMAN' , MVC_VIEW_CANCHANGE, .F.)
	oStructDTX:SetProperty( 'DTX_CODVEI' , MVC_VIEW_CANCHANGE, .F.)
	oStructDTX:SetProperty( 'DTX_DATPIN' , MVC_VIEW_CANCHANGE, .F.)
	
	oStructDJ1:SetProperty( 'DJ1_NUMROM' , MVC_VIEW_CANCHANGE, .F.)
	oStructDJ1:SetProperty( 'DJ1_SEQUEN' , MVC_VIEW_CANCHANGE, .F.)
	oStructDJ1:SetProperty( 'DJ1_EST'	 , MVC_VIEW_CANCHANGE, .F.)
	
	oView:= FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField("TMSA191_01" , oStructDTX, /*cLinkID*/ )

   	oView:AddGrid('VIEW_CTE'	, oStructDT6,"DETAIL_CTE")
	oView:AddGrid('VIEW_RES'	, oStructRES,"DETAIL_RES")
	oView:AddGrid('VIEW_PER'	, oStructDJ1,"DETAIL_PER")	
 	   	
	oView:CreateHorizontalBox( "MASTER"			, 55,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
   	oView:CreateHorizontalBox( "DETAIL"			, 45,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ ) 
	oView:CreateHorizontalBox( "DETAIL_CTE"		, 100,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "DETAIL_RES"		, 100,,,"IDFOLDER","IDSHEET02" )	
	oView:CreateHorizontalBox( "DETAIL_PER"		, 100,,,"IDFOLDER","IDSHEET03" )

	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01","Documentos")
	oView:AddSheet("IDFOLDER","IDSHEET02","Resumo")	
	oView:AddSheet("IDFOLDER","IDSHEET03","Percurso")

	oView:SetOwnerView("TMSA191_01"	,"MASTER")
	oView:SetOwnerView("VIEW_CTE"	,"DETAIL_CTE")
	oView:SetOwnerView("VIEW_RES"	,"DETAIL_RES")		
	oView:SetOwnerView("VIEW_PER"	,"DETAIL_PER")
	
	oView:AddIncrementField("VIEW_CTE"		,"DETAIL_CTE")
	oView:AddIncrementField("VIEW_RES"		,"DETAIL_RES")
	oView:AddIncrementField("VIEW_PER"		,"DETAIL_PER")
	
	oView:SetCloseOnOk({|| .T. })
	
Return (oView)
	
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------------------
// Adiciona botões do browse                                                               
//-------------------------------------------------------

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.TMSA191" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.TMSA191" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSA191" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE "MDFe" ACTION "TMSAE73()" OPERATION 9 ACCESS 0 //"Monitor MDFe"

Return (aRotina)

/*/{Protheus.doc} loadGridCTE
Retorna o conteudo do grid para os valores dos CTE
Uso restrito

@sample
loadGridCTE()

@author Fabio Marchiori Sampaio.
@since 13/08/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
         
Static Function TMSA191CTE(oModel, lCopy, nTipConsulta)

Local oModelCTE	:= oModel:GetModel("DETAIL_CTE")
Local lFirst		:= .T.
Local aLoadCTe	:= {}
Local nLinha		:= 0
Local cAliasCTe	:= ""
Local cQuery		:= ""

cAliasCTe := GetNextAlias()

cQuery := " SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_QTDVOL, DT6_PESO, DT6_PESCOB, DT6_VALMER, DT6_TIPFRE, DT6_FILDES "
cQuery += "	FROM " + RetSqlName("DUD") + " DUD"
cQuery += "	INNER JOIN " + RetSqlName("DT6") + " DT6" 
cQuery += "		ON DT6.DT6_FILIAL = '" + xFilial("DT6")+"' "
cQuery += "		  AND DT6.DT6_FILDOC = DUD.DUD_FILDOC "
cQuery += "		  AND DT6.DT6_DOC	 	= DUD.DUD_DOC "
cQuery += "		  AND DT6.DT6_SERIE	= DUD.DUD_SERIE "
cQuery += "		  AND DT6.D_E_L_E_T_ = ' ' "
cQuery += "	WHERE DUD.DUD_FILIAL = '" + xFilial("DUD")+"' "
If nTipConsulta = 1
	cQuery += "		AND DUD.DUD_NUMROM  = '"+ Iif(!Empty(DTX->DTX_NUMROM), DTX->DTX_NUMROM, 'zz')+"'"
ElseIf nTipConsulta = 2
	cQuery += "		AND DUD.DUD_NUMROM  = '"+ Iif(!Empty(MV_PAR01), MV_PAR01, 'zz')+"'"
EndIf
cQuery += "		AND DUD.D_E_L_E_T_	= ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasCTe, .T., .F.)	

If nTipConsulta = 1
	While (cAliasCTe)->( !Eof() )
		
		nLinha++
			
		aAdd(aLoadCTe,{nLinha,{ (cAliasCTe)->DT6_FILDOC,(cAliasCTe)->DT6_DOC,(cAliasCTe)->DT6_SERIE,(cAliasCTe)->DT6_QTDVOL,(cAliasCTe)->DT6_PESO,(cAliasCTe)->DT6_PESCOB,(cAliasCTe)->DT6_VALMER,(cAliasCTe)->DT6_TIPFRE,(cAliasCTe)->DT6_FILDES}})

		(cAliasCTe)->( DbSkip() )
			
	EndDo                     

ElseIf nTipConsulta = 2

	While !(cAliasCTe)->( Eof() )
		If lFirst .And. oModelCTE:Length() == 1
			lFirst := .F.
			oModelCTE:GoLine(1)
		Else
			oModelCTE:AddLine()
		EndIf
		
		oModelCTE:SetValue("DT6_FILDOC",	(cAliasCTe)->DT6_FILDOC)
		oModelCTE:SetValue("DT6_DOC",		(cAliasCTe)->DT6_DOC)
		oModelCTE:SetValue("DT6_SERIE",		(cAliasCTe)->DT6_SERIE)
		oModelCTE:SetValue("DT6_QTDVOL",	(cAliasCTe)->DT6_QTDVOL)
		oModelCTE:SetValue("DT6_PESO",		(cAliasCTe)->DT6_PESO)
		oModelCTE:SetValue("DT6_PESCOB",	(cAliasCTe)->DT6_PESCOB)
		oModelCTE:SetValue("DT6_VALMER",	(cAliasCTe)->DT6_VALMER)
		oModelCTE:SetValue("DT6_TIPFRE",	(cAliasCTe)->DT6_TIPFRE)
		oModelCTE:SetValue("DT6_FILDES",	(cAliasCTe)->DT6_FILDES)
		
		(cAliasCTe)->( DbSkip() )
		
	EndDo	

EndIf

	(cAliasCTe)->(DbCloseArea())

Return(aLoadCTe)													

/*/{Protheus.doc} loadGridRES
Retorna o conteudo do grid para os valores dos resumo
Uso restrito

@sample
loadGridRES()

@author Fabio Marchiori Sampaio.
@since 13/08/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
         
Static Function TMSA191RES(oModel, lCopy, nTipConsulta)

Local oModelRES	:= oModel:GetModel("DETAIL_RES")	
Local aLoadRES	:= {}
Local nLinha		:= 0
Local cAliasRES	:= ""
Local cQuery		:= ""
Local lFirst		:= .T.
Local nValMercC	:= 0  
Local nValFreteC	:= 0
Local nValICMC	:= 0
Local nVolsC		:= 0
Local nPesoC		:= 0
Local nPesoCobC	:= 0
Local nVarNTribC	:= 0
Local nVarTribC	:= 0
Local nCtrcsC		:= 0
Local nValMercF	:= 0  
Local nValFreteF	:= 0
Local nValICMF	:= 0
Local nVolsF		:= 0
Local nPesoF		:= 0
Local nPesoCobF	:= 0
Local nVarNTribF	:= 0 
Local nVarTribF	:= 0
Local nCtrcsF		:= 0

cAliasRES := GetNextAlias()

cQuery := " SELECT	DT6_TIPFRE, DT6_VALMER, DT6_VALFAT,	F2_VALICM, DT6_QTDVOL, DT6_PESO, DT6_PESCOB, DT6_VALFAT "
cQuery += "		F2_BASEICM 	"
cQuery += "	FROM " + RetSqlName("DUD") + " DUD" 
cQuery += "	INNER JOIN " + RetSqlName("DT6") + " DT6"
cQuery += "		ON DT6.DT6_FILIAL = '" + xFilial("DT6")+"' "
cQuery += "		  AND DT6.DT6_FILDOC = DUD.DUD_FILDOC " 
cQuery += "		  AND DT6.DT6_DOC	 	= DUD.DUD_DOC "
cQuery += "		  AND DT6.DT6_SERIE	= DUD.DUD_SERIE " 
cQuery += "		  AND DT6.D_E_L_E_T_ = ' ' " 
cQuery += "	INNER JOIN " + RetSqlName("SF2") + " SF2"
cQuery += "     ON  SF2.F2_FILIAL  = '" + xFilial("SF2")+"' "
cQuery += "		AND SF2.F2_DOC      = DT6.DT6_DOC "
cQuery += "		AND SF2.F2_SERIE    = DT6.DT6_SERIE "
cQuery += "		AND SF2.D_E_L_E_T_  = ' ' "
cQuery += "	WHERE DUD.DUD_FILIAL = '" + xFilial("DUD")+"' " 
If nTipConsulta = 1
	cQuery += "		AND DUD.DUD_NUMROM  = '"+ Iif(!Empty(DTX->DTX_NUMROM), DTX->DTX_NUMROM, 'zz')+"'"
ElseIf nTipConsulta = 2
	cQuery += "		AND DUD.DUD_NUMROM  = '"+ Iif(!Empty(MV_PAR01), MV_PAR01, 'zz')+"'"
EndIf
cQuery += "		AND DUD.D_E_L_E_T_  = ' '

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasRES, .T., .F.)	

	While (cAliasRES)->( !Eof() )
		
		nLinha++
			
		If (cAliasRES)->DT6_TIPFRE == "1" // Frete CIF
			nValMercC  += (cAliasRES)->DT6_VALMER	// Valor Mercadoria CIF
			nValFreteC += (cAliasRES)->DT6_VALFAT	// Valor do Frete CIF
			nValICMC   += (cAliasRES)->F2_VALICM	// Valor do ICMS CIF
			nVolsC     += (cAliasRES)->DT6_QTDVOL	// Volumes CIF
			nPesoC     += (cAliasRES)->DT6_PESO		// Peso Liquido CIF
			nPesoCobC  += (cAliasRES)->DT6_PESCOB	// Peso Cobrado Liquido CIF
			nVarNTribC += (cAliasRES)->DT6_VALFAT-(cAliasRES)->F2_BASEICM	// Valor nao Tributavel CIF
			nVarTribC  += (cAliasRES)->F2_BASEICM	// Valor Tributavel CIF
			nCtrcsC    += 1							// Numero de Conhecimentos CIF
		Else // Frete FOB
			nValMercF  += (cAliasRES)->DT6_VALMER	// Valor Mercadoria FOB
			nValFreteF += (cAliasRES)->DT6_VALFAT	// Valor do Frete FOB
			nValICMF   += (cAliasRES)->F2_VALICM	// Valor do ICMS FOB
			nVolsF     += (cAliasRES)->DT6_QTDVOL	// Volumes FOB
			nPesoF     += (cAliasRES)->DT6_PESO		// Peso Liquido FOB
			nPesoCobF  += (cAliasRES)->DT6_PESCOB	// Peso Cobrado FOB
			nVarNTribF += (cAliasRES)->DT6_VALFAT-(cAliasRES)->F2_BASEICM	// Valor nao Tributavel CIF
			nVarTribF  += (cAliasRES)->F2_BASEICM	// Valor Tributavel CIF
			nCtrcsF    += 1							// Numero de Conhecimentos FOB
		EndIf
		
		(cAliasRES)->( DbSkip() )
			
	EndDo                     

If nTipConsulta = 1

	//CIF
	aAdd(aLoadRES,{0,{"CIF",	nValMercC,	nValFreteC, nValICMC, nVolsC, nPesoC, nPesoCobC, nVarNTribC, nVarTribC, nCtrcsC }})
	//FOB
	aAdd(aLoadRES,{0,{"FOB",	nValMercF,	nValFreteF, nValICMF, nVolsF, nPesoF, nPesoCobF, nVarNTribF, nVarTribF, nCtrcsF }})
	//TOTAL
	aAdd(aLoadRES,{0,{"Total",	nValMercC + nValMercF,	nValFreteC + nValFreteF, nValICMC + nValICMF, nVolsC + nVolsF, nPesoC + nPesoF, nPesoCobC + nPesoCobF, nVarNTribC + nVarNTribF, nVarTribC + nVarTribF, nCtrcsC + nCtrcsF }})

ElseIf nTipConsulta == 2	
	
		If lFirst .And. oModelRES:Length() == 1
			lFirst := .F.
			oModelRES:GoLine(1)
		Else
			oModelRES:AddLine()
		EndIf
		//CIF
		oModelRES:SetValue("DT6_TIPFRE"	,	"CIF")
		oModelRES:SetValue("DT6_VALMER"	,	nValMercC) 
		oModelRES:SetValue("DT6_VALFAT"	,	nValFreteC)
		oModelRES:SetValue("F2_VALICM"	,	nValICMC)
		oModelRES:SetValue("DT6_QTDVOL"	,	nVolsC)
		oModelRES:SetValue("DT6_PESO"	,	nPesoC)
		oModelRES:SetValue("DT6_PESCOB"	,	nPesoCobC)
		oModelRES:SetValue("DT6_VALFAT"	,	nVarNTribC)
		oModelRES:SetValue("F2_BASEICM"	,	nVarTribC)
		oModelRES:SetValue("XXX_QTDCTE"	,	nCtrcsC)
		
		//FOB
		oModelRES:AddLine()
		oModelRES:SetValue("DT6_TIPFRE"	,	"FOB")
		oModelRES:SetValue("DT6_VALMER"	,	nValMercF) 
		oModelRES:SetValue("DT6_VALFAT"	,	nValFreteF)
		oModelRES:SetValue("F2_VALICM"	,	nValICMF)
		oModelRES:SetValue("DT6_QTDVOL"	,	nVolsF)
		oModelRES:SetValue("DT6_PESO"	,	nPesoF)
		oModelRES:SetValue("DT6_PESCOB"	,	nPesoCobF)
		oModelRES:SetValue("DT6_VALFAT"	,	nVarNTribF)
		oModelRES:SetValue("F2_BASEICM"	,	nVarTribF)
		oModelRES:SetValue("XXX_QTDCTE"	,	nCtrcsF)
		
		//TOTAL
		oModelRES:AddLine()
		oModelRES:SetValue("DT6_TIPFRE"	,	"Total")
		oModelRES:SetValue("DT6_VALMER"	,	nValMercC + nValMercF) 
		oModelRES:SetValue("DT6_VALFAT"	,	nValFreteC + nValFreteF)
		oModelRES:SetValue("F2_VALICM"	,	nValICMC + nValICMF)
		oModelRES:SetValue("DT6_QTDVOL"	,	nVolsC + nVolsF)
		oModelRES:SetValue("DT6_PESO"	,	nPesoC + nPesoF)
		oModelRES:SetValue("DT6_PESCOB"	,	nPesoCobC + nPesoCobF)
		oModelRES:SetValue("DT6_VALFAT"	,	nVarNTribC + nVarNTribF)
		oModelRES:SetValue("F2_BASEICM"	,	nVarTribC + nVarTribF)
		oModelRES:SetValue("XXX_QTDCTE"	,	nCtrcsC + nCtrcsF)

EndIf

(cAliasRES)->(DbCloseArea())

Return(aLoadRES)													

//-------------------------------------------------------------------
/*
Estrutura dos campos 
Cria uma estrutura para os das do CTe no manifesto
@author Fabio Marchiori Sampaio
@since 12/08/2014
@version 1.0
*/
//-------------------------------------------------------------------

Static Function T191StrCTe(nType,aCampos)

Local oStruct   := Nil
Local nX        := 0
Local aDadosCpo := {}

Default nType   := 1 //  1=Tipo Model / 2= Tipo View
DefauLt aCampos := {}

If nType == 1
	oStruct := FWFormModelStruct():New()

	//----------Estrutura do campo tipo Model----------------------------		
	// [01] C Titulo do campo
	// [02] C ToolTip do campo
	// [03] C identificador (ID) do Field
	// [04] C Tipo do campo
	// [05] N Tamanho do campo
	// [06] N Decimal do campo
	// [07] B Code-block de validação do campo
	// [08] B Code-block de validação When do campo
	// [09] A Lista de valores permitido do campo
	// [10] L Indica se o campo tem preenchimento obrigatório
	// [11] B Code-block de inicializacao do campo
	// [12] L Indica se trata de um campo chave
	// [13] L Indica se o campo pode receber valor em uma operação de update.
	// [14] L Indica se o campo é virtual
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campo filial da tabela fake. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//oStruct:AddTable('ZXX',{'ZXX_DOC'},'Codigo de Barra')
	//oStruct:AddField("Filial","Filial do Sistema","ZXX_FILIAL","C",FwSizeFilial(),0)	//"Filial"//"Filial do Sistema"
	
	For nX := 1 To Len(aCampos)
		aDadosCpo := TMSX3Cpo(aCampos[nX])
		oStruct:AddField(aDadosCpo[1],aDadosCpo[2],aCampos[nX],aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])

	Next nX                                                                                                                                

Else
	
	//----------------Estrutura para criação do campo-----------------------------
	// [01] C Nome do Campo
	// [02] C Ordem
	// [03] C Titulo do campo
	// [04] C Descrição do campo
	// [05] A Array com Help
	// [06] C Tipo do campo
	// [07] C Picture
	// [08] B Bloco de Picture Var
	// [09] C Consulta F3
	// [10] L Indica se o campo é evitável
	// [11] C Pasta do campo
	// [12] C Agrupamento do campo
	// [13] A Lista de valores permitido do campo (Combo)
	// [14] N Tamanho Maximo da maior opção do combo
	// [15] C Inicializador de Browse
	// [16] L Indica se o campo é virtual
	// [17] C Picture Variável
	
	oStruct := FWFormViewStruct():New()

	For nX := 1 To Len(aCampos)
		aDadosCpo := TMSX3Cpo(aCampos[nX])
		oStruct:AddField(aCampos[nX],StrZero(nX,2),aDadosCpo[1],aDadosCpo[2],{""},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil)
	Next nX	

EndIf

Return(oStruct)

//-------------------------------------------------------------------
/*{Protheus.doc} TMSA191

Função para a Manutenção do MDF-e para o Serie 3

@author Fabio Marchiori Sampaio	
@since 11/08/14
@version 1.0
*/
//-------------------------------------------------------------------
Function TMSA191Mnt()  

Local oFWMVCWin := Nil
Local oModel    := Nil
Local aSize	  := FWGetDialogSize( oMainWnd )

Pergunte('TMA191',.T.)

//--- Opcao Alteracao
oModel := FWLoadModel("TMSA191")
oModel:SetOperation(3)
oModel:Activate()

oView := FWLoadView("TMSA191")
oView:SetModel(oModel)
oView:SetOperation(3)

oFWMVCWin:= FWMVCWindow():New()
oFWMVCWin:SetUseControlBar(.T.)
oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0008)
oFWMVCWin:oView:BCloseOnOk := {|oView| MsgAlert("Botão Ok")}  
oFWMVCWin:Activate()


Return()                                  

//-------------------------------------------------------------------
/*{Protheus.doc} TMSA191POS

unção para validar e carregar a tela, para a geração do MDF-e

@author Fabio Marchiori Sampaio	
@since 20/08/14
@version 1.0
*/
//-------------------------------------------------------------------

Static Function TMSA191POS(oModel)

Local lRet		:= .T.
Local cSerman	:= SuperGetMv("MV_SERMAN", .F., "0")
Local dDatMan	:= Date()
Local nQdtVol	:= 0
Local nPeso	:= 0
Local nValMer	:= 0
Local nPesCob	:= 0
Local cCodVei	:= 0
Local nQdtDoc := 0		
Local nPesoM3	:= 0
Local cHoraBase 	:= Left( StrTran( Time(), ":", "" ), 4 )
Local nOperation	:= oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT

	dbSelectArea(cAliasMDF)
	(cAliasMDF)->( dbGoTop() )
	While !(cAliasMDF)->( EOF() ) 
		nQdtVol	+=(cAliasMDF)->DT6_QTDVOL
		nPeso	+=(cAliasMDF)->DT6_PESO
		nValMer	+=(cAliasMDF)->DT6_VALMER
		nPesCob	+=(cAliasMDF)->DT6_PESCOB
		nPesoM3	+=(cAliasMDF)->DT6_PESOM3
		cCodVei	:=(cAliasMDF)->DYB_CODVEI
		
		nQdtDoc ++		
	(cAliasMDF)->( dbSkip() )
	EndDo
	
	oModel:SetValue( 'TMSA191_01', 'DTX_FILIAL',	xFilial("DTX"))
	oModel:SetValue( 'TMSA191_01', 'DTX_FILMAN',	cFilAnt)
	oModel:SetValue( 'TMSA191_01', 'DTX_FILDCA',	cFilAnt)
	oModel:SetValue( 'TMSA191_01', 'DTX_SERMAN',	cSerman)				
	oModel:SetValue( 'TMSA191_01', 'DTX_FILORI',	cFilAnt)
	oModel:SetValue( 'TMSA191_01', 'DTX_DATMAN',	dDatMan)
	oModel:SetValue( 'TMSA191_01', 'DTX_HORMAN',	cHoraBase)
	oModel:SetValue( 'TMSA191_01', 'DTX_QTDDOC',	nQdtDoc)
	oModel:SetValue( 'TMSA191_01', 'DTX_QTDVOL',	nQdtVol)
	oModel:SetValue( 'TMSA191_01', 'DTX_PESO'  , 	nPeso)
	oModel:SetValue( 'TMSA191_01', 'DTX_PESOM3',	nPesoM3)
	oModel:SetValue( 'TMSA191_01', 'DTX_VALMER',	nValMer)
	oModel:SetValue( 'TMSA191_01', 'DTX_PESCOB',	nPesCob)
	oModel:SetValue( 'TMSA191_01', 'DTX_CDRDES',	' ')
	oModel:SetValue( 'TMSA191_01', 'DTX_CODVEI',	cCodVei)
	oModel:SetValue( 'TMSA191_01', 'DTX_TIPMAN',	'2')  //Eletronico 
	oModel:SetValue( 'TMSA191_01', 'DTX_STATUS',	'1')  //Em Aberto
	oModel:SetValue( 'TMSA191_01', 'DTX_RTIMDF',	'003 - O MDF-e ainda não foi transmitida - aguarde a transmissao') 		
	oModel:SetValue( 'TMSA191_01', 'DTX_RTFMDF',	'033 - Encerramento do MDF-e nao transmitido') 						
	oModel:SetValue( 'TMSA191_01', 'DTX_QTDCTE',	nQdtDoc)
	oModel:SetValue( 'TMSA191_01', 'DTX_NUMROM',	MV_PAR01)
	
	TMSA191DJ1( oModel, , 2)
	TMSA191RES( oModel, , 2)
	TMSA191CTE( oModel, , 2)

	(cAliasMDF)->(dbCloseArea())

EndIf	


Return (lRet)

//-------------------------------------------------------------------
/*{Protheus.doc} TMSA191PRE

Função para validar os dados antes de carregar a tela

@author Fabio Marchiori Sampaio	
@since 11/08/14
@version 1.0
*/
//-------------------------------------------------------------------

Static Function TMSA191PRE(oModel)

Local lRet			:= .T.
Local nOperation	:= oModel:GetOperation()
Local nMdfeExc  	:= SuperGetMv( "MV_MDFEEXC", .F., 0   ) //-- Prazo em horas para cancelamento do MDF-e autorizado

If nOperation == MODEL_OPERATION_INSERT
	If lRet := Pergunte('TMA191',.T.)
		If TMS191Rom()	
			If !Empty((cAliasMDF)->DUD_MANIFE)
				Help(,,'TMSA19102',, "Romaneio já possui MDFe " + (cAliasMDF)->DUD_MANIFE  ,1,0)
				lRet := .F.
			EndIf
		Else
			Help(,,'TMSA19103',, "Romaneio não encontrado.",1,0)			
			lRet := .F.			
		EndIf
	Else
		Help(,,'TMSA19104',, "Favor preencher os paramentros",1,0)
	EndIf

ElseIf nOperation == 1 // Visualização
	TMS191Rom()

ElseIf nOperation == MODEL_OPERATION_DELETE 
    
	If  !Empty(DTX->DTX_CHVMDF) .And. DTX->DTX_STIMDF = '1'
		Help("", 1, "TMSA19105")	// "Não é permitido excluir manifesto. Aguardando retorno da Sefaz"
		Return .F.		 
	ElseIf DTX->DTX_STIMDF == '2' .And. DTX->DTX_STFMDF <> '2' // 100 - Autorizado o uso do CT-e
		nHoras := Round(SubtHoras( DTX->DTX_DATMAN, SubStr(DTX->DTX_HORMAN,1,2) + ":" + SubStr(DTX->DTX_HORMAN,3,2) , ;
		Date(), 		  SubStr(Time(),1,2)		  + ":" + SubStr(Time(),4,2) ),2) //Prazo em Horas
		If nHoras > nMdfeExc
			Help(' ', 1, 'TMSA19106', ,"Prazo "+Alltrim(STR(nMdfeExc))+" horas",5,1 )
			Return .F.
		Else
			If DTX->DTX_CODEVE == '2' 
				Help(,,'TMSA19107',, "MDFe já foi autorizado pela SEFAZ, não será permitido a exclusão",1,0)			
				lRet := .F.			
			EndIf
		EndIf
	
	ElseIf DTX->DTX_STFMDF == '2'
		Help("", 1, "TMSA19108") // Não é permitido excluir manifesto MDF-e já encerrado na SEFAZ.
		Return .F.
	ElseIf Empty( DTX->DTX_NUMROM)
		Help("", 1, "TMSA19110") // Manifesto sem romaneio verifique os dados do manifesto.
		Return .F.
	EndIf
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*{Protheus.doc} TMSA191GRV

Função para gravar o manifesto.

@author Fabio Marchiori Sampaio	
@since 20/08/14
@version 1.0
*/
//-------------------------------------------------------------------

Static Function TMSA191GRV(oModel)

Local nOpc			:= oModel:GetOperation()
Local lRet			:= .T.
Local oModelDTX 	:= oModel:GetModel("TMSA191_01")
Local cNumRom		:= ''
Local cObsCan		:= ''      

If nOpc == MODEL_OPERATION_INSERT 
	
	BEGIN TRANSACTION
	
		cNumRom 	:= oModelDTX:GetValue("DTX_NUMROM")        
		oModel:SetValue( 'TMSA191_01', 'DTX_MANIFE', TMSA191Ser() )
		
		dbSelectArea("DUD")
		DUD->( dbSetOrder(08) )
		If DUD->( dbSeek(xFilial("DUD")+cNumRom) )

			While !DUD->( Eof() ) .And. DUD->DUD_FILIAL == xFilial("DUD") .And. DUD->DUD_NUMROM == cNumRom 
				RecLock("DUD",.F.)
					DUD->DUD_FILMAN := oModelDTX:GetValue("DTX_FILMAN")
					DUD->DUD_MANIFE := oModelDTX:GetValue("DTX_MANIFE")
					DUD->DUD_SERMAN := oModelDTX:GetValue("DTX_SERMAN")
				MsUnLock("DUD")
				DUD->( dbSkip() )
			EndDo
		Else
			lRet := .F.
		EndIf
	
		If !lRet
			DisarmTransaction()
		EndIf

		If lRet
			FwFormCommit(oModel)
		EndIf
             		
	END TRANSACTION

ElseIf nOpc == MODEL_OPERATION_DELETE 

	If TMSA191Obs(@cObsCan)
		BEGIN TRANSACTION
		
			cNumRom 	:= oModelDTX:GetValue("DTX_NUMROM")
			
			If !Empty(cNumRom)
				dbSelectArea("DUD")
				DUD->( dbSetOrder(08) )
				If DUD->( dbSeek(xFilial("DUD")+cNumRom) )
		
					While !DUD->( Eof() ) .And. DUD->DUD_FILIAL == xFilial("DUD") .And. DUD->DUD_NUMROM == cNumRom 
						RecLock("DUD",.F.)
						DUD->DUD_FILMAN := " "
						DUD->DUD_MANIFE := " "
						DUD->DUD_SERMAN := " "
						MsUnLock("DUD")
						DUD->( dbSkip() )
					EndDo
				Else
					lRet := .F.
				EndIf
			Else
				lRet := .F.						
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava Tabela para envio do Cancelamento da MDFe                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If DTX->DTX_TIPMAN == '2' .And. DTX->DTX_STIMDF == '2' .And. lRet
				RecLock("DYN", .T.)
				DYN->DYN_FILIAL:= xFilial('DYN')
				DYN->DYN_FILMAN:= oModelDTX:GetValue("DTX_FILMAN")
				DYN->DYN_MANIFE:= oModelDTX:GetValue("DTX_MANIFE")
				DYN->DYN_SERMAN:= oModelDTX:GetValue("DTX_SERMAN")
				DYN->DYN_FILORI:= oModelDTX:GetValue("DTX_FILORI")
				DYN->DYN_NUMROM:= oModelDTX:GetValue("DTX_NUMROM")
				DYN->DYN_DATMAN:= oModelDTX:GetValue("DTX_DATMAN")
				DYN->DYN_HORMAN:= oModelDTX:GetValue("DTX_HORMAN")
				DYN->DYN_FILDCA:= oModelDTX:GetValue("DTX_FILDCA")
				DYN->DYN_CDRDES:= oModelDTX:GetValue("DTX_CDRDES")
				DYN->DYN_CODVEI:= oModelDTX:GetValue("DTX_CODVEI")
				DYN->DYN_CHVMDF:= oModelDTX:GetValue("DTX_CHVMDF")
				DYN->DYN_PRIMDF:= oModelDTX:GetValue("DTX_PRIMDF")
				DYN->DYN_STIMDF:= oModelDTX:GetValue("DTX_STIMDF")
				DYN->DYN_RTIMDF:= oModelDTX:GetValue("DTX_RTIMDF")
				DYN->DYN_IDIMDF:= oModelDTX:GetValue("DTX_IDIMDF")
				DYN->DYN_CTGMDF:= oModelDTX:GetValue("DTX_CTGMDF")
				DYN->DYN_STCMDF:= '0'
				DYN->DYN_RTCMDF:= STR0012 //'016 - Cancelamento do MDF-e nao transmitido.
				DYN->DYN_IDCMDF:= ''
				MSMM(DYN->DYN_CODOBS,,,cObsCan,1,,,"DYN","DYN_CODOBS")
				MsUnLock()
			Else
				lRet := .F.
			EndIf
		    
			If Empty(DTX->DTX_STIMDF) .Or. DTX->DTX_STIMDF == '3'	
				lRet := .T.
			EndIf		

			If !lRet
				DisarmTransaction()
			EndIf

			If lRet
				FwFormCommit(oModel)
			EndIf
	
		END TRANSACTION
	Else
		lRet := .F.						
	EndIf

	If !lRet
		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro := oModel:GetErrorMessage()
		// A estrutura do vetor com erro é:
		// [1] identificador (ID) do formulário de origem
		// [2] identificador (ID) do campo de origem
		// [3] identificador (ID) do formulário de erro
		// [4] identificador (ID) do campo de erro
		// [5] identificador (ID) do erro
		// [6] mensagem do erro
		// [7] mensagem da solução
		// [8] Valor atribuído
		// [9] Valor anterior
		AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
		AutoGrLog( "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' )
		AutoGrLog( "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' )
		AutoGrLog( "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' )
		AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
		AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
		AutoGrLog( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
		AutoGrLog( "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' )
		AutoGrLog( "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' )
		MostraErro()   
	EndIf

EndIf

Return(lRet)


//-------------------------------------------------------------------
/*{Protheus.doc} TMS191Rom

Função conultar se o numero do romaneio existe

@author Fabio Marchiori Sampaio	
@since 20/08/14
@version 1.0
*/
//-------------------------------------------------------------------

Static Function TMS191Rom()

Local lRet		:= .F.

cAliasMDF		:= GetNextAlias()           

cQuery := " SELECT DYB.DYB_NUMROM, DUD.DUD_MANIFE, DT6.DT6_QTDVOL, DT6.DT6_PESO, DT6.DT6_VALMER,	DT6.DT6_PESCOB, DT6.DT6_PESOM3,	DYB.DYB_CODVEI " 

cQuery += " 	FROM " + RetSqlName("DYB") + " DYB " 
cQuery += " 	INNER JOIN " + RetSqlName("DYC") + " DYC " 
cQuery += " 		ON DYC.DYC_FILIAL = '"+xFilial("DYC")+"'" 
cQuery += " 	 AND DYC.DYC_NUMROM = DYB.DYB_NUMROM "
cQuery += " 		 AND DYC.D_E_L_E_T_ <> '*' "
cQuery += " 	INNER JOIN " + RetSqlName("DUD") + " DUD " 
cQuery += " 		ON DUD.DUD_FILIAL = '"+xFilial("DUD")+"'"
cQuery += " 		 AND DYC.DYC_NUMROM = DUD.DUD_NUMROM "
cQuery += " 		 AND DYC.DYC_FILDOC = DUD.DUD_FILDOC "
cQuery += " 		 AND DYC.DYC_DOC = DUD.DUD_DOC "
cQuery += " 		 AND DYC.DYC_SERIE = DUD.DUD_SERIE " 
cQuery += " 		 AND DUD.D_E_L_E_T_ <> '*' "
cQuery += " 	INNER JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += " 		ON DT6.DT6_FILIAL = '"+xFilial("DT6")+"'"
cQuery += " 		 AND DUD.DUD_FILDOC = DT6.DT6_FILDOC "
cQuery += " 		 AND DUD.DUD_DOC = DT6.DT6_DOC "
cQuery += " 		 AND DUD.DUD_SERIE = DT6.DT6_SERIE "
cQuery += " 		 AND DT6.D_E_L_E_T_ <> '*' "
cQuery += " 	WHERE DYB.DYB_FILIAL = '"+xFilial("DYB")+"'" 
cQuery += " 		 AND DYB.DYB_NUMROM = '"+ MV_PAR01+"'" 
cQuery += "  		 AND DYB.D_E_L_E_T_ <> '*'

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasMDF, .T., .F.)	

If (cAliasMDF)->( !Eof() )
	lRet := .T.
EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} 
Relacao do Percuso
@author Fabio Marchiori Sampaio
@since 22/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function TMSA191DJ1( oModel, lLoad, nTipConsulta )

Local oModelDJ1	:= oModel:GetModel("DETAIL_PER")	
Local aLoadDJ1	:= {}
Local nLinha		:= 0
Local cAliasDJ1	:= GetNextAlias()
Local cQuery		:= ""
Local lFirst		:= .T.

cQuery := "		SELECT DJ1_FILIAL, DJ1_NUMROM, DJ1_SEQUEN, DJ1_EST " 
cQuery += "			FROM " + RetSqlName("DJ1") + " DJ1 "
cQuery += " 		WHERE DJ1.DJ1_FILIAL = '"+xFilial("DJ1")+"'"

If nTipConsulta = 1
	cQuery += "		AND DJ1.DJ1_NUMROM  = '"+ Iif(!Empty(DTX->DTX_NUMROM), DTX->DTX_NUMROM, 'zz')+"'"
ElseIf nTipConsulta = 2
	cQuery += "		AND DJ1.DJ1_NUMROM  = '"+ Iif(!Empty(MV_PAR01), MV_PAR01, 'zz')+"'"
EndIf

cQuery += "			AND DJ1.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDJ1, .T., .F.)	

If nTipConsulta == 1	
	While (cAliasDJ1)->( !Eof() )
		
		nLinha++
		
		aAdd(aLoadDJ1,{nLinha,{(cAliasDJ1)->DJ1_FILIAL, (cAliasDJ1)->DJ1_NUMROM,(cAliasDJ1)->DJ1_SEQUEN,(cAliasDJ1)->DJ1_EST}})

		(cAliasDJ1)->( DbSkip() )
			
	EndDo                     

ElseIf nTipConsulta == 2	
	
	While !(cAliasDJ1)->( Eof() )
		If lFirst .And. oModelDJ1:Length() == 1
			lFirst := .F.
			oModelDJ1:GoLine(1)
		Else
			oModelDJ1:AddLine()
		EndIf
		oModelDJ1:SetValue("DJ1_NUMROM",(cAliasDJ1)->DJ1_NUMROM)
		oModelDJ1:SetValue("DJ1_SEQUEN",(cAliasDJ1)->DJ1_SEQUEN)	
		oModelDJ1:SetValue("DJ1_EST",(cAliasDJ1)->DJ1_EST)
		(cAliasDJ1)->( DbSkip() )
	EndDo	
	
EndIf	
	
	(cAliasDJ1)->(DbCloseArea())

Return(aLoadDJ1)

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Observação do Cancelamento
@author Fabio Marchiori Sampaio
@since 22/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TMSA191Obs(cObsCan)

Local oDlgObs
Local nOpcao   := 0
Local cObsDlg  := ""
Local lRet     := .T.

DEFINE MSDIALOG oDlgObs TITLE STR0013 FROM 15,20 TO 25,62 

@ 0.5,0.7  GET oGet VAR cObsDlg OF oDlgObs MEMO SIZE 150,40

DEFINE SBUTTON FROM 52,100 TYPE 1 OF oDlgObs ENABLE ACTION (nOpcao := 1,oDlgObs:End())
DEFINE SBUTTON FROM 52,128 TYPE 2 OF oDlgObs ENABLE ACTION (nOpcao := 0,oDlgObs:End())

ACTIVATE MSDIALOG oDlgObs CENTERED

If nOpcao == 0
	lRet:= .F.
Else
	If Empty(cObsDlg) .Or. Len(AllTrim(cObsDlg)) < 15
		Help("", 1, "TMSA19109") 
		lRet:= .F.
	Else
		cObsCan:= cObsDlg
	EndIf
EndIf

Return(lRet)     

//-------------------------------------------------------------------
/*{Protheus.doc} TMSA191Ser

Funçao para retornar o numero do manifesto.

@author Fabio Marchiori Sampaio	
@since 07/10/14
@version 1.0
*/
//-------------------------------------------------------------------
Static Function TMSA191Ser()

Local cRet  	  := ""
Local cNumNF  	  := ""
Local cFilSx5	  := xFilial("SX5")
Local __lChgX5FIL := ExistBlock("CHGX5FIL")
Local cTabSX5     := ""
Local cSerman	  := SuperGetMv("MV_SERMAN", .F., "0")
Local aSeries     := {}
Local nI          := 0

If !Empty(cSerman)
	IF __lChgX5FIL
		cFilSx5 := ExecBlock("CHGX5FIL",.f.,.f.)
	Endif

	aSeries  := FWGetSX5("PT")
	If Empty(aSeries)
		aSeries  := FWGetSX5("ZV")
	EndIf

	nI := Ascan(aSeries, { |x| x[1] + AllTrim(x[3]) == cFilSx5 + cSerman })
	If nI > 0
		cNumNF  := aSeries[nI][4]
	    cTabSX5 := aSeries[nI][2]
	EndIf
 	
	If !Empty(cNumNF)
		cNumNF := Soma1(AllTrim(cNumNF))
		FwPutSX5(cFilSX5, cTabSX5, cSerman, cNumNF, cNumNF, cNumNF )
		cRet := StrZero( Val( cNumNF ),TamSx3("DTX_MANIFE")[1],0 )
	Else
		Help(' ', 1, 'TMSA19019', ,"Série: "+Alltrim(cSerman) ) //"Série do manifesto não encontrada na tabela genérica ZV"
	EndIf
Else
	cRet  := GETSX8NUM("DTX","DTX_MANIFE")
EndIf

Return(cRet)