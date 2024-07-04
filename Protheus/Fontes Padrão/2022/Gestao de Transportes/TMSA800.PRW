#include "TMSA800.CH"
#Include "FWMVCDEF.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSA800  ³ Autor ³Patricia A. Salomao    ³ Data ³30.06.2003  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Contrato de Fornecedores                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA800()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador    ³ Data   ³ BOPS ³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Mauro Paladini ³15/10/13³      ³ Conversao da rotina para MVC            ³±±
±±³               ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA800()

Local oBrowse 	:= Nil
Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DUJ")
oBrowse:SetDescription(STR0001) // "Contrato de Fornecedores"
oBrowse:Activate()

Return Nil
 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ModelDef ³ Autor ³ Mauro Paladini        ³ Data ³21.08.2013³±±
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
Local oStruCDUJ := FwFormStruct( 1, "DUJ") 
Local oStruIDVG := FwFormStruct( 1, "DVG")

// Validacoes dos Fields
Local bPreValid	:= Nil
Local bPosValid := { |oMdl| PosVldMdl(oMdl) }
Local bComValid := Nil
Local bCancel	:= Nil
Local aCpoCheck := {}

// Validacoes da Grid
Local bLinePost	:= { |oMdl| PosVldLine(oMdl) }

oModel:= MpFormMOdel():New("TMSA800",  /*bPreValid*/ , bPosValid , /*bComValid*/ ,/*bCancel*/ )
oModel:SetDescription(STR0001) 		// "Contrato de Fornecedores"

oModel:AddFields("MdFieldCDUJ",Nil,oStruCDUJ,/*prevalid*/,,/*bCarga*/)
                              
oModel:SetPrimaryKey({ })


oModel:AddGrid("MdGridIDVG", "MdFieldCDUJ" /*cOwner*/, oStruIDVG , /*bLinePre*/ , bLinePost , /*bPre*/ , /*bPost*/,  /*bLoad*/)
oModel:SetRelation( "MdGridIDVG", { { "DVG_FILIAL" , 'xFilial("DVG")'  }, { "DVG_NCONTR", "DUJ_NCONTR" } }, DVG->( IndexKey( 1 ) ) )

oModel:GetModel("MdGridIDVG"):SetUseOldGrid()

Return ( oModel )                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ViewDef  ³ Autor ³ Mauro Paladini        ³ Data ³20.08.2013³±±
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

Local oModel 	:= FwLoadModel("TMSA800")
Local oView 	:= Nil

Local oStruCDUJ := FwFormStruct( 2, "DUJ") 
Local oStruIDVG := FwFormStruct( 2, "DVG")

oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField('VwFieldCDUJ', oStruCDUJ , 'MdFieldCDUJ') 
oView:AddGrid( 'VwGridIDVG', oStruIDVG , 'MdGridIDVG')

oView:CreateHorizontalBox("SUPERIOR",30)
oView:CreateHorizontalBox("INFERIOR",70)              

oView:EnableTitleView('VwFieldCDUJ')

oView:AddIncrementField( 'VwGridIDVG', 'DVG_ITEM' ) 

oView:SetOwnerView("VwFieldCDUJ","SUPERIOR")
oView:SetOwnerView("VwGridIDVG","INFERIOR")

