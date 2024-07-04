#Include "TMSAO41.ch"
#Include "FWMVCDEF.CH"

#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º  TMSAO41   º Autor ºGuilherme Gaiofatto º Data º 18/02/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±   
±±º Programa  º  Apontamento de Justificativas                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   º TMSAO41()                                                 º±±
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

Function TMSAO41(aRotAuto,nOpcAuto) 

Local oBrowse := Nil
Local   lAptJor := SuperGetMv("MV_CONTJOR",,.F.) //-- Apontamento da jornada de trabalho do motorista
Private aRotina := MenuDef()   

If !lAptJor
	Help(,1,"TMSAO3002" ) //-- Jornada nao habilitada
	Return
EndIf

DbSelectArea('DAY')

If aRotAuto == Nil
	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("DAY")
	oBrowse:SetDescription(STR0001)
	//-- Adiciona legendas ao Browse
	oBrowse:AddLegend('DAY_STATUS== "1"', "YELLOW" ,STR0007 )
	oBrowse:AddLegend('DAY_STATUS== "2"', "RED"    ,STR0008 )
	oBrowse:Activate()  
Else  
	FwMvcRotAuto(ModelDef(),"DAY",nOpcAuto,{{"MdFieldDAY",aRotAuto}})  //-- Chamada da rotina automatica através do MVC
EndIf

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
Local oStruDAY	:= FWFormStruct(1,"DAY")
Local bPosValid	:= { |oMdl| TA041TOk(oMdl) }

oModel:= MpFormMOdel():New("TMSAO41",/*PREVAL*/, bPosValid , { |oModel| CommitMdl( oModel ) } ,/*BCANCEL*/)
oModel:AddFields("MdFieldDAY",Nil,oStruDAY,/*prevalid*/,,/*bCarga*/)
oModel:SetDescription(STR0002) 
oModel:GetModel("MdFieldDAY"):SetDescription(STR0002) 
oModel:SetPrimaryKey({"DAY_FILIAL","DAY_CODMOT","DAY_DATAPT","DAY_HORAPT"})

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

Local oModel := FwLoadModel("TMSAO41")
Local oView := Nil

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField("VwFieldDAY", FWFormStruct(2,"DAY"),"MdFieldDAY")
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VwFieldDAY","TELA")  

Return(oView)
                                       
//---------------------------------------
/*	MenuDef do Browser
@author		Guilherme Gaiofatto
@version	P10 R1.8
@build		7.00.101202A
@since		31/03/2011
@return		aRotina array com o MENUDEF*/
//---------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"         OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAO41" OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAO41" OPERATION 4 ACCESS 0 // "Apontar Justificativa"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSAO41" OPERATION 5 ACCESS 0 // "Excluir" 

Return ( aRotina )

//-----------------------------------------------------
/*	Valida a inclusão e alteração do registro.
@author		Guilherme Gaiofatto
@version	P10 R1.8
@build		7.00.101202A
@since		31/03/2011
@return		lRet Valor lógico que indica o retorno*/
//------------------------------------------------------
Function TA041TOk(oMdl)   

Local lRet	:= .T.     
Local nOpcx	:= oMdl:GetOperation()

If IsInCallStack("TMSA400MNT") .And. M->DAY_STATUS == '2'  
    Help( "" , 1 ,"TMSAO4101") //-- "Informe um status diferente de: 'Justificativa pendente de análise'
    lRet := .F.
EndIf  
If nOpcx == MODEL_OPERATION_UPDATE .And. ( Empty(M->DAY_OBS) .Or. Empty(M->DAY_CODJUS) ) 
	Help( "" , 1 ,"TMSAO4102") //-- "É obrigatório o preenchimento dos campos: Observação e Código de Justificativa."
	lRet := .F.  
EndIf
If nOpcx == MODEL_OPERATION_DELETE .And. AllTrim( FunName() ) == 'TMSAO41'
	Help( "" , 1 ,"TMSAO4103") //-- "Exclusão permitida somente a partir da rotina que originou a pendência de justificativa."
	lRet := .F.  
EndIf

Return lRet


//-------------------------------------------------------------------
/* CommitMdl
Função de gravação do model

@author  Caio Murakami
@since   26/02/2013
@version 1.0
*/
//-------------------------------------------------------------------

Static Function CommitMdl(oModel)  
Local oMdlField := oModel:GetModel("MdFieldDAY")
Local cCodMot 	 := oMdlField:GetValue("DAY_CODMOT")
Local cAptJor   := oMdlField:GetValue("DAY_APTJOR")
Local dDatApt   := oMdlField:GetValue("DAY_DATAPT")
Local cHorApt   := oMdlField:GetValue("DAY_HORAPT")
Local cFilOri 	 := oMdlField:GetValue("DAY_FILORI")
Local cViagem	 := oMdlField:GetValue("DAY_VIAGEM")
Local aAreaDEW  := DEW->( GetArea() ) 
Local nOpc		 := oMdlField:GetOperation()
Local lRet 		 := .T.

//-- Na justificativa o status fica como analisado
If nOpc == 4  
	//-- 1=Justificativa analisada ;2=Pendente de Analise	
	oMdlField:SetValue("DAY_STATUS","1")
EndIf

lRet := FwFormCommit(oModel) 
 
IF lRet .And. nOpc == 4 
	//-- Atualiza status do apontamento quando justificativa é realizada pela propria rotina
	DEW->(dbSetOrder(1))
	If DEW->(dbSeek(xFilial('DEW')+cCodMot+cAptJor+Dtos(dDatApt)+cHorApt))
		RecLock('DEW',.F.)
		DEW->DEW_STATUS := '3' //-- Atrasado e justificado
		MsUnLock()
	EndIf
	If !Empty(cViagem) 
	   TmsBlqViag(cFilOri,cViagem,,,,,,,,,,,,,,{cCodMot})
	EndIf
EndIf

RestArea( aAreaDEW ) 
Return lRet 