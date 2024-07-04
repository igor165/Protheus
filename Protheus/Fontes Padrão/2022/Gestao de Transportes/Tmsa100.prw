#Include "Protheus.ch"
#INCLUDE "Tmsa100.ch"
#INCLUDE "FWMVCDEF.CH"                   

//===========================================================================================================
/* Cadastro de Consignatarios
@author  	Katia
@version 	P11       
@build		700120420A
@since 	    28/08/2013
@Parametros ExpA1 - Array Contendo os Campos (Rot. Automatica)           
            ExpN1 - Opcao Selecionada (Rot. Automatica)                  
@return 	*/
//===========================================================================================================
FUNCTION TMSA100(aRotAuto, nOpcAuto)

Private l100Auto := (Valtype(aRotAuto) == "A")                                   

Private aRotina:= MenuDef()
    
If l100Auto
	FwMvcRotAuto(ModelDef(),"DTI",nOpcAuto,{{"MdFieldDTI",aRotAuto}},.T.,.T.)  //Chamada da rotina automatica através do MVC
Else
	oBrowse:= FwMBrowse():New()
	oBrowse:SetAlias( 'DTI' )
	oBrowse:SetDescription( OemToAnsi(STR0001) )
	oBrowse:Activate()
EndIf	

Return

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Consignatarios
@author  	Katia
@version 	P11      
@build		700120420A
@since 	    28/08/2013
@return 	oModel - Modelo de Dados */
//===========================================================================================================
Static Function ModelDef()

Local oModel	:= Nil
Local oStruDTI	:= FwFormStruct( 1, "DTI" )

oModel:= MpFormModel():New( "TMSA100", /*bPre*/,{ |oModel| TMSA100TudOk( oModel ) }, /*bCommit*/, /*bCancel*/ )

oModel:SetDescription( OemToAnsi(STR0001) )	    //Consignatarios

oModel:AddFields( "MdFieldDTI", Nil, oStruDTI )

oModel:GetModel("MdFieldDTI"):SetDescription(STR0001)  

oModel:SetPrimaryKey({"DTI_FILIAL", "DTI_CLIREM", "DTI_LOJREM", "DTI_CLIDES", "DTI_LOJDES"})

Return( oModel )

//===========================================================================================================
/* Retorna a View (tela) da rotina Consignatarios         
@author  	Katia              
@version 	P11      
@build		700120420A
@since 	    28/08/2013
@return 	oView -  */
//===========================================================================================================
Static Function ViewDef()                  

Local oView		:= Nil
Local oModel	:= FwLoadModel("TMSA100")
Local oStruDTI	:= FwFormStruct( 2, "DTI" )

oView:= FwFormView():New()
oView:SetModel( oModel )

oView:AddField("VwFieldDTI",oStruDTI, "MdFieldDTI")

oView:CreateHorizontalBox("Field",100)                 

oView:EnableTitleView("VwFieldDTI",STR0001) //-- Consignatarios

oView:SetOwnerView("VwFieldDTI", "Field")

Return( oView )

//===========================================================================================================
/* Retorna as operacoes disponiveis para a rotina Consignatarios         
@author  	Katia
@version 	P11       
@build		700120420A
@since 	    28/08/2013
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Static Function MenuDef()

Private aRotina		:= {	{ STR0002,	"AxPesqui"			,0 , 1,,.F. },;  	//"Pesquisar"
							{ STR0003,	"VIEWDEF.TMSA100"	,0 , 2 },;  		//"Visualizar"
							{ STR0004,	"VIEWDEF.TMSA100"	,0 , 3 },;  		//"Incluir"
							{ STR0005,	"VIEWDEF.TMSA100"	,0 , 4 },;  		//"Alterar"
							{ STR0006,	"VIEWDEF.TMSA100"	,0 , 5 } }  		//"Excluir"
						
Return( aRotina ) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA100Tud³ Autor ³ Patricia A. Salomao   ³ Data ³ 07.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da Tela                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA100TudOk()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TMSA100TudOk(oModel)

Local aPerfil	:= {}
Local lRet      := .T.

If Inclui
	If ! ExistChav("DTI",M->DTI_CLIREM+M->DTI_LOJREM+M->DTI_CLIDES+M->DTI_LOJDES,1)
		lRet:= .F.
	EndIf
EndIf			
   
If lRet .And. M->DTI_CLIREM+M->DTI_LOJREM == M->DTI_CLIDES+M->DTI_LOJDES
	Help("",1,"TMSA10001") // Destinatario Nao Pode ser igual ao Remetente
	lRet:= .F.
EndIf	

//-- Obtem o perfil do cliente remetente
If lRet
	aPerfil := TmsPerfil(M->DTI_CLIREM,M->DTI_LOJREM,.F.)
	If	Empty(aPerfil)
		lRet:= .F.
	EndIf
EndIf	

If lRet .And. aPerfil[4] == StrZero(1,Len(DUO->DUO_FOBDIR))
	Help("",1,"TMSA10002") // Remetente não Autorizado, pois o mesmo está configurado como FOB Dirigido
	lRet:= .F.
EndIf	

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA100Vld³ Autor ³ Patricia A. Salomao   ³ Data ³07.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do sistema                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA100Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA100Vld()
Local cCampo := ReadVar()
Local lRet   := .T.

If cCampo $ "M->DTI_CLICON.M->DTI_LOJCON" 
   If !Empty( M->DTI_CLICON ) .And. !Empty( M->DTI_LOJCON )
	   lRet := TMSVldCli(M->DTI_CLICON,M->DTI_LOJCON) // Valida se o Codigo Informado e' de Cliente Generico
   EndIf
ElseIf cCampo $ "M->DTI_CALFRE"
	If DTI->(FieldPos("DTI_TIPPER")) > 0
		M->DTI_TIPPER := M->DTI_CALFRE
	EndIf
EndIf

Return lRet                        
