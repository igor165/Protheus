#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#Include "TMSAD20.CH"

Static lLibTemp := .F.
Static lDetail  := .F.

//-----------------------------------------------------------------------------------------------------------
/* Documentos Exigidos X Fornecedores 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Function TMSAD20()

Local oMBrowse 		:= Nil

Private aRotina   := MenuDef()

oMBrowse:= FWMBrowse():New()	
oMBrowse:SetAlias( "DD1" )
oMBrowse:SetDescription( STR0001 )
oMBrowse:Activate()

Return NIL

//===========================================================================================================
/* ModelDef
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	oModel */          
//===========================================================================================================
Static Function ModelDef()

Local oModel    := NIL       		  
Local oStruFDD1 := NIL
Local oStruGDD3 := NIL
Local aRelacDD3	:= {}
Local bPosValid := { || PosVldMdl(oModel) 	}
Local bLinePost	:= { || DD3LinePst(oModel)	}
Local bCommit	:= { || CommitMdl(oModel) 	}
Local aAux      := {}

oStruFDD1	:= FWFormStruct( 1, 'DD1' )
oStruGDD3	:= FWFormStruct( 1, 'DD3' )

oStruGDD3:SetProperty("DD3_CODFOR",MODEL_FIELD_OBRIGAT,.F.)  
oStruGDD3:SetProperty("DD3_LOJFOR",MODEL_FIELD_OBRIGAT,.F.)

oModel := MPFormModel():New ( "TMSAD20", /*bPreValid*/, bPosValid, bCommit, /*bCancel*/ )

oModel:SetDescription(STR0001)

oModel:AddFields( 'MdFieldDD1',	NIL, oStruFDD1, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)				
oModel:GetModel ( 'MdFieldDD1' )
oModel:SetPrimaryKey( { "DD1_FILIAL","DD1_CODFOR", "DD1_LOFOR" } ) 

oModel:AddGrid( 'MdGridDD3', 'MdFieldDD1', oStruGDD3, /*bLinePre*/, bLinePost, /*bPre*/ , /*bPost*/, /*bLoad*/)

aAdd(aRelacDD3, { "DD3_FILIAL", "xFilial('DD3')" } )
aAdd(aRelacDD3, { "DD3_CODFOR", "DD1_CODFOR" } )
aAdd(aRelacDD3, { "DD3_LOJFOR", "DD1_LOJFOR" } )

oModel:SetRelation( 'MdGridDD3', aRelacDD3 , DD3->( IndexKey( 1 ) )  )

oModel:GetModel( 'MdGridDD3' ):SetUniqueLine( { 'DD3_CODDOC' } )

