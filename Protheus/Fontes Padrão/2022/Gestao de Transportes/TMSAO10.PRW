#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH" 
#INCLUDE "FWBROWSE.CH"  
#INCLUDE "TMSAO10.CH"              

//-------------------------------------------------------------------
/*TMSAO10

Posicionamento de veiculos

@author  Caio Murakami
@since   09/04/2012
@version 1.0      
*/
//-------------------------------------------------------------------
Function TMSAO10(aRotAuto,nOpcAuto,cFiltro)
Local oBrowse

Private aRotina   := MenuDef()
Private cCadastro := STR0007 //-- Posicionamento  

DEFAULT cFiltro := ""    

If aRotAuto == NIL  
	If Empty(cFiltro)
  		If Pergunte("TMSAO10",.T.)
 		
	 		cFiltro 	:= " DAV_CODVEI >= '" + mv_par01  + "' "
	 		cFiltro 	+= " .And. DAV_CODVEI <= '"+mv_par02+"' "
	 		cFiltro  += " .And. DAV_DATPOS >= '"+dToS(mv_par03)+"' "
	 		cFiltro	+= " .And. DAV_DATPOS <= '"+dToS(mv_par04)+"' "
	 		
	 		//-- Considerar Status? 
	 		If mv_par05 == 1
	 			cFiltro += " .And. DAV_STATUS == '"+cValToChar(mv_par06)+"' "
	 		EndIf 
	 
	 	EndIf
 		
 	EndIf

	oBrowse := FWmBrowse():New()	
	oBrowse:SetAlias( 'DAV' )   
	
	//-- Adiciona legendas ao Browse
	oBrowse:AddLegend('DAV_STATUS== "1" .Or. Empty(DAV_STATUS) ', "RED"  ,STR0008 )
	oBrowse:AddLegend('DAV_STATUS== "2"' 								, "BLUE" ,STR0009 )
	oBrowse:AddLegend('DAV_STATUS== "3"' 								, "GREEN",STR0010 ) 	 
	oBrowse:SetFilterDefault(cFiltro)		 
	oBrowse:DisableDetails()
	oBrowse:SetDescription( cCadastro ) 
	oBrowse:Activate()	
Else 
	FwMvcRotAuto(ModelDef(),"DAV",nOpcAuto,{{"MdFieldDAV",aRotAuto}},.T.,.T.)  //-- Chamada da rotina automatica através do MVC
EndIf  

Return


//-------------------------------------------------------------------
/*MenuDef

@author  Caio Murakami
@since   09/04/2012
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRot := {}  

	aAdd( aRot, { STR0002 	, 'VIEWDEF.TMSAO10', 0, 2, 0, NIL } )	//-- Visualizar
	aAdd( aRot, { STR0004 	, 'VIEWDEF.TMSAO10', 0, 8, 0, NIL } )	//-- Imprimir
	aAdd( aRot, { STR0005 	, 'VIEWDEF.TMSAO10', 0, 9, 0, NIL } )	//-- Copiar
	aAdd( aRot, { STR0028  	, 'TmsAO10Mnt' 	 , 0, 5, 0, NIL } )	//-- Manutenção de viagens
	                          
Return aRot

//-------------------------------------------------------------------
/*ModelDef

@author  Caio Murakami
@since   09/04/2012
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 	   := Nil
Local oStructDAV 	:= Nil 

oStructDAV := FwFormStruct(1,"DAV",,)
                                                                         
oModel:= MpFormModel():New("TMSAO10",,{|oModel|PosVldMdl(oModel)},{|oModel|CommitMdl(oModel)},/*Cancel*/)  

oModel:AddFields("MdFieldDAV",,oStructDAV,/*bPreValid*/,/*bPosValid*/,/*Carga*/)
oModel:SetDescription(STR0007) 								
oModel:GetModel("MdFieldDAV"):SetDescription(STR0007) 
oModel:SetPrimaryKey({"DAV_IDMPOS"})

Return ( oModel )


//-------------------------------------------------------------------
/* ViewDef
Definicao da Visao

@author  Caio Murakami
@since   09/04/2012
@version 1.0
*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oStructDAV := FwFormStruct(2,'DAV')
Local oModel     := FwLoadModel('TMSAO10')            
Local oView    

oView := FwFormView():New()

oView:SetModel(oModel)
oView:AddField('VwFieldDAV', oStructDAV , 'MdFieldDAV') 
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VwFieldDAV','TELA')

Return oView      
 
//-------------------------------------------------------------------
/* PosVldMdl
Pós Valid

@author  Caio Murakami
@since   03/05/12
@version 1.0
*/
//-------------------------------------------------------------------
Static Function PosVldMdl(oModel)
Local lRet       	:= .T.
Local nOperation	:= oModel:GetOperation()              

If nOperation == 4  

	Help(" ",,'TMSAO1001')//--  Mensagens de posicionamento nao podem ser alteradas 
	lRet := .F.

ElseIf nOperation == 5  

	Help(" ",,'TMSAO1002')//--  Mensagens de posicionamento nao podem ser excluidas 
	lRet := .F. 
	
EndIf 


Return lRet 


//-------------------------------------------------------------------
/* CommitMdl
Efetua a gravacao do model

@author  Caio Murakami
@since   03/05/12
@version 1.0
*/
//-------------------------------------------------------------------

Static Function CommitMdl(oModel)
Local lRet 		:= .T.  

//-- Efetua a atualizacao do posicionamento
AO10AtuPos(oModel:GetModel("MdFieldDAV"))

//-- Efetua a atualizacao de viagem
AO10AtuVge(oModel:GetModel("MdFieldDAV"))

//-- Efetua a gravacao do Model
FwFormCommit( oModel )

Return lRet
   
              

//-------------------------------------------------------------------
/*IntegDef

@author  Caio Murakami
@since   08/05/12
@version 1.0      
*/
//-------------------------------------------------------------------
   

Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local aRet := {}

aRet := TMSIO10( cXML , nTypeTrans , cTypeMessage )

Return aRet   
   


//-------------------------------------------------------------------
/*AO10AtuVge
            
Atualiza Status e movimento de viagem

@author  Caio Murakami
@since   10/05/12
@version 1.0      
*/
//-------------------------------------------------------------------

Static Function AO10AtuVge( oModel ) 

