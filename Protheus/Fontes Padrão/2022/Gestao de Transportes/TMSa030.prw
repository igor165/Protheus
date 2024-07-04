#include "TMSA030.ch"
#include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º  TMSA030   º Autor º        Nava        º Data º 02/11/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                        Componentes de Frete                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º  TMSA030()                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º NIL                                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º SigaTMS - Gestao de Transportes                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º                                                           º±±
±±º            º                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador    º  Data    º BOPS º Motivo da Alteracao                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMauro Paladini º 09/08/13 º      º Conversao para padrao MVC            º±±
±±ºMauro Paladini º 06/12/13 º      º Ajustes para funcionamento do Mile   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSA030()

Local oBrowse := Nil
Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DT3")
oBrowse:SetDescription(STR0001) //"Componentes de Frete"
oBrowse:Activate()

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ModelDef ³ Autor ³ Mauro Paladini        ³ Data ³09.08.2013³±±
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

Local oModel		:= Nil
Local oStruDT3	:= Nil
Local oStruDJE	:= Nil

Local bPreValid	:= Nil
Local bPosValid	:= { |oMdl| PosVldMdl(oMdl) }
Local bCommit		:= { |oMdl| CommitMdl(oMdl) }
Local bCancel		:= Nil
Local lTabDJE	    := AliasIndic("DJE")

oStruDT3	:= FWFormStruct(1,"DT3")

oModel:= MpFormMOdel():New("TMSA030",  /*bPreValid*/ , bPosValid , bCommit ,/*bCancel*/ )
oModel:AddFields("MdFieldDT3",Nil,oStruDT3,/*prevalid*/,,/*bCarga*/)
oModel:SetDescription(STR0001) 	// ""Componentes de Frete"

If lTabDJE
	oStruDJE	:= FwFormStruct( 1, "DJE" )
	
	oModel:AddGrid( "MdGridDJE", "MdFieldDT3", oStruDJE )
	
	oModel:SetRelation( "MdGridDJE", { { "DJE_FILIAL", "xFilial( 'DJE' )" }, { "DJE_CODPAS", "DT3_CODPAS" } }, DJE->( IndexKey( 1 ) ) )
	
	oModel:GetModel( "MdGridDJE" ):SetUniqueLine( { "DJE_CMPREL" } )
	
	oModel:GetModel( "MdGridDJE" ):SetOptional( .T. )
	
	oModel:GetModel("MdGridDJE"):SetDescription(STR0001) // "Componentes de Frete"
EndIf	

	oModel:SetPrimaryKey({"DT3_FILIAL","DT3_CODPAS"})

Return ( oModel )                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ViewDef  ³ Autor ³ Mauro Paladini        ³ Data ³09.08.2013³±±
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

Local oModel 	:= FwLoadModel("TMSA030")
Local oView 	:= Nil
Local oStruDJE:= Nil 
Local lTabDJE := AliasIndic("DJE")

oView:= FwFormView():New()
oView:SetModel(oModel)

If !lTabDJE
	oView:CreateHorizontalBox( "TELA"	, 100 )
Else
	oStruDJE:=FwFormStruct( 2, "DJE" )
	oStruDJE:RemoveField( "DJE_CODPAS" )
	oView:CreateHorizontalBox( "TELA"	, 050 )
	oView:CreateHorizontalBox( "Grid"	, 050 )
EndIf

oView:AddField('VwFieldDT3', FWFormStruct(2,"DT3") , 'MdFieldDT3') 
oView:SetOwnerView("VwFieldDT3","TELA")

If lTabDJE	
	oView:AddGrid( "VwGridDJE", oStruDJE, "MdGridDJE" )
	oView:SetOwnerView( "VwGridDJE"		, "Grid"	)

	oView:AddIncrementView( "VwGridDJE", "DJE_ITEM" )
	oView:EnableTitleView( "VwGridDJE",STR0019 )  //Componentes Relacionados
EndIf		

Return(oView)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Mauro Paladini        ³ Data ³09.08.2013³±±
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

ADD OPTION aRotina TITLE STR0014 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE STR0015 	ACTION "VIEWDEF.TMSA030" OPERATION 2 ACCESS 0  //"Visualizar"
ADD OPTION aRotina TITLE STR0016 	ACTION "VIEWDEF.TMSA030" OPERATION 3 ACCESS 0  //"Incluir"
ADD OPTION aRotina TITLE STR0017 	ACTION "VIEWDEF.TMSA030" OPERATION 4 ACCESS 0  //"Alterar"
ADD OPTION aRotina TITLE STR0018 	ACTION "VIEWDEF.TMSA030" OPERATION 5 ACCESS 0  //"Excluir"
ADD OPTION aRotina TITLE STR0020 	ACTION "VIEWDEF.TMSA030" OPERATION 9 ACCESS 0  //"Copiar"