Return(oView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Mauro Paladini        ³ Data ³14.08.2013³±±
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

Private aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0    //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA800" OPERATION 2 ACCESS 0    //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSA800" OPERATION 3 ACCESS 0    //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TMSA800" OPERATION 4 ACCESS 0    //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSA800" OPERATION 5 ACCESS 0    //"Excluir"
                
If ExistBlock("TM800MNU")
	ExecBlock("TM800MNU",.F.,.F.)
EndIf

Return ( aRotina )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PosVldLine  Autor ³ Mauro Paladini        ³ Data ³14.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Faz a validacao da linha na GRID (LineOk)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 - Verdadeiro ou Falso                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PosVldLine(oMld)

	Local lRet 		:= .T.
	Local oModel 	:= FWModelActive()
	Local oModelAtu := oModel:GetModel("MdGridIDVG")

	Private aCols 	:= oModelAtu:aCols
	Private aHeader	:= oModelAtu:aHeader
	Private n		:= oModelAtu:nLine	
	
	lRet := TMSA800LinOk()
	
Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA800LinOk  ³ Autor ³ Patricia A. Salomao  ³ Data ³30.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida a Linha digitada                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA800LinOk()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador    ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Mauro Paladini ³15/10/13³      ³ Conversao da rotina para MVC             ³±±
±±³               ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function TMSA800LinOk()

	Local lRet    := .T.
	Local cTabFre := ""
	Local cTipTab := ""
	Local cTabCar := ""
	Local lAbrCal := DVG->(ColumnPos("DVG_ABRCAL")) > 0
	Local lTipCal := DVG->(ColumnPos("DVG_TIPCAL")) > 0
	
	If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
		//-- Se for Transporte Aereo, sera' permitido informar varias Tabelas de Frete.
		If GdFieldGet("DVG_SERTMS",n) == StrZero(2, Len(DVG->DVG_SERTMS)) .And. GdFieldGet("DVG_TIPTRA",n) == StrZero(2, Len(DVG->DVG_TIPTRA))
			If DVG->(ColumnPos('DVG_TPOPVG')) > 0
				lRet := GDCheckKey( { 'DVG_SERTMS', 'DVG_TIPTRA', 'DVG_TIPVEI', 'DVG_TPOPVG', 'DVG_TABFRE', 'DVG_TIPTAB'}, 4 )
			Else
				lRet := GDCheckKey( { 'DVG_SERTMS', 'DVG_TIPTRA', 'DVG_TIPVEI', 'DVG_TABFRE', 'DVG_TIPTAB'}, 4 )
			EndIf
		Else
			If DVG->(ColumnPos('DVG_TPOPVG')) > 0
				lRet := GDCheckKey( { 'DVG_SERTMS', 'DVG_TIPTRA', 'DVG_TIPVEI', 'DVG_TPOPVG'}, 4 )
			Else
				lRet := GDCheckKey( { 'DVG_SERTMS', 'DVG_TIPTRA', 'DVG_TIPVEI'}, 4 )
			EndIf
		EndIf
	EndIf
	
	If lRet
	
		If !GdDeleted( n )
			cTabFre := GDFieldGet("DVG_TABFRE", n)
			cTipTab := GDFieldGet("DVG_TIPTAB", n)
			cTabCar := GDFieldGet("DVG_TABCAR", n)
	
			If !Empty(cTabCar) .And. !Empty(cTabFre)
				Help("", 1, "TMSA80002") // Utilize apenas uma tabela.
				lRet:= .F.
			EndIf
	
			If lRet .And. Empty(cTabCar) .And. Empty(cTabFre)
				Help("", 1, "TMSA80003") //"Informe a Tabela de Frete Ou a Tabela de Carreteiro"
				lRet:= .F.
			EndIf
	
			If lRet
				DTL->(dbSetOrder(1))
				If (!Empty(cTabFre) .Or. !Empty(cTipTab)) .And. ;
					!DTL->(MsSeek(xFilial('DTL')+cTabFre+cTipTab))
					Help("", 1, "TMSA80004") //Tabela de Frete Nao Cadastrada !!!
					lRet:= .F.
				EndIf

				If lRet .And. lAbrCal .And. FWFldGet("DVG_ABRCAL",n) $ '12'   
					If FwFldGet("DVG_SERTMS",n)  <> StrZero(3,Len(DVG->DVG_SERTMS))
						Help("", 1, "TMSA80009") //A Abrangencia de Calculo deve ser informada apenas para o Serviço de Transporte de ENTREGA
						lRet:= .F.
					EndIf
				EndIf

				If lRet .And. lTipCal .And. !Empty(FWFldGet("DVG_TIPCAL",n))
					If !Empty(cTabCar) 
						Help("", 1, "TMSA80010") //Não é permitido informar o 'Tipo de Calculo de Frete' para Tabela de Carreteiro. 
						lRet:= .F.
					EndIf
				EndIf

			EndIf
		EndIf
	
	EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º PosVldMdl  º Autor º        Nava        º Data º 15/10/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Faz a validacao do model                                    		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º                                                           º±±
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
±±ºMauro Paladini º 15/10/13 º      º Conversao para padrao MVC            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PosVldMdl(oMdl)

	Local aAreaDUJ  := DUJ->(GetArea())
	Local lRet      := .T.
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""         

	Local oModelDUJ := oMdl:GetModel("MdFieldCDUJ")	
	Local dFimVig	  := oModelDUJ:GetValue('DUJ_FIMVIG')
	Local dIniVig	  := oModelDUJ:GetValue('DUJ_INIVIG')
	Local cCodFor   := oModelDUJ:GetValue('DUJ_CODFOR')
	Local cLojFor   := oModelDUJ:GetValue('DUJ_LOJFOR')
	Local cNContr   := oModelDUJ:GetValue('DUJ_NCONTR')	
	
	Local oModel 	:= FWModelActive()
	Local oModelAtu := oModel:GetModel("MdGridIDVG")

	Private aCols 	:= oModelAtu:aCols
	Private aHeader	:= oModelAtu:aHeader
	Private n		:= oModelAtu:nLine		

	If oMdl <> Nil .And. oMdl:GetOperation() == MODEL_OPERATION_DELETE
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se existir Carreteiro utilizando o Contrato, nao permite excluir o mesmo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cQuery := " SELECT 1 "
		cQuery += "   FROM " + RetSqlName("DTY") + " DTY "
		cQuery += "   WHERE DTY.DTY_CODFOR = '"+DUJ->DUJ_CODFOR+"' "
		cQuery += "     AND DTY.DTY_LOJFOR = '"+DUJ->DUJ_LOJFOR+"' "
		cQuery += "  AND DTY.DTY_DATCTC >= '"+Dtos(DUJ->DUJ_INIVIG)+"' "

		If !Empty(dFimVig)
			cQuery += "  AND DTY.DTY_DATCTC <= '"+Dtos(DUJ->DUJ_FIMVIG)+"' "
		EndIf

		cQuery += "     AND DTY.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		If (cAliasQry)->(!Eof())
			Help( ' ', 1, 'TMSA80006') //"Existe Contrato(s) de Carreteiro(s) utilizando este Contrato..."
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	
	Elseif  oMdl <> Nil .And. oMdl:GetOperation() <> MODEL_OPERATION_DELETE
	
		lRet:= TMSA800LinOK()
	
		//-- Analisa se todos os itens da GetDados estao deletados.
		If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
			Help( ' ', 1, 'OBRIGAT2') //"Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
			Return ( .F. )
		EndIf
		
		If !Empty(dFimVig)

			cQuery := " SELECT COUNT(*) NREG "
			cQuery += "   FROM " + RetSqlName("DTY") + " DTY "
			cQuery += "   WHERE DTY.DTY_CODFOR = '"+DUJ->DUJ_CODFOR+"' "
			cQuery += "     AND DTY.DTY_LOJFOR = '"+DUJ->DUJ_LOJFOR+"' "
			cQuery += "  AND DTY.DTY_DATCTC >= '"+Dtos(dFimVig)+"' "
			cQuery += "     AND DTY.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
			If (cAliasQry)->NREG > 0
				Help( ' ', 1, 'TMSA80007') //Data de vigência inválida. Existe(m) Contrato(s) de Carreteiro(s) com data superior a data final de vigencia!
				lRet := .F.
			EndIf
	
			(cAliasQry)->(DbCloseArea())

		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe outro contrato na mesma data de vigencia para o cliente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  oMdl <> Nil .And. oMdl:GetOperation() <> MODEL_OPERATION_UPDATE
		
			dbSelectArea("DUJ")
			dbSetOrder(2)
			If lRet .And. DUJ->(MsSeek(xFilial('DUJ')+cCodFor+cLojFor))
	
				Do While !Eof() .And. DUJ->DUJ_FILIAL+DUJ->DUJ_CODFOR+DUJ->DUJ_LOJFOR == xFilial('DUJ')+cCodFor+cLojFor
				If DUJ->DUJ_NCONTR <> cNContr .And.;
				(Empty(DUJ->DUJ_FIMVIG) .Or. ( dIniVig <=DUJ->DUJ_FIMVIG .Or.;
				If(!Empty(dFimVig),dFimVig<=DUJ->DUJ_INIVIG,.F.) ) )
					Help(" ", 1, "TMSA80001") // Ja existe Contrato cadastrado para este Fornecedor ...
					lRet := .F.
					Exit
				EndIf
				DUJ->(dbSkip())
			EndDo
	
			EndIf
		
		EndIf
			
	Endif
	
	RestArea(aAreaDUJ)

Return lRet 



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA800Val    ³ Autor ³ Patricia A. Salomao  ³ Data ³01.07.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao dos campos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA800Val()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function TMSA800Val()

	Local lRet      := .T.
	Local cTabela   := ""
	Local cTipo     := ""
	Local cCampo    := ReadVar()
	Local cCatTab   := StrZero(2, Len(DTL->DTL_CATTAB)) // Categoria da Tabela : Frete a Pagar 
	Local lTMSA730  := IsInCallStack("TMSA730")  //Geração Contrato Fornecedor
	Local oModel 	:= Iif(lTMSA730, Nil, FWModelActive() )
	Local oModelAtu := Iif(lTMSA730, Nil, oModel:GetModel("MdGridIDVG") )
	Local lAchou     := .F.
	Local lTMSOPdg   := SuperGetMV("MV_TMSOPDG",,"0") == "2"
	Local cCodOper   := "01"
	Local cDVG_Sertms:= ""
	
	If cCampo $ 'M->DVG_TABFRE.M->DVG_TIPTAB'

		If cCampo == 'M->DVG_TABFRE'

			cTabela := M->DVG_TABFRE
			// Se a tabela nao for preenchida limpa tb o tipo de tabela
			If Empty(cTabela)
				If lTMSA730
					GDFieldPut( 'DVG_TIPTAB' , Criavar("DVG_TIPTAB",.F.) , n )
				Else	
					oModel:SetValue( "MdGridIDVG" , "DVG_TIPTAB" , Criavar("DVG_TIPTAB",.F.) )
				EndIf	
			EndIf
			If lTMSA730
				cTipo   := GdFieldGet('DVG_TIPTAB',n)				
			Else	
				cTipo   := oModel:GetValue( "MdGridIDVG" , 'DVG_TIPTAB' )
			EndIf	

		ElseIf cCampo == 'M->DVG_TIPTAB'

			cTipo   := M->DVG_TIPTAB
			// Se o tipo nao for preenchido limpa tb a tabela
			If Empty(cTipo)
				If lTMSA730
					GDFieldPut( 'DVG_TABFRE' , Criavar("DVG_TABFRE",.F.) , n )
				Else	
					oModel:SetValue( "MdGridIDVG" , "DVG_TABFRE",Criavar("DVG_TABFRE",.F.) )
				EndIf	
			EndIf

			If lTMSA730
				cTabela := GdFieldGet('DVG_TABFRE',n)
			Else	
				cTabela := oModel:GetValue( "MdGridIDVG" , 'DVG_TABFRE' )
			EndIf	

		EndIf

		If !Empty(cTabela) .And. !Empty(cTipo)
			lRet := TMSTbAtiva( cTabela, cTipo,,, cCatTab, .T.)
		EndIf
	ElseIf cCampo == "M->DVG_OPERAC" 
		If lTMSOPdg
			cDVG_Sertms:= Iif(lTMSA730, GdFieldGet('DVG_SERTMS',n), oModel:GetValue( "MdGridIDVG" , 'DVG_SERTMS' ))

			DEJ->(dbSetOrder(1)) //DEJ_FILIAL+DEJ_CODOPE+DEJ_ITEM
			DEJ->(MsSeek(xFilial("DEJ")+cCodOper))
			While DEJ->(!Eof() .And. DEJ_FILIAL+DEJ_CODOPE == xFilial("DEJ")+cCodOper)
				If	M->DVG_OPERAC == DEJ->DEJ_OPERAC .And. DEJ->DEJ_SERTMS == cDVG_Sertms
					lAchou := .T.
					Exit
				EndIf
				DEJ->(dbSkip())
			EndDo
		EndIf
		If !lAchou
			lRet := .F.
			Help('', 1, 'REGNOIS')
		EndIf
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA800Whe³ Autor ³ Eduardo de Souza      ³ Data ³ 23/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verificar a permissao da digitacao dos campos.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sibtaxe   ³ TMSA800Whe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SINCRONIZADOR                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA800Whe()

	Local lRet   	:= .T.
	Local cCampo 	:= ReadVar()
	Local oModel 	:= FWModelActive()
	
	If cCampo == "M->DVG_TABCAR"
		If !Empty( oModel:GetValue( "MdGridIDVG" , 'DVG_TIPVEI' ) )
			lRet := .F.
		EndIf
	ElseIf cCampo == "M->DVG_ABRCAL"
		//-- Campo habilitado somente para Entrega
		lRet:= oModel:GetValue( "MdGridIDVG" , 'DVG_SERTMS' ) == StrZero(3,Len(DVG->DVG_SERTMS))
	ElseIf cCampo == "M->DVG_TIPCAL"
		lRet:= Empty(oModel:GetValue( "MdGridIDVG" , 'DVG_TABCAR' )) 
	EndIf

Return lRet



