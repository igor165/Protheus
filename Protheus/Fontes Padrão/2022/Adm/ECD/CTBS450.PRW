#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CTBS450.CH'

//Compatibilização de fontes 30/05/2018


Static aFill_Mes := {}
//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS450
Cadastro do Bloco V=ECF=DEREX

@author TOTVS
@since 03/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------
Function CTBS450()
Local oBrowse

oBrowse := FWmBrowse():New()

oBrowse:SetAlias( 'CSU' )

oBrowse:SetDescription( STR0001 ) //

oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 03/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.CTBS450' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.CTBS450' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0010 Action 'VIEWDEF.CTBS450' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0011 Action 'VIEWDEF.CTBS450' OPERATION 5 ACCESS 0 //'Excluir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 03/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCSU := FWFormStruct(1,'CSU')
Local oStruCVU := FWFormStruct(1,'CVU')
Local oStruCVV := FWFormStruct(1,'CVV')
Local oStruCVW := FWFormStruct(1,'CVW')
Local oModel

oModel := MPFormModel():New('CTBS450')

oModel:AddFields('CSUMASTER',,oStruCSU, /*<bPre >*/, { |oFieldModel| DETAIL_CVU(oFieldModel) .And. CVU_TDOK() }/*<bPost >*/, /*<bLoad >*/)

