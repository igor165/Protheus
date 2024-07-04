#INCLUDE "JURA124.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "FWMVCDEF.CH"   

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA124
Filtra os cadastros do assunto jurídico
Uso no cadastro de Conceções.

@param 	cProcesso  	Código do Assunto Jurídico
@author Clóvis Eduardo Teixeira
@since 23/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA124(cProcesso, cFilFiltro, lChgAll)
Local oBrowse                 

Default cProcesso   := ''   
Default cFilFiltro	:= xFilial("NWU")
Default lChgAll	    := .T.

oBrowse := FWMBrowse():New()
oBrowse:SetChgAll( lChgAll )
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NWU" )
oBrowse:SetLocate()      

If !Empty( cProcesso )
	oBrowse:SetFilterDefault( "NWU_FILIAL == '" + cFilFiltro + "' .AND. NWU_CAJURI == '" + cProcesso + "'" )    
Else	
	oBrowse:AddFilter(STR0011,"NSZ_TIPOAS IN ("+ JurTpAsJr(__CUSERID) +" ) AND D_E_L_E_T_ = ' '",.T.,.T.,"NSZ")		
EndIf	    

oBrowse:SetMenuDef('JURA124')
JurSetBSize(oBrowse, '50,50,50')
JurSetLeg(oBrowse, "NWU" )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Clóvis Eduardo Teixeira
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

aAdd( aRotina, { STR0001,  "PesqBrw" , 0, 1, 0, .T. } ) // "Pesquisar"   

If JA162AcRst('15',1)
	aAdd( aRotina, { STR0002,  "VIEWDEF.JURA124", 0, 2, 0, NIL } ) // "Visualizar"
EndIf	

If JA162AcRst('15',3)
	aAdd( aRotina, { STR0003,  "VIEWDEF.JURA124", 0, 3, 0, NIL } ) // "Incluir"
EndIf		
	
If JA162AcRst('15',4)
	aAdd( aRotina, { STR0004,  "VIEWDEF.JURA124", 0, 4, 0, NIL } ) // "Alterar"
EndIf		
	        
If JA162AcRst('15',5)
	aAdd( aRotina, { STR0005,  "VIEWDEF.JURA124", 0, 5, 0, NIL } ) // "Excluir"
EndIf		
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Contratos do Processo

@author Clóvis Eduardo Teixeira
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel   := FWLoadModel( "JURA124" )
Local oStruct  := FWFormStruct( 2, "NWU" )  
Local cGrpRest := JurGrpRest()

JurSetAgrp( 'NWU',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField("JURA124_VIEW" , oStruct , "NWUMASTER" )
oView:CreateHorizontalBox("FORMFIELD", 100)
oView:SetOwnerView( "JURA124_VIEW","FORMFIELD" )

oView:SetDescription( STR0007 ) //"Andamentos"                                                   
oView:EnableControlBar( .T. )                      

oView:setUseCursor(.F.)   

oView:SetCloseOnOk({||.T.})      

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Andamentos

@author Clóvis Eduardo Teixeira
@since 27/05/09                                                 		
@version 1.0

@obs NWUMASTER - Dados do Andamentos

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel   := NIL
Local oStruct  := FWFormStruct( 1, "NWU" ) 

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA124", /*Pre-Validacao*/, {|oX| JA124TOk(oX)} /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NWUMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Andamentos"
oModel:GetModel( "NWUMASTER" ):SetDescription( STR0009 ) // "Dados de Andamentos"   

JurSetRules( oModel, "NWUMASTER",, "NWU" )  
  
Return oModel

/*/   
//-------------------------------------------------------------------
{Protheus.doc} JA124TOk(oModel)
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 20/01/10
@version 1.0
//------------------------------------------------------------------- 
/*/
Function JA124TOk(oModel)                  
Local nOpc      := oModel:GetOperation()
Local lRet      := .T.       

if (nOpc == 3 .or. nOpc == 4)           
	if Val(oModel:GetValue('NWUMASTER','NWU_PRAZOR')) <= Val(oModel:GetValue('NWUMASTER','NWU_PRAZOM'))
		lRet := .F.
		JurMsgErro(STR0010) //O prazo de renovação interna não pode ser inferior a 7 meses. Verifique!                                                         
	Endif
	
	If lRet
		lRet := JA124ConceVal() //Funcao para validacao da nova concessao por Socio (Envolvido)
	Endif
Endif
 
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} JA105QYNRP            
Monta a query da consulta padrao de gênero.
@Param cUser    Codigo do usuario do sistema
@Return cQuery	 	Query montada

