#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSAO35.CH' 
#INCLUDE "FWMVCDEF.CH" 

#DEFINE JO_APTJOR  1
#DEFINE JO_DATAPT  2
#DEFINE JO_HORAPT  3
#DEFINE JO_FILORI  4
#DEFINE JO_VIAGEM  5
#DEFINE JO_NMAX    5

#DEFINE JU_CODMOT  1
#DEFINE JU_APTJOR  2
#DEFINE JU_FILORI  3
#DEFINE JU_VIAGEM  4
#DEFINE JU_DATAPT  5
#DEFINE JU_HORAPT  6
#DEFINE JU_CODPAR  7
#DEFINE JU_MOTAPT  8
#DEFINE JU_NLINHA  9
#DEFINE JU_LDEL   10
#DEFINE JU_NMAX   10

Static aAptJus	   	:= {}
Static dDatIniJor 	:= CToD('')
Static dDatFimJor 	:= CToD('')


//-------------------------------------------------------------------
/*TMSAO35

Rotina de apontamento da jornada de trabalho do motorista
                                                                                        
@author  Caio Murakami
@since   22/11/2012
@version 1.0      
*/
//-------------------------------------------------------------------

Function TMSAO35( aRotAuto,aItensAuto, nOpcAuto )
Local aCoors 		:= FWGetDialogSize( oMainWnd )
Local cFiltroDA4 	:= ""
Local cFiltroDEW 	:= ""
Local lAptJor		:= SuperGetMv("MV_CONTJOR",,.F.) //-- Apontamento da jornada de trabalho do motorista
Local oDlgPrinc
Local oPanelUp, oFWLayer, oPanelDown, oBrowseUp, oBrowseDown, oRelacDAO  
Local aDate			:= {} 

Default aRotAuto 		:= NIL
Default aItensAuto   := {}

If !lAptJor
	Help(,1,"TMSAO3002" ) //-- Jornada nao habilitada
	Return
EndIf

If aRotAuto == Nil
	
	If Pergunte("TMSAO35")
		
		cFiltroDA4 := " DA4_COD >= '" + mv_par01 + "' .And. DA4_COD <= '" + mv_par02 + "' "		

		If FindFunction("GetFuncArray")
			//-- Retorna a data do fonte FwBrwRelation
			GetFuncArray('__FWBrwRelation', , , , aDate,)
			
			If Len(aDate) > 0			
				//-- Data do fonte deve ser superior a 29/04/2013 para executar o filtro no grid filho
				If CtoD( dToC(aDate[1]) ) >= CtoD( "29/04/2013" )   	  	
		  			cFiltroDEW := " DtoS(DEW->DEW_DATAPT) >= '" + DToS(mv_par03) + "' .And. DtoS(DEW->DEW_DATAPT) <= '" + DToS(mv_par04) + "' "	 
		  		EndIf  		  		
			EndIf
		EndIf		
		
		//-- Força inicialização das variaveis STATIC
		aAptJus	  := {}		 
		dDatIniJor := CToD('')
		dDatFimJor := CToD('')
		
		DEFINE MSDIALOG oDlgPrinc TITLE STR0001 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL
		
		DEW->( dbSetOrder(2) )
		oFWLayer := FWLayer():New() //-- Cria novo Layer
		oFWLayer:Init( oDlgPrinc, .F., .T. )
		oFWLayer:AddLine( 'UP', 40, .F. ) //-- Adiciona linha com 70% da tela
		oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' ) //-- Adiciona coluna com 100% da tela
		oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
		
		oFWLayer:AddLine( 'DOWN', 60, .F. )//-- Adiciona linha com 30% da tela
		oFWLayer:AddCollumn( 'LEFT' , 100, .T., 'DOWN' )//-- Coluna para a linha adicionada com 100% da tela
		oPanelDown := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' )
		
		//-- Browse superior vinculado com estrutura oPanelUp criada
		oBrowseUp:= FWmBrowse():New()
		oBrowseUp:SetOwner( oPanelUp )
		oBrowseUp:SetDescription( STR0001 )
		oBrowseUp:SetAlias( 'DA4' )
		oBrowseUp:SetMenuDef( 'TMSAO35' )
		oBrowseUp:DisableDetails()
		oBrowseUp:SetFilterDefault(cFiltroDA4)
		oBrowseUp:SetProfileID( '1' )
		oBrowseUp:ForceQuitButton()
		oBrowseUp:Activate()
		
		
		//-- Browse superior vinculado com estrutura oPanelDown criada
		oBrowseDown:= FWMBrowse():New()
		oBrowseDown:SetOwner( oPanelDown )
		oBrowseDown:SetDescription( STR0001 )
		oBrowseDown:SetMenuDef( '' )
		oBrowseDown:DisableDetails()
		oBrowseDown:SetAlias( 'DEW' )
		oBrowseDown:SetFilterDefault(cFiltroDEW)
		//-- Legendas do browse
		oBrowseDown:AddLegend('DEW_STATUS == "1"',"GREEN" ,STR0008)
		oBrowseDown:AddLegend('DEW_STATUS == "2"',"RED"   ,STR0009)
		oBrowseDown:AddLegend('DEW_STATUS == "3"',"YELLOW",STR0010)
		oBrowseDown:SetProfileID( '2' )
		oBrowseDown:Activate()
		
		//-- Realiza relacionamento entre os 2 browses criados
		oRelacDAO:= FWBrwRelation():New()
		oRelacDAO:AddRelation( oBrowseUp , oBrowseDown , { {"DEW_FILIAL","xFilial('DEW')"},{"DEW_CODMOT","DA4_COD"}} )
		oRelacDAO:Activate()
		
		ACTIVATE MSDIALOG oDlgPrinc CENTER
	EndIf
	
EndIf

Return

//-------------------------------------------------------------------
/*MenuDef
@author  Caio Murakami
@since   22/01/2013
@version 1.0      
*/
//-------------------------------------------------------------------

Static Function MenuDef()  
Local aRot := {}   

	aAdd( aRot, { STR0004				  	, 'VIEWDEF.TMSAO35', 0, 4, 0, .F. } )	//-- Alterar
	aAdd( aRot, { STR0005   				, 'VIEWDEF.TMSAO35', 0, 2, 0, .F. } )	//-- Visualizar	
	aAdd( aRot, { STR0006  					, 'VIEWDEF.TMSAO35', 0, 8, 0, .F. } )	//-- Imprimir
	aAdd( aRot, { STR0007 					, 'VIEWDEF.TMSAO35', 0, 9, 0, .F. } )	//-- Copiar

Return aRot

//-------------------------------------------------------------------
/*ModelDef
Model dos Parametros da Jornada de Trabalho

@author  Caio Murakami
@since   21/01/2013
@version 1.0      
*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel 	   	:= FwLoadModel('OMSA040')
Local oStruDEW	 		:= FwFormStruct(1,"DEW")
Local bFiltroDEW		:= {}

/*
@param aLoadFilter      Estrutura de filtro
                        [n][1] cIdField do formulário de destino
                        [n][2] cIdField ou expressão do formulário de destino
                        [n][3] Operador Relacional  (Opcional, default MVC_LOADFILTER_EQUAL )
                                   MVC_LOADFILTER_EQUAL               Igual a
                                   MVC_LOADFILTER_NOT_EQUAL           Diferente de
                                   MVC_LOADFILTER_LESS                Menor que
                                   MVC_LOADFILTER_LESS_EQUAL          Menor que ou Igual a
                                   MVC_LOADFILTER_GREATER             Maior que
                                   MVC_LOADFILTER_GREATER_EQUAL Maior que ou Igual a
                                   MVC_LOADFILTER_CONTAINS            Contém
                                   MVC_LOADFILTER_NOT_CONTAINS  Não Contém
                                   MVC_LOADFILTER_IS_CONTAINED  Está Contido Em
                                   MVC_LOADFILTER_IS_NOT_CONTAINED Não Está Contido Em

*/    

Pergunte("TMSAO35",.F.)

If Empty( dDatIniJor ) .And. Empty( dDatFimJor )
	AO35SetVar( mv_par03, mv_par04 )
EndIf

bFiltroDEW := {  {"DEW_DATAPT", " '"+dToS(dDatIniJor)+"' " , MVC_LOADFILTER_GREATER_EQUAL }  , {"DEW_DATAPT", " '"+DtoS(dDatFimJor)+"' ", MVC_LOADFILTER_LESS_EQUAL  } } 

If mv_par05 != 4
	Aadd( bFiltroDEW , {"DEW_STATUS", " '"+cValToChar(mv_par05)+"' ", MVC_LOADFILTER_EQUAL } )
EndIf

//-- Altera função de gravação do Model
oModel:bCommit	:= {|oModel|TMSAO35Grv(oModel)}

oModel:GetModel("OMSA040_DA4"):SetOnlyView( .T. ) 

oModel:AddGrid("MdGridDEW","OMSA040_DA4",oStruDEW, { |oModel, nLine, cAction | PreVldDEW(oModel, nLine, cAction ) }, { |oModel| PosVldDEW( oModel ) } )

oModel:SetRelation("MdGridDEW",{{"DEW_FILIAL","xFilial('DEW')"},{"DEW_CODMOT","DA4_COD"}},DEW->(IndexKey(2))) 

//-- Filtro do GRID
oModel:GetModel("MdGridDEW"):SetLoadFilter(bFiltroDEW)

//-- Permite GRID sem dados
oModel:GetModel("MdGridDEW"):SetOptional(.T.)

//-- Define campos que não podem se repetir da linha
oModel:GetModel("MdGridDEW"):SetUniqueLine( { 'DEW_APTJOR', 'DEW_FILORI', 'DEW_VIAGEM', 'DEW_DATAPT', 'DEW_HORAPT' } )
								
Return oModel

//-------------------------------------------------------------------
/* ViewDef
Definicao da View 

@author  Caio Murakami
@since   21/01/2013
@version 1.0
*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oStruDEW := FwFormStruct( 2,"DEW")
Local oStruDA4	:= FwFormStruct( 2,"DA4")//,{|cCampo|  AllTrim(cCampo) + "|" $ 'DA4_COD|DA4_NOME|DA4_NREDUZ|DA4_CGC|DA4_NUMCNH|' } )
Local oModel   := FwLoadModel('TMSAO35')            
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField('VwFieldDA4', oStruDA4 , 'OMSA040_DA4') 
oView:AddGrid('VwGridDEW'  , oStruDEW , 'MdGridDEW')                                

oView:CreateHorizontalBox('CABECALHO',40)  
oView:CreateHorizontalBox('GRID',60)
oView:SetOwnerView('VwFieldDA4','CABECALHO')   
oView:SetOwnerView('VwGridDEW' ,'GRID')   
 
DEW->( DbGoTo(0) )

Return oView 

//-------------------------------------------------------------------
/* PreVldDEW
Pré Validação do apontamento

@author  Caio Murakami
@since   05/03/2013
@version 1.0
*/
//-------------------------------------------------------------------
 
Static Function PreVldDEW( oMdlGRD, nLine, cAction ) 

Local cTipApt 	:= oMdlGRD:GetValue("DEW_TIPAPT")
Local lRet 		:= .T.
Local cCodMot	:= ''
Local oModel	:= oMdlGRD:GetModel()
Local nPosLine := oMdlGrd:GetLine()	
Local nMaxLine := oMdlGrd:Length()
Local nI	   	:= 0
Local nPos		:= 0

cCodMot := oModel:GetModel( "OMSA040_DA4" ):GetValue( "DA4_COD" )

If cAction == "DELETE" 
	If AllTrim( FunName() ) == "TMSAO35" 
		If AllTrim( cTipApt ) == "1"
			Help('',1,'TMSAO3517') //-- Somente é possível excluir apontamentos manuais
			lRet := .F.	
		Else 
			For nI := nMaxLine To 1 Step -1
				oMdlGRD:GoLine(nI)
				If !oMdlGrd:IsDeleted() 
					If nI >= nPosLine
						If nI <> nPosLine
							Help('',1,'TMSAO3512') //-- Não é permitido excluir este registro.     
							lRet := .F.
							Exit
						EndIf					
					Else
						Exit					
					EndIf
				EndIf									
			Next nI
		EndIf
	EndIf
	
	oMdlGRD:GoLine(nPosLine)			
	
	If lRet .And. oMdlGRD:GetValue( 'DEW_STATUS' ) <> '1' 
   	nPos := Ascan( aAptJus, { | x | x[JU_NLINHA] == nPosLine } ) 
   	If nPos > 0	
   		aAptJus[nPos,JU_LDEL] := .T.
		Else
			//-- Alimenta ARRAY com itens que estão pendentes de justicativa 
			//-- para que a justicativa seja excluída em caso de correção do horário pelo usuário
			AO35AptJus(oMdlGRD,nPosLine,,.T.)
		EndIf	   		
	EndIf
	