Local nOperation	:= oModel:GetOperation()
Local cFilOri 		:= ""
Local cViagem 		:= ""
Local cCodVei		:= oModel:GetValue("DAV_CODVEI") 
Local dDatIni		:= oModel:GetValue("DAV_DATPOS")
Local cHorIni		:= oModel:GetValue("DAV_HORPOS")
Local cCodMac		:= oModel:GetValue("DAV_CODMAC")
Local cDetPos		:= oModel:GetValue("DAV_DETPOS")
Local cMsg			:= oModel:Getvalue("DAV_DETMSG")
Local cCodOco		:= ""
Local cAtivid     := ""
Local cLogErro		:= ""
Local cFilDoc		:= "" 
Local cDoc			:= ""
Local cSerie		:= ""
Local cQtdVol		:= ""
Local cNumNFC		:= "" 
Local cSerTMS		:= "" //-- Irá armazenar o serviço de transporte da viagem ( Coleta, Transporte ou Entrega )   
Local cTipApo		:= "" //-- 0-Nao utiliza;1-Inicio;2-Fim;3-Inicio/Fim - Controle para o Inicio data/hora e Realizado das atividades  
Local cChaveDAZ	:= "" 
Local cQuery		:= ""
Local cAliasQry 	:= ""
Local cFilRest		:= cFilAnt
Local cFilRest2	:= ""
Local cHorRea		:= StrTran(Left(Time(),5),":","")
Local aCab			:= {} 
Local aItens 		:= {}
Local aItemMac    := {}
Local aItemDoc		:= {}             
Local aAreaDTW		:= {}
Local aOcorPos		:= {} 
Local aViagem		:= {}
Local aArea			:= GetArea()
Local aAreaDAV		:= DAV->( GetArea() ) 
Local aAreaDTQ		:= DTQ->( GetArea() )
Local aAreaDUP		:= {}
Local nCountErr	:= 0
Local nSeq		 	:= 0  
Local nItemDoc		:= 0
Local nCount		:= 1 
Local nDiasLim		:= SuperGetMV('MV_DIASPOS',.F.,15) 
Local lAtuDoc		:= .F.
Local lConfigMac 	:= .F. 
Local lGravaDTW	:= .F.   
Local lFilOriMac  := .F. //-- Variavel que identifica se enviou filial de origem na mensagem de macro
Local lViagemMac	:= .F. //-- Variavel que identifica se enviou viagem na mensagem de macro	
Local lFilialMac	:= .F. //-- Variavel que identifica se enviou filia na mensagem de macro
Local lIDMsgPos	:= Iif( DUA->( FieldPos("DUA_IDMPOS") ) > 0 .And. DTW->( FieldPos("DTW_IDMPOS") ) > 0 , .T. , .F. ) 
Local dDatRea		:= dDataBase //-- Data do apontamento realizado
Local cAptJor		:= ""
Local lAptJor		:= SuperGetMv("MV_CONTJOR",,.F.) .And. AliasInDic("DEW") .And. DAO->( FieldPos("DAO_APTJOR") ) > 0  //-- Apontamento da jornada do motorista 
Local aCodMot		:= {}
Local nCountMot	:= 0 
Local cChaveDUP	:= ""
Local aItemDTC    := {}   
Local lRet			:= .T.
Local cAliasDUA	:= "" 
Local cQueryDUA	:= ""
Local nRecnoDUA	:= 0
Local lIncluDUA	:= .T.

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

cAliasQry := GetNextAlias()

cQuery := " SELECT * FROM " + RetSqlName("DAQ") + " DAQ "
cQuery += " WHERE DAQ_FILIAL 	= '" + xFilial("DAQ") + "' "
cQuery += " AND DAQ_CODMAC   	= '" + cCodMac 			+ "' "  
cQuery += " AND D_E_L_E_T_		= ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.)   

//-- Preenche array com os itens de configuração de macro
While (cAliasQry)->( !Eof() )
	Aadd( aItemMac , {} )
   Aadd( aItemMac[Len(aItemMac)], (cAliasQry)->DAQ_ITEM   )
   Aadd( aItemMac[Len(aItemMac)], (cAliasQry)->DAQ_CPOMAC )
   Aadd( aItemMac[Len(aItemMac)], (cAliasQry)->DAQ_TAMCPO )
   Aadd( aItemMac[Len(aItemMac)], (cAliasQry)->DAQ_POSINI )
   Aadd( aItemMac[Len(aItemMac)], (cAliasQry)->DAQ_POSFIM )   
	(cAliasQry)->( dbSkip() )
EndDo

cQuery := ""
(cAliasQry)->( dbCloseArea() )
   
dbSelectArea("DUD")

AO10StrMsg( cMsg , aItemMac , cFilOri , cViagem , @cLogErro , .F. , @lFilialMac , @lFilOriMac , @lViagemMac )

//-- Retorna ultima filial de origem e viagem do veiculo
If FwIsInCallStack("TMSAE81")
	lFilOriMac := .T.
	lViagemMac := .T.
Else
	aViagem 	:= AO10RetVge( cCodVei, cCodMac, dDatIni, cHorIni, lFilialMac )
EndIf

If !lFilOriMac
	cFilOri	:= aViagem[1]
	oModel:SetValue('DAV_FILORI',cFilOri)
Else
	cFilOri := oModel:GetValue("DAV_FILORI")
EndIf

If !lViagemMac
	cViagem 	:= aViagem[2]
	oModel:SetValue('DAV_VIAGEM',cViagem)
Else
	cViagem	:= oModel:GetValue("DAV_VIAGEM")
EndIf