oModel:AddGrid('CVUDETAIL','CSUMASTER',oStruCVU, /*bLinePre*/, /*bLinePost*/{ || DETAIL_CVV() .And. DETAIL_CVW() }	, /*bPreVal*/, {|| CVU_TDOK() }/*bPosVal*/, /*BLoad*/ )
oModel:AddGrid('CVVDETAIL','CVUDETAIL',oStruCVV, /*bLinePre*/, /*bLinePost*/												, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid('CVWDETAIL','CVUDETAIL',oStruCVW, /*bLinePre*/, /*bLinePost*/												, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetRelation('CVUDETAIL',{{'CVU_FILIAL','XFilial("CVU")'},{'CVU_IDBLV','CSU_IDBLV'}}, CVU->(IndexKey(1)) )
oModel:SetRelation('CVVDETAIL',{{'CVV_FILIAL','XFilial("CVV")'},{'CVV_IDBLV','CSU_IDBLV'},{'CVV_CODIGO','CVU_CODIGO'}},CVV->(IndexKey(1)))
oModel:SetRelation('CVWDETAIL',{{'CVW_FILIAL','XFilial("CVW")'},{'CVW_IDBLV','CSU_IDBLV'},{'CVW_CODIGO','CVU_CODIGO'}},CVW->(IndexKey(1)) )

oModel:SetDescription( STR0033 )  //"Bloco V - ECF DEREX"

oModel:GetModel('CSUMASTER'):SetDescription( STR0001 ) //"Cadastro do Bloco V=ECF DEREX"
oModel:GetModel('CVUDETAIL'):SetDescription( STR0002 ) //"Registro V010: DEREX=Instituição"
oModel:GetModel('CVVDETAIL'):SetDescription( STR0003 ) //"Registro V020: DEREX=Responsável pela movimentação"
oModel:GetModel('CVWDETAIL'):SetDescription( STR0004+" -> "+STR0005 ) 	//"Registro V030: DEREX=Período/Mês "
															   						//"Registro V100: Demonstrativo dos recursos em moeda estrangeira decorrentes do recebimento de exportações"

oModel:GetModel( 'CVUDETAIL' ):SetOptional( .T. )
oModel:GetModel( 'CVVDETAIL' ):SetOptional( .T. )
oModel:GetModel( 'CVWDETAIL' ):SetOptional( .T. )

oModel:GetModel( 'CVUDETAIL' ):SetUniqueLine( { 'CVU_NOME' } )
oModel:GetModel( 'CVVDETAIL' ):SetUniqueLine( { 'CVV_TIPDOC', 'CVV_NRODOC', 'CVV_IDCTA' } )
oModel:GetModel( 'CVWDETAIL' ):SetUniqueLine( { 'CVW_MES' } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela da Rotina

@author TOTVS
@since 03/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruCSU	:= FWFormStruct(2,'CSU')
Local oStruCVU	:= FWFormStruct(2,'CVU')
Local oStruCVV	:= FWFormStruct(2,'CVV')
Local oStruCVW	:= FWFormStruct(2,'CVW')
Local oModel		:= FWLoadModel('CTBS450')
Local oView
Local bInclMes    := {|| Ctbs450Fld() } 

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_CSU',oStruCSU,'CSUMASTER')

oView:AddGrid('VIEW_CVU',oStruCVU,'CVUDETAIL')
oView:AddGrid('VIEW_CVV',oStruCVV,'CVVDETAIL')
oView:AddGrid('VIEW_CVW',oStruCVW,'CVWDETAIL')


// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'EMCIMA' 	,  15 )
oView:CreateHorizontalBox( 'MEIO'		,  30 )
oView:CreateHorizontalBox( 'EMBAIXO'	,  55 )

// Cria Folder na view
oView:CreateFolder( 'BLOCOS', 'EMBAIXO' )

// Cria pastas nas folders
oView:AddSheet( 'BLOCOS', 'V020', STR0012 )  //'V020=Responsaveis'
oView:AddSheet( 'BLOCOS', 'V030', STR0013, bInclMes)  //'V030=Valores'

oView:SetOwnerView('VIEW_CSU','EMCIMA'		)
oView:SetOwnerView('VIEW_CVU','MEIO'		)

oView:CreateHorizontalBox( 'V020EMBAIXO', 100, /*owner*/, /*lUsePixel*/, 'BLOCOS', 'V020')
oView:SetOwnerView('VIEW_CVV','V020EMBAIXO'	)

oView:CreateHorizontalBox( 'V030EMBAIXO', 100, /*owner*/, /*lUsePixel*/, 'BLOCOS', 'V030')
oView:SetOwnerView('VIEW_CVW','V030EMBAIXO'		)

oView:EnableTitleView('VIEW_CSU')
oView:EnableTitleView('VIEW_CVU')
oView:EnableTitleView('VIEW_CVV')
oView:EnableTitleView('VIEW_CVW')

oView:AddUserButton( STR0014,'' , {|oView| Ctbs450Fld(.T.)} )  //"Preencher Meses" 
oView:AddUserButton( STR0015,'' , {|oView| Ctbs450Repl()} )  //"Replicar Conf.Livro" 

oView:SetViewAction( 'BUTTONCANCEL',{ |oView| aFill_Mes := {} } )  //limpar array de controle de preenchimento de meses

oView:SetCloseOnOk({||.T.})

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} DETAIL_CVU()
Validacao sobre o preenchimento do Neto quando o filho estiver 
preenchido

@author TOTVS
@since 09/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------
Static Function DETAIL_CVU()
Local lRet		:= .T.
Local oModel	:= FWModelActive()

//----------------------------------------
// Valida se o bloco W250 esta preenchido
//----------------------------------------
If oModel:GetModel( 'CVVDETAIL' ):IsEmpty()
	Help( , ,"DETAIL_CVU", ,STR0006,1,0,,,,,,{ STR0007 })	//"Cadastro do bloco V não preenchido!" ### 
																//"Para solucionar efetue o cadastro dos registros referente ao bloco V=DEREX"                    
	lRet := .F.
EndIf

//somente deve limpar o array de controle quando confirmar e der OK
If lRet
	aFill_Mes := {}  //limpar array de controle de preenchimento de meses
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} DETAIL_CVV()
Validacao sobre o preenchimento do Neto quando o filho estiver 
preenchido

@author TOTVS
@since 09/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------
Static Function DETAIL_CVV()
Local lRet		:= .T.
Local oModel	:= FWModelActive()

//----------------------------------------
// Valida se o bloco W250 esta preenchido
//----------------------------------------
If oModel:GetModel( 'CVVDETAIL' ):IsEmpty()
	Help( , ,"DETAIL_CVV", ,STR0006,1,0,,,,,,{ STR0007 })	//"Cadastro do bloco V não preenchido!" ### 
																//"Para solucionar efetue o cadastro dos registros referente ao bloco V=DEREX"                    
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DETAIL_CVW()
Validacao sobre o preenchimento do Neto quando o filho estiver 
preenchido

@author TOTVS
@since 09/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------
Static Function DETAIL_CVW()
Local lRet		:= .T.
Local oModel	:= FWModelActive()

//----------------------------------------
// Valida se o bloco W250 esta preenchido
//----------------------------------------
If oModel:GetModel( 'CVWDETAIL' ):IsEmpty()
	Help( , ,"DETAIL_CVW", ,STR0006,1,0,,,,,,{ STR0007 })	//"Cadastro do bloco V não preenchido!" ### 
																//"Para solucionar efetue o cadastro dos registros referente ao bloco V=DEREX"                    
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS45OPER
Validacao sobre o preenchimento das datas de inicio e fim do mes informado 

@author TOTVS
@since 09/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------

Function CTBS45OPER(cAnoCal, dDatIni, dDatFim, cMes, cCampo)
Local lRet := .T.

If Empty(cAnoCal)
	Help( , ,"ANO_CAL", ,STR0016,1,0,,,,,,{ STR0017 })	//""Ano Calendario nao preenchido!" ### 
																//"Para solucionar preencha o ano calendario referente ao bloco V=DEREX"                    

	lRet := .F.
Else
	If cCampo = "CVW_DATINI"
	 	If Month(dDatIni) != Val(cMes)
			Help( , ,"MES_INI", ,STR0018,1,0,,,,,,{ STR0019 })	//"Mes informado diferente do mes da data inicial!" ### 
																//"Para solucionar preencha a data dentro do mes selecionado."                    
			lRet := .F.
		Else 
			If Year(dDatIni) != Val(cAnoCal)
				Help( , ,"ANO_INI", ,STR0020,1,0,,,,,,{ STR0021 })	//"Ano Calendario diferente do ano informado!" ### 
																			//"Para solucionar preencha o ano do periodo inicial de acordo com calendario informado."                    
				lRet := .F.
			EndIf
		EndIf
	ElseIf cCampo = "CVW_DATFIM"
	 	If Month(dDatFim) != Val(cMes)
			Help( , ,"MES_FIM", ,STR0022,1,0,,,,,,{ STR0023 })	//"Mes informado diferente do mes da data final!" ### 
																			//"Para solucionar preencha a data do periodo final dentro do mes selecionado."                    
			lRet := .F.
		Else 
			If Year(dDatFim) != Val(cAnoCal)
				Help( , ,"ANO_FIM", ,STR0024,1,0,,,,,,{ STR0025 })	//"Ano Calendario diferente do ano informado!" ### 
																			//"Para solucionar preencha a data do periodo final dentro do ano calendario."                    
				lRet := .F.
			Else
				If dDatIni > dDatFim
					Help( , ,"ANO_FIM", ,STR0026,1,0,,,,,,{ STR0027 })	//"Data Inicial maior que data final!" ### 
																			//"Para solucionar preencha a data inicial menor ou igual a data do periodo final dentro do ano calendario."                    
					lRet := .F.
				EndIf	
			EndIf
		EndIf
	Else
		Help( , ,"ANO_FIM", ,STR0028,1,0,,,,,,{ STR0029 })	//"Campo sem regra de validacao!" ### 
																			//"Verifique as regras de validacao."                    
		lRet := .F.
	EndIf
EndIf	

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} Ctbs450Fld()
Preenche os meses de janeiro a dezembro na grade V030 - Valores

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------

