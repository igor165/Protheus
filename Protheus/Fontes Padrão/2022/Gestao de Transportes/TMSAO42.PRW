#Include "TMSAO42.ch"
#Include "FWMVCDEF.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º  TMSAO42   º Autor ºGuilherme Gaiofatto º Data º 18/02/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±   
±±º Programa  º  Cadastro de Justificativas                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   º TMSAO42()                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametrosº                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   º NIL                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       º TMS - Gestao de Transportes                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                              

Function TMSAO42() 

Local oBrowse 	:= Nil
Local lAptJor	:= SuperGetMv("MV_CONTJOR",,.F.) //-- Apontamento da jornada de trabalho do motorista

Private aRotina := MenuDef() 

If !lAptJor
	Help(,1,"TMSAO3002" ) //-- Jornada nao habilitada
	Return
EndIf

DbSelectArea('DAX')  

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DAX")
oBrowse:SetDescription(STR0001) 
oBrowse:Activate()

Return Nil    

//-------------------------------------
/*	Modelo de Dados
@author		Guilherme Gaiofatto
@version	P11 R11.80
@build		7.00.101202A
@since		31/03/2011
@return		oModel Objeto do Modelo*/
//-------------------------------------
Static Function ModelDef()
Local oModel	:= Nil
Local oStruDUT	:= FWFormStruct(1,"DAX")
Local bPosValid	:= { |oMdl| TA042ExcOk(oMdl) }

oModel:= MpFormMOdel():New("TMSAO42",/*PREVAL*/, bPosValid/*bPosValid*/, /*Commit*/,/*BCANCEL*/)
oModel:AddFields("TMSAO42_DAX",Nil,oStruDUT,/*prevalid*/,,/*bCarga*/)
oModel:SetDescription(STR0001) 
oModel:GetModel("TMSAO42_DAX"):SETDESCRIPTION(STR0001) 
oModel:SetPrimaryKey({"DAX_FILIAL+DAX_CODJUS"})

Return ( oModel )           

//---------------------------------------
/*	Exibe browser de acordo com estrutura
@author 	Guilherme Gaiofatto
@version	P10 R11.80
@build		7.00.101202A
@since		31/03/2011
@return		oView Objeto do View*/
//---------------------------------------
Static Function ViewDef()

Local oModel := FwLoadModel("TMSAO42")
Local oView  := Nil

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField("TMSAO42_DAX", FWFormStruct(2,"DAX"))
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("TMSAO42_DAX","TELA")  

Return(oView)
                                       
//---------------------------------------
/*	MenuDef do Browser
@author		Guilherme Gaiofatto
@version	P10 R11.80
@build		7.00.101202A
@since		31/03/2011
@return		aRotina array com o MENUDEF*/
//---------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"         OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAO42" OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSAO42" OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAO42" OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSAO42" OPERATION 5 ACCESS 0 // "Excluir"

Return ( aRotina )



//-----------------------------------------------------
/*	Valida em MVC a exclusão do registro.
@author		Guilherme Gaiofatto
@version	P10 R1.8
@build		7.00.101202A
@since		31/03/2011
@return		lRet Valor lógico que indica o retorno*/
//------------------------------------------------------
Function TA042ExcOk(oMdl)     

Local lRet      :=.T.
Local nOperation:= 0
Local cQuery    :=""
Local cAliasTop := "DAY"

nOperation := oMdl:GetOperation()

If nOperation == 5

	cAliasTop := GetNextAlias()
	cQuery := "SELECT COUNT(*) COUNT FROM "+RetSqlName("DAY")+" "
	cQuery += "WHERE DAY_FILIAL='"+xFilial("DAY")+"' AND "
	cQuery += "DAY_CODJUS='"+DAX->DAX_CODJUS+"' AND D_E_L_E_T_=' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
	If (cAliasTop)->(COUNT) > 0 .And. (cAliasTop)->( !Eof() ) 
		Help( "" , 1 ,"TMSAO4201") //-- "Justificativa cadastrada em um apontamento nao pode ser deletada"
		lRet:=.F.
	EndIf
	(cAliasTop)->(dbCloseArea())   
EndIf

Return lRet