#INCLUDE "WFA000.ch"
#include "SIGAWF.CH"
#Include "Protheus.ch"
#Include "FWMVCDef.ch"

Static cAliasTMP
Static oTempTable

//-------------------------------------------------------------------
/*/{Protheus.doc} WFA000

Janela de cadastro de Parametros do Workflow

@author henrique.makauskas

@since 14/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function WFA000()	
	FWExecView(STR0032, 'WFA000', WF_ALTERAR)
	
	fDelTMP(cAliasTMP)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função de criação do menu de opções da rotina

@author henrique.makauskas

@since 14/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRot := {}
	
	ADD OPTION aRot TITLE STR0005 ACTION 'VIEWDEF.WFA000' 	OPERATION WF_ALTERAR 	ACCESS 0 //"Alterar"		

Return aRot

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface

@author henrique.makauskas
@since 14/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
	Local oView	:= Nil
	Local oModel 	:= ModelDef()
	Local oStr2	:= viewoStr1Str()
	oView 			:= FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField('FormParam' , oStr2,'FieldParam' ) 
	oView:CreateHorizontalBox( 'BOXFORMParam', 100)
	oView:SetOwnerView('FormParam','BOXFORMParam')
	oView:SetCloseOnOk({|| .T. }) 
		
	// Cria os grupos para agrupamentos de campos
	oStr2:AddGroup( 'Correio', STR0033, 'TELA', 2 )	
	oStr2:AddGroup( 'Processos', STR0034, 'TELA', 2 )	
	oStr2:AddGroup( 'Notificacao', STR0035, 'TELA', 2 )	
	oStr2:AddGroup( 'Messenger', STR0036, 'TELA', 2 )
		
	oStr2:SetProperty('MV_WFMLBOX', MVC_VIEW_GROUP_NUMBER, 'Correio' )
	oStr2:SetProperty('MV_WFFILA', MVC_VIEW_GROUP_NUMBER, 'Correio' )
	oStr2:SetProperty('MV_WFHTML', MVC_VIEW_GROUP_NUMBER, 'Correio' )
	oStr2:SetProperty('MV_WFSNDAU', MVC_VIEW_GROUP_NUMBER, 'Correio' )
	oStr2:SetProperty('MV_WFJAVAS', MVC_VIEW_GROUP_NUMBER, 'Correio' )
		
	oStr2:SetProperty('MV_WFMAXJB', MVC_VIEW_GROUP_NUMBER, 'Processos' )
	oStr2:SetProperty('MV_WFNEWJB', MVC_VIEW_GROUP_NUMBER, 'Processos' )
	oStr2:SetProperty('MV_WFREACT', MVC_VIEW_GROUP_NUMBER, 'Processos' )
	oStr2:SetProperty('MV_WFTRANS', MVC_VIEW_GROUP_NUMBER, 'Processos' )
	oStr2:SetProperty('MV_WFREPRO', MVC_VIEW_GROUP_NUMBER, 'Processos' )
	oStr2:SetProperty('MV_WFENVIO', MVC_VIEW_GROUP_NUMBER, 'Processos' )
	 
	oStr2:SetProperty('MV_WFADMIN', MVC_VIEW_GROUP_NUMBER, 'Notificacao' )
	oStr2:SetProperty('MV_WFNF001', MVC_VIEW_GROUP_NUMBER, 'Notificacao' )
	oStr2:SetProperty('MV_WFNF002', MVC_VIEW_GROUP_NUMBER, 'Notificacao' )
	oStr2:SetProperty('MV_WFNF003', MVC_VIEW_GROUP_NUMBER, 'Notificacao' )
	oStr2:SetProperty('MV_WFNF004', MVC_VIEW_GROUP_NUMBER, 'Notificacao' )
	
	oStr2:SetProperty('MV_WFBROWS', MVC_VIEW_GROUP_NUMBER, 'Messenger' )
	oStr2:SetProperty('MV_WFBRWSR', MVC_VIEW_GROUP_NUMBER, 'Messenger' )
	oStr2:SetProperty('MV_WFDHTTP', MVC_VIEW_GROUP_NUMBER, 'Messenger' )
	oStr2:SetProperty('MV_WFMESSE', MVC_VIEW_GROUP_NUMBER, 'Messenger' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author henrique.makauskas

@since 14/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
	Local oModel	:= Nil
	Local oStr1	:= Nil
		
	//Cria arquivo temporario
	cAliasTMP := fCriaTMP()
	
	oStr1:= mldoStr1Str(cAliasTMP)
	
	oModel := MPFormModel():New('ModelWFParam', /*bPreValidacao*/, /*bPosValidacao*/, { | oModel | ParamFormCommit( oModel ) } /*bCommit*/, /*bCancel*/ )
	
	oModel:SetDescription('Model')
	oModel:addFields('FieldParam',,oStr1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,  /*bLoad*/)
	oModel:getModel('FieldParam'):SetDescription('Field')

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} mldoStr1Str()
Retorna estrutura do tipo FWformModelStruct.

