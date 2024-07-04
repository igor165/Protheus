#INCLUDE "PROTHEUS.CH"
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FILEIO.CH"

//OSMAR
/*/{Protheus.doc} G001GerAnu
//TODO Descrição auto-gerada.
@author osmar.junior
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTPC857Anula()
	Local aArea     := GetArea()
	Local lRet  	:= .T.
	Local oModelGZH := FWLOADModel('GTPA850')
	Local oMdlGZH   := Nil
	Local cDocAux	:= ''
	Local cSerieAux	:= ''
	Local cAliasTmp := GetNextAlias()

	If BuscaNFE(@cDocAux, @cSerieAux)
	
		// verificando se registro já gerado para evitar errorlog de chave duplicada
		BeginSql alias cAliasTmp
			SELECT * FROM %table:GZH% GZH
			WHERE GZH_FILIAL = %xFilial:GZH% AND
				  GZH_NOTA   = %Exp:cDocAux% AND
				  GZH_SERIE  = %Exp:cSerieAux% AND
				  GZH_CLIENT = %Exp:GZH->GZH_CLIENT% AND
				  GZH_LOJA   = %Exp:GZH->GZH_LOJA% AND 
				  GZH.%notDel%
		EndSql 
		
		If (cAliasTmp)->(Eof())
			oModelGZH:SetOperation(MODEL_OPERATION_INSERT)
			oModelGZH:Activate()
		
			oMdlGZH	:= oModelGZH:GetModel( 'FIELDGZH' ) 
		
			lRet := oMdlGZH:LoadValue( "GZH_NOTA"	, cDocAux ) .And. ;
					oMdlGZH:LoadValue( "GZH_SERIE"	, cSerieAux) .And. ;
					oMdlGZH:LoadValue( "GZH_CLIENT"	, GZH->GZH_CLIENT) .And. ;
					oMdlGZH:LoadValue( "GZH_LOJA"	, GZH->GZH_LOJA) .And. ;
					oMdlGZH:LoadValue( "GZH_EVENTO"	, '01'	) .And. ;
					oMdlGZH:LoadValue( "GZH_UMUINI" , GZH->GZH_UMUINI  ) .And. ;
					oMdlGZH:LoadValue( "GZH_CMUINI" , GZH->GZH_CMUINI  ) .And. ;
					oMdlGZH:LoadValue( "GZH_DMUINI" , GZH->GZH_DMUINI  ) .And. ;
					oMdlGZH:LoadValue( "GZH_UMUFIM" , GZH->GZH_UMUFIM  ) .And. ;
					oMdlGZH:LoadValue( "GZH_CMUFIM" , GZH->GZH_CMUFIM  ) .And. ;
					oMdlGZH:LoadValue( "GZH_DMUFIM" , GZH->GZH_DMUFIM  ) .And. ;
					oMdlGZH:LoadValue( "GZH_VEIC"   , GZH->GZH_VEIC    ) .And. ;
					oMdlGZH:LoadValue( "GZH_PLACA"  , GZH->GZH_PLACA   ) .And. ;
					oMdlGZH:LoadValue( "GZH_RENAVA" , GZH->GZH_RENAVA  ) .And. ;
					oMdlGZH:LoadValue( "GZH_UFVEI"  , GZH->GZH_UFVEI   ) .And. ;
					oMdlGZH:LoadValue( "GZH_INFQ"   , GZH->GZH_INFQ    ) .And. ;
					oMdlGZH:LoadValue( "GZH_UFPER"	, GZH->GZH_UFPER   ) .And. ;						
					oMdlGZH:LoadValue( "GZH_PEDIDO" , GZH->GZH_PEDIDO  ) .And. ;
					oMdlGZH:LoadValue( "GZH_COMPVL"	, GZH->GZH_COMPVL  ) .And. ;
					oMdlGZH:LoadValue( "GZH_DSAIDA" , GZH->GZH_DSAIDA  ) .And. ;
					oMdlGZH:LoadValue( "GZH_HSAIDA" , GZH->GZH_HSAIDA  ) .And. ;
					oMdlGZH:LoadValue( "GZH_REGEST" , GZH->GZH_REGEST  ) .And. ;
					oMdlGZH:LoadValue( "GZH_MODAL"  , GZH->GZH_MODAL  ) .And. ;
					oMdlGZH:LoadValue( "GZH_TPFRET" , GZH->GZH_TPFRET  ) .And. ;
					oMdlGZH:LoadValue( "GZH_CODGQ2" , GZH->GZH_CODGQ2  ) .And. ;
					oMdlGZH:LoadValue( "GZH_STATUS"	, '1'	)	
			
			If !Empty(oMdlGZH:GetValue( "GZH_CODGQ2"))
				lRet := .F.
				FwAlertHelp("ANULACAO","Não é possível gerar anulação de uma nota do tipo Excesso de Bagagem.") 	
			Endif
			
			If ( lRet .And. oModelGZH:VldData() )
				lRet := oModelGZH:CommitData()
				If lRet
					FwAlertSuccess("ANULACAO",'Gerado CTE de anulação Série:'+cSerieAux+'  Número:'+cDocAux) 
				EndIf 
			EndIf
		else
			FwAlertWarning("ANULACAO",'CTE de anulação já gerado, Série:'+cSerieAux+'  Número:'+cDocAux) 
		EndIf
		(cAliasTmp)->(DbCloseArea())

	else
			FwAlertHelp("ANULACAO",'Documento de entrada não encontrado com NF de origem: '+GZH->GZH_NOTA+'  e Série:'+GZH->GZH_SERIE) 			
	EndIf

	If Valtype(oModelGZH) = "O"
		oModelGZH:DeActivate()
		oModelGZH:Destroy()
		oModelGZH:= nil
	EndIf
	
	RestArea(aArea)

Retur lRet


/*/{Protheus.doc} BuscaNFE
//TODO Descrição auto-gerada.
@author osmar.junior
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function BuscaNFE(cDocAux,cSerieAux)
	Local lRet		:= .F.
	Local aAreaSD1 	:= SD1->(GetArea())
	Local cNota 	:= GZH->GZH_NOTA
	Local cSerie 	:= GZH->GZH_SERIE
	Local cCliFor 	:= GZH->GZH_CLIENT
	Local cLoja		:= GZH->GZH_LOJA
 
	SD1->(DbSetOrder(19))
	If SD1->(DbSeek(xFilial('SD1')+PadR(cNota,TamSx3('F2_DOC')[1])+PadR(cSerie,TamSx3('F2_SERIE')[1])+cCliFor+PadR(cLoja,TamSx3('F2_LOJA')[1])))
		lRet	:= .T.
		cDocAux	:= SD1->D1_DOC
		cSerieAux	:= SD1->D1_SERIE
	EndIf

RestArea(aAreaSD1)

Return lRet
