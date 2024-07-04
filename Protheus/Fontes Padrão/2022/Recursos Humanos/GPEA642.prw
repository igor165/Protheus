#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'GPEA642.ch'

Function GPEA642()

Local oBrw := FwMBrowse():New()

oBrw:SetAlias( 'TIV' )
oBrw:SetMenudef( "GPEA642" )
oBrw:SetDescription( OEmToAnsi( STR0001 ) ) // Cadastro de Pontuação

oBrw:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
	Rotina para construção do menu
@sample 	Menudef()
@since		06/09/2013
@version 	P11.90

/*/
//------------------------------------------------------------------------------
Static Function Menudef()

Local aMenu := FWMVCMenu("GPEA642")

Return aMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author arthur.colado

@since 04/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel 
Local oStr1:= FWFormStruct(1,'TIV')

oModel := MPFormModel():New('GPEA642',,,{|oModel|AT642GRV(oModel)})
oModel:SetDescription('GPEA642')
oModel:addFields('FIELD1',,oStr1)
oModel:SetPrimaryKey({ 'TIV_FILIAL', 'TIV_CODIGO' })

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author arthur.colado

@since 04/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'TIV')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('FORM1' , oStr1,'FIELD1' )
oView:CreateHorizontalBox( 'BOXFORM1', 100)
oView:SetOwnerView('FORM1','BOXFORM1')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} AT642GRV
Grava e Realiza o processamento da pontuação para os Atendentes

@author arthur.colado
@since 04/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AT642GRV(oModel)
Local lRet 	:= .T.
Local nOperation := oModel:GetOperation()

DbSelectArea("TIT")

If IsBlind()
	If nOperation == MODEL_OPERATION_INSERT
		lRet := At642Processa(nOperation)
	Else
		If TIT->(ColumnPos('TIT_CODTIV')) > 0
			lRet := At642Processa(nOperation)
		EndIf
	EndIf
	
Else
	If nOperation == MODEL_OPERATION_INSERT
		MsgRun("Atribuindo Pontuação...." ,"Aguarde"  ,{ || lRet := At642Processa(nOperation) })	//"Atribuindo Pontuação...." ,"Aguarde"
		
	Elseif nOperation == MODEL_OPERATION_UPDATE .And. TIT->(ColumnPos('TIT_CODTIV')) > 0
	
		MsgRun("Alterando Pontuação...." ,"Aguarde"  ,{ || lRet := At642Processa(nOperation) })//"Alterando Pontuação...." ,"Aguarde"
	
	Elseif nOperation == MODEL_OPERATION_DELETE .And. TIT->(ColumnPos('TIT_CODTIV')) > 0
		MsgRun("Deletando Pontuação...." ,"Aguarde"  ,{ || lRet := At642Processa(nOperation) })//"Deletando Pontuação...." ,"Aguarde"
	EndIf
EndIf
If lRet
	FwFormCommit(oModel)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At642Processa
Realiza o processamento da pontuação para os atendentes

@author arthur.colado
@since 04/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function At642Processa(nOper)
Local lRet		:= .T.
Local aFunc		:= {}
Local cCodTIV	:= FwFldGet("TIV_CODIGO")
Local cAliasTIT	:= ""

If nOper == 4 .Or. nOper == 5

	cAliasTIT := GetNextAlias()
	
	BeginSQL alias cAliasTIT
	
		SELECT TIT.TIT_CODIGO
		FROM %Table:TIT% TIT
		WHERE TIT.TIT_FILIAL   = %xfilial:TIT%
			AND TIT.TIT_CODTIV = %Exp:cCodTIV%
			AND TIT.%NotDel%
	EndSQL
	
	DbSelectArea("TIT")
	TIT->(DbSetOrder(1))

	While (cAliasTIT)->(!EOF())

		If TIT->(DbSeek(xFilial("TIT")+(cAliasTIT)->TIT_CODIGO))
			RecLock("TIT",.F.)
			TIT->(DbDelete())
			TIT->(MsUnLock())
		Endif

		(cAliasTIT)->(DbSkip())

	EndDo

	(cAliasTIT)->(DbCloseArea())

Endif


If nOper == 3 .Or. nOper == 4 //Inclusão ou alteração

	aFunc := At642QryFunc(FwFldGet("TIV_ADMITI"))
	
	If !Empty(aFunc)
		lRet := At642AplPonto(aFunc)
	Else
		Help( ,, "At642Processa",, STR0004, 1, 0 )	//"Não há funcionario para aplicar pontuação"
		lRet := .F.
	EndIf

Endif

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} At642QryFunc
Realiza a consulta para os atendentes que receberão a pontuação

@author arthur.colado
@since 04/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function At642QryFunc(dDtAdmit)
Local aRet			:= {}
Local cAlias		:= GetNextAlias()
Local cData			:= ""

Default dDtAdmit	:= ""

If !Empty(dDtAdmit)
	cData := dToS(dDtAdmit)
EndIf

BeginSQL alias cAlias		
		SELECT SRA.RA_FILIAL,
				SRA.RA_ADMISSA,
				SRA.RA_DEMISSA,
				SRA.RA_RESCRAI,
				SRA.RA_MAT,
				SRA.RA_NOME,
				SRA.RA_SITFOLH,
				AA1.AA1_CODTEC,
				AA1.AA1_FUNFIL
		FROM
			%Table:SRA% SRA
		LEFT JOIN 
					%Table:AA1% AA1  
			       ON 
			       	AA1.AA1_FILIAL = %xfilial:AA1% 
			      	AND
			      		AA1.AA1_FUNFIL = SRA.RA_FILIAL
			      	AND 
			      		AA1.AA1_CDFUNC = SRA.RA_MAT
			      	AND 
			      		AA1.%NotDel%
				
		WHERE
				SRA.RA_FILIAL = %xfilial:SRA%
			AND
				SRA.RA_DEMISSA = %exp:SPACE(TamSX3("RA_DEMISSA")[1])%
			AND
				SRA.RA_RESCRAI = %exp:SPACE(TamSX3("RA_RESCRAI")[1])%
			AND
				SRA.RA_ADMISSA <= %Exp:cData%
			AND
				SRA.RA_SITFOLH <> 'D'
			AND 
				SRA.%NotDel%
EndSQL

While (cAlias)->(!Eof())
	
		AAdd( aRet, { 	(cAlias)->AA1_CODTEC,;
							(cAlias)->RA_ADMISSA,;
							(cAlias)->RA_DEMISSA,;
							(cAlias)->RA_RESCRAI,;
							(cAlias)->RA_MAT,;
							(cAlias)->RA_NOME,;
							(cAlias)->RA_SITFOLH } )
		
		(cAlias)->(DbSkip())
		
	EndDo

(cAlias)->(DbCloseArea())


Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} At642AplPonto
Inclui a pontuação para os atendentes na tabela TIT

@author arthur.colado
@since 04/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function At642AplPonto(aFunc)
Local lRet		:= .T.
Local nX		:= 0

Default aFunc	:= {}

If Len(aFunc) > 0
	
	DbSelectArea("TIT")
	
	For nX := 1 To Len(aFunc)
	
		Begin Transaction
			RecLock("TIT",.T.)
				REPLACE TIT_FILIAL 		With xFilial("TIT")
				REPLACE TIT_CODIGO 		With GETSX8NUM("TIT","TIT_CODIGO")
				REPLACE TIT_TIPO		With '2'
				REPLACE TIT_CODTIQ		With FwFldGet("TIV_CODTIQ")
				REPLACE TIT_DATA 		With dDataBase
				REPLACE TIT_HORA	 	With Time()
				REPLACE TIT_CODTIS		With FwFldGet("TIV_CODTIS")
				REPLACE TIT_CODTEC		With aFunc[nX][1]
				REPLACE TIT_APLICA		With '2'
				REPLACE TIT_DESCRI		With FwFldGet("TIV_DESCRI")
				REPLACE TIT_PONTOS		With FwFldGet("TIV_PONTOS")
				REPLACE TIT_MAT			With aFunc[nX][5]
				REPLACE TIT_USUARI 		With __cUserId
				
				If TIT->(ColumnPos('TIT_CODTIV')) > 0				
					REPLACE TIT_CODTIV		With FwFldGet("TIV_CODIGO")
				Endif
				
			TIT->(MsUnlock())
			ConfirmSX8()
			
		End Transaction	
	
	Next nX
Else
	lRet := .F.
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} f642TIVTIQ
Valid do campo TIV_CODTIQ se disciplina escolhida (TIQ) é tipo mérito
@author  isabel.noguti
@since   01/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function f642TIVTIQ()
Local lRet	:= .F.
Local aArea	:= GetArea()

	DbSelectArea("TIQ")
	If DbSeek( xFilial("TIQ", cFilAnt ) + FwFldGet("TIV_CODTIQ") ) .And. TIQ->TIQ_TIPO == "2"
		lRet := .T.
	EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} f642TIVTIS
Valid do campo TIV_CODTIS se motivo escolhido (TIS) é tipo mérito
@author  isabel.noguti
@since   01/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function f642TIVTIS()
Local lRet	:= .F.
Local aArea	:= GetArea()

	DbSelectArea("TIS")
	If DbSeek( xFilial("TIS", cFilAnt ) + FwFldGet("TIV_CODTIS") ) .And. TIS->TIS_TIPO == "2"
		lRet := .T.
	EndIf

RestArea(aArea)
Return lRet
