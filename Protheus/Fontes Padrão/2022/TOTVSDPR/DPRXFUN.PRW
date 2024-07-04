#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'DPRXFUN.CH'

//------------------------------------------------------------------
/*/{Protheus.doc} DPRXError
Mensagem padrão para exibição de erros do SIGADPR

@param 	cRotina		Nome da rotina a ser exibida na janela
					1-Help não cadastrado com solução
					2-Alerta
					3-Help Cadastrado no ATUSX
					4-Help não cadastrado
@param 	cMsg		Mensagem de erro
@param  nTipo       Tipo de erro

@Return lRet	 	Exibe a mensagem e retorna .F.

@author Ana Carolina Tome Klock
@since 11/01/12
@version P12

/*/
//------------------------------------------------------------------
Function DPRXError( cRotina, cMsg, nTipo, cSoluc )
	Default cMsg	:= STR0022 //'Erro '
	Default cRotina	:= ProcName( 1 )
	Default nTipo	:= 1
	Default cSoluc	:= ''

	If nTipo == 1
		ShowHelpDlg( cRotina, { cMsg }, , { cSoluc } )
	ElseIf nTipo == 2
		MsgAlert( cMsg, cRotina )
	ElseIf nTipo == 3
		Help( ,, 'HELP', cMsg, , 1, 0)
	ElseIf nTipo != 0
		Help( ,, 'HELP', cRotina, cMsg, 1, 0)
	Endif
Return .F.
//-------------------------------------------------------------------
/*/{Protheus.doc} DPRIntegra
Verifica qual o tipo de Integração do DPR

@Return nRet	 	Retorna um número equivalente a integração
					0 = Não integrado
					1 = Protheus
					2 = Datasul

@author Ana Carolina Tome Klock
@since 11/01/12
@version P12
/*/
//-------------------------------------------------------------------
Function DPRIntegra()
Local nRet := GetMV('MV_INTDPR',.F.,0)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRXVLDPAR()
Realiza a validação de parâmetros da base

@param 		nParam		Informa o parâmetro a ser validado
						1 = MV_DPRESTR ou MV_DPROPER
						2 = MV_INTDPR
						3 = MV_DPRMOED
						4 = MV_DPRPROT

@parma 		lRet		Retorna se o campo está preenchido corretamente

@author Ana Carolina Tomé Klock
@since 12/07/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRXVLDPAR( nParam )
Local aValidaDPR := {}
Local aArea      := GetArea()
Local lRet 		 := .T.

Default nParam  := 1

cConteudo := "X6_CONTEUD"

If nParam == 1
	If Val(M->&cConteudo) < 1 .And. !Empty( M->&cConteudo)
		DPRXError( 'DPRXVLDPAR', 'DPRXFUN_PAR1', 3 ) // Parâmetro deve possuir valor maior que zero
		lRet := .F.
	EndIf
ElseIf nParam == 2
	If M->&cConteudo != '0' .And.  M->&cConteudo != '1' .And. M->&cConteudo != '2' .And. !Empty( M->&cConteudo)
		DPRXError( 'DPRXVLDPAR', 'DPRXFUN_PAR2', 3 ) // Parâmetro deve possuir valor entre 0 e 2
		lRet := .F.
	Else
	    If !Empty( M->&cConteudo)	
		   aValidaDPR := ValidaDPR( M->&cConteudo )
		   If !Empty(aValidaDPR[2])
			  DPRXError( 'DPRXINTEG', aValidaDPR[2], 3 )
			  lRet := .T.
		   EndIf
		EndIf   
	EndIf
ElseIf nParam == 3
	dbSelectArea('CZY')
	dbSetOrder(2)
	If !dbSeek( xFilial('CZY')+M->&cConteudo ) .And. !Empty( M->&cConteudo )
   		DPRXError( 'DPRXVLDPAR', 'DPRXFUN_PAR3', 3 ) // Moeda deve estar previamente cadastrada
		lRet := .F.
	EndIf
ElseIf nParam == 4
	dbSelectArea('CZ3')
	dbSetOrder(1)
	If !dbSeek( xFilial('CZ3')+M->&cConteudo ) .And. !Empty( M->&cConteudo )
   		DPRXError( 'DPRXVLDPAR', 'DPRXFUN_PAR4', 3 ) // Produto deve estar previamente cadastrado
		lRet := .F.
	EndIf
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRXVALATR
Valida o atributo informado conforme parâmetros recebidos

@param 	nCampo		Tipo do campo a ser validado (1=Caracter, 2=Numérico, 3=Data, 4=Lógico)
@param 	cAlias		Alias da Tabela a ser usada
@param	nValida		Identifica o tipo de validação (1=Edição Picture, 2=Modo Edição)

@Return xRet	 	Retorna a Picture para o campo (se nValida == 1) ou True/False (se nValida == 2)