ElseIf cAction == "UNDELETE" 

	If AllTrim( FunName() ) == "TMSAO35" 
		For nI := nPosLine To nMaxLine
			oMdlGrd:GoLine( nI )
			If !oMdlGrd:IsDeleted() 
				Help('',1,'TMSAO3518') //-- A recuperação de apontamentos excluídos deve ser feita do último para o primeiro.
				lRet := .F.	     
				Exit
			EndIf
		Next nI
	EndIf
		
	oMdlGRD:GoLine(nPosLine)
	
	If lRet .And. oMdlGRD:GetValue( 'DEW_STATUS' ) <> '1'
   	nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nPosLine } ) 
   	If nPos > 0	
   		aAptJus[nPos,JU_LDEL] := .F.
		EndIf	   		
	EndIf
    
EndIf

Return lRet 

//-------------------------------------------------------------------
/* PosVldDEW
Pos Validação do apontamento

@author  Caio Murakami
@since   22/01/2013
@version 1.0
*/
//-------------------------------------------------------------------

Static Function PosVldDEW( oMdlGrid )

Local cFilOri  		:= oMdlGrid:GetValue("DEW_FILORI")
Local cViagem 	 	:= oMdlGrid:GetValue("DEW_VIAGEM")
Local cAptJor		:= oMdlGrid:GetValue("DEW_APTJOR")
Local dDatApt		:= oMdlGrid:GetValue("DEW_DATAPT")
Local cHorApt		:= oMdlGrid:GetValue("DEW_HORAPT")
local cTipApt		:= oMdlGrid:GetValue("DEW_TIPAPT") //-- 1=Automatico;2=Manual
Local cObsApt		:= oMdlGrid:GetValue("DEW_OBSAPT")
Local nOperation	:= oMdlGrid:GetOperation()
Local cCodMot 	 	:= M->DA4_COD

Local aAreaDTQ		:= DTQ->( GetArea() )
Local aArea			:= GetArea()
Local aSaveLine		:= FWSaveRows()

Local lRet 			:= .T.
Local lVgeLgaDis	:= .F. //-- Viagens de longa distancia
Local lVgeSemana  	:= .F. //-- Viagem de mais de 1 semana

Local aAptJor		:= {}
Local aTipVei		:= {}

Local nCount		:= 0
Local lAptManual	:= Iif(cTipApt=='2',.T.,.F.)
Local cSerTms		:= ""
Local cTipTra		:= "" 
Local nPosLine    	:= 0
Local nTotLine    	:= 0

If nOperation <> 5
	
	If !Empty(cFilOri) .And. !Empty(cViagem)
		//-- Atualiza variaveis sertms, tiptra, atipve, lVgeLgaDis, lVgeSemana
		AO35Vge( cFilOri, cViagem , @cSerTMS , @cTipTra , @aTipVei , @lVgeLgaDis , @lVgeSemana )
	EndIf
	
	nPosLine := oMdlGrid:GetLine()
	nTotLine := oMdlGrid:Length()
	
	For nCount := 1 To nTotLine
		oMdlGrid:GoLine(nCount)
		If !oMdlGrid:IsDeleted()
			//-- O item em edicao não deve ser adicionado no array
			If cAptJor + DToS(dDatApt) + cHorApt <> oMdlGrid:GetValue("DEW_APTJOR") + DToS(oMdlGrid:GetValue("DEW_DATAPT") ) + oMdlGrid:GetValue("DEW_HORAPT")
				Aadd( aAptJor, Array(JO_NMAX) )
				aAptJor[ Len(aAptJor), JO_APTJOR ] := oMdlGrid:GetValue("DEW_APTJOR")
				aAptJor[ Len(aAptJor), JO_DATAPT ] := oMdlGrid:GetValue("DEW_DATAPT")
				aAptJor[ Len(aAptJor), JO_HORAPT ] := oMdlGrid:GetValue("DEW_HORAPT")
				aAptJor[ Len(aAptJor), JO_FILORI ] := oMdlGrid:GetValue("DEW_FILORI")
				aAptJor[ Len(aAptJor), JO_VIAGEM ] := oMdlGrid:GetValue("DEW_VIAGEM")
			EndIf
			//-- Alimenta ARRAY com itens que estão pendentes de justicativa 
			//-- para que a justicativa seja excluída em caso de correção do horário pelo usuário
			AO35AptJus(oMdlGrid,nCount)
		EndIf
	Next nCount

	oMdlGrid:GoLine(nPosLine)
	
	If lRet
		lRet := AO35VldApt(cAptJor,;  		//-- Codigo do apontamento
	   						dDatApt,;  		//-- Data do apontamento
							cHorApt,;  		//-- Hora do apontamento
							aAptJor,;  		//-- Array com os apontamentos relacionados
							cFilOri,;  		//-- Filial de origem
							cViagem,;  		//-- Viagem
							lAptManual,;	//-- Apontamento manual
							cCodMot,;   	//-- Codigo do motorista
							cSerTms,;   	//-- Servico de transporte
							cTipTra,;   	//-- Tipo de transporte
							aTipVei,;   	//-- Tipos de veiculos
							lVgeLgaDis,;	//-- Viagens de longa distancia
							lVgeSemana,;	//-- Viagem maior que 1 semana
							cObsApt ,;     //-- Observacao do apontamento
							oMdlGrid)
					
	EndIf
	
EndIf

FwRestRows( aSaveLine )
RestArea( aAreaDTQ )
RestArea( aArea )

Return lRet
               
//-------------------------------------------------------------------
/* AO35VldAp
Valida os apontamentos

@author  Caio Murakami
@since   29/01/2013
@version 1.0
*/
//-------------------------------------------------------------------
Static Function AO35VldApt( cAptJor, dDatApt , cHorApt , aAptJor,  cFilOri, cViagem, lAptManual , cCodMot , cSerTms , cTipTra , aTipVei, lVgeLgaDis, lVgeSemana, cObsApt, oMdlGrid )
Local lRet 				:= .T.
Local cHora				:= ""
Local cTempo			:= ""
Local cAtraso			:= ""
Local cParDEY			:= ""
Local nCount			:= 1
Local aAuxApt			:= {}
Local aAux				:= {}
Local nLenAux			:= 0
Local cAux				:= ""
Local cAtivChg   		:= GetMV('MV_ATIVCHG',,'')
Local cAtivSai   		:= GetMV('MV_ATIVSAI',,'')
Local aAreaDTW			:= {}
Local dDatPre			:= CToD("")		//-- Data prevista
Local cHorPre			:= ""				//-- Hora prevista
Local lContVei			:= SuperGetMv("MV_CONTVEI",,.F.)
Local nPos				:= 0
Local nLine				:= 0
Local nPosLine    		:= 0
Local nLinePrx    		:= 0
Local nLineAnt    		:= 0
Local dDatAntApt  		:= CToD("")
Local cHorAntApt  		:= ""
Local dDatPrxApt  		:= CToD("")
Local cHorPrxApt  		:= ""
Local aUltApt     		:= {}
Local dDatDes			:= CToD("")
Local cHorDes        	:= ""
Local aAreaDA4       	:= DA4->(GetArea())
Local oDataModel 
Local nRecNo
Local cMensagem			:= ""

Default lVgeLgaDis 	:= .F.
Default lVgeSemana 	:= .F.
Default cObsApt	 	:= ""
Default cFilOri	 	:= ""
Default cViagem	 	:= ""

/*-------------------------------------------------------
T1 - Tempo Tolerancia Saida
T2 - Tempo Tolerancia Chegada
T3 - Tempo de tolerancia de direcao continua

P1 - Tempo Permanencia na filial de origem
P2 - Tempo Permanencia na filial de transferencia
P3 - Tempo Permanencia na filial de destino

J1 - Tempo Entrada em descanso
J2 - Tempo Descanso entre a jornada
J3 - Tempo de refeicao
J4 - Tempo da jornada de trabalho
J5 - Tempo de viagem de longa distancia
J6 - Tempo Descanso para viagens longa distancia
J7 - Tempo Descanso semanal para viagens longa distancia
J8 - Tempo permitido para direcao continua
J9 - Tempo viagens semanais
-----------------------------------------------------------*/

//-- Para apontamentos manuais não é permitido lancar inicio e fim de viagem
If lAptManual 
	
	If cAptJor == "IV"
		lRet := .F.
		Help(" ",,"TMSAO3501") //-- IV - Inicio de Viagem não pode ser apontado manualmente.
		
	ElseIf cAptJor == "FV"
		lRet	:= .F.
		Help(" ",,"TMSAO3502") //-- FV - Fim de Viagem não pode ser apontado manualmente.
	EndIf

ElseIf lAptManual .And. lContVei
	
	If cAptJor == "IJ"
		lRet := .F.
		Help(" ",,"TMSAO3510") //-- Inicio de Jornada não pode ser apontado manualmente com MV_CONTVEI ativo.		
	ElseIf cAptJor == "FJ"
		lRet	:= .F.
		Help(" ",,"TMSAO3511") //-- Fim de Jornada não pode ser apontado manualmente com MV_CONTVEI ativo.
	EndIf
	
EndIf

If lRet	
	//-- Obtem a data e hora do último apontamento anterior a linha atual 
	nPosLine := oMdlGrid:GetLine()
	nLineAnt := nPosLine - 1
	If nLineAnt <= 0
		If oMdlGrid:GetOperation() <> 4
			aUltApt  := AO35UltApt( cCodMot )
		else
			oDataModel := oMdlGrid:GetData() 
			nRecNo := oDataModel[nPosLine][4]
			If !Empty(nRecNo)			
				aUltApt  := AO35UltApt( cCodMot,,AllTrim(STR(nRecNo)) )
			Else
				aUltApt  := AO35UltApt( cCodMot )
			EndIF
		EndIF
		If !Empty(aUltApt)
			dDatAntApt := aUltApt[1]
			cHorAntApt := aUltApt[2]
		Else
			dDatAntApt := CToD("01/01/80")
			cHorAntApt := "0000"
		EndIf				
	Else
		oMdlGrid:GoLine(nLineAnt)
		dDatAntApt := oMdlGrid:GetValue( "DEW_DATAPT" )
		cHorAntApt := oMdlGrid:GetValue( "DEW_HORAPT" )
	EndIf		
	
	nLinePrx := nPosLine + 1
	If nLinePrx > oMdlGrid:Length()
		dDatPrxApt := dDataBase
		cHorPrxApt := Substr(StrTran(Time(),":",""),1,4)
	Else		
		oMdlGrid:GoLine(nLinePrx)
		dDatPrxApt := oMdlGrid:GetValue( "DEW_DATAPT" )
		cHorPrxApt := oMdlGrid:GetValue( "DEW_HORAPT" )
	EndIf		
	
	oMdlGrid:GoLine(nPosLine)
	
	//-- Nao permite informar apontamentos anteriores a ultima data e hora apontados
	lRet := ValDatHor(dDatApt,cHorApt,dDatAntApt,cHorAntApt,,STR0020,STR0021,,.F.,@cMensagem) //-- Atual ## Apontamento Anterior
	If lRet
		//-- Nao permite informar apontamentos superiores a ultima data e hora apontados
		lRet := ValDatHor(dDatPrxApt,cHorPrxApt,dDatApt,cHorApt,,STR0022,STR0020,,.F.,@cMensagem) //-- Próximo Apontamento ## Atual
	EndIf	

	If !lRet .And. !Empty(cMensagem)
		Help('',1,'TMSAO3521',,cMensagem,3,1) //-- Controle da jornada de trabalho do motorista: Existem apontamentos com data/hora superiores a data/hora que está sendo realizada o apontamento atual. Não é permitido o apontamento com datas inferiores as que já estão registradas  no controle de jornada do motorista.
	EndIf

EndIf	

