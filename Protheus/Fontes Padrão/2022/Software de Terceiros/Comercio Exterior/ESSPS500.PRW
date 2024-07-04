#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH" 

Function ESSPS500(nOpc, nReg, nOpc) 
Local aCoors := FWGetDialogSize( oMainWnd )
Local cTpReg := ""
Local aRel := {}

Private oPanelUp := NIL
Private oFWLayer := NIL
Private oPanelDown := NIL
Private oBrowseUp := NIL 
Private oBrowseDown := NIL 
Private oRelacEEQ := NIL
Private oDlgPrinc := NIL
Private aRotina := NIL
Private lNaoCancelar := .F.

If Type("cPed") == "C"
   cTpReg := cPed
EndIf

//Variaveis do controle de invoices ESSIS400
Private nRegEJW    := nReg
Private cTpInvoice := cTpReg
Private lIS400Auto := .F.
Private lFaturaTod := .F.
Private aValFatura := {0,0}
Private aRotina    := {}//FSY - 26/12/2013 - aRotina Movido 
//RRC - 11/11/2013 - Caso o compartilhamento entre as tabelas EEQ e ELA sejam diferentes, não deve prosseguir, uma vez que existe um relacionamento entre elas
Begin Sequence
If (!Empty(xFilial("ELA")) .And. Empty(xFilial("EEQ"))) .Or. (Empty(xFilial("ELA")) .And. !Empty(xFilial("EEQ")))
   EasyHelp("O Compartilhamento das tabelas EEQ (Parcelas de Câmbio) e ELA (Invoices de Serviços) são diferentes, essa rotina não poderá ser executada.","Aviso")
   Break
Else
   //IS400BrwColumn(cTpReg)
   //AF500BrwColumns(cTpReg)

   //Variaveis do PS402
   Private cTipoProc := cTpReg

   Define MsDialog oDlgPrinc Title If(cTpReg=="A","Invoices", "Faturamentos") From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel //"Invoices/Faturamentos"
   
   // Cria o conteiner onde serão colocados os browses
   oFWLayer := FWLayer():New()
   oFWLayer:Init( oDlgPrinc, .F., .T. )
   
   // Define Painel Superior
   oFWLayer:AddLine( 'UP', 50, .F. )// Cria uma "linha" com 50% da tela
   oFWLayer:AddCollumn( 'ALLUP', 100, .T., 'UP' )// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
   oPanelUp := oFWLayer:GetColPanel( 'ALLUP', 'UP' )// Pego o objeto desse pedaço do container

   // FWmBrowse Superior Det. dos Serviços
   oBrowseUp:= FWmBrowse():New()
   oBrowseUp:SetOwner( oPanelUp )
   //oBrowseUp:SetFilterDefault(" EJX->EJX_FILIAL == EJW->EJW_FILIAL .AND. EJX->EJX_TPPROC == EJW->EJW_TPPROC .And. EJX->EJX_PROCES == EJW->EJW_PROCES ")//Filtro do Browse
   oBrowseUp:SetFilterDefault(" ELA->ELA_FILIAL == '"+xFilial("ELA")+"' .AND. ELA->ELA_TPPROC == '"+cTpReg+"' .And. ELA->ELA_PROCES == EJW->EJW_PROCES ")//Filtro do Browse
   
   // Aqui se associa o browse ao componente de tela
   //oBrowseUp:SetDescription( "Serviços" )//"Serviços"
   oBrowseUp:SetDescription( "Invoices" )//"Serviços"
   //oBrowseUp:SetAlias( 'EJX' )
   oBrowseUp:SetAlias( 'ELA' )
   oBrowseUp:SetMenuDef( 'ESSIS400' )
   
   // Define de onde virao os botoes deste browse
   oBrowseUp:SetProfileID( '1' ) // identificador (ID) para o Browse
   oBrowseUp:ForceQuitButton() // Força exibição do botão "Sair"
   oBrowseUp:DisableDetails()

   //THTS - 18/07/2017 - Criada a funcao AvGetCpBrw() para retirar do Browse campos que nao querem que sejam exibidos
   If Upper(cTpReg) == "A"
     //aMostra := {"ELA_EXPORT", "ELA_LOJEXP", "ELA_DSCEXP"}
     //aEsconde := {"ELA_IMPORT", "ELA_LOJIMP", "ELA_DSCIMP"}
     oBrowseUp:SetOnlyFields(AvGetCpBrw("ELA",{"ELA_IMPORT", "ELA_LOJIMP", "ELA_DSCIMP"}))
   ElseIf Upper(cTpReg) == "V"
     //aMostra := {"ELA_IMPORT", "ELA_LOJIMP", "ELA_DSCIMP"}
     //aEsconde := {"ELA_EXPORT", "ELA_LOJEXP", "ELA_DSCEXP"}
     oBrowseUp:SetOnlyFields(AvGetCpBrw("ELA",{"ELA_EXPORT", "ELA_LOJEXP", "ELA_DSCEXP"}))
   EndIf

   oBrowseUp:Activate() 
   //aRotina  := {}//FSY - 26/12/2013 - Variavel private reutilizado na classe :SetMenuDef para setar os botões em ações relacionais.
   // Painel Inferior                 
   oFWLayer:AddLine( 'DOWN', 50, .F. )// Cria uma "linha" com 50% da tela
   oFWLayer:AddCollumn( 'ALLDOWN' , 100, .T., 'DOWN' )// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
   oPanelDown := oFWLayer:GetColPanel( 'ALLDOWN' , 'DOWN' ) // Pego o objeto inferior
   
   // FWmBrowse Parcelas de Cambio
   oBrowseDown:= FWMBrowse():New()
   oBrowseDown:SetOwner( oPanelDown )   
   oBrowseDown:SetDescription( "Parcelas de Cambio" )
   oBrowseDown:SetMenuDef( 'ESSPS401' ) // Nome do fonte do MenuDef 
   oBrowseDown:SetAlias( 'EEQ' )
   oBrowseDown:SetProfileID( '2' ) 
   oBrowseDown:DisableDetails()                                                        
   oBrowseDown:ForceQuitButton() // Força exibição do botão "Sair"
   //RRC - 07/10/2013 - Somente Versao P11: Adicionado filtro pois quando não havia invoice incluída, o sistema exibia parcelas que não estavam relacionados ao SIGAESS, quando invoice era vazia e tipo de processo também
   //Somente para o SIGAESS o campo Tipo de Processo estará preenchido, juntamente com a Invoice
   oBrowseDown:SetFilterDefault("EEQ->EEQ_FILIAL == '"+xFilial("EEQ")+"' .AND. (EEQ->EEQ_TPPROC == 'A' .OR. EEQ->EEQ_TPPROC == 'V')")//Filtro do Browse

   //THTS - 18/07/2017 - Criada a funcao AvGetCpBrw() para retirar do Browse campos que nao querem que sejam exibidos
   If Upper(cTpReg) == "A"
     //aMostra  := {"EEQ_FORN","EEQ_FOLOJA","EEQ_DESFOR"}
     //aEsconde := {"EEQ_IMPORT","EEQ_IMLOJA","EEQ_DESIMP"}
     oBrowseDown:SetOnlyFields(AvGetCpBrw("EEQ",{"EEQ_IMPORT","EEQ_IMLOJA","EEQ_DESIMP"}))