If lLibTemp 
	oModel:GetModel('MdFieldDD1'):SetOnlyView( .T. )  
	oModel:GetModel( 'MdGridDD3' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MdGridDD3' ):SetNoInsertLine( .T. )
EndIf

oModel:SetVldActivate( { |oModel| VldActMdl( oModel ) } ) // Realiza a pre validação do Model

Return(oModel)

//===========================================================================================================
/* ViewDef
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	oView */          
//===========================================================================================================
Static Function ViewDef()

Local oView		:= NIL
Local oModel    := NIL       		  
Local oStruFDD1 := NIL
Local oStruGDD3 := NIL

oModel     := FwLoadModel( "TMSAD20" )

oStruFDD1	:= FWFormStruct( 2, 'DD1' )
oStruGDD3	:= FWFormStruct( 2, 'DD3' )

oStruGDD3:RemoveField('DD3_CODFOR')
oStruGDD3:RemoveField('DD3_LOJFOR')
oStruGDD3:RemoveField('DD3_OK')

If !lLibTemp .And. !lDetail
	oStruGDD3:RemoveField('DD3_TOLERA')
ElseIf  lLibTemp
	oStruGDD3:SetProperty( '*' 			, MVC_VIEW_CANCHANGE,.F.) //-- Bloqueia Todos Os Campos Da Grid
	oStruGDD3:SetProperty( 'DD3_TOLERA'	, MVC_VIEW_CANCHANGE,.T.) //-- Habilita Somente o Campo Tolera
EndIf

oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VwFieldDD1', oStruFDD1 , 'MdFieldDD1'	)
oView:AddGrid( 	'VwGridDD3'	, oStruGDD3 , 'MdGridDD3'	)

oView:CreateHorizontalBox( 'FIELD'  , 40 )
oView:CreateHorizontalBox( 'GRID'   , 60 )

oView:SetOwnerView( 'VwFieldDD1' , 'FIELD')
oView:SetOwnerView( 'VwGridDD3'  , 'GRID' )

oView:AddIncrementField('VwGridDD3','DD3_ITEM')

oView:SetViewProperty("VwGridDD3", "ENABLENEWGRID")
oView:SetViewProperty("VwGridDD3", "GRIDFILTER", {.T.}) 
oView:SetViewProperty("VwGridDD3", "GRIDSEEK", {.T.})

If lDetail
	oView:AddUserButton( STR0007 , 'DESTINOS', {|| TMSAD20Det()} )	
EndIf

Return(oView)

//===========================================================================================================
/* DD3LinePst
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	 lRet*/          
//===========================================================================================================
Static Function DD3LinePst(oModel)
Local oModelGrid	:= oModel:GetModel ("MdGridDD3")
Local lRet      	:= .T.

If Empty(FwFldGet('DD3_TOLERA'))
	If FwFldGet('DD3_PRXAPR')  < dDataBase
		Help('',1,'TMSAD2004') //-- "Data para apresentacao do documento invalida!"
		lRet := .F.
	EndIf
EndIf

Return( lRet )

//===========================================================================================================
/* PosVldMdl
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	 */          
//===========================================================================================================
Static Function PosVldMdl(oModel)
Local lRet 		 	:= .T. 		// Recebe o Retorno
Local nOperation	:= 0		// Recebe a Operacao realizada
Local cQuery		:= ""
Local cAliasQry		:= ""
Local nCount		:= 0
Local oModelGrid	:= oModel:GetModel ("MdGridDD3")

nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_DELETE

	If lRet
		cAliasQry := GetNextAlias()
		cQuery := "SELECT DUC.DUC_CODDOC, DUC.DUC_CODFOR, DUC.DUC_LOJFOR"
		cQuery += " FROM " + RetSQLName('DUC') + " DUC"
		cQuery += " WHERE DUC.DUC_FILIAL = '" + xFilial('DUC') + "' AND"
		cQuery += " DUC.DUC_CODFOR = '" + DD1->DD1_CODFOR + "' AND"
		cQuery += " DUC.DUC_LOJFOR = '" + DD1->DD1_LOJFOR + "' AND"
		cQuery += " (
		
		For nCount := 1 To oModelGrid:Length()
			
			oModelGrid:GoLine( nCount )

			cQuery += " DUC.DUC_CODDOC = '" + oModelGrid:GetValue('DD3_CODDOC') + "'" 

			If nCount < oModelGrid:Length()
				cQuery += " OR "
			EndIf

		Next nCount

		cQuery += " ) AND"
		cQuery += " DUC.D_E_L_E_T_ = ''"
		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		lContinua := (cAliasQry)->(EoF()) 
		(cAliasQry)->(DbCloseArea())

		If !lContinua
			Help('',1,'TMSAD2005') //-- 'Existem bloqueios de viagem referente a este Fornecedor. Exclusao nao permitida.'
			lRet := .F.
		EndIf
	EndIf
	
	If lRet		
		cAliasQry := GetNextAlias()
		cQueryB := "SELECT DD5_CODDOC, DD5_CODFOR "
		cQueryB += "FROM " + RetSQLName('DD5') + " DD5 "
		cQueryB += "JOIN " + RetSQLName('DD3') + " DD3 ON DD5_CODDOC = DD3_CODDOC "
		cQueryB += "AND DD3.DD3_FILIAL = '" + xFilial('DD3') + "' "
		cQueryB += "AND DD3.D_E_L_E_T_ = '' "
		cQueryB += "WHERE DD5.DD5_FILIAL = '" + xFilial('DD5') + "' "
		cQueryB += "AND DD5_CODFOR = '" + DD1->DD1_CODFOR + "' "
		cQueryB += "AND DD5_LOJFOR = '" + DD1->DD1_LOJFOR + "' "
		cQueryB += "AND DD5.D_E_L_E_T_ = '' "
		cQueryB += "GROUP BY DD5_CODFOR,DD5_CODDOC "
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryB), cAliasQry, .F., .T.)
		
		If (cAliasQry)->(!EoF())
			Help('',1,'TMSAD3008')//Exclusão não permitida. Ja foi realizada a manutenção deste documento")
			lRet := .F.
		Endif
		(cAliasQry)->(DbCloseArea())	
	EndIf
	