If !Empty(cViagem) .And. !Empty(cFilOri)
	//-- Se nao enviou filial na mensagem de macro, considera a filial de origem da viagem
	If !lFilialMac
		cFilAnt := cFilOri 
	EndIf
	
	DTQ->( dbSetOrder(2) ) //-- DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM
	DAO->( dbSetOrder(1) ) //-- DAO_FILIAL+DAO_CODMAC
	DAQ->( dbSetOrder(1) ) //-- DAQ_FILIAL+DAQ_CODMAC+DAQ_ITEM  
	DAZ->( dbSetOrder(1) ) //-- DAZ_FILIAL+DAZ_CODMAC
	
	If DTQ->( MsSeek(xFilial("DTQ")+cFilOri+cViagem ))
		cSERTms := DTQ->DTQ_SERTMS 		
	EndIf
	
	If !Empty(cCodMac) 
	 
	   cAliasQry := GetNextAlias()
	   
	   cQuery := "  SELECT DAO.DAO_CODMAC, DAO.DAO_ATIVID, DAO.DAO_TIPAPO, DAZ.DAZ_CODOCO, DT2.DT2_CODOCO, DT2.DT2_CATOCO "
	   If lAptJor
	   	cQuery += " , DAO.DAO_APTJOR "
	   EndIf
	   cQuery += "    FROM " + RetSqlName("DAO") + " DAO "  
	   cQuery += " 	LEFT JOIN " + RetSqlName("DAZ") + " DAZ "
	   cQuery += " 	  ON DAZ.DAZ_FILIAL = '" + xFilial("DAZ") + "' "
	   cQuery += "		 AND DAZ.DAZ_CODMAC = DAO.DAO_CODMAC " 
	   cQuery += "		 AND DAZ.DAZ_SERTMS = '" + cSerTms + "' "
	   cQuery += " 	 AND DAZ.D_E_L_E_T_ = ' ' " 
	   cQuery += " 	LEFT JOIN " +  RetSQLName("DT2") + " DT2 " 
	   cQuery += "		  ON DT2.DT2_FILIAL = '" + xFilial("DT2") + "' "
	   cQuery += "		 AND DT2.DT2_CODOCO = DAZ.DAZ_CODOCO "
	   cQuery += "		 AND DT2.D_E_L_E_T_ = ' '  "
	   cQuery += "   WHERE DAO.DAO_FILIAL = '" + xFilial("DAO") + "' "
	   cQuery += "     AND DAO.DAO_CODMAC = '" + cCodMac + "' "
	   cQuery += "  	 AND DAO.D_E_L_E_T_ = ' ' "
	   
	 	cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.)  	
	   
	   If !Empty((cAliasQry)->DAO_CODMAC)
	   	cAtivid  := (cAliasQry)->DAO_ATIVID 
			cTipApo	:= (cAliasQry)->DAO_TIPAPO   
			
			If lAptJor
				cAptJor := (cAliasQry)->DAO_APTJOR 
			EndIf
			
			While (cAliasQry)->( !Eof() )			
				cCodOCo := (cAliasQry)->DT2_CODOCO   	
				If (cAliasQry)->DT2_CATOCO = '1'
			  		lAtuDoc := .T.							
			   EndIf			   
				(cAliasQry)->( dbSkip() )
			EndDo
			
			//-- Se a ocorrencia vinculada realiza atualizacao por docto. verifica itens de configuracao de macro
			If lAtuDoc .And. DAQ->( MsSeek( xFilial("DAQ") + cCodMac) )
				lConfigMac := .T.
			EndIf 

	   Else
	   	cLogErro += RetTitle("DAV_CODMAC") + cCodMac + STR0027 + 	CRLF  //-- Macro inexistente
	   EndIf
	
		cQuery := ""
		(cAliasQry)->( dbCloseArea() )
      
		dbSelectArea("DUD")
		
	EndIf
	
	If nOperation == 3 
	   If !Empty(cCodOco)
	   	 	
	      DT6->( dbSetOrder(1) )
		   DUD->( dbSetOrder(2) )
		   nSeq := 1  
		   aCab := {}
			AAdd(aCab,{"DUA_FILORI",cFilOri,Nil})
			AAdd(aCab,{"DUA_VIAGEM",cViagem,Nil})
			 
		   If lAtuDoc .And. DUD->( MsSeek( xFilial("DUD") + cFilOri + cViagem ))
		     	
		   	If lConfigMac
		   		//-- Realiza a quebra de mensagem conforme itens de configuracao de macro
		   		aItemDoc := AO10StrMsg( cMsg , aItemMac , cFilOri , cViagem , @cLogErro , .T. )
		   		
		   		For nCount := 1 To Len(aItemDoc)
	   		  			
						If !Empty(aItemDoc[nCount])
							AAdd(aItens,{{"DUA_SEQOCO", StrZero(nCount,Len(DUA->DUA_SEQOCO)),	Nil },;
								 			{"DUA_DATOCO", dDatIni							,	Nil },;
											{"DUA_HOROCO", cHorIni							,	Nil },;
											{"DUA_CODOCO", cCodOco							,	Nil } } ) 
											
							If lIDMsgPos
				 				Aadd( aItens[Len(aItens)] , { "DUA_IDMPOS" , M->DAV_IDMPOS , Nil } )
			  				EndIf
		
							For nItemDoc := 1 To Len(aItemDoc[nCount])
								Aadd( aItens[Len(aItens)] , aItemDoc[nCount,nItemDoc]  )
							Next nX
						EndIF
		   		Next nCount  		   
		
		   	EndIf		
			EndIf
	
			If Empty(aItens)
		   	aItens:= {}
				AAdd(aItens,{{"DUA_SEQOCO", StrZero(nCount,Len(DUA->DUA_SEQOCO))	,  Nil},;
				   			{"DUA_DATOCO" , dDatIni									,  Nil},;
							{"DUA_HOROCO" , cHorIni									,  Nil},;
							{"DUA_CODOCO" , cCodOco									,  Nil}})  
								
				If lIDMsgPos
					Aadd( aItens[Len(aItens)] , { "DUA_IDMPOS" , M->DAV_IDMPOS , Nil } )
			  	EndIf
			
			EndIf
		  
			//-- Inclusao da Ocorrencia			
			MsExecAuto({|x,y,z|Tmsa360(x,y,z)},aCab,aItens,{},nOperation)
		      
			If lMsErroAuto
				aErroAuto := GetAutoGRLog()
				For nCountErr := 1 To Len(aErroAuto)					
					cLogErro += StrTran(StrTran(aErroAuto[nCountErr],"<",""),"-","") + (" ")
				Next nCountErr
				cLogErro += " / " + CRLF					
			EndIf
		EndIf
		
		If !Empty(cAtivid)
		   If !Empty(cViagem) .And. !Empty(cFilOri)	
		   	DTW->( dbSetOrder(4) )
		   	If DTW->( MsSeek( xFilial("DTW") +  cFilOri + cViagem + cAtivid ) ) 
		   	   
		   	   //-- 1-Inicio da atividade 
		   	   //-- 2-Fim da atividade 
		   	   //-- 3-Inicio/Fim 	   	   
		   	   If cTipApo == "1"		   	   	
		   	   	dDatRea 	:= Nil  		   	   	  
		   	   	cHorRea 	:= Nil		   	   
		   	   ElseIf cTipApo == "2"
		   	      dDatRea	:= dDatIni
		   	   	cHorRea	:= cHorIni
		   	   	dDatIni 	:= Nil    
		   	   	cHorIni	:= Nil
		   	   ElseIf cTipApo == "3" 
						dDatRea 	:= dDatIni  		   	   	  
		   	   	cHorRea  := cHorIni		   	   
		   	   EndIf   	   
		   	   
		   	   cFilRest2 	:= cFilAnt 
		   	   cFilAnt		:= Iif( !Empty(DTW->DTW_FILATI) , DTW->DTW_FILATI , cFilAnt )  
		   	   
		   	   aAreaDTW := DTW->( GetArea() ) 
		   	   Begin Transaction 
		   	   
		   	 	lGravaDTW := TMSA350Grv(nOperation , cFilOri , cViagem , cAtivid ,dDatIni ,cHorIni ,dDatRea , cHorRea , , , M->DAV_IDMPOS ) 
		   	 	
		   		End Transaction
		   		
		   		If !lGravaDTW
		   			cLogErro += STR0011 + cAtivid + STR0012 + cViagem + CRLF //-- Gravação de atividade /  não efetuada para a viagem  
		   		EndIf
		   		cFilAnt := cFilRest2
		   		RestArea( aAreaDTW )
		   	Else
		   		cLogErro 	+= STR0013 + cViagem 			//-- Operação de transporte inexistente para a viagem
		   		cLogErro    += STR0014 + cCodMac + CRLF   //-- Verifique a atividade vinculada a macro
		   	EndIf   
		   
		   EndIf			
		EndIf 
		
		
		//-- Apontamentos da jornada do motorista
		If lAptJor .And. !Empty(cAptJor) 
		
			aAreaDUP := DUP->( GetArea() ) 
		
			//-- Busca motoristas da viagem 
			DUP->( dbSetOrder(1) ) //-- DUP_FILIAL+DUP_FILORI+DUP_VIAGEM
			If DUP->( MsSeek( cChaveDUP := xFilial("DUP") + cFilOri + cViagem )) 
				While DUP->( !Eof() ) .And. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM) == cChaveDUP 
			   	Aadd( aCodMot , DUP->DUP_CODMOT )	   	   
			   	DUP->( dbSkip() )
				EndDo
			EndIf
		 	
		 	If FindFunction("TMSAptJor")
			 	For nCountMot := 1 To Len( aCodMot ) 
               //-- Realiza apontamento da jornada ( DEW ) 
			  		TMSAptJor( aCodMot[nCountMot] , cAptJor , oModel:GetValue("DAV_DATPOS") , oModel:GetValue("DAV_HORPOS") , cFilOri , cViagem , cMsg)
			 	
			 	Next nCountMot
			EndIf 	
		   
			RestArea( aAreaDUP ) 
		EndIf	
		
	EndIf
	