@author Juliana Iwayama Velho
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA124QNWW(cUser)
Local cQuery := ''

	cQuery := "SELECT NWV.NWV_COD, NWV.NWV_DESC, NWV.R_E_C_N_O_ NWVRECNO "
	cQuery += "  FROM "+RetSqlName("NWV")+" NWV, "+RetSqlName("NWW")+" NWW"	
	cQuery += " WHERE NWW.NWW_CUSUAR = '" +cUser+ "'"
	cQuery += "   AND NWV.NWV_COD = NWW.NWW_CGENER	"
	cQuery += "   AND NWW.NWW_FILIAL = '" +xFilial("NWW") + "' "
	cQuery += "   AND NWV.NWV_FILIAL = '" +xFilial("NWV") + "' "
	cQuery += "   AND NWW.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NWV.D_E_L_E_T_ = ' ' "
		
Return cQuery               

//-------------------------------------------------------------------
/*{Protheus.doc} JA124F3NWW             
Função de Montagem da Consulta padrao de Gênero
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA124F3NWW()
Local lRet      := .F.
Local aArea     := GetArea()
Local aPesq     := {"NWV_COD", "NWV_DESC"} 
Local cUser     := __CUSERID
Local cQuery 

	cQuery := JA124QNWW(cUser)
	
	cQuery := ChangeQuery(cQuery, .F.)
	uRetorno := ''
	RestArea( aArea )
	
	If JurF3Qry( cQuery, 'JA124F3NWW', 'NWVRECNO', @uRetorno,,aPesq,,,,,'NWV' )
		NWV->( dbGoto( uRetorno ) )
		lRet := .T.
	EndIf

Return lRet   

//-------------------------------------------------------------------
/*{Protheus.doc} JA124VencOut
Função que realiza o calculo de vencimento da Outorga
@Return dData Data de vencimento da Outorga
@author Clóvis Eduardo Teixeira
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA124VencOut() 
Local aArea  	:= GetArea()
Local dData   := cTod('')
Local cTipo		:= JurGetDados('NWV', 1, xFilial('NWV') + FwFldGet('NWU_CGENER'), 'NWV_TIPO')	
local cPeriod := '' 
	
	If cTipo  == '1'
		cPeriod  := 'A'
	ElseIF cTipo == '2'
		cPeriod  := 'M'
	EndIf                                                                     
	
  // Executa somas e subtracoes em datas com unidades de dias, meses ou anos
	dData := JurPrxData(FwFldGet('NWU_DTINIO'), Val(FwFldGet('NWU_PRAZOT')), cPeriod )

RestArea(aArea)	
Return dData  

//-------------------------------------------------------------------
/*{Protheus.doc} JA124IniPro
Função que realiza o calculo de inicio do Protocolo
@Return lRet	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA124IniPro() 
Local dData    := cTod('')

	dData := JurPrxData(FwFldGet('NWU_DTVENO'), SuperGetMV('MV_JCLDTIP',,'0'),'M', 2)

Return dData  

//-------------------------------------------------------------------
/*{Protheus.doc} JA124IniPro
Função que realiza o calculo de fim do Protocolo
@Return lRet	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA124FimPro() 
Local dData    := cTod('')

	dData := JurPrxData(FwFldGet('NWU_DTVENO'), SuperGetMV('MV_JCLDTFP',,'0'),'M', 2)

Return dData
             
//-------------------------------------------------------------------
/*{Protheus.doc} JA124RenInt()
Função que realiza o calculo do prazo de renocação interna
@Return lRet	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA124RenInt() 
Local dData    := cTod('')

	dData := JurPrxData(FwFldGet('NWU_DTVENO'), Val(FwFldGet('NWU_PRAZOR')), 'M', 2)

Return dData  

//-------------------------------------------------------------------
/*{Protheus.doc} JA124GenVal            
Validação do campo de Genero
@Param cUser    Codigo do usuario do sistema
@Return cQuery	 	Query montada
@author Clóvis Eduardo Teixeira
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA124GenVal(cGenero)
Local cQuery := ''   
Local aArea  := GetArea()
Local cAlias := GetNextAlias()
Local cUser  := __CUSERID   
Local lRet   := .F.

	cQuery := "SELECT NWV.NWV_COD, NWV.NWV_DESC, NWV.R_E_C_N_O_ NWVRECNO "
	cQuery += "  FROM "+RetSqlName("NWV")+" NWV, "+RetSqlName("NWW")+" NWW"	
	cQuery += " WHERE NWW.NWW_CUSUAR = '" +cUser+ "'"
	cQuery += "   AND NWV.NWV_COD = NWW.NWW_CGENER	"
	cQuery += "   AND NWW.NWW_FILIAL = '" +xFilial("NWW") + "' "
	cQuery += "   AND NWV.NWV_FILIAL = '" +xFilial("NWV") + "' "
	cQuery += "   AND NWW.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NWV.D_E_L_E_T_ = ' ' "
		
	cQuery := ChangeQuery(cQuery)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
	While !(cAlias)->( EOF() )
		If (cAlias)->NWV_COD == cGenero
			lRet := .T.
			Exit
		EndIf
		(cAlias)->( dbSkip() )
	End
	
	(cAlias)->(dbCloseArea())	
	RestArea(aArea)	
		
Return lRet    

//-------------------------------------------------------------------
/*{Protheus.doc} JA124QNWX            
Monta a query da consulta padrao de gênero.
@Param cUser    Codigo do usuario do sistema
@Return cQuery	 	Query montada
@author Clóvis Eduardo Teixeira
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA124QNWX(cGenero)
Local cQuery := ''
	
	cQuery := "SELECT NWX.NWX_COD, NWX.NWX_DESC, NWX.R_E_C_N_O_ NWXRECNO "
	cQuery += "  FROM "+RetSqlName("NWV")+" NWV, "+RetSqlName("NWX")+" NWX "		
	cQuery += " WHERE NWV.NWV_COD = NWX.NWX_CGENER "	
	
	if !Empty(cGenero)	
		cQuery += " AND NWX.NWX_CGENER = '"+cGenero+"'" 
	endif	
				
	cQuery += "   AND NWX.NWX_FILIAL = '" +xFilial("NWX") + "' "
	cQuery += "   AND NWV.NWV_FILIAL = '" +xFilial("NWV") + "' "
	cQuery += "   AND NWX.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NWV.D_E_L_E_T_ = ' ' "	
				
Return cQuery               

//-------------------------------------------------------------------
/*/{Protheus.doc} JA124F3NWX             
Função de Montagem da Consulta padrao de Gênero
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA124F3NWX()
Local lRet      := .F.
Local aArea     := GetArea()
Local aPesq     := {"NWX_COD", "NWX_DESC"} 
Local oModel    := FWModelActive()
Local cGenero   := oModel:GetValue("NWUMASTER", "NWU_CGENER")
Local cQuery 

	cQuery := JA124QNWX(cGenero)	
	cQuery := ChangeQuery(cQuery, .F.)
	uRetorno := ''
	RestArea( aArea )
	
	If JurF3Qry( cQuery, 'JA124F3NWX', 'NWXRECNO', @uRetorno,,aPesq,,,,,'NWX' )
		NWX->( dbGoto( uRetorno ) )
		lRet := .T.
	EndIf