EndIf

Return lRet

//===========================================================================================================
/* VldActMdl
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	 */          
//===========================================================================================================
Static Function VldActMdl(oModel)
Local lRet 		 := .T. 		// Recebe o Retorno
Local nOperation := 0			// Recebe a Operacao realizada

nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE 
	If !SoftLock("DD1")
		lRet := .F.
	EndIf	
EndIf

Return lRet

//===========================================================================================================
/* VldActMdl
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	 */          
//===========================================================================================================
Static Function CommitMdl(oModel)

Local lRet 			:= .T.
Local cQuery		:= ''
Local cAliasQry		:= ''
Local aAvaliaBlq	:= {}
Local aArea			:= GetArea()
Local nCount		:= 1
Local oMdlGrd		:= oModel:GetModel("MdGridDD3")

Begin Transaction

	For nCount := 1 To oMdlGrd:Length()
		
		oMdlGrd:GoLine( nCount )

		If lLibTemp .And. !Empty(FwFldGet('DD3_TOLERA'))
			cAliasQry := GetNextAlias()
			//-- Verifica se Existem Bloqueios relacionado ao Documento
			//-- que esta sendo lancada a data de Tolerancia. Caso afirmativo, elimina o bloqueio
			cQuery := "SELECT DUC.DUC_CODBLQ,DUC.DUC_CODDOC,DUC.DUC_CODFOR,DUC.DUC_LOJFOR, DUC.R_E_C_N_O_ DUCRecNo "
			cQuery += "FROM " + RetSQLName('DUC') + " DUC, " + RetSQLName('DTQ') + " DTQ "
			cQuery += "WHERE DUC.DUC_FILIAL = '" + xFilial('DUC') + "' AND "
			cQuery += "DUC.DUC_CODFOR = '" + DD1->DD1_CODFOR + "' AND "
			cQuery += "DUC.DUC_LOJFOR = '" + DD1->DD1_LOJFOR + "' AND "
			cQuery += "DUC.DUC_CODDOC = '" + FwFldGet('DD3_CODDOC') + "' AND "
			cQuery += "DUC.DUC_STATUS = '1' AND "
			cQuery += "DUC.DUC_FILORI = DTQ.DTQ_FILORI AND "
			cQuery += "DUC.DUC_VIAGEM = DTQ.DTQ_VIAGEM AND "
			cQuery += "DTQ.DTQ_DATGER <= '" + DtoS(FwFldGet('DD3_TOLERA')) + "' AND "
			cQuery += "DUC.D_E_L_E_T_ = '' "

			cQuery := ChangeQuery(cQuery)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
			While !(cAliasQry)->(EoF())
				DUC->(DbGoTo( (cAliasQry)->DUCRecNo ))
				//-- Monta Array para reavaliacao dos status
				AAdd( aAvaliaBlq, {	DUC->DUC_CODBLQ, DUC->DUC_CODFOR, DUC->DUC_LOJFOR,;
									DUC->DUC_CODMOT, DUC->DUC_DTAAPR, DUC->DUC_DTAAFA,;
									DUC->DUC_DTARET, .F. } )

				//-- Exclui o registro de Bloqueio									
				RecLock('DUC', .F.)
				DbDelete()
				MsUnLock()
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
			
			//Gravar o Historico na Liberacao Temporaria
			RecLock('DD5',.T.)
			DD5->DD5_FILIAL := xFilial('DD5')
			DD5->DD5_CODFOR := DD1->DD1_CODFOR
			DD5->DD5_LOJFOR := DD1->DD1_LOJFOR
			DD5->DD5_CODDOC := FwFldGet('DD3_CODDOC')
			DD5->DD5_DTAAPR := dDataBase
			DD5->DD5_RESPON := cUserName
			DD5->DD5_TIPO := "2" //--Liberacao por Tolerancia
			DD5->(MsUnLock())
		EndIf
	NEXT Count
				
	TMSAvlBlqDoc( aAvaliaBlq )

	lRet:= FWFormCommit( oModel )
	