Else                
	If !Empty(cCodMac)                
		cLogErro 	+= STR0015 + cCodVei + CRLF 	//--  Não foi encontrada viagem para o veículo 
		cLogErro		+= STR0016 + CRLF					//-- As viagens com Status igual a 3=Encerrada ou 9=Cancelada não são consideradas 
		cLogErro 	+= STR0017 + CRLF					//-- Viagens com Tipo Viagem igual a 3=Planejada não são consideradas 
			
		dDatIni		:= oModel:GetValue("DAV_DATPOS")	
		cLogErro 	+= STR0024 + DToC(dDatIni) + STR0025 + DToC( dDatIni - nDiasLim ) + CRLF //-- O intervalo considerado foi para as viagens entre ( Data do posicionamento ) e ( Data Limite ) 
	   cLogErro		+= STR0026 + CRLF  //-- Configure o parâmetro MV_DIASPOS para alterar o critério de busca das viagens, a partir da data do posicionamento recebido 
	EndIf
EndIf

//-- Restaura para a filial original
cFilAnt := cFilRest 

//-- Gravacao de log de erro e atualizacao de status do posicionamento
If !Empty(cLogErro)
	oModel:SetValue("DAV_DETLOG", cLogErro  )
	oModel:SetValue("DAV_STATUS", "2") 
Else
	oModel:SetValue("DAV_STATUS", "3")
EndIf

DAV->( RestArea(aAreaDAV) ) 
DTQ->( RestArea(aAreaDTQ) )
RestArea(aArea)

Return .T.  

//-------------------------------------------------------------------
/*AO10StrMsg
            
Quebra da mensagem de macro, e devolve o conteudo

@author  Caio Murakami
@since   10/05/12
@version 1.0      
*/
//-------------------------------------------------------------------

Static Function AO10StrMsg( cMsg , aItemMac , cFilOri , cViagem , cLogErro , lDocMac , lFilialMac , lFilOriMac , lViagemMac )
Local aRet 			:= {}
Local nCount 	   := 0
Local cDoc			:= ""
Local cFilDoc		:= ""
Local cSerie	 	:= ""
Local cRptCpo  	:= ""  
Local cQuery   	:= "" 
Local cObsMac		:= "" 
Local cFilMac		:= ""  //-- Filial enviada na mensagem de macro
Local cSerieTit   := Posicione('SX3' ,2 ,'DUD_SERIE' , 'X3Titulo()')
Local cDocTit		:= Posicione('SX3', 2, 'DUD_DOC'   , 'X3Titulo()')
Local cViagTit		:= Posicione('SX3', 2, 'DTQ_VIAGEM', 'X3Titulo()')
Local cFilDocTit  := Posicione('SX3', 2, 'DUD_FILDOC', 'X3Titulo()') 
Local cAlias 		:= GetNextAlias()
Local aArea			:= GetArea()  
Local aAreaDTQ		:= DTQ->( GetArea() )
Local nQtdVol		:= 0  
Local oModel		:= FwModelActive()

Local lDoc   		:= .F. //-- Considera a filial do documento = filial de origem 

Default lDocMac	 	:= .F.    
Default cFilOri		:= ""	
Default cViagem		:= ""	 
Default aItemMac		:= {}
Default cMsg			:= ""  
Default lFilialMac  	:= .F.  
Default lFilOriMac	:= .F.  
Default lViagemMac	:= .F.

/*
aItemMac[][1] == DAQ->DAQ_ITEM 
aItemMac[][2] == DAQ->DAQ_CPOMAC
aItemMac[][3] == DAQ->DAQ_TAMCPO
aItemMac[][4] == DAQ->DAQ_POSINI
aItemMac[][5] == DAQ->DAQ_POSFIM
*/               

oModel := oModel:GetModel("MdFieldDAV")

