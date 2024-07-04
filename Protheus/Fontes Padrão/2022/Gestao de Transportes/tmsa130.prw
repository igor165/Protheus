#include "TMSA130.ch"   
#include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"                 

Static lTMA010His := ExistBlock("TMA010HIS")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º  TMSA130   º Autor º        Nava        º Data º 18/12/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                 Configuracao da Tabela de Frete                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º TMSA130()                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º Nenhum                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º NIL                                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º SigaTMS - Gestao de Transportes                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º Seleciona quais Folders vao existir para cada tabela de   º±±
±±º            º de Frete                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Mauro      º06/12/13º      º Ajustes para funcionamento do Mile        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION TMSA130()
LOCAL aArea	  := GetArea()
Local oBrowse   := Nil
Private aRotina := MenuDef()


oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DTL")
oBrowse:SetDescription(STR0001) //"Configuracao da Tabela de Frete"
oBrowse:SetCacheView(.F.) //-- Desabilita Cache da View, pois gera colunas dinamicamente
oBrowse:Activate()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura os dados de entrada                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RestArea( aArea )


RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ModelDef ³ Autor ³ Daniel Leme           ³ Data ³29.08.2013³±±
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

Local oModel	  := Nil
Local oStruCDTL := FwFormStruct( 1, "DTL") 
Local oStruIDVE := FwFormStruct( 1, "DVE")

// Validacoes dos Fields
Local bPreValid := Nil
Local bPosValid := { |oModel| PosVldMdl(oModel) }
Local bComValid := Nil
Local bCancel	  := Nil
Local aCpoCheck := {'DVE_CODPAS'}

// Validacoes da Grid
Local bLinePost	:= { |oModel| PosVldLine(oModel) }

Local lContHis  := GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete
Local lAux,bWheAux 
Local lNoUpd := .F.

If !IsInCallStack("CFG600LMdl") .And. !IsInCallStack("FWMILEIMPORT") .And. !IsInCallStack("FWMILEEXPORT") .And. Type("Altera") != "U" .And. Altera
	If lTMA010His
		lAux := ExecBlock("TMA010HIS",.F.,.F.,{4,DTL->DTL_TABFRE,DTL->DTL_TIPTAB}) 
		If ValType(lAux) <> "L"
			lAux :=.T.
		EndIf   
		lContHis := lAux
	EndIf   

	If lContHis .And. TMSA130Has(DTL->DTL_TABFRE,DTL->DTL_TIPTAB)
		lNoUpd := .T.
		
		bWheAux := oStruIDVE:GetProperty( "DVE_COMOBR" , MODEL_FIELD_WHEN)
		oStruCDTL:SetProperty( "*" , MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, '.F.' )) //-- Não permite alterar
		oStruIDVE:SetProperty( "*" , MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, '.F.' )) //So permite alterar na GetDados o campo "Componente Obrigatorio?"
		oStruIDVE:SetProperty( "DVE_COMOBR" , MODEL_FIELD_WHEN,bWheAux) //So permite alterar na GetDados o campo "Componente Obrigatorio?"
	EndIf	 
EndIf	

oModel:= MpFormMOdel():New("TMSA130",  /*bPreValid*/ , bPosValid, /*bComValid*/ ,/*bCancel*/ )
oModel:SetDescription(STR0001) 		//"Configuracao da Tabela de Frete"

oModel:AddFields("MdFieldCDTL",Nil,oStruCDTL,/*prevalid*/,,/*bCarga*/)

oModel:AddGrid("MdGridIDVE", "MdFieldCDTL" /*cOwner*/, oStruIDVE , {|oModelGrid,nLine,cAction| PreVldMdl(oModelGrid,nLine,cAction)} /*bLinePre*/ , bLinePost , /*bPre*/ , /*bPost*/,  /*bLoad*/)
oModel:SetRelation( "MdGridIDVE", { { "DVE_FILIAL" , 'xFilial("DVE")'  }, { "DVE_TABFRE", "DTL_TABFRE" } , { "DVE_TIPTAB","DTL_TIPTAB"} }, DVE->( IndexKey( 1 ) ) )

oModel:GetModel( "MdGridIDVE" ):SetUniqueLine( aCpoCheck )
oModel:GetModel("MdGridIDVE"):SetUseOldGrid()

If lNoUpd
	oModel:GetModel( "MdGridIDVE" ):SetNoDeleteLine( .T. )
	oModel:GetModel( "MdGridIDVE" ):SetNoInsertLine( .T. )