End Transaction	

RestArea(aArea)

Return( lRet )

//===========================================================================================================
/* MenuDef
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	aRotina - Array com as opçoes de Menu */          
//===========================================================================================================
Static Function MenuDef()

Local aArea		:= GetArea() 

Private	aRotina	:= {}

aAdd( aRotina, { STR0002, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0003, "VIEWDEF.TMSAD20"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0004, "VIEWDEF.TMSAD20"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0005, "VIEWDEF.TMSAD20"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0006, "VIEWDEF.TMSAD20"  , 0, 5, 3, Nil } ) // Excluir	

If ExistBlock("TMAD20MNU")
	ExecBlock("TMAD20MNU",.F.,.F.)
EndIf

RestArea( aArea )							 

Return(aRotina)

//===========================================================================================================
/* TMSAD20STC
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020 */
//Funçao executada pela rotina TMSAD40 para diferenciar se é Lib.Temporaria ou Consulta
//===========================================================================================================
Function TMSAD20STC(lLbTmp, lDtl)

Default lLbTmp	:= .F.
Default lDtl	:= .F.

lLibTemp := lLbTmp 
lDetail  := lDtl  

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAD20Det ³ Autor ³ Vitor Raspa          ³ Data ³ 30.Ago.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe detalhes do Documento selecionado na GetDados        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAD20Det()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAD20Det()
Local aArea     := GetArea()
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local oDlg      := NIL
Local oLstBox   := NIL
Local aDados    := {}
Local cCodDoc   := CriaVar('DD0_CODDOC')
Local cDesDoc   := CriaVar('DD0_DESDOC')
Local cDesc     := ""
Local nSeek     := 0
Local aSx3Box   := RetSx3Box( Posicione('SX3', 2, 'DD5_TIPO', 'X3CBox()' ),,, 1 )

cQuery := "SELECT DD5.DD5_CODFOR, DD5.DD5_LOJFOR, DD5.DD5_CODDOC, DD5.DD5_DTAAPR, DD5.DD5_RESPON, DD5.DD5_TIPO "
cQuery += "FROM " + RetSQLName('DD5') + " DD5 "
cQuery += "WHERE DD5.DD5_FILIAL = '" + xFilial('DD5') + "' AND "
cQuery += "DD5.DD5_CODDOC = '" + FwFldGet('DD3_CODDOC') + "' AND "
cQuery += "DD5.DD5_CODFOR = '" + DD1->DD1_CODFOR + "' AND "
cQuery += "DD5.DD5_LOJFOR = '" + DD1->DD1_LOJFOR + "' AND "
cQuery += "DD5.D_E_L_E_T_ = '' "
cQuery += "ORDER BY DD5.DD5_FILIAL, DD5.DD5_DTAAPR"
cQuery := ChangeQuery(cQuery)	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
TcSetField(cAliasQry,"DD5_DTAAPR","D",8,0)
If !(cAliasQry)->(EoF())
	While !(cAliasQry)->(EoF())
		If	( nSeek := Ascan( aSx3Box, { |x| x[ 2 ] == (cAliasQry)->DD5_TIPO } ) ) > 0
			cDesc :=  aSx3Box[ nSeek, 3 ]
		EndIf
		AAdd( aDados, {DD5->DD5_DTAAPR, (cAliasQry)->DD5_RESPON, cDesc } )
		(cAliasQry)->(DbSkip())
	EndDo

	cCodDoc := AllTrim(FwFldGet('DD3_CODDOC')) 
	cDesDoc := FwFldGet('DD3_DESDOC') 

	DEFINE MSDIALOG oDlg FROM 94 ,104 TO 442,655 TITLE STR0008 Of oMainWnd PIXEL //'Mais Detalhes...'
	@ 020,010 SAY RetTitle('DD1_CODFOR') OF oDlg PIXEL
	@ 028,010 MSGET M->DD1_CODFOR When .F. OF oDlg PIXEL

	@ 020,50 SAY RetTitle('DD1_LOJFOR') OF oDlg PIXEL
	@ 028,50 MSGET M->DD1_LOJFOR When .F. OF oDlg PIXEL

	@ 020,070 SAY RetTitle('DD1_NOMFOR') OF oDlg PIXEL
	@ 028,070 MSGET M->DD1_NOMFOR When .F. SIZE 150,010 OF oDlg PIXEL

	@ 045,010 SAY RetTitle('DD3_CODDOC') OF oDlg PIXEL
	@ 053,010 MSGET cCodDoc When .F. OF oDlg PIXEL
	
	@ 045,050 SAY RetTitle('DD3_DESDOC') OF oDlg PIXEL
	@ 053,050 MSGET cDesDoc When .F. OF oDlg PIXEL
	
										 	
	@ 070,002 LISTBOX oLstBox FIELDS HEADER	RetTitle('DD5_DTAAPR')+"/"+RetTitle('DD3_TOLERA'),;
										 	RetTitle('DD5_RESPON'),RetTitle('DD5_TIPO');
										 	OF oDlg SIZE 272,100 PIXEL
										 	
	oLstBox:SetArray(aDados)
	oLstBox:bLine := {|| {	aDados[ oLstBox:nAT, 1 ],;
							aDados[ oLstBox:nAT, 2 ], aDados[ oLstBox:nAT, 3 ]} }
							

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,	{|| oDlg:End() } ,;
														{|| oDlg:End()}) CENTERED
	(cAliasQry)->(DbCloseArea())