Static Function Ctbs450Fld(lForce)
Local oModel	:= FWModelActive()
Local nOperation	:= oModel:GetOperation()
Local oView		:= FWViewActive()

Local oGridCVW := oModel:GetModel("CVWDETAIL")
Local nQtdLin := 0
Local cUltMes := Space(2)

Default lForce := .F.

If ((nOperation == MODEL_OPERATION_UPDATE .And. lForce) .OR.  nOperation == MODEL_OPERATION_INSERT ) 


	If lForce
		//levantar ultimo mes incluido na grade
		nQtdLin := Ctbs450Ult(oModel, oView,  oGridCVW, @cUltMes)
		
		//se nao tiver nenhuma linha/mes cadastrado eh igual a inclusao
		If nQtdLin == 0
			Ctbs450TMes(oModel, oView,  oGridCVW)
		Else
			//incluir os proximos meses
			Ctbs450PxMes(oModel, oView,  oGridCVW, nQtdLin, cUltMes)
		EndIf
		  
	Else
	
		Ctbs450TMes(oModel, oView,  oGridCVW)

	EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctbs450TMes(oModel, oView,  oGridCVW)
Preenche TODOS os meses de janeiro a dezembro na grade V030 - Valores

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------

Function Ctbs450TMes(oModel, oView,  oGridCVW)
Local lContinua := .T.
Local nX := 0
Local nLinGrade := 0

