#INCLUDE "TMSA610.ch"
#Include "PROTHEUS.ch"   
#INCLUDE "FWMVCDEF.CH" 

Static aMemos := {{"DV2_CODOBS", "DV2_OBS"}}

//===========================================================================================================
/* Observacoes de clientes
@author  	Katia
@version 	P11       
@build		700120420A
@since 	    29/08/2013
@Parametros ExpA1 - Array Contendo os Campos (Rot. Automatica)           
            ExpN1 - Opcao Selecionada (Rot. Automatica)                  
@return 	*/
//===========================================================================================================
Function TMSA610(aRotAuto,nOpcAuto)

/* Especifica os campos de observacoes. */
Private l610Auto := (ValType(aRotAuto) == "A")           

If l610Auto
    FwMvcRotAuto(ModelDef(),"DV2",nOpcAuto,{{"MdFieldDV2",aRotAuto}},.T.,.T.)  //Chamada da rotina automatica atraves do MVC
Else
	oBrowse:= FwMBrowse():New()
	oBrowse:SetAlias("DV2")
	oBrowse:SetDescription( OemToAnsi(STR0001) )
	oBrowse:Activate()
EndIf

Return Nil

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Observacoes de Clientes
@author  	Katia
@version 	P11      
@build		700120420A
@since 	    29/08/2013
@return 	oModel - Modelo de Dados */
//===========================================================================================================
Static Function ModelDef()
         
Local oModel:= Nil
Local oStruDV2:= FwFormStruct( 1, "DV2" )

oModel:= MpFormModel():New( "TMSA610", /*bPre*/,{ |oModel| PosVldMdl( oModel ) },  { |oModel| CommitMdl( oModel ) }, /*bCancel*/ )

oModel:SetDescription( OemToAnsi(STR0001) )  //Observacoes de Clientes

oModel:AddFields( "MdFieldDV2", Nil, oStruDV2 )

oModel:GetModel( "MdFieldDV2" ):SetDescription(STR0001)

oModel:SetPrimaryKey({"DV2_FILIAL","DV2_CODCLI","DV2_LOJCLI","DV2_SEQUEN"})

Return ( oModel )                                                        

//===========================================================================================================
/* Retorna a View (tela) da rotina Observacoes Clientes
@author  	Katia              
@version 	P11      
@build		700120420A
@since 	    29/08/2013
@return 	oView -  */
//===========================================================================================================
Static Function ViewDef()                  
                              
Local oView		:= Nil
Local oModel	:= FwLoadModel("TMSA610")
Local oStruDV2	:= FwFormStruct( 2, "DV2" )
                                 
oStruDV2:RemoveField("DV2_CODOBS")

oView:= FwFormView():New()   

oView:SetModel( oModel )

oView:AddField( "VwFieldDV2", oStruDV2, "MdFieldDV2" ) 

oView:CreateHorizontalBox("Field", 100)

oView:EnableTitleView( "VwFieldDV2", STR0001 )  //Observacoes de Clientes

oView:SetOwnerView("VwFieldDV2","Field")

Return ( oView ) 

//===========================================================================================================
/* Retorna as operacoes disponiveis para a rotina Observacoes de Clientes
@author  	Katia
@version 	P11       
@build		700120420A
@since 	    29/08/2013
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Static Function MenuDef()

Private aRotina:= {	{ STR0003,	"AxPesqui"			,0 , 1,,.F. },;  	//"Pesquisar"
					{ STR0004,	"VIEWDEF.TMSA610"	,0 , 2 },;  		//"Visualizar"
					{ STR0005,	"VIEWDEF.TMSA610"	,0 , 3 },;  		//"Incluir"
					{ STR0006,	"VIEWDEF.TMSA610"	,0 , 4 },;  		//"Alterar"
					{ STR0007,	"VIEWDEF.TMSA610"	,0 , 5 } }  		//"Excluir"

Return ( aRotina )                                             

//===========================================================================================================
/* Valid do Model
@author  	Katia
@version 	P11       
@build		700120420A
@since 	    28/08/2013
@return 	lRet */
//===========================================================================================================
Static Function PosVldMdl(oModel)

Local lRet		 	:= .T.
Local lExistBlock	:=ExistBlock("TM610TOK") 
Local nOperation	:= oModel:GetOperation()
Local lExclusao		:= .F.
                    
If nOperation == 5
	lExclusao := .T.   
EndIf

// Executa ponto de entrada 
If lExistBlock
	lRet:=ExecBlock("TM610TOK",.F.,.F.,{lExclusao})
	If Valtype(lRet) # "L"
		lRet:=.T.
	EndIf	
EndIf

Return ( lRet )

//===========================================================================================================
/* Gravação do Model
@author  	Katia
@version 	P11 
@build		700120420A
@since 		30/08/2013
@return 	lRet */
//===========================================================================================================
Static Function CommitMdl( oMdl )

Local lRet 		:= .F.
Local nOpcx		:= oMdl:GetOperation()
Local oMdlDV2	:= oMdl:GetModel('MdFieldDV2')            		
Local aArea		:= DV2->( GetArea() )
Local nI		:= 0  
Local cCpoDV2	:= '' 

Begin Transaction
	
	If FwFormCommit( oMdl )
		For nI := 1 To Len(aMemos)
			cCpoDV2:= aMemos[nI,1]							
			MSMM(&cCpoDV2,,,oMdlDV2:GetValue("DV2_OBS"),1,,,'DV2',aMemos[nI,1])						
		Next nI     
		lRet:= .T.
	Else                   
		DisarmTransaction()
	EndIf	
	
End Transaction

RestArea( aArea )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA610Vld³ Autor ³ Robson Alves          ³ Data ³14.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do campo.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA610Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaTMS - Gestao de Transporte                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA610Vld()
Local lRet	 := .T.

Local cCampo := AllTrim(ReadVar())

If	cCampo == "M->DV2_CODCLI" .Or. cCampo == "M->DV2_LOJCLI"
	/* Obtem a sequencia do cliente. */
	DV2->(dbSetOrder(1))
	DV2->(dbSeek(xFilial("DV2") + M->DV2_CODCLI + M->DV2_LOJCLI + Replicate("Z", Len(DV2->DV2_SEQUEN)), .T.))  
	DV2->(dbSkip(-1))
	If DV2->(DV2_CODCLI + DV2_LOJCLI) == M->(DV2_CODCLI + DV2_LOJCLI)
		M->DV2_SEQUEN := Soma1(DV2->DV2_SEQUEN)
	Else
		M->DV2_SEQUEN := StrZero(1, Len(DV2->DV2_SEQUEN))
	EndIf		
EndIf

Return( lRet )