@author Ana Carolina Tome Klock
@since 11/06/12
@version P12
/*/
//-------------------------------------------------------------------
Function DPRXVALATR( nCampo, cAlias, nValida )
Local xRet  := If (nValida == 1, "" , .T.)
Local cDSAB := ""
Local nI    := 0
Local nTam	:= 0
Default nCampo := 0
Default lAutoMacao := .F.

IF !lAutoMacao
	cDSAB := FwFldGet( cAlias + '_DSAB' )
	nTam  := TAMSX3(cAlias + '_VLAB2')[1]
ENDIF

dbSelectArea( 'DGB' )
dbSetOrder(1)
If dbSeek( xFilial( 'DGB' )+AllTrim(cDSAB) )
	If nValida == 1 .And. nCampo == 0
		xRet := "@E "
		For nI := 1 to nTam-DGB->DGB_NRFM-1
			xRet += '9'
		Next
		If DGB->DGB_NRFM > 0
			xRet += '.'
			For nI := 1 to DGB->DGB_NRFM
				xRet += '9'
			Next
		EndIf
	ElseIf nValida == 2
		If DGB->DGB_TPAB != cValToChar(nCampo)
			xRet := .F.
		EndIf
	EndIf
EndIf

Return xRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DPRXFIL
Realiza o filtro na Consulta Padrão especificada

@param 	cSXB		Nome da Consulta Padrão

@return lRet	 	Retorna .T. ou .F. conforme filtro

@author Ana Carolina Tome Klock
@since 16/03/12
@version P12
/*/
//-------------------------------------------------------------------
Function DPRXFIL( cSXB )
Local lRet := .F.

// Versão
If cSXB == 'DG0002'
	// Telas que contem o campo DG1_CDMTDV no Model
	// DPRA300 - Versão Produto ; DPRA310 - Estrutura
	If IsInCallStack('DPRA300') .Or. IsInCallStack('DPRA310')
		If AllTrim(DG0->DG0_CDACDV) == AllTrim(FwFldGet('DG1_CDMTDV'))
			lRet := .T.
		EndIf
	EndIf
// Atividade
ElseIf cSXB == 'DG9001'
	// Telas que contem os campos DG0_CDACDV e DG0_NRVRAC no Model
	// DPRA300 - Versão Produto ; DPRA322 - Rede Pert
	If IsInCallStack('DPRA300') .Or. IsInCallStack('DPRA322')
		If AllTrim(DG9->DG9_CDACDV) == AllTrim(FwFldGet('DG0_CDACDV')) .And. AllTrim(DG9->DG9_NRVRAC) == AllTrim(FwFldGet('DG0_NRVRAC'))
			lRet := .T.
		EndIf
	EndIf
// Critério
ElseIf cSXB == 'DGF001'
	// Telas que contem o campo DGA_CDACVD no Model
	// DPRA101 - Preço Produto Concorrente
	If IsInCallStack('DPRA101')
		If AllTrim(DGF->DGF_CDACDV) == AllTrim(FwFldGet('DGA_CDACDV'))
			lRet := .T.
		EndIf

	// Telas que contem o campo DG0_CDACDV no Model
	// DPRA300 - Versão Produto; DPRA100 - Produto Desenvolvido
	ElseIf IsInCallStack('DPRA300') .Or. IsInCallStack('DPRA100')
		If AllTrim(DGF->DGF_CDACDV) == AllTrim(FwFldGet('DG0_CDACDV'))
			lRet := .T.
		EndIf
	EndIf
// Atributo
ElseIf cSXB == 'DGB001'
	// Telas que contem a tabela DG3
	// DPRA100 - Produto Desenvolvido
	If IsInCallStack('DPRA100')
		If AllTrim(DGB->DGB_CDTB) == 'DG3'
			lRet := .T.
		EndIf

	// Telas que contem a tabela DG0
	// DPRA300 - Versão Produto
	ElseIf IsInCallStack('DPRA300')
   		If AllTrim(DGB->DGB_CDTB) == 'DG0'
			lRet := .T.
		EndIf
	EndIf
EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DPRXTRIG
Realiza uma trigger especifica para cada alias

@param 	cAlias		Nome do Alias da Trigger

@return lRet	 	Retorna se ocorreu algum erro (.F.) ou não (.T.)

