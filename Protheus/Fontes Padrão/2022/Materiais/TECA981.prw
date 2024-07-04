#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#DEFINE CRLF Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} TECA981()
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Function TECA981()
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Processar"},{.T.,"Cancelar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}

If FWIsAdmin()
	If AbreExcl('TWI')
		FWExecView ("Limpeza de movimentos", "TECA981", MODEL_OPERATION_INSERT,,,,,aButtons)							
	EndIf
Else
	Help( , , "At982Admin", , "Rotina exclusiva para usuários com perfil de administrador",4,10,,,,,,)	
EndIf	
	 
Return
	
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStru := FWFormStruct( 1, 'LIMPEZA', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel	:= Nil

oStru:AddField( "Atenção",;                          // cTitle	//'Nulo'
                "",;                          		// cToolTip
                'LMP_ATEN',;                       // cIdField
                'M',;                              // cTipo
                10,;                                // nTamanho
                0,;                                // nDecimal
                Nil,;									// bValid
                Nil,;
                { },;                              // aValues
                .F.,;                              // lObrigat
                 {||'A execução do processo de limpeza de movimentações eliminará fisicamente os dados da tabela TWI (Movimentos de saldos).' + CRLF + CRLF;
                 	                 		+ 'Quando:' + CRLF + '- Os dados enquadrarem-se no período informado.' + CRLF;
                 	                 		+ '- Não possuam mais relevância para calcúlos de disponibilidade (Quantidade de saída = Quantidade de retorno).' + CRLF + CRLF;
                 	                   	+ 'Este processo é irreversível!'},;
                .F.,;                              // lKey
                .F.,;                              // lNoUpd
                .T.)                               // lVirtual                
                                                                

oStru:AddField( "Filtrar por",;                          // cTitle	//'Nulo'
                "",;                          // cToolTip	//'Nulo'
                'LMP_FILTRO',;                       // cIdField
                'C',;                              // cTipo
                1,;                                // nTamanho
                0,;                                // nDecimal
                NIL,;                              // bValid
                NIL,;                              // bWhen
                { '1=Intervalo de datas','2=Inferior a','3=Periodicidade'},;                              // aValues
                .T.,;                              // lObrigat
                NIL,;                              // bInit
                .F.,;                              // lKey
                .F.,;                              // lNoUpd
                .F.)       
                            

oStru:AddField( "De",;                          // cTitle	//'Nulo'
                "",;                          // cToolTip	//'Nulo'
                'LMP_DTDE',;                       // cIdField
                'D',;                              // cTipo
                8,;                                // nTamanho
                0,;                                // nDecimal
                Nil,;// bValid
                 {||FwFldGet('LMP_FILTRO') == '1'},;
                Nil,;                              // aValues
                .F.,;                              // lObrigat
                NIL,;                              // bInit
                .F.,;                              // lKey
                .F.,;                              // lNoUpd
                .F.)       
                
oStru:AddField( "Até",;                          // cTitle	//'Nulo'
                "",;                          // cToolTip	//'Nulo'
                'LMP_DTATE',;                       // cIdField
                'D',;                              // cTipo
                8,;                                // nTamanho
                0,;                                // nDecimal
                Nil,;// bValid
                {||FwFldGet('LMP_FILTRO') == '1'},;
                Nil,;                              // aValues
                .F.,;                              // lObrigat
                NIL,;                              // bInit
                .F.,;                              // lKey
                .F.,;                              // lNoUpd
                .F.)       
                
                
oStru:AddField( "Data",;                          // cTitle	//'Nulo'
                "",;                          // cToolTip	//'Nulo'
                'LMP_DTINF',;                       // cIdField
                'D',;                              // cTipo
                8,;                                // nTamanho
                0,;                                // nDecimal
                NIL,;                              // bValid
                {||FwFldGet('LMP_FILTRO') == '2'},;
                Nil,;                              // aValues
                .F.,;                              // lObrigat
                NIL,;                              // bInit
                .F.,;                              // lKey
                .F.,;                              // lNoUpd
                .F.)                                         
                                                                                

oModel := MPFormModel():New('TECA981', , {|oModel|E981Vld(oModel)},{|oModel|E981Proc(oModel)})

oModel:AddFields( 'LMPMASTER', /*cOwner*/, oStru, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetPrimaryKey( {} )
oModel:SetDescription( 'Parâmetros' )
oModel:GetModel( 'LMPMASTER' ):SetDescription( 'Parâmetros' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := ModelDef()
Local oStru := FWFormStruct( 2, 'LIMPEZA' )
Local oView 	:= Nil

oStru:AddGroup( "GRP1" , "Atenção", "" , 2 )	//"Parâmetros"
oStru:AddGroup( "GRP2" , "Intervalo de datas", "" , 2 )	//"Parâmetros"
oStru:AddGroup( "GRP3" , "Inferior a", "" , 2 )	//"Parâmetros"


oStru:AddField( 'LMP_ATEN',;             // cIdField
                '01',;                   // cOrdem
                "ATENÇÃO",;                // cTitulo //"Nulo"
                "ATENÇÃO",;                // cDescric //"Nulo"
                Nil,;                    // aHelp
                'N',;                    // cType
                '',;    // cPicture
                NIL,;                    // nPictVar
                '',;                     // Consulta F3
                .F.,;                    // lCanChange
                NIL,;                    // cFolder
                NIL,;                    // cGroup
                {},;                              // aValues
                Nil,;                    // nMaxLenCombo
                NIL,;                    // cIniBrow
                .T.,;                    // lVirtual
                NIL )                    // cPictVar
                
                                
oStru:AddField( 'LMP_FILTRO',;             // cIdField
                '02',;                   // cOrdem
                "Filtrar por",;                // cTitulo //"Nulo"
                "Filtrar por",;                // cDescric //"Nulo"
                Nil,;                    // aHelp
                'N',;                    // cType
                '',;    // cPicture
                NIL,;                    // nPictVar
                '',;                     // Consulta F3
                .T.,;                    // lCanChange
                NIL,;                    // cFolder
                NIL,;                    // cGroup
                { '1=Intervalo de datas','2=Inferior a'},;                              // aValues
                Nil,;                    // nMaxLenCombo
                NIL,;                    // cIniBrow
                .T.,;                    // lVirtual
                NIL )                    // cPictVar

oStru:AddField( 'LMP_DTDE',;             // cIdField
                '03',;                   // cOrdem
                "De",;                // cTitulo //"Nulo"
                "De",;                // cDescric //"Nulo"
                Nil,;                    // aHelp
                'D',;                    // cType
                '',;    // cPicture
                NIL,;                    // nPictVar
                '',;                     // Consulta F3
                .T.,;                    // lCanChange
                NIL,;                    // cFolder
                NIL,;                    // cGroup
                Nil,;                              // aValues
                Nil,;                    // nMaxLenCombo
                NIL,;                    // cIniBrow
                .T.,;                    // lVirtual
                NIL )                    // cPictVar
                
oStru:AddField( 'LMP_DTATE',;             // cIdField
                '04',;                   // cOrdem
                "Até",;                // cTitulo //"Nulo"
                "Até",;                // cDescric //"Nulo"
                Nil,;                    // aHelp
                'D',;                    // cType
                '',;    // cPicture
                NIL,;                    // nPictVar
                '',;                     // Consulta F3
                .T.,;                    // lCanChange
                NIL,;                    // cFolder
                NIL,;                    // cGroup
                Nil,;                              // aValues
                Nil,;                    // nMaxLenCombo
                NIL,;                    // cIniBrow
                .T.,;                    // lVirtual
                NIL )                    // cPictVar
                
oStru:AddField( 'LMP_DTINF',;             // cIdField
                '05',;                   // cOrdem
                "Data",;                // cTitulo //"Nulo"
                "Data",;                // cDescric //"Nulo"
                Nil,;                    // aHelp
                'D',;                    // cType
                '',;    // cPicture
                NIL,;                    // nPictVar
                '',;                     // Consulta F3
                .T.,;                    // lCanChange
                NIL,;                    // cFolder
                NIL,;                    // cGroup
                Nil,;                              // aValues
                Nil,;                    // nMaxLenCombo
                NIL,;                    // cIniBrow
                .T.,;                    // lVirtual
                NIL )                    // cPictVar                                       
                

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_LMP', oStru, 'LMPMASTER')
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_LMP', 'TELA' )

oStru:SetProperty( "LMP_ATEN" , MVC_VIEW_GROUP_NUMBER, "GRP1" )
oStru:SetProperty( "LMP_FILTRO" , MVC_VIEW_GROUP_NUMBER, "GRP1" )
oStru:SetProperty( "LMP_DTDE" , MVC_VIEW_GROUP_NUMBER, "GRP2" )
oStru:SetProperty( "LMP_DTATE" , MVC_VIEW_GROUP_NUMBER, "GRP2" )
oStru:SetProperty( "LMP_DTINF" , MVC_VIEW_GROUP_NUMBER, "GRP3" )

oView:setInsertMessage('Concluído', 'Processamento executado com sucesso')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} E981Proc()
Processando 

@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Function E981Proc(oModel)

Return MsgRun("Processando","Eliminando registros de movimentação",{|| lRet := E981Exec(oModel) })

//-------------------------------------------------------------------
/*/{Protheus.doc} E981Vld()
Validação do modelo
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Function E981Vld(oModel)
Local oLMPMaster	:= oModel:GetModel('LMPMASTER')
Local cFiltro		:= oLMPMaster:GetValue('LMP_FILTRO')
Local cAliasNew 	:= GetNextAlias()
Local cDtDe		:= oLMPMaster:GetValue('LMP_DTDE')
Local cDtAte		:= oLMPMaster:GetValue('LMP_DTATE')
Local lRet := .T.

If cFiltro == '1'
	 If Empty(oLMPMaster:GetValue('LMP_DTDE'))
	 	Help( , , "At982Dt", , "Necessário informar a data 'De' para filtragem dos dados",4,10,,,,,,)
	 	lRet := .F.
	 ElseIf Empty(oLMPMaster:GetValue('LMP_DTATE'))
	 	Help( , , "At982Dt", , "Necessário informar a data 'Até' para filtragem dos dados",4,10,,,,,,)
	 	lRet := .F.
	 ElseIf oLMPMaster:GetValue('LMP_DTDE') > oLMPMaster:GetValue('LMP_DTATE') 
	 	Help( , , "At982Dt", , "A data 'De' não pode ser mais que a data 'Até'",4,10,,,,,,)
	 	lRet := .F.	 	
	 EndIf
ElseIf cFiltro == '2'
	If Empty(oLMPMaster:GetValue('LMP_DTINF')) 
	 	Help( , , "At982Dt", , "Necessário informar a data para filtragem dos dados",4,10,,,,,,)
	 	lRet := .F.	 	
	EndIf	 		 	 	
EndIf 

If lRet 
	If !MsgYesNo('Tem certeza que deseja executar o processamento de Limpeza de movimentos?')
		Help( , , "At982Canc", , "Operação cancelada",4,10,,,,,,)
		lRet := .F.
	EndIf
EndIf	
		
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} E981Exec()
Execução do processo

@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Function E981Exec(oModel)
Local oLMPMaster	:= oModel:GetModel('LMPMASTER')
Local cFiltro		:= oLMPMaster:GetValue('LMP_FILTRO')
Local cAliasNew 	:= GetNextAlias()
Local cDtDe			:= oLMPMaster:GetValue('LMP_DTDE')
Local cDtAte		:= oLMPMaster:GetValue('LMP_DTATE')
Local cDtInf		:= oLMPMaster:GetValue('LMP_DTINF')
Local lNEof			:= .T.
Local aArea			:= GetArea()

If cFiltro == '1'
	BeginSql Alias cAliasNew 

		SELECT R_E_C_N_O_ REC FROM %table:TWI% TWI		
	
		WHERE TWI.TWI_FILIAL = %xfilial:TWI%
	  		AND TWI_QTDSAI = TWI_QTDRET 	 
	  		AND TWI.TWI_DTRET BETWEEN %Exp:cDtDe% AND %Exp:cDtAte%
	  		AND TWI.%NotDel%
	  		 	  			
	EndSql
		
ElseIf cFiltro == '2'
	BeginSql Alias cAliasNew 

		SELECT R_E_C_N_O_ REC FROM %table:TWI% TWI		
	
		WHERE TWI.TWI_FILIAL = %xfilial:TWI%
	  		AND TWI_QTDSAI = TWI_QTDRET 	 
	  		AND TWI.TWI_DTRET < 	%Exp:cDtInf%
	  		AND TWI.%NotDel%  			
	EndSql 
EndIf

Begin Transaction
	lNEof :=  (cAliasNew)->(!EOF())
	While (cAliasNew)->(!EOF())
		TWI->(dbGoto((cAliasNew)->Rec))
		RecLock("TWI",.F.)
		TWI->(dbDelete())
		TWI->(MsUnLock())
		(cAliasNew)->(DBSkip())						
	EndDo				  	
End Transaction

If lNEof 
	DbSelectArea('TWI')
	If !IsBlind()
		PACK
	EndIf	
EndIf	

RestArea(aArea)


Return .T.