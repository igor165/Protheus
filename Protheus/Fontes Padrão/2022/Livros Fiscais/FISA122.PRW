#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA122.CH"

#define MB_YESNO                    4
#define MB_ICONEXCLAMATION          48

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA122
Notas Fiscais Emitidas de Crédito Presumido

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------
Function FISA122()

Local oBrowse := Nil

If AliasIndic("F0S") 
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("F0S")
	oBrowse:SetDescription(STR0001) //Notas Fiscais Emitidas de Crédito Presumido 
	oBrowse:Activate()
Else
	Help("",1,"Help","Help",STR0002,1,0) //Tabela F0S ainda não foi criada, rodar o update U_UPDSIGAFIS
EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

Local aRotina := {}	
	
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA122' OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA122' OPERATION 8 ACCESS 0 //Imprimir
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA122' OPERATION 5 ACCESS 0 //Excluir
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel		:= Nil
Local oStructCAB	:= FWFormStruct(1, "F0S",{|cCampo| MontaEstru(cCampo,"CAB")}) 
Local oStructITE	:= FWFormStruct(1, "F0S",{|cCampo| MontaEstru(cCampo,"ITE")})    
	
oModel	:=	MPFormModel():New('FISA122MOD')
	
oModel:AddFields('FISA122MOD',, oStructCAB)	   

oModel:AddGrid('FISA122ITE', 'FISA122MOD', oStructITE)
	
oModel:SetRelation("FISA122ITE", {{"F0S_FILIAL",'xFilial("F0S")'},{"F0S_DOCCRE","F0S_DOCCRE"},{"F0S_SERCRE","F0S_SERCRE"},{"F0S_FORCRE","F0S_FORCRE"},{"F0S_LOJCRE","F0S_LOJCRE"},{"F0S_EMICRE","F0S_EMICRE"}},F0S->(IndexKey(1)))

oModel:SetPrimaryKey({"F0S_FILIAL"},{"F0S_DOCCRE"},{"F0S_SERCRE"},{"F0S_FORCRE"},{"F0S_LOJCRE"},{"F0S_EMICRE"})	
	
oModel:GetModel("FISA122ITE"):SetUniqueLine({"F0S_DOCSAI"})

oModel:GetModel('FISA122MOD'):SetDescription(STR0005) //Nota de Crédito
oModel:GetModel('FISA122ITE'):SetDescription(STR0006) //Notas que compoem Crédito

Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= FWLoadModel("FISA122")
Local oStructCAB	:= FWFormStruct(2,"F0S",{|cCampo| MontaEstru(cCampo,"CAB")}) 
Local oStructITE	:= FWFormStruct(2,"F0S",{|cCampo| MontaEstru(cCampo,"ITE")}) 
Local oView		:= Nil
	
oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW", oStructCAB, 'FISA122MOD')	

oView:AddGrid('VIEW_ITE', oStructITE, 'FISA122ITE')

oView:CreateHorizontalBox("SUPERIOR", 20)
	
oView:CreateHorizontalBox('INFERIOR', 80)

oView:SetOwnerView("VIEW", "SUPERIOR")	
	
oView:SetOwnerView('VIEW_ITE', 'INFERIOR')

oView:EnableTitleView('VIEW', STR0001) 

oView:AddUserButton(STR0010,'',{|| F122DelItem(oModel,oView)},STR0010) //Exclusão
	
Return oView

//-------------------------------------------------------------------

/*/{Protheus.doc} MontaEstru
Monta estrutura de campos das telas superior e inferior

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------
Static Function MontaEstru(cCampo,cTipo)

Local	cCAB	:=	"F0S_FILIAL/F0S_DOCCRE/F0S_SERCRE/F0S_EMICRE/F0S_FORCRE/F0S_LOJCRE/"
Local	cITE	:=	"F0S_DOCSAI/F0S_SERSAI/F0S_EMISAI/F0S_CLISAI/F0S_LOJSAI/F0S_UFSAI/F0S_CRESAI/"

If cTipo = "CAB"
	Return AllTrim(cCampo)+"/"$cCab
Else
	Return AllTrim(cCampo)+"/"$cIte
EndIf

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Monta a observação da Nota Fiscal 
Chamada através da Fórmula
Obs= Emissão, Nota Fiscal, UF, Valor Crédito

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------
Function F122NF(cRotina, cMens)

Local aArea	:= GetArea()
Local cObs		:= "" 
Local cDoc		:= ""
Local cSer		:= ""
Local cFor		:= ""
Local cLoj		:= ""
Local dEmi		:= ""           

If cRotina=="LIVRARRAYOBS" .Or. cRotina=="REGC110"
	cDoc	:= SF3->F3_NFISCAL
	cSer	:= SF3->F3_SERIE
	cFor	:= SF3->F3_CLIEFOR
	cLoj	:= SF3->F3_LOJA
	dEmi	:= SF3->F3_EMISSAO
Else      
	cDoc	:= SF1->F1_DOC
	cSer	:= SF1->F1_SERIE
	cFor	:= SF1->F1_FORNECE
	cLoj	:= SF1->F1_LOJA
	dEmi	:= SF1->F1_EMISSAO
Endif

BeginSQL Alias "OBS"
	COLUMN F0S_EMICRE AS DATE
	COLUMN F0S_EMISAI AS DATE

	SELECT *   
	FROM %Table:F0S% 
	WHERE F0S_FILIAL=%xFilial:F0S% AND F0S_DOCCRE=%Exp:cDoc% AND F0S_SERCRE=%Exp:cSer% AND F0S_FORCRE=%Exp:cFor% AND F0S_LOJCRE=%Exp:cLoj% AND F0S_EMICRE=%Exp:dEmi% AND D_E_L_E_T_=''
EndSql

dbSelectArea("OBS")
While !EOF()
	cObs += Dtoc(F0S_EMISAI) + " " + AllTrim(F0S_DOCSAI) + " " + F0S_UFSAI + " " + AllTrim(Transform(F0S_CRESAI,"@e 99,999,999,999.99")) + " "    
	DBSkip()
Enddo
dbCloseArea()

If cRotina<>"LIVRARRAYOBS" .And. cRotina<>"REGC110"
	cObs += Space(1) + cMens
Endif	 

RestArea(aArea)	

Return cObs

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Permite a exclusão do item

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------

Static Function F122DelItem(oModel,oView)

If "PRE"$F0S->F0S_DOCCRE
	If MessageBox(STR0009,STR0010,MB_YESNO)==6
		RecLock("F0S",.F.)
		F0S->(dbDelete())
		MsUnLock()
	Endif	
Else
	MessageBox(STR0008, "", 48) //Operação permitida apenas para Pré-Nota
Endif	

oView:Refresh

Return
