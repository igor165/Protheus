#include "AGRA751.CH"
#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"

/** -------------------------------------------------------------------------------------
{Protheus.doc}
Romaneio de Vendas
@param: 	Nil
@author: 	Joaquim Burjack
@since: 	06/08/2014
@Uso: 		UBA
------------------------------------------------------------------------------------- **/
Function AGRA751()
Local bKeyF12    := { || aPerBal := AGRX003E( .T., "AGRA751001" ) }
Local oBrowse    := Nil
Private aPerBal	 := AGRX003E(.F.,"AGRA751001")
Private aFardos	 := {}
Private aFdDisp	 := {}
Private vVetNDXS := {"DXS_STATUS","DXS_PSSUBT","DXS_PSDESC","DXS_PSBASE","DXS_PSEXTR"}
Private vVetNDXT := {"DXT_TIPO","DXT_BLOCO","DXT_PSBRUT","DXT_PSLIQU","DXT_PSDIF","DXT_PERC","DXT_PSRAT","DXT_PSFISC"}
Static lModified := .F.

// Seta acao para tecla F12
SetKey( VK_F12, bKeyF12 )

// Instancia o Browser
oBrowse := FWMBrowse():New()
oBrowse:SetAlias( "DXS" )
oBrowse:SetDescription( STR0001 ) //"Romaneios de Venda"
oBrowse:SetMenuDef("AGRA751")
oBrowse:DisableDetails()

// Adiciona Legendas no Browser
AGRLEGEBROW(@oBrowse,{{"DXS_STATUS == '1'",X3CBOXDESC('DXS_STATUS','1')},{"DXS_STATUS == '2'",X3CBOXDESC('DXS_STATUS','2')},;
                      {"DXS_STATUS == '3'",X3CBOXDESC('DXS_STATUS','3')},{"DXS_STATUS == '4'",X3CBOXDESC('DXS_STATUS','4')}})
// Ativa o Browser
oBrowse:Activate()

// Retira acao da tecla F12
SetKey( VK_F12, Nil )

Return()

/** -------------------------------------------------------------------------------------
{Protheus.doc} ModelDef
Retorna o modelo de dados para a rotina

@author: 	Joaquim Burjack
@since: 	06/08/2014
@Uso: 		UBA@Uso: 		AGRA751
------------------------------------------------------------------------------------- **/
Static Function ModelDef()
Local oModel   	:= Nil
Local oStruDXS 	:= FwFormStruct( 1, "DXS" )
Local oStruDXT 	:= FwFormStruct( 1, "DXT" )
Default VVETNDXT := {"DXT_TIPO","DXT_BLOCO","DXT_PSBRUT","DXT_PSLIQU","DXT_PSDIF","DXT_PERC","DXT_PSRAT","DXT_PSFISC"}

// Instacia o modelo de dados
oModel := MpFormModel():New( "AGRA751", , { |oMdl| AGR751LEFIM( oMdl ) } ,  { |oMdl| GrvModelo( oMdl ) }) //, { | oMdl | CanModelo( oMdl ) } )

oModel:SetDescription( STR0002 ) //"Modelo de Dados dos Romaneios de venda"
    
// Altera a propriedade do X3_OBRIGAT 
AGROBRIGMVC(@oStruDXT,vVetNDXT) 

// Altera a propriedade do X3_VALID 
AGRVALIDMVC(@oStruDXT,vVetNDXT)

// Adiciona a estrutura dos campos da field no modelo de dados
oModel:AddFields( "MDFIELDDXS",,oStruDXS )
oModel:GetModel( "MDFIELDDXS" ):SetDescription( STR0003 ) //"Cabeçalho da venda"

// Adiciona a estrutura dos camnpos da grid no modelo de dados
oModel:AddGrid( "MDGRIDDXT", "MDFIELDDXS", oStruDXT) //, {|a,b,c,d,e,f| PreLinha(a,b,c,d,e,f ) } )
oModel:GetModel( "MDGRIDDXT" ):SetDescription( STR0004 ) //"Itens da venda"
//oStruDXT:AddField(STR0074,STR0074,'C6_VALOR','N',14,2,{|| NAOVAZIO()},NIL,,NIL,,NIL,NIL,.F.)

oModel:SetRelation( "MDGRIDDXT",{{"DXT_FILIAL", "xFilial('DXT')"},{"DXT_CODIGO", "DXS_CODIGO"}},DXT->(IndexKey(1)))

// Validação de linha duplicada
oModel:GetModel( "MDGRIDDXT" ):SetUniqueLine( { 'DXT_NUMIE', 'DXT_ITEMIE' } )