@author Ana Carolina Tome Klock
@since 25/05/12
@version P12
/*/
//-------------------------------------------------------------------
Function DPRXTRIG( cAlias ) //Automatizado
Local nQTUT  := 0
Local oModel := FWModelActive()

// Carregar valor de quantidade usada
If cAlias == 'DG1' .Or. cAlias == 'DG4'
	If oModel:GetModel( FWFindID( cAlias+'_QTMT') ):GetQtdLine() > 0
		If DPRIntegra() == 1
			nQTUT := (FwFldGet( cAlias+'_QTMT' ) / FwFldGet( cAlias+'_QTAC' ) ) * (1 + (FwFldGet( cAlias+'_VLPNLS' )/100) )
		Else
			If FwFldGet( cAlias+'_QTAC' ) != 0
				nQTUT := FwFldGet(cAlias+'_QTMT')/FwFldGet(cAlias+'_QTAC')
			EndIf
		EndIf
	Else
		nQTUT := 1
	EndIf
ElseIf cAlias == '340'
	If DPRIntegra() == 1
		nQTUT := (aDG1[1])->DG1_QTMT / (aDG1[1])->DG1_QTAC * (1 + ((aDG1[1])->DG1_VLPNLS/100) )
	Else
		If aDG1[nI][13] != 0
			nQTUT := (aDG1[1])->DG1_QTMT/(aDG1[1])->DG1_QTAC
		EndIf
	EndIf
ElseIf cAlias == 'DG3'
	If	DPRIntegra() == 2
		oModel:LoadValue('DG3MASTER', 'DG3_CDUNDE', POSICIONE("CY6",1,xFilial("CY6")+oModel:GetValue("DG3MASTER", 'DG3_CDFA'  ),"CY6_CDUN"  ) )
   		oModel:LoadValue('DG3MASTER', 'DG3_DSUNDE', POSICIONE("CZ9",1,xFilial("CZ9")+oModel:GetValue("DG3MASTER", 'DG3_CDUNDE'),"CZ9_DSUN"  ) )
   		oModel:LoadValue('DG3MASTER', 'DG3_CDDPPA', POSICIONE("CY6",1,xFilial("CY6")+oModel:GetValue("DG3MASTER", 'DG3_CDFA'  ),"CY6_CDDPPA") )
   		oModel:LoadValue('DG3MASTER', 'DG3_DSDPPA', POSICIONE("CZX",1,xFilial("CZX")+oModel:GetValue("DG3MASTER", 'DG3_CDDPPA'),"CZX_DSDP"	) )
	EndIf
	Return POSICIONE("CY6",1,xFilial("CY6")+oModel:GetValue("DG3MASTER", 'DG3_CDFA'),"CY6_DSFA")
EndIf

Return nQTUT

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRCanEdit
Valida determinados valores para:
* Carregar os valores dos campos relacionados
* Bloquear edição de campos

@param 		cCode		Código a ser retornado
@param			nType		Define o tipo de gatilho editável
							1 = Produto Destino    			(DG3)
							2 = Unidade de Medida  			(DG3)
							3 = Unidade de Medida Destino 	(DG3)
							4 = Unidade de Medida 2        	(DG3)
							5 = CNPJ Concorrente			(DGA)
							6 = Tipo Atributo				(DGB)
@return		xRet		Retorno da função

@author Ana Carolina Tome Klock
@since 29/08/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRCanEdit( cCode, nType )
Local oModel	:= FwModelActive()
Local oModelDG3 := NIL
Local oModelDGA := NIL
Local xRet		:= .T.
Local nDPRA100A := 1
Default lAutoMacao := .F.

IF !lAutoMacao
	oModelDG3 := oModel:GetModel( 'DG3MASTER' )
	oModelDGA := oModel:GetModel( 'DGADETAIL' )
ENDIF

Pergunte('DPRA100A',.F.)

nDPRA100A := IF(MV_PAR01==nil,1,MV_PAR01)

// Produto Destino
If nType == 1
	// Se existir o Produto Destino
	dbSelectArea('CZ3')
	If dbSeek( xFilial('CZ3')+cCode )
		oModelDG3:LoadValue( 'DG3_DSACDE', CZ3->CZ3_DSAC   )
		oModelDG3:LoadValue( 'DG3_CDUNDE', CZ3->CZ3_CDUN   )
		oModelDG3:LoadValue( 'DG3_DSUNDE', Posicione('CZ9', 1, xFilial('CZ9')+CZ3->CZ3_CDUN, 'CZ9_DSUN'   ) )
		oModelDG3:LoadValue( 'DG3_CDGE'  , CZ3->CZ3_CDGR   )
		oModelDG3:LoadValue( 'DG3_DSGE'  , Posicione('CY7', 1, xFilial('CY7')+CZ3->CZ3_CDGR , 'CY7_DSGE'  ) )
		oModelDG3:LoadValue( 'DG3_CDFA'  , CZ3->CZ3_CDFA   )
		oModelDG3:LoadValue( 'DG3_DSFA'  , Posicione('CY6', 1, xFilial('CY6')+CZ3->CZ3_CDFA , 'CY6_DSFA'  ) )
		oModelDG3:LoadValue( 'DG3_CDDPPA', CZ3->CZ3_CDDP   )
		oModelDG3:LoadValue( 'DG3_DSDPPA', Posicione('CZX', 1, xFilial('CZX')+CZ3->CZ3_CDDP , 'CZX_DSDP'  ) )
		oModelDG3:LoadValue( 'DG3_CDFACM', CZ3->CZ3_CDFACM )
		oModelDG3:LoadValue( 'DG3_CDES'	 , CZ3->CZ3_CDES   )
		If DPRIntegra() == 1
			oModelDG3:LoadValue( 'DG3_CDUN2' , Posicione('SB1', 1, xFilial('SB1')+cCode			, 'B1_SEGUM'  ) )
			oModelDG3:LoadValue( 'DG3_VLPNUN' , Posicione('SB1', 1, xFilial('SB1')+cCode			, 'B1_CONV'  ) )
			If SB1->B1_TIPCONV == 'D'
				oModelDG3:LoadValue( 'DG3_TPPNUN' , '2' )
			Else
				oModelDG3:LoadValue( 'DG3_TPPNUN' , '1' )
			EndIf
			oModelDG3:LoadValue( 'DG3_DSUN2' , Posicione('CZ9', 1, xFilial('CZ9')+Posicione('SB1', 1, xFilial('SB1')+cCode, 'B1_SEGUM'), 'CZ9_DSUN'  ) )
		EndIf
	Elseif nDPRA100A == 1
	   	oModelDG3:ClearField('DG3_DSACDE')
		oModelDG3:ClearField('DG3_CDUNDE')
		oModelDG3:ClearField('DG3_DSUNDE')
		If DPRIntegra() == 1
			oModelDG3:ClearField('DG3_CDUN2' )
			oModelDG3:ClearField('DG3_DSUN2' )
		EndIf
		oModelDG3:ClearField('DG3_CDGE'  )
		oModelDG3:ClearField('DG3_DSGE'  )
		oModelDG3:ClearField('DG3_CDFA'  )
		oModelDG3:ClearField('DG3_DSFA'  )
		oModelDG3:ClearField('DG3_CDDPPA')
		oModelDG3:ClearField('DG3_DSDPPA')
		oModelDG3:ClearField('DG3_CDFACM')
		oModelDG3:ClearField('DG3_CDES'  )
	Endif

// Unidade de Medida
ElseIf nType == 2
	oModelDG3:LoadValue( 'DG3_VLPNUN' , 1 )

// Unidade de Medida Destino
ElseIf nType == 3
	If cCode[1] == cCode[2]
		oModelDG3:LoadValue( 'DG3_VLPNUN' , 1 )
	EndIF
	If cCode[2] == cCode[3]
		oModelDG3:LoadValue( 'DG3_VLPN2' , 1 )
	EndIf
	xRet := cCode[2]

// Unidade de Medida 2
ElseIf nType == 4
	oModelDG3:LoadValue( 'DG3_VLPN2'  , 1 )

// CNPJ Concorrente
ElseIf nType == 5
	// Se estiver no Produto Desenvolvido
	If IsInCallStack('DPRA100')
		If Empty( oModelDGA:GetValue('DGA_NRSQ') ) .And. DPRXVldMdl( oModelDGA )
   			DPRXSetVal( oModelDGA, 'DGA_NRSQ' )
   		EndIf
   		If ExistCpo('DGA', oModelDG3:GetValue('DG3_CDACDV')+oModelDGA:GetValue('DGA_NRSQ'))
   			xRet := .F.
   		Else
   			xRet := .T.
   		EndIf
    // Se estiver no Preço do Produto Concorrente
   	ElseIf oModel:GetOperation() == 3
   		xRet := .T.
   	Else
   		xRet := .F.
   	EndIf

// Tipo do Atributo
ElseIf nType == 6
	dbSelectArea( 'DGG' )
	dbSetOrder(2)
	If dbSeek( xFilial('DGG') + cCode )
		xRet := .F.
	Else
		dbSelectArea( 'DGK' )
		dbSetOrder(2)
		If dbSeek( xFilial('DGK') + cCode )
			xRet := .F.
		Else
			xRet := .T.
		EndIf
	EndIf
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRXVldHou
Realiza a validação do horário informado

@param 	cHour		(Obrigatório) Verifica se a hora está no formato 'HH:MM:SS'

@Return lRet	 	Retorna se a hora está valida (.T.) ou não (.F.)

@author Ana Carolina Tomé Klock
@since 26/04/12
@version 12
/*/
//-------------------------------------------------------------------
Function DPRXVldHou( cHour )
Local lRet  := .T.