dbSelectArea("DUD")
Aadd( aRet, {} )
nCount := 1
While nCount <= Len(aItemMac)
   //-- Irá tratar apenas os itens 01,02,03,04
   If lDocMac
   
	  	//-- Verifica se item de macro esta repetido para adicionar novo nivel de array
	   If aItemMac[nCount,2] $ cRptCpo   
	   
	   	//-- Item de macro possui numero do documento mas nao possui filial
	   	If '02' $ cRptCpo .And. !('01' $ cRptCpo)
				lDoc := .T.
				//-- Considera a filial do documento igual a filial de origem
				cFilDoc := cFilOri 
				cRptCpo += '01'
	   	Else
				Aadd( aRet, {} )	    
		   	cRptCpo 	 := ""  
	   	EndIf
	   Else  
			/*[01 - Fil. Docto.]
			[02 - No. Docto.   ]
			[03 - Qtde. Volume ]
			[04 - Obs. da Macro]
			[05 - Fil. Ori.    ]
			[06 - Viagem       ]
			[07 - Filial       ]
			*/	
	   	If aItemMac[nCount,2] == '01'
		  		cFilDoc := SubStr(cMsg, aItemMac[nCount,4] , aItemMac[nCount,3])
		  		//-- Se filial nao preenchida, considera filial da viagem
		  		If Empty(cFilDoc)
		  			cFilDoc := cFilOri
		  		EndIF
		  		lDoc := .F. 	    	
		  	ElseIf aItemMac[nCount,2] == '02'      	
		  		cDoc := SubStr(cMsg, aItemMac[nCount,4] , aItemMac[nCount,3])	
		  	ElseIf aItemMac[nCount,2] == '03'
		  		nQtdVol := Val(SubStr(cMsg, aItemMac[nCount,4] , aItemMac[nCount,3]))
		  	   If nQtdVol > 0 .And. nCount != Len(aItemMac)
		  	   	Aadd( aRet[Len(aRet)] ,  {"DUA_QTDOCO" , nQtdVol , Nil}  )
		  	   EndIf
		  	ElseIf aItemMac[nCount,2] == '04'
		  		cObsMac := SubStr( cMsg, aItemMac[nCount,4] , aItemMac[nCount,3] )
		  		If !Empty(cObsMac) .And. nCount != Len(aItemMac)
		  			Aadd( aRet[Len(aRet)] ,  {"DUA_MOTIVO" , cObsMac , Nil}  )	
		  		EndIf
		  	EndIf 
		  	cRptCpo += aItemMac[nCount,2]
		  	nCount++	  		  	  
	   EndIf
	  	 
	  	If (!Empty(cDoc) .And. !Empty(cFilDoc)) .Or. nCount > Len(aItemMac) 
	    	If Empty(cFilDoc)
	    		cFilDoc := cFilOri
	    	EndIf 
	    	If !Empty(cDoc)
		    	cQuery := " SELECT DUD_SERIE    "
				cQuery += " FROM " + RetSQLName("DUD") + " DUD " 
				cQuery += " WHERE " 
				cQuery += 	" DUD_FILIAL      	= '" + xFilial("DUD")   + "' " 
				cQuery += 	" AND DUD_FILORI  	= '" + cFilOri          + "' "
				cQuery += 	" AND DUD_VIAGEM  	= '" + cViagem          + "' "
				cQuery +=   " AND DUD_FILDOC  	= '" + Padr(cFilDoc,TamSx3("DUD_FILORI")[1]) + "' "
				cQuery +=   " AND DUD_DOC     	= '" + Padr(cDoc,TamSx3("DUD_DOC")[1])    + "' "
				cQuery += 	" AND DUD.D_E_L_E_T_ = ' ' " 
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAlias),.F.,.T.) 
				
				cSerie := (cAlias)->DUD_SERIE
		   	
		   	(cAlias)->( DBCloseArea() )
		   	
		   	If Empty(cSerie)
		  		  	cLogErro += cSerieTit  + STR0018 + cFilDocTit + cFilDoc  + " " //-- Não encontrado
		  		  	cLogErro += cDocTit + cDoc + " " + cViagTit + cViagem + " / "    
		  		Else 
		  		 	Aadd( aRet[Len(aRet)], {"DUA_FILDOC" , cFilDoc , Nil } )
		  		 	Aadd( aRet[Len(aRet)], {"DUA_DOC" , cDoc , Nil }    )
		  		 	Aadd( aRet[Len(aRet)], {"DUA_SERIE", cSerie , Nil }  )
		  		 	If nQtdVol > 0 
			  	   	Aadd( aRet[Len(aRet)] ,  {"DUA_QTDOCO" , nQtdVol , Nil}  )
			  	   EndIf
		  		 	If !Empty(cObsMac)
			  			Aadd( aRet[Len(aRet)] ,  {"DUA_MOTIVO" , cObsMac , Nil}  )	
			  		EndIf
			   EndIf	   
		   	cDoc 		:= ""
		   	If !lDoc
			    	cFilDoc 	:= ""
			   EndIf
		     	nQtdVol  := 0 	
		     	cObsMac  := ""
		   EndIf
   	EndIf
   Else
   	/*[01 - Fil. Docto.]
		[02 - No. Docto.   ]
		[03 - Qtde. Volume ]
		[04 - Obs. da Macro]
		[05 - Fil. Ori.    ]
		[06 - Viagem       ]
		[07 - Filial       ]
		*/	
		 
		/*
		aItemMac[][1] == DAQ->DAQ_ITEM 
		aItemMac[][2] == DAQ->DAQ_CPOMAC
		aItemMac[][3] == DAQ->DAQ_TAMCPO
		aItemMac[][4] == DAQ->DAQ_POSINI
		aItemMac[][5] == DAQ->DAQ_POSFIM
		*/      
	
		If aItemMac[nCount,2] == '05'
	 		cFilMac := SubStr(cMsg, aItemMac[nCount,4] , aItemMac[nCount,3])
	  		If !Empty(cFilMac) .And. FwFilExist( cEmpAnt , cFilMac )
	  			lFilialMac	:= .T.
	  			cFilAnt := cFilMac
	  		Else
	  			cLogErro += RetTitle("DAV_FILIAL") + cFilMac + STR0027 + CRLF	 //-- FILIAL INEXISTENTE			
	  		EndIf 	 	
	  	ElseIf aItemMac[nCount,2] == '06'      	
	  		cFilOri := SubStr(cMsg, aItemMac[nCount,4] , aItemMac[nCount,3])	  		    	
	  		DTQ->( dbSetOrder(2) )
	  		If !DTQ->( MsSeek( xFilial("DTQ") + cFilOri ) ) 
	  			cLogErro += RetTitle("DAV_FILORI") + cFilOri + STR0027 + CRLF //-- FILIAL DE ORIGEM INEXISTENTE
	  		Else
	  			If	oModel:SetValue("DAV_FILORI", cFilOri )   
	  				lFilOriMac := .T.
	  			EndIf
	  		EndIf  	
	  	ElseIf aItemMac[nCount,2] == '07'
	  		DTQ->( dbSetOrder(1) )
	  		cViagem := SubStr(cMsg, aItemMac[nCount,4] , aItemMac[nCount,3])
	  		If !DTQ->( MsSeek( xFilial("DTQ") + cViagem ) )
	  			cLogErro += RetTitle("DAV_VIAGEM") + cViagem +  STR0027  + CRLF  	//-- VIAGEM INEXISTENTE
	  		Else
	  			If oModel:SetValue("DAV_VIAGEM",cViagem)	   
	  				lViagemMac := .T.
	  			EndIf
	  		EndIf	
	   EndIf
		nCount++	     
   	
  	EndIf   
EndDo

RestArea( aAreaDTQ ) 
RestArea(aArea     )

Return aRet    

//-------------------------------------------------------------------
/*AO10RetVge
            
Retorna a viagem corrente do veículo

@author  Caio Murakami
@since   10/05/12
@version 1.0      
*/
//-------------------------------------------------------------------
        
