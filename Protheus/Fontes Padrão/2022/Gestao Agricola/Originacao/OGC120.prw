#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OGC120.CH"
#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"

Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio
Static __lbaixaAuto	:= SuperGetMv('MV_AGRO207', , .F.) // Parametro baixa automática

/* {Protheus.doc} OGC120        
Gestão Financeira

@author 	Gustavo Pereira
@since 		21/03/2019
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function OGC120()
		
    Local cFiltroDef := "NJR_STATUS IN ('A','I')"

	Private oMBrowse := {}

	If !__lnewNeg .or. !__lbaixaAuto 
		Agrhelp(STR0049, STR0093, STR0094) //#AJUDA #Rotina está disponível somente para o conceito da nova comercialização e quando configurado a baixa automática. #Habilite a nova comercialização (MV_AGRO002) e a baixa automática dos títulos (MV_AGRO207) para utilizar essa rotina.
		Return
	EndIf
	
	Processa({|| fAtuAtraso()},  STR0092 )	  //Verificando previsões financeiras em atraso
	
	oMBrowse := FWMBrowse():New()	
	oMBrowse:SetAlias("NN7")
	oMBrowse:SetDescription(STR0090) // PAINEL FINANCEIRO AGRO 	
	oMBrowse:AddFilter(STR0091,cFiltroDef,.T.,.T.,"NJR") // "Somente contratos abertos ou iniciados"
		
	oMBrowse:SetMenuDef( "OGC120" )
	
	oMBrowse:AddLegend( "NN7_STATUS=='1' .OR. Empty(NN7_STATUS) ", "BR_VERDE"			, X3CboxDesc( "NN7_STATUS", "1" ) ) //"Aberto"
	oMBrowse:AddLegend( "NN7_STATUS=='2'", "BR_AMARELO"		    , X3CboxDesc( "NN7_STATUS", "2" ) ) //"Confirmado"
	oMBrowse:AddLegend( "NN7_STATUS=='3'", "BR_VERMELHO"		, X3CboxDesc( "NN7_STATUS", "3" ) ) //"Divergente"
	oMBrowse:AddLegend( "NN7_STATUS=='4'", "BR_LARANJA"			, X3CboxDesc( "NN7_STATUS", "4" ) ) //"Em Atraso"
	oMBrowse:AddLegend( "NN7_STATUS=='5'", "BR_VIOLETA"		    , X3CboxDesc( "NN7_STATUS", "5" ) ) //"Finalizado"	

  
	oMBrowse:DisableDetails()
	oMBrowse:SetAttach( .T. ) //Visualização
	oMBrowse:Activate()
	
Return()

/*{Protheus.doc} MenuDef()
@type  Function
@author francisco.nunes
@since 08/06/2018
@version 1.0
*/
Static Function MenuDef()
	Local aRotina := {} 
	
	aAdd(aRotina, {STR0086, "OGC120ICNRA('1')", 0, 4, 0, Nil})  //"Vincular Adiantamentos"
	aAdd(aRotina, {STR0087, "OGC120ICNRA('2')", 0, 4, 0, Nil}) //"Desvincular Adiantamentos"		
	aAdd(aRotina, {STR0088, "OGC120CONSPR()", 0, 2, 0, Nil } ) // # Consulta de Previs?es          	
	aAdd(aRotina, {STR0089, "OGC120BREC()", 0, 4, 0, Nil}) //"Recalcular Previsão"	
	aAdd(aRotina, {STR0028, "OGC120ACNT()", 0, 1, 0, .T.})  //'Contato'		
	
Return aRotina


/*
{Protheus.doc} OGC120FDES
Retorna a descrição dos campos parametrizados

@author gustavo.pereira
@since 21/03/2019
@version 1.0
@param cFilCtr, characters, Filial do Contrato
@param cCodCtr, characters, Código do Contrato
@type function
*/

