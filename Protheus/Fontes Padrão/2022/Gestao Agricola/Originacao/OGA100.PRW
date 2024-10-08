#INCLUDE "OGA100.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integra��o com EAI

static __lIntGFE    := SuperGetMv("MV_INTGFE",,.F.)   //Integra��o GFE    

/** {Protheus.doc} OGA100
Rotina para cadastro de negociadores e lideres de mesa de opera��o de trader.

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Origina��o de Gr�os
*/
Function OGA100()
	Local oMBrowse 	:= Nil

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NJU" )
	oMBrowse:SetDescription( STR0001 ) //"Safra"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return( Nil )


/** {Protheus.doc} MenuDef
Fun��o que retorna os itens para constru��o do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA100 - Safra
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002, 'PesqBrw'       , 0, 1, 0, .T. } ) //'Pesquisar'
	aAdd( aRotina, { STR0003, 'ViewDef.OGA100', 0, 2, 0, Nil } ) //'Visualizar'
	aAdd( aRotina, { STR0004, 'ViewDef.OGA100', 0, 3, 0, Nil } ) //'Incluir'
	aAdd( aRotina, { STR0005, 'ViewDef.OGA100', 0, 4, 0, Nil } ) //'Alterar'
	aAdd( aRotina, { STR0006, 'ViewDef.OGA100', 0, 5, 0, Nil } ) //'Excluir'
	aAdd( aRotina, { STR0007, 'ViewDef.OGA100', 0, 8, 0, Nil } ) //'Imprimir'
	aAdd( aRotina, { STR0008, 'ViewDef.OGA100', 0, 9, 0, Nil } ) //'Copiar'
	aAdd( aRotina, { STR0014, 'OGA100CTSAF', 0, 10, 0, Nil } ) //'Copiar'

Return( aRotina )


/** {Protheus.doc} ModelDef
Fun��o que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA100 - Safra
*/
Static Function ModelDef()
	Local oStruNJU := FWFormStruct( 1, "NJU" )
	Local oModel   := MPFormModel():New( "OGA100" )

	oModel:AddFields( "NJUUNICO", Nil, oStruNJU )
	oModel:SetDescription( STR0001 ) //"Safra"
	oModel:GetModel( "NJUUNICO" ):SetDescription( STR0009 ) //"Dados da Safra"

	
Return( oModel )


/** {Protheus.doc} ViewDef
Fun��o que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA100 - Safra
*/
Static Function ViewDef()
	Local oStruNJU := FWFormStruct( 2, "NJU" )
	Local oModel   := FWLoadModel( "OGA100" )
	Local oView    := FWFormView():New()
	
	If NJU->(ColumnPos('NJU_ID')) > 0 
		oStruNJU:RemoveField('NJU_ID')
	EndIf
	
	oView:SetModel( oModel )
	oView:AddField( "VIEW_NJU", oStruNJU, "NJUUNICO" )
	oView:CreateHorizontalBox( "UM"  , 100 )
	oView:SetOwnerView( "VIEW_NJU", "UM"   )

	If !__lIntGFE 
		oStruNJU:RemoveField('NJU_OPELOG')
		oStruNJU:RemoveField('NJU_DOPLOG')
	EndIf

	oView:SetCloseOnOk( {||.t.} )

Return( oView )


/*/{Protheus.doc} CriaTlProF
@author bruna.rocio
@since 21/04/2016
@version undefined

@type function
/*/
Function OGA100CTSAF()
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oPnDown   := Nil
	Local oSize     := Nil	
	Local oBrwMrk := Nil

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4],;
	STR0012 , , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	oFWLayer:AddLine( 'UP', 10, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	oPnTOP := oFWLayer:GetColPanel( 'ALL', 'UP' )

	oFWLayer:AddLine( 'DOWN', 90, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'DOWN' )
	oPnDown := oFWLayer:GetColPanel( 'ALL', 'DOWN' )

	oBrwMrk:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	oBrwMrk:SetDescription( STR0010 ) // Define o titulo do MarkBrowse
	oBrwMrk:SetFilterDefault("@"+FiltraMark())
	oBrwMrk:SetFilterDefault()
	oBrwMrk:SetAlias("NN1") 
	oBrwMrk:SetFieldMark("NN1_OK")	// Define o campo utilizado para a marcacao		
	oBrwMrk:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	oBrwMrk:DisableConfig()	// Desabilita a opcao de configuracao do MarkBrowse
	oBrwMrk:DisableDetails()	// Desabilita a exibicao dos detalhes do MarkBrowse
	oBrwMrk:DisableReport()	// Desabilita a opcao de imprimir
	oBrwMrk:SetMenuDef("")	// Desabilita a opcao de imprimir	    
	oBrwMrk:Activate(oPnDown)	// Ativa o MarkBrowse
	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar(oDlg,{|| IIf(MsgRun( STR0011, STR0013,;
	{|| GeraSafra( oBrwMrk )}), oDlg:End(), NIL)},{||oDlg:End()},,) } )

	RestArea(aArea)