//MFR 02/08/2017 WCC-526892 TE-6334     
// ElseIf Upper(cTipo) == "V"
   ElseIf Upper(cTpReg) == "V"
     //aMostra  := {"EEQ_IMPORT","EEQ_IMLOJA","EEQ_DESIMP"}
     //aEsconde := {"EEQ_FORN","EEQ_FOLOJA","EEQ_DESFOR"}
     oBrowseDown:SetOnlyFields(AvGetCpBrw("EEQ",{"EEQ_FORN","EEQ_FOLOJA","EEQ_DESFOR"}))
   EndIf   
   
   oBrowseDown:Activate() 
   
   // Relacionamento entre os Paineis
   DbSelectArea("EEQ")
   oRelacEEQ:= FWBrwRelation():New()
   /*RRC - 11/11/2013 - Tratamento para considerar múltiplas filiais:
   A função xFilial() retorna só a filial ativa, mas o browseUp exibe registros de todas as filiais da empresa, neste caso, o browseDown deve exibir os dados relacionados*/
   //oRelacEEQ:AddRelation( oBrowseUp, oBrowseDown , { { 'EEQ_FILIAL', 'xFilial("EEQ")' }, { 'EEQ_TPPROC' , 'ELA_TPPROC' }, { 'EEQ_FORN','ELA_EXPORT'}, { 'EEQ_FOLOJA','ELA_LOJEXP'}, { 'EEQ_IMPORT','ELA_IMPORT'}, { 'EEQ_IMLOJA','ELA_LOJIMP'}, { 'EEQ_NRINVO','ELA_NRINVO'}, { 'EEQ_PROCES','ELA_PROCES'} } )
   oRelacEEQ:AddRelation( oBrowseUp, oBrowseDown , { { 'EEQ_FILIAL', 'ELA_FILIAL' }, { 'EEQ_TPPROC' , 'ELA_TPPROC' }/*, { 'EEQ_FORN','ELA_EXPORT'}, { 'EEQ_FOLOJA','ELA_LOJEXP'}, { 'EEQ_IMPORT','ELA_IMPORT'}, { 'EEQ_IMLOJA','ELA_LOJIMP'}*/, { 'EEQ_NRINVO','ELA_NRINVO'}, { 'EEQ_PROCES','ELA_PROCES'} } )
   oRelacEEQ:Activate()
   oBrowseUp:Refresh()
   oBrowseDown:Refresh(.T.)
   
   Activate MsDialog oDlgPrinc Center
EndIf
End Sequence
 
Return

Function PS500Atua()

If Type("oBrowseUp") == "O"
   oBrowseUp:Refresh()
EndIf

If Type("oBrowseDown") == "O"
   oBrowseDown:Refresh(.T.)
EndIf
/*
If Type("oBrowseRight") == "O"
   oBrowseRight:Refresh(.T.) 
EndIf
*/
Return Nil