Return ( aRotina )





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º PosVldMdl  º Autor º        Nava        º Data º 02/11/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º        	Deleta a Componentes de Frete e seus Filhos (DT1)   		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º  TMSA030Del()                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                         			       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º NIL                                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º SigaTMS - Gestao de Transportes                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º                                                           º±±
±±º            º                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador    º  Data    º BOPS º Motivo da Alteracao                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMauro Paladini º 09/08/13 º      º Conversao para padrao MVC            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PosVldMdl(oMdl)

Local lRet    := .T.
Local lTabDJE := AliasIndic("DJE")
Local oMdldje := oMdl:GetModel("MdGridDJE")

If oMdl <> Nil .And. oMdl:GetOperation() == MODEL_OPERATION_DELETE

	DVE->(DbSetOrder(2))  // DVE_FILIAL + DVE_CODPAS
	If DVE->(DbSeek(xFilial("DVE") + FwFldGet("DT3_CODPAS")))
		Help(' ', 1, 'TMSA03001')  //-- Nao pode excluir Componente de Frete com Lay-out de Tabela relacionado.
		lRet := .F.
	Else
		If Aviso(	STR0002, STR0003 + FwFldGet("DT3_CODPAS") + CRLF + ; //"AVISO"###"Apagar Componentes de Frete "
					STR0004, { STR0005, STR0006 },, STR0007 ) == 1 //"e TODAS as tabelas CADASTRADAS COM ESTE CODIGO"###"Confirma"###"Cancela"###"Confirmacao"
	
			DbSelectArea( "DT3" )
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf
Else
	If  oMdl <> Nil .And. lTabDJE 
		If FwFldGet("DT3_TIPFAI") == '16' //Herda Valor
			If oMdldje:Length() <= 1 .And. (oMdldje:IsEmpty() .Or. oMdldje:IsDeleted())
				Help(' ', 1, 'TMSA03007')  //-- Para o componente que calcula sobre 16-Herda Valor, é obrigatorio informar os componentes relacionados.
				lRet := .F.
			EndIf
		If lRet .And. FwFldGet("DT3_TAXA") == StrZero(1,Len(FwFldGet("DT3_TAXA")))  //Sim
				Help(' ', 1, 'TMSA03012')  //-- Nao é permitido informar TAXA igual a SIM, para componentes que Calcula Sobre '16-Herda Valor'
				lRet := .F.
			EndIf	
		Else
			If oMdldje:Length(.T.) >= 1 .And. !oMdldje:IsEmpty()
				Help(' ', 1, 'TMSA03010')  //-- Para componentes com calcula sobre diferente de 16-Herda Valor, não é permitido informar componentes relacionados.
				lRet := .F.
			EndIf
		EndIf	
	
	EndIf
Endif

Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CommitMdl ³ Autor ³ Mauro Paladini        ³ Data ³02.10.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de gravacao no commit (substituiu a funcao de grv)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CommitMdl()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
*/

Static Function CommitMdl(oModel)

	Begin Transaction
	
		FwFormCommit(oModel/*oModel*/,/*bBefore*/,/*bAfter*/,/*bAfterSTTS*/)
		If oModel:GetOperation() == MODEL_OPERATION_DELETE
			TMA030ComA()		
		Endif
	
	End Transaction

Return .T.

 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tma030ComA³ Autor ³ Mauro Paladini        ³ Data ³02.10.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao auxiliar de gravacao do commit                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tma010Comm()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
*/
Static Function TMA030ComA()

Local cQuery  := ""

cQuery := "UPDATE " + RetSqlName('DT1')
cQuery += "   SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_ "
cQuery += " WHERE DT1_FILIAL = '" + xFilial( 'DT1' ) + "' "
cQuery += "   AND DT1_CODPAS = '" + DT3->DT3_CODPAS + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
If TCSqlExec( cQuery ) <> 0
	Help('',1,'TMSA03015',,'DT1',04,01) //-- Erro ao Excluir Registro da Tabela:
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA030Wh ³ Autor ³ Robson Alves          ³ Data ³25.09.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Nao permite a altercao do campo(DT3_TIPFAI) se o componente³±±
±±³          ³estiver sendo utilizado no layout da tabela de frete.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA030Wh()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
*/

Function TmsA030Wh()

Local cCampo  := ReadVar()
Local lRet    := .T.

If Altera
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o componente esta sendo usando no layout da tabela.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DVE->(dbSetOrder(2))
	lRet := !(DVE->(MsSeek(xFilial("DTL") + M->DT3_CODPAS)))
