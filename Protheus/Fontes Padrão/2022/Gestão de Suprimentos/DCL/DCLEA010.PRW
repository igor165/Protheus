#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE MB_ICONASTERISK 64

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA010
Interface auxiliar para distribuicao das quantidades entre os armazens.       

@author Bruno.Schmidt
@since 16/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCLEA010()
Local oBrowse := FWMBrowse():New() 
Local aAreaSF5	:= SF5->(GetArea())

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

oBrowse:SetAlias('DH9')
oBrowse:SetDescription('Rateio de Recebimento Antecipado') 

//Legendas
oBrowse:AddLegend("DH9->DH9_VO20GF==0 .AND. DH9->DH9_DATA <= DDATABASE"	,"YELLOW"	,"Pendente")	// "Execução"
oBrowse:AddLegend("DH9->DH9_VO20GF==0 .AND. DH9->DH9_DATA  > DDATABASE"	,"GREEN"	,"Programado")	// "Executado"
oBrowse:AddLegend("DH9->DH9_VO20GF<>0 "										,"RED"		,"Encerrado")	// "Finalizado"

SF5->(DbsetOrder(2))
If !(SF5->(DbSeek(xFilial("SF5") + "PR" + "D")))
	Help( ,, 'Atencao',, "Tipo de Movimento Provisorio (PR) Não Cadastrado.", 1, 0 )
Else
	oBrowse:Activate()
EndIf

RestArea(aAreaSF5)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu

@author Bruno.Schmidt
@since 16/02/2017
@version P12
/*/
//-------------------------------------------------------------------	

Static Function MenuDef()
Local aRotina:={}

ADD OPTION aRotina TITLE "Visualizar"	ACTION "VIEWDEF.DCLEA010"	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0	//"Visualizar"
ADD OPTION aRotina TITLE "Incluir" 	ACTION "VIEWDEF.DCLEA010"	OPERATION MODEL_OPERATION_INSERT 	ACCESS 0	//"Incluir"
ADD OPTION aRotina TITLE "Alterar"	ACTION "VIEWDEF.DCLEA010"	OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0 	//'Alterar'
ADD OPTION aRotina TITLE "Excluir"	ACTION "VIEWDEF.DCLEA010"	OPERATION MODEL_OPERATION_DELETE	ACCESS 3  // Excluir
ADD OPTION aRotina TITLE "Estornar"	ACTION "DCLEA010ESTORNA()"	OPERATION MODEL_OPERATION_DELETE	ACCESS 3  // Estornar


Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo

@author Bruno.Schmidt
@since 16/02/2017
@version P12
/*/
//-------------------------------------------------------------------	
Static Function ModelDef()
Local oStruDH9	:= FWFormStruct( 1, 'DH9') 																			// Equipe  
Local oStruD3D	:= FWFormStruct( 1,'D3D') 
Local oModel		:= Nil 

//-- Cria a estrutura basicaadmin
oModel := MPFormModel():New('DCLEA010',/*bPreValidacao*/,{ |oModel| POSDCLEA010( oModel ) }, { |oModel| COMDCLEA010( oModel ) }, /*bCancel*/ )

oModel:AddFields(	'DH9MASTER',/*cOwner*/	, oStruDH9,/*bPreValidacao*/{ |oModel| PREDCLEA010( oModel ) },/*bPosValidacao*/)

oModel:AddGrid(	'D3DDETAIL', 'DH9MASTER'	, oStruD3D,/*bPreValidacao*/,{ |oModel| D3DPOSVALIDDCLEA010() } ) 

oModel:SetRelation('D3DDETAIL', {{'D3D_FILIAL' , 'xFilial("D3D")'   },{'D3D_CODIGO','DH9_CODIGO'}    },D3D->(IndexKey(1)))

oModel:SetPrimaryKey( {} )

oModel:SetDescription("Digitação de bombeio")

oModel:GetModel( 'DH9MASTER' ):SetDescription("Cabec")
oModel:GetModel( 'D3DDETAIL' ):SetDescription("Grid")

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View