@author henrique.makauskas

@since 14/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
static function mldoStr1Str(cAlias)
	Local oStruct := FWFormModelStruct():New()
	Local aFields	:= {}
	Local n		:= 0
	Local bInit	:= Nil 
	Local cInit	:= Nil
			
	oStruct:AddTable(cAlias,{'MV_WFMLBOX'}, STR0032)
	
	aFields := {}
	AAdd( aFields, { "MV_WFMLBOX",/**/,STR0002 , 'C', 20 , 0, , , WFMBoxList(), .F., .F., .F., .T., , } )	// Caixa de correio do workflow
	AAdd( aFields, { "MV_WFADMIN",/**/,STR0048 , 'C', 50 , 0, , , {}, .F., .F., .F., .T., , } )	// E-mail do(s) administrador(es)
	AAdd( aFields, { "MV_WFHTML" ,/**/,STR0040 , 'L', 1  , 0, , , {}, .F., .F., .F., .T., , } )	// Enviar html no corpo da mensagem
	AAdd( aFields, { "MV_WFJAVAS",/**/,STR0042 , 'L', 1  , 0, , , {}, .F., .F., .F., .T., , } )	// Usa javascript
	AAdd( aFields, { "MV_WFSNDAU",/**/,STR0041 , 'L', 1  , 0, , , {}, .F., .F., .F., .T., , } )	// Envio automatico de mensagens
	AAdd( aFields, { "MV_WFREACT",/**/,STR0046 , 'L', 1  , 0, , , {}, .F., .F., .F., .T., , } )	// Reativar processos automaticamente
	AAdd( aFields, { "MV_WFMAXJB",/**/,STR0044 , 'C', 20 , 0, , , {}, .F., .F., .F., .T., , } )	// Numero max de execucao de retornos por vez
	AAdd( aFields, { "MV_WFTRANS",/**/,STR0047 , 'L', 1  , 0, , , {}, .F., .F., .F., .T., , } )	// Usa transacao
	AAdd( aFields, { "MV_WFBROWS",/**/,STR0055 , 'C', 100, 0, , , {}, .F., .F., .F., .T., , } )	// Browser internet utilizado.
	AAdd( aFields, { "MV_WFBRWSR",/**/,STR0056 , 'C', 50 , 0, , , {}, .F., .F., .F., .T., , } )	// Browser internet utilizado.
	AAdd( aFields, { "MV_WFDHTTP",/**/,STR0057 , 'C', 100, 0, , , {}, .F., .F., .F., .T., , } )	// Diretorio HTTP 
	AAdd( aFields, { "MV_WFNF001",/**/,STR0051 , 'L', 1  , 0, , , {}, .F., .F., .F., .T., , } )	// Notificar se houver erro ao executar funcoes de retorno e timeout
	AAdd( aFields, { "MV_WFNF002",/**/,STR0052 , 'L', 1  , 0, , , {}, .F., .F., .F., .T., , } )	// Notificar ao reativar processos pendentes
	AAdd( aFields, { "MV_WFNF003",/**/,STR0053 , 'L', 1  , 0, , , {}, .F., .F., .F., .T., , } )	// Notificar ao receber mensagens nao reconhecidas. 
	AAdd( aFields, { "MV_WFMESSE",/**/,STR0059 , 'L', 1  , 0, , , {}, .F., .F., .F., .T., , } )	// Habilitar messenger
	AAdd( aFields, { "MV_WFNEWJB",/**/,STR0060 , 'L', 1  , 0, , , {}, .F., .F., .F., .T., ,  } )	// Habilitar o novo recurso de execucao de jobs no retorno.
	AAdd( aFields, { "MV_WFFILA" ,/**/,STR0065 , 'L', 1  , 0, , , {}, .F., .F., .F., .T., , } )	// Habilitar o novo recurso de utilização de filas de envio de email
	AAdd( aFields, { "MV_WFENVIO",/**/,STR0061 , 'C', 20 , 0, , , {'1','2'}, .F., .F., .F., .T., , } )	// Forma de Envio de Email Em Lote (1) ou Individual (2)
	AAdd( aFields, { "MV_WFNF004",/**/,STR0067 , 'L', 1  , 0, , , {}, .F., .F., .F., .T., , } )	// Notificar se ocorrer erro no envio de mensagens.	
	AAdd( aFields, { "MV_WFREPRO",/**/,STR0068 , 'L', 1  , 0, , , {}, .F., .F., .F., .T., , } )	// Reprocessar wfm's da pasta error.
	
	WFAGetMV( aFields )
	
	//Carrega os campos do formulário com os dados da SX6
	For n := 1 To Len(aFields)
		
		If  aFields[n, 2] == Nil
			bInit := Nil
			cInit := Nil
		Else
			If ValType(aFields[n, 2]) == 'L'				
				cInit := IIF(aFields[n ,2], "{ || .T. }" , "{ || .F. }")
												
			ElseIf ValType(aFields[n, 2]) == 'N'
				cInit := "{ || '" + AllTrim(STR(aFields[n ,2])) + "'}"
							
			Else				
				cInit := "{ || '" + AllTrim(aFields[n ,2]) + "'}"
								
			EndIf
			
			bInit := &(cInit)
			
		EndIf
										
		oStruct:AddField(aFields[n, 3], aFields[n, 3], aFields[n, 1], aFields[n, 4], aFields[n, 5], aFields[n, 6], aFields[n, 7], aFields[n, 8], aFields[n, 9], aFields[n, 10], bInit, aFields[n,11], aFields[n, 12], aFields[n, 13], aFields[n, 14], aFields[n, 15])
		
	Next
		