EndIf

If cCampo $ 'M->DT3_AGRVAL.M->DT3_APLDES'
	lRet := ( M->DT3_TIPFAI <= StrZero( 50, Len(DT3->DT3_TIPFAI)) )
ElseIf cCampo == 'M->DJE_CMPREL'
	lRet:= M->DT3_TIPFAI == '16' //Herda Valor
ElseIf cCampo == 'M->DT3_FAIXA2'
	If M->DT3_TIPFAI == '18' // TDA X REGIÃO 
		lRet := .F. 
	EndIf 
EndIf

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA030WPe³ Autor ³ Alex Egydio           ³ Data ³24.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Nao permite alterar o campo DT3_CALPES se o conteudo for 0 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA030WPe()

Local cCampo	:= ReadVar()
Local lRet		:= .T.

//-- Nao permite digitar se o conteudo for igual a 0-Nao Tem
If	cCampo == 'M->DT3_CALPES'
	lRet := ( M->DT3_CALPES != StrZero(0,Len(DT3->DT3_CALPES)) )
ElseIf cCampo == 'M->DT9_CALPES'

	lRet := AT250WhCfg()

	
EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA030Vld³ Autor ³ Alex Egydio           ³ Data ³24.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida antes de editar o campo.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA030Vld()

Local cCampo	:= ReadVar()
Local lRet		:= .T.
Local nTipFai	:= Len(DT3->DT3_TIPFAI)
Local nFaixa	:= Len(DT3->DT3_FAIXA)
Local cTipFai := ""

If	cCampo $ 'M->DT3_TIPFAI.M->DT3_FAIXA.M->DT3_FAIXA2'
	
	If cCampo = 'M->DT3_TIPFAI'
		//-- Gatilha a Faixa padrao
		M->DT3_FAIXA := M->DT3_TIPFAI
	ElseIf cCampo = 'M->DT3_FAIXA'
		//-- Verifica se a Faixa esta preenchida.
		If Empty(M->DT3_FAIXA)
			lRet := .F.
		EndIf
		// -- Se for praca de pedagio valida o campo DT3_FAIXA
		If lRet .And. M->DT3_TIPFAI == StrZero(9, Len(DT3->DT3_TIPFAI))
			If M->DT3_FAIXA <> StrZero(9, Len(DT3->DT3_TIPFAI))
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	If lRet
		//-- Compara os campos Calcula Sobre e Faixa Por para veirificacao das faixas reservadas.
		If !Empty(M->DT3_TIPFAI) .And. !Empty(M->DT3_FAIXA)
			If M->DT3_TIPFAI <  "50" .And. M->DT3_FAIXA >= "50"
				Help(' ', 1, 'TMSA03003') //A 'Faixa Por' devera ser entre a numeracao disponibilizada para componentes de tabela A Receber.
				lRet := .F.
			ElseIf M->DT3_TIPFAI >= "50" .And. M->DT3_FAIXA < "50"
				Help(' ', 1, 'TMSA03004') //A 'Faixa Por' devera ser entre a numeracao disponibilizada para componentes de tabela A Pagar
				lRet := .F.
			EndIf
			//-- Compara os campos Calcula Sobre e Sub Faixa para veirificacao das faixas reservadas.
			If lRet .And. !Empty(M->DT3_TIPFAI) .And. DT3->(FieldPos("DT3_FAIXA2")) > 0 .And. !Empty(M->DT3_FAIXA2)
				If M->DT3_TIPFAI <  "50" .And. M->DT3_FAIXA2 >= "50"
					Help(' ', 1, 'TMSA03005') //A 'Sub Faixa' devera ser entre a numeracao disponibilizada para componentes de tabela A Receber.
					lRet := .F.
				ElseIf M->DT3_TIPFAI >= "50" .And. M->DT3_FAIXA2 < "50"
					Help(' ', 1, 'TMSA03006') //A 'Sub Faixa' devera ser entre a numeracao disponibilizada para componentes de tabela A Pagar.
					lRet := .F.
				EndIf
			EndIf
			
			If lRet .And. M->DT3_TIPFAI = '14' .And. M->DT3_FAIXA <> M->DT3_TIPFAI
				lRet	:= .F.
				Help(' ', 1, 'TMSA03007') //--A 'Sub Faixa' deverá ser igual ao campo 'Calcula Sobre' quando o campo for igual a '14'.                                        
			EndIf
			
		EndIf
	EndIf
	
	//-- Se o componente for calculado por PESO MERCADORIA / PESO TRANSPORTADO (DT3_TIPFAI) ou
	//-- se a Faixa for por PESO MERCADORIA / PESO TRANSPORTADO (DT3_FAIXA)
	//-- se a Sub Faixa por PESO MERCADORIA / PESO TRANSPORTADO (DT3_FAIXA2)
	//-- preencher o campo Calc. Peso c/ 2-Peso cubado
	If lRet
		If	M->DT3_TIPFAI == StrZero(1,nTipFai ) .Or. M->DT3_TIPFAI == StrZero(51,nTipFai) .Or.;
			M->DT3_TIPFAI == StrZero(62,nFaixa ) .Or. M->DT3_FAIXA  == StrZero(62,nFaixa ) .Or.;
			M->DT3_FAIXA  == StrZero(1,nFaixa ) .Or. M->DT3_FAIXA  == StrZero(51,nFaixa ) .Or.;
			( DT3->(FieldPos("DT3_FAIXA2")) > 0 .And. ( M->DT3_FAIXA2 == StrZero(1,nFaixa) .Or. M->DT3_FAIXA2 == StrZero(51,nFaixa)) )
			M->DT3_CALPES := StrZero(2,Len(DT3->DT3_CALPES))
			//-- Caso contrario, preencher c/ 0	-Nao utiliza
		Else
			M->DT3_CALPES := StrZero(0,Len(DT3->DT3_CALPES))
		EndIf
		//-- Se o componente informado for > 50, preencher os campos 'Agrupa Valor' e 'Apl. Desconto' c/ Nao Utiliza
		If M->DT3_TIPFAI > StrZero(50,nTipFai)
			M->DT3_AGRVAL := StrZero(0,Len(DT3->DT3_AGRVAL))
			M->DT3_APLDES := StrZero(0,Len(DT3->DT3_APLDES))
		EndIf
	EndIf
	