@author Bruno.Schmidt
@since 16/02/2017
@version P12
/*/
//--------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= FWLoadModel( 'DCLEA010' )
Local oStruDH9	:= FWFormStruct( 2, 'DH9') 
Local oStruD3D	:= FWFormStruct( 2, 'D3D',{|cCampo| !AllTrim(cCampo) $ "D3D_CODIGO"	}) 

oView := FWFormView():New()

//-- Associa o View ao Model
oView:SetModel( oModel )

//-- Insere os componentes na view
oView:AddField( 'VIEW_CABEC', oStruDH9, 'DH9MASTER' )

//--Insere os Gris na View
oView:AddGrid( 'VIEW_GRID', oStruD3D, 'D3DDETAIL')

//-- Cria os Box's
oView:CreateHorizontalBox( 'CABEC'	,70)
oView:CreateHorizontalBox( 'GRID',30)


oView:SetOwnerView( 'VIEW_CABEC'	, 'CABEC')
oView:SetOwnerView( 'VIEW_GRID'	, 'GRID')


Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} D3DPOSVALIDDCLEA010()
Definicao da View

@author Totvs
@since 16/02/2017
@version P12
/*/
//--------------------------------------------------------------------
Static Function D3DPOSVALIDDCLEA010( )
Local oModel		:= FwModelActive()
Local oStruD3D	:= oModel:GetModel('D3DDETAIL')
Local oStruDH9	:= oModel:GetModel('DH9MASTER')
Local nOperation	:= oModel:GetOperation()
Local nI			:= 0
Local cLocal		:= ""
Local lRet		:= .T.

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
	
	For nI:=1 to oStruD3D:Length()
		oStruD3D:GoLine( nI )
		If !oStruD3D:IsDeleted() 
			If oStruD3D:GetValue('D3D_LOCAL') $ cLocal
				MsgAlert('Cessionaria ja digitada na linha: '+strzero(nI,3))
				lRet := .F.
			EndIf		
		cLocal := oStruD3D:GetValue('D3D_LOCAL')
		EndIf
	Next nI
	
	If lRet 
		D35->(dbSetOrder(1))
		If	!D35->(dbSeek(xFilial('D35')+cLocal))
			lRet:=.F.
			MsgAlert('Cessionaria nao cadastrada')
		EndIf
	EndIf
EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} POSDCLEA010()
Pós Valid do modelão

@author Totvs
@since 16/02/2017
@version P12
/*/
//--------------------------------------------------------------------
Function POSDCLEA010( oModel )
Local oStruD3D	:= oModel:GetModel('D3DDETAIL')
Local oStruDH9	:= oModel:GetModel('DH9MASTER')
Local nOperation	:= oModel:GetOperation()
Local nI			:= 0
Local cLocal		:= ""
Local lRet		:= .T.
Local nTotal		:= 0

For nI :=1  To oStruD3D:Length()
	nTotal += oStruD3D:GetValue('D3D_QTDLOC')
Next nI

IF oStruDH9:GetValue('DH9_QTDSOL') <> nTotal
	MessageBox("A Soma das quantidade dos Locais está Diferente da Qtd. Solicitada","Atenção",MB_ICONASTERISK)
	lRet := .F.
ENDIF

IF lRet
	For nI:=1 to oStruD3D:Length()
		oStruD3D:GoLine( nI )
		cLocal := oStruD3D:GetValue('D3D_LOCAL')
		nQTLOC := oStruD3D:GetValue('D3D_QTDLOC')
		
		IF ! EMPTY(cLocal)
			D35->(dbSetOrder(1))
			If !D35->(dbSeek(xFilial('D35')+cLocal))
				MsgAlert("Cessionaria não localizada.","Aviso")
				lRet := .F.
			Else
				lRet:= DCLEA10VMAX(oStruDH9:GetValue('DH9_CODPRO'),D35->D35_CODCON,D35->D35_LOJCON,cLocal,"3",nQTLOC)
				IF !lRet
					Return(lRet)
				Endif
			Endif
		EndIf
	Next nI
Endif

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} PREDCLEA010()
Pós Valid do modelão

@author Totvs
@since 16/02/2017
@version P12
/*/
//--------------------------------------------------------------------
Static Function PREDCLEA010( oModel )
Local oStruD3D	:= oModel:GetModel('D3DDETAIL')
Local oStruDH9	:= oModel:GetModel('DH9MASTER')
Local nOperation	:= oModel:GetOperation()
Local nI			:= 0
Local cLocal		:= ""
Local lRet		:= .T.
Local nTotal		:= 0
Local nQTLOC		:= 0 
Local nTamNF		:= TamSX3('D3_NFORP')[1]

If dDataBase <= GETMV("MV_ULMES")
	Help( ,, 'Atencao',, "Fechamento de estoque ja Promovido para esta Data", 1, 0 ) 
	lRet := .F.
EndIf

SF5->(DbsetOrder(2))
If lRet .and. !SF5->(msSeek(xFilial("SF5")+"PR"+"D"))
	Help( ,, 'Atencao',, "Tipo de Movimento Provisorio (PR) Não Cadastrado.", 1, 0 )
	lRet := .F.
EndIf

If lRet .and. nOperation == MODEL_OPERATION_UPDATE 
	If DH9->DH9_VO20GF <> 0
		Help( ,, 'Atencao',, "Rec.Antecipado ja Encerrado nao Pode ser Alterado", 1, 0 )
		lRet := .F.
	EndIf
EndIf	

