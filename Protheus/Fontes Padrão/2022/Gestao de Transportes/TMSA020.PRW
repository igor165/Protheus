#INCLUDE "TMSA020.ch"
#Include "FWMVCDEF.CH"
#Include "Protheus.ch"

Static lTmsToGfe := SuperGetMV("MV_TMS2GFE",.f.,.f.) //-- Integração de Ocorrências entre SIGAGFE e SIGATMS
Static cOcoAnt   := ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º  TMSA020   º Autor º  Richard Anderson  º Data º 01/10/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Programa  º  Tabela de Ocorrencias                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   º TMSA020()                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametrosº                                        			          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   º NIL                                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       º TMS - Gestao de Transportes 		            	      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador    º  Data    º BOPS º Motivo da Alteracao                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMauro Paladini º 11/10/13 º      º Conversao para padrao MVC           º±±
±±ºMauro Paladini º 06/12/13 º      º Ajustes para funcionamento do Mile  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSA020(aRotAuto,nOpcAuto)

Local aAutoCab	:= {}
Local oBrowse 	:= Nil

Private aRotina := MenuDef()
Private l020Auto := (Valtype(aRotAuto) == "A")

If l020Auto
	Private lMsHelpAuto := .T.
EndIf

If l020Auto
	aAutoCab   := Aclone( aRotAuto )
	FwMvcRotAuto( ModelDef(), 'DT2', nOpcAuto, { { 'MdFieldDT2', aAutoCab } } )  
Else
	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("DT2")
	oBrowse:SetDescription(STR0001) //"Tabela de Ocorrencias"
	oBrowse:Activate()
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ModelDef ³ Autor ³ Mauro Paladini        ³ Data ³11.10.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Modelo de dados                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oModel Objeto do Modelo                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ModelDef()

Local oModel	:= Nil
Local oStruDT2	:= FWFormStruct(1,"DT2")

Local bPreValid	:= Nil
Local bPosValid := { |oMdl| PosVldMdl(oMdl) }
Local bCommit 	:= Nil
Local bCancel	:= Nil

oModel:= MpFormMOdel():New("TMSA020",  /*bPreValid*/ , bPosValid , {|oModel| TMA020Cmt(oModel)} ,/*bCancel*/ )
oModel:AddFields("MdFieldDT2",Nil,oStruDT2,/*prevalid*/,,/*bCarga*/)
oModel:SetDescription(STR0001) 	// "Tabela de Ocorrencias"
oModel:GetModel("MdFieldDT2"):SetDescription(STR0001) //"Tabela de Ocorrencias"
oModel:SetPrimaryKey({ "DT2_FILIAL","DT2_CODOCO" })

Return ( oModel )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ViewDef  ³ Autor ³ Mauro Paladini        ³ Data ³11.10.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe browse de acordo com a estrutura                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oView do objeto oView                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ViewDef()

Local oModel 	:= FwLoadModel("TMSA020")
Local oStruDT2	:= FWFormStruct(2,"DT2")
Local oView 	:= Nil

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField('VwFieldDT2', oStruDT2 , 'MdFieldDT2') 
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VwFieldDT2","TELA")