// Verifica se o tamanho é menor que 8
If Len( AllTrim(cHour) ) < 8 .Or. cHour == '  :  :  '
	lRet := .F.
Else
	// Se o valor para horas for maior que 23
	If Val( SubStr(cHour, 1, 2)) > 23
		lRet := .F.
	// Se o valor para minutos for maior que 59
	ElseIf Val( SubStr(cHour, 4, 2)) > 59
   		lRet := .F.
 	// Se o valor para segundos for maior que 59
	ElseIf Val( SubStr(cHour, 7, 2)) > 59
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRXSetVal
Cria um código sequencial conforme campo do modelo

@param 		oModel	 		Modelo de dados onde se encontra o campo
@param 		cField	   		Nome do campo que é sequencial

@return 	lRet	  		Caso consiga setar o valor, retorna .T.

@author Ana Carolina Tome Klock
@since 24/04/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRXSetVal( oModel, cField ) //Automatizada
Local lRet

lRet := oModel:LoadValue(cField, DPRXCOUNT( TamSX3(cField)[1], Val(FwFldGet(cField, oModel:GetLine()-1 )) ) )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRXVldMdl
Valida se a linha do Modelo informado está vazia

@param 		oModel	 		Modelo de dados a ser validado

@return 	lRet	  		Caso esteja preenchida, retorna .T.

@author Ana Carolina Tome Klock
@since 24/04/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRXVldMdl( oModel ) //Automatizada
Local lRet := .F.
Local nI, nMax := len(oModel:aHeader)

