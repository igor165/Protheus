#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGXTEL.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "SMARTCTI.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "TMKA600.CH"

#DEFINE USE_MODEM  		"1"
#DEFINE USE_CTI    		"2"
#DEFINE USE_MANUAL		"3"    
#DEFINE USE_SMARTCTI	"4"

Static oDlg				:= Nil	//Dialog Principal
Static oDlgDAC			:= Nil	//Dialog Superior	para seleção dos DAC´s	
Static oFWChartFactory	:= Nil	//Objeto para criação dos Graficos
Static oFWChart			:= Nil	//Objeto onde será inicializado o Grafico
Static oTimer			:= Nil	//Objeto de Timer para atualização do Grafico.
Static oAgtSmartCTI		:= Nil //Instancia do objeto AgentSmartCTI.  

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMKA600()
Fila de Chamadas em Espera

@sample 	TMKA600() 
	
@return	ExpL	Verdadeiro / Falso

@author	CRM
@since		24/05/2012       
@version	P11   
/*/         
//------------------------------------------------------------------------------
Function TMKA600()

Local aSize	 		:= FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local oFWLayer		:= Nil	
Local oMrkBrowse	:= Nil
Local aCombo		:= {STR0002,STR0003}				//"Barras","Pizza"
Local cCombo1		:= aCombo[1]                   	//RedVar do ComBox
Local cAliasAGI		:= GetNextAlias()					//Alias Temporario
Local aAlias		:= {}								//Array para o retorno da função TK600QueryDAC
Local aColumns		:= {}								//Colunas do Browse			
Local bAtuGraf		:= {||TK600ProcGraf(oMrkBrowse, oFWChartFactory, oFwChart , oDlgGraf, oCombo:nAt, cAlias,.F.)}	//Bloco de Codigo para Atualizar o Grafico
Local nConfTimer	:= SuperGetMV("MV_TKTGRAF",,12000)  //Parametro com o tempo do Timer
Private oTempTable	:= NIL
//-----------------------------------------------------------------------
//Verifica se o usuario tem permissão para acessar/Somente supervisores
//-----------------------------------------------------------------------
If !TK600Perm()
	MsgAlert(STR0004) //"Usuario não tem permissão para acessar a rotina"
	Return(.F.)
EndIf

//----------------------------------------------------------
//Retorna as colunas para o preenchimento da FWMarkBrowse
//----------------------------------------------------------
aAlias := TK600QueryDAC()

cAlias 		:= aAlias[1]
aColumns 	:= aAlias[2]

DEFINE DIALOG oDlg TITLE STR0001 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL	//Lista de Chamadas

//--------------------------------------
//Inicializa o objeto do Grafico
//--------------------------------------
oFWChartFactory := FWChartFactory():New()

//--------------------------
//Construção dos Layers
//--------------------------			
oFWLayer := FWLayer():New()
oFWLayer:Init(oDlg,.F.)

oFWLayer:addLine("LISTA_DAC", 50, .F.)
oFWLayer:addCollumn("COL_DAC",100, .T. , "LISTA_DAC")
oFWLayer:AddWindow("COL_DAC","oDlgDAC",STR0005,100,.F.,.F.,{||},"LISTA_DAC",{|| })	// "Lista de DAC"

oFWLayer:setLinSplit( "LISTA_DAC", CONTROL_ALIGN_BOTTOM, {|| , oFwLayer:winopen("COL_DAC","oDlgDAC","LISTA_DAC") } )
		
oDlgDAC := oFWLayer:GetWinPanel("COL_DAC","oDlgDAC","LISTA_DAC")

oFWLayer:addLine("GRAFICOS", 50, .F.)
oFWLayer:addCollumn("COL_GRAF",100, .T. , "GRAFICOS")
oFWLayer:AddWindow("COL_GRAF","oDlgGraf",STR0006,100,.F.,.F.,,"GRAFICOS",{||})	// "Graficos"
		
oDlgGraf := oFWLayer:GetWinPanel("COL_GRAF","oDlgGraf","GRAFICOS")

//------------------------------------------
//Criação da MarkBrowse no Layer LISTA_DAC
//------------------------------------------
oMrkBrowse:= FWMarkBrowse():New()
oMrkBrowse:SetFieldMark("AGI_OK")
oMrkBrowse:SetOwner(oDlgDAC)
oMrkBrowse:oBrowse:SetDataQuery(.F.)
oMrkBrowse:oBrowse:SetDataTable(.T.)
oMrkBrowse:SetAlias(cAlias)
oMrkBrowse:SetCustomMarkRec({|| TK600CMkB1(oMrkBrowse) })
oMrkBrowse:SetDescription("")
oMrkBrowse:SetMenuDef("")
oMrkBrowse:AddButton(STR0007,{|| TK600ProcGraf(oMrkBrowse, oFWChartFactory, oFwChart , oDlgGraf, oCombo:nAt, cAlias,.T.)},,,,.F.,1) 	// "Gerar Grafico"
oMrkBrowse:AddButton(STR0008,{|| TK600AtuTimer()},,,,.F.,1) 	// "Conf. Tempo de Atualização"
oMrkBrowse:SetColumns(aColumns)
oMrkBrowse:Activate()

oCombo := TComboBox():New(02,40,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},;
	                         aCombo,50,10,oDlgGraf,,{||TK600ProcGraf(oMrkBrowse, oFWChartFactory, oFwChart , oDlgGraf, oCombo:nAt, cAlias,.F.)};
	                         ,,,,.T.,,,,,,,,,'cCombo1')

oCombo:ALIGN:= CONTROL_ALIGN_LEFT

//------------------------------------------------------------------
//Define o TImer para atualização do grafico
//------------------------------------------------------------------
DEFINE TIMER oTimer INTERVAL nConfTimer ACTION Eval(bAtuGraf) OF oDlg

ACTIVATE DIALOG oDlg CENTERED

If( valtype(oTempTable) == "O")
	oTempTable:Delete()
	freeObj(oTempTable)
	oTempTable := Nil
EndIf

Return (.T.)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK600CMkB1()
Atualiza Marcador do FWMarkBrowse

@param		ExpO 	Objeto da MarkBrowse(FWMarkBrowse). 
			
@sample 	TK600CMkB1(oMrkBrowse)
	
@return	ExpL	Verdadeiro / Falso

@author	CRM
@since		24/05/2012       
@version	P11   
/*/         
//--------------------------------------------------------------------------------
Static Function TK600CMkB1(oMrkBrowse)