Static Function AO10RetVge(cCodVei, cCodMac, dDatPos, cHorPos , lFilialMac )      
Local cViagem 		:= "" 
Local cFilOri		:= ""
Local cQuery 		:= "" 
Local cCodAtivi	:= ""  
Local cStatusDTQ	:= ""    
Local nDiasLim		:= SuperGetMV('MV_DIASPOS',.F.,15) 
Local dData			:= dDatPos
Local dDataLim		:= dDatPos - nDiasLim 
Local aArea	   	:= GetArea()
Local aAreaDAO		:= DAO->( GetArea() )
Local cAlias  		:= GetNextAlias()    
Local lAtivSai		:= .F.
Local lAtivChg		:= .F.

Local cAtivChg	  	:= SuperGetMV('MV_ATIVCHG',.F.,'') //-- Atividade de Chegada de viagem
Local cAtivSai	  	:= SuperGetMV('MV_ATIVSAI',.F.,'') //-- Atividade de Saida de viagem

Default cCodMac 	:= ""
Default dDatPos   := dDataBase
Default cHorPos	:= "" 
Default lFilialMac:= .F.

If !Empty(cCodMac)      
	DAO->( dbSetOrder(1) )	
	If DAO->( MsSeek( xFilial("DAO") + cCodMac ) )	    
	 	cCodAtivi := DAO->DAO_ATIVID	
	 	If !Empty(cCodAtivi)
			If cCodAtivi == cAtivChg
				lAtivChg	:= .T.						 					
			ElseIf cCodAtivi == cAtivSai 				
				lAtivSai := .T.						 	
			EndIf
		EndIf
  	EndIf	   	
EndIf

While Empty(cFilOri) .And. Empty(cViagem) .And. dData >= dDataLim 

	cQuery := " SELECT DTR_FILIAL , DTR_VIAGEM, DTR_FILORI , DTQ_STATUS "
	cQuery += " FROM " + RetSQLName("DTR") + " DTR " 
	cQuery += 	" INNER JOIN " + RetSQLName("DTQ") + " DTQ  "
	cQuery += 		"  ON   DTQ.DTQ_VIAGEM = DTR.DTR_VIAGEM  "
	cQuery +=		"	AND  DTQ.DTQ_FILORI = DTR.DTR_FILORI  "
	cQuery +=		"	AND  DTQ.DTQ_FILIAL = DTR.DTR_FILIAL  "  	
	cQuery +=  		"  AND DTQ.DTQ_STATUS NOT IN ('3', '9' ) " //-- 1=Em aberto;2=Em transito;3=Encerrada;4=Chegada em filial;5=Fechada;9=Cancelada      
	
	If lAtivChg
		cQuery 	+= "  AND DTQ.DTQ_STATUS IN ('2') "		
	ElseIf lAtivSai
  		cQuery 	+= "  AND DTQ.DTQ_STATUS IN ('1','5') "
  		cQuery 	+= "  AND DTQ.DTQ_DATGER = '" + DToS( dData )  + "' "	
	EndIf
	
	If !lAtivSai
		cQuery 	+= "  AND DTQ.DTQ_DATFEC = '" + DToS( dData )  + "' " 
	EndIf
		                                                                         
	cQuery += 		"  AND DTQ.DTQ_TIPVIA NOT IN ('3') "  //-- 1=Normal;2=Vazia;3=Planejada;4=Socorro;5=Redespacho     
	cQuery += 		"  AND DTQ.DTQ_TIPTRA = '1' " 
	cQuery +=  		"  AND DTQ.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE " 
	cQuery += 	" DTR.DTR_CODVEI = '" + cCodVei + "' "
	cQuery += 	" AND DTR.D_E_L_E_T_ = ' ' " 
	cQuery += 	" ORDER BY  " 
	If !lAtivSai
	   cQuery += 	" DTQ.DTQ_DATFEC, DTQ.DTQ_HORFEC DESC " 
	Else
		cQuery += 	" DTQ.DTQ_DATGER, DTQ.DTQ_HORGER DESC " 
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAlias),.F.,.T.) 
	
	If (cAlias)->(!Eof() ) 
		cFilOri 		:= (cAlias)->DTR_FILORI 
		cViagem 		:= (cAlias)->DTR_VIAGEM	 
		cStatusDTQ	:= (cAlias)->DTQ_STATUS
	EndIf
	
	dData-- 
	(cAlias)->( DBCloseArea() )

EndDo      

If lAtivSai .And. cStatusDTQ == '1' //-- Viagem em aberto
	AO10FecVge( cFilOri , cViagem , dDatPos , cHorPos , cCodAtivi , lFilialMac ) 
EndIf

RestArea( aAreaDAO ) 
RestArea( aArea    )

Return { cFilOri, cViagem }   


//-------------------------------------------------------------------
/*AO10FecVge
            
Atualiza status da viagem

@author  Caio Murakami
@since   04/01/13
@version 1.0      
*/
//-------------------------------------------------------------------


Static Function AO10FecVge( cFilOri, cViagem , dDatPos, cHorPos , cCodAtivi , lFilialMac )  
Local cFilRest := cFilAnt  
Local aArea		:= GetArea()   
      
Local aAreaDTQ := DTQ->( GetArea() )
Local aAreaDTR	:= DTR->( GetArea() ) 

Default lFilialMac := .F.

DTQ->( dbSetOrder(2) ) //-- FILIAL+FILORI+VIAGEM 

If !lFilialMac
  	//-- cFilAnt recebe o conteudo da filial de origem
  	cFilAnt 	:= cFilOri 
EndIf
  	
If DTQ->( MsSeek( xFilial("DTQ") + cFilOri + cViagem ) ) 
	TMSA310Grv( 3 , .T. , .F. , dDatPos , cHorPos )  
EndIf		 			
  
If !lFilialMac
	cFilAnt	:= cFilRest 
EndIf   	

RestArea( aAreaDTR ) 
RestArea( aAreaDTQ ) 
RestArea( aArea    )

Return NIL



//-------------------------------------------------------------------
/*AO10AtuPos( oModel )

Atualiza o posicionamento do veiculo

@author  Caio Murakami
@since   14/06/12
@version 1.0 

*/
//-------------------------------------------------------------------


Static Function AO10AtuPos(oModel)
Local cLatitu  := TMSLatLong(oModel:GetValue("DAV_LATITU")) //-- Retorna coordenadas no formato adequado
Local cLongit	:= TMSLatLong(oModel:GetValue("DAV_LONGIT")) //-- Retorna coordenadas no formato adequado
Local cPosici	:= ""

oModel:SetValue("DAV_LATITU",cLatitu)
oModel:SetValue("DAV_LONGIT",cLongit)

cPosici := AO10PtoPrx( Val(cLatitu) , Val(cLongit), /*Raio*/ ) 

oModel:SetValue("DAV_DETPOS",AllTrim(cPosici))

Return  