For nI := 1 to nMax
	If oModel:GetModel():GetModel(oModel:cID):IsFieldUpdated(oModel:aHeader[nI][2]) .Or. !Empty(oModel:GetModel():aErrorMessage[8])
		lRet := .T.
		Exit
	EndIf
Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRXCOUNT
Cria um código sequencial conforme tamanho passado

@param 		nTamanho  		Tamanho do campo a ser criado
@param 		nCount	   		Número que será sequencial

@return 	cSequence  		Caracter sequencial com tamanho especificado

@author Ana Carolina Tome Klock
@since 01/02/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRXCOUNT( nTamanho, nCount ) //Automatizada
Local cSequence, nInc := 1
Default nTamanho := 5
Default nCount   := 0

If IsInCallStack('DPRA300DG1')
  	nInc := SuperGetMV('MV_DPRESTR',.F.,1)
  	nTamanho  := nTamanho - Len( AllTrim( Str( nCount + nInc ) ) )
	cSequence := Replicate('0', nTamanho) + AllTrim( Str( nCount + nInc ) )
ElseIf IsInCallStack('DPRA300DG9')
	nInc := SuperGetMV('MV_DPROPER',.F.,1)
	nTamanho  := nTamanho - Len( AllTrim( Str( nCount + nInc ) ) )
	cSequence := Replicate('0', nTamanho) + AllTrim( Str( nCount + nInc ) )
Else
	nTamanho  := nTamanho - Len( AllTrim( Str( nCount + 1 ) ) )
	cSequence := Replicate('0', nTamanho) + AllTrim( Str( nCount + 1 ) )
EndIf

Return cSequence

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DPRFORMULA
Cria uma tela para montar as fórmulas

@param nTipo Tipo de fórmula que será tratada. 1=Produto, 2=Versão