return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} viewoStr1Str()
Retorna estrutura do tipo FWFormViewStruct.

@author henrique.makauskas

@since 14/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------

static function viewoStr1Str()
	Local oStruct := FWFormViewStruct():New()

	oStruct:AddField( 'MV_WFMLBOX','1',STR0002,STR0002,, 'Combo' ,,,, IIF( LEN(WFMBoxList()) > 0, .T., .F. ) ,,,WFMBoxList(),,,.T.,, ) // Caixa de correio do workflow
	oStruct:AddField( 'MV_WFADMIN','2',STR0048,STR0048,, 'Get' ,,,,,,,,,,.T.,, )	 // E-mail do(s) administrador(es)
	oStruct:AddField( 'MV_WFHTML','4',STR0040,STR0040,, 'Check' ,,,,,,,,,,.T.,, ) // Enviar html no corpo da mensagem
	oStruct:AddField( 'MV_WFJAVAS','5',STR0042,STR0042,, 'Check' ,,,,,,,,,,.T.,, ) //Usa javascript
	oStruct:AddField( 'MV_WFSNDAU','6',STR0041,STR0041,, 'Check' ,,,,,,,,,,.T.,, ) // Envio automatico de mensagens
	oStruct:AddField( 'MV_WFREACT','7',STR0046,STR0046,, 'Check' ,,,,,,,,,,.T.,, ) // Reativar processos automaticamente
	oStruct:AddField( 'MV_WFMAXJB','8',STR0044,STR0044,, 'Get' ,'9999',,,,,,,,,.T.,, ) // Numero max de execucao de retornos por vez
	oStruct:AddField( 'MV_WFTRANS','9',STR0047,STR0047,, 'Check' ,,,,,,,,,,.T.,, ) // Usa transacao
	oStruct:AddField( 'MV_WFBROWS','10',STR0055,STR0055,, 'Get' ,,,,,,,,,,.T.,, ) // Browser internet utilizado.
	oStruct:AddField( 'MV_WFBRWSR','11',STR0056,STR0056,, 'Get' ,,,,,,,,,,.T.,, ) // Browser internet utilizado.
	oStruct:AddField( 'MV_WFDHTTP','12',STR0057,STR0057,, 'Get' ,,,,,,,,,,.T.,, ) // Diretorio HTTP	
	oStruct:AddField( 'MV_WFNF001','14',STR0051,STR0051,, 'Check' ,,,,,,,,,,.T.,, ) // Notificar se houver erro ao executar funcoes de retorno e timeout
	oStruct:AddField( 'MV_WFNF002','15',STR0052,STR0052,, 'Check' ,,,,,,,,,,.T.,, ) // Notificar ao reativar processos pendentes
	oStruct:AddField( 'MV_WFNF003','16',STR0053,STR0053,, 'Check' ,,,,,,,,,,.T.,, ) // Notificar ao receber mensagens nao reconhecidas. 
	oStruct:AddField( 'MV_WFNF004','17',STR0067,STR0067,, 'Check' ,,,,,,,,,,.T.,, ) // Notificar se ocorrer erro no envio de mensagens.
	oStruct:AddField( 'MV_WFMESSE','18',STR0059,STR0059,, 'Check' ,,,,,,,,,,.T.,, ) // Habilitar messenger
	oStruct:AddField( 'MV_WFNEWJB','19',STR0060,STR0060,, 'Check' ,,,,,,,,,,.T.,, ) // Habilitar o novo recurso de execucao de jobs no retorno.
	oStruct:AddField( 'MV_WFFILA','20',STR0065,STR0065,, 'Check' ,,,,,,,,,,.T.,, ) // Habilitar o novo recurso de utilização de filas de envio de email
	oStruct:AddField( 'MV_WFENVIO','21',STR0061 + ":  [1] - " + STR0062 + " [2] - " + STR0063,STR0061,, 'Combo' ,,,,,,, {'1','2'} ,,,.T.,, ) // Forma de Envio de Email Em Lote (1) ou Individual (2)		
	oStruct:AddField( 'MV_WFREPRO','22',STR0068,STR0068,, 'Get' ,,,,,,,,,,.T.,, ) // Reprocessar wfm's da pasta error.