If aScan( aFill_Mes, { |x| x[1] == oModel:GetModel("CVUDETAIL"):GetLine() } ) == 0 

	For nX:=1 TO 12
	
	    nLinGrade++
	    If nX >= 2				
			If oGridCVW:AddLine() != nLinGrade
				lContinua := .F.  //se der erro captura o erro
			EndIf
		EndIf
		If lContinua
			//na linha incluida pelo metodo addline ou na linha posicionada sem preenchimento do Grupo Filial atribui os valores
			oGridCVW:SetValue("CVW_MES", StrZero(nX, 2, 0) )  																	//MES 
			oGridCVW:SetValue("CVW_TPSALD", "1" )                                               							//SALDO REAL (1) 
			oGridCVW:SetValue("CVW_DATINI", CTOD("01/"+StrZero(nX,2,0)+"/"+FwFldGet("CSU_ANOCAL")) )                 		//DATA INICIO 
			oGridCVW:SetValue("CVW_DATFIM", LastDay(CTOD("01/"+StrZero(nX,2,0)+"/"+FwFldGet("CSU_ANOCAL"))) )           	//DATA FIM  
		Else
			Help( , ,"CVW_ADD_LIN", ,STR0030+oModel:GetErrorMessage()[6],1,0,,,,,,{ STR0031+oModel:GetErrorMessage()[7] })	 //"Não pode incluir linhas no Cadastro do bloco V Reg V030 !"###Verifique
			EXIT 
		EndIf
	
	
	Next
	
	oGridCVW:GoLine(1)
	aAdd( aFill_Mes, {oModel:GetModel("CVUDETAIL"):GetLine(), .T. } )
	
	oView:Refresh("CVWDETAIL")  //ESTE REFRESH EH NECESSARIO PARA ATUALIZAR A GRADE COM OS NOVOS VALORES ATRIBUIDOS

EndIf
			

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctbs450Ult(oModel, oView,  oGridCVW, cUltMes)
Retorna quantidade de linhas da grade CVW e preenche variavel cUltMes passado por referencia

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------

Static Function Ctbs450Ult(oModel, oView,  oGridCVW, cUltMes)
Local nQtdLin := 0
Local nX := 0

For nX:=1 TO oGridCVW:Length()
	
	oGridCVW:GoLine(nX)  //vai para linha
	If Empty( oGridCVW:GetValue("CVW_MES") )
		Exit
	Else
		nQtdLin++
		If ! oGridCVW:IsDeleted()  //se nao estiver deletada
			cUltMes := oGridCVW:GetValue("CVW_MES")
		EndIf
	Endif
	
Next

Return(nQtdLin)