If lRet .and. nOperation == MODEL_OPERATION_DELETE .and. oStruDH9:GetValue('DH9_VO20GF') <> 0
	// Valida se os Movimentos Provisorios podem ser Estornados	
	For nI:=1 to oStruD3D:Length()
		oStruD3D:GoLine( nI )
		cLocal := oStruD3D:GetValue('D3D_LOCAL')
		nQTLOC := oStruD3D:GetValue('D3D_QTDLOC')
		SD3->(DbSetorder(17))
		If nQTLOC <> 0 .AND. ! EMPTY(cLocal)
			If ! SD3->(msSeek(xFilial("SD3")+PadR(oStruDH9:GetValue('DH9_CODIGO')+cLocal,nTamNF)+"PR"+" "))
				_cLocais += cLocal+'/'
				lRet := .F.
				Help( ,, 'Atencao',, "Nota fiscal já informada para os locais: "+_cLocais+;
				". O registro só poderá ser excluído se não houver nenhuma nota fiscal associada.", 1, 0 )
			EndIf
		EndIf
	Next nI
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} COMDCLEA010
Comit do Modelo

@author TOTVS
@since 09/02/2017
@version P12
/*/
//------------------------------------------------------------------- 
Static Function COMDCLEA010( oModel )
Local oStruD3D	:= oModel:GetModel('D3DDETAIL')
Local oStruDH9	:= oModel:GetModel('DH9MASTER')
Local I1			:= 0
Local nDifer		:= 0	
Local nMediaPond	:= 0
Local nQTLOC		:= 0
Local cTMD		:= ""
Local cTMR		:= ""
Local cTMT		:= ""
Local nOperation	:= oModel:GetOperation()
Local lRet		:= .T.
Local lRateio		:= SuperGetMV("MV_RATBOMB",.F., .F.)

Private lMsErroAuto	:= .F.

Do case

	Case nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona o TM para a geracao do PR  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF5->(DbsetOrder(2))
		IF SF5->(msSeek(xFilial("SF5")+"PR"+"D"))
			cTMD := SF5->F5_CODIGO
			cTMT := SF5->F5_MOVTANQ
			SF5->(dbSetOrder(1))
		EndIf
		
		If oStruDH9:GetValue('DH9_VO20GF')<> 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera os Movimentos Provisorios de Entrada - PR   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For I1:=1 to oStruD3D:Length()
				oStruD3D:GoLine( I1 )
				cLocal := oStruD3D:GetValue('D3D_LOCAL')
				nQTLOC := oStruD3D:GetValue('D3D_QTDLOC')
				If nQTLOC <> 0 .AND. !EMPTY(cLocal)
					MessageBox("O Recebimento Antecipado gerará os Movimentos Internos Provisórios de Estoque.","Atenção",MB_ICONASTERISK)
					
					aVetor:= {	{"D3_TM"		,cTMD											,NIL},;
								{"D3_COD"		,oStruDH9:GetValue('DH9_CODPRO')			,NIL},;
								{"D3_QUANT"	,nQTLOC										,NIL},;
								{"D3_LOCAL"	,cLocal										,NIL},;
								{"D3_DOC"  	,oStruDH9:GetValue('DH9_CODIGO')			,NIL},;
								{"D3_EMISSAO"	,oStruDH9:GetValue('DH9_DATA')				,NIL},;
								{"D3_TANQUE"	,oStruDH9:GetValue('DH9_TANQUE')			,NIL},;
								{"D3_NFORP"	,oStruDH9:GetValue('DH9_CODIGO')+cLocal	,NIL},;
								{"D3_CODFOR"	,oStruDH9:GetValue('DH9_FORNEC')			,NIL},;
								{"D3_LOJAFOR"	,oStruDH9:GetValue('DH9_LOJA')				,NIL},;
								{"D3_TPMOVAJ"	,cTMT											,NIL},;
								{"D3_OBS"		,oStruDH9:GetValue('DH9_OBS')				,NIL}}
					
					MSExecAuto({|x,y| MATA240(x,y)},aVetor,3) //Inclusao
					
					If lMsErroAuto
						DisarmTransaction()
						MostraErro()
						lRet:= .F.
					Else
						Reclock("SD3",.F.)
						SD3->D3_TEMPTAQ	:= oStruDH9:GetValue('DH9_TEMPTF')
						SD3->D3_TEMPAMO	:= oStruDH9:GetValue('DH9_TEMPF')
						SD3->D3_DENSAMB		:= oStruDH9:GetValue('DH9_DENSF')
						SD3->D3_FATCORR	:= Iif(oStruDH9:GetValue('DH9_FATCOF')== 0,1,oStruDH9:GetValue('DH9_FATCOF') )
						MSUnlock()
					EndIf
				EndIf
			Next
			
			// Verifica se existe diferenca no Volume 20G para gerar Perda/Ganho
			
			nDifer := (oStruDH9:GetValue('DH9_VO20GF')- oStruDH9:GetValue('DH9_VO20GI')) - oStruDH9:GetValue('DH9_QTDSOL')
			
			If nDifer <> 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Seleciona os TM's para geracao da Perda e Ganho - BO ou DE  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SF5->(DbSetORder(2))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cancela transacao se nao encontrar os TM's para Perda e Ganho  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF5->(msSeek(xFilial("SF5")+oStruDH9:GetValue('DH9_TIPO')+"R"))
					cTMR := SF5->F5_CODIGO
				Else
					Help( ,, 'Atencao',, "Tipo de Movimento Provisório ("+ Alltrim(oStruDH9:GetValue('DH9_TIPO')) +") Não Cadastrado.", 1, 0 )
					DisarmTransaction()
					lRet:= .F.
				EndIf
				
				If lRet
					If SF5->(msSeek(xFilial("SF5")+DH9->DH9_TIPO+"D"))
						cTMD := SF5->F5_CODIGO
					Else
						Help( ,, 'Atencao',, "Tipo de Movimento Provisório ("+ Alltrim(oStruDH9:GetValue('DH9_TIPO')) +") Não Cadastrado.", 1, 0 )
						DisarmTransaction()
						lRet:= .F.
					EndIf
				EndIf
				
				If lRet
					SF5->(dbSetOrder(1))
					lMsErroAuto := .F.
					dbSelectArea("SD3")
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gera os Movimentos de Perda/Ganho com Rateio - BO ou DE   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRateio
						For I1:=1 to oStruD3D:Length()
							oStruD3D:GoLine( I1 )
							
							cLocal := oStruD3D:GetValue('D3D_LOCAL')
							nQTLOC := oStruD3D:GetValue('D3D_QTDLOC')
							If &(nQTLOC)<> 0 .AND. ! Empty(&(cLocal))
								
								nPercen := nQTLOC / oStruDH9:GetValue('DH9_QTDSOL')
								nMediaPond := ABS(nDifer * nPercen)
								
								aVetor := {	{"D3_TM"	,Iif(nDifer > 0,cTMD,cTMR)				,NIL},;
											{"D3_COD"		,oStruDH9:GetValue('DH9_CODPRO')		,NIL},;
											{"D3_QUANT"	,nMediaPond								,Nil},;
											{"D3_LOCAL"	,cLocal									,Nil},;
											{"D3_CODFOR"	,oStruDH9:GetValue('DH9_FORNEC')		,NIL},;
											{"D3_LOJAFOR"	,oStruDH9:GetValue('DH9_LOJA')			,NIL},;
											{"D3_NFORP"	,oStruDH9:GetValue('DH9_CODIGO')+"99"	,NIL},;
											{"D3_TANQUE"	,oStruDH9:GetValue('DH9_TANQUE')		,NIL},;
											{"D3_TPMOVAJ"	,oStruDH9:GetValue('DH9_TIPO')			,NIL},;
											{"D3_DOC"		,oStruDH9:GetValue('DH9_CODIGO')		,NIL},;
											{"D3_OBS"		,oStruDH9:GetValue('DH9_OBS')			,NIL},;
											{"D3_EMISSAO"	,oStruDH9:GetValue('DH9_DATA')			,NIL}}
								
								MSExecAuto({|x,y| MATA240(x,y)},aVetor,3) //Inclusao
								
								IF lMsErroAuto
									MostraErro()
									lRet:= .F.
								Else
									Reclock("SD3",.F.)
									SD3->D3_FATCORR	:= Iif(oStruDH9:GetValue('DH9_FATCOF') == 0,1,oStruDH9:GetValue('DH9_FATCOF'))
									MSUnlock()
								Endif
							Endif
						Next
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gera os Movimentos de Perda/Ganho sem Rateio - BO ou DE   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Else
						aVetor := {{"D3_TM"	,IIF(nDifer > 0,cTMD,cTMR)					,NIL},;
									{"D3_COD"		,oStruDH9:GetValue('DH9_CODPRO')		,NIL},;
									{"D3_QUANT"	,Iif(nDifer < 0,(nDifer * -1),nDifer)	,NIL},;
									{"D3_LOCAL"	,cLocal						,NIL},;
									{"D3_CODFOR"	,oStruDH9:GetValue('DH9_FORNEC')		,NIL},;
									{"D3_LOJAFOR"	,oStruDH9:GetValue('DH9_LOJA')			,NIL},;
									{"D3_NFORP"	,oStruDH9:GetValue('DH9_CODIGO')+"99"	,NIL},;
									{"D3_TANQUE"	,oStruDH9:GetValue('DH9_TANQUE')		,NIL},;
									{"D3_DOC"		,oStruDH9:GetValue('DH9_CODIGO')		,NIL},;
									{"D3_TPMOVAJ" ,oStruDH9:GetValue('DH9_TIPO')			,NIL},;
									{"D3_OBS"		,oStruDH9:GetValue('DH9_OBS')			,NIL},;
									{"D3_EMISSAO"	,oStruDH9:GetValue('DH9_DATA')			,NIL}}
						
						MSExecAuto({|x,y| MATA240(x,y)},aVetor,3) //Inclusao
					EndIf
					
					If lMsErroAuto
						DisarmTransaction()
						MostraErro()
						lRet:= .F.
					Else
						Reclock("SD3",.F.)
						SD3->D3_FATCORR	:= Iif(oStruDH9:GetValue('DH9_FATCOF') == 0,1,oStruDH9:GetValue('DH9_FATCOF'))
						MSUnlock()
					EndIf
				EndIf
			EndIf
		EndIf
	
	Case  nOperation == MODEL_OPERATION_DELETE 
		DELETDCLEA010(oModel)
EndCase
If lRet
	lRet:= FwFormCommit(oModel)
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETDCLEA010
Pre- validação da deleção

@author TOTVS
@since 09/02/2017
@version P12
/*/
//------------------------------------------------------------------- 
Static Function DELETDCLEA010( oModel )
Local oStruD3D	:= oModel:GetModel('D3DDETAIL')
Local oStruDH9	:= oModel:GetModel('DH9MASTER')
Local cLocal := ""
Local nQTLOC := 0 
Local nTamNF		:= TamSX3('D3_NFORP')[1]
Local nI := 0 
Local lRet := .T.