ElseIf cCampo == 'M->DT3_CALPES'
	//-- Se o componente for calculado pelo peso, nao permitir digitar no campo Calc. Peso o valor 0-Nao Utiliza
	If	M->DT3_TIPFAI == StrZero(1,nTipFai) .Or.	M->DT3_TIPFAI == StrZero(51,nTipFai) .Or. M->DT3_TIPFAI == StrZero(62,nTipFai)
		lRet := ( M->DT3_CALPES != StrZero(0,Len(DT3->DT3_CALPES)) )
	EndIf
ElseIf cCampo == 'M->DT9_CALPES'
	If	GDFieldGet('DT9_CALPES',n) != StrZero(0,Len(DT9->DT9_CALPES))
		lRet := ( M->DT9_CALPES != StrZero(0,Len(DT9->DT9_CALPES)) )
	EndIf
ElseIf cCampo == 'M->DJE_CMPREL'
	cTipFai:= Posicione('DT3', 1, xFilial('DT3') + M->DJE_CMPREL, 'DT3_TIPFAI')
	
	If cTipFai >=  StrZero(50,Len(DT3->DT3_TIPFAI))
		Help(' ', 1, 'TMSA03011') //Somente é permitido selecionar componentes de tabela A Receber.
		lRet := .F.
	ElseIf cTipFai == StrZero(16,Len(DT3->DT3_TIPFAI))
		Help(' ', 1, 'TMSA03008') //Nao é permitido selecionar componentes que calcula sobre 16-Herda Valor
		lRet:= .F.
	EndIf
	
ElseIf cCampo == 'M->DT3_TXADIC'
	If M->DT3_TIPFAI == StrZero(17,nTipFai).And. M->DT3_TXADIC == StrZero(1,Len(DT3->DT3_TXADIC))
		Help(' ', 1, 'TMSA03009') //Nao é permitido selecionar componentes com calcula sobre 17 com Taxa Adicional "Sim".
		lRet:= .F.
	EndIf	

ElseIf cCampo == 'M->DT3_CODPAS'
	If M->DT3_CODPAS == 'TF'
		Help(' ', 1, 'TMSA03016') //Não é permitido a inclusão do código 'TF' para o compomente de frete esse, o código e reservado para o Total do Frete.
		lRet:= .F.
	EndIf
EndIf


Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA030BFx³ Autor ³ Eduardo de Souza      ³ Data ³ 05/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ x3_Box do campo DT3_FAIXA                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA030BFx()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA030BFx()

Local cRet := ""
Local nCnt := 0
Local aRet := TMSValField("TIPFAI",.F.,,.F.,.T.)

If ValType(aRet) == "A"
	For nCnt := 1 To Len(aRet)
		If !Empty(cRet)
			cRet += ";"
		EndIf
		cRet += aRet[nCnt,01] + "=" + aRet[nCnt,2]
	Next nCnt
EndIf

Return cRet