@author Ana Carolina Tome Klock
@since 06/09/2012
@version P12
/*///------------------------------------------------------------------------------------------------
Function DPRFORMULA(nTipo)
Local cConst    := { SPACE(20), SPACE(20), SPACE(20) }
Local aFormula  := {}
Local oForm	    := { , , }
Local lContinua := .T.
Local aField 	:= {{STR0006 + ' [DG0_VLPJDV]', '[DG0_VLPJDV]'}, ; // Valor Projeto Desenvolvimento
					{STR0007 + ' [DG0_VLPJ]'  , '[DG0_VLPJ]'  }, ; // Valor Projeto
					{STR0008 + ' [DG0_VLCSPO]', '[DG0_VLCSPO]'}, ; // Valor Custo Fabricação
					{STR0009 + ' [DG0_VLCS]'  , '[DG0_VLCS]'  }, ; // Valor Custos Diversos
					{STR0010 + ' [DG0_VLRS]'  , '[DG0_VLRS]'  }, ; // Valor Retorno Esperado
					{STR0011 + ' [DG0_VLPR]'  , '[DG0_VLPR]'  }, ; // Valor Preço-Teto
					{STR0012 + ' [DG0_VLUT]'  , '[DG0_VLUT]'  }}  // Valor Investimento
Local nI
Default nTipo := 1
Default lAutoMacao := .F.

if nTipo == 2
	aFormula  := { DG3->DG3_DSFOPJ, DG3->DG3_DSFOUT, DG3->DG3_DSFOCS }
Else
	aFormula  := { DG0->DG0_DSFOPJ, DG0->DG0_DSFOUT, DG0->DG0_DSFOCS }
	
	If Val(DG0->DG0_TPST) > 5
		lContinua := .F.
	Endif
Endif
	
// Se a versão não estiver liberada
if lContinua
	IF !lAutoMacao
		Define MsDialog	oDlgMessage Title STR0023 FROM 00,00 To 350,500 Pixel // 'Montar Fórmula'

		// Folder
		aTFolder   := { STR0013, STR0014, STR0015 } // Projeto ## Investimento ## Custos Diversos
		oTFolder   := TFolder():New( 30, 0, aTFolder, { STR0013, STR0014, STR0015 }, oDlgMessage, , RGB(225,225,225), , .T., , 270, 150 ) // Projeto ## Investimento ## Custos Diversos

		oBrwCampos := TWBrowse():New( 60, 140, 100, 80, , { STR0016 }, {150}, oDlgMessage,,,,,{||},,,,,,,.T.,,.T.) // 'Campos Disponíveis'
		oBrwCampos:lHScroll := .T.
		oBrwCampos:SetArray(aField)
		oBrwCampos:bLine := { || { If(Len(aField) > 0,aField[oBrwCampos:nAt,1], ) } }

		For nI := 1 to 3
			oForm[nI] := TSimpleEditor():New( 10, 10, oTFolder:aDialogs[nI], 100, 100, aFormula[nI], .T., , , .T. )
			oForm[nI]:Load( aFormula[nI] )
			oForm[nI]:TextFormat(2)
			TButton():New( 12,  120,  '<', oTFolder:aDialogs[nI], {|| oForm[oTFolder:nOption]:Load( AllTrim( oForm[oTFolder:nOption]:RetText() ) + " " + aField[oBrwCampos:nAt][2]) }, 10,10,,,,.T.)
			TButton():New( 27,  120,  '+', oTFolder:aDialogs[nI], {|| oForm[oTFolder:nOption]:Load( AllTrim( oForm[oTFolder:nOption]:RetText() ) + " + ") }, 10,10,,,,.T.)
			TButton():New( 42,  120,  '-', oTFolder:aDialogs[nI], {|| oForm[oTFolder:nOption]:Load( AllTrim( oForm[oTFolder:nOption]:RetText() ) + " - ") }, 10,10,,,,.T.)
			TButton():New( 57,  120,  '*', oTFolder:aDialogs[nI], {|| oForm[oTFolder:nOption]:Load( AllTrim( oForm[oTFolder:nOption]:RetText() ) + " * ") }, 10,10,,,,.T.)
			TButton():New( 72,  120,  '/', oTFolder:aDialogs[nI], {|| oForm[oTFolder:nOption]:Load( AllTrim( oForm[oTFolder:nOption]:RetText() ) + " / ") }, 10,10,,,,.T.)
			TButton():New( 87,  120,  '(', oTFolder:aDialogs[nI], {|| oForm[oTFolder:nOption]:Load( AllTrim( oForm[oTFolder:nOption]:RetText() ) + " ( ") }, 10,10,,,,.T.)
			TButton():New( 102, 120,  ')', oTFolder:aDialogs[nI], {|| oForm[oTFolder:nOption]:Load( AllTrim( oForm[oTFolder:nOption]:RetText() ) + " ) ") }, 10,10,,,,.T.)
			TGet():New( 95, 140,{ |u| If( Pcount()>0, cConst[oTFolder:nOption] := cValToChar(Val(StrTran ( u, ',', '.'))), cConst[oTFolder:nOption] ) },oTFolder:aDialogs[nI], 100, 010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cConst[oTFolder:nOption],,,,.T. )
			TButton():New( 110, 140,  STR0017, oTFolder:aDialogs[nI], {|| oForm[oTFolder:nOption]:Load( AllTrim( oForm[oTFolder:nOption]:RetText() ) + " " + cConst[oTFolder:nOption], cConst[oTFolder:nOption] := SPACE(20) ) }, 70,10,,,,.T.) // Adicionar constante
			TButton():New( 110, 210,  STR0018, oTFolder:aDialogs[nI], {|| oForm[oTFolder:nOption]:Load( Substr(AllTrim(oForm[oTFolder:nOption]:RetText()), 1, RAT(" ", AllTrim(oForm[oTFolder:nOption]:RetText())) ) ) }, 30,10,,,,.T.)   // Desfazer
		Next

		Activate MsDialog oDlgMessage Centered On Init EnchoiceBar( oDlgMessage, { || If (DPRVLDFORM( { oForm[1]:RetText(), oForm[2]:RetText(), oForm[3]:RetText() }, nTipo ), oDlgMessage:End(), NIL) }, { || oDlgMessage:End() } )
	ENDIF
Else
	DPRXError( 'DPRXFUN', 'DPRXFUN_FORM', 3 )    // Não é possivel alterar as fórmulas de uma versão que foi liberada.
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} valParente
Função que valida se existem inconsistencias com os parênteses na fórmula.

@param cFormula 	Fórmula que será validada.
@return

@author 	Lucas Konrad França
@since 		09/10/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function valParente(cFormula)
	Local nI    := 0
	Local nCont := 0

	For nI := 1 To Len(AllTrim(cFormula))
		//Valida se existem parênteses abertos/fechados incorretamente
		If SubStr(cFormula,nI,1) == "("
			nCont++
			If nI < Len(cFormula)
				If SubStr(cFormula,nI+1,1) = ")"
					Return .F.
				END IF
				If SubStr(cFormula,nI+1,1) $ "/*+.=^"
					Return .F.
				EndIf
			EndIf
		EndIf
		If SubStr(cFormula,nI,1) == ")"
			nCont--
			If nCont < 0
				Return .F.
			EndIf
			If SubStr(cFormula,nI+1,1) == "("
				Return .F.
			EndIf
			If SubStr(cFormula,nI-1,1) $ "/*+.=^-"
				Return .F.
			EndIf
		EndIf
	Next

	If nCont > 0
		Return .F.
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} validForm
Função de validação da fórmula.

@param cFormula 	Fórmula que será validada.
@param cRelac		Relacionador do atributo.
@return

@author 	Lucas Konrad França
@since 		09/10/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function validForm(cFormula)
	Local nI      := 0
	Local nI2     := 0
	Local nI3     := 0
	Local nCount  := 0
	Local nPosIni := 0

	cFormula := AllTrim(cFormula)
	If !(valParente(cFormula))
		Return .F.
	EndIf
	If SubStr(cFormula,1,1) $ "/*+.=^"
		Return .F.
	EndIf
	If SubStr(cFormula,1,1) == "-"
		cFormula := SubStr(cFormula,2)
	EndIf
	For nI := 1 To Len(cFormula)
		If SubStr(cFormula,nI,1) $ "/*+.=^-"
			If SubStr(cFormula,nI+1,1) $ "/*+.=^-" //Verifica se colocou operadores repetidos
				Return .F.
			EndIf
		EndIf
		If SubStr(cFormula,nI,1) == "("
			For nI2 := nI+1 To Len(cFormula)
				If SubStr(cFormula,nI2,1) == "("
					nI := nI2
					Loop
				EndIf
				If SubStr(cFormula,nI2,1) == ")"
					If !(validForm(SubStr(cFormula,nI+1,(nI2-nI)-1)))
						Return .F.
					EndIf
					cFormula := AllTrim(SubStr(cFormula,1,nI-1) + SubStr(cFormula,nI2+1))
					If SubStr(cFormula,Len(cFormula),1) $ "/*-+"
						cFormula := SubStr(cFormula,1,(Len(cFormula)-1))
					EndIf
					nI := 1
					Exit
				EndIf
			Next
		EndIf

		If IsAlpha(SubStr(cFormula,nI))
			nCount := 0
			For nI2 := nI To Len(cFormula)
				If SubStr(cFormula, nI2+1,1) == "("
					Return .F.
				EndIf
				nCount++
				If SubStr(cFormula, nI2+1,1) $ "/*+.=^-"
					Exit
				EndIf
			Next
			nPosIni := 1
			For nI3 := nI-1 To 1 Step -1
				If SubStr(cFormula, nI3,1) $ "0123456789"
					nCount++
				EndIf
				If SubStr(cFormula, nI3,1) $ "/*+.=^-("
					nPosIni := nI3 + 1
					Exit
				EndIf
			Next

			nI := nI2
		EndIf
	Next

	If SubStr(cFormula,Len(cFormula),1) $ "/*+.=^-("
		Return .F.
	EndIf
Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DPRVLDFORM
Valida as fórmulas montadas e salva na versão.

@param		aFormula		Array contendo as três fórmulas criadas
@return 	lRet			Retorna se as fórmulas estão ok e foram salvas

@author Ana Carolina Tome Klock
@since 28/09/2012
@version P12
/*///------------------------------------------------------------------------------------------------
Static Function DPRVLDFORM( aFormula, nTipo )
	Local nI, nJ
	Local lRet		:= .T.
	Local cValid	:= ''
	Local aItens	:= {}
	Local cCDACDV	:= ''
	//Indica se o valor e o valor anterior são numéricos
	Local lIsNum
	Local lIsNumAnt

	// Transforma strings para número e monta fórmula a ser validada
	For nI := 1 to len(aFormula)
		cValid := ''
		aItens := StrTokArr( aFormula[nI], " " ) 
		lIsNum		:= .F.
		lIsNumAnt	:= .F.
		For nJ := 1 to len(aItens)
			lIsNumAnt := lIsNum
			//Verifica se o valor é um campo('[') ou um decimal
			If Substr( aItens[nJ], 1, 1 ) == '[' .Or. RAT( '.', aItens[nJ]) != 0
				aItens[nJ] := '1'
			EndIf

			//Verifica se o valor atual é um númerico
			lIsNum := (aItens[nJ] == "0" .Or. Val(aItens[nJ]) <> 0)

			//Valida se foram informados dois numéricos seguidos
			If lIsNum .And. lIsNumAnt
				DPRXError(if(nTipo==2,"DPRA100","DPRA300"), STR0019, ,STR0024 )// Expressão informada está invalida ## Verifique inconsistencia na fórmula
				Return .F.
			EndIf

			cValid += aItens[nJ]
		Next
		// Valida a fórmula
		If !Empty(cValid)
			lRet := validForm(cValid)
			If !lRet
				DPRXError(if(nTipo==2,"DPRA100","DPRA300"), STR0019, ,STR0024 )// Expressão informada está invalida ## Verifique inconsistencia na fórmula
				Return .F.
			EndIf
		EndIf
	Next

	// Salva as fórmulas
	If lRet

		if nTipo == 2

			IF DG3->DG3_DSFOPJ != aFormula[1] .OR.;
			   DG3->DG3_DSFOUT != aFormula[2] .OR.;
			   DG3->DG3_DSFOCS != aFormula[3]

				oModelDG3 := FWLoadModel( 'DPRA100' )
				oModelDG3:SetOperation( 4 )
				oModelDG3:Activate()   
				oModelDG3:SetValue( 'DG3MASTER', 'DG3_DSFOPJ', aFormula[1] )
				oModelDG3:SetValue( 'DG3MASTER', 'DG3_DSFOUT', aFormula[2] )  
				oModelDG3:SetValue( 'DG3MASTER', 'DG3_DSFOCS', aFormula[3] ) 
				If oModelDG3:VldData()
					oModelDG3:CommitData()
				Else
					aErro := oModelDG3:GetErrorMessage()
					DPRXError('DPRA100', aErro[6])
					lRet := .F.
				EndIf
				oModelDG3:DeActivate()
				
				dbSelectArea('DG0')
				DG0->(dbSetOrder(3))
				if DG0->(dbSeek(xFilial('DG0')+DG3->DG3_CDACDV+'1'))
						   
					if MsgYesNo(STR0025,'DPRXFUN') // Deseja propagar a(s) fórmula(s) alterada(s) à(s) versão(ões) em Aberto?
					
						cCDACDV := DG3->DG3_CDACDV
					
						While DG0->(!EOF()) .AND. DG0->DG0_CDACDV == cCDACDV .AND. DG0->DG0_TPST == '1'
				
							oModelDG0 := FWLoadModel( 'DPRA300' )
							oModelDG0:SetOperation( 4 )
							oModelDG0:Activate()   
							oModelDG0:SetValue( 'DG0MASTER', 'DG0_DSFOPJ', aFormula[1] )
							oModelDG0:SetValue( 'DG0MASTER', 'DG0_DSFOUT', aFormula[2] )  
							oModelDG0:SetValue( 'DG0MASTER', 'DG0_DSFOCS', aFormula[3] ) 
							If oModelDG0:VldData()
								oModelDG0:CommitData()
							Else
								aErro := oModelDG0:GetErrorMessage()
								DPRXError('DPRA300', aErro[6])
								lRet := .F.
							EndIf
							oModelDG0:DeActivate()
							
							DG0->(dbSkip())
						End
					Endif				
				Endif
			Endif
		Else
			oModelDG0 := FWLoadModel( 'DPRA300' )
			oModelDG0:SetOperation( 4 )
			oModelDG0:Activate()   
			oModelDG0:SetValue( 'DG0MASTER', 'DG0_DSFOPJ', aFormula[1] )
			oModelDG0:SetValue( 'DG0MASTER', 'DG0_DSFOUT', aFormula[2] )  
			oModelDG0:SetValue( 'DG0MASTER', 'DG0_DSFOCS', aFormula[3] ) 
			If oModelDG0:VldData()
				oModelDG0:CommitData()
			Else
				aErro := oModelDG0:GetErrorMessage()
				DPRXError('DPRA300', aErro[6])
				lRet := .F.
			EndIf
			oModelDG0:DeActivate()
		Endif
	EndIf
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} DPRLoad()
Valida se o modulo SIGADPR esta sendo executado a partir do release 8.