If ( !oMrkBrowse:IsMark() )
	RecLock(oMrkBrowse:Alias(),.F.)
	(oMrkBrowse:Alias())->AGI_OK  := oMrkBrowse:Mark()
	(oMrkBrowse:Alias())->(MsUnLock())

Else
	RecLock(oMrkBrowse:Alias(),.F.)
	(oMrkBrowse:Alias())->AGI_OK  := ""
	(oMrkBrowse:Alias())->(MsUnLock())
EndIf     

Return( .T. )

//------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK600ProcGraf()
Realiza o Processamento do Grafico da Lista de Chamadas

@param		ExpO1 	Objeto da MarkBrowse(FWMarkBrowse). 
@param		ExpO2	Objeto do Grafico(FwChartFactory).
@param		ExpO3	Objeto onde será inicializado o Grafico.
@param 		ExpO4	Dialog que será inicializado o Grafico.
@param		ExpO5	Posição do comboBox para o tipo de Grafico(1-Barra,2-Pizza).
@param		ExpO6	Alias Temporario.
@param		ExpL	Indica se Mostra Mensagem ("Não há chamadas na fila para o DAC: ")
			
@sample 	TK600ProcGraf(oMrkBrowse, oFWChartFactory, oFwChart , oDlgGraf, nPos, cAlias)
	
@return	ExpL	Verdadeiro / Falso