// Seta preenchimento opicional da Grid
oModel:GetModel( "MDGRIDDXT" ):SetOptional( .T. )

// Validação da ativação do model
oModel:SetVldActivate( { |oModel| A751ACTIVE( oModel ) } )

Return(oModel)

/** -------------------------------------------------------------------------------------
{Protheus.doc} ViewDef
Retorna a View (tela) da rotina
@author: 	Joaquim Burjack
@since: 	06/08/2014
@Uso: 		AGRA751
------------------------------------------------------------------------------------- **/
Static Function ViewDef()
Local oView    := Nil
Local oModel   := FwLoadModel( "AGRA751" )
Local oStruDXS := FwFormStruct( 2, "DXS" )
Local oStruDXT := FwFormStruct( 2, "DXT" )
Local nNumIe   := nNumIe   := aScan(oStruDXT:aFields,{|x| x[1] == "DXT_NUMIE"})

// Remove campos da estrutura
AGRGRIDMVC(@oStruDXS,"DXS",vVetNDXS,.T.)

AGRGRIDMVC(@oStruDXT,"DXT",vVetNDXT,.T.)

oStruDXT:aFields[nNumIe,3] := STR0020

// Instancia a View
oView := FwFormView():New()
oView:SetModel( oModel )

 //Adiciona mais campos
//oStruDXT:AddField('C6_VALOR','4',STR0074,STR0074,,'N','@E 99,999,999.99',NIL,'',.F.,NIL,NIL,,NIL,NIL,.F.,NIL)  

// Adiciona a estrutura ao modelo
oView:AddField( "VIEW_DXS", oStruDXS, "MDFIELDDXS" )
oView:AddGrid( "VIEW_DXT", oStruDXT, "MDGRIDDXT" )

// Cria Box
oView:CreateHorizontalBox( "SUP", 60 )
oView:CreateHorizontalBox( "MED", 40 )

// Seta o Owner da View
oView:SetOwnerView( "VIEW_DXS", "SUP" )
oView:SetOwnerView( "VIEW_DXT", "MED" )

// Adiciona os botoes na tela
oView:AddUserButton( STR0005 , 'CLIPS', {|x| Pesagem( x ) } ) //'Pesagem'

// Define o campo incremental
oView:AddIncrementField( 'VIEW_DXT', 'DXT_ITEM' )

oView:SetViewProperty('VIEW_DXT',"CHANGELINE",{{|oView,cViewID| AGR751LEFIM(oView,cViewID)}})

Return(oView)

/** -------------------------------------------------------------------------------------
{Protheus.doc} MenuDef
Menu Padrao da Rotina
@author: 	Joaquim Burjack
@since: 	06/08/2014
@Uso: AGRA751
------------------------------------------------------------------------------------- **/
Static Function MenuDef()
Local aRotina := {}    

aAdd( aRotina, { STR0006, "PesqBrw"			 , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0007, "ViewDef.AGRA751", 0, 2, 0, Nil } ) //"Visualizar"
aAdd( aRotina, { STR0008, "ViewDef.AGRA751", 0, 3, 0, Nil } ) //"Incluir"
aAdd( aRotina, { STR0009, "ViewDef.AGRA751", 0, 4, 0, Nil } ) //"Alterar"
aAdd( aRotina, { STR0010, "AGRA750P()"		 , 0, 4, 0, Nil } ) //"Prep.Doc.Sai."
aAdd( aRotina, { STR0011, "AGRA750C()"		 , 0, 4, 0, Nil } ) //"Cancela"
aAdd( aRotina, { STR0012, "AGRAR750"			 , 0, 8, 0, Nil } ) //"Imprimir"
aAdd( aRotina, { STR0021, "AGRAR760"			 , 0, 8, 0, Nil } ) //"Imprimir Ticket de Pesagem"

Return(aRotina)

/*
############################################################################
# Função   : AGR751LEFIM                                                   #
# Descrição: Controle de novegação na grid e na confirmação                #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 26/08/2014                                                    #  
############################################################################
*/
Function AGR751LEFIM()
Local oModel	 := FwModelActive(),lRet := .t.
Local oGrdDXT	 := oModel:GetModel("MDGRIDDXT")
Local nLinDXT := oGrdDXT:nLine,nx,nCont := 0
For nx := 1 To oGrdDXT:Length()
   oGrdDXT:GoLine(nx)
   If !oGrdDXT:IsDeleted()
      nCont ++
      If nCont > 1
         Help(,1,"HELP",,STR0013,1,0)      
         lRet := .f.
      EndIf
   EndIf