Else
	Help('',1,'TMSAD2002') //-- 'Nao existe historio de Apresentacao para este Documento/Fornecedor'
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAD20Vld ³ Autor ³ Vitor Raspa          ³ Data ³ 28.Ago.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Campos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAD20Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAD20Vld()
Local lRet		:= .T.
Local cCampo	:= ReadVar()
Local nFator    := 0
Local aAreaDD0  := DD0->(GetArea())

If cCampo == 'M->DD1_DTCALC' //-- Data para Calculo
	If !Empty(M->DD1_DIATRB)
		M->DD1_DTAAFA := M->DD1_DTCALC + M->DD1_DIATRB
	EndIf
	If !Empty(M->DD1_DTAAFA)
		M->DD1_DTARET := M->DD1_DTAAFA + M->DD1_DIAAFA
	EndIf
	
ElseIf cCampo == 'M->DD1_DIATRB' //-- Dias Trabalhados    
    M->DD1_DTAAFA := M->DD1_DTCALC + M->DD1_DIATRB
	If !Empty(M->DD1_DTAAFA)
		M->DD1_DTARET := M->DD1_DTAAFA + M->DD1_DIAAFA
	EndIf

ElseIf cCampo == 'M->DD1_DIAAFA' //-- Dias Afastado
	If !Empty(M->DD1_DTAAFA)
		M->DD1_DTARET := M->DD1_DTAAFA + M->DD1_DIAAFA
	EndIf

ElseIf cCampo == 'M->DD3_CODDOC'
	DD0->(DbSetOrder(1))
	If DD0->(MsSeek(xFilial('DD0') + M->DD3_CODDOC))
		If 	DD0->DD0_PESSOA == M->DD1_PESSOA .Or. DD0->DD0_PESSOA == 'N' .And.;
			( DD0->DD0_OBRIGA == '1' .Or. DD0->DD0_OBRIGA == '3' )
			lRet := .T.
		Else
			Help('',1,'TMSAD1001') //-- Documento Invalido para esta amarracao
			lRet := .F.
		EndIf

		If lRet
			If DD0->DD0_TIPPER == '1' //-- Diario
				nFator := 1
			ElseIf DD0->DD0_TIPPER == '2' //-- Mensal
				nFator := 30
			ElseIf DD0->DD0_TIPPER == '3' //-- Diario
				nFator := 365
			EndIf
		EndIf
	EndIf