If lRet
	For nCount := 1 To Len(aAptJor)
		//-- Inicio Jornada
		If cAptJor == "IJ"
			
			If aAptJor[nCount,JO_APTJOR] == "IJ" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FJ"
				Aadd( aAuxApt, aAptJor[nCount] )
			EndIf
			
		//-- Inicio de Descanco
		ElseIf cAptJor == "ID"
			
			If ( aAptJor[nCount,JO_APTJOR] == "ID" .Or. aAptJor[nCount,JO_APTJOR] == "FD" .Or. ; 
			   aAptJor[nCount,JO_APTJOR] == "IP" .Or.  aAptJor[nCount,JO_APTJOR] == "FP"  .Or.;
			   aAptJor[nCount,JO_APTJOR] == "IV" )	   

				Aadd( aAuxApt, aAptJor[nCount] )
			

			ElseIf aAptJor[nCount,JO_APTJOR] == "IR" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FR"			
				Aadd( aAux  , aAptJor[nCount] )
				Aadd( aAuxApt, aAptJor[nCount] )

			ElseIf aAptJor[nCount,JO_APTJOR] == "IE" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FE"			
				Aadd( aAux  , aAptJor[nCount] )
				Aadd( aAuxApt, aAptJor[nCount] )
			EndIf	

		//-- Fim Descanso
		ElseIf cAptJor == "FD"
			
			If aAptJor[nCount,JO_APTJOR] == "ID" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FD"
				Aadd( aAuxApt , aAptJor[nCount] )
			EndIf
			
		//-- Inicio Parada
		ElseIf cAptJor == "IP"			
			If aAptJor[nCount,JO_APTJOR] == "IP" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FP"
				Aadd( aAuxApt , aAptJor[nCount] )
			EndIf
		
		//-- Fim Parada
		ElseIf cAptJor == "FP"			
			If aAptJor[nCount,JO_APTJOR] == "IP" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FP"
				Aadd( aAuxApt , aAptJor[nCount] )
			EndIf
			
		//-- Inicio Refeicao
		ElseIf cAptJor == "IR"

			If ( aAptJor[nCount,JO_APTJOR] == "ID" .Or. aAptJor[nCount,JO_APTJOR] == "FD" .Or. ; 
			   aAptJor[nCount,JO_APTJOR] == "IP" .Or.  aAptJor[nCount,JO_APTJOR] == "FP"  .Or.;
			   aAptJor[nCount,JO_APTJOR] == "IV" )	   

				Aadd( aAuxApt, aAptJor[nCount] )
			

			ElseIf aAptJor[nCount,JO_APTJOR] == "IR" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FR"	

				Aadd( aAux  , aAptJor[nCount] )

				Aadd( aAuxApt, aAptJor[nCount] )

			ElseIf aAptJor[nCount,JO_APTJOR] == "IE" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FE"	

				Aadd( aAux  , aAptJor[nCount] )
				Aadd( aAuxApt, aAptJor[nCount] )

			EndIf	
					
		//-- Fim Refeicao
		ElseIf cAptJor == "FR"
			
			If aAptJor[nCount,JO_APTJOR] == "IR" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FR"
				Aadd( aAuxApt , aAptJor[nCount] )
			EndIf
		
		//-- Inicio Espera
		ElseIf cAptJor == "IE"
			
			If aAptJor[nCount,JO_APTJOR] == "ID" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FD" 
				Aadd( aAuxApt, aAptJor[nCount] )
			

			ElseIf aAptJor[nCount,JO_APTJOR] == "IR" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FR"			
				Aadd( aAux  , aAptJor[nCount] )
			

			ElseIf aAptJor[nCount,JO_APTJOR] == "IE" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FE"			
				Aadd( aAux  , aAptJor[nCount] )
			EndIf	

		//-- Fim Espera
		ElseIf cAptJor == "FE"
			
			If aAptJor[nCount,JO_APTJOR] == "IE" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FE"
				Aadd( aAuxApt , aAptJor[nCount] )
			EndIf


		//-- Fim Viagem
		ElseIf cAptJor == "FV"
			
			If (aAptJor[nCount,JO_APTJOR] == "IV" .Or. aAptJor[nCount,JO_APTJOR] == "FV") .And. aAptJor[nCount,JO_FILORI] == cFilOri .And. aAptJor[nCount,JO_VIAGEM] == cViagem
				Aadd( aAuxApt, aAptJor[nCount] )
			Else				
				Aadd( aAuxApt, aAptJor[nCount] )
			EndIf				
							
		//-- Fim Jornada
		ElseIf cAptJor == "FJ"
		
			If aAptJor[nCount,JO_APTJOR] == "IJ" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FJ"
				Aadd( aAuxApt, aAptJor[nCount] )
			EndIf
			
			If aAptJor[nCount,JO_APTJOR] == "ID" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FD" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "IR" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FR" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "IE" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FE" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "IP" .Or. ;
			   aAptJor[nCount,JO_APTJOR] == "FP" 
				Aadd( aAux, aAptJor[nCount] )
			EndIf
			
		EndIf
		
	Next nCount
	
	nLenAux := Len(aAuxApt)
	
	If nLenAux > 0 .Or. Len(aAux) > 0
		nLine := oMdlGrid:GetLine()
		//-- Inicio Jornada
		If cAptJor == "IJ"
			If nLenAux > 0 .And. aAuxApt[Len(aAuxApt),JO_APTJOR] == "IJ" 
				lRet := .F.
				Help(" ",,"TMSAO3509")  //-- Não são permitidos apontamentos do mesmo tipo seguidos.
			Else				
				//-- J2 - Tempo Descanso entre as jornadas
				cParDEY:= "J2"
				cTempo := AO35Param(cParDEY,cSerTMS,cTipTra,aTipVei)
				cHora  := TmsTotHora( aAuxApt[ nLenAux, JO_DATAPT ], aAuxApt[ nLenAux, JO_HORAPT ], dDatApt, cHorApt )
				//-- verifica se motorista descanso o minimo necessário
				If Val(cTempo) > Val(cHora) .And. AO35GerBlq( cParDEY , cSerTMS, cTipTra , aTipVei )
					AO35AptJus( oMdlGrid, nLine, cParDEY,, "2", STR0011, cTempo, cHora ) 
				Else				     
					oMdlGrid:SetValue("DEW_STATUS", "1")
			   		
					If (nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nLine } ) ) > 0
			   			aAptJus[nPos,JU_LDEL] := .T.
					EndIf		   		
		   	
					aAux := {}
					//-- Retorna ultima viagem finalizada do motorista
					aAux := AO35Vge(,,,,,,,.T.,cCodMot )
					
					If Len(aAux) > 0 .And. lRet
						cFilOri := aAux[4]
						cViagem := aAux[5]
					
						AO35Vge( cFilOri, cViagem , cSerTMS , cTipTra , aTipVei , lVgeLgaDis , @lVgeSemana ,,)
					
						If lVgeSemana
							//-- Tempo Descanso entre as jornadas
							aUltApt := AO35UltApt( cCodMot, 'FJ' )
							cParDEY := "J7"
							cTempo  := AO35Param(cParDEY,cSerTMS,cTipTra,aTipVei)
							cHora	  := TmsTotHora( aUltApt[1], aUltApt[2], dDatApt , cHorApt )
						
							If Val(cTempo) > Val(cHora) .And. AO35GerBlq( cParDEY , cSerTMS, cTipTra , aTipVei )
								AO35AptJus( oMdlGrid, nLine, cParDEY,, "2", STR0012, cTempo, cHora ) 
							Else
								oMdlGrid:SetValue("DEW_STATUS", "1")
						   	If (nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nLine } ) ) > 0
						   		aAptJus[nLine,JU_LDEL] := .T.
						   	EndIf			
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf				
			
		//-- Inicio Viagem
		ElseIf cAptJor == "IV"
		
			aAreaDTW := DTW->( GetArea() )
			DTW->( dbSetOrder(4) )
			If DTW->( MsSeek( xFilial("DTW") + cFilOri + cViagem + cAtivSai + cFilAnt ) )
				dDatPre := DTW->DTW_DATPRE
				cHorPre := DTW->DTW_HORPRE
				cParDEY := "T1"
				cTempo  := AO35Param(cParDEY,cSerTMS,cTipTra,aTipVei)
				cHora	:= TmsTotHora(dDatPre,cHorPre,dDatApt,cHorApt)

				If Val(cHora) > Val(cTempo) .And. AO35GerBlq( cParDEY , cSerTMS, cTipTra , aTipVei )
					AO35AptJus( oMdlGrid, nLine, cParDEY,, "2", STR0013, cTempo, cHora ) 
				Else
					oMdlGrid:SetValue("DEW_STATUS", "1")
			   	If (nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nLine } ) ) > 0
			   		aAptJus[nPos,JU_LDEL] := .T.
			   	EndIf			
				EndIf
			
			EndIf
			RestArea( aAreaDTW )
			
		//-- Inicio Parada
		ElseIf cAptJor == "IP"		
			
			If nLenAux > 0 .And. aAuxApt[Len(aAuxApt),JO_APTJOR] == "IP" 
				lRet := .F.
				Help(" ",,"TMSAO3509")  //-- Não são permitidos apontamentos do mesmo tipo seguidos.
			ElseIf nLenAux > 0 .And. aAuxApt[nLenAux,JO_APTJOR] <> "FP"
				Help("",1,'TMSAO3513') //-- Inicio de refeicao nao pode estar em aberto
				lRet := .F.			 
			EndIf
			
		//-- Fim Parada
		ElseIf cAptJor == "FP"		
			
			If nLenAux > 0 .And. aAuxApt[Len(aAuxApt),JO_APTJOR] == "FP" 
				lRet := .F.
				Help(" ",,"TMSAO3509")  //-- Não são permitidos apontamentos do mesmo tipo seguidos.
			EndIf
			
		//-- Inicio Descanso
		ElseIf cAptJor == "ID"  
			lRet	:= VldAptOpen(aAuxApt,nLenAux,aAux)

			//--------------------------------------------------
			//-- J8 - Direção continua
			//--------------------------------------------------
			If lRet
				
				//-- Tempo de direção continua
				cHora 	:= TContDrive( cAptJor, dDatApt, cHorApt , aAuxApt )

				//-- Tempo Permitido
				cTempo	:= MaxDirCont(cSerTMS,cTipTra,aTipVei)

				If !Empty(cHora) .And. Val(cHora) > Val(cTempo) .And. AO35GerBlq( "J8" , cSerTMS, cTipTra , aTipVei )
					AO35AptJus( oMdlGrid, nLine, cParDEY,, "2", STR0016, cTempo, cHora ) 
				Else
					oMdlGrid:SetValue("DEW_STATUS", "1")
					If (nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nLine } ) ) > 0
						aAptJus[nPos,JU_LDEL] := .T.
					EndIf	
				EndIf
				
			EndIf

		//-- Fim Descanso
		ElseIf cAptJor == "FD"
			
			If nLenAux > 0 .And. aAuxApt[nLenAux,JO_APTJOR] == "ID"
				cHora	 := TmsTotHora( aAuxApt[nLenAux,JO_DATAPT] , aAuxApt[nLenAux,JO_HORAPT] , dDatApt , cHorApt )
				//-- J6 - Tempo Descanso para viagens longa distancia
				//-- JA - Tempo Descanso para viagens com distância continua
				cParDEY	:= Iif(lVgeLgaDis,"J6","JA")
				cTempo 	:= AO35Param(cParDEY,cSerTMS,cTipTra,aTipVei)

				If Val(cHora) > Val(cTempo) .And. AO35GerBlq( cParDEY , cSerTMS, cTipTra , aTipVei )
					AO35AptJus( oMdlGrid, nLine, cParDEY,, "2", STR0014, cTempo, cHora ) 
				Else
					oMdlGrid:SetValue("DEW_STATUS", "1")
					If (nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nLine } ) ) > 0
						aAptJus[nPos,JU_LDEL] := .T.
					EndIf			
				EndIf
			Else
				lRet := .F.
				Help(" ",,'TMSAO3503') //-- ID - Inicio do Descanso deve estar em aberto.
			EndIf
			
		//-- Inicio Refeição
		ElseIf cAptJor == "IR"  
			lRet	:= VldAptOpen(aAuxApt,nLenAux,aAux)

			//--------------------------------------------------
			//-- J8 - Direção continua
			//--------------------------------------------------
			If lRet
				
				//-- Tempo de direção continua
				cHora 	:= TContDrive( cAptJor, dDatApt, cHorApt , aAuxApt )

				//-- Tempo Permitido
				cTempo	:= MaxDirCont(cSerTMS,cTipTra,aTipVei)

				If !Empty(cHora) .And. Val(cHora) > Val(cTempo) .And. AO35GerBlq( "J8" , cSerTMS, cTipTra , aTipVei )
					AO35AptJus( oMdlGrid, nLine, cParDEY,, "2", STR0016, cTempo, cHora ) 
				Else
					oMdlGrid:SetValue("DEW_STATUS", "1")
					If (nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nLine } ) ) > 0
						aAptJus[nPos,JU_LDEL] := .T.
					EndIf	
				EndIf
				
			EndIf

		//-- Fim Refeicao
		ElseIf cAptJor == "FR"

			If nLenAux > 0 .And. aAuxApt[nLenAux,JO_APTJOR] == "IR"
				cHora	  := TmsTotHora( aAuxApt[nLenAux,JO_DATAPT], aAuxApt[nLenAux,JO_HORAPT] , dDatApt , cHorApt )
				//-- J3 - Tempo de refeição
				cParDEY := "J3"
				cTempo  := AO35Param(cParDEY,cSerTMS,cTipTra,aTipVei)
				
				//-- Se o tempo gasto excede o tempo previsto deve-se justificar
				If Val(cHora) > Val(cTempo) .And. AO35GerBlq( cParDEY , cSerTMS, cTipTra , aTipVei )
					AO35AptJus( oMdlGrid, nLine, cParDEY,, "2", STR0015, cTempo, cHora ) 
				ElseIf Val(cHora) < Val(cTempo) .And. AO35GerBlq( cParDEY , cSerTMS, cTipTra , aTipVei )
					AO35AptJus( oMdlGrid, nLine, cParDEY,, "2", STR0015, cTempo, cHora ) 
				Else
					oMdlGrid:SetValue("DEW_STATUS", "1")
					If (nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nLine } ) ) > 0
						aAptJus[nPos,JU_LDEL] := .T.
					EndIf			
				EndIf
				
			Else
				lRet := .F.
				Help(" ",,"TMSAO3504") //-- IR - Inicio de Refeição deve estar em aberto.
			EndIf
			
		//-- Inicio Espera
		ElseIf cAptJor == "IE"  			
			lRet	:= VldAptOpen(aAuxApt,nLenAux,aAux)

		//-- Fim Espera
		ElseIf cAptJor == "FE"

			If nLenAux > 0 .And. aAuxApt[nLenAux,JO_APTJOR] == "IE"  
				cHora	  := TmsTotHora( aAuxApt[nLenAux,JO_DATAPT], aAuxApt[nLenAux,JO_HORAPT] , dDatApt , cHorApt )
				
				oMdlGrid:SetValue("DEW_STATUS", "1")
				If (nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nLine } ) ) > 0
					aAptJus[nPos,JU_LDEL] := .T.
				EndIf	
					
			Else
				lRet := .F.
				Help("",1,'TMSAO3520') //-- Para realizar o apontamento de FE - Fim de Espera o apontamento de IE - Início de Espera deve estar em aberto.       
			EndIf

		//-- Fim Viagem
		ElseIf cAptJor == "FV" .And. nLenAux > 0 
		
			If Ascan( aAuxApt, { | e | e[JO_APTJOR]+DToS(e[JO_DATAPT])+e[JO_HORAPT] == cAptJor+DtoS(dDatApt)+cHorApt}) == 0
				Aadd( aAuxApt, Array(JO_NMAX) )
				nLenAux := Len(aAuxApt)
				aAuxApt[ Len(aAuxApt), JO_APTJOR ] := cAptJor
				aAuxApt[ Len(aAuxApt), JO_DATAPT ] := dDatApt
				aAuxApt[ Len(aAuxApt), JO_HORAPT ] := cHorApt
				aAuxApt[ Len(aAuxApt), JO_FILORI ] := cFilOri
				aAuxApt[ Len(aAuxApt), JO_VIAGEM ] := cViagem
			EndIf				
         
			ASort(aAuxApt,,,{ | x, y | DToS(x[JO_DATAPT]) + x[JO_HORAPT] >= DToS(y[JO_DATAPT]) + y[JO_HORAPT] } )
			
			cHora  := ""
			dDatDes:= CToD("")
			cHorDes:= ""
			//-- J8 - Tempo permitido para direcao continua
			cParDEY:= "J8"
			//-- T3 - Tempo de tolerancia de direcao continua
			cTempo := StrTran( IntToHora( TmsHrToInt(AO35Param(cParDEY,cSerTMS,cTipTra,aTipVei),3) + TmsHrToInt( AO35Param("T3",cSerTMS,cTipTra,aTipVei), 3 ), 3 ), ":", "" ) 
			
			//-- Verifica tempo de direcao entre os intervalos de refeição, descanso e jornada
			For nCount := 1 To nLenAux
				If (aAuxApt[nCount,JO_APTJOR] == "FD" .Or. aAuxApt[nCount,JO_APTJOR] == "FR" .Or. aAuxApt[nCount,JO_APTJOR] == "IJ") .And. !Empty(dDatDes)
					cHora := TmsTotHora( aAuxApt[nCount,JO_DATAPT], aAuxApt[nCount,JO_HORAPT], dDatDes, cHorDes )  
					If Val(cHora) > Val(cTempo)
						Exit
					EndIf
				Else
					If aAuxApt[nCount,JO_APTJOR] == "FV" .Or. ;
						aAuxApt[nCount,JO_APTJOR] == "IR" .Or. ;
						aAuxApt[nCount,JO_APTJOR] == "ID" .Or. ; 
						aAuxApt[nCount,JO_APTJOR] == "FJ"
						dDatDes := aAuxApt[nCount,JO_DATAPT]
						cHorDes := aAuxApt[nCount,JO_HORAPT]
					EndIf						
				EndIf
			Next nCount

			//-- Verifica tempo de direcao quando ocorreu o primeiro descanco, a primeira refeição ou o fim da jornada
			If Empty(cHora) .Or. Val(cHora) <= Val(cTempo)
				cHora  := ""
				dDatDes:= CToD("")
				cHorDes:= ""
				For nCount := 1 To nLenAux
					If aAuxApt[nCount,JO_APTJOR] == "IV" .And. !Empty(dDatDes)
						cHora := TmsTotHora( aAuxApt[nCount,JO_DATAPT], aAuxApt[nCount,JO_HORAPT], dDatDes, cHorDes )  
						Exit
					Else
						If aAuxApt[nCount,JO_APTJOR] == "IR" .Or. ;
							aAuxApt[nCount,JO_APTJOR] == "ID" .Or. ;
							aAuxApt[nCount,JO_APTJOR] == "FJ" 
							dDatDes := aAuxApt[nCount,JO_DATAPT]
							cHorDes := aAuxApt[nCount,JO_HORAPT]
						EndIf
					EndIf					
				Next nCount
			EndIf				
			
			If !Empty(cHora) .And. Val(cHora) > Val(cTempo) .And. AO35GerBlq( cParDEY , cSerTMS, cTipTra , aTipVei )
				AO35AptJus( oMdlGrid, nLine, cParDEY,, "2", STR0016, cTempo, cHora ) 
			Else
				oMdlGrid:SetValue("DEW_STATUS", "1")
				If (nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nLine } ) ) > 0
					aAptJus[nPos,JU_LDEL] := .T.
				EndIf			
			
				aAreaDTW := DTW->( GetArea() )
				DTW->( dbSetOrder(4) )
				If DTW->( MsSeek( xFilial("DTW") + cFilOri + cViagem + cAtivChg + cFilAnt ) )
					dDatPre := DTW->DTW_DATPRE
					cHorPre := DTW->DTW_HORPRE
					cParDEY := "T2"
					cTempo  := AO35Param(cParDEY,cSerTMS,cTipTra,aTipVei)
					cHora	  := TmsTotHora(dDatPre,cHorPre,dDatApt,cHorApt)
					If Val(cHora) > Val(cTempo) .And. AO35GerBlq( cParDEY , cSerTMS, cTipTra , aTipVei )
						AO35AptJus( oMdlGrid, nLine, cParDEY,, "2", STR0017, cTempo, cHora ) 
					Else
						oMdlGrid:SetValue("DEW_STATUS", "1")
				   	If (nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nLine } ) ) > 0
				   		aAptJus[nPos,JU_LDEL] := .T.
			   		EndIf			
					EndIf
				EndIf
				RestArea( aAreaDTW )			
			EndIf
			
		ElseIf cAptJor == "FJ"
			
			If nLenAux > 0 .And. aAuxApt[Len(aAuxApt),JO_APTJOR] == "FJ"
				lRet := .F.
				Help(" ",,"TMSAO3506") //-- IJ - Inicio da Jornada deve estar em aberto.
			ElseIf Len(aAux) > 0  
				//-- Verifica se inicio de refeicao ou inicio de descanso está em aberto
				If aAux[Len(aAux),JO_APTJOR] == "IR"
					lRet := .F.
					Help(" ",,"TMSAO3507") //-- IR - Inicio de Refeição em aberto.
				ElseIf aAux[Len(aAux),JO_APTJOR] == "ID"
					lRet := .F.
					Help(" ",,"TMSAO3508")  //-- ID - Inicio do Descanso em aberto.
				EndIf
			EndIf
			
			If lRet
				//-- Ordenação decrescente para verificar ultimo inicio de jornada
				Asort( aAuxApt ,,, {|x,y| DToS( x[JO_DATAPT] )+ x[JO_HORAPT] >= DToS( y[JO_DATAPT] ) + y[JO_HORAPT] } )
				nPos := Ascan( aAuxApt,{ | e | e[JO_APTJOR] == "IJ" } )
				
				If nPos > 0
					cHora   := TmsTotHora( aAuxApt[nPos,JO_DATAPT] , aAuxApt[nPos,JO_HORAPT] , dDatApt , cHorApt )
					
					//-- Retorna tempo do array 
					cAux	:= RetTimeArr(aAux , aAuxApt[nPos,JO_DATAPT] , dDatApt )

					//-- Tempo da jornada de trabalho
					cParDEY := "J4"
					cTempo  := Transform( AO35Param(cParDEY,cSerTMS,cTipTra,aTipVei) , PesqPict("DEY","DEY_TEMPO") )
					
					If !Empty(cAux)
						cHora	:= IntToHora( TmsHrToInt(cHora) - TmsHrToInt(cAux,2) )
					EndIf					

					If TmsHrToInt(cHora,2) > TmsHrToInt(cTempo) .And. AO35GerBlq( cParDEY , cSerTMS, cTipTra , aTipVei )
						AO35AptJus( oMdlGrid, nLine, cParDEY,, "2", STR0018, cTempo, cHora , IntToHora( TmsHrToInt(cHora,2) - TmsHrToInt(cTempo) )  ) 
					Else
						oMdlGrid:SetValue("DEW_STATUS", "1")
						If (nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nLine } ) ) > 0
							aAptJus[nPos,JU_LDEL] := .T.
						EndIf			
					EndIf
				EndIf

				Asort( aAuxApt ,,, {|x,y| DToS( x[JO_DATAPT] )+ x[JO_HORAPT] <= DToS( y[JO_DATAPT] ) + y[JO_HORAPT] } )
				
				If nLenAux > 0 .And. aAuxApt[nLenAux,JO_APTJOR] == "FV"
					//-- J1 - Tempo Entrada em descanso
 					cParDEY := "J1"
					cTempo  := AO35Param(cParDEY,cSerTMS,cTipTra,aTipVei)
					cHora   := TmsTotHora( aAuxApt[nLenAux,JO_DATAPT] , aAuxApt[nLenAux,JO_HORAPT] , dDatApt , cHorApt )
					
					If Val(cHora) > Val(cTempo) .And. AO35GerBlq( cParDEY , cSerTMS, cTipTra , aTipVei )
						AO35AptJus( oMdlGrid, nLine, cParDEY,, "2", STR0019, cTempo, cHora ) 
					Else
						oMdlGrid:SetValue("DEW_STATUS", "1")
						If (nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nLine } ) ) > 0
							aAptJus[nPos,JU_LDEL] := .T.
				  		EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		If cAptJor == "FJ"
			lRet := .F.
			Help(" ",,"TMSAO3506") //-- IJ - Inicio da Jornada deve estar em aberto.
		ElseIf cAptJor == "FP"
			lRet := .F.
			Help(" ",,"TMSAO3519") //-- IP - Inicio da Parada deve estar em aberto.				
		ElseIf cAptJor == "FD"
			lRet := .F.
			Help(" ",,'TMSAO3503') //-- ID - Inicio do Descanso deve estar em aberto.
		ElseIf cAptJor == "FR"
			lRet := .F.
			Help(" ",,"TMSAO3504") //-- IR - Inicio de Refeição deve estar em aberto.
		ElseIf cAptJor == "FE"
			lRet	:= .F. 
			Help(" ",,"TMSAO3520") //-- Para realizar o apontamento de FE - Fim de Espera o apontamento de IE - Início de Espera deve estar em aberto.       
		EndIf
	EndIf