Function OGC120FDES(cCampo)                    

	Local cRetorno  := ""
	Local cCodPagto := ""
	Local aAreaNJR  := NJR->(GetArea())	
	Local aAreaNN7  := NN7->(GetArea())	
	Local oModel    := FwModelActive()
	Local oModelNJR	:= nil
	Local oModelNN7	:= nil

	If oModel != NIL
		oModelNJR	:= oModel:GetModel("NJRUNICO")	
		oModelNN7	:= oModel:GetModel("NN7UNICO")	
			
		If !Empty(oModelNJR:GetValue("NJR_CODNGC")) .And. oModel:GetOperation() == 4
			IF cCampo = "NN7_DESPRO"
				cRetorno := Posicione('SB1',1,xFilial('SB1') + oModelNJR:GetValue("NJR_CODPRO"), 'B1_DESC')   
			endIf                  
			
			IF cCampo = "NN7_NOMENT"
				cRetorno := Posicione('NJ0',1,xFilial('NJ0')+ oModelNJR:GetValue("NJR_CODENT") + oModelNJR:GetValue("NJR_LOJENT"),'NJ0_NOME')   
			endIf

			If cCampo = "NN7_MOEREF" .AND. !Empty(oModelNJR:GetValue("NJR_CODNGC"))
				cRetorno := AgrMvSimb(oModelNJR:GetValue("NJR_MOEDA")) 
				If oModelNJR:GetValue("NJR_TIPMER") = "1" .And. oModelNJR:GetValue("NJR_MOEDA") <> 1 
					If NJR->NJR_OPERAC = "1"
						cRetorno := AgrMvSimb(oModelNJR:GetValue("NJR_MOEDAR")) 
					Else
						cRetorno := AgrMvSimb(oModelNJR:GetValue("NJR_MOEDAF"))
					Endif
				Endif
			Endif	
		EndIf
			
		RestArea(aAreaNJR)	
		RestArea(aAreaNN7)
	EndIf

Return cRetorno

/*{Protheus.doc} OGC120CINRA
//Chama função de inclusão de RA padrão do sistema
@author filipe.olegini
@since 05/12/2018
@version 1.0
@type function
*/
Function OGC120ICNRA(cAction)
	
	Local cFilLog  := ""

	//armazena valor da filial logada
	cFilLog := cFilAnt
	
	//recebe filial origem da previsão 
	cFilAnt := NN7->NN7_FILORG
	
	If cAction = "1"
		OGC120CVIN('1')
	Else
		OGC120CVIN('2')	
	Endif
	
    //devolve o valor da filial logada 
    cFilAnt := cFilLog 
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuAtraso
Função para mudar status das previsões para atrasado
@author  rafael.voltz
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fAtuAtraso()
    Local cAliasQry := GetNextAlias()

    BeginSQL Alias cAliasQry
        SELECT NN7.R_E_C_N_O_ RECNO
          FROM %table:NJR% NJR
         INNER JOIN %table:NN7% NN7 ON NN7.NN7_FILIAL = NJR.NJR_FILIAL AND NN7.NN7_CODCTR = NJR.NJR_CODCTR AND NN7.%NotDel%
         WHERE NJR.NJR_FILIAL = %xFilial:NJR%
           AND NN7.NN7_STATUS IN ("1",'') //EM ABERTO
           AND NN7.NN7_DTVENC < %Exp:dtos(dDatabase)%
		   AND NJR.NJR_STATUS IN ("A","I")
           AND NJR.%NotDel%
    EndSql

    While (cAliasQry)->(!Eof())
        NN7->(DbGoto((cAliasQry)->RECNO))
        Reclock("NN7", .F.)
            NN7->NN7_STATUS = "4" //EM ATRASO
        NN7->(MsUnlock())
        (cAliasQry)->(DbSkip())
    EndDo

     (cAliasQry)->(dbCloseArea())

Return 


/*/{Protheus.doc} OGC120CONSPR
	Função para consultar a previsão financeira.
	@type  Static Function
	@author user
	@since date
/*/
 Function OGC120CONSPR()
	Local aAreaNN7 := NN7->(GetArea())
	
	OGC150(NN7->NN7_CODCTR, .F.)	
	
	//necessário update para releitura da NN7, 
	//caso contrário a tabela perde referência 
	//e ocorre erros nas operações de vincular/desvinular
	Processa({|| oMBrowse:UpdateBrowse()}) 

	RestArea(aAreaNN7)

Return 