Return lRet    

//-------------------------------------------------------------------
/*/{Protheus.doc} JA124EspVal            
Validação do campo de Genero
@Param cUser    Codigo do usuario do sistema
@Return cQuery	 	Query montada

@author Clóvis Eduardo Teixeira
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA124EspVal(cGenero, cEspec)
Local cQuery := ''   
Local aArea  := GetArea()
Local cAlias := GetNextAlias() 
Local lRet   := .F.
                                                  
	if !Empty(cGenero)
	
		cQuery := "SELECT NWX_CGENER "
		cQuery += "  FROM "+RetSqlName("NWX")+"  "		
		cQuery += " WHERE NWX_FILIAL = '" +xFilial("NWX") + "' "		
		cQuery += "   AND NWX_COD = '"+cEspec+"'" 					
		cQuery += "   AND D_E_L_E_T_ = ' ' "
			
		cQuery := ChangeQuery(cQuery)	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		
		While !(cAlias)->( EOF() ) 
		
			If (cAlias)->NWX_CGENER == cGenero
				lRet := .T.
				Exit
			EndIf
			(cAlias)->( dbSkip() )
		End
		
		(cAlias)->(dbCloseArea())	
		RestArea(aArea)	
	
	Else
		lRet := .T.	
	Endif
		
Return lRet  

//-------------------------------------------------------------------
/*{Protheus.doc} JA124ConsVal
Valida a Nova regra de Concessao por Socio (Envolvido)            

@Param 
@Return lRet	Permite ou nao a gravacao dos dados

@author Rodrigo Guerato
@since 17/07/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA124ConceVal()
	Local oModel
	Local lRet		 := .T.
	Local aArea	 := GetArea()
	Local aAreaNT9	 := NT9->( GetArea() )
	Local aAreaNWX := NWX->( GetArea() )
	Local aAreaNWV := NWV->( GetArea() )
	Local aAreaNWY := NWY->( GetArea() )
	Local oMdlBkp	 := FWModelActive()
	Local oMdlConc	 := FWModelActive()
	Local cJTVCONC	 := SuperGetMv("MV_JTVCONC",,"2")
	Local cJSOCAND	 := SuperGetMv("MV_JSOCAND",,"" )
	Local cJTETVCO	 := SuperGetMv("MV_JTETVCO",,"" )
	Local nLin	     := 0
	Local cTemp	 := Nil
	Local aTV	     := {}
	Local aRadio	 := {}
	Local aEstado	 := {}
	Local NAux		 := 0
	Local cGenero	 := ""
	Local cArea	 := ""
	Local cEspecie	 := ""
	Local cEstado	 := ""
	Local cEnvol	 := ""
		
	//Valida se o parametros esta preenchido
	If cJTVCONC == "1" .and. Empty(cJTETVCO)
		JurMsgErro(STR0012)
		lRet := .F.
	Endif
	
	//Valida o Estado
	If cJTVCONC == "1" .and. Empty( oMdlConc:GetValue("NWUMASTER", "NWU_ESTADO") )
		JurMsgErro(STR0023)
		lRet := .F.
	Endif
	
	//Valida abrangencia, somente para ondas Medias e Radio
	cEspecie := JurGetDados("NWX",1, xFilial("NWX") + oMdlConc:GetValue("NWUMASTER","NWU_CESPEC"), "NWX_TIPO"  )
	If cEspecie == "3" .and. Empty( oMdlConc:GetValue("NWUMASTER", "NWU_CAREA") )
		JurMsgErro(STR0024)
		lRet := .F.	
	Endif
	
	if lRet .and. cJTVCONC == "1" 
		oModel := FWLoadModel("JURA095")
		oModel:SetOperation(1) //Visualizar
		oModel:Activate()
	
		//Faz a Referencia
		oModel := oModel:GetModel("NT9DETAIL")
		
		For nLin := 1 to oModel:GetQtdLine()
		
			If !oModel:IsDeleted(nLin) .and. AllTrim( oModel:GetValue("NT9_CSITUA", nLin) ) == Alltrim( cJSOCAND ) 
				If oModel:GetValue("NT9_CTPENV", nLin) $ cJTETVCO //Considera como tipo de envolvidos
					//Realiza a Query para buscar ou outros processos
					cTemp	 := GetNextAlias()
					BeginSQL Alias cTemp
						SELECT NWV.NWV_TIPOG, NWX.NWX_TIPO, NWY.NWY_TIPO,NWU.NWU_ESTADO
						FROM %Table:NT9% NT9
						JOIN %Table:NWU% NWU ON (NT9.NT9_CAJURI = NWU.NWU_CAJURI AND NWU.NWU_FILIAL = %xFilial:NWU% AND NWU.%NotDel% )
						JOIN %Table:NWV% NWV ON (NWU.NWU_CGENER = NWV.NWV_COD AND NWV.NWV_FILIAL = %xFilial:NWV% AND NWV.%NotDel% )
						JOIN %Table:NWX% NWX ON (NWU.NWU_CESPEC = NWX.NWX_COD AND NWX.NWX_FILIAL = %xFilial:NWX% AND NWX.%NotDel%)
						LEFT JOIN %Table:NWY% NWY ON (NWU.NWU_CAREA  = NWY.NWY_COD  AND NWY.NWY_FILIAL = %xFilial:NWY% AND NWY.%NotDel%)
						WHERE UPPER(NT9.NT9_NOME) = %Exp:Upper( oModel:GetValue("NT9_NOME", nLin ))%  
						  AND NWU.NWU_COD <> %Exp:oMdlConc:GetValue("NWUMASTER","NWU_COD")% //Nao considera o registro atual
  						  AND NT9.NT9_FILIAL = %xFilial:NT9%
  						  AND NT9.%NotDel%
						ORDER BY NWV.NWV_TIPOG, NWX.NWX_TIPO, NWY.NWY_TIPO,NWU.NWU_ESTADO 						
					EndSQL
					
					aTV	     := {}
					aRadio	 := {}
					aEstado := {}
					
					(cTemp)->( dbGoTop() )
					While (cTemp)->( !Eof() )
						//Radio
						If (cTemp)->NWV_TIPOG == "1" 
							nAux := aScan(aRadio, {|X| X[1]==(cTemp)->NWX_TIPO .and. X[2]==(cTemp)->NWY_TIPO }  )
							
							If nAux > 0
								aRadio[nAux][3]++
							Else
								aAdd(aRadio, { (cTemp)->NWX_TIPO, (cTemp)->NWY_TIPO, 1 } )
							
							Endif
						//TV							
						Elseif (cTemp)->NWV_TIPOG == "2" 
							nAux := aScan( aTV, {|X| X[1] == (cTemp)->NWX_TIPO } )
							
							If nAux > 0
								aTV[nAux][2]++ 
							Else
								aAdd( aTV, { (cTemp)->NWX_TIPO, 1 } )
							Endif
						Endif
						
						//Estados
						nAux := aScan( aEstado, {|X| X[1]==(cTemp)->NWU_ESTADO .and. X[2]==(cTemp)->NWX_TIPO } )
						
						If nAux > 0
							aEstado[nAux][3]++
						Else
							aAdd( aEstado, { (cTemp)->NWU_ESTADO, (cTemp)->NWX_TIPO, 1 } )
						Endif
					
						(cTemp)->( dbSkip() )					
					EndDo
					
					//Recupera os dados da concessao em questao
					cGenero  := JurGetDados("NWV",1, xFilial("NWV") + oMdlConc:GetValue("NWUMASTER","NWU_CGENER"), "NWV_TIPOG" )
					cEspecie := JurGetDados("NWX",1, xFilial("NWX") + oMdlConc:GetValue("NWUMASTER","NWU_CESPEC"), "NWX_TIPO"  )
					cArea	  := JurGetDados("NWY",1, xFilial("NWY") + oMdlConc:GetValue("NWUMASTER","NWU_CAREA") , "NWY_TIPO"  )
					cEstado  := oMdlConc:GetValue("NWUMASTER","NWU_ESTADO")
						
					//Faz a soma da concessao atual
					If cGenero == "1"
						nAux := aScan( aRadio, {|X| X[1]==cEspecie .and. X[2]==cArea } )
						
						If nAux > 0
							aRadio[nAux][3]++
						Else
							aAdd( aRadio, {cEspecie, cArea, 1 } )
						Endif
					Elseif cGenero == "2"
						nAux := aScan( aTV, {|X| X[1]==cEspecie } )
						
						If nAux > 0
							aTV[nAux][2]++
						Else
							aAdd( aTV, { cEspecie, 1 } )
						Endif
					Endif  	
					
					nAux := aScan( aEstado, {|X| X[1]==cEstado .and. X[2]==cEspecie  } )
						
					If nAux > 0
						aEstado[nAux][3]++
					Else
						aAdd( aEstado, { cEstado, cEspecie, 1 } )
					Endif
					
					//Chama a Rotina da Validacao
					cEnvol := oModel:GetValue("NT9_NOME", nLin)
					If !JA124Valida( cEnvol, aRadio, aTV, aEstado )
						lRet := .F.
						Exit
					Endif
				Endif 
			Endif
		Next nLin
				
		//Desativa o Modelo de Dados
		oModel:DeActivate()
	Endif
	
	If Select(cTemp) > 0
		(cTemp)->( dbCloseArea() )
	Endif 
	
	
	FWModelActive( oMdlBkp )
	RestArea( aArea )
	NT9->( RestArea(aAreaNT9) )
	NWX->( RestArea(aAreaNWX) )
	NWV->( RestArea(aAreaNWV) )
	NWY->( RestArea(aAreaNWY) )
Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} JA124Valida
Realiza a validacao nos arrays calculados
           
@Param	 cExp1: Codigo e Nome do Envolvido, apenas para a mensagem
        aExp2: Array com os valores somados do Radio
        aExp3: Array com os valores somados da TV
        aExp4: Array com os valores somados do Estado
        
@Return lRet1: Continua ou nao com o a gravacao

@author Rodrigo Guerato
@since 17/07/2013
@version 1.0
/*/
//-------------------------------------------------------------------
/* Regra para validacao ( Qtde de Concessoes)
	   TV: 10 em todo pais
	       05 em VHF em todo pais
	       02 por estado, idependente de ser VHF ou UHF
//-------------------------------------------------------------------	       
	Radio: 04 Onda Media Local
	       03 Onda Media Regional
	       02 Onda Media Nacional
	       06 Frequencia Modulada
	       02 Ondas Curtas
	       03 Ondas tropicais em todo pais
	       02 Ondas tropicais por estado
*/
//-------------------------------------------------------------------
Static Function JA124Valida( cEnvolvido, aRadio, aTv, aEstado )
	Local lReturn	:= .T.
	Local nAux		:= 0
	Local nTotal	:= 0
	Local nX		:= 0
	Local cUF		:= ""
	
	//Ordena o Array
	aSort( aEstado, , , {|x,y| x[1]+x[2] < y[1]+y[2] } )
	
	//+--------------------+
	//|Validacoes da TV    |
	//+--------------------+
	For nX := 1 to Len(aTv)
		nTotal += aTv[nX][2]
	Next nX
	
	If nTotal > 10
		JurMsgErro( STR0013 + cEnvolvido )
		lReturn := .F.
	Endif
	
	If lReturn
		nAux := aScan( aTv, { |x| x[1] == "2" } ) //VHF
		
		If nAux > 0
			If aTv[nAux][2] > 5
				JurMsgErro( STR0014 + cEnvolvido )
				lReturn := .F.
			Endif
		Endif
	Endif
	
	If lReturn
		nTotal := 0
		For nX := 1 to Len(aEstado)
			If (cUF <> aEstado[nX][1])
				cUF 	:= aEstado[nX][1]
				nTotal := 0
			Endif			

			If aEstado[nX][2] $ "1/2" //So considera TV
				nTotal += aEstado[nX][3]

				If nTotal > 2
					JurMsgErro( STR0015 + cEnvolvido + "/" + cUF )
					lReturn := .F.
					Exit
				Endif
			Endif		
		Next nX
	Endif
	
	//+---------------------+
	//|Validacoes da Radio  |
	//+---------------------+
	If lReturn
		nAux := aScan( aRadio, {|x| x[1]=="3" .and. x[2]=="1" } ) //Onda Media Local
		
		If nAux > 0
			If aRadio[nAux][3] > 4
				JurMsgErro(STR0016 + cEnvolvido )
				lReturn := .F.
			Endif
		Endif		
	Endif
	
	If lReturn
		nAux := aScan( aRadio, {|x| x[1]=="3" .and. x[2]=="2" } ) //Onda Media Regional
		
		If nAux > 0
			If aRadio[nAux][3] > 3
				JurMsgErro(STR0017 + cEnvolvido )
				lReturn := .F.
			Endif
		Endif		
	Endif

	If lReturn
		nAux := aScan( aRadio, {|x| x[1]=="3" .and. x[2]=="3" } ) //Onda Media Local
		
		If nAux > 0
			If aRadio[nAux][3] > 2
				JurMsgErro(STR0018 + cEnvolvido )
				lReturn := .F.
			Endif
		Endif		
	Endif
	
	If lReturn
		nTotal := 0
		For nX := 1 to Len(aRadio)
			IIf( aRadio[nX][1]=="4", nTotal+= aRadio[nX][3], ) 
		Next nX
		
		If nTotal > 6
			JurMsgErro(STR0019 + cEnvolvido)
			lReturn := .F.
		Endif
	Endif

	If lReturn
		nTotal := 0
		For nX := 1 to Len(aRadio)
			IIf( aRadio[nX][1]=="6", nTotal+= aRadio[nX][3], ) 
		Next nX
		
		If nTotal > 2
			JurMsgErro(STR0020 + cEnvolvido)
			lReturn := .F.
		Endif
	Endif
	
	If lReturn
		nTotal := 0
		For nX := 1 to Len(aRadio)
			IIf( aRadio[nX][1]=="5", nTotal+= aRadio[nX][3], ) 
		Next nX
		
		If nTotal > 3
			JurMsgErro(STR0021 + cEnvolvido)
			lReturn := .F.
		Endif
	Endif
	
	If lReturn
		For nX := 1 to Len(aEstado)
			If aEstado[nX][2] == "5" //So considera Onda Tropical
				If aEstado[nX][3] > 2
					JurMsgErro( STR0021 + cEnvolvido + "/" + aEstado[nX][1] )
					lReturn := .F.
					Exit
				Endif
			Endif
		Next nX
	Endif