EndIf

RestArea(aAreaDA4)

Return lRet

//-------------------------------------------------------------------
/* VldAptOpen
Valida os apontemos IE, ID e IR em aberto

@author  Caio Murakami
@since   30/09/2019
@version 1.0
*/
//-------------------------------------------------------------------
Static Function VldAptOpen( aAuxApt , nLenAux , aAux )
Local lRet		:= .T. 
Local cMensagem	:= ""

If nLenAux > 0 
	
	cMensagem	:= CHR(10) + CHR(13) + aAuxApt[nLenAux,JO_APTJOR] + " - " + DTOC( aAuxApt[nLenAux,JO_DATAPT] ) + " - " + Transform( aAuxApt[nLenAux,JO_HORAPT] , "@R 99:99" )
	
	If aAuxApt[nLenAux,JO_APTJOR] == "IR"
		Help("",1,'TMSAO3516',,cMensagem,3,1)  //-- Inicio de refeicao nao pode estar em aberto
		lRet := .F.
	ElseIf aAuxApt[nLenAux,JO_APTJOR] == "IE"
		Help("",1,'TMSAO3519',,cMensagem,3,1)  //-- O apontamento de IE - Início de Espera não pode estar em aberto.  
		lRet	:= .F. 
	ElseIf aAuxApt[nLenAux,JO_APTJOR] == "ID"
		Help("",1,'TMSAO3515',,cMensagem,3,1)  //-- Inicio de descanso nao pode estar em aberto
		lRet := .F.	
	EndIf