Return(oView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Mauro Paladini        ³ Data ³11.10.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ MenuDef com as rotinas do Browse                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina array com as rotina do MenuDef                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA020" OPERATION 2 ACCESS 0  //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSA020" OPERATION 3 ACCESS 0  //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TMSA020" OPERATION 4 ACCESS 0  //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSA020" OPERATION 5 ACCESS 0  //"Excluir"

Return ( aRotina )

    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PosVldMdl ³ Autor ³ Mauro Paladini        ³ Data ³11.10.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de validacao do modelo MVC                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPL1 - Verdadeiro ou Falso                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PosVldMdl(oMdl)

Local lRet    := .T.

If oMdl <> Nil .And. oMdl:GetOperation() == MODEL_OPERATION_DELETE

	lRet := TMSA020DelOk()
	
Elseif oMdl <> Nil .And. ( oMdl:GetOperation() == MODEL_OPERATION_INSERT .Or. oMdl:GetOperation() == MODEL_OPERATION_UPDATE )

	lRet := TMSA020TudOk()

Endif

Return lRet 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA020Tud³ Autor ³ Patricia A. Salomao   ³ Data ³ 07.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da Tela                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA020TudOk()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TMSA020TudOk()
Local aTipOco 	:= {}

AAdd( aTipOco, StrZero( 6, Len( DT2->DT2_TIPOCO ) ) ) // Gera Pendencia
AAdd( aTipOco, StrZero( 9, Len( DT2->DT2_TIPOCO ) ) ) // Gera Indenizacao

//Somente aceitar tipo de ocorrencia "4 - Retrabalho" para servico de 
//Transporte "1 - Coleta" e "3 - Entrega".
If M->DT2_TIPOCO == StrZero( 4, Len( DT2->DT2_TIPOCO ) ) .And.  ( M->DT2_SERTMS <> StrZero( 1, Len( DT2->DT2_SERTMS ) ) .And. M->DT2_SERTMS <> StrZero( 3, Len( DT2->DT2_SERTMS ) ) )
  	If !Empty(M->DT2_SERTMS)
  		Help('',1,'TMSA02001') //O tipo de ocorrência "4-Retrabalho" deve ser utilizado somente para serviços de  transporte "1- Coleta" ou "3-Entrega".
		Return( .F. )
	Endif	
EndIf

// O Cancelamento so' e' permitido para "Entrega" ou "Coleta"
If M->DT2_TIPOCO == StrZero( 12, Len( DT2->DT2_TIPOCO ) ) .And. ( M->DT2_SERTMS <> StrZero( 1, Len(DT2->DT2_SERTMS)) .And. M->DT2_SERTMS <> StrZero( 3, Len( DT2->DT2_SERTMS ) ) )
	If !Empty(M->DT2_SERTMS)
	  	Help('',1,'TMSA02005') //-- O Tipo de Ocorrencia "12 - Cancelamento", so' e' permitido para Servicos de Transp. de "Coleta" ou "Entrega" 
		Return( .F. )
	Endif	
EndIf

If M->DT2_TIPOCO == StrZero( 6, Len( DT2->DT2_TIPOCO ) ) .And. Empty( M->DT2_COMSEG )
  	Help('',1,'TMSA02002') //-- Obrigatoria a digitação do campo Ramo de Seguro
	Return( .F. )
EndIf

If M->DT2_TIPOCO == StrZero( 6, Len( DT2->DT2_TIPOCO ) ) .And. Empty( M->DT2_TIPPND )
  	Help('',1,'TMSA02003') //-- Obrigatoria a digitação do campo Tipo de Pendencia
	Return( .F. )
EndIf

//-- Obrigatoria a digitacao do tipo do seguro quando o tipo da ocorrencia for igual a 09-Gera Indenizacao
If M->DT2_TIPOCO == StrZero( 9, Len( DT2->DT2_TIPOCO ) ) .And. Empty( M->DT2_COMSEG )
  	Help('',1,'TMSA02002') //-- Obrigatoria a digitação do campo Ramo de Seguro
	Return( .F. )
EndIf

If M->DT2_SERTMS == StrZero( 1, Len( DT2->DT2_SERTMS ) ) .And. Ascan( aTipOco, M->DT2_TIPOCO ) > 0
	Help('',1,'TMSA02004') //-- Tipo invalido para servico de coleta
	Return( .F. )
EndIf

//Somente aceitar tipo de ocorrencia "06 - Gera pendencia + Tipo Pnd 04 - Retorno de Documento 
// para Transporte "3 - Entrega".
If M->DT2_TIPOCO == StrZero( 6, Len( DT2->DT2_TIPOCO ) ) .And. M->DT2_TIPPND == StrZero( 4, Len( DT2->DT2_TIPOCO ) ) .And. M->DT2_SERTMS <> StrZero( 3, Len( DT2->DT2_SERTMS ) )
  	If !Empty(M->DT2_SERTMS) 
	  	Help('',1,'TMSA02008') //O tipo de ocorrência "06-Gera Pendencia"  e Tipo Pendencia "04 - "Retorno Dc. Cliente" deve ser utilizado somente para serviços de  transporte "3-Entrega".
		Return( .F. )
	Endif	
EndIf

If DT2->(ColumnPos("DT2_PRZENT")) > 0 
	If M->DT2_LIBAUT == StrZero(1, Len(DT2->DT2_LIBAUT)) 
		If Empty(M->DT2_PRZENT)
			If M->DT2_RESOCO == StrZero(2, Len(DT2->DT2_RESOCO)) .And. ;
	   			(M->DT2_TIPOCO == StrZero(4, Len(DT2->DT2_TIPOCO)) .Or. M->DT2_TIPOCO == StrZero(5, Len(DT2->DT2_TIPOCO)) )
					Help('',1,"OBRIGAT2",,RetTitle('DT2_PRZENT'),04,01) 
					Return( .F. )
			EndIf	
		EndIf	
	EndIf
EndIf

Return  .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA020Whe³ Autor ³ Alex Egydio           ³ Data ³09.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes antes de editar o campo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA020Whe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DT2_COMSEG                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA020Whe()

Local  lRet    := .T.
Local  aTipOco := {}
Local  cCampo  := AllTrim( ReadVar() )
Local  oModel  := FWModelActive()
Local  oView   := FWViewActive() 

AAdd( aTipOco, StrZero( 6, Len( DT2->DT2_TIPOCO ) ) ) //-- Gera Pendencia
AAdd( aTipOco, StrZero( 9, Len( DT2->DT2_TIPOCO ) ) ) //-- Gera Indenizacao

If cCampo == 'M->DT2_TIPOCO'

	If M->DT2_TIPOCO == StrZero(16, Len(DT2->DT2_TIPOCO)) //-- Receita
		oModel:LoadValue( "MdFieldDT2" , "DT2_CDPASD" , "" ) //-- Esvazia Conteúdo
		oModel:LoadValue( "MdFieldDT2" , "DT2_DEPASD" , "" ) //-- Esvazia Conteúdo
		oModel:LoadValue( "MdFieldDT2" , "DT2_CODDES" , "" ) //-- Esvazia Conteúdo - Cód.Despesa
	EndIf

	If M->DT2_TIPOCO == StrZero(17, Len(DT2->DT2_TIPOCO)) //-- Despesa
		oModel:LoadValue( "MdFieldDT2" , "DT2_CDPASR" , "" ) //-- Esvazia Conteúdo
		oModel:LoadValue( "MdFieldDT2" , "DT2_DEPASR" , "" ) //-- Esvazia Conteúdo
	EndIf

	If M->DT2_TIPOCO <> StrZero(16, Len(DT2->DT2_TIPOCO)) .And.;
	   M->DT2_TIPOCO <> StrZero(17, Len(DT2->DT2_TIPOCO)) .And.;
	   M->DT2_TIPOCO <> StrZero(18, Len(DT2->DT2_TIPOCO))
		oModel:LoadValue( "MdFieldDT2" , "DT2_CDPASD" , "" ) //-- Esvazia Conteúdo
		oModel:LoadValue( "MdFieldDT2" , "DT2_DEPASD" , "" ) //-- Esvazia Conteúdo
		oModel:LoadValue( "MdFieldDT2" , "DT2_CDPASR" , "" ) //-- Esvazia Conteúdo
		oModel:LoadValue( "MdFieldDT2" , "DT2_DEPASR" , "" ) //-- Esvazia Conteúdo
	EndIf



ElseIf cCampo == 'M->DT2_COMSEG' .Or. cCampo == 'M->DT2_TIPPND' 

	lRet := ( Ascan( aTipOco, M->DT2_TIPOCO ) > 0 )

ElseIf cCampo == "M->DT2_CDPASR" //-- Componente Receita

	If 	M->DT2_TIPOCO <> StrZero( 16 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Receita
		M->DT2_TIPOCO <> StrZero( 18 ,Len(DT2->DT2_TIPOCO))			//-- Receita/Despesa

		oModel:LoadValue( "MdFieldDT2" , "DT2_CDPASR" , "" ) //-- Esvazia Conteúdo
		oModel:LoadValue( "MdFieldDT2" , "DT2_DEPASR" , "" ) //-- Esvazia Conteúdo
		//oView:Refresh()
		lRet := .f.

	EndIf
ElseIf cCampo == "M->DT2_CDPASD" //-- Componente Despesa

	If 	( M->DT2_TIPOCO <> StrZero( 17 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Despesa
		M->DT2_TIPOCO <> StrZero( 18 ,Len(DT2->DT2_TIPOCO))	) .Or. ;	//-- Receita/Despesa
		!Empty(M->DT2_CODAED)								  

		oModel:LoadValue( "MdFieldDT2" , "DT2_CDPASD" , "" ) //-- Esvazia Conteúdo
		oModel:LoadValue( "MdFieldDT2" , "DT2_DEPASD" , "" ) //-- Esvazia Conteúdo
		//oView:Refresh()
		lRet := .f.

	EndIf
ElseIf cCampo == "M->DT2_CODDES" //-- Código Despesa Transporte

		If 	( M->DT2_TIPOCO <> StrZero( 17 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Despesa
		M->DT2_TIPOCO <> StrZero( 18 ,Len(DT2->DT2_TIPOCO)) ) .Or. ;	//-- Receita/Despesa
		!Empty(M->DT2_CODAED) .Or. !Empty(M->DT2_CDTIPO)	

		oModel:LoadValue( "MdFieldDT2" , "DT2_DESDSP" , "" ) //-- Esvazia Conteúdo
		lRet := .f.

	EndIf
ElseIf cCampo == "M->DT2_CODNAT" //-- Código Da Natureza Financeira

	If 	M->DT2_TIPOCO =  StrZero( 17 ,Len(DT2->DT2_TIPOCO)) .Or. ;	//-- Despesa
		M->DT2_TIPOCO =  StrZero( 18 ,Len(DT2->DT2_TIPOCO))	.Or. ;	//-- Receita/Despesa
		!Empty(M->DT2_CODAED) .Or. !Empty(M->DT2_CDTIPO)	

		If !Empty(M->DT2_CDTIPO)
			lRet := .f.
		ElseIf DDI->(ColumnPos('DDI_TPREEM'))> 0  .And. !Empty(M->DT2_CODAED) .And. ;
				Posicione('DDI',1,FwxFilial('DDI')+(M->DT2_CODAED),'DDI_TPREEM') == STR(1,TamSX3('DDI_TPREEM')[1])	
			lRet := .F.
		EndIf
	
	Else		
		lRet := .f.
	EndIf
	
	//-- Esvazia Conteúdo
	If !(lRet)
		oModel:LoadValue( "MdFieldDT2" , "DT2_CODNAT" , "" ) //-- Esvazia Conteúdo
	EndIf	

ElseIf cCampo == "M->DT2_MOTDT6" //-- Herda Motivo Da Ocorrência

	If 	M->DT2_TIPOCO <> StrZero( 16 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Receita
		M->DT2_TIPOCO <> StrZero( 18 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Receita/Despesa
		M->DT2_TIPOCO <> StrZero( 19 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Reentrega
		M->DT2_TIPOCO <> StrZero( 20 ,Len(DT2->DT2_TIPOCO))			//-- Devolução

		lRet := .f.
		oModel:LoadValue( "MdFieldDT2" , "DT2_MOTDT6" , CriaVar("DT2_MOTDT6") ) //-- Altera Conteúdo Para o Inicilizador Padrão Do Campo

	EndIf

ElseIf cCampo == "M->DT2_ALTVLR" //-- Altera Valor Na Liberação?

	If 	M->DT2_TIPOCO <> StrZero( 16 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Receita
		M->DT2_TIPOCO <> StrZero( 17 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Despesa
		M->DT2_TIPOCO <> StrZero( 18 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Receita/Despesa
		M->DT2_TIPOCO <> StrZero( 19 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Reentrega
		M->DT2_TIPOCO <> StrZero( 20 ,Len(DT2->DT2_TIPOCO))	//-- Devolução
		
		lRet := .f.
		oModel:LoadValue( "MdFieldDT2" , "DT2_ALTVLR" , CriaVar("DT2_ALTVLR") ) //-- Altera Conteúdo Para o Inicilizador Padrão Do Campo

	EndIf

ElseIf cCampo == "M->DT2_CDTIPO" //-- Tipo Da Ocorrência GFE   

	lRet := .F.
	If lTmsToGfe
		If M->DT2_TIPOCO == StrZero(18,Len(DT2_TIPOCO))
			lRet	:= .F. 
		ElseIf  M->DT2_TIPOCO == StrZero(16,Len(DT2_TIPOCO)) 
			lRet	:= .T.
		Else 
			lRet	:= .T. 
			
			If !Empty(M->DT2_CODAED) .Or. !Empty(M->DT2_CDPASD) .Or. !Empty(M->DT2_CDPASR)
				lRet	:= .F. 
			EndIf
			
		EndIf
	EndIf
	
	//-- Esvazia Conteúdo
	If !(lRet)
		oModel:LoadValue( "MdFieldDT2" , "DT2_CDTIPO" , "" ) //-- Esvazia Conteúdo
	EndIf

ElseIf cCampo == "M->DT2_CMPAUT"

	lRet	:= .T. 
	
	If 	M->DT2_TIPOCO <> StrZero( 16 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Receita
		M->DT2_TIPOCO <> StrZero( 17 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Despesa
		M->DT2_TIPOCO <> StrZero( 18 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Receita/Despesa
		M->DT2_TIPOCO <> StrZero( 19 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Reentrega
		M->DT2_TIPOCO <> StrZero( 20 ,Len(DT2->DT2_TIPOCO))			//-- Devolução
		
		lRet	:= .F. 
		oModel:LoadValue( "MdFieldDT2" , "DT2_CMPAUT" , CriaVar("DT2_CMPAUT") ) //-- Altera Conteúdo Para o Inicilizador Padrão Do Campo
		
	EndIf
	

ElseIf cCampo == "M->DT2_LIBAUT"

	lRet	:= .T. 
	   
	If 	M->DT2_TIPOCO <> StrZero( 16 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Receita
		M->DT2_TIPOCO <> StrZero( 17 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Despesa
		M->DT2_TIPOCO <> StrZero( 18 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Receita/Despesa
		M->DT2_TIPOCO <> StrZero( 19 ,Len(DT2->DT2_TIPOCO)) .And.;	//-- Reentrega
		M->DT2_TIPOCO <> StrZero( 20 ,Len(DT2->DT2_TIPOCO))		//-- Devolução
	
		lRet	:= .F. 
	EndIf

	//--- Prazo de Entrega
	If DT2->(ColumnPos("DT2_PRZENT")) > 0 .And. M->DT2_RESOCO == StrZero( 2 ,Len(DT2->DT2_RESOCO))  .And. ;
    	(M->DT2_TIPOCO == StrZero( 4 ,Len(DT2->DT2_TIPOCO)) .Or. M->DT2_TIPOCO == StrZero( 5 ,Len(DT2->DT2_TIPOCO)) )
		lRet:= .T.
	EndIf

	If !lRet
		oModel:LoadValue( "MdFieldDT2" , "DT2_LIBAUT" , CriaVar("DT2_LIBAUT") ) //-- Altera Conteúdo Para o Inicilizador Padrão Do Campo
	EndIf
	

ElseIf cCampo == "M->DT2_CODAED"

	lRet	:= .T.

	If 	M->DT2_TIPOCO <> StrZero( 17 ,Len(DT2->DT2_TIPOCO)) .And. M->DT2_TIPOCO <> StrZero( 18 ,Len(DT2->DT2_TIPOCO))
		lRet	:= .F. 
		oModel:LoadValue( "MdFieldDT2" , "DT2_CODAED" , "" ) 
	Else
		
		If !Empty(M->DT2_CDTIPO)
			lRet	:= .F. 
			oModel:LoadValue( "MdFieldDT2" , "DT2_CODAED" , "" ) 
		EndIf
		
	EndIf

ElseIf cCampo == "M->DT2_PRZENT"
	lRet	:= .F. 
	If Empty(M->DT2_SERTMS) .Or. M->DT2_SERTMS == StrZero( 3 ,Len(DT2->DT2_SERTMS))   //Entrega
		// Poderá ser preenchido se a “Responsabilidade” for “2-Cliente” e se o “Tipo” for  “04-Retorna documento” ou “05-Informativa		
		If (M->DT2_TIPOCO == StrZero( 4 ,Len(DT2->DT2_TIPOCO)) .Or. M->DT2_TIPOCO == StrZero( 5 ,Len(DT2->DT2_TIPOCO)) )  .And. M->DT2_RESOCO == StrZero( 2 ,Len(DT2->DT2_RESOCO))  
			lRet:= .T.
		EndIf
	EndIf	

EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA020Vld³ Autor ³ Alex Egydio           ³ Data ³09.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do sistema                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA020Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DT2_TIPOCO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA020Vld()

Local lRet     := .T.
Local cCampo   := AllTrim( ReadVar() )
Local oModel   := FWModelActive()

Local aArea     := GetArea()
Local cQuery    := ""
Local cAliasDT2 := ""
Local nMotGFE	:= 0
Local lPrzEnt   := DT2->(ColumnPos("DT2_PRZENT")) > 0 

If	cCampo == 'M->DT2_TIPOCO' 

	M->DT2_COMSEG := Space(Len(DT2->DT2_COMSEG))
	M->DT2_DESSEG := Space(TamSX3('DT2_DESSEG')[1])
	M->DT2_TIPPND := Space(Len(DT2->DT2_TIPPND))
	M->DT2_DESPND := Space(TamSX3('DT2_DESPND')[1])

	If	M->DT2_TIPOCO == StrZero(14,Len(DT2->DT2_TIPOCO)) //-- Ajuste Previsao de Chegada
		M->DT2_CATOCO := StrZero( 2,Len(DT2->DT2_CATOCO)) //-- Por Viagem
	EndIf

	If lPrzEnt .And. M->DT2_PRZENT == StrZero(1, Len(DT2->DT2_PRZENT)) 
		If M->DT2_RESOCO == StrZero(2, Len(DT2->DT2_RESOCO)) .And. ;
		   (M->DT2_TIPOCO <> StrZero(4, Len(DT2->DT2_TIPOCO)) .And. M->DT2_TIPOCO <> StrZero(5, Len(DT2->DT2_TIPOCO)) )
			//-- "O Prazo de Entrega (DT2_PRZENT), só poderá ser preenchido com conteúdo "SIM" se a Responsabilidade (DT2_RESOCO) 
			//-- for do  “Cliente” e se o Tipo da Ocorrência (DT2_TIPOCO) for  “04-Retorna documento” ou “05-Informativa”.
			Help("", 1, 'TMSA02019')
			lRet := .F.
		EndIf
	EndIf	
	

ElseIf cCampo == 'M->DT2_CATOCO'

	If	M->DT2_TIPOCO == StrZero(14,Len(DT2->DT2_TIPOCO)) .And. ; //-- Ajuste Previsao de Chegada
		M->DT2_CATOCO == StrZero( 1,Len(DT2->DT2_CATOCO)) //-- Por Documento
		Help("",1,"TMSA02006") //-- "Para o tipo 'Ajuste Previsao de Chegada' a categoria deverá ser por viagem !!!"
		lRet := .F.
	EndIf

ElseIf cCampo == 'M->DT2_CDPASR'

	//-- Posiciona No Componente Do Frete RECEITA
	DbSelectArea("DT3")
	DbSetOrder(1) //-- DT3_FILIAL+DT3_CODPAS
	If MsSeek( FWxFilial("DT3") + M->DT2_CDPASR , .F. )
	
		If DT3->DT3_TIPFAI >= '50'
			Help("",1,"TMSA02009") //-- "Permitido Apenas Componentes De Frete Com Tipo De Faixa (DT3_TIPFAI) Inferior a 50 !"
			lRet := .F.
		Else
			//-- Gatilha Descrição Para Campo Virtual
			oModel:LoadValue( "MdFieldDT2" , "DT2_DEPASR" , DT3->DT3_DESCRI )
		EndIf
	EndIf

ElseIf cCampo == 'M->DT2_CDPASD'

	//-- Posiciona No Componente Do Frete DESPESA
	DbSelectArea("DT3")
	DbSetOrder(1) //-- DT3_FILIAL+DT3_CODPAS
	If MsSeek( FWxFilial("DT3") + M->DT2_CDPASD , .F. )
	
		If DT3->DT3_TIPFAI < '50'
			Help("",1,"TMSA02010") //-- "Permitido Apenas Componentes De Frete Com Tipo De Faixa (DT3_TIPFAI) Superior a 49 !"
			lRet := .F.
		Else
			//-- Gatilha Descrição Para Campo Virtual
			oModel:LoadValue( "MdFieldDT2" , "DT2_DEPASD" , DT3->DT3_DESCRI )
		EndIf
	EndIf

ElseIf cCampo == 'M->DT2_CODDES'

	//-- Posiciona No Cadastro De Despesas De Transporte
	DbSelectArea("DT7")
	DbSetOrder(1) //-- DT7_FILIAL+DT7_CODDES
	If MsSeek( FWxFilial("DT7") + M->DT2_CODDES , .F. )
	
		//-- Não Pode Movimentar Banco Nem Estoque
		If DT7->DT7_MOVBCO == '1' .Or. DT7->DT7_CONEST == '1'
			Help("",1,"TMSA02011") //-- "Não é Permitido Códigos De Despesa Que Movimentem Financeiro (DT7_MOVBCO) Ou Estoque (DT7_CONEST) !"
			lRet := .F.
		Else
			//-- Gatilha Descrição Para Campo Virtual
			oModel:LoadValue( "MdFieldDT2" , "DT2_DESDSP" , DT7->DT7_DESCRI )
		EndIf
	EndIf	

ElseIf cCampo == 'M->DT2_LIBAUT'

	//--------------------------------------------------------------------------------------------- 
	//-- Validação na função TmsA020Vld() consistindo configuração entre 
	//-- o campo de aprovação automática TMS e o campo de aprovação automática GFE 
	//-- (DT2_LIBAUT='1' .AND. GU6_APRAUT='1' .or DT2_LIBAUT='2' .AND. GU6_APRAUT='2') - 
	//-- DT2_CDTIPO<>'' .AND. (GU5_CDTIPO=DT2_CDTIPO; GU4_CDTIPO=GU5_CDTIPO; GU6_CDMOT=GU4_CDMOT). 
	//-- Alertar o operador sobre o motivo da inconsistencia.
	//---------------------------------------------------------------------------------------------
	If M->DT2_LIBAUT == '1' .And. lRet
	
		//-- Tratamento Para Campo DT2_CDTIPO Não Informado.
		If !Empty(M->DT2_CDTIPO)

			//--Help("",1,"TMSA02012") //-- "Informe Primeiro o Tipo Da Ocorrência GFE (DT2_CDTIPO) !"
			//--lRet := .F.

			//-- Posiciona No "Tipo Da Ocorrencia" (GFE)
			DbSelectArea("GU5")
			DbSetOrder(1) //-- GU5_FILIAL+GU5_CDTIPO
			If MsSeek( FWxFilial("GU5") + M->DT2_CDTIPO , .F. )
			
				//-- Tipo X Motivo Ocorrencia
				DbSelectArea("GU4")
				DbSetOrder(2) //-- GU4_FILIAL+GU4_CDTIPO
				DbSeek(xFilial("GU4") + GU5->GU5_CDTIPO , .F.)
				
				While GU4->(!Eof()) .And. (GU4->GU4_CDTIPO == GU5->GU5_CDTIPO)  
					
					//-- Motivo Da Ocorrencia
					DbSelectArea("GU6")
					DbSetOrder(1) //-- GU6_FILIAL+GU6_CDMOT
					If DbSeek( FWxFilial("GU6") + GU4->GU4_CDMOT , .F. )
						
						If M->DT2_LIBAUT <> GU6->GU6_APRAUT
							//-- "Configurações De Liberação Automática Diferente Entre TMS e GFE !", "Verifique O Conteúdo Dos Campos "
							Help(Nil,Nil,'HELP',Nil, STR0007 + Chr(13) + Chr(10) + STR0008 + TmsReTitle( 'DT2_LIBAUT' ) + " / " + TmsReTitle( 'GU6_APRAUT' ) , 1, 0)
							lRet := .F.
						ElseIf !Empty(M->DT2_CDTIPO) .And. (GU5->GU5_CDTIPO <> M->DT2_CDTIPO) 		 
							//-- "Configurações De Liberação Automática Diferente Entre TMS e GFE !", "Verifique O Conteúdo Dos Campos "
							Help(Nil,Nil,'HELP',Nil, STR0007 + Chr(13) + Chr(10) + STR0008 + TmsReTitle( 'DT2_CDTIPO' ) + " / " + TmsReTitle( 'GU5_CDTIPO' ) , 1, 0)
							lRet := .F.
						ElseIf !Empty(M->DT2_CDTIPO) .And. (GU4->GU4_CDTIPO <> GU5->GU5_CDTIPO) 		 
							//-- "Configurações De Liberação Automática Diferente Entre TMS e GFE !", "Verifique O Conteúdo Dos Campos "
							Help(Nil,Nil,'HELP',Nil, STR0007 + Chr(13) + Chr(10) + STR0008 + TmsReTitle( 'GU4_CDTIPO' ) + " / " + TmsReTitle( 'GU5_CDTIPO' ) , 1, 0)
							lRet := .F.
						ElseIf !Empty(M->DT2_CDTIPO) .And. (GU6->GU6_CDMOT <> GU4->GU4_CDMOT) 		 
							//-- "Configurações De Liberação Automática Diferente Entre TMS e GFE !", "Verifique O Conteúdo Dos Campos "
							Help(Nil,Nil,'HELP',Nil, STR0007 + Chr(13) + Chr(10) + STR0008 + TmsReTitle( 'GU6_CDMOT' ) + " / " + TmsReTitle( 'GU4_CDMOT' ) , 1, 0)
							lRet := .F.
						EndIf								
				
					EndIf
					
					GU4->(DbSkip())
				EndDo	
	
			EndIf	
		EndIf

		//--- Prazo de Entrega
		If lRet .And. lPrzEnt
			If M->DT2_RESOCO == StrZero( 2 ,Len(DT2->DT2_RESOCO)) .And. (M->DT2_TIPOCO == StrZero( 4 ,Len(DT2->DT2_TIPOCO)) .Or. M->DT2_TIPOCO == StrZero( 5 ,Len(DT2->DT2_TIPOCO)) )
				If M->DT2_PRZENT == StrZero( 2 ,Len(DT2->DT2_PRZENT))  
					//Se o Prazo de Entrega estiver preenchido como 'Não', a Liberação Automática também deverá ser preenchida como 'Não'.
					Help("", 1, 'TMSA02020')  
					lRet:= .F.
				EndIf
			EndIf	
		EndIf

	EndIf

ElseIf cCampo == 'M->DT2_CDTIPO'

	If ! Empty(M->DT2_CDTIPO) //-- Somente se for informada

		//-- Posiciona No "Tipo Da Ocorrencia" (GFE)
		DbSelectArea("GU5")
		DbSetOrder(1) //-- GU5_FILIAL+GU5_CDTIPO
		If MsSeek( FWxFilial("GU5") + M->DT2_CDTIPO , .F. )
			
			//-- Tipo X Motivo Ocorrencia
			DbSelectArea("GU4")
			DbSetOrder(2) //-- GU4_FILIAL+GU4_CDTIPO
			DbSeek(xFilial("GU4") + GU5->GU5_CDTIPO , .F.)
				
			While GU4->(!Eof()) .And. (GU4->GU4_CDTIPO == GU5->GU5_CDTIPO) .And. lRet
				
				//-- Motivo Da Ocorrencia
				DbSelectArea("GU6")
				DbSetOrder(1) //-- GU6_FILIAL+GU6_CDMOT
				If DbSeek( FWxFilial("GU6") + GU4->GU4_CDMOT , .F. )
					
					//-- Contador de quantos motivos o GFE possui
					nMotGFE++
					
					//-- Tratamento DT2_TIPOCO = 17 Ou 18
					If	M->DT2_TIPOCO == StrZero( 17 ,Len(DT2->DT2_TIPOCO)) .Or. ;	//-- Despesa
						M->DT2_TIPOCO == StrZero( 18 ,Len(DT2->DT2_TIPOCO))			//-- Receita/Despesa
							
						If M->DT2_LIBAUT <> GU6->GU6_APRAUT
							//-- "Configurações De Liberação Automática Diferente Entre TMS e GFE !", "Verifique O Conteúdo Dos Campos "
							Help(Nil,Nil,'HELP',Nil, STR0007 + Chr(13) + Chr(10) + STR0008 + TmsReTitle( 'DT2_LIBAUT' ) + " / " + TmsReTitle( 'GU6_APRAUT' ) , 1, 0)
							lRet := .F.
						ElseIf !Empty(M->DT2_CDTIPO) .And. (GU4->GU4_CDTIPO <> GU5->GU5_CDTIPO)
							//-- "Configurações De Liberação Automática Diferente Entre TMS e GFE !", "Verifique O Conteúdo Dos Campos "
							Help(Nil,Nil,'HELP',Nil, STR0007 + Chr(13) + Chr(10) + STR0008 + TmsReTitle( 'GU4_CDTIPO' ) + " / " + TmsReTitle( 'GU5_CDTIPO' ) , 1, 0)
							lRet := .F.
						ElseIf !Empty(M->DT2_CDTIPO) .And. (GU6->GU6_CDMOT  <> GU4->GU4_CDMOT )
							//-- "Configurações De Liberação Automática Diferente Entre TMS e GFE !", "Verifique O Conteúdo Dos Campos "
							Help(Nil,Nil,'HELP',Nil, STR0007 + Chr(13) + Chr(10) + STR0008 + TmsReTitle( 'GU6_CDMOT' ) + " / " + TmsReTitle( 'GU4_CDMOT' ) , 1, 0)
							lRet := .F.
						ElseIf !Empty(GU5->GU5_OCOTMS)
							//-- "Não é Permitido Utilizar Ocorrência do GFE Vinculada ao TMS !"
							Help(Nil,Nil,'HELP',Nil, STR0011 , 1, 0)
							lRet := .F.
						EndIf
					EndIf

					//-- Tratamento DT2_TIPOCO = 21
					If M->DT2_TIPOCO == StrZero( 21 ,Len(DT2->DT2_TIPOCO))
						
						If GU5->GU5_EVENTO <> StrZero( 04 ,Len(GU5->GU5_EVENTO))
							Help("",1,"TMSA02014",Nil,Nil ) //-- "Campo De Evento (GU5_EVENTO) No GFE Diferente de '4'"
							lRet := .F.
							Exit
						EndIf
						
					ElseIf M->DT2_TIPOCO == StrZero( 17 ,Len(DT2->DT2_TIPOCO))
					
						If GU5->GU5_EVENTO <> StrZero( 1 , Len(GU5->GU5_EVENTO)) .And. GU5->GU5_TPCALC <> StrZero(3,Len(GU5->GU5_TPCALC) )
							Help("",1,"TMSA02018",Nil,Nil) //-- Tip.Ocor.GFE informado inválido.Para ocorrencias do tipo 17 = Despesa as Ocorrências do SIGAGFE devem possuir o Evento de Ocorrencia igual a 1=Cálculo, e o campo Tipo do Calculo Adicional igual a 3 = Serviço.
							lRet	:= .F. 
							Exit
						EndIf
						
					EndIf
				
				EndIf
				GU4->(DbSkip())
			EndDo

			If lRet .And. nMotGFE > 1			
				Help(" ", 1, 'TMSA02017') //-- "Tip.Ocor.GFE informado inválido, pois há mais de um Motivo vinculado no cadastro deste Tipo da Ocorrência GFE."
				lRet := .F.
			EndIf
		EndIf

		//-- Verifica se a ocorrência já está sendo utilizada
		If lRet
			cAliasDT2 := GetNextAlias()
			cQuery := "SELECT DT2_CODOCO "	
			cQuery += "  FROM " + RetSqlName("DT2") + " DT2 "
			cQuery += " WHERE DT2_FILIAL = '" + FwxFilial("DT2") + "' "
			cQuery += "   AND DT2_CDTIPO = '" + M->DT2_CDTIPO + "' "
			cQuery += "   AND DT2.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDT2,.T.,.T.)
			If (cAliasDT2)->(!Eof())
				Help(Nil,Nil,'HELP',Nil, STR0009 + "( " + (cAliasDT2)->DT2_CODOCO + " )" , 1, 0) //-- "Ocorrência do GFE já vinculada na ocorrência do TMS " ###
				lRet := .F.
			EndIf
		EndIf
	EndIf
ElseIf cCampo == 'M->DT2_RESOCO'
	If lPrzEnt .And. M->DT2_PRZENT == StrZero(1, Len(DT2->DT2_PRZENT))  
		If M->DT2_RESOCO <> StrZero(2, Len(DT2->DT2_RESOCO)) .And. ;
		   (M->DT2_TIPOCO == StrZero(4, Len(DT2->DT2_TIPOCO)) .Or. M->DT2_TIPOCO == StrZero(5, Len(DT2->DT2_TIPOCO)) )
			//-- "O Prazo de Entrega (DT2_PRZENT), só poderá ser preenchido com conteúdo "SIM" se a Responsabilidade (DT2_RESOCO) 
			//-- for do  “Cliente” e se o Tipo da Ocorrência (DT2_TIPOCO) for  “04-Retorna documento” ou “05-Informativa”.
			Help("", 1, 'TMSA02019')
			lRet := .F.
		EndIf
	EndIf	

ElseIf cCampo == 'M->DT2_PRZENT'
	If M->DT2_LIBAUT == StrZero(1, Len(DT2->DT2_LIBAUT)) 
		If M->DT2_PRZENT == StrZero(2, Len(DT2->DT2_PRZENT)) 
			If M->DT2_RESOCO == StrZero(2, Len(DT2->DT2_RESOCO)) .And. ;
		   		(M->DT2_TIPOCO == StrZero(4, Len(DT2->DT2_TIPOCO)) .Or. M->DT2_TIPOCO == StrZero(5, Len(DT2->DT2_TIPOCO)) )
                //Se o Prazo de Entrega estiver preenchido como 'Não', a Liberação Automática também deverá ser preenchida como 'Não'.
				Help("", 1, 'TMSA02020')
				lRet := .F.
			EndIf	
		EndIf	
	EndIf		

EndIf

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA020Inc³ Autor ³ Patricia A. Salomao   ³ Data ³ 02.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de Manutencao do Arquivo DT2 (Cadastro de Operacoes)³±±
±±³          ³ Disparada por rotina automatica                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA020Inc(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo.                                  ³±±
±±³          ³ ExpC2 = Registro.                                          ³±±
±±³          ³ ExpC3 = Opcao Selecionada.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TMSA020Inc(cAlias,nReg,nOpc)
Local aArea := GetArea()

SAVEINTER()

FWExecView(STR0004,"VIEWDEF.TMSA020", MODEL_OPERATION_INSERT,, { || .T. } ,,  /*nPerReducTela*/ ) //'Incluir'

RestArea(aArea)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma TMSA020DelOkºAutor  ³Adalberto S.M       º Data ³  08/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Manutencao TMSA020.                                         º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA020DelOk()

	Local cAliasDWU	:= GetNextAlias()
	Local cQuery	:= ""
	Local lRet		:= .T.
	
	Local cAliasDUA := ""
	cQuery := "SELECT (COUNT(*)) DWU_COUNT "
	cQuery += "  FROM " + RetSqlName("DWU")+" DWU "
	cQuery += " WHERE DWU.DWU_FILIAL = '" + xFilial("DWU") + "'"
	cQuery += "   AND DWU.DWU_CODOCO = '" + DT2->DT2_CODOCO + "'"
	cQuery += "   AND DWU.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDWU,.T.,.T.)
	
	If (cAliasDWU)->DWU_COUNT > 0
		Help('',1,"TMSA02007") //-- Nao eh possivel excluir ocorrencia. Verifique o cadastro de Ocorrencias x Usuarios.
		lRet := .F.
	EndIf
	
	(cAliasDWU)->(DbCloseArea())

	//-- Verifica se existe registro de ocorrência
	cAliasDUA	:= GetNextAlias()
	cQuery := "SELECT COUNT(DUA_CODOCO) QUANTIDADE "
	cQuery += "  FROM " + RetSqlName("DUA")+" DUA "
	cQuery += " WHERE DUA_FILIAL = '" + xFilial("DUA") + "'"
	cQuery += "   AND DUA_CODOCO = '" + DT2->DT2_CODOCO + "'"
	cQuery += "   AND DUA.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUA,.T.,.T.)
	
	If (cAliasDUA)->QUANTIDADE > 0
		Help('',1,"TMSA02015") //-- Existem apontamentos para a ocorrência.
		lRet := .F.
	EndIf
	
	(cAliasDUA)->(DbCloseArea())

Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TMA020Cmt  ³ Autor ³ Valdemar Roberto    ³ Data ³ 23.02.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava registro                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA020Cmt(oExp01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExp01 = Modelo                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TMA020Cmt(oModel)

If lTmsToGfe
	cOcoAnt := DT2->DT2_CDTIPO
EndIf

FwFormCommit(oModel,/*bBefore*/,{|oModel,cID,cAlias,lNewRecord| TMA020CCmt(oModel,cID,cAlias,lNewRecord)},/*bAfterSTTS*/)
		
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TMA020CCmt ³ Autor ³ Valdemar Roberto    ³ Data ³ 23.02.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Complementa gravação do registro                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA020CCmt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TMA020CCmt(oModel,cId,cAlias,lNewRecord)
Local aAreas := {GU5->(GetArea()),GetArea()}

If lTmsToGfe
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() == MODEL_OPERATION_INSERT
		GU5->(DbSetOrder(1))
		If GU5->(DbSeek(xFilial("GU5") + M->DT2_CDTIPO))
			RecLock("GU5",.F.)
			GU5->GU5_OCOTMS := DT2->DT2_CODOCO
			GU5->(MsUnlock())
		EndIf
		If GU5->(DbSeek(xFilial("GU5") + cOcoAnt))
			RecLock("GU5",.F.)
			GU5->GU5_OCOTMS := Space(TamSX3("GU5_OCOTMS")[1])
			GU5->(MsUnlock())
		EndIf
	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
		If GU5->(DbSeek(xFilial("GU5") + cOcoAnt))
			RecLock("GU5",.F.)
			GU5->GU5_OCOTMS := Space(TamSX3("GU5_OCOTMS")[1])
			GU5->(MsUnlock())
		EndIf
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return .T.