return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaTMP
Cria arquivo temporário

@author henrique.makauskas

@since 14/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function fCriaTMP()
	Local aArea     := GetArea()
	Local aCampos   := {}
	Local cIndTemp  := ""	
	Local cQuery    := ""
	Local cAliasTmp := "TMP"

	AAdd( aCampos, { "MV_WFMLBOX", "C", 20, 0} )	// Caixa de correio do workflow
	AAdd( aCampos, { "MV_WFADMIN", "C", 50, 0} )	// E-mail do(s) administrador(es)	
	AAdd( aCampos, { "MV_WFHTML ", "C", 20, 0} )	// Enviar html no corpo da mensagem
	AAdd( aCampos, { "MV_WFJAVAS", "C", 20, 0} )	// Usa javascript
	AAdd( aCampos, { "MV_WFSNDAU", "C", 20, 0} )	// Envio automatico de mensagens
	AAdd( aCampos, { "MV_WFREACT", "C", 20, 0} )	// Reativar processos automaticamente
	AAdd( aCampos, { "MV_WFMAXJB", "C", 20, 0} )	// Numero max de execucao de retornos por vez
	AAdd( aCampos, { "MV_WFTRANS", "C", 20, 0} )	// Usa transacao
	AAdd( aCampos, { "MV_WFBROWS", "C", 20, 0} )	// Browser internet utilizado.
	AAdd( aCampos, { "MV_WFBRWSR", "C", 20, 0} )	// Browser internet utilizado.
	AAdd( aCampos, { "MV_WFDHTTP", "C", 20, 0} )	// Diretorio HTTP 	
	AAdd( aCampos, { "MV_WFNF001", "C", 20, 0} )	// Notificar se houver erro ao executar funcoes de retorno e timeout
	AAdd( aCampos, { "MV_WFNF002", "C", 20, 0} )	// Notificar ao reativar processos pendentes
	AAdd( aCampos, { "MV_WFNF003", "C", 20, 0} )	// Notificar ao receber mensagens nao reconhecidas. 
	AAdd( aCampos, { "MV_WFMESSE", "C", 20, 0} )	// Habilitar messenger
	AAdd( aCampos, { "MV_WFNEWJB", "C", 20, 0} )	// Habilitar o novo recurso de execucao de jobs no retorno.
	AAdd( aCampos, { "MV_WFFILA" , "C", 20, 0} )	// Habilitar o novo recurso de utilização de filas de envio de email
	AAdd( aCampos, { "MV_WFENVIO", "C", 20, 0} )	// Forma de Envio de Email Em Lote (1) ou Individual (2)
	AAdd( aCampos, { "MV_WFNF004", "C", 20, 0} )	// Notificar se ocorrer erro no envio de mensagens.	
	AAdd( aCampos, { "MV_WFREPRO", "C", 20, 0} )	// Reprocessar wfm's da pasta error.
		
	If Select(cAliasTmp)>0
		dbSelectArea(cAliasTmp)
		dbCloseArea()
	EndIf
	
	//-----------------------------------------
	// Criação do objeto de arquivo temporário.
	//-----------------------------------------
	oTempTable := FWTemporaryTable():New( cAliasTmp )
	oTemptable:SetFields( aCampos )
	
	oTempTable:AddIndex("indice1", {"MV_WFMLBOX"} )
	
	//-----------------------------------------
	// Criação da tabela.
	//-----------------------------------------
	oTempTable:Create()
	
	//------------------------------------
	// Executa query para leitura da tabela.
	//------------------------------------
	cQuery := "select * from " + oTempTable:GetRealName()
	MPSysOpenQuery( cQuery, cAliasTmp )

	DbSelectArea(cAliasTmp)
	
	RestArea( aArea )

Return cAliasTmp

//-------------------------------------------------------------------
/*/{Protheus.doc} fDelTMP
Deleta o arquivo temporário

@author henrique.makauskas

@since 14/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fDelTMP(cAlias)
	Local aArea := GetArea()
	
	If Select(cAlias) > 0 
		dbSelectArea(cAlias)
		dbCloseArea()
	EndIf
	
	RestArea(aArea)
	
	//---------------------------------
	//Exclui a tabela temporária. 
	//---------------------------------
	If !( oTempTable == Nil )
		oTempTable:Delete()
	EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ParamFormCommit
Commit e gravação dos dados na SX6

@author henrique.makauskas

@since 14/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
static function ParamFormCommit(oModel)
	Local oModelParams := oModel:getModel('FieldParam'):GetStruct()
	Local aRetorno
	Local nEntity := 1
	Local aFields := {}
				
	aRetorno := oModelParams:GetFields()
		
	For nEntity := 1 To Len(aRetorno)
		
		AAdd( aFields, { aRetorno[nEntity][3], oModel:GetValue('FieldParam' , aRetorno[nEntity][3]) } )
			
	Next
		
	WFASetMV( aFields )

Return .T.