Else
	cMensagem	:= CHR(10) + CHR(13) + aAux[Len(aAux),JO_APTJOR] + " - " + DTOC( aAux[Len(aAux),JO_DATAPT] ) + " - " + Transform( aAux[Len(aAux),JO_HORAPT], "@R 99:99" )
	
	If Len(aAux) > 0 .And. aAux[Len(aAux),JO_APTJOR] == "IR"
		Help("",1,'TMSAO3516',,cMensagem,3,1)  //-- Inicio de refeicao nao pode estar em aberto
		lRet := .F.
	ElseIf Len(aAux) > 0 .And. aAux[Len(aAux),JO_APTJOR] == "IE"
		Help("",1,'TMSAO3519',,cMensagem,3,1)  //-- O apontamento de IE - Início de Espera não pode estar em aberto.  
		lRet	:= .F. 
	ElseIf Len(aAux) > 0 .And. aAux[Len(aAux),JO_APTJOR] == "ID"
		Help("",1,'TMSAO3515',,cMensagem,3,1)  //-- Inicio de descanso nao pode estar em aberto
		lRet := .F.	
	EndIf	
EndIf

Return lRet

//-------------------------------------------------------------------
/* AO35Vge
Atualiza variaveis Servico de viagem, tipo de transporte, tipos de veiculos 
Retorna ultima viagem

@author  Caio Murakami
@since   20/02/2013
@version 1.0
*/
//-------------------------------------------------------------------

Static Function AO35Vge( cFilOri, cViagem , cSerTMS , cTipTra , aTipVei , lVgeLgaDis , lVgeSemana , lUltVge , cCodMot ) 
Local aAreaDTQ  	:= DTQ->( GetArea() ) 
Local aAreaDTR  	:= DTR->( GetArea() ) 
Local cTempo	 	:= ""
Local cTmpVge	 	:= "" 
Local aRet			:= {}
Local cQuery		:= ""
Local cAliasQry	

Default cFilOri := ""
Default cViagem := ""
Default cSerTMS := ""
Default cTipTra := ""
Default aTipVei := {}
Default lVgeLgaDis := .F.
Default lVgeSemana := .F.
Default lUltVge := .F.
Default cCodMot := ""

If lUltVge //-- Retorna ultimo FV - Fim de Viagem

	cAliasQry := GetNextAlias() 
	
	cQuery := " SELECT * FROM "  + RetSQLName("DEW") + " DEW "
	cQuery += " WHERE		DEW_FILIAL 	= '" + xFilial("DEW") + "' "
	cQuery += " 	AND   DEW_CODMOT 	= '" + cCodMot + "' " 
	cQuery += "		AND 	DEW_APTJOR	= 'FV' "
	cQuery += " 	AND D_E_L_E_T_ 	= ' ' "
	cQuery += "		ORDER BY DEW_DATAPT DESC "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.)  
  
	If (cAliasQry)->( !Eof() ) 	 	
		aRet :=  { (cAliasQry)->DEW_APTJOR, (cAliasQry)->DEW_DATAPT,(cAliasQry)->DEW_HORAPT , (cAliasQry)->DEW_FILORI ,(cAliasQry)->DEW_VIAGEM	} 
	EndIf			

Else

	DTQ->( dbSetOrder(2) ) 
	If DTQ->( MsSeek( xFilial("DTQ") + cFilOri + cViagem ) )
		cSerTMS 	:= DTQ->DTQ_SERTMS
		cTipTra		:= DTQ->DTQ_TIPTRA
		DTR->( dbSetOrder(1) )
		DA3->( dbSetOrder(1) )  
		
		If DTR->( MsSeek( xFilial("DTR") + cFilOri + cViagem ) )
	            
	 		//-- J5 - Tempo de viagens de longa distancia
		   cTempo  := AO35Param("J5",cSerTMS,cTipTra,aTipVei)
		   cTmpVge := TmsTotHora(DTR->DTR_DATINI,DTR->DTR_HORINI,DTR->DTR_DATFIM,DTR->DTR_HORFIM)
	
			While DTR->( !Eof() ) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == ( xFilial("DTR") + cFilOri + cViagem ) 
			   //-- Tipos de veículos que estão na viagem
				If DA3->( MsSeek( xFilial("DA3") + DTR->DTR_CODVEI ) )				   
					Aadd( aTipVei , { cFilOri + cViagem , DA3->DA3_TIPVEI  } )
				EndIf					
				DTR->( dbSkip() ) 
			EndDo
						
			If Val(cTmpVge) > Val(cTempo)
				lVgeLgaDis := .T.
				
				//-- J9 - Tempo de viagens semanais
		   		cTempo  := AO35Param("J9",cSerTMS,cTipTra,aTipVei)
		  	 	
		  	 	//-- Se a duracao da viagem é maior que 1 semana
				If Val(cTmpVge) > Val(cTempo)
					lVgeSemana := .T.
				EndIf  

			EndIf		
		EndIf 	
	EndIf
EndIf

RestArea( aAreaDTR ) 
RestArea( aAreaDTQ )  
Return aRet
 
//-------------------------------------------------------------------
/* AO35Param
Retorna o tempo dos parametros da jornada

@author  Caio Murakami
@since   22/01/2013
@version 1.0
*/
//-------------------------------------------------------------------
Function AO35Param( cCodPar , cSerTMS, cTipTra , aTipVei )
Local cQuery   	:= ""
Local cAliasQry	:= GetNextAlias() 
Local lTipVei		:= .F. 
Local nCount		:= 0  
Local nCountPar
Local aParam   	:= {}   
Local cTempo		:= ""

Default cCodPar	:= ""
Default cSerTMS := ""
Default aTipVei := {} 
Default cTipTra := ""

/*-------------------------------------------------------
T1 - Tempo Tolerancia Saida
T2 - Tempo Tolerancia Chegada 
T3 - Tempo de tolerancia de direcao continua   

P1 - Tempo Permanencia na filial de origem
P2 - Tempo Permanencia na filial de transferencia
P3 - Tempo Permanencia na filial de destino  

J1 - Tempo Entrada em descanso
J2 - Tempo Descanso entre a jornada
J3 - Tempo de refeicao
J4 - Tempo da jornada de trabalho                  
J5 - Tempo de viagem de longa distancia
J6 - Tempo Descanso para viagens longa distancia
J7 - Tempo Descanso semanal para viagens longa distancia   
J8 - Tempo permitido para direcao continua 
J9 - Tempo viagens semanais  
JA - Tempo Descanso para viagens com distância continua
-----------------------------------------------------------*/
               
cQuery := " SELECT * FROM  " + RetSQLName("DEY") + " DEY "
cQuery += " WHERE DEY_FILIAL = '" + xFilial("DEY")+ "' " 
cQuery += " AND DEY_CODPAR   = '" + cCodPar + "' "
If !Empty(cTipTra)
	cQuery += " AND DEY_TIPTRA   = '" + cTipTra	+ "' " 
EndIf 
If !Empty(cSerTMS)
	cQuery += " AND DEY_SERTMS = '" +cSerTMS + "' "
EndIf
cQuery += " AND D_E_L_E_T_   = ' ' " 
 
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.)  

While (cAliasQry)->( !Eof() ) 	
	Aadd( aParam , { (cAliasQry)->DEY_FILIAL, (cAliasQry)->DEY_CODPAR, (cAliasQry)->DEY_TIPTRA, (cAliasQry)->DEY_SERTMS , (cAliasQry)->DEY_TIPVEI, (cAliasQry)->DEY_TEMPO } )								
	(cAliasQry)->( dbSkip() )
EndDo   

For nCountPar := 1 To Len(aParam)
   
   //-- Percorre array aTipVei para verificar se há algum tempo exclusivo para o tipo de veículo
   For nCount := 1 To Len(aTipVei)
		If aTipVei[nCount,2] == aParam[nCountPar,5] 
			lTipVei 	:= .T. 
			cTempo 	:= aParam[nCountPar,6]
		EndIf
	Next nCount 	
	
	//-- Caso não encontre tempo exclusivo para tipo de veiculo   
	If !lTipVei
		cTempo 	:= aParam[nCountPar,6]	   
   EndIf
   
Next nCountPar

(cAliasQry)->( DBCloseArea() )	

Return cTempo

//-------------------------------------------------------------------
/* AO35GerBlq
Identifica se o parâmetro irá gerar bloqueio

@author  Caio Murakami
@since   23/10/2019
@version 1.0
*/
//-------------------------------------------------------------------
Static Function AO35GerBlq( cCodPar , cSerTMS, cTipTra , aTipVei )
Local aAreaDEY	:= DEY->( GetArea() )
Local lRet		:= .F.
Local cAliasQry	:= GetNextAlias()
Local cQuery	:= ""
Local nCount	:= 1

Default cCodPar	:= ""
Default cSerTMS := ""
Default aTipVei := {} 
Default cTipTra := ""

cQuery := " SELECT * FROM  " + RetSQLName("DEY") + " DEY "
cQuery += " WHERE DEY_FILIAL = '" + xFilial("DEY")+ "' " 
cQuery += " AND DEY_CODPAR   = '" + cCodPar + "' "
If !Empty(cTipTra)
	cQuery += " AND DEY_TIPTRA   = '" + cTipTra	+ "' " 
EndIf 
If !Empty(cSerTMS)
	cQuery += " AND DEY_SERTMS = '" +cSerTMS + "' "
EndIf

If Len(aTipVei) > 0
	cQuery	+= " AND DEY_TIPVEI IN ( "
	For nCount := 1 To Len(aTipVei)
		cQuery	+= "'" + aTipVei[nCount,2] + "'"
		If nCount <> Len(aTipVei)
			cQuery	+= ","
		EndIf
	Next nCount 
	cQuery	+= " ) "
EndIf

cQuery += " AND D_E_L_E_T_   = ' ' " 
 
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.)  

While (cAliasQry)->( !Eof() ) 	
	lRet	:= .T.

	If DEY->(ColumnPos("DEY_GERBLQ")) > 0 
		If (cAliasQry)->DEY_GERBLQ == "2"
			lRet	:= .F. 
		EndIf
	EndIf

	(cAliasQry)->( dbSkip() )
EndDo   


RestArea( aAreaDEY )
Return lRet

//-------------------------------------------------------------------
/* TMSAO35Grv
Função de gravação do model

@author  Caio Murakami
@since   08/02/2013
@version 1.0
*/
//-------------------------------------------------------------------
Function TMSAO35Grv(oModel)

Local aAreaAtu := GetArea()
Local lRet 		:= .T.
Local nOpc		:= oModel:GetOperation()
Local cCodMot	:= M->DA4_COD  
Local nI			:= 0	
Local nPosLine := 0
Local nTotLine := 0
Local cAptJus 	:= ""
Local aDatSal  := {}
Local cAptJor  := ""
Local dDatApt  := CToD("")
Local oMdlGrid	 

Begin Transaction

	oMdlGrid	:= oModel:GetModel("MdGridDEW")
	nPosLine	:= oMdlGrid:GetLine()
	nTotLine 	:= oMdlGrid:Length()   
	
	//-- Atualiza dados
	lRet := FwFormCommit(oModel)

	If lRet .And. nOpc <> 5
		For nI := 1 to Len(aAptJus)
			oMdlGrid:GoLine( aAptJus[nI,JU_NLINHA] )
			
			cAptJus := TMSAptJus( aAptJus[nI,JU_CODMOT], ;
			                      aAptJus[nI,JU_APTJOR], ;
			                      aAptJus[nI,JU_FILORI], ;
			                      aAptJus[nI,JU_VIAGEM], ;
			                      aAptJus[nI,JU_DATAPT], ;
			                      aAptJus[nI,JU_HORAPT], ;
			                      aAptJus[nI,JU_CODPAR], ;
			                      aAptJus[nI,JU_MOTAPT], ;
			                      aAptJus[nI,JU_LDEL  ]  )
			                      
			If !Empty( cAptJus ) 
				//-- Vai atualizar status somente se não for exclusão da justificativa
				If aAptJus[nI,JU_LDEL]
					oMdlGrid:SetValue( "DEW_STATUS", "1" ) //-- 'Ok'
				Else					
					If cAptJus == "1"
						oMdlGrid:SetValue( "DEW_STATUS", "3" )
					ElseIf cAptJus == "2" .Or. cAptJus == "0"
						oMdlGrid:SetValue( "DEW_STATUS", "2" )
					ElseIf cAptJus == "ERROR"
						lRet := .F.
						Exit
					EndIf
					cAptJus := ""
				EndIf
			EndIf
		Next nI
		
	EndIf
	
	If lRet
		//-- Verifica as datas de saldo de cada jornada
		For nI := 1 To nTotLine
			oMdlGrid:GoLine( nI )
			cAptJor := oMdlGrid:GetValue( 'DEW_APTJOR' )
			dDatApt := oMdlGrid:GetValue( 'DEW_DATAPT' )
			If cAptJor == 'IJ' 
				If Ascan(aDatSal,dDatApt) == 0
					Aadd(aDatSal,dDatApt)
				EndIf
			EndIf
		Next nI												
		
		aAptJus := {}
		//-- Atualiza saldos da tabela DEX
		For nI  := 1 To Len(aDatSal)
			AO35AtuSal(cCodMot,aDatSal[nI])
		Next nI
	Else
		DisarmTransaction()
	EndIf	
	
	//-- Posiciona na linha atual do GRID
	oMdlGrid:GoLine(nPosLine)
	