@author Samantha Preima
@since 22/02/2013
@version 1.0
/*/
//--------------------------------------------------------------------
Function DPRLoad()
	If !AliasInDic("DG0")
		Final(STR0021)  // Este módulo está disponível somente a partir do Release 8.
	EndIf
Return
//--------------------------------------------------------------------
//Valida se o release está atualizada para utilizar o procedimento/função
//--------------------------------------------------------------------
Function DPRVldR( nVersao, cRelease )
	//Se a versão for maior que a versão ou maior que o release da versão
	If !(Val(GetVersao(.F.)) > nVersao .OR. (GetRpoRelease() >= cRelease .AND. Val(GetVersao(.F.)) == nVersao))
		Final( STR0026 + " " + AllTrim(Str(nVersao)) + " " + STR0027 + " " + AllTrim(cRelease) )	//Este módulo está disponível somente a partir da versão x release x
	EndIf
Return
//--------------------------------------------------------------------
/*/{Protheus.doc} DPRConvert()  
Converte valores de campo conforme campo.

@author 	Samantha Preima
@since 		27/06/2013
@version 	P12
/*/
//--------------------------------------------------------------------
Function DPRConvert(nValor, cCampo, cCampoOrig)
Local aRet		:= TamSX3(cCampo)
Local aRetOrg	:= TamSX3(cCampoOrig)
Local nInt		:= Int(nValor)
Local nDec		:= nValor - nInt

If Subs( Transform(nValor, x3Picture(cCampo)), 1, 1 ) == '*'
	If aRet[1] < aRetOrg[1]
		nInt := alltrim(STR(nInt))
		nInt := Val(Substr(nInt,len(nInt) - ((aRetOrg[1] - (aRetOrg[2] + 1)) - (aRet[1] - (aRet[2] + 1)))+1,aRet[1]))
		nValor := nInt + nDec
	EndIf
	If aRet[2] < aRetOrg[2]
		nValor := NOROUND(nValor, aRet[2])
	EndIf
EndIf
Return nValor
//--------------------------------------------------------------------
/*/{Protheus.doc} DPRFicha()
Retorna se o módulo está integrado com PCP e se utiliza ficha técnica

nTipo  1=Verifica MV_DPRFICH, 2=Verifica MV_PCPFTEC

@author 	Samantha Preima
@since 		29/10/2013
@version 	P12
/*/
//--------------------------------------------------------------------
Function DPRFicha(nTipo) //Automatizada
Local lRet := .F.

Default nTipo := 1

if GetMV('MV_INTDPR',.F.,0) == 1

	if nTipo == 1 .AND. GetMV('MV_DPRFICH',.F.,.F.) == .T.
		lRet := .T.
	Endif

	if nTipo == 2 .AND. GetMV('MV_PCPFTEC',.F.,'N') == 'S'
		lRet := .T.
	Endif
Endif

Return lRet