@author	CRM
@since		24/05/2012       
@version	P11   
/*/         
//-------------------------------------------------------------------------------------------------
Static Function TK600ProcGraf(oMrkBrowse, oFWChartFactory, oFwChart , oDlgGraf, nPos, cAlias, lMsg)
Local lRetorno		:= .T.
Local aArea 		:= GetArea()
Local aDacMark		:= {}
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local aListDac		:= {}
Local cListDac		:= ""
Local aRet			:= {}
Local aAux			:= {}
Local cCTI			:= ""
Local cTipoCTI    	:= TkPosto(TkOperador(),"U0_TIPOCTI")
Local nOcupado		:= 0

If oDlgGraf == Nil
	Return Nil
EndIf
	
If oFwChart <> NIL
	FreeObj(oFwChart)
Endif  

//-----------------------------------------------------
//Verifica o tipo de grafico escolhido no ComboBox.
//-----------------------------------------------------
If nPos == 1
	oFwChart := oFWChartFactory:getInstance( BARCHART )
Else
	oFwChart := oFWChartFactory:getInstance( PIECHART )
EndIf

//--------------------------
//Inicializa o Grafico
//--------------------------
oFWChart:init( oDlgGraf )
oFWChart:setTitle( STR0009, CONTROL_ALIGN_CENTER ) //"Lista de Chamadas em espera"
oFWChart:setLegend( CONTROL_ALIGN_BOTTOM )

//-----------------------------------------------------------
//Verifica o tipo de discagem para realizar o comando CTI.
//-----------------------------------------------------------
TK600VerDisc(@cCTI,cTipoCTI)

//-----------------------------------------------
// Verifica quais os DAC´s foram Selecionados
//-----------------------------------------------
(cAlias)->( dbGoTop() )
While !(cAlias)->( EOF() )

	If oMrkBrowse:IsMark()
		aAdd(aDacMark,(oMrkBrowse:Alias())->AGI_NUM)		
	EndIf
	
	(cAlias)->( dbSkip() )

End

If Len(aDacMark) > 0
	For nX := 1 to Len(aDacMark)
			If ValType(oAgtSmartCTI) == "U" 
				lRetorno:= SGCommand(	"L"	 , cCTI ,Nil ,Nil, Nil ,Nil, cTipoCTI , Nil ,@cListDac,cValToChar(aDacMark[nX]))
				oAgtSmartCTI:= getObjCTI()
			Else
				cListDac := oAgtSmartCTI:GetCallList(cValToChar(aDacMark[nX]))
			EndIf
			
			//MsgAlert("Retorno do Comando: " + cValToChar(cListDac))
				
			//For para simular uma lista de chamadas em espera
			/*	
			For nY := 1 To 30 
				If nY == 1 
					cListDac := ""
					cListDac += "CMD#LISTA_CHAMADAS#00#2005#01/04/13 16:18:18 010A 801500,7,2004"
				Else
					cListDac += ";"
					cListDac += "01/04/13 16:18:18 010A 801500,7,2004"
				EndIf
			Next nY
			*/						
			If lRetorno .And. !Empty(cListDac)
	
				//----------------------------------		
				//Separa as Chamadas
				//----------------------------------
				aListDac := strToArray(cListDac,";")
				
				//-----------------------------------
				//Separa os estados das chamadas
				//-----------------------------------
				For nZ := 1 To Len(aListDac)
					aRet := strToArray(aListDac[nZ],",")
					aAdd(aAux,{aRet})
				Next nZ
				
				//----------------------------------------
				//Realiza a contagem de ligações em Fila
				//----------------------------------------
				For nY := 1 To Len(aAux)
					If aAux[nY][1][2] == "7"
						nOcupado ++ 
					EndIF
				Next nY
				
				oFWChart:addSerie(STR0010 + cValToChar(aDacMark[nX]) , nOcupado ) //"Fila de Chamadas - "
				
				//----------------------------------------------------------------------
				//Reinicializa os Arrays auxiliares e o Contador para a nova contagem
				//----------------------------------------------------------------------
				aListDac	:= {}
				aRet		:={}
				aAux		:={}
				nOcupado 	:= 0
				cListDac	:= ""
			Else
				If !lRetorno
					Aviso(STR0011, STR0013,{STR0012}, 2) //"Atenção", "Houve erro no Comando",{"OK"}
				Else
					If lMsg
						Aviso(STR0011, STR0015 + cValToChar(aDacMark[nX]) ,{STR0012}, 2) //"Atenção", "Não há chamadas na fila para o DAC: " + cValToChar(aDacMark[nX] ,{"OK"}
					EndIf
					oFWChart:addSerie(STR0010 + cValToChar(aDacMark[nX]) , nOcupado ) //"Fila de Chamadas - "
				EndIf	
			EndIf	
									
	Next nX
Else
	Aviso(STR0011, STR0014,{STR0012},2) //"Atenção", "Não há DAC selecionado para a geração de graficos de Lista de Chamadas",{"OK"}
EndIf

//---------------------------
//Inicializa o Grafico
//---------------------------
oFWChart:setMask( " *@* " )
oFWChart:setPicture( "" )
		
oFWChart:build()

//--------------------
//Inicializa o Timer
//--------------------
oTimer:Activate()

RestArea(aArea)

Return (lRetorno)

//----------------------------------------------------------------------------------
/*/{Protheus.doc} TK600Perm()
Verifica se o usuario tem perfil de supervisor
			
@sample 	TK600Perm()
	
@return	ExpL	Verdadeiro / Falso

@author	CRM
@since		24/05/2012       
@version	P11   
/*/         
//------------------------------------------------------------------------------
Static Function TK600Perm()
Local lRetorno	:= .T.
Local aArea 	:= GetArea()
Local aAreaSU7	:= SU7->(GetArea())