End Transaction 

//-- Posiciona no DA4, pois neste momento a tabela ficava em EOF e o Relation do MVC se perdia
DA4->(dbSetOrder(1))
DA4->(dbSeek(xFilial('DA4')+cCodMot))

RestArea(aAreaAtu)

Return lRet 

//-------------------------------------------------------------------
/* AO35AtuSal
Atualização de saldos tabela DEX

@author  Caio Murakami
@since   08/02/2013
@version 1.0
*/
//-------------------------------------------------------------------

Function AO35AtuSal(cCodMot,dDatSal)
Local aHorJor		:= {}
Local aHorVge		:= {}
Local aHorDes		:= {}
Local aHorRef		:= {}
Local aHorPar		:= {}
Local aHorEsp		:= {}
Local aAux			:= {}
Local aCabDEX		:= {}
Local aCabAux		:= {}
Local bBloco 		:= {| x,y | x[3]+x[4] > y[3]+y[4]  }
Local aAreaDEX		:= DEX->( GetArea() )
Local cAliasQry		:= GetNextAlias()
Local cQuery 		:= ""
Local cAux			:= ""
Local cSeekDEX		:= ""
Local cTipoDEX		:= '1' //-- 1=Tempo da Jornada de Trabalho;2=Tempo de Direção;3=Tempo Excedido da Jornada;4=Tempo de Espera;5=Tempo de Descanso;6=Tempo de Refeição
Local cHorIni		:= ""
Local cHorFim		:= ""
Local cHorDEX	 	:= ""
Local cDatIni     	:= ""
Local cDatFim	   	:= ""
Local cHorDes		:= ""
Local cHorRef		:= ""
Local cHorPar		:= ""
Local cHorEsp		:= "" 
Local cHorSoma		:= ""
Local aHorSoma		:= {}
Local nOpc			:= 3
Local nAux			:= 1
Local nAux2			:= 1
Local nPosIniVge	:= 0
Local nPosFimVge	:= 0
Local nI   	   		:= 0
Local nCount		:= 0
Local nCountVge		:= 0
Local lWhile		:= .T.
Local lExecAuto		:= .T.
Local lVerMotVge	:= .F.
Local aDadosDEX		:= {}
Local nPosDadDEX	:= 0
Local oModel		:= Nil
Local nPos        	:= 0
Local aSldJor     	:= {}
Local lRegOk      	:= .T.
Local dUltApt     	:= CToD("")
Local oMdlDEX     	:= Nil

Default cCodMot 	:= ""
Default dDatSal 	:= CToD("")

dUltApt := AO35UltApt( cCodMot, 'IJ' )[1]
If Empty(dDatSal) .And. !Empty(dUltApt) 
	dDatSal := dUltApt
EndIf

aDadosDEX := AO35SelDEX( cCodMot, dDatSal )

//-- Verifica a próxima data com inicio de jornada a partir da data do saldo
cQuery := " SELECT MIN(DEW_DATAPT) DEW_DATAPT "
cQuery += " FROM " + RetSQLName("DEW") + " DEW "
cQuery += " WHERE DEW_FILIAL  = '" + xFilial("DEW") + "' "
cQuery += "   AND DEW_DATAPT  > '" + DToS(dDatSal)  + "' "
cQuery += "   AND DEW_CODMOT  = '" + cCodMot        + "' "
cQuery += "   AND DEW_APTJOR  = 'IJ'"
cQuery += "   AND D_E_L_E_T_  = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.)
If (cAliasQry)->(!Eof()) 
	cDatFim := (cAliasQry)->DEW_DATAPT
EndIf 
(cAliasQry)->(dbCloseArea())
If !Empty(cDatFim)
	cQuery := " SELECT MIN(DEW_HORAPT) DEW_HORAPT "
	cQuery += "FROM " + RetSQLName("DEW") + " DEW "
	cQuery += " WHERE DEW_FILIAL  = '" + xFilial("DEW") + "' "
	cQuery += "   AND DEW_DATAPT  = '" + cDatFim        + "' "
	cQuery += "   AND DEW_CODMOT  = '" + cCodMot        + "' "
	cQuery += "   AND DEW_APTJOR  = 'IJ'"
	cQuery += "   AND D_E_L_E_T_  = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.)
	If (cAliasQry)->(!Eof())
		cHorFim := (cAliasQry)->DEW_HORAPT
	EndIf
	(cAliasQry)->(dbCloseArea())
EndIf	 

cQuery := "SELECT MIN(DEW_HORAPT) DEW_HORAPT "
cQuery += "  FROM " + RetSQLName("DEW") + " DEW "
cQuery += " WHERE DEW_FILIAL  = '" + xFilial("DEW") + "' "
cQuery += "   AND DEW_DATAPT  = '" + DToS(dDatSal)  + "' "
cQuery += "   AND DEW_CODMOT  = '" + cCodMot        + "' "
cQuery += "   AND DEW_APTJOR  = 'IJ'"
cQuery += "   AND D_E_L_E_T_  = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.)
If (cAliasQry)->(!Eof())
	cHorIni := (cAliasQry)->DEW_HORAPT
EndIf
(cAliasQry)->(dbCloseArea())

//-- Obtem todos os apontamentos da data do saldo
cQuery := " SELECT * FROM " +RetSQLName("DEW") + " DEW "
cQuery += "  WHERE DEW_FILIAL  = '" + xFilial("DEW") + "' "
cQuery += " 	AND DEW_CODMOT	 = '" + cCodMot + "' "
cQuery += "		AND DEW_DATAPT >= '" + DToS(dDatSal) + "' "
//-- Ate o ultimo IJ caso exista no mesmo dDatSal
If !Empty(cDatFim) 
	cQuery += " AND DEW_DATAPT <= '" + cDatFim  + "' "
EndIf 
cQuery += " 	AND D_E_L_E_T_  = ' '"
cQuery += "  ORDER BY DEW_DATAPT, DEW_HORAPT DESC "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.)

/*--------------------------------
IV - INICIO VIAGEM
FV - FIM VIAGEM
IJ - INICIO JORNADA
FJ - FIM JORNADA
ID - INICIO DESCANSO
FD - FIM DESCANSO
IR - INICIO REFEICAO
FR - FIM REFEICAO
IE - INICIO ESPERA
FE - FIM ESPERA
----------------------------------*/
Aadd( aHorVge , {} )