//-------------------------------------------------------------------
/*/{Protheus.doc} Ctbs450PxMes(oModel, oView,  oGridCVW, nQtdLin, cUltMes)
Preenche os PROXIMOS meses da grade CVW a partir da  variavel cUltMes

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------


Function Ctbs450PxMes(oModel, oView,  oGridCVW, nQtdLin, cUltMes)

Local lContinua := .T.
Local nX := 0
Local nLinGrade := 0
Local lInclLin  := .F.

If !Empty(oGridCVW:GetValue("CVW_MES"))  // se mes estiver preenchido nao deixa incluir linhas
	
	Help( , ,"CVW_ADD_LIN", ,STR0030,1,0,,,,,,{ "Posicione em uma nova linha para incluir novos meses" })	 //"Não pode incluir linhas no Cadastro do bloco V Reg V030 !"###"Posicione em uma nova linha para incluir novos meses"

Else
	If Val(cUltMes) < 12 
		nLinGrade := nQtdLin
		lInclLin  := .F.
	
		For nX := Val(cUltMes)+1 TO 12
		
		    nLinGrade++
		    If lInclLin  //se inclui linha				
				If oGridCVW:AddLine() != nLinGrade
					lContinua := .F.  //se der erro captura o erro
				EndIf
			Else
				lInclLin  := .T.	
			EndIf
			If lContinua
				//na linha incluida pelo metodo addline ou na linha posicionada sem preenchimento do Grupo Filial atribui os valores
				oGridCVW:SetValue("CVW_MES", StrZero(nX, 2, 0) )  																	//MES 
				oGridCVW:SetValue("CVW_TPSALD", "1" )                                               							//SALDO REAL (1) 
				oGridCVW:SetValue("CVW_DATINI", CTOD("01/"+StrZero(nX,2,0)+"/"+FwFldGet("CSU_ANOCAL")) )                 		//DATA INICIO 
				oGridCVW:SetValue("CVW_DATFIM", LastDay(CTOD("01/"+StrZero(nX,2,0)+"/"+FwFldGet("CSU_ANOCAL"))) )           	//DATA FIM  
			Else
				Help( , ,"CVW_ADD_LIN", ,STR0030+oModel:GetErrorMessage()[6],1,0,,,,,,{ STR0031+oModel:GetErrorMessage()[7] })	 //"Não pode incluir linhas no Cadastro do bloco V Reg V030 !"###Verifique
				EXIT 
			EndIf
		
		Next
		
		oGridCVW:GoLine(nQtdLin+1)
		
		oView:Refresh("CVWDETAIL")  //ESTE REFRESH EH NECESSARIO PARA ATUALIZAR A GRADE COM OS NOVOS VALORES ATRIBUIDOS
	
	Else
	
		Help( , ,"CVW_INC_LIN", ,STR0030,1,0,,,,,,{ STR0031 })	 //"Não pode incluir linhas no Cadastro do bloco V Reg V030 !"###"Verifique"

	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CVU_TDOK()
Validação Tudo OK preenchimento da grade referente registro K100=Empresas participantes da consolidacao

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CVU_TDOK()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oGridCVU := oModel:GetModel("CVUDETAIL")
Local nLinOri  := oGridCVU:GetLine()  //grava a linha atual da grade para retornar apos contagem laco for...next
Local nX
Local oView		:= FWViewActive()

For nX:=1 TO oGridCVU:Length()
	
	oGridCVU:GoLine(nX)  //vai para linha
	
	If ! oGridCVU:IsDeleted()  //se nao estiver deletada
		lRet := CVW_TDOK()
		If !lRet
			Exit
		EndIf
	EndIf

Next 

If lRet
	oGridCVU:GoLine(nLinOri)  //vai para linha posicionada anteriormente ao laco for...next se estiver tudo ok senao continua na linha a ser editada
Else
	oView:Refresh("CVUDETAIL")  //ESTE REFRESH EH NECESSARIO PARA ATUALIZAR A GRADE COM OS NOVOS VALORES ATRIBUIDOS
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CVW_TDOK()
Validação Tudo OK preenchimento da grade referente registro V030

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CVW_TDOK()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oGridCVW := oModel:GetModel("CVWDETAIL")
Local nLinOri  := oGridCVW:GetLine()  //grava a linha atual da grade para retornar apos contagem laco for...next
Local nX
Local oView		:= FWViewActive()

For nX:=1 TO oGridCVW:Length()
	
	oGridCVW:GoLine(nX)  //vai para linha
	
	If ! oGridCVW:IsDeleted()  //se nao estiver deletada
		lRet := !Empty(oGridCVW:GetValue("CVW_CFGLIV"))
		If !lRet
			//Alert(STR0032)  //"Config. Livros não informada para o mes. " 
			Help( , ,"CVW_CFGLIV", ,STR0032,1,0,,,,,,{ STR0034 })  //"Config. Livros não informada para o mes. "##"Informe a configuracao do livro amarrada a uma visao gerencial." 
			Exit
		EndIf
		//VALIDA SE ALGUM ANO DATA INICIO OU FIM ESTA DIFERENTE DA CSU_ANOCAL 
		lRet := Year( oGridCVW:GetValue("CVW_DATINI") ) == Val( FwFldGet("CSU_ANOCAL") )
		If !lRet
			//Alert("Ano de data do periodo inicial diferente do informado no ano calendario.") 
			Help( , ,"ANO_INI", ,STR0020,1,0,,,,,,{ STR0021 })	//"Ano Calendario diferente do ano informado!" ### 
																			//"Para solucionar preencha o ano do periodo inicial de acordo com calendario informado."                    
			Exit
		EndIf
		
		lRet := Year( oGridCVW:GetValue("CVW_DATFIM") ) == Val( FwFldGet("CSU_ANOCAL") )
		If !lRet
			//Alert("Ano de data do periodo final diferente do informado no ano calendario.") 
			Help( , ,"ANO_FIM", ,STR0024,1,0,,,,,,{ STR0025 })	//"Ano Calendario diferente do ano informado!" ### 
																			//"Para solucionar preencha a data do periodo final dentro do ano calendario."                    
			Exit
		EndIf
		




	EndIf

Next 

If lRet
	oGridCVW:GoLine(nLinOri)  //vai para linha posicionada anteriormente ao laco for...next se estiver tudo ok senao continua na linha a ser editada
Else
	oView:Refresh("CVUDETAIL")  //ESTE REFRESH EH NECESSARIO PARA ATUALIZAR A GRADE COM OS NOVOS VALORES ATRIBUIDOS
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Ctbs450Doc()
Opcoes do combo box para tipo documento bloco V-Derex

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function Ctbs450Doc()
Local cRetorno := ''

cRetorno += 'CI=Cédula de Identidade;'
cRetorno += 'PS=Passaporte;'
cRetorno += 'BI=Bilhete de Identidade;'
cRetorno += 'DI=Documentos Nacional de Identificação;'
cRetorno += 'SR=State Registry;'
cRetorno += 'CT=Carnet de Identidad;'
cRetorno += 'TI=Tarjeta de Identidad;'
cRetorno += 'NC=National Identity Card;'
cRetorno += 'PC=Permanent Resident Cards;'
cRetorno += 'DL=Driver s License;'
cRetorno += 'SN=Social Securty Number (SSN);'
cRetorno += 'OT=Outros'

Return(cRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctbs450Repl()
Opcoes para replicar conteudo da celula posicionada na grade para outras linhas
referente a configuracao livro 
@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------

Static Function Ctbs450Repl()

Local oModel	:= FWModelActive()
Local nOperation	:= oModel:GetOperation()
Local oView		:= FWViewActive()

Local oGridCVW := oModel:GetModel("CVWDETAIL")
Local nX := 0
Local cCfgLiv := Space(3)

cCfgLiv := oGridCVW:GetValue("CVW_CFGLIV") 


If !Empty(cCfgLiv) .And. ( nOperation == MODEL_OPERATION_UPDATE .OR.  nOperation == MODEL_OPERATION_INSERT )

	For nX:=1 TO oGridCVW:Length()

		oGridCVW:GoLine(nX)
		oGridCVW:SetValue("CVW_CFGLIV", cCfgLiv )

	Next
	
	
	oGridCVW:GoLine(1)
	oView:Refresh("CVWDETAIL")  //ESTE REFRESH EH NECESSARIO PARA ATUALIZAR A GRADE COM OS NOVOS VALORES ATRIBUIDOS

EndIf

Return