If !Val(Posicione( "SU7", 4, xFilial("SU7") + __cUserID, "U7_TIPO")) == SUPERVISOR
	lRetorno := .F.
EndIf	

RestArea(aAreaSU7)
RestArea(aArea)

Return(lRetorno)

//----------------------------------------------------------------------------------
/*/{Protheus.doc} TK600ProcGraf()
Realiza a Query para criar e popular a MarkBrowse
			
@sample 	TK600QueryDAC()
	
@return	ExpA	- Array[1] - Alias da Tabela Temporaria.
					- Array[2] - Colunas da Tabela.

@author	CRM
@since		24/05/2012       
@version	P11   
/*/         
//------------------------------------------------------------------------------
Static Function TK600QueryDAC()
Local aArea		:= GetArea()			//Area a ser recuperada
Local aAreaSX3	:= SX3->(GetArea())		//Area do SX3
Local cAlias	:= GetNextAlias()		//Alias
Local cUsuario	:=  __cUserID			//Armazena o codigo do usuario
Local aStruct	:= AGI->(DBSTRUCT())	//Estrutura da Tabela AGI
Local aColumns	:= {}					//Array com as colunas da Tabela AGI
Local nX		:= 0					//Contador
Local cTempTab	:= GetNextAlias()		//Armazena nome da tabela temporaria

AADD(aStruct,{"AGI_OK","C"	,2		,0		})

//----------------------------------------------
//Verifica quais DAC´S o usuario tem acesso
//----------------------------------------------
BeginSQL alias cAlias

	SELECT DISTINCT 
		AGI.*,'  ' AS AGI_OK //AGI_OK é o campo criado para o campo de Marcação
		
	FROM 
		%table:SU7% SU7
	JOIN 
		%table:AG9% AG9 ON (AG9.AG9_FILIAL=%xfilial:AG9% AND SU7.U7_COD=AG9.AG9_CODSU7 AND AG9.%notDel%)
	JOIN
		%table:AGJ% AGJ ON (AGJ.AGJ_FILIAL=%xfilial:AGJ% AND AG9.AG9_CODSU0=AGJ.AGJ_SU0COD AND AGJ.%notDel%) 
	JOIN	
		%table:AGI% AGI ON (AGI.AGI_FILIAL=%xfilial:AGI% AND AGJ.AGJ_GICOD=AGI.AGI_COD AND AGI.%notDel%)
	WHERE
			SU7.U7_FILIAL = %xfilial:SU7%
		AND
			SU7.U7_CODUSU = %exp:cUsuario%
		AND	
			SU7.%notDel%
		
EndSql
//-------------------------------------------------------------------
// Instancia tabela temporária.  
//-------------------------------------------------------------------

oTempTable	:= FWTemporaryTable():New(cTempTab)


//-------------------------------------------------------------------
// Atribui o  os índices.  
//-------------------------------------------------------------------
oTempTable:SetFields( aStruct )
oTempTable:AddIndex("1",{"AGI_FILIAL","AGI_COD"})
//------------------
//Criação da tabela
//------------------
oTempTable:Create()

(cAlias)->(DbGoTop())
	nTam := (cAlias)->(FCOUNT())
	If	!(cAlias)->(Eof())	
		
			While !(cAlias)->(Eof())
				RecLock( cTempTab,.T. )
				For nX := 1 to nTam
					DbSelectArea(cAlias)
					
					nY 		:= ASCAN(aStruct,{|x|x[1]==ALLTRIM(FIELD(nX))})	
					gDado 	:= &((cAlias)->(ALLTRIM(FIELD(nX))))
					
					If nY > 0
						DbSelectArea(cTempTab)
						
						If VALTYPE(&((cAlias)->(ALLTRIM(FIELD(nX))))) == "D"
							&((cTempTab)->(ALLTRIM(FIELD(nY))))   := StoD(gDado)
						Else
							&((cTempTab)->(ALLTRIM(FIELD(nY))))   := gDado	
						EndIf
						
					EndIf
					
				Next	 	
				(cTempTab)->(MsUnLock())		
				(cAlias)->(DbSkip())			
			EndDo
		
	EndIf 


If ( Select( cAlias ) > 0 )
	DbSelectArea(cAlias)
	DbCloseArea()
EndIf

For nX := 1 To Len(aStruct)
	If	!aStruct[nX][1] == "AGI_OK"
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[nX]:SetData( &("{||"+aStruct[nX][1]+"}") )
		aColumns[nX]:SetTitle(RetTitle(aStruct[nX][1])) 
		aColumns[nX]:SetSize(aStruct[nX][3]) 
		aColumns[nX]:SetDecimal(aStruct[nX][4]) 
	EndIf 	