Return lReturn


//+-------------------------------------------------------------------------- 
/*/ {Protheus.doc} JA124When()
Validacao do When para o campo NWU_CAREA

@author     rodrigo.guerato
@since      26/07/2013
@return     lRet1: Habilita ou nao o campo
@version    1.0
/*/
//+--------------------------------------------------------------------------
Function JA124When()
	Local aArea	 := GetArea()
	Local aAreaNWX := NWX->( GetArea() ) 
	Local lTrava	 := SuperGetMv("MV_JTVCONC",,"2") == "1"
	Local oModel	 := FWModelActive()  
	Local oView	 := FWViewActive()
	Local nOpc		 := oModel:GetOperation()  
	Local lRet	  	 := .T.
	Local cTipo	 := ""
	
	If lTrava .and. !Empty( FwFldGet("NWU_CESPEC") )
		If nOpc == 3 .or. nOpc == 4
			cTipo := JurGetDados('NWX', 1, xFilial('NWX') + FwFldGet("NWU_CESPEC"), "NWX_TIPO")
			If cTipo == "3" //Somente Ondas Medias
				lRet := .T.
			Else
				oModel:LoadValue("NWUMASTER", "NWU_CAREA","")
				oModel:LoadValue("NWUMASTER", "NWU_DAREA","")
				oView:Refresh()
				lRet := .F.
			Endif
		Endif
	Endif
	
	RestArea( aArea )
	NWX->( RestArea( aAreaNWX ) )
Return lRet