Return .T.




/*/{Protheus.doc} FiltraMark
//TODO Descri��o auto-gerada.
@author bruna.rocio
@since 08/03/2017
@version undefined

@type function
/*/
Static Function FiltraMark()
	Local cQuery := ""

	cQuery := " NN1_CODSAF = ' ' " + ;
	" AND NOT EXISTS ( SELECT NJU_CODSAF " +;
	" FROM " + RetSqlName('NJU') + " NJU " +;
	" WHERE NJU.D_E_L_E_T_ = ' ' " +;
	"   AND NJU.NJU_FILIAL = '" + FwXFilial('NJU') + "' " +; 
	"   AND NJU.NJU_CODSAF = NN1_ANO+NN1_SEQ) "

Return cQuery


/*/{Protheus.doc} GeraSafra
//TODO Descri��o auto-gerada.
@author bruna.rocio
@since 09/03/2017
@version undefined
@param oBrwMrk, object, descricao
@type function
/*/
Static Function GeraSafra(oBrwMrk)
	Local lRet   := .T.
	Local cAQry  := GetNextAlias() 	

	//Inicia transa��o
	Begin Transaction

		//Posiciona no topo da lista	
		NN1->(dbGoTop())
		While NN1->( !Eof() )

			//Verifica se ciclo produtivo foi selecionado
			If oBrwMrk:IsMark()

				//Verifica se j� existe safra para o ciclo produtivo
				dbSelectArea('NJU')
				dbSetOrder(1)
				If !dbSeek(FwxFilial('NJU')+NN1->NN1_ANO+NN1->NN1_SEQ)

					//Trava registro e cria safra
					If RecLock('NJU', .T.)
						NJU->NJU_FILIAL := FwxFilial('NJU')
						NJU->NJU_CODSAF := NN1->NN1_ANO + NN1->NN1_SEQ
						NJU->NJU_DESCRI := NN1->NN1_DESCRI
						MsUnlock()
					Endif	

					//Trava registro e vincula safra ao ciclo produtivo
					If RecLock('NN1',.F.)
						NN1->NN1_CODSAF := NN1->NN1_ANO + NN1->NN1_SEQ
						NN1->(MsUnlock())
					Endif

					If Select(cAQry) > 0
						(cAQry)->(dbCloseArea())
						cAQry := GetNextAlias()
					Endif

					//Verifica se existe contrato para o ciclo produtivo
					//Se sim, atualiza a informa��o no campo ADA_CODSAF
					BeginSql Alias cAQry
					Select ADA_NUMCTR From %Table:ADA% ADA 
					Where ADA.%notDel%	
					AND ADA.ADA_FILIAL = %xFilial:ADA%
					AND ADA.ADA_SAFRA  = %exp:NN1->NN1_CODSAF%
					AND ADA.ADA_CODSAF = ' '  
					EndSQL

					dbSelectArea(cAQry)

					(cAQry)->(dbGoTop()) 	
					While !(cAQry)->(Eof())
						dbSelectArea('ADA')
						dbSetOrder(1)
						If dbSeek(FwXFilial('ADA')+(cAQry)->ADA_NUMCTR )
							Reclock('ADA',.F.)
							ADA->ADA_CODSAF := ADA->ADA_SAFRA
							MsUnlock()
						Endif
						(cAQry)->( dbSkip())
					EndDo				 	
					//Fim atualiza��es
				Endif
			Endif
			NN1->(dbSkip())
		EndDo
	End Transaction

	oBrwMrk:Refresh()
Return lRet


/*/{Protheus.doc} IntegDef
//Fun��o responsavel pela chamada de integra��o
@author bruna.rocio
@since 07/08/2017
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
	Local aRet := {}	
	If ExistFunc( 'OGI100' )
		//Prote��o de codigo para campo necess�rio ao adapter
		If NJU->(ColumnPos( 'NJU_ATIVO' )) > 0 
			aRet:= OGI100( cXml, nTypeTrans, cTypeMessage )
		Else
			MsgNextRel()
		Endif 
	EndIf
Return aRet