Next nx
oGrdDXT:GoLine(nLinDXT)
Return lRet

/** -------------------------------------------------------------------------------------
{Protheus.doc} A751ACTIVE
Validação da ativação do model

@param: 	oModel - Modelo de dados da rotina
@author: 	Joaquim Burjack
@since: 	06/08/2014
@Uso: 		AGRA751
------------------------------------------------------------------------------------- **/
Static Function A751ACTIVE(oModel)
Local aArea		:= GetArea()
Local lRet		:= .T.

If oModel:GetOperation() == MODEL_OPERATION_UPDATE  

	DO CASE
		// Preparação do documento fiscal
		CASE IsIncallStack("AGRA750P") 
			If DXS->DXS_STATUS == "3" // Status "3" = Encerrado
				lRet := .F.
				Help("",1,STR0014,,STR0015+Alltrim(AGRTxtBox('3','DXS_STATUS'))+STR0016,1) //"ATENÇÃO"###"Este romaneio está "###" ! "
			ElseIf DXS->DXS_STATUS == "4" // Status "4" = Cancelado
				lRet := .F.
				Help("",1,STR0014,,STR0017+Alltrim(AGRTxtBox('4','DXS_STATUS'))+STR0018,1) //"ATENÇÃO"###"Este romaneio foi "###" !"
			EndIf
		// Cancelamento	
		CASE IsIncallStack("AGRA750C")	
			If DXS->DXS_STATUS == "4" // Status "4" = Cancelado
				lRet := .F.
				Help("",1,STR0014,,STR0015+Alltrim(AGRTxtBox('4','DXS_STATUS'))+ STR0018 ,1) //"ATENÇÃO"###"Este romaneio está "###" !"
			EndIf
	ENDCASE

EndIf 

RestArea(aArea)	
Return(lRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} GrvModelo
Rotina para gravação do modelo de dados

@param:		oModel 	- Modelo de dados da rotina
@author: 	Joaquim Burjack
@since: 	06/08/2014
@Uso: 		AGRA751
------------------------------------------------------------------------------------- **/
Static Function GrvModelo( oModel )
Local oMdlDXT		:= oModel:GetModel("MDGRIDDXT")
Local aAreaAtu	:= GetArea( )
Local cRomaneio	:= FwFldGet("DXS_CODIGO")
Local cEtiqueta	:= ""
Local cSafra		:= ""
Local lRet			:= .T.
Local nOperac 	:= oModel:GetOperation()
Local nX, nI		:= 0
Local nPos			:= 0

ADA->(dbSetOrder(1)) // Filial + Contrato
ADA->(dbSeek(xFilial("ADA")+ FwFldGet("DXS_CODCTP")))
cSafra	:= ADA->ADA_SAFRA

BEGIN TRANSACTION

	If lRet .And. (INCLUI .Or. ALTERA)  
		// Atualiza o relacionamento entre os itens do romaneio e os fardos 
		If lModified .And. Len(aFardos) > 0
			// Atualiza o saldo da instrução de embarque
			// A750ATUDXO(oMdlDXT, nOperac )
			
			dbSelectArea( "DXI" )
			DXI->(dbSetOrder(1))
			
			For nX := 1 to oMdlDXT:Length()
				oMdlDXT:GoLine( nX )
				
				cItemR := oMdlDXT:GetValue("DXT_ITEM")
				If !oMdlDXT:IsDeleted() .And. (nPos := ASCAN(aFardos, {|x| x[1] == cItemR})) > 0
				
					For nI := 1 to Len(aFardos[nPos,2])
					
						cEtiqueta := aFardos[nPos,2,nI,2]
					
						If DXI->(dbSeek( xFilial( "DXI" ) + cSafra + cEtiqueta ))
							RecLock( "DXI", .F. )
							DXI_ROMSAI := cRomaneio
							DXI_ITROMS := cItemR
							DXI->(MsUnLock())
						EndIf
					Next nI   
				EndIf	
			Next nX
		EndIf	
	EndIf
	
	If lRet
		// Se não for operação EXCLUIR
		If nOperac # 5
			// Atualiza rateio do peso da carga entre os itens do romaneio
		Else
			// A750ATUDXO(oMdlDXT, MODEL_OPERATION_DELETE)
		EndIf
	    
		FwFormCommit( oModel )
	Else 
		DisarmTransaction()
	EndIf
	
END TRANSACTION()

aFardos 	:= {}
lModified 	:= .F.                

RestArea( aAreaAtu )
Return(lRet)