//-------------------------------------------------------------------
//-- AO10PtoPrx( nPVLat, nPVLong, nRaio)
/*Calcula o ponto de referencia a partir das coordenadas mais proximo

@author  Caio Murakami
@since   14/06/12
@version 1.0 

*/
//-------------------------------------------------------------------
Static Function AO10PtoPrx( nPVLat , nPVLong , nRaio)

Local cNomeMun		:= ""
Local cCodUF      := ""
Local cUF			:= ""
Local cRef			:= ""
Local cPosici		:= ""
Local cQuery1 		:= "" 
Local cQuery2 		:= "" 
Local cRecLat1		:= ""
Local cRecLat2		:= ""
Local cRecLong1	:= ""
Local cRecLong2	:= ""  
Local cPtoRef		:= ""
Local cEntida		:= "" 
Local cCodEntida  := ""  
Local cPicture		:= PesqPict('DAV','DAV_LATITU') //-- A mesma picture deve ser utilizada pelo cadastro de referencias
Local cAliasQry1	:= GetNextAlias()
Local cAliasQry2  := GetNextAlias()
Local nNumDist		:= 0
Local nPtoLat		:= 0
Local nPtoLong 	:= 0
Local nRecLat1 	:= 0
Local nRecLat2		:= 0
Local nRecLong1 	:= 0
Local nRecLong2 	:= 0
Local nMenorDist	:= 0  
Local nRecnoDAR	:= 0
Local aArea			:= GetArea()    

//-- Em metros
DEFAULT nRaio 		:= 1000 
  
If nRaio == 0
	nRaio := 1000
EndIf

While  cRef == ""  .And.  nRaio < 10000000 

	//-- Calcula Ponto médio
   nNumDist 	:= nRaio/(29.44 * 60 * 60 )
   nRecLat1 	:= nPVLat - nNumDist
   nRecLong1 	:= nPVLong - nNumDist
   nRecLat2		:= nPVLat + nNumDist
   nRecLong2	:= nPVLong + nNumDist 
    
   cRecLat1 	:= Transform( cValToChar(nRecLat1) , cPicture )
   cRecLat2 	:= Transform( cValToChar(nRecLat2) , cPicture )	
   cRecLong1 	:= Transform( cValToChar(nRecLong1), cPicture )		
   cRecLong2 	:= Transform( cValToChar(nRecLong2), cPicture )
    
   nMenorDist 	:= 99999999  
   
   If cRecLat1 > cRecLat2 
   	cAux			:= cRecLat1
   	cRecLat1	 	:= cRecLat2
      cRecLat2 	:= cAux
   EndIf       	
   
   If cRecLong1 > cRecLong2
   	cAux 			:= cRecLong1
   	cRecLong1	:= cRecLong2
   	cRecLong2	:= cAux
   EndIf
   //-- Query para encontrar registros entre as coordenadas passadas
   cQuery1 := " SELECT DAR_CODENT , DAR_LATITU , DAR_LONGIT, DAR_ENTIDA , R_E_C_N_O_ "   
   cQuery1 += " 	FROM " + RetSQLName("DAR") + " DAR " 
   cQuery1 += "   WHERE DAR_LATITU BETWEEN  '" + cRecLat1  + "' AND '" + cRecLat2  + " ' 
   cQuery1 += "		AND DAR_LONGIT BETWEEN '" + cRecLong1 + "' AND '" + cRecLong2 + " '
   cQuery1 += " 		AND D_E_L_E_T_ = ' ' "
   cQuery1 += " 	ORDER BY 2 "   
   
   cQuery1 := ChangeQuery(cQuery1)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery1),(cAliasQry1),.F.,.T.) 
	
	//-- Recebe o código do municipio - Lembrando que o código do município deve ser composto de código de estado + código da cidade
	cCodEntida 	:= (cAliasQry1)->(DAR_CODENT)
	           	
	cEntida 		:= (cAliasQry1)->(DAR_ENTIDA)
	
	nRecnoDAR   := (cAliasQry1)->(R_E_C_N_O_)
	
	//-- Cálculo de distancia à partir da coordenada recebida, e a coordenada do registro
	nNumDist:= AO10CalDis( nPVLat, nPVLong , Val((cAliasQry1)->DAR_LATITU) , VAl((cAliasQry1)->DAR_LONGIT) )
   
   (cAliasQry1)->( dbCloseArea() )
   
   If !Empty(cCodEntida)
      
      If 'CC2' $ cEntida      	                 
      	   
      	cPtoRef := ""  
      	
	      //-- Código do município deve ser composto de código de estado + código da cidade
	   	cCodUF 		:= SubStr(cCodEntida, 1, 2 )
	   	cCodEntida	:= SubStr(cCodEntida, 3, 7 )
	      
	      //-- Passa como parametro o código do estado, e é retornado a sigla correspondente, TMSA120 - deve estar atualizado
	      cUF := TMS120CdUf( cCodUF , "3")
	      	      
	   	cQuery2 := " SELECT  CC2_MUN ,   DAR_LATITU ,  DAR_LONGIT  "
	   	If DAR->( FieldPos("DAR_PTOREF") ) > 0
    			cQuery2 += "  , DAR_PTOREF  "
   		EndIf   
	   	cQuery2 += "	FROM " + RetSQLName("CC2") + " CC2 "
	   	cQuery2 += " 		LEFT JOIN " + RetSQLName("DAR") + " DAR "
	   	cQuery2 += "			ON DAR_FILENT  = CC2_FILIAL "
	   	cQuery2 += " 			AND DAR.R_E_C_N_O_ = " + cValToChar(nRecnoDAR) + " " 
	   	cQuery2 += " 	WHERE CC2_CODMUN  = '" + cCodEntida + " '
	   	cQuery2 += " 		AND CC2_FILIAL = '" + xFilial("CC2") + " '
	   	cQuery2 += " 		AND CC2_EST    = '" + cUF            + " '
	   	cQuery2 += " 		AND CC2.D_E_L_E_T_ = ' '                "  	
	      
	      cQuery2 := ChangeQuery(cQuery2)
	  		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery2),(cAliasQry2),.F.,.T.) 
	      
	     	cNomeMun := (cAliasQry2)->CC2_MUN
	     	nPtoLat  := Val((cAliasQry2)->DAR_LATITU)
	     	nPtoLong := Val((cAliasQry2)->DAR_LONGIT) 
	      
	     	If DAR->( FieldPos("DAR_PTOREF") ) > 0
  				cPtoRef := (cAliasQry2)->(DAR_PTOREF)
			EndIf
	     
	     	(cAliasQry2)->( dbCloseArea() )  
	     	
      EndIf
            
   EndIf 
   
   //-- Monta mensagem de posicionamento
   If !Empty(cCodEntida) .And. nNumDist <= nRaio .And. nNumDist < nMenorDist .And. !Empty(cNomeMun)
   	nMenorDist 	:= nNumDist 
   	cRef 			:= AllTrim(Transform(nNumDist/1000, "@E 999,999,999.99 ")) + " KM "    	 
   	//-- Calcula direcionamento tendo como referencia os pontos cardeais
   	cPosici 		:= AO10CalDir( nPtoLat, nPtoLong, nPVLat , nPVLong )    	
   	If !Empty(cPosici)
   		cRef			+= "(" + cPosici + ")"  
   	EndIf
   	cRef		   += " DE " + AllTrim(cPtoRef) + "(" + cUf + "-" + AllTrim( cNomeMun ) + ")"     	
   EndIf    
   
   //-- Duplica raio de busca 
   nRaio := nRaio * 2
   