While (cAliasQry)->( !Eof() )

	lRegOk := .T.

	If !Empty(cHorIni)
		lRegOk := (cAliasQry)->DEW_DATAPT + (cAliasQry)->DEW_HORAPT >= DToS(dDatSal) + cHorIni
	EndIf
	
	If !Empty(cDatFim) .And. !Empty(cHorFim)
		lRegOk := (cAliasQry)->DEW_DATAPT + (cAliasQry)->DEW_HORAPT < cDatFim + cHorFim
	EndIf
	
	If lRegOk
		If (cAliasQry)->DEW_APTJOR == "IJ" .Or. (cAliasQry)->DEW_APTJOR == "FJ"
			//-- Apontamentos da jornada ( IJ,FJ )
			Aadd( aHorJor , { (cAliasQry)->DEW_CODMOT , (cAliasQry)->DEW_APTJOR  , (cAliasQry)->DEW_DATAPT , (cAliasQry)->DEW_HORAPT , (cAliasQry)->DEW_FILORI , (cAliasQry)->DEW_VIAGEM } )
		ElseIf (cAliasQry)->DEW_APTJOR == "ID" .Or. (cAliasQry)->DEW_APTJOR == "FD"
			//-- Apontamentos do descanso ( ID, FD )
			Aadd( aHorDes , { (cAliasQry)->DEW_CODMOT , (cAliasQry)->DEW_APTJOR  , (cAliasQry)->DEW_DATAPT , (cAliasQry)->DEW_HORAPT } )
		ElseIf (cAliasQry)->DEW_APTJOR == "IP" .Or. (cAliasQry)->DEW_APTJOR == "FP"
			//-- Apontamentos de Parada ( IP, FP )
			Aadd( aHorPar , { (cAliasQry)->DEW_CODMOT , (cAliasQry)->DEW_APTJOR  , (cAliasQry)->DEW_DATAPT , (cAliasQry)->DEW_HORAPT } )
		ElseIf (cAliasQry)->DEW_APTJOR == "IR" .Or. (cAliasQry)->DEW_APTJOR == "FR"
			//-- Apontamentos de refeição ( IR, FR )
			Aadd( aHorRef , { (cAliasQry)->DEW_CODMOT , (cAliasQry)->DEW_APTJOR  , (cAliasQry)->DEW_DATAPT , (cAliasQry)->DEW_HORAPT } )
		ElseIf (cAliasQry)->DEW_APTJOR == "IE" .Or. (cAliasQry)->DEW_APTJOR == "FE"
			Aadd( aHorEsp , { (cAliasQry)->DEW_CODMOT , (cAliasQry)->DEW_APTJOR  , (cAliasQry)->DEW_DATAPT , (cAliasQry)->DEW_HORAPT } )
		EndIf
		
		If (cAliasQry)->DEW_APTJOR == "IV" .Or. (cAliasQry)->DEW_APTJOR == "IJ" .Or. (cAliasQry)->DEW_APTJOR == "FV" .Or. (cAliasQry)->DEW_APTJOR == "FJ"
			//-- Apontamentos para calculo do tempo de direçao ( IV,FV,IJ,FJ,ID,FD,IR,FR )
			Aadd( aHorVge[Len(aHorVge)] , { (cAliasQry)->DEW_CODMOT , (cAliasQry)->DEW_APTJOR  , (cAliasQry)->DEW_DATAPT , (cAliasQry)->DEW_HORAPT } )
		EndIf 
	EndIf
	
	(cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->( dbCloseArea() )

dbSelectArea("DEX")

//-- Soma horas de Descanso/Refeição/Parada/Espera
Aadd( aHorSoma , aClone(aHorDes) )
Aadd( aHorSoma , aClone(aHorPar) )
Aadd( aHorSoma , aClone(aHorRef) )
Aadd( aHorSoma , aClone(aHorEsp) )

cHorSoma	:= AO35HorSoma( aHorSoma )

//-- Inicia variaveis devido as novas utilizações abaixo
cHorIni := ""
cDatFim := ""
cHorFim := ""

//-- Tratamento para atualizacao dos tempo de: Jornada, Descanso e Refeição
While lWhile
	aAux	:= {}
	//-- Array com registros da jornada
	If Len(aHorJor) > 0
		aAux 		:= aClone(aHorJor)
		cAux		:= "FJ"
		aHorJor 	:= {}
		//-- Array com registro do descanso
	ElseIf Len(aHorDes) > 0
		aAux 		:= aClone(aHorDes)
		cAux		:= "FD"
		aHorDes		:= {}
	//-- Array com registro do descanso
	ElseIf Len(aHorPar) > 0
		aAux 		:= aClone(aHorPar)
		cAux		:= "FP"
		aHorPar		:= {}
		//-- Array com registros de refeicao
	ElseIf Len(aHorRef) > 0
		aAux 		:= aClone(aHorRef)
		cAux		:= "FR"
		aHorRef  	:= {}
	ElseIf Len(aHorEsp) > 0
		aAux 		:= aClone(aHorEsp)
		cAux		:= "FE"
		aHorEsp  	:= {}
	Else
		lWhile 		:= .F.
		cAux		:= ""
	EndIf
	
	//-- 1=Tempo da Jornada de Trabalho;2=Tempo de Direção;3=Tempo Excedido da Jornada;4=Tempo de Espera;5=Tempo de Descanso;6=Tempo de Refeição
	If cAux == "FJ"
		cTipoDEX := "1"
	ElseIf cAux == "FD"
		cTipoDEX := "5"
	ElseIf cAux == "FR"
		cTipoDEX := "6"
	ElseIf cAux == "FP"
		cTipoDEX := "7"
	ElseIf cAux == "FE"
		cTipoDEX := "4"
	Else
		cTipoDEX := ""
	EndIf
	
	//-- Ordena em ordem decrescente para pegar a hora fim (-) hora inicio
	aAux := Asort(aAux,,,bBloco)
	DEX->( dbSetOrder(1) )
	
	For nCount := 1 To Len(aAux)
		
		If aAux[nCount,2] == cAux //-- Fim
			cDatFim  := aAux[nCount,3]
			cHorFim	:= aAux[nCount,4]
		Else //-- Inicio
			If !Empty(cHorFim)
				cDatIni := aAux[nCount,3]
				cHorIni := aAux[nCount,4]
				cHorDEX := IntToHora( TmsHrToInt( TmsTotHora( SToD(cDatIni), cHorIni , SToD(cDatFim), cHorFim ) ),2 )
				cHorDEX := StrTran(cHorDEX,":","")
				
				If ( nPos  := Ascan( aSldJor, { |e| e[1] == cTipoDEX } ) ) > 0
					cHorDEX := IntToHora( TMSHrToInt( aSldJor[ nPos, 2 ], 2 ) + TMSHrToInt( cHorDEX, 2 ), 2 )
					cHorDEX := StrTran(cHorDEX,":","")
				Else
					Aadd( aSldJor, { cTipoDEX, "" } )
					nPos := Len(aSldJor)
				EndIf
				aSldJor[ nPos, 2 ] := cHorDEX
				
				If cAux == "FJ"
					AO35AtuExc( cCodMot  , StoD(cDatIni) , cHorIni , StoD(cDatFim) , cHorFim , cHorDEX, aAux[nCount,5] , aAux[nCount,6] , @aSldJor , cHorSoma )				
				ElseIf cAux == "FD"
					cHorDes := cHorDEX
				ElseIf cAux == "FP"
					cHorPar := cHorDEX
				ElseIf cAux == "FR
					cHorRef	:= cHorDEX
				ElseIf cAux == "FE"
					cHorEsp	:= cHorDEX
				EndIf   
				
				cHorFim := ""
			EndIf
		EndIf
	Next nCount
EndDo

//-- Tratamento para tempo de direção
//-- O tratamento é feito separadamente pois o inicio/fim de viagem podem ser feitos em dias diferentes
For nCountVge := 1 To Len(aHorVge)
	aAux		:= {}
	aAux		:= aClone(aHorVge[nCountVge])
	cDatFim  	:= ""
	cHorFim		:= ""
	cDatIni		:= ""
	cHorIni		:= ""	
	
	If Len(aAux) > 0
		//-- Ordena em ordem DECRESCENTE
		aAux     := Asort(aAux,,,bBloco)
		cAux	   := "FV"

		//-- 1=Tempo da Jornada de Trabalho;2=Tempo de Direção;3=Tempo Excedido da Jornada;4=Tempo de Espera;5=Tempo de Descanso;6=Tempo de Refeição
		cTipoDEX := "2"
		
		nPosIniVge := aScan(aAux,{|x| x[2] == "IV" } )
		If ( nPosIniVge > 0 )
			//-- Se tiver inicio de viagem deve terminar pelo ultimo registro = "IV"
			nAux2 := nPosIniVge
		Else
			nAux2 := Len(aAux)
		EndIf   
		
		nPosFimVge := aScan(aAux,{|x| x[2] == "FV" } )
		If ( nPosFimVge > 0 )
			//-- Se tiver termino de viagem deve começar pelo primeiro registro = "FV"
			nAux	:= nPosFimVge
		Else
			nAux := 1
		EndIf 
		
		DEX->( dbSetOrder(1) )
		For nCount := nAux To nAux2			
			If "FV" $ aAux[nCount,2] .Or. "FJ" $ aAux[nCount,2]
				cDatFim 	:= aAux[nCount,3]
				cHorFim		:= aAux[nCount,4]
				cSeekDEX	:= ""			
				//-- Se ultimo apontamento é fim de jornada deve-se verificar se motorista está em viagem para calcular o tmp direção
				//-- Isso acontece pois o inicio e fim de viagem podem ocorrer em dias diferentes
				If "FJ" $ aAux[nCount,2]
					lVerMotVge := .T.
				EndIf			
			ElseIf "IV" $ aAux[nCount,2] .Or. "IJ" $ aAux[nCount,2]
				cHorIni		:= aAux[nCount,4]
				cDatIni		:= aAux[nCount,3]
				If !Empty( cDatIni ) .And. !Empty( cDatFim )
					lExecAuto := .T.				
					If lVerMotVge
						//-- Verifica se o motorista está em viagem
						lExecAuto := !TMSEmViag(,,cCodMot,2,.F.)
					EndIf				
					If lExecAuto
											
						cSeekDEX := xFilial("DEX")+aAux[nCount,1]+aAux[nCount,3]+cTipoDEX
						//-- Diferenca de horas
						cHorDEX  := Transform(TmsTotHora( SToD(cDatIni), cHorIni , SToD(cDatFim), cHorFim),"@R 999:99")	
						//-- Subtrai o Tempo de Descanso
						cHorDEX := Transform(IntToHora( TmsHrToInt(cHorDEX,3) - TmsHrToInt( cHorDes , 2 ),3 ),"@R 999:99")			
						//-- Subtrai o Tempo de Refeicao
						cHorDEX := Transform(IntToHora( TmsHrToInt(cHorDEX,3) - TmsHrToInt( cHorRef , 2 ),3 ),"@R 999:99")		
						//-- Subtrai o Tempo de Parada
						cHorDEX := Transform(IntToHora( TmsHrToInt(cHorDEX,3) - TmsHrToInt( cHorPar , 2 ),3 ),"@R 999:99")						
						//-- Subtrai o Tempo de Espera
						cHorDEX := Transform(IntToHora( TmsHrToInt(cHorDEX,3) - TmsHrToInt( cHorEsp , 2 ),3 ),"@R 999:99")
						
						//-- Transforma hora no formato adequado para inclusao na DEX
						cHorDEX := StrTran( IntToHora( TmsHrToInt(cHorDEX,3),2 ) , ":" , "" ) 	
						Aadd( aSldJor, { cTipoDEX, cHorDEX } )									  
					EndIf  								
					lVerMotVge 	:= .F.								
				EndIf			
			EndIf   			
		Next nCount
	EndIf  
Next nCountVge 

//-- Adiciona saldos utilizados
If !Empty(aSldJor) 
	For nI := 1 To Len(aSldJor)
		cTipoDEX  := aSldJor[nI,1]
		aCabDEX   := {}
		lExecAuto := .T.
		Aadd( aCabDEX, { "DEX_CODMOT", cCodMot      , Nil } )
		Aadd( aCabDEX, { "DEX_DATA"  , dDatSal      , Nil } )
		Aadd( aCabDEX, { "DEX_TIPO"  , cTipoDEX     , Nil } )
		Aadd( aCabDEX, { "DEX_SALDO" , aSldJor[nI,2], Nil } )
		aCabAux := aClone(aCabDEX)
		If DEX->( MsSeek( xFilial( 'DEX' ) + cCodMot + DToS( dDatSal ) + cTipoDEX ) )
			nOpc := 4
			If ( nPosDadDEX := Ascan( aDadosDEX, { |x| x[1] + x[2] == DToS( dDatSal ) + cTipoDEX } ) ) > 0
				aDel( aDadosDEX, nPosDadDEX )
				aSize( aDadosDEX, Len(aDadosDEX) - 1 )
			EndIf
			//-- Se o saldo for o mesmo não deve passar pela ExecAuto
			If DEX->DEX_SALDO == aSldJor[nI,2]
				lExecAuto := .F.
			EndIf					
		Else
			nOpc := 3
		EndIf								
		If lExecAuto
			TMSMdlAuto( aCabAux ,,nOpc, "TMSAO40" , "MdFieldDEX" ,, "DEX",)
		EndIf
	Next nI			
EndIf	

//-- Exclui saldos nao utilizados
lExecAuto:= .F.
For nCount := 1 To Len( aDadosDEX )
	DEX->( DbSetOrder( 1 ) )
	If DEX->( DbSeek( xFilial( 'DEX' ) + cCodMot + aDadosDEX[ nCount, 1 ] + aDadosDEX[ nCount, 2 ] ) )
		lExecAuto:= .T.
		oMdlDEX := FWLoadModel("TMSAO40")
		oMdlDEX:SetOperation(MODEL_OPERATION_DELETE)
		oMdlDEX:Activate()
		If oMdlDEX:VldData()
			oMdlDEX:CommitData()
		EndIf
		oMdlDEX:DeActivate()
	EndIf
Next nCount
If lExecAuto 
	oMdlDEX:Destroy()
EndIf	

RestArea( aAreaDEX )

Return

//-------------------------------------------------------------------
/* AO35AtuExc
Função que atualiza a hora excedida da jornada

@author  Caio Murakami
@since   21/02/2013
@version 1.0
*/
//-------------------------------------------------------------------

Static Function AO35AtuExc(cCodMot, dDatIni , cHorIni , dDatFim , cHorFim , cTmpJor , cFilOri , cViagem , aSldJor , cHorSoma )
Local aAreaDEX := DEX->( GetArea()  ) 
Local cTipo 	:= "3" //-- 3=Tmp Excedido da Jornada
Local cTmpExc	:= "" 
Local cSerTMS  := ""
Local cTipTra	:= "" 
Local aTipVei	:= {}

Default cHorSoma	:= ""

//-- Desconta tempo de Refeição / Descanso / Parada
If !Empty(cHorSoma)
	cTmpJor		:=  IntToHora( TmsHrToInt(cTmpJor,2) - TmsHrToInt(cHorSoma,2) , 2 )

	//-- Atualiza no saldo total do tempo da jornada o valor descontado de refeição/descanso/parada
	aSldJor[Len(aSldJor),2]		:= StrTran( cTmpJor , ":" , "" )  

EndIf

//-- Atualiza parametros cSerTMS , cTipTra e aTipVei
AO35Vge( cFilOri, cViagem , @cSerTMS , @cTipTra , @aTipVei ,  ,  ,  , cCodMot ) 

//-- Tempo total da jornada
cTmpExc 	:= Transform(AO35Param("J4",cSerTMS,cTipTra,aTipVei), PesqPict("DEY","DEY_TEMPO") )

If TmsHrToInt(cTmpJor,2) > TmsHrToInt(cTmpExc,3)
	cTmpExc := StrTran( IntToHora( TmsHrToInt(cTmpJor,2) - TmsHrToInt(cTmpExc,3) , 2 ) , ":" , "" ) 	
   	Aadd( aSldJor , { cTipo , cTmpExc } )                          
EndIf

RestArea( aAreaDEX ) 
Return Nil    

//-------------------------------------------------------------------
/* Carrega conteudo na variavel static
@author  Jefferson Tomaz
@since   21/03/2013
@version 1.0      
*/
//-------------------------------------------------------------------

Function AO35SetVar( dDataIniJo, dDataFimJo )

Default dDataIniJo	:= CToD("  /  /  ")
Default dDataFimJo	:= dDataBase

dDatIniJor := dDataIniJo
dDatFimJor := dDataFimJo

Return

//-------------------------------------------------------------------
/* Carrega os dados do saldo do motorista
@author  Jefferson Tomaz
@since   21/03/2013
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function AO35SelDEX( cCodMot, dData )

Local aArea			:= GetArea()
Local cAliasQry		:= GetNextAlias()
Local cQuery		:= ""
Local aRet      	:= {}

Default cCodMot 	:= ''
Default dData  	:= dDatIniJor 

//DEX_FILIAL+DEX_CODMOT+DTOS(DEX_DATA)+DEX_TIPO                                                                                                                   
cQuery := " SELECT DEX_DATA, DEX_TIPO "
cQuery += "  FROM " + RetSqlName( "DEX" ) + " DEX "
cQuery += " WHERE DEX_FILIAL  = '" + xFilial( "DEX" ) + "' "
cQuery += "   AND DEX_CODMOT  = '" + cCodMot + "' "
cQuery += "   AND DEX_DATA    = '" + DToS( dData ) + "' "
cQuery += "   AND D_E_L_E_T_  = '' "
cQuery += " ORDER BY DEX_DATA, DEX_TIPO "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry( , , cQuery ), (cAliasQry), .F., .T. )

While (cAliasQry)->( !Eof() )
	
	aAdd( aRet, { (cAliasQry)->DEX_DATA, (cAliasQry)->DEX_TIPO } )
	
	(cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->( dbCloseArea() )

RestArea( aArea )  

Return aRet

//-------------------------------------------------------------------
/* Alimenta ARRAY aAptJus                  
@author  Richard Anderson
@since   05/04/2013
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function AO35AptJus( oMdlGrid, nLine, cCodPar, lDel, cDEWStatus, cMsgJus, cTmpPar, cTmpMot, cAtraso )

Local   nElem      	:= 0, nPos := 0
Local   lMsgJor	 	:= SuperGetMv("MV_MSGJOR",,.F.)
Local   cMotApt    	:= ""
Local   cCodMot    	:= ""
Local   oModel	    := oMdlGrid:GetModel()
Local   cObsApt   	:= ""

Default lDel       := .F.
Default cDEWStatus := "" 
Default cMsgJus    := ""
Default cTmpPar    := ""
Default cTmpMot    := ""
Default cAtraso    := ""

//-- Posiciona na linha
oMdlGrid:GoLine( nLine )           

//-- Obtem dados
cCodMot := oModel:GetModel( "OMSA040_DA4" ):GetValue( "DA4_COD" )
cObsApt := oMdlGrid:GetValue("DEW_OBSAPT")

//-- Posicione no Alias devido ao limbo da QUERY
dbSelectArea("DEW")
If !Empty(cMsgJus)

	If Empty(cAtraso)
		If Val(cTmpMot) > Val(cTmpPar)
			cAtraso := IntToHora( TmsHrToInt(cTmpMot,3) - TmsHrToInt(cTmpPar,3), 3 )
		Else
			cAtraso := IntToHora( TmsHrToInt(cTmpPar,3) - TmsHrToInt(cTmpMot,3), 3 )
		EndIf	
	Else
		cTmpMot		:= IntToHora(TmsHrToInt(cTmpMot,2) ,3) 
		cAtraso		:= IntToHora(TmsHrToInt(cAtraso,2) ,3) 
	EndIf

	cAtraso := StrTran( cAtraso, ":", "" )
	cMotApt := cMsgJus + CRLF
	cMotApt += CRLF
	
	If !Empty(cObsApt)
		cMotApt += AllTrim( RetTitle("DEW_OBSAPT") ) + ": " + CRLF
		cMotApt += cObsApt + CRLF
		cMotApt += CRLF
	EndIf

	cMotApt += STR0023 + CRLF //-- "Tempo Previsto:"
	cMotApt += Transform(cTmpPar,"@R 999h99m") + CRLF	
	cMotApt += CRLF
	
	cMotApt += STR0024 + CRLF //-- "Tempo Motorista:"
	cMotApt += Transform(cTmpMot,"@R 999h99m") + CRLF	
	cMotApt += CRLF
	
	cMotApt += STR0025 + CRLF //-- "Tempo Atraso:"
	cMotApt += Transform(cAtraso,"@R 999h99m") + CRLF	
	If lMsgJor
		MsgAlert(cMsgJus)
	EndIf
EndIf	

//-- DEW_STATUS
//-- 0=Não gravou;1=Justificativa analisada;2=Pendente de Analise
If !Empty(cDEWStatus)
	oMdlGrid:SetValue("DEW_STATUS",cDEWStatus)
EndIf	

If oMdlGrid:GetValue("DEW_STATUS") <> "1" 

	nPos := Ascan( aAptJus, { | e | e[JU_NLINHA] == nLine } ) 
	
	If nPos == 0
		Aadd( aAptJus, Array(JU_NMAX) )
	
		nElem := Len(aAptJus)
	
		//-- Pesquisa justificativas já gravadas para o caso das chamadas que não possuem todas as informações
		If Empty(cCodPar)
			DAY->(dbSetOrder(1))
			If DAY->(dbSeek(xFilial('DAY')+cCodMot+oMdlGrid:GetValue("DEW_APTJOR")))
				cCodPar := DAY->DAY_CODPAR
				cMotApt := DAY->DAY_MOTAPT
			EndIf
		EndIf					
		aAptJus[ nElem, JU_CODMOT ] := cCodMot
		aAptJus[ nElem, JU_NLINHA ] := nLine
		aAptJus[ nElem, JU_LDEL   ] := lDel
	Else
		nElem := nPos
	EndIf		
	
	aAptJus[ nElem, JU_APTJOR ] := oMdlGrid:GetValue("DEW_APTJOR")
	aAptJus[ nElem, JU_FILORI ] := oMdlGrid:GetValue("DEW_FILORI")
	aAptJus[ nElem, JU_VIAGEM ] := oMdlGrid:GetValue("DEW_VIAGEM")
	aAptJus[ nElem, JU_DATAPT ] := oMdlGrid:GetValue("DEW_DATAPT")
	aAptJus[ nElem, JU_HORAPT ] := oMdlGrid:GetValue("DEW_HORAPT")
	aAptJus[ nElem, JU_CODPAR ] := cCodPar
	aAptJus[ nElem, JU_MOTAPT ] := cMotApt
	
EndIf

Return Nil

//-------------------------------------------------------------------
/* Retorna a maior data de um tipo de apontamento por motorista
@author  Jefferson Tomaz
@since   21/03/2013
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function AO35UltApt( cCodMot, cTpAptJor, cRecNo )

Local aArea			:= GetArea()
Local cAliasQry		:= GetNextAlias()
Local cQuery		:= ""
Local dUltDatApt	:= CToD("  /  /  ")
Local cUltHorApt	:= ""

Default cCodMot		:= ""
Default cTpAptJor	:= ""

cQuery := " SELECT MAX(DEW_DATAPT) DEW_DATAPT "
cQuery += " FROM " + RetSQLName("DEW") + " DEW "
cQuery += " WHERE DEW_FILIAL = '" + xFilial( "DEW" ) + "'
If !Empty( cTpAptJor )
	cQuery += " AND DEW_APTJOR = '" + cTpAptJor + "' "
EndIf
If !Empty( cRecNo )
	cQuery += " AND R_E_C_N_O_ < '" + cRecNo + "' "
EndIf
cQuery += " AND DEW_CODMOT = '" + cCodMot + "' "
cQuery += " AND D_E_L_E_T_ = '' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TCGenQry( , , cQuery ), (cAliasQry), .F., .T. )

If (cAliasQry)->( !Eof() )
	dUltDatApt := StoD( (cAliasQry)->DEW_DATAPT )
EndIf

(cAliasQry)->( DBCloseArea() )

cAliasQry	:= GetNextAlias()

If !Empty( dUltDatApt )
	cQuery := " SELECT MAX(DEW_HORAPT) DEW_HORAPT "
	cQuery += " FROM " + RetSQLName("DEW") + " DEW "
	cQuery += " WHERE DEW_FILIAL = '" + xFilial( "DEW" ) + "'
	If !Empty( cTpAptJor )
		cQuery += " AND DEW_APTJOR = '" + cTpAptJor + "' "
	EndIf
	If !Empty( cRecNo )
		cQuery += " AND R_E_C_N_O_ < '" + cRecNo + "' "
	EndIf
	cQuery += " AND DEW_CODMOT = '" + cCodMot + "' "
	cQuery += " AND DEW_DATAPT = '" + DtoS( dUltDatApt ) + "' " 
	cQuery += " AND D_E_L_E_T_ = '' "
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGenQry( , , cQuery ), (cAliasQry), .F., .T. )

	If (cAliasQry)->( !Eof() )
		cUltHorApt :=  (cAliasQry)->DEW_HORAPT
	EndIf	

EndIf

RestArea( aArea )  

Return { dUltDatApt, cUltHorApt } 

//-------------------------------------------------------------------
/* Verifica se o campo pode ser habilitado para edicao
@author  Jefferson Tomaz
@since   02/04/2013
@version 1.0      
*/
//-------------------------------------------------------------------
Function TMSAO35Whe( cCampo )

Local   lRet   := .T.
Default cCampo := AllTrim( ReadVar() )

If FwFldGet( 'DEW_STATUS' ) == '3' //-- Atrasado e justificado
	lRet := .F.
Else	
	If AllTrim( FunName() ) == 'TMSAO35' .And. FwFldGet( 'DEW_TIPAPT' ) == '1'
		lRet := .F.	
	EndIf
EndIf	

Return( lRet )

//-------------------------------------------------------------------
/* Retorna o tempo de direção continua
@author  Caio Murakami
@since   19/12/2019
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function TContDrive( cAptJor , dDatApt , cHorApt , aAuxApt )
Local aArea		:= GetArea()
Local cTempo	:= ""
Local nLenAux 	:= 0
Local nAux		:= 0  
Local nPos		:= 0
Local aHorCont	:= {} 
Local aAux		:= {}
Local lContinua	:= .F. 
Local nTryMax	:= 3
Local nCount	:= 1 
Local dDatAux	:= dDataBase
Local lAux		:= .T. 

Default cAptJor		:= ""
Default dDatApt		:= dDataBase
Default cHorApt		:= ""
Default aAuxApt		:= {} 

nLenAux		:= Len(aAuxApt)

If nLenAux > 0 
	dDatAux	:= dDatApt

	While lAux 
		
		If nPos > 0 .Or. nCount == nTryMax
			lAux	:= .F. 
			Exit
		EndIf

		nPos	:= aScan( aAuxApt , {|e| e[JO_DATAPT] == dDatAux .And. e[JO_APTJOR] == "IV"  })

		dDatAux--
		nCount++
	EndDo

	If nPos > 0 

		While nPos <= Len(aAuxApt) 
			If aAuxApt[nPos,JO_DATAPT] <= dDatApt  .And. aAuxApt[nPos,JO_DATAPT] >= dDatAux 
				Aadd( aAux , { aAuxApt[nPos,JO_APTJOR] , aAuxApt[nPos,JO_DATAPT] , aAuxApt[nPos,JO_HORAPT] })
			EndIf
			nPos++
		EndDo		
	EndIf
	
	If Len(aAux) > 0 
		
		For nAux := Len(aAux) To 1 Step -1 

			If cHorApt >= aAux[nAux,3] .Or. lContinua

				lContinua	:= .T. 

				If ( aAux[nAux,1] == "FR" .Or. ;
					aAux[nAux,1] == "FD" .Or. ; 
					aAux[nAux,1] == "FE" .Or. ; 
					aAux[nAux,1] == "FP" .Or. ;
					aAux[nAux,1] == "IV" )

					lContinua	:= .F. 
					Aadd( aHorCont , {  aAux[nAux,2]  , aAux[nAux,3] } )
					Exit
				EndIf		
			EndIf
		Next 

		If Len(aHorCont) > 0 
			cTempo	:= TmsTotHora( aHorCont[1,1] , aHorCont[1,2] , dDatApt, cHorApt )
		EndIF
	EndIf
EndIf

RestArea(aArea)
Return cTempo

//-------------------------------------------------------------------
/* MaxDirCont
Retorna o tempo permitido para direção continua
//-- J8 - Tempo permitido para direcao continua
//-- T3 - Tempo de tolerancia de direcao continua

@author  Caio Murakami
@since   20/12/2019
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function MaxDirCont(cSerTMS,cTipTra,aTipVei)
Local cTempo	:= ""

Default	cSerTMS	:= ""
Default cTipTra	:= ""
Default aTipVei	:= {} 

//-- J8 - Tempo permitido para direcao continua
//-- T3 - Tempo de tolerancia de direcao continua
cTempo := StrTran( IntToHora( TmsHrToInt(AO35Param("J8",cSerTMS,cTipTra,aTipVei),3) + TmsHrToInt( AO35Param("T3",cSerTMS,cTipTra,aTipVei), 3 ), 3 ), ":", "" ) 

Return cTempo

//-------------------------------------------------------------------
/* AO35HorSoma
@author  Caio Murakami
@since   20/12/2019
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function AO35HorSoma( aHorSoma )
Local cHorSoma	:= ""
Local nAux		:= 0 
Local aAux		:= {}
Local nSoma		:= 0 
Local dData		:= ""
Local cHora		:= ""
Local cAptAux	:= ""
Local nHora		:= 0 

Default aHorSoma	:= {} 

For nAux := 1 To Len(aHorSoma)
	aAux	:= aClone( aHorSoma[nAux] )
	
	For nSoma := 1 To Len(aAux)
		cAptAux	:= aAux[nSoma,2]
		
		If cAptAux $ "FD/FR/FP/FE"
			dData	:= aAux[nSoma,3]
			cHora	:= aAux[nSoma,4]
		Else
			nHora		+= TmsHrToInt(TmsTotHora( Iif( ValType(aAux[nSoma,3]) == "D" , aAux[nSoma,3], SToD( aAux[nSoma,3] ) ) ,  aAux[nSoma,4] , StoD( dData ) , cHora ) )
		EndIf

	Next nSoma

	FwFreeObj(aAux)	

Next nAux

If nHora > 0 
	cHorSoma	:= IntToHora( nHora )
EndIf

FwFreeObj( aHorSoma )

Return cHorSoma

//-------------------------------------------------------------------
/* RetTimeArr
@author  Caio Murakami
@since   10/01/2020
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function RetTimeArr(aAux , dIniJor , dFimJor )
Local cHora		:= ""
Local nCount	:= 1 
Local dDatFim	:= CToD("")
Local dDatIni	:= CToD("")
Local cHorFim	:= ""
Local cHorIni	:= ""
Local nHora		:= 0

For nCount := Len(aAux) To 1 Step -1 

	If aAux[nCount][JO_DATAPT] == dIniJor .Or. aAux[nCount][JO_DATAPT] == dFimJor
		
		If aAux[nCount][JO_APTJOR] $ "FR/FE/FP/FD"
			dDatFim	:= aAux[nCount][JO_DATAPT]	
			cHorFim	:= aAux[nCount][JO_HORAPT]
		Else
			dDatIni	:= aAux[nCount][JO_DATAPT]	
			cHorIni	:= aAux[nCount][JO_HORAPT]

			nHora	+= TmsHrToInt(TmsTotHora( dDatIni , cHorIni , dDatFim , cHorFim ) )

			dDatFim	:= CToD("")
			cHorFim	:= ""
			dDatIni	:= CToD("")
			cHorIni	:= ""

		EndIf
	EndIf

Next nCount

If nHora > 0 
	cHora	:= IntToHora( nHora )
EndIf

Return cHora