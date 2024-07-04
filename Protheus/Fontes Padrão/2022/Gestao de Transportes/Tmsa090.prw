#include "PROTHEUS.ch"
#INCLUDE "Tmsa090.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'

//-----------------------------------------------------------------------------------------------------------
/* Destino de Calculo 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Function TMSA090(aRotAuto, nOpcAuto)

Local lAutTMS090	:= ( ValType( aRotAuto ) == "A" )
Local aAutoCab		:= {}
Local oMBrowse 		:= Nil

Private aRotina   := MenuDef()

If !lAutTMS090
	oMBrowse:= FWMBrowse():New()	
	oMBrowse:SetAlias( "DTH" )
	oMBrowse:SetDescription( STR0001 )
	oMBrowse:Activate()
Else
	aAutoCab 	:= aClone(aRotAuto)
	FwMvcRotAuto( ModelDef(), "DTH", nOpcAuto, { { "MdFieldDTH", aAutoCab } } )  //Chamada da rotina automatica atrav�s do MVC
EndIf

Return()

//===========================================================================================================
/* Retorna as opera��es disponiveis para o Destino de Calculo.
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	aRotina - Array com as op�oes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()
Local aArea		:= GetArea() 

Private	aRotina	:= {}

aAdd( aRotina, { STR0005, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0006, "VIEWDEF.TMSA090"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0007, "VIEWDEF.TMSA090"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0008, "VIEWDEF.TMSA090"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0009, "VIEWDEF.TMSA090"  , 0, 5, 3, Nil } ) // Excluir	

If ExistBlock("TMA090MNU")
	ExecBlock("TMA090MNU",.F.,.F.)
EndIf

RestArea( aArea )

Return(aRotina)

//-----------------------------------------------------------------------------------------------------------
/* Destino de Calculo 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 	:= NIL
Local oStruDTH 	:= Nil

oStruDTH := FwFormStruct( 1, "DTH" ) 

oModel := MPFormModel():New ( "TMSA090",/*bPreValid*/, /*bPosValid*/,, /*bCancel*/ )

oModel:SetDescription(STR0001)

oModel:AddFields( 'MdFieldDTH',	, oStruDTH, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)	

oModel:SetPrimaryKey({"DTH_FILIAL","DTH_CLIDEV","DTH_LOJDEV","DTH_CDRDES"})


Return( oModel )

//-----------------------------------------------------------------------------------------------------------
/* Destino de Calculo 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView 	:= NIL
Local oModel   	:= NIL 
Local oStruDTH 	:= Nil

oModel   := FwLoadModel( "TMSA090" )
oStruDTH := FwFormStruct( 2, "DTH" ) 

oView := FwFormView():New()
oView:SetModel(oModel)	

oView:AddField( 'VwFieldDTH', oStruDTH , 'MdFieldDTH' )

oView:CreateHorizontalBox( 'TOPO'   , 100 )

oView:SetOwnerView( 'VwFieldDTH' , 'TOPO' )

Return( oView )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA090Vld� Autor � Alex Egydio           � Data �15.04.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes do sistema                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA090Vld()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TmsA090Vld()
Local cCampo   := ReadVar()
Local lRet	   := .T.
Local aAreaAnt := GetArea()

If cCampo == 'M->DTH_CDRDES' .Or.  cCampo == 'M->DTH_CDRCAL'
  DUY->( DbSetOrder( 1 ) )
  If DUY->( MsSeek( xFilial('DUY') + &( ReadVar() ), .F. ) ) .And. DUY->DUY_GRPSUP == 'MAINGR'
      Help('', 1, 'TMSA09001') // Nao Informe Regiao com grupo superior igual a MAINGR
      lRet:=.F.
  EndIf 
EndIf

If lRet .And. cCampo == "M->DTH_CDRDES"
	DTH->(dbSetOrder(1))
	If DTH->(dbSeek(xFilial("DTH")+M->DTH_CLIDEV+M->DTH_LOJDEV+M->DTH_CDRDES))
		lRet := .F.
		Help("", 1, "TMSA09002") // Destino de Calculo JA Cadastrado
	EndIf
EndIf

RestArea(aAreaAnt)

Return( lRet )