EndDo 

//-- Se a variavel cRef estiver vazia significa que nao foi encontrado nenhum ponto de referencia 
//-- no raio máximo de 10000000 metros 
If Empty(cRef)    

	/* Ponto de referência não encontrado no raio de + cValToChar(Transform(nRaio, "@E 999,999,999.99 ")) + metros
	 para as coordenadas Latitude + cValToChar(nPVLat) + Longitude + cValToChar(nPVLong)*/ 
	 
	cRef += STR0019  + cValToChar(Transform(nNumDist, "@E 999,999,999.99 ")) + STR0020	
	cRef += STR0021 + STR0022 + AllTrim(M->DAV_LATITU) + STR0023 + AllTrim(M->DAV_LONGIT) 

EndIf

RestArea( aArea )
Return  cRef 

//-------------------------------------------------------------------
//--AO10CalDis( Latitude1, Longitude1, Latitude1, Latitude2) 
/*Calcula Distancia     

@author  Caio Murakami
@since   14/06/12
@version 1.0 
*/
//-------------------------------------------------------------------
Static Function AO10CalDis( nLat1, nLong1, nLat2 , nLong2 )
Local nDist 	:= 0
Local nLatitu	:= 0     
Local nLongit  := 0

nLatitu 		:= nLat1 - nLat2  
nLongit	 	:= nLong1 - nLong2             
            
nDist := Sqrt( (nLatitu * nLatitu ) + (nLongit * nLongit ) ) * ( 29.44 * 60 * 60 ) 

Return nDist                    


       
//-------------------------------------------------------------------
//-- AO10CalDir(Latitude1, Longitude1,Latitude2 ,Longitude2)
/*
Calcula aproximaçao retornando a direção ( Pontos cardeais ) 

@author  Caio Murakami
@since   14/06/12
@version 1.0 

*/
//-------------------------------------------------------------------
Static Function AO10CalDir( nNumLat1, nNumLong1 , nNumLat2 , nNumLong2)
Local cRet 		:= ""
Local nDLon		:= 0
Local nLat1 	:= 0
Local nLat2		:= 0
Local nX			:= 0
Local nY 		:= 0
Local nBear		:= 0
Local nPos1		:= 0


If (nNumLat1 <> 0 .And. nNumLat1 <> NIL ) .And. ( nNumLong1 <> 0 .And. nNumLong1 <> NIL) .And. ;
	(nNumLat2 <> 0 .And. nNumLat2<> NIL ) .And. ( nNumLong2 <> 0 .And. nNumLong2 <> NIL) .And. ;
	(nNumLat1 <> nNumLat2) .And. (  nNumLong1 <> nNumLong2)
	 
	//-- Valor do ânguloo em radianos
	nLat1	:= AO10Rad(nNumLat1)
	nLat2 := AO10Rad(nNumLat2)      
	
	nDLon := AO10Rad( nNumLong2 - nNumLong1 )
	
	nY 	:=  Sin(nDLon) * Cos(nLat2)
	nX		:= (Cos(nLat1) * Sin(nLat2))- (Sin(nLat1) * Cos(nLat2) * Cos(nDLon)) 
	
	//--	Retorna o ângulo, em radianos, entre o eixo x positivo e o raio a partir da origem até o ponto (y, x);
	//-- em que x e y são os valores das duas expressões flutuantes especificadas
	nBear :=  Atn2(nX, nY )
	
	//-- Valor do ângulo em graus
	nPos1 := AO10Degree(nBear) + 360
   
	nPos1 := Mod(nPos1,360)
	
	//-- Direção 
	If nPos1 >=0 .And. nPos1 <=22
		cRet := 'N'
	ElseIf nPos1 > 22 .And. nPos1 <= 67
		cRet := 'NE'
	ElseIf nPos1>67 .And.  nPos1 <= 112
		cRet := 'L'
	ElseIf nPos1 > 112 .And. nPos1 <=157
		cRet := 'SE'
	ElseIf nPos1 > 157 .And. nPos1 <= 202
		cRet := 'S'
	ElseIf nPos1 > 202 .And. nPos1 <= 247	
		cRet := 'SO'
	ElseIf nPos1 > 247 .And. nPos1 <= 292
		cRet := 'O'
	ElseIf nPos1 > 292 .And. nPos1 <= 337
		cRet := 'NO'
	ElseIf nPos1 > 337 .And. nPos1 <= 360
		cRet := 'N'
	EndIf
	
EndIf

Return cRet 
//-------------------------------------------------------------------
//-- AO10Rad( Ângulo )                                                         
/* Retorna o ângulo  em radianos  

@author  Caio Murakami
@since   14/06/12
@version 1.0 

*/
//-------------------------------------------------------------------

Static Function AO10Rad( nAngulo )
Local nRad := 0 

Default nAngulo := 0.00

nRad := 3.141592*( nAngulo / 180.00 )

Return nRad     

//-------------------------------------------------------------------
//-- AO10Degree(Ângulo em Radianos)  
/* Retorna o ângulo em graus  

@author  Caio Murakami
@since   14/06/12
@version 1.0  

*/
//-------------------------------------------------------------------
Static Function AO10Degree( nRad )
Local nAngulo := 0

nAngulo := (180*nRad)/3.141592

Return nAngulo 
      
//------------------------------------------------------------------- 
//-- TmsAO10Mnt()  
/* Manutenção de viagens  

@author  Caio Murakami
@since   08/08/12
@version 1.0  

*/
//-------------------------------------------------------------------
Function TmsAO10Mnt()
Local aAreaDTQ := DTQ->(GetArea() )

DTQ->( dbSetOrder(2) )

If DTQ->( dbSeek( xFilial("DTQ") + DAV->( DAV_FILORI + DAV_VIAGEM ) ) )
	TmsA140( DTQ->DTQ_SERTMS , DTQ->DTQ_TIPTRA ,,, DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM )
Else
	Help('',1,'REGNOIS')
EndIf

DTQ->( RestArea(aAreaDTQ) )
Return     