EndIf

oModel:SetVldActivate( { | oModel | VldActiv( oModel ) } )

Return ( oModel ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ViewDef  ³ Autor ³ Daniel Leme           ³ Data ³29.08.2013³±±
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

Local oModel 	:= FwLoadModel("TMSA130")
Local oView 	:= Nil

Local oStruCDTL 	:= FwFormStruct( 2, "DTL") 
Local oStruIDVE 	:= FwFormStruct( 2, "DVE") 

Local aOpc			:= {MODEL_OPERATION_VIEW,MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE,MODEL_OPERATION_DELETE}

Local aSomaButtons
Local nCntFor

oStruIDVE:RemoveField("DVE_COPPAS")
oStruIDVE:RemoveField("DVE_PERREA")
oStruIDVE:RemoveField("DVE_TABFRE")
oStruIDVE:RemoveField("DVE_TIPTAB")

oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField('VwFieldCDTL', oStruCDTL , 'MdFieldCDTL') 
oView:AddGrid( 'VwGridIDVE', oStruIDVE , 'MdGridIDVE')

oView:CreateHorizontalBox("SUPERIOR",30)
oView:CreateHorizontalBox("INFERIOR",70)              

oView:EnableTitleView('VwFieldCDTL')
oView:EnableTitleView('VwGridIDVE',STR0027) //"Itens da Conf. Tabela Frete"

oView:AddIncrementField( 'VwGridIDVE', 'DVE_ITEM' ) 

oView:SetOwnerView("VwFieldCDTL","SUPERIOR")
oView:SetOwnerView("VwGridIDVE","INFERIOR")

//-- Ponto de entrada para incluir botoes
If	ExistBlock('TM130BUT')
	For nCntFor := 1 To Len(aOpc)
		aSomaButtons:=ExecBlock('TM130BUT',.F.,.F.,{aOpc[nCntFor]})
		If	ValType(aSomaButtons) == 'A'
			AEval( aSomaButtons, { |x| oView:AddUserButton( x[3], x[1], x[2] ,NIL,NIL, {aOpc[nCntFor]}) } ) 			
		EndIf
	Next nCntFor
EndIf

Return(oView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VldActiv ³ Autor ³ Daniel Leme           ³ Data ³29.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação Ativação do Model                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oView do objeto oView                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldActiv(oModel)
Local lRet := .T.
Local lContHis  := GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete
Local lAux

If oModel:GetOperation() == MODEL_OPERATION_DELETE
	If lTMA010His
		lAux := ExecBlock("TMA010HIS",.F.,.F.,{5,DTL->DTL_TABFRE,DTL->DTL_TIPTAB}) 
		If ValType(lAux) <> "L"
			lAux :=.T.
		EndIf   
		lContHis := lAux
	EndIf   

	If lContHis .And. TMSA130Has(DTL->DTL_TABFRE,DTL->DTL_TIPTAB)
		Help("", 1, "TMSA13002") //A Configuracao da Tabela de Frete Nao podera ser Excluida pois esta sendo utilizado por alguma Tabela de Frete ...
		lRet := .F.
	EndIf	 
EndIf	

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PosVldMdl³ Autor ³ Daniel Leme           ³ Data ³29.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação TOk                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oView do objeto oView                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PosVldMdl(oModel)
Local lRet := .T.
Local lContHis  := GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete
Local lAux

If oModel:GetOperation() == MODEL_OPERATION_DELETE
	If lTMA010His
		lAux := ExecBlock("TMA010HIS",.F.,.F.,{oModel:GetOperation(),DTL->DTL_TABFRE,DTL->DTL_TIPTAB}) 
		If ValType(lAux) <> "L"
			lAux :=.T.
		EndIf   
		lContHis := lAux
	EndIf   

	If lContHis .And. TMSA130Has(DTL->DTL_TABFRE,DTL->DTL_TIPTAB)
		Help("", 1, "TMSA13002") //A Configuracao da Tabela de Frete Nao podera ser Excluida pois esta sendo utilizado por alguma Tabela de Frete ...
		lRet := .F.
	EndIf	 
EndIf	 

If lRet .And. ExistBlock("TMA130TOK")
	lRet:=ExecBlock("TMA130TOK",.F.,.F.)
	If ValType(lRet) # "L"
		lRet:=.T.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PosVldLine³ Autor ³ Daniel Leme           ³ Data ³29.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação LOk                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico - Se a linha foi aceita                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PosVldLine(oModel)
Local aArea   := GetArea()
Local lRet		:= .T.
Local aTemp	:= {}
Local nPos		:= 0
Local nI		:= 0

Private aHeader
Private aCols	

SaveInter()

n		:= oModel:GetLine() //Controle de numero da linha
aHeader:= oModel:aHeader
aCols	:= oModel:aCols
    
//-- Nao avalia linhas deletadas.
If	 !GDDeleted( n )
	
	For ni:= 1 to Len(Acols)
		IF !GDDeleted( nI )
			DT3->(DBSETORDER(1))
			DT3->(DbSeek(XFILIAL("DT3")+ GdFieldGet('DVE_CODPAS',ni)))
			
			nPos13 := aScan(aTemp,{|x| x[1] == "13" })
			nPos14 := aScan(aTemp,{|x| x[1] == "14" })
			nPos18 := aScan(aTemp,{|x| x[1] == "18" })
			
     		IF DT3->DT3_TIPFAI > "50" .And. M->DTL_CATTAB == "1"
     			Help( ,, 'HELP',, "Componente do tipo 'a pagar' não pode ser relacionado a uma tabela de frete do tipo 'a receber'." , 1, 0)
     			lRet := .F.
     		EndIf			

     		If lRet
	     		IF DT3->DT3_TIPFAI == "09" .AND. M->DTL_CATTAB == "2"
		       		Help("", 1, "TMSA13009") // Não é permitido vincular componentes com o campo calcula sobre igual praça de pedágio em tabela de frete do tipo a pagar.
	        		lRet := .F.        
	     		EndIF
				IF DT3->DT3_TIPFAI == "13"
					
					IF Len(aTemp) == 0
						AAdd(aTemp,{DT3->DT3_TIPFAI, ni})
					ElseIF nPos13 > 0 .and. nPos14 == 0 .and. nPos18 == 0 
						aTemp[nPos13,2] := nI
					ElseIF (nPos13 > 0 .and. nPos14 > 0) .or. (nPos13 == 0 .and. nPos14 > 0)
						IF aTemp[nPos14,2] < nI
						   Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
							Exit
						Else
							IF nPos13 > 0
								aTemp[nPos13,2] := nI
							Else
								AAdd(aTemp,{DT3->DT3_TIPFAI, ni})		
							EndIF
						EndiF
					ElseIf (nPos13 > 0 .and. nPos18 > 0) .Or. (nPos13 == 0 .and. nPos18 > 0)
						If aTemp[nPos18,2] < nI
							Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
							Exit
						EndIf 
					Endif
					
				ElseIF DT3->DT3_TIPFAI == "14"
					
					IF Len(aTemp) == 0
						AAdd(aTemp,{DT3->DT3_TIPFAI, ni})
					ElseIF nPos14 > 0 .and. nPos13 == 0 .and. nPos18 == 0  
						aTemp[nPos14,2] := nI
					ElseIF (nPos14 > 0 .and. nPos13 > 0) .or. (nPos14 == 0 .and. nPos13 > 0)
						IF aTemp[nPos13,2] > nI
						   Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
							Exit
						ElseIf nPos18 > 0
						 	If aTemp[nPos18,2] < nI
								Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
								lRet := .F.
								Exit
							EndIf 
						Else
							IF nPos14 > 0
								aTemp[nPos14,2] := nI
							Else
								AAdd(aTemp,{DT3->DT3_TIPFAI, ni})
							EndIF
						EndiF
					ElseIf (nPos14 > 0 .and. nPos18 > 0) .Or. (nPos14 == 0 .and. nPos18 > 0)
						If aTemp[nPos18,2] < nI
							Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
							Exit
						EndIf
					Endif
				ElseIf DT3->DT3_TIPFAI == "18"
				 	If Len(aTemp) == 0
						AAdd(aTemp,{DT3->DT3_TIPFAI, ni})
					ElseIf nPos18 > 0 .and. nPos13 == 0  .or. nPos18 > 0 .and. nPos14 == 0
						aTemp[nPos18,2] := nI
					ElseIf (nPos18 > 0 .and. nPos13 > 0 ) .or. (nPos18 == 0 .and. nPos13 > 0 )
						AAdd(aTemp,{DT3->DT3_TIPFAI, ni})
					ElseIf (nPos18 > 0 .and. nPos14 > 0 ) .or. (nPos18 == 0 .and. nPos14 > 0 )
						AAdd(aTemp,{DT3->DT3_TIPFAI, ni})
					EndIf
				ElseIf Len(aTemp) > 0 
					
					IF nPos13 > 0 
						IF aTemp[nPos13,2] < nI
						   Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
						EndiF
					EndIF
					
					IF nPos14 > 0 
						IF aTemp[nPos14,2] < nI
						   Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
						EndiF
					EndIF
				
					IF nPos18 > 0 
						IF aTemp[nPos18,2] < nI
						   Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
						EndiF
					EndIF
				EndIF
			EndIf
		
			If DVE->(ColumnPos("DVE_RATEIO")) > 0 .And. lRet 
				If GdFieldGet('DVE_RATEIO',ni) == StrZero(1,Len(DVE->DVE_RATEIO))  //Sim
					If GdFieldGet('DVE_COMOBR',ni) == StrZero(1,Len(DVE->DVE_COMOBR))  .And. GdFieldGet('DVE_DIZIMA',ni) <> StrZero(1,Len(DVE->DVE_DIZIMA))   //Componente Obrigatorio e Dizima igual a Nao 
						Help("", 1, "TMSA13010",,' ' + STR0028 + DT3->DT3_CODPAS  + ' / ' + DT3->DT3_DESCRI ,5,1 ) 	//Componentes 'Obrigatorio' que utilizam Rateio, devem ser configurados como 'Calcula Dizima' igual a SIM.
						lRet:= .F.
						Exit
					EndIf
					
				
				    If (DT3->DT3_TXADIC == '1' .Or.; 
				    	DT3->DT3_TIPFAI == StrZero(13, Len(DT3->DT3_TIPFAI)) .Or.;
					 	DT3->DT3_TIPFAI == StrZero(14, Len(DT3->DT3_TIPFAI)) .Or.;
					 	DT3->DT3_TIPFAI == StrZero(15, Len(DT3->DT3_TIPFAI)) .Or.;
						DT3->DT3_TIPFAI == StrZero(16, Len(DT3->DT3_TIPFAI)) .Or.;
					 	DT3->DT3_TIPFAI == StrZero(18, Len(DT3->DT3_TIPFAI)))
     					Help("", 1, "TMSA13012",,' ' + STR0028 + DT3->DT3_CODPAS  + ' / ' + DT3->DT3_DESCRI ,5,1 ) 	//O componente nao pode ser configurado como Rateio igual a Sim.   //13012 
						lRet:= .F.
						Exit
				    EndIf
				    
				Else
					If GdFieldGet('DVE_DIZIMA',ni) == StrZero(1,Len(DVE->DVE_DIZIMA))
						Help("", 1, "TMSA13011",,' ' + STR0028 + DT3->DT3_CODPAS  + ' / ' + DT3->DT3_DESCRI ,5,1 )	 	//O campo 'Calcula Dizima' deve ser configurado como 'SIM' somente para componentes que utilizam Rateio. 	
						lRet:= .F.
						Exit
					EndIf
				EndIf
			EndIf
		EndIF
	Next NI
	
EndIf

RestInter()
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA130Has³ Autor ³ Daniel Leme           ³ Data ³29.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se há movimentação com a configuração da tabela   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oView do objeto oView                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA130Has(cTabFre,cTipTab)
Local lExistDYA := AliasInDic('DYA')
Local lExistTab := .F.
Local aAreas := {	DT0->(GetArea()),;
					DTF->(GetArea()),;
					DUX->(GetArea())}

If lExistDYA
	aAdd(aAreas,DYA->(GetArea()))
EndIf
aAdd(aAreas,GetArea())

DT0->(dbSetOrder(1))              
DTF->(dbSetOrder(1))
DUX->(dbSetOrder(3))	    
If lExistDYA
	DYA->(dbSetOrder(1))
EndIf 

If DT0->( MsSeek( xFilial( "DT0" ) + cTabFre + cTipTab ) )   
	lExistTab := .T.
ElseIf DTF->( MsSeek( xFilial( "DTF" ) + cTabFre + cTipTab ) )
	lExistTab := .T.		
ElseIf DUX->( MsSeek( xFilial( "DUX" ) + cTabFre + cTipTab ) )
	lExistTab := .T.		
ElseIf lExistDYA .And. DYA->( MsSeek( xFilial( "DYA" ) + cTabFre + cTipTab ) )
	lExistTab := .T.		
EndIf				

aEval(aAreas,{|xArea| RestArea(xArea) })       

Return lExistTab

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA130Vld ³ Autor ³Patricia A. Salomao ³ Data ³ 20/02/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao dos campos                                        ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA130Vld()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA130Vld()
Local cCampo  := ReadVar()
Local lRet    := .T.          
Local nX      := 0

Local oModel
Local aSaveLines

If 'DTL_CATTAB' $ cCampo
   If M->DTL_CATTAB == StrZero(1,Len(DTL->DTL_CATTAB)) //-- Categoria da Tabela : Frete a Receber
		oModel 		  := FwModelActive()
		aSaveLines  := FWSaveRows()
		For nX := 1 To oModel:GetModel("MdGridIDVE"):Length()
			oModel:GetModel("MdGridIDVE"):SetLine(nX)
			oModel:SetValue("MdGridIDVE","DVE_BASIMP",PadR("1",Len(DVE->DVE_BASIMP)))  
		Next
		FWRestRows( aSaveLines )
	EndIf	
EndIf	
Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao     º  TMSA130COPº Autor º Rafael M. Quadrottiº Data º 18/12/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                 Copia Configuracao da Tabela de Frete                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º TMSA130COP()                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                         			         º±±
±±º         01 º cAlias - Alias do arquivo                                 º±±
±±º         02 º nReg   - Registro do Arquivo                              º±±
±±º         03 º nOpcx  - Opcao da MBrowse                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º .T.                                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º SigaTMS - Gestao de Transportes                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º Efetua a copia das Configuracoes das Tabelas  com base    º±±
±±º            º em Configuracoes ja existentes.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ºxx/xx/03ºxxxxxxº                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA130COP(cAlias,nReg,nOpcx) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objetos da janela            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oDlg   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objetos do Get               ³
//³Objetos da tabela de destino ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oTabOri
Local oTipOri
Local oTipDOri
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objetos da tabela de destino  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oTabDes
Local oTipDes 
Local oTipDDes
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis da tabela de origem³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTabOri   := Criavar("DTL_TABFRE",.F.)
Local cTipOri   := Criavar("DTL_TIPTAB",.F.)
Local cTipDOri  := Criavar("DTL_DESTIP",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis da tabela de destino³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTabDes   := Criavar("DTL_TABFRE",.F.)
Local cTipDes   := Criavar("DTL_TIPTAB",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis da vigencia         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local dDatDe   := Criavar("DTL_DATDE",.F.)
Local dDatAte  := Criavar("DTL_DATATE",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BackUp da var Inclui          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lOldInc  := Inclui

Private cTipDDes  := Criavar("DTL_DESTIP",.F.)

// Para a funcao ExistChav
Inclui := .T.

DbSelectArea("DTL")
DbSetOrder(1)
DbGoTo(nReg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega dados da tabela de Origem³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTabOri  := DTL->DTL_TABFRE
cTipOri  := DTL->DTL_TIPTAB
cTipDOri := Tabela("M5",DTL->DTL_TIPTAB,.F.)

DEFINE MSDIALOG oDlg FROM 0,0 TO 150,355 TITLE STR0020 PIXEL //"Copia Configuracao da Tabela de Frete"
	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Campos utilizados na Dialog                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 11,005 SAY STR0021 SIZE 41,8 OF oDlg PIXEL //"Da Tabela "
	@ 10,047 MSGet oTabOri  Var cTabOri  Picture "@!" SIZE 21,8 OF oDlg PIXEL WHEN .F.
	@ 11,078 SAY STR0022 SIZE 16,8 OF oDlg PIXEL //"Tipo: "
	@ 10,094 MSGet oTipOri  Var cTipOri  Picture "@!"    SIZE   5,8 OF oDlg PIXEL WHEN .F.
	@ 10,115 MSGet oTipDOri Var cTipDOri Picture "@!"    SIZE  59,8 OF oDlg PIXEL WHEN .F.

	@ 24,005 SAY STR0023 SIZE 41,8 OF oDlg PIXEL //"Para a Tabela "
	@ 23,047 MSGet oTabDes  Var cTabDes  Picture "@!" VALID !Empty(cTabDes) .And. ExistChav("DTL",cTabDes+cTipDes,1) F3 "DTL"  SIZE 21,8 OF oDlg PIXEL 
	@ 24,078 SAY STR0022 SIZE 16,8 OF oDlg PIXEL //"Tipo: "
	@ 23,094 MSGet oTipDes  Var cTipDes  Picture "@!"  F3 "M5" VALID !Empty(cTipDes) .And. TMA130TabOk(cTabDes, cTipDes)  SIZE 5,8 OF oDlg PIXEL
	@ 23,115 MSGet oTipDDes Var cTipDDes Picture "@!"   SIZE  59,8 OF oDlg PIXEL WHEN .F.

	@ 37,005 SAY STR0024 SIZE 41,8 OF oDlg PIXEL //"Ini.Vigencia "
	@ 36,047 MSGet oDatDe Var dDatDe  Picture PesqPict('DTL','DTL_DATDE') VALID(!Empty(dDatDe)) SIZE 41,8 OF oDlg PIXEL 

	@ 50,005 SAY STR0025 SIZE 41,8 OF oDlg PIXEL //"Fim Vigencia "
	@ 49,047 MSGet oDatAte Var dDatAte  Picture PesqPict('DTL','DTL_DATATE')  SIZE 41,8 OF oDlg PIXEL 

	DEFINE SBUTTON FROM 60,115  TYPE 1 ACTION (IIf(Tmsa130COK(cTabOri,cTipOri,cTabDes,cTipDes,dDatDe,dDatAte,oTabOri,oTipOri,oTabDes,oTipDes,oDatDe,oDatAte),oDlg:End(),"")) ENABLE OF oDlg
	DEFINE SBUTTON FROM 60,145  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
 
ACTIVATE MSDIALOG oDlg CENTERED
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura variavel.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Inclui := lOldInc

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao      ºTMSA130COK  ºAutor  ºRafael M. Quadrotti º Data º  02/19/03º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            Copia da Configuracao da Tabela de Frete                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º TMSA130COK()                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                         			      	º±±
±±º         01 º cTabOri - Codigo da Tabela de Origem 					      º±±
±±º         02 º cTipOri - Codigo do Tipo (Tabela de Origem)               º±±
±±º         03 º cTabDes - Codigo da Tabela de Destino 					      º±±
±±º         04 º cTipDes - Codigo do Tipo de Destino  					      º±±
±±º         05 º dDatDe  - Data de Inicio da Vigencia da nova tabela       º±±
±±º         06 º dDatAte - Data do Fim da Vigencia da Nova tabela		      º±±
±±º         07 º oTabOri - Objeto do Get da tabela de Origem     		      º±±
±±º         08 º oTipOri - Objeto do Get do tipo de Origem       		      º±±
±±º         09 º oTabDes - Objeto do Get da tabela de Destino    		      º±±
±±º         10 º oTipDes - Objeto do Get do tipo de Destino      		      º±±
±±º         11 º oDatDe  - Objeto do Get da Data de Vigencia     		      º±±
±±º         12 º oDatAte - Objeto do Get da Data do Fim da Vigencia		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º .T.                                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º SigaTMS - Gestao de Transportes                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario ºProcessamento da copia das configuracoes com base nas Confiº±±
±±º            ºguracoes ja existentes.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ºxx/xx/03ºxxxxxxº                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tmsa130COK(cTabOri,cTipOri,cTabDes,cTipDes,dDatDe,dDatAte,oTabOri,oTipOri,oTabDes,oTipDes,oDatDe,oDatAte)

Local lRet 	 := .T.
//--Variavel para controle de posicao dos arrays aCopyDTL e aCopyDVE
Local nLinha := 0 
Local nCount := 0 // Usado no For da gravacao
Local nW     := 0 // Usado no For da gravacao
//-- Arrays com dados para copia.
Local aCopyDTL := {}  
Local aCopyDVE := {}  
//--Variavel de auxilio para aCopyDTL/aCopyDVE
Local cCampo   := ""
Local aStruct

Do Case
	Case Empty(cTabDes)
		Help("", 1, "TMSA13005")// A tabela de Destino não foi informada. Por favor informe uma tabela valida.
		oTabDes:SetFocus()
		lRet := .F.
	
	Case Empty(cTipDes)
		Help("", 1, "TMSA13006")// O Tipo para Configuracao da Tabela de Frete nao foi informado. Por favor informe um tipo valido.
		oTipDes:SetFocus()
		lRet := .F.

	Case Empty(dDatDe)
		Help("", 1, "TMSA13007")// A data de vigencia não foi informada. Por favor informe uma data válida.
		oDatDe:SetFocus()
		lRet := .F.
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Flag para retorno único na funcao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena dados do Dtl (Configuracao de tabela) para posterior gravacao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("DTL")
	DbSetOrder(1)
	If MsSeek(xFilial("DTL")+cTabOri+cTipOri)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona linha no array .                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLinha++
		Aadd(aCopyDTL,{})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seleciona DTL³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aStruct := DTL->(DbStruct())
	
		For nCount := 1 To Len(aStruct)
			cCampo := AllTrim(aStruct[nCount][1])
			Do Case
				Case (cCampo == "DTL_FILIAL")
					Aadd(aCopyDTL[nLinha],{"DTL_FILIAL",xFilial("DTL")})
				Case (cCampo == "DTL_TABFRE")
					Aadd(aCopyDTL[nLinha],{"DTL_TABFRE",cTabDes})
				Case (cCampo == "DTL_TIPTAB")
					Aadd(aCopyDTL[nLinha],{"DTL_TIPTAB",cTipDes})
				Case (cCampo == "DTL_DATDE")
					Aadd(aCopyDTL[nLinha],{"DTL_DATDE",dDatDe})
				Case (cCampo == "DTL_DATATE")
					Aadd(aCopyDTL[nLinha],{"DTL_DATATE",dDatAte})
				OtherWise
					Aadd(aCopyDTL[nLinha],{cCampo,DTL->&(cCampo)})
			EndCase
		Next nCount
	
		nLinha:=0
		DbSelectArea("DVE")
		DbSetOrder(1)
		If MsSeek(xFilial("DVE")+cTabOri+cTipOri)
			While ((!EOF()) .And. xFilial("DVE")==DVE_FILIAL .And. DVE_TABFRE==cTabOri .And. DVE_TIPTAB==cTipOri  )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Adiciona linha no array .                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nLinha++
				Aadd(aCopyDVE,{})
				
				aStruct := DVE->(DbStruct())
				For nCount := 1 To Len(aStruct)
					cCampo := ALLTRIM(aStruct[nCount][1])
					Do Case
						Case (cCampo == "DVE_FILIAL")
							Aadd(aCopyDVE[nLinha],{"DVE_FILIAL",xFilial("DVE")})
						Case (cCampo == "DVE_TABFRE")
							Aadd(aCopyDVE[nLinha],{"DVE_TABFRE",cTabDes})
						Case (cCampo == "DVE_TIPTAB")
							Aadd(aCopyDVE[nLinha],{"DVE_TIPTAB",cTipDes})
						OtherWise
							Aadd(aCopyDVE[nLinha],{cCampo,DVE->&(cCampo)})
					EndCase
				Next nCount
				DbSelectArea("DVE")
				DbSkip()
			End
		EndIf
	EndIf

	BEGIN TRANSACTION
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera novo DTL³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("DTL")
		DbSetOrder(1)
		
		If (Len(aCopyDTL)>0)
			For nCount:=1 To Len(aCopyDTL)
				RecLock("DTL",.T.)
				For nW:=1 To Len(aCopyDTL[nCount])
					Replace DTL->&(aCopyDtl[nCount][nW][1])  With aCopyDtl[nCount][nW][2] // Nova tabela
				Next nW
				MsUnlock()
				Dbcommit()
			Next nCount
		
		
	        If (Len(aCopyDVE)>0)
				DbSelectArea("DVE")
				DbSetOrder(1)
			
				For nCount:=1 To Len(aCopyDVE)
					RecLock("DVE",.T.)
					For nW:=1 To Len(aCopyDVE[nCount])
						Replace DVE->&(aCopyDVE[nCount][nW][1])  With aCopyDVE[nCount][nW][2] // Nova tabela
					Next nW
					MsUnlock()
					Dbcommit()
				Next nCount
			EndIf    
		EndIf
	
	END TRANSACTION

EndIf	

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA130TabOk³ Autor ³Patricia A. Salomao ³ Data ³ 15/03/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da Tabela/Tipo Tab. informados na Copia de Configu³±± 
±±³          ³racao da Tabela de Frete.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMA130TabOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Tabela de Frete                                     ³±± 
±±³          ³ExpC2 - Tipo da Tabela de Frete                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMA130TabOk(cTabDes, cTipDes)

If Empty(Tabela("M5",cTipDes,.F.))
	HELP("",1,"REGNOIS") //"Nao existe registro relacionado a este codigo"
	Return( .F. )
EndIf                                  

DTL->(dbSetOrder(1))
If DTL->(MsSeek(xFilial("DTL")+cTabDes+cTipDes))
	HELP("",1,"JAGRAVADO") //"Ja existe registro com esta informacao"
	Return( .F. )
EndIf

cTipDDes :=Tabela("M5",cTipDes,.F.)	

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA130Whe ³ Autor ³Patricia A. Salomao ³ Data ³ 21/05/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³X3_WHEN do campo DTL_CATTAB. Nao permite a ALTERACAO do con-³±± 
±±³          ³teudo deste campo, mesmo se o parametro MV_CONTHIS (Controle³±± 
±±³          ³de Historico de Tabela) estiver desabilitado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA130Whe()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA130Whe()
Local lRet   := .T.

If !Inclui
	lRet := .F.
EndIf	

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA130Whn ³ Autor ³Patricia A. Salomao ³ Data ³ 20/02/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³X3_WHEN do campo DVE_BASIMP. Nao permite a ALTERACAO do con-³±± 
±±³          ³teudo deste campo, se a categoria da tabela for diferente de³±± 
±±³          ³'Frete a Pagar'                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA130Whn()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA130Whn(cCampo)

Local lRet   := .T.          

Default cCampo:= ReadVar()
If cCampo == "M->DVE_BASIMP"
	If M->DTL_CATTAB <> StrZero(2,Len(DTL->DTL_CATTAB)) //-- Se a Categoria da Tabela for diferente de 'Frete a Pagar'
		lRet := .F.
	EndIf	

ElseIf cCampo == "M->DVE_RATEIO"  
	DT3->(DBSETORDER(1))
	DT3->(DbSeek(XFILIAL("DT3")+ GdFieldGet('DVE_CODPAS',n)))

 	If GdFieldGet('DVE_RATEIO',n) <> '1'   
	    // Se for um Componente Adicionar, nao podera ser configurado como RATEIO=SIM //
	    IF DT3->DT3_TXADIC == "1" .And. GdFieldGet('DVE_RATEIO',n) <> '1'
	       lRet := .F.
	    EndIF
	     
	    // Se for Calcula Sobre 13 / 14 / 15 / 18 nao podera ser configurado como RATEIO=SIM //
	    If (lRet) .And.(DT3->DT3_TIPFAI == StrZero(13, Len(DT3->DT3_TIPFAI)) .Or.;
					 DT3->DT3_TIPFAI == StrZero(14, Len(DT3->DT3_TIPFAI)) .Or.;
					 DT3->DT3_TIPFAI == StrZero(15, Len(DT3->DT3_TIPFAI)) .Or.;
					 DT3->DT3_TIPFAI == StrZero(18, Len(DT3->DT3_TIPFAI)))
	       lRet := .F.
		EndIf
	EndIf	
EndIf

Return lRet 
 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
Private aRotina := {}
     
ADD OPTION aRotina TITLE STR0002 	ACTION "AxPesqui"         OPERATION 1 ACCESS 0   //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA130" OPERATION 2 ACCESS 0   //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSA130" OPERATION 3 ACCESS 0   //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TMSA130" OPERATION 4 ACCESS 0   //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSA130" OPERATION 5 ACCESS 0   //"Excluir"
ADD OPTION aRotina TITLE STR0019 	ACTION "TMSA130Cop" OPERATION 6 ACCESS 0   //"Copiar"


If ExistBlock("TMA130MNU")
	ExecBlock("TMA130MNU",.F.,.F.)
EndIf

Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA130Gat ³ Autor ³Katia              ³ Data ³ 02/07/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gatilho para o campo DVE_DIZIMA									 ±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA130Gat()
Local cRet:= '2' //Dizima Não

//--- Componente Obrigatorio e Rateio igual a SIM
If FwFldGet('DVE_RATEIO') == '1'  
	If FwFldGet('DVE_COMOBR') == '1' 
		cRet:= '1'   //Dizima SIM
	EndIf	     
EndIf	

Return cRet


/*/-----------------------------------------------------------
{Protheus.doc} PreVldMdl
Pré-valida a Linha do grid

Uso: TMSA130

@sample
//PreVldMdl(oModelGrid)

@author Katia
@since 23/01/2017
@version 1.0
-----------------------------------------------------------/*/
Static Function PreVldMdl(oModelGrid,nLine,cAction)
Local lRet 		:= .T.					// Recebe o Retorno
Local aAreaDVE	:= DVE->(GetArea())	// Recebe a Area da tebela DDJ

oModelGrid:GoLine(nLine)

If cAction ==  "CANSETVALUE"
	If oModelGrid:cId == "MdGridIDVE" .AND.  Empty(oModelGrid:GetValue("DVE_TABFRE",nLine))
		oModelGrid:LoadValue("DVE_TABFRE", M->DTL_TABFRE)
		oModelGrid:LoadValue("DVE_TIPTAB", M->DTL_TIPTAB)
	EndIf 
EndIf

RestArea(aAreaDVE)	
Return lRet