ElseIf cCampo == 'M->DD3_PERAPR' 
	If !Empty(M->DD3_PERAPR) .And. !Empty(FwFldGet('DD3_TIPPER'))
		If FwFldGet('DD3_TIPPER') == '1' //-- Diario
			nFator := 1
		ElseIf FwFldGet('DD3_TIPPER') == '2' //-- Mensal
			nFator := 30
		ElseIf FwFldGet('DD3_TIPPER') == '3' //-- Diario
			nFator := 365
		EndIf
	EndIf

ElseIf cCampo == 'M->DD3_TIPPER' 
	If !Empty(FwFldGet('DD3_PERAPR')) .And. !Empty(M->DD3_TIPPER)
		If M->DD3_TIPPER == '1' //-- Diario
			nFator := 1
		ElseIf M->DD3_TIPPER == '2' //-- Mensal
			nFator := 30
		ElseIf M->DD3_TIPPER == '3' //-- Diario
			nFator := 365
		EndIf
	EndIf

ElseIf cCampo == 'M->DD3_TOLERA'
	If !Empty(M->DD3_TOLERA)
		If FwFldGet('DD3_PRXAPR') > M->DD3_TOLERA
			Help('',1,'TMSAD2003') //-- 'Data invalida!
			lRet := .F.
		ElseIf M->DD3_TOLERA <= FwFldGet('DD3_PRXAPR')
			Help('',1,'TMSAD2007') //--Tolerancia tem que ser maior que a data da proxima apresentacao
			lRet := .F.
		EndIf
	Else
		DD3->(DbSetOrder(2))
		If DD3->(MsSeek(xFilial("DD3")+M->DD1_CODFOR+M->DD1_LOJFOR+FwFldGet('DD3_CODDOC')))
			If !Empty(DD3->DD3_TOLERA)
				Help('',1,'TMSAD2006') //--Ja existe tolerancia registrada para este documento
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaDD0)
Return( lRet )

//===========================================================================================================
/* TMSAD20GAT
@author  	Katia
@version 	P12 R12.1.30
@since 		21/05/2020 */
//Funçao executada por gatilho de campos da Grid
//===========================================================================================================
Function TMSAD20GAT()
Local dDatRet	:= CtoD('')
Local aArea		:= GetArea()
Local cCampo    := ReadVar() 

If "DD3_CODDOC" $ cCampo  
	DD0->(DbSetOrder(1))
	If DD0->(MsSeek(xFilial('DD0') + M->DD3_CODDOC))
		If DD0->DD0_TIPPER == '1' //-- Diario
			nFator := 1
		ElseIf DD0->DD0_TIPPER == '2' //-- Mensal
			nFator := 30
		ElseIf DD0->DD0_TIPPER == '3' //-- Diario
			nFator := 365
		EndIf
		dDatRet:= (dDataBase + (DD0->DD0_PERAPR * nFator)) 
	EndIf
ElseIf 	"DD3_PERAPR" $ cCampo  
	If !Empty(M->DD3_PERAPR) .And. !Empty(FwFldGet('DD3_TIPPER'))
		If FwFldGet('DD3_TIPPER') == '1' //-- Diario
			nFator := 1
		ElseIf FwFldGet('DD3_TIPPER') == '2' //-- Mensal
			nFator := 30
		ElseIf FwFldGet('DD3_TIPPER') == '3' //-- Diario
			nFator := 365
		EndIf
		dDatRet:= (dDataBase + (M->DD3_PERAPR * nFator))
	EndIf
ElseIf "DD3_TIPPER" $ cCampo 
	If !Empty(FwFldGet('DD3_PERAPR')) .And. !Empty(M->DD3_TIPPER)
		If M->DD3_TIPPER == '1' //-- Diario
			nFator := 1
		ElseIf M->DD3_TIPPER == '2' //-- Mensal
			nFator := 30
		ElseIf M->DD3_TIPPER == '3' //-- Diario
			nFator := 365
		EndIf
		dDatRet:=  (dDataBase + (FwFldGet('DD3_PERAPR') * nFator))
	EndIf   
EndIf

RestArea( aArea )
Return dDatRet