If oStruDH9:GetValue('DH9_VO20GF')<> 0

	// Inicia o processo de Estorno dos Movimentos Provisorios

	// Estorna os Movimentos Provisorios de Entrada - PR 
	For nI:=1 to oStruD3D:Length()
		oStruD3D:GoLine( nI )
		cLocal := oStruD3D:GetValue('D3D_LOCAL')
		nQTLOC := oStruD3D:GetValue('D3D_QTDLOC')
		If nQTLOC<> 0 .AND. !Empty(cLocal)
			SD3->(DbSetorder(17))
			If SD3->(msSeek(xFilial("SD3")+PadR(oStruDH9:GetValue('DH9_CODIGO')+cLocal,nTamNF)+"PR"+" "))
				lMsErroAuto := .F.
				
				aVetor := {{"D3_NUMSEQ"		,SD3->D3_NUMSEQ	,NIL},;
							{"D3_CHAVE"		,SD3->D3_CHAVE	,NIL},;
							{"D3_COD"			,SD3->D3_COD		,NIL},;
							{"INDEX"			,4					,NIL}}
							
				MSExecAuto({|x,y| MATA240(x,y)},aVetor,5) // Estorno
				If lMsErroAuto
					MostraErro()
					DisarmTransaction()
					lRet := .F.
					Exit
				EndIf
		    EndIf
		EndIf
	Next nI
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estorna os Movimentos de Perda/Ganho sem Rateio - BO ou DE   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SD3->(DbSetorder(17))
	While SD3->(msSeek(xFilial("SD3")+PadR(oStruDH9:GetValue('DH9_CODIGO')+"99",nTamNF)+oStruDH9:GetValue('DH9_TIPO')+" "))
		lMsErroAuto := .F.
		
		aVetor := {	{"D3_NUMSEQ"	,SD3->D3_NUMSEQ	,NIL},;
					{"D3_CHAVE"		,SD3->D3_CHAVE	,NIL},;
					{"D3_COD"			,SD3->D3_COD		,NIL},;
					{"INDEX"			,4					,NIL}}
					
		MSExecAuto({|x,y| MATA240(x,y)},aVetor,5) // Estorno
		If lMsErroAuto
			MostraErro()
			DisarmTransaction()
			Return()
		EndIf						
		SD3->(DBSKIP())
	EndDo
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA010ESTORNA
Estorna os Mov. Provisorios da Digitacao de Bombeio   

@author TOTVS
@since 09/02/2017
@version P12
/*/
//------------------------------------------------------------------- 
Function DCLEA010ESTORNA( oModel )
Local nI			:= 0
Local nTamNF		:= TamSX3('D3_NFORP')[1]
Local cLocal		:= " " 
Local _cLocais	:= "" 
Local lEstorno	:= .F.
Local aAreaDH9	:= DH9->(GetArea())


If DH9->DH9_VO20GF <> 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se os Movimentos Provisorios podem ser Estornados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("D3D")
	DbSetOrder(1)
	D3D->(DbSeek(xFilial("D3D")+DH9->DH9_CODIGO))
	While D3D->(D3D_FILIAL+D3D_CODIGO) == DH9->(DH9_FILIAL+DH9_CODIGO) .AND. !EOF()
		cLocal := D3D->D3D_LOCAL
		nQTLOC := D3D->D3D_QTDLOC
		SD3->(DbSetOrder(17))
		If nQTLOC<> 0 .And. ! EMPTY(cLocal)
			If ! SD3->(msSeek(xFilial("SD3")+PadR(DH9->DH9_CODIGO+cLocal,nTamNF)+"PR"+" "))
				lEstorno := .T.
				_cLocais += cLocal+'/'
				Exit
			EndIf
		EndIf
		D3D->(DbSkip())
	End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia o processo de Estorno dos Movimentos Provisorios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lEstorno
		If MsgYesNo("Deseja estornar a apuração do Recebimento Antecipado?")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estorna os Movimentos Provisorios de Entrada - PR   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("D3D")
			DbSetOrder(1)
			D3D->(DbSeek(xFilial("D3D")+DH9->DH9_CODIGO))
			While D3D->(D3D_FILIAL+D3D_CODIGO) == DH9->(DH9_FILIAL+DH9_CODIGO) .AND. !EOF()
				cLocal := D3D->D3D_LOCAL
				nQTLOC := D3D->D3D_QTDLOC
				If nQTLOC<> 0 .And. ! EMPTY(cLocal)
					SD3->(DbSetOrder(17))
					If SD3->(msSeek(xFilial("SD3")+PadR(DH9->DH9_CODIGO+cLocal,nTamNF)+"PR"+" "))
						lMsErroAuto := .F.
						
						aVetor := {	{"D3_NUMSEQ"	,SD3->D3_NUMSEQ		,NIL},;
									{"D3_CHAVE"		,SD3->D3_CHAVE		,NIL},;
									{"D3_COD"		,SD3->D3_COD		,NIL},;
					           	 	{"INDEX"		,4					,NIL}}
					           	 	
						MSExecAuto({|x,y| MATA240(x,y)},aVetor,5) // Estorno
						If lMsErroAuto
							MostraErro()
							DisarmTransaction()
							Return()
						EndIf	
					EndIf
				EndIf
				D3D->(DbSkip())
			End
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estorna os Movimentos de Perda/Ganho sem Rateio - BO ou DE   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While SD3->(msSeek(xFilial("SD3")+PadR(DH9->DH9_CODIGO+"99",nTamNF)+DH9->DH9_TIPO+" "))
				lMsErroAuto := .F.
				
				aVetor := {	{"D3_NUMSEQ"	,SD3->D3_NUMSEQ		,NIL},;
							{"D3_CHAVE"		,SD3->D3_CHAVE		,NIL},;
							{"D3_COD"			,SD3->D3_COD		,NIL},;
				          	{"INDEX"		,4					,NIL}}
				          	
				MSExecAuto({|x,y| MATA240(x,y)},aVetor,5) // Estorno
				If lMsErroAuto
					MostraErro()
					DisarmTransaction()
					Return()
				EndIf
				SD3->(DbSkip())
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ajusta Volume Final 20G   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("DH9")
			Reclock("DH9",.F.)
			DH9->DH9_VO20GF := 0
			MsUnlock()
		EndIf
	Else
		MessageBox("Nota Fiscal já informada para os locais: "+_cLocais+". O registro não pode ser estornado.","Atenção",MB_ICONASTERISK)
	EndIf
Else
	MessageBox("Só é permitido estorno de Recebimentos Antecipados já encerrados.","Atenção",MB_ICONASTERISK)
EndIf


RestArea(aAreaDH9)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA10VMAX
Valida quantidade de Volume Recebido.Nao Permite Volume de Entrada + 
Volume em estoque ser maior que o declarado no Campo: A5_XVOLMAX - Tabela SA5.	
Chamado Por: P.E.: MT100LOK, P.E.: MT240TOK ou TDCEA010.	

@author TOTVS
@since 09/02/2017
@version P12
/*/
//------------------------------------------------------------------- 
Function DCLEA10VMAX(cProduto,Cfornec,cLoja,cLocal,cOrig,nQuant)

Local cMsg := ''
Local lret := .t.

SA5->(dbSetOrder(1)) //A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO
If !SA5->(dbSeek(xFilial("SA5")+Cfornec+cLoja+cProduto)) .Or. Empty(SA5->A5_VOLMAX)
	Return .t.
Endif

SB2->(dbSetOrder(1))

If !SB2->(DBSEEK(XFILIAL()+cProduto+cLocal))
	MessageBox(" Inconsistencia no Saldo do Produto ","Atenção",MB_ICONASTERISK)
	Return .f.
Endif

If SB2->B2_QATU + nQuant > SA5->A5_VOLMAX
	cMsg := "Volume informado para armazen : (" +cLocal+')  '+Alltrim(Transform(nQuant,"@E 999,999,999")) + chr(13)+chr(10)
	cMsg += "Acrescentado ao Volume existente: " + Alltrim(Transform(SB2->B2_QATU,"@E 999,999,999")) + chr(13)+chr(10)
	cMsg += "É maior que o Volume Máximo Permitido: " + Alltrim(Transform(SA5->A5_VOLMAX,"@E 999,999,999"))
	MessageBox(cMsg,"Informação",MB_ICONASTERISK)
	Return .f.
Endif

Return lret

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA10MARG
Verifica a Margem aceitavel a Menor ou a Maior entre as Qtds
Fiscal e Apuradas. Em (%).	

@author TOTVS
@since 09/02/2017
@version P12
/*/
//------------------------------------------------------------------- 
FUNCTION DCLEA10MARG()

Local nTamNF		:= TamSX3('D3_NFORP')[1]
Local nPerc		:= 0
Local cMsg		:= ''
Local cSeek		:= ''
Local cProdu		:= GDFieldGet("D1_COD")
Local cLocal		:= GDFieldGet("D1_LOCAL")
Local cXVia		:= GDFieldGet("DH4_TDCARG")
Local nQtd		:= GDFieldGet("D1_QUANT")
Local nQtd1		:= GDFieldGet("DH4_QTD20G")
Local cDprov		:= GDFieldGet("DH4_DCPROV")

//CNFISCAL+CSERIE+CA100FOR+CLOJA
SA5->(dbSetOrder(1)) //A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO
If !SA5->(dbSeek(xFilial("SA5") + cA100For + cLoja + cProdu)) .Or. Empty(SA5->A5_TOLEDIF)
	Return .t.
Endif

cSeek:= Padr(cDprov + cLocal,nTamNF)+"PR"+" "

If cXVia == "02" // TIPO BOMBEIO
	SD3->(DbSetOrder(16))
	If SD3->(msSeek(xFilial("SD3")+cSeek))
		nPerc:= XPercent (SD3->D3_QUANT,nQtd )
	Else
		ApMsgAlert("Movimento nao localizado: " + Alltrim(cSeek),"Aviso")
		Return .f.
	Endif
Else	//TIPO DESCARGA
	nPerc:= XPercent (nQtd1,nQtd)
Endif

If nPerc < SA5->A5_TOLEDIF
	Return .t.
Endif

cMsg := "Inconsistencia de Dados." + chr(13)+chr(10)
cMsg += "A Margem aceitavel de " + Transform(SA5->A5_TOLEDIF,"@E 9999.99") + "% " + chr(13)+chr(10)
cMsg += "Entre a diferença da Quantidade Fiscal e a Apurada, foi ultrapassada."+ chr(13)+chr(10)
cMsg += "A diferença esta em " + Transform(nPerc,"@E 9999.99") + "%."

ApMsgAlert(cMsg,"Aviso")

Return .f.

//-------------------------------------------------------------------
/*/{Protheus.doc} XPercent
Calculo da Porcentagem.	

@author TOTVS
@since 09/02/2017
@version P12
/*/
//------------------------------------------------------------------- 
Static Function XPercent (nQ1,nQ2)

Local nPercent:= 0

nPercent := If (nQ1 >= nQ2,nQ1/nQ2,nQ2/nQ1)
nPercent := (nPercent - 1) *100

Return nPercent

//-------------------------------------------------------------------
/*/{Protheus.doc} TDC10TM
Gatilho utilizado no D3_TM para gravacao do D3_TPMOVAJ  

@author TOTVS
@since 09/02/2017
@version P12
/*/
//------------------------------------------------------------------- 
Function TDC10TM(cTM)

Local cTMT		:= ""
Local aArea		:= GetArea()
Local aAreaSF5	:= SF5->(GetArea())

dbSelectArea("SF5")
SF5->(dbSetOrder(1))

If SF5->(MsSeek(xFilial("SF5")+cTM))
	cTMT := SF5->F5_MOVTANQ
EndIf

RestArea(aAreaSF5)
RestArea(aArea)

Return cTMT


//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEE004()
Calculo Volume de Produto no Tanque com Base em Fatores

@author Totvs
@since 01/07/2002
@version 1.0
@return nVolume
/*/
//-------------------------------------------------------------------
Function DCLEE004()
Local oModel		:= FwModelActive()
Local oStruDH9	:= oModel:GetModel('DH9MASTER')
Local oStruD3D	:= oModel:GetModel('D3DDETAIL')
Local cAliasA		:= Alias()
Local cIndex		:= IndexOrd()
Local nRecno		:= Recno()	
Local nAltura		:= 0
Local nFator		:= 0
Local nVolume		:= 0
Local nSelo		:= 0
Local nConta		:= 0
Local cFaixa		:= AllTrim(SuperGetMV('MV_FXARQ',.F.,'I'))

If SuperGetMv("MV_DCLNEW",.F.,.F.)

	nSelo:= GETMV("MV_SELOINI")
	
	IF oStruDH9:GetValue('DH9_TIPO') == 'BO' .And. oStruDH9:GetValue('DH9_ALTI') <> 0
		
		dbSelectArea("DHG")
		DHG->(dbSetOrder(1))
		DHG->(dbSeek(xFilial() + oStruDH9:GetValue('DH9_TANQUE'),.F.))
		
		IF ReadVar() = "M->DH9_ALTI" .OR. ReadVar() = "M->DH9_FATCOI"
			nAltura := oStruDH9:GetValue('DH9_ALTI')
			nFator  := oStruDH9:GetValue('DH9_FATCOI')
		ELSE
			nAltura := oStruDH9:GetValue('DH9_ALTF')
			nFator  := oStruDH9:GetValue('DH9_FATCOF')
		ENDIF
		
		While !eof() .And. DHG->DHG_FILIAL == xFilial() .And. DHG->DHG_TANQUE == oStruDH9:GetValue('DH9_TANQUE')
			
			IF (nALTURA) >= DHG->DHG_CMINI .And. (nALTURA) <= DHG->DHG_CMFIM
				
				IF cFaixa == 'F'
				   nConta := DHG->DHG_CMFIM - nALTURA
				Else
				   nConta := nALTURA - DHG->DHG_CMINI
				Endif   
						
				If nConta > 0
					If nALTURA >= nSelo
						IF cFaixa == 'F'
						   nvolume := Int((DHG->DHG_ACUM - NoRound(DHG->DHG_FATOR * nConta) - DHG->DHG_LASTRO))
						ELSE
						   nvolume := Int((DHG->DHG_ACUM + NoRound(DHG->DHG_FATOR * nConta) - DHG->DHG_LASTRO))
						ENDIF   
					Else
						IF cFaixa == 'F'
						   nvolume := Int(DHG->DHG_ACUM - NoRound(DHG->DHG_FATOR * nConta))
						ELSE
						   nvolume := Int(DHG->DHG_ACUM + NoRound(DHG->DHG_FATOR * nConta))
						ENDIF   
					Endif
				else
					If nALTURA >= nSelo
						nVolume := Int(DHG->DHG_ACUM - DHG->DHG_LASTRO)
					Else
						nVolume := Int(DHG->DHG_ACUM)
					Endif
				endif
				Exit
			Endif
			DbSelectArea("DHG")
			DbSkip()
		Enddo
		nVolume := nVolume * nFator
	ELSE
		nVolume := oStruDH9:GetValue('DH9_QTDSOL') * oStruDH9:GetValue('DH9_FATCOF')
	ENDIF
	
	dbSelectArea(cAliasA)
	dbSetOrder(cIndex)
	dbGoTo(nRecno)
	
EndIf
	
Return(nVolume)

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEE005()
Calculo Volume de Produto no Tanque com Base em Fatores
Adaptação da função TDCEE002
@author Totvs
@since 01/07/2002
@version 1.0
@return nRet
/*/
//-------------------------------------------------------------------
Function DCLEE005()
Local oModel		:= FwModelActive()
Local oStruD3D	:= oModel:GetModel('D3DDETAIL')
Local oStruDH9	:= oModel:GetModel('DH9MASTER')
Local cAliasA		:= Alias()
Local cIndex		:= IndexOrd()
Local nRecno		:= Recno()
Local nVolume 	:= 0
Local nRet    	:= 0
Local aAreaSX3	:= SX3->(GetArea())
Local cPoLocal	:= ""
LocaL nI			:= 0 
Local nJ			:= 0 
Local nQtd		:= 0

If SuperGetMv("MV_DCLNEW",.F.,.F.)

	cPoLocal	:= "DH9_LOCA01"
	
	For nI:=1 to oStruD3D:Length()
		oStruD3D:GoLine( nI )
		
		If ReadVar() == "M->D3D_QTDLOC"
	       nQtd := 0
	       
	       For nJ := 1  to oStruD3D:Length()
				oStruD3D:GoLine( nJ )     
				nQtd += oStruD3D:GetValue('D3D_QTDLOC')
	       next nJ       
	      
			oStruD3D:GoLine( nI )
			nVolume := oStruDH9:GetValue('DH9_QTDSOL') - nQtd       
			nRet := oStruDH9:GetValue('DH9_QTDSOL')
       

	       If nVolume > 0
	          oStruD3D:SetValue('D3D_QTDLOC'):= nVolume
	       ElseIf nVolume < 0
	       
	          MsgAlert("Volume negativo Invalido")
	       EndIf
	       EXIT
	    EndIf
	Next nI
	
	dbSelectArea(cAliasA)
	dbSetOrder(cIndex)
	dbGoTo(nRecno)
	
	SX3->(RestArea(aAreaSX3))
	
EndIf
	
Return(nRet)