Next nX 


Return({cTempTab,aColumns})

//----------------------------------------------------------------------------------
/*/{Protheus.doc} TK600ProcGraf()
Verifica o tipo de discagem que é realizada através do tipo de configuração.

@param		ExpC1 	Conexão Utilizada
@param		ExpC2	Tipo de Configuração CTI
			
@sample 	TK600VerDisc(cCTI,cTipoCTI)
	
@return	ExpL	Verdadeiro

@author	CRM
@since		24/05/2012       
@version	P11   
/*/         
//------------------------------------------------------------------------------
Static Function TK600VerDisc(cCTI,cTipoCTI)

//---------------------------------------------------
// Verifica qual o tipo de discagem a ser realizada.
//----------------------------------------------------
Do Case
	case cTipoCTI == USE_MODEM 		// 1 - Modem
		cCTI := ""

	case cTipoCTI == USE_CTI      		// 2 - Cti   
		cCTI := SuperGetMV("MV_TMKCTI")    
		
	case cTipoCTI == USE_MANUAL		// 3 - Manual
		cCTI := ""

	case cTipoCTI == USE_SMARTCTI 			//4 - SmartCTI
		cCTI := "SMARTCTI"
			
	case Empty(cTipoCTI) 			// Discagem Manual
		cCTI := ""                  
	
EndCase

Return(.T.)

//----------------------------------------------------------------------------------
/*/{Protheus.doc} TK600AtuTimer()
Cria a tela para atualização do tempo do Timer
	
@sample 	TK600AtuTimer()
	
@return	ExpL	Verdadeiro

@author	CRM
@since		24/05/2012       
@version	P11   
/*/         
//------------------------------------------------------------------------------
Static Function TK600AtuTimer()
Local oDlgTimer
Local cTempo		:= Space(20)
Local oPanel
Local oFooter
Local oOk
Local oCancel

DEFINE DIALOG oDlgTimer TITLE STR0016 FROM 00,00 TO 120,200 PIXEL	//"Atualização do Grafico"

@ 000, 000 MsPanel oPanel Of oDlgTimer Size 100, 100
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

//Get para informar o tempo do Timer
@ 5,5  SAY STR0017 SIZE 50,8 OF oPanel PIXEL 
@ 5,25 MSGET oTempo VAR cTempo MESSAGE STR0018 Picture "99999999999999999999" SIZE 70,10 OF oPanel PIXEL //"Digite o Tempo em Milisegundos"

@ 000, 000 MsPanel oFooter Of oDlgTimer Size 000, 010
oFooter:Align   := CONTROL_ALIGN_BOTTOM

@ 000, 000 Button oCancel Prompt STR0019  Of oFooter Size 030, 000 Pixel //Cancelar
oCancel:bAction := { || oDlgTimer:End() }
oCancel:Align   := CONTROL_ALIGN_RIGHT

@ 000, 000 Button oOk     Prompt STR0020 Of oFooter Size 030, 000 Pixel //Confirmar
oOk:bAction     := { || TK600GrvTimer(cTempo), oDlgTimer:End() }
oOk:Align       := CONTROL_ALIGN_RIGHT


ACTIVATE DIALOG oDlgTimer CENTERED

Return ( .T. )

//----------------------------------------------------------------------------------
/*/{Protheus.doc} TK600GrvTimer(cTempo)
Grava o tempo configurado e atualiza o Timer

@param		ExpC1 	Tempo digitado
			
@sample 	TK600GrvTimer(cTempo)
	
@return	ExpL	Verdadeiro

@author	CRM
@since		24/05/2012       
@version	P11   
/*/         
//------------------------------------------------------------------------------
Static Function TK600GrvTimer(cTempo)
Local aAreaSX6		:= SX6->(GetArea())

//----------------------------------------
//Grava o tempo configurado no parametro 
//para restaurar na proxima vez que entrar
//-----------------------------------------
If !Empty(cTempo)
	DbSelectArea("SX6")
	SX6->(DbSetOrder(1))
	If SX6->(DbSeek(Space(FWSizeFilial())+"MV_TKTGRAF"))
		RecLock("SX6",.F.)
		X6_CONTEUD	:= cTempo
   		X6_CONTSPA	:= cTempo
   		X6_CONTENG	:= cTempo
   		MsUnLock() 	
	EndIf
EndIf

//----------------------------
//Atualiza o tempo do Timer
//-----------------------------
oTimer:nInterval := Val(cTempo)


RestArea(aAreaSX6)

Return (.T.)