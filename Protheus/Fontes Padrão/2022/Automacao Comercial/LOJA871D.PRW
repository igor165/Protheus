#INCLUDE "APWIZARD.CH" 
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "LOJA871D.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA870E
Efetua o fechamento servico financeiro gerando uma pedido de venda de prestacao
de servico para a administradora financeira.
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LOJA871D()
 
Local lRet := .F.    

Local nOpcA     := 0	// sem opção para incluir/alterar/excluir  
Local nValFin   := 0	// valor total dos titulos provisórios apresentado na tela
Local nValPed   := 0	// valor total do pedido de venda referente a prestacao de serviço para administradora financeira
Local nFreeze	:= 0	// sem freeze
Local nMax		:= 999999999 // maximo de itens
Local cLinOk	:= "AllwaysTrue"   // sempre .T.
Local cTudoOk	:= "AllwaysTrue"   // sempre .T.
Local cIniCpos	:= ""              // sem inicializador
Local cFieldOk	:= "AllwaysTrue"  // sempre .T.
Local cSuperDel	:= ""             // sem validação
Local cDelOk	:= "AllwaysTrue"  // sempre .T.
Local aAlter    := {}             //Array para campos que podem ser alterados

Local aColsMfi:= {} // para grid de titulos provisórios 
Local aColsSe2:= {} // para grid do titulo efetivo
Local aColsSc6:= {} // para grid do pedido de venda

Local aHeader1 := LjMtaHeader('1') // serve para aColsMfi e aColsSe2
Local aHeader2 := LjMtaHeader('2') // apenas para o aColsSc6 

Local oTPanel1:= Nil
Local oTPanel2:= Nil
Local oTPanel3:= Nil

Local aTitles := {STR0001, STR0002, STR0003} //'Titulos Provisórios'###'Titulo Efetivo Gerado' ####'Pedido de Venda Gerado'

Local oFolder:=Nil

Local oGet1    := Nil
Local oGet2    := Nil
Local oGet3	 := Nil
Local oWizard  := Nil
Local oSayPar  := Nil

Local oMvPar01:= Nil
Local oMvPar02:= Nil
Local oMvPar03:= Nil
Local oMvPar04:= Nil
Local oMvPar05:= Nil
Local oAdmFin := Nil

Local dDtIni:= CTOD("  /  /  ")
Local dDtFim:= CTOD("  /  /  ")
Local cSayPar   := ''
Local cMvPar01 := "1"
Local aMvPar01 := {"1=Sim","2=Não"}

Local cMvPar02 := Space(TamSx3("MFH_LOTE")[1])
Local cMvPar03 := Space(TamSx3("MG8_CODIGO")[1])
Local cMvPar04 := Space(TamSx3("E2_TIPO")[1])
Local cMvPar05 := Space(TamSx3("C5_CONDPAG")[1])
Local cAdmFin  := Space(TamSx3("AE_DESC")[1])

//Local cNat := ''//SuperGetMv("MV_LJNATRE",,"")	// Prefixo do titulo a pagar provisorio /

//Local cPref := ''//SuperGetMv("MV_LJPRGAR",,"") 	// Prefixo do titulo a pagar provisorio /

Local cAux:=	STR0004+; //"Esta rotina permite processar todas as vendas com Serviço Financeiro do período"
			 	STR0005+; //" informado de uma determinada Administradora Financeira(Prestadora de serviço). Emite um Pedido de Venda de Prestação de "
             	STR0006 //" Serviço para faturamento e gera um titulo permanente no Contas a Pagar, baixando os provisórios."
Local cMsg:= ''
    
Local lEstorno := .F.

//Efetua a quebra de linhas para escrita na tela inicial do Wizard
While !Empty(cAux)
	cMsg+= SubStr(cAux,1,IIf(EspacoAt(cAux, 125) > 1, EspacoAt(cAux, 125) - 1, 125))+CRLF
	cAux := SubStr(cAux,IIf(EspacoAt(cAux, 125) > 1, EspacoAt(cAux, 125), 125) + 1)
EndDo
	

//Valida se os parametros obrigatórios estão preenchidos
//If !Lj870VldSx6()
//	Return
//EndIf
//ÚÄÄÄÄÄÄÄ¿
//³Panel 1³
//ÀÄÄÄÄÄÄÄÙ
DEFINE WIZARD oWizard SIZE 0,0,550,800 TITLE STR0007 HEADER STR0008 ;	//"Fechamento Serviços Financeiro" ##"Definição do Processo"
		MESSAGE " "; 										
		TEXT " ";
		NEXT {|| .T. } ;
		FINISH {|| .T. } NOFIRSTPANEL	PANEL 		
		oWizard:GetPanel(1)		
		@ 035,015 SAY cMsg 	OF oWizard:GetPanel(1) PIXEL SIZE 500,030  
	//ÚÄÄÄÄÄÄÄ¿                                   
	//³Panel 2³
	//ÀÄÄÄÄÄÄÄÙ
		CREATE PANEL oWizard  HEADER STR0007 ;  	
			MESSAGE STR0008 ; 					
			BACK {|| .T. } ;
			NEXT {|| 	lRet:= Lj870EVldNx( oWizard:nPanel ,@oWizard,cMvPar02,cMvPar03,cMvPar04,cMvPar05,@lEstorno,;
										   @nValFin,@nValPed,@dDtIni,@dDtFim)    } FINISH {||  .T. };
			FINISH {|| .T.} PANEL 
			oWizard:GetPanel(2)  
			
			@ 15,10	 	TO   140,395 LABEL STR0009	OF oWizard:GetPanel(2) COLOR CLR_HBLUE PIXEL //"Parâmetros"

			oSayPar:= TMultiget():New(150,10,{|u| IIF(Pcount()>0,cSayPar:= u,cSayPar)},oWizard:GetPanel(2),150,040,,,,,,.T.,,.T.,,,,.T.,,,,.F.,.T.)//,.T.,.T.)	
			oSayPar:lWordWrap := .T.			

			@ 035,015 SAY STR0010 	OF oWizard:GetPanel(2) PIXEL SIZE 220,007  //"Imp. Relatório"
			oMvPar01 := TComboBox():New(035,85,{|u|if(PCount()>0,cMvPar01:=u,cMvPar01)},aMvPar01,50,10,oWizard:GetPanel(2),,{||  },,,,.T.,,,,,,,,,'cMvPar01')		
			oMvPar01:Select(1) //por padrão inicia como sim
			oMvPar01:bGotFocus:= {|| Lj870Say(@oSayPar,@cSayPar,STR0011,STR0012,"") }//"Define se exibe relatório de Fechamento Serviço financeiro" ##" ao final do processo."
			
			@ 055,015 SAY STR0013 	OF oWizard:GetPanel(2) PIXEL SIZE 220,007  //"Numero do Lote"
			@ 055,85 MSGET oMvPar02 VAR cMvPar02 Size 60,10 Picture "@!" F3 "MFH"  OF oWizard:GetPanel(2);
						VALID ( Iif(!Empty(cMvPar02),ExistCpo("MFH",cMvPar02), ) ) PIXEL 
			oMvPar02:bGotFocus:= {|| Lj870Say(@oSayPar,@cSayPar,STR0014,"","") } //"Informe o numero do lote do arquivo texto."
			
			@ 075,015 SAY STR0015 	OF oWizard:GetPanel(2) PIXEL SIZE 220,007 // "Serviço"
			@ 075,85 MSGET oMvPar03 VAR cMvPar03 Size 60,10 Picture "@!" F3 "MG8"  OF oWizard:GetPanel(2);
						VALID (  Iif(!Empty(cMvPar03),Lj871SFNChg(cMvPar03,@oAdmFin,@cAdmFin),) ) PIXEL 

			@ 080,150 SAY 	oAdmFin Var cAdmFin OF oWizard:GetPanel(2) PIXEL SIZE 210,9 			
															
			oMvPar03:bGotFocus:= {|| Lj870Say(@oSayPar,@cSayPar,STR0016,"","") } //"Informe serviço financeiro."
						
			@ 095,015 SAY STR0017 	OF oWizard:GetPanel(2) PIXEL SIZE 220,007  //"Tipo do Titulo" 
			@ 095,85 MSGET oMvPar04 VAR cMvPar04 Size 60,10 Picture "@!" F3 "05"  OF oWizard:GetPanel(2);
						VALID ( Iif(!Empty(cMvPar04),ExistCpo('SX5', '05' + cMvPar04),)  ) PIXEL 
			oMvPar04:bGotFocus:= {|| Lj870Say(@oSayPar,@cSayPar,STR0018,STR0019,"") } //#"Informe o tipo do titulo para gerar " ##"o financeiro"
			
			@ 115,015 SAY STR0020 	OF oWizard:GetPanel(2) PIXEL SIZE 220,007  //"Cond. Pgto"
			@ 115,85 MSGET oMvPar05 VAR cMvPar05 Size 60,10 Picture "@!" F3 "SE4"  OF oWizard:GetPanel(2);
						VALID (Iif(!Empty(cMvPar05),ExistCpo("SE4",cMvPar05),)  ) PIXEL
			oMvPar05:bGotFocus:= {|| Lj870Say(@oSayPar,@cSayPar,STR0021,STR0022,"") }//	#"Informe a condicao de pagamento" ##"para o pedido"					
			
			
	//ÚÄÄÄÄÄÄÄ¿
	//³Panel 3³
	//ÀÄÄÄÄÄÄÄÙ	
		CREATE PANEL oWizard  HEADER STR0007 ; //"Fechamento Serviços Financeiro"  	
			MESSAGE STR0008 ; //"Definição do Processo" 					
			BACK {|| .T.} ;
			NEXT {|| MsgRun(STR0023 ,,; //"Aguarde, efetuando o Fechamento Serviço financeiro ..."
			               { || Lj870Nota(dDtIni,dDtFim,cMvPar02,cMvPar03,cMvPar04,cMvPar05,@aColsSc6,;
			               @aColsMfi,@aColsSe2,@oWizard,@oGet1,@oGet2,@oGet3) } ),.T. } ;			
		    FINISH {||  .T. } PANEL 
			oWizard:GetPanel(3)  

			@ 035,015 SAY STR0024 ; //"Valor total do Fechamento do Serviço Financeiro:"
			OF oWizard:GetPanel(3)  PIXEL SIZE 300,007   

			@ 045,015 SAY STR0025 +TransForm(nValFin,PesqPict("MFI","MFI_VLRITE")) OF oWizard:GetPanel(3)  PIXEL SIZE 300,007 //"R$ "            

			@ 055,015 SAY STR0026 ; //"Valor total Pedido de Venda(Prestação de Serviço):"
			OF oWizard:GetPanel(3)  PIXEL SIZE 300,007   

			@ 065,015 SAY STR0025 +TransForm(nValPed,PesqPict("MFI","MFI_VLRITE"))	OF oWizard:GetPanel(3)  PIXEL SIZE 300,007
			
			@ 085,015 SAY STR0027+cMvPar03+" - "+Posicione("MG8",1,xFilial("MG8")+cMvPar03,"MG8_DESCRI"); //"Confirma o fechamento do serviço financeiro para o serviço selcionado:"			              
			OF oWizard:GetPanel(3)  PIXEL SIZE 500,007  
			
			@ 095,015 SAY STR0028+DTOC(dDtIni)+STR0029 +DTOC(dDtFim) +STR0030 OF oWizard:GetPanel(3)  PIXEL SIZE 500,007  //#"para o periodo " ##" até " ###" ?"			
						
	//ÚÄÄÄÄÄÄÄ¿
	//³Panel 4³ 
	//ÀÄÄÄÄÄÄÄÙ	
		CREATE PANEL oWizard  HEADER STR0007 ; //"Fechamento Serviços Financeiro"  	
			MESSAGE STR0008 ; //"Definição do Processo" 								
			BACK {|| .F.} ;
			NEXT {|| Iif(cMvPar01=='1',LOJA870J(.T.,Posicione("MG8",1,xFilial("MG8")+cMvPar03,"MG8_ADMIN"),cMvPar02),cMvPar01),oWizard:nPanel:= 5, .T. } ;
		    FINISH {||  .T. } PANEL EXEC {|| oWizard:OBACK:LVISIBLECONTROL := .F.}			
			oWizard:GetPanel(4)	                		

			oFolder := TFolder():New(000,000,aTitles,{"HEADER"},oWizard:GetPanel(4),,,, .T., .F.,315,140)
			oFolder:Align:= CONTROL_ALIGN_ALLCLIENT	  			
			

			oGet1 := MsNewGetDados():New(015,005,100,350,nOpcA,cLinOk,cTudoOk,cIniCpos,aAlter,;
				   						nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oFolder:aDialogs[1],@aHeader1,@aColsMfi)			
			oGet1:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT	   						

			oGet2 := MsNewGetDados():New(115,005,150,350,nOpcA,cLinOk,cTudoOk,cIniCpos,aAlter,;
				   						nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oFolder:aDialogs[2],@aHeader1,@aColsSe2)			
			oGet2:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT	   						

			oGet3 := MsNewGetDados():New(170,005,200,350,nOpcA,cLinOk,cTudoOk,cIniCpos,aAlter,;
				   						nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oFolder:aDialogs[3],@aHeader2,@aColsSc6)			          
			oGet3:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT	   						
	//ÚÄÄÄÄÄÄÄ¿
	//³Panel 5³ 
	//ÀÄÄÄÄÄÄÄÙ	
		CREATE PANEL oWizard  HEADER STR0007 ; //"Fechamento Serviços Financeiro" 	
			MESSAGE STR0008 ; //"Definição do Processo" 					
			BACK {|| .F.} ;
			NEXT {|| .T. } ;
		    FINISH {||  .T. } PANEL EXEC {|| oWizard:OBACK:LVISIBLECONTROL := .F.}			
			oWizard:GetPanel(5)
			@ 035,015 SAY STR0031 ; //"Não foi possivel realizar o Fechamento do Serviço Financeiro."
			OF oWizard:GetPanel(5)  PIXEL SIZE 300,007  
			
	//ÚÄÄÄÄÄÄÄ¿
	//³Panel 6³
	//ÀÄÄÄÄÄÄÄÙ	
		CREATE PANEL oWizard  HEADER STR0007 ; //"Fechamento Serviços Financeiro"  	
			MESSAGE STR0008 ; //"Definição do Processo" 					
			BACK {|| .F.} ;
			NEXT {|| .T. } ;
		    FINISH {||  .T. } PANEL EXEC {|| oWizard:OBACK:LVISIBLECONTROL := .F.}			
			oWizard:GetPanel(6)
			@ 035,015 SAY STR0032 ; //"Processamento da rotina finalizado."
			OF oWizard:GetPanel(6)  PIXEL SIZE 300,007  

						
ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.}
		

Return(Nil) 
    
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870Nota
Funcao que gera a nota fiscal de serviço para administradora financeira.
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function Lj870Nota(dDtIni,dDtFim,cMvPar02,cMvPar03,;
						cMvPar04,cMvPar05,aColsSc6,aColsMfi,;
						aColsSe2,oWizard,oGet1,oGet2,;
						oGet3)

Local cAliasTrb:= GetNextAlias() // Proximo alias disponivel
Local cNumTit  := ''     // Numero do titulo no financeiro
Local nVlrUnit := 0       //Valor unitario 
Local nVlrTot  := 0        // Valor total
Local cPedido  := ''      // Numero do pedido gerado
Local aItem    := {}     // Itens do pedido     de venda
Local aCab     := {}     // Cabecalho do pedido de venda
Local aLinha   := {}    // Itens do pedido     de venda
Local aRecMFI  := {}     //Recno da tabela 	MFI 
Local nItem    := 1      // Contador de itens
Local nPrcVen  := 0     // Preco de venda
Local nSaveSx8 := GetSx8Len()  
Local cProduto := ''//SuperGetMv("MV_LJPRDSC",,"")//produto servico para pedido de venda
Local cDescri  := ''//Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
Local cTes     := ''//SuperGetMv("MV_LJTESSV",,"")// tes de servico para pedido de venda
Local cMsg     := ''    // Mensagem do pedido de venda
Local nI       := 1          // contador
Local nTotReg  := 0          // Total de registros
Local cAdmFin  := ''//cMvPar03   // Administradora financeira
Local cTipo    := cMvPar04   // Tipo do titulo
Local cNatureza:= ''//cNat   // Natureza do titulo
Local cPrefixo := ''//cPref  // Prefixo do titulo
Local aRet     :=  {}       // Array de retorno para preenchimento do aCols do Wizard
Local lRet     := .T.
Private lMSErroAuto:= .F.
                                  
MG8->(DbSetOrder(1))
If MG8->(DbSeek(xFilial("MG8")+cMvPar03))
	cAdmFin  := MG8->MG8_ADMIN
	cProduto := MG8->MG8_PRDSF
	cDescri  := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
	cTes     := MG8->MG8_TES
	cNatureza:= MG8->MG8_NATURE
	cPrefixo := MG8->MG8_PREFIX
EndIf
//Efetua a extração dos dados para processamento
nTotReg:= FilDados(cAliasTrb,dDtIni,dDtFim,cMvPar02,cAdmFin)

ProcRegua(nTotReg)

If (cAliasTrb)->(!EOF())
	
	Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega um numero de pedido valido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPedido:= GETSXENUM("SC5","C5_NUM","",1)
	SC5->(DbSetOrder(1))
	While SC5->(DbSeek(xFilial("SC5")+cPedido))
		ConfirmSx8()
		cPedido:= GETSXENUM("SC5","C5_NUM","",1)
	EndDo 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera o cabecalho do pedido de venda.    				       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd(aCab,{"C5_FILIAL"  ,xFilial("SC5")				,Nil})
	AAdd(aCab,{"C5_NUM"   	,cPedido						,Nil})
	AAdd(aCab,{"C5_TIPO" 	,"N"								,Nil})
	AAdd(aCab,{"C5_CLIENTE"	,(cAliasTrb)->MFI_ADMIN	,Nil})
	AAdd(aCab,{"C5_LOJACLI"	,'01'							,Nil})
	AAdd(aCab,{"C5_TIPOCLI"	,'F'							,Nil})
	AAdd(aCab,{"C5_CONDPAG"	,cMvPar05						,Nil})
	AAdd(aCab,{"C5_OBS"		,cMsg							,Nil})

	AAdd(aItem,{"C6_FILIAL" 	,xFilial("SC6")				,Nil})
	AAdd(aItem,{"C6_NUM"    	,cPedido						,Nil})
	AAdd(aItem,{"C6_ITEM"   	,StrZero(nItem,2)				,Nil})
	AAdd(aItem,{"C6_PRODUTO"	,cProduto						,Nil})
	AAdd(aItem,{"C6_QTDVEN" 	,1								,Nil})
	AAdd(aItem,{"C6_TES"    	,cTes							,Nil})
	While (cAliasTrb)->(!EOF()) 
      	nPrcVen+= (cAliasTrb)->MFI_VLRITE - (cAliasTrb)->MFI_CUSTO
      	AAdd(aRecMFI,(cAliasTrb)->RECNOMFI)
      	IncProc()
		(cAliasTrb)->(DbSkip())
	EndDo
	AAdd(aItem,{"C6_PRCVEN" 	,nPrcVen					,Nil})
	AAdd(aItem,{"C6_PRUNIT" 	,nPrcVen					,Nil})
	AAdd(aItem,{"C6_VALOR"  	,nPrcVen 				    ,Nil})
		
	AAdd(aLinha,aItem)
	
	Aadd(aColsSc6,{xFilial("SC6"),cPedido,cProduto,cDescri,cTes,nPrcVen,.F.})
	
	(cAliasTrb)->(DbCloseArea())
	MSExecAuto({|x,y,z| Mata410(x,y,z)},aCab,aLinha,3)
	If lMSErroAuto
		Alert(STR0033+cPedido) //"Erro ao incluir pedido: "
		MostraErro()
		RollBackSxE()
		DisarmTransaction()
		aColsSc6:= {}
		aColsSe2:= {}
		aColsMfi:= {}		
		oWizard:nPanel:= 4
	Else
		//Chama rotina que ira aglutinar os titulos provisório no financeiro e gerar um unico para administradora financeira.
		MsgRun(STR0034,, { || cNumTit:= Lj870Fin(aRecMFI,cAdmFin,cTipo,cNatureza,cPrefixo,@aColsMfi,@aColsSe2) } ) //"Aguarde, substituindo os titulos provisórios ..."		
		If !Empty(cNumTit)
			//Grava o pedido na tabela de controle
			For nI:= 1 To Len(aRecMFI)
				MFI->(DbGoTo(aRecMFI[nI]))
				RecLock("MFI",.F.)
				MFI->MFI_PEDIDO := cPedido // Armazena o pedido de venda gerado para a administradora financeira
				MFI->(MsUnlock())		
			Next nI
			oWizard:nPanel:= 3	
			oGet1:SetArray(aColsMfi)
			oGet2:SetArray(aColsSe2)
			oGet3:SetArray(aColsSc6)
		Else 
			MSExecAuto({|x,y,z| Mata410(x,y,z)},aCab,aLinha,5)				
			oWizard:nPanel:= 4
			aColsSc6:= {}
			aColsSe2:= {}
			aColsMfi:= {}
		EndIf
		//Processo realizado com Sucesso.
	EndIf
	
	End Transaction
	 
Else
	MsgInfo(STR0035,STR0036) //#"Não há dados para processar!"  ## "Atenção"
	oWizard:nPanel:= 4
EndIf     


oGet1:Refresh()
oGet2:Refresh()
oGet3:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FilDados
Funcao que gera a nota fiscal de serviço para administradora financeira.
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function FilDados(cAliasTrb,dDtIni,dDtFim,cMvPar02,cAdmFin)

Local cQuery := ''
Local cDtIni := Dtos(dDtIni)//Dt inicial
Local cDtFim := Dtos(dDtFim)//Dt final
Local nRet   := 0 // retorna quantos registros tem na consulta


cQuery+= " SELECT MFI_ADMIN,MFI_PREFIX,MFI_TITULO,MFI_PARCEL,MFI_TIPO,MFI_VLRITE,MFI_CUSTO,MFI.R_E_C_N_O_ AS RECNOMFI"
cQuery+= "  FROM "+RetSqlName("MFI")+" MFI" +CRLF
cQuery+= " WHERE MFI.MFI_FILIAL = '"+xFilial("MFI")+"' "+CRLF
cQuery+= " AND MFI.MFI_ADMIN  = '"+cAdmFin+"' "+CRLF
cQuery+= " AND MFI.MFI_NUMLOT = '"+cMvPar02+"' "+CRLF
cQuery+= " AND MFI.MFI_ORIGEM = 'SF' "+CRLF
cQuery+= " AND MFI.MFI_SITGAR IN('','02')  "+CRLF
cQuery+= " AND MFI.MFI_EMISSA BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "+CRLF
cQuery+= " AND MFI.MFI_PEDIDO = ''   "+CRLF 
cQuery+= " AND MFI.D_E_L_E_T_ <> '*' "+CRLF
cQuery+= " ORDER BY MFI.MFI_FILORI,MFI.MFI_ADMIN,MFI.MFI_TITULO,MFI.MFI_TIPO,MFI.MFI_PREFIX"+CRLF
cQuery:= ChangeQuery(cQuery) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(cAliasTrb) > 0
	(cAliasTrb)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTrb, .F., .T.)

(cAliasTrb)->(DBGotop())
Count To nRet
(cAliasTrb)->(DBGotop())

Return nRet

       
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870Fin
Aglutina os titulos financeiros provisorio e gera um definitivo
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function Lj870Fin(aRecMFI,cAdmFin,cTipo,cNatureza,cPrefixo,aColsMfi,aColsSe2)

Local aFilTit:={}                            // Array com os titulos ja adicionados
Local nScan  := 0                            // Scan no titulos adicionado 
Local aSe2	  := {}                          // Array do titulo efetivo
Local aSe2Prov:= {}                          // Array de titulos provisorios
Local aAux    := {}                          // Array de titulos provisorios
Local nI      := 1                           //Contador
Local nSoma   := 0                           // somatoria dos titulos provisorios 
Local cNum    := ""                          // numero sequencial titulo financeiro
Local cParcela:= SuperGetMv("MV_1DUP",,"A")  // Define a parcela do titulo efetivo
Local cNatOp  := cNatureza                    // Define a natureza do titulo efetivo
Local aRet    := {{},{},{}}                  //Array bidimencional de retorno
Local cRet	  := ''                          // Armazena a chave do titulo efetivo
Local cFornece:= ''                          // Fornecedor para geracao do titulo efetivo
Local cLoja   :='01'                         // para administradora financeira eh sempre loja 01
Private lMsErroAuto := .F.                   // Variavel para o MsExecAuto

DBSelectArea("SE2")
DbSetOrder(1)
Dbseek( xFilial("SE2") + cPrefixo + Replicate("Z", TamSX3("E2_NUM")[1]), .T. )
DbSkip(-1) 
If SubStr(SE2->E2_NUM, 1, 1) == "0"
	 cNum := StrZero(Val(SE2->E2_NUM) + 1 ,Len(AllTrim(SE2->E2_NUM)))
Else
 	cNum := StrZero(Val(SE2->E2_NUM) + 1 ,Len(AllTrim(SE2->E2_NUM)))
EndIf  

//Busca administradora financeira cadastrada como fornecedor.
DbSelectArea("SA2")
DbSetOrder(8)  //A2_FILIAL+A2_CODADM
If dbSeek(xFilial("SA2")+cAdmFin)
	cFornece := SA2->A2_COD
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta array dos titulos provisorios a serem substituidos|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
For nI:= 1 To Len(aRecMFI)

	MFI->(DbGoTo(aRecMFI[nI]))	
	nScan:= aScan(aFilTit,MFI->MFI_FILORI+MFI->MFI_ADMIN+MFI->MFI_TITULO+MFI->MFI_TIPO+MFI->MFI_PREFIX)
	If nScan == 0
		AAdd(aAux,  { "E2_FILIAL"   ,MFI->MFI_FILORI    , NIL }) 
		AAdd(aAux,  { "E2_PREFIXO"  ,MFI->MFI_PREFIX    , NIL }) 
		AAdd(aAux,	{ "E2_NUM"      , MFI->MFI_TITULO   , NIL })
		AAdd(aAux,	{ "E2_PARCELA"  , MFI->MFI_PARCEL   , NIL })
		AAdd(aAux,	{ "E2_TIPO"     , MFI->MFI_TIPO     , NIL })
		AAdd(aAux,	{ "E2_NATUREZ"  , cNatOp            , NIL })
		AAdd(aAux,	{ "E2_FORNECE"  , MFI->MFI_FORNEC   , NIL })
		AAdd(aAux,	{ "E2_LOJA"     , MFI->MFI_LJFORN   , NIL})	
		aAdd(aSe2Prov,aAux)	         
		aAdd(aFilTit,MFI->MFI_FILORI+MFI->MFI_ADMIN+MFI->MFI_TITULO+MFI->MFI_TIPO+MFI->MFI_PREFIX)	         
		//Adiciona no aColsMfi para exibir no Wizard
        Aadd(aColsMfi,{MFI->MFI_FILORI,MFI->MFI_ADMIN,SA2->A2_NREDUZ,MFI->MFI_PREFIX,MFI->MFI_TITULO,MFI->MFI_TIPO,MFI->MFI_VLRITE,.F.})
	EndIf	
	nSoma+= MFI->MFI_VLRITE
	aAux:={}
Next nI                                                                

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta array do titulo|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSe2  := {  { "E2_FILIAL"   ,xFilial("SE2")    , NIL },; 
			{ "E2_PREFIXO"  , cPrefixo          , NIL },;
            { "E2_NUM"      , cNum              , NIL },;
            { "E2_PARCELA"  , cParcela          , NIL },;
            { "E2_TIPO"     , cTipo             , NIL },;
            { "E2_NATUREZ"  , cNatureza         , NIL },;
            { "E2_FORNECE"  , cFornece          , NIL },;
            { "E2_LOJA"     , '01'              , NIL },;
            { "E2_EMISSAO"  , dDataBase		 	, NIL },;
            { "E2_VENCTO"   , LastDay(dDataBase), NIL },;
            { "E2_VALOR"    , nSoma   		    , NIL },;
            { "E2_FLUXO"    , "S"   		    , NIL }}
Aadd(aColsSe2,{xFilial("SE2"),cFornece,SA2->A2_NREDUZ,cPrefixo,cNum,cTipo,nSoma,.F.})	            

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a inclusao do contas a pagar via ExecAuto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄEÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MSExecAuto({|a,b,c,d,e,f,g,h,i,j| Fina050(a,b,c,d,e,f,g,h,i,j)},aSe2,,6,,,,,,aSe2Prov,)
If lMsErroAuto
	MostraErro()
Else
	cRet:= xFilial("SE2")+cPrefixo+cNum+cParcela+cTipo+cFornece+'01'
EndIf	


Return cRet                        
                      
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870EVldNx
Define qual sera o proximo painel a ser exibido de acordo  com o 
painel corrente.  

@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function Lj870EVldNx(nPanel ,oWizard ,cMvPar02,cMvPar03,cMvPar04,cMvPar05,lEstorno,;
							nValFin,nValPed,dDtIni,dDtFim)
Local lRet  :=  .T.   

Default cMvPar02:=""
Default cMvPar03:=""
Default cMvPar04:=""

Default cMvPar05:=""
Default lEstorno:= .F.     

If nPanel == 2             
	lEstorno:= .F.     
	If  !Empty(cMvPar02) .AND. !Empty(cMvPar03) .AND. !Empty(cMvPar04) ;
		.AND. !Empty(cMvPar05)			

        MFH->(DbSetOrder(1))
        If MFH->(DbSeek(xFilial("MFH")+cMvPar02))
			dDtIni  := MFH->MFH_DTINI
			dDtFim  := MFH->MFH_DTFIM		
		Else
			oWizard:nPanel:= 5			
			MsgInfo(STR0037,STR0036) //#"Não exite data inicial e final para o lote informado." ## //"Atenção"
			Return lRet
		EndIf        
		//Valida se o lote e o servico fianceiro estão amarrados.		
		If Lj871DSFnxLot(cMvPar02,cMvPar03)			
			
		    FII->(DbSetOrder(1))//FII_FILIAL+FII_ENTORI+FII_PREFOR+FII_NUMORI+FII_PARCOR+FII_TIPOOR+FII_CFORI+FII_LOJAOR			    
		    If FII->(DbSeek(xFilial("FII")+"SE2"+MFI->MFI_PREFIX+MFI->MFI_TITULO+MFI->MFI_PARCEL+MFI->MFI_TIPO+MFI->MFI_FORNEC+MFI->MFI_LJFORN))		    
	        //Identificou que ja foi feito a rotina de fechamento e solicita para que o usuario faça o estorno.	    	    		    		
	    		lEstorno:= .T.     
	      	EndIf    	   
			
			If !lEstorno
	
				nValPed := 0
				nValFin := 0
				While MFI->(!EOF()) .AND. MFI->MFI_NUMLOT == cMvPar02
					nValPed+= MFI->MFI_VLRITE - MFI->MFI_CUSTO
					nValFin+= MFI->MFI_VLRITE			
					MFI->(DbSkip())
				EndDo
				
			Else	
				If MsgYesNo(STR0038+cMvPar03+" - "+Posicione("MG8",1,xFilial("MG8")+cMvPar03,"MG8_DESCRI")+; //"Confirma o estorno do fechamento do serviço financeiro para Administradora financeira "
							STR0039+DTOC(dDtIni)+STR0040 +DTOC(dDtFim) +STR0030) //#"para o mes " ##" de " 
					MsgRun(STR0041 ,, { || Lj870Est(cMvPar02,@oWizard) })			//"Aguarde, efetuando estorno do Fechamento Serviço financeiro ..."
				Else
					oWizard:nPanel:= 5
				EndIf
			EndIf	
		Else
			lRet:= .F.							
		EndIf	
	Else          
		MsgInfo(STR0042 ,STR0036) //#"Obrigatório informar todos os parâmetros." ## //"Atenção"
		lRet:= .F.		
	EndIf		
		
EndIf


Return lRet                     
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870Est
Efetua o estorno do Lote
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------           
Static Function Lj870Est(cMvPar02,oWizard)

Local aRecnoMfi:= {}  //
Local cTitEf   := '' // Numero do titulo efetivo no financeiro
Local aArray   := {}
Local nIndex   := 0
Local nI       := 1
Local aCabPed  := {}
Local aLinhaPed:= {}
Local aItensPed:= {}
PRIVATE lMsErroAuto := .F.
                             			
 
MFI->(DbSetOrder(3))
If MFI->(DbSeek(xFilial("MFI")+cMvPar02))
   
	SC5->(DbSetOrder(1))
	If SC5->(DbSeek(xFilial("SC5")+MFI->MFI_PEDIDO))	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda o Cabecalho do Pedido³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/
		AAdd(aCabPed,{"C5_FILIAL" ,SC5->C5_FILIAL	,Nil})
		aAdd(aCabPed,{"C5_NUM"    ,SC5->C5_NUM		,Nil}) // Numero do pedido
		aAdd(aCabPed,{"C5_CLIENTE",SC5->C5_CLIENTE	,Nil}) // Codigo do cliente
		aAdd(aCabPed,{"C5_LOJACLI",SC5->C5_LOJACLI	,Nil}) // Loja do cliente
		aAdd(aCabPed,{"C5_TIPO"   ,SC5->C5_TIPO		,Nil}) // Tipo de pedido
		aAdd(aCabPed,{"C5_CONDPAG",SC5->C5_CONDPAG	,Nil}) // Codigo da condicao de pagamanto - SE4
		aAdd(aCabPed,{"C5_EMISSAO",SC5->C5_EMISSAO	,Nil}) // Data de emissao
		aAdd(aCabPed,{"C5_TIPOCLI",SC5->C5_TIPOCLI	,Nil}) // Tipo do Cliente

		SC6->(DbSetOrder(1))
		If SC6->(DbSeek(xFilial("SC6")+MFI->MFI_PEDIDO,.T.))	
			While SC6->(!Eof()) .AND. SC5->C5_NUM == SC6->C6_NUM
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Guarda os Itens do Pedido   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AAdd(aLinhaPed,{"C6_FILIAL" ,SC6->C6_FILIAL  	,Nil})				
				aAdd(aLinhaPed,{"C6_NUM"    ,SC6->C6_NUM		,Nil}) // Numero do Pedido
				aAdd(aLinhaPed,{"C6_ITEM"   ,SC6->C6_ITEM		,Nil}) // Numero do Item no Pedido
				aAdd(aLinhaPed,{"C6_PRODUTO",SC6->C6_PRODUTO	,Nil}) // Codigo do Produto
				aAdd(aLinhaPed,{"C6_QTDVEN" ,SC6->C6_QTDVEN		,Nil}) // Quantidade Vendida
				aAdd(aLinhaPed,{"C6_PRUNIT" ,SC6->C6_PRUNIT		,Nil}) // Preco Unitario 
				aAdd(aLinhaPed,{"C6_PRCVEN" ,SC6->C6_PRCVEN		,Nil}) // Preco Unitario Liquido
				aAdd(aLinhaPed,{"C6_VALOR"  ,SC6->C6_VALOR		,Nil}) // Valor Total do Item
				aAdd(aLinhaPed,{"C6_TES"    ,SC6->C6_TES		,Nil}) // Tipo de Entrada/Saida do Item
				Aadd(aItensPed, aLinhaPed)
				aLinhaPed := {}
				SC6->(DbSkip())
			EndDo
			MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabPed,aItensPed,5)	
			
			If lMsErroAuto
			    MostraErro()
			    Alert(STR0043) //"Estorno não realizado."
			    oWizard:nPanel:= 5
			EndIf
			 				
		EndIf
    EndIf
        
    If !lMsErroAuto
    
		FII->(DbSetOrder(1))//FII_FILIAL+FII_ENTORI+FII_PREFOR+FII_NUMORI+FII_PARCOR+FII_TIPOOR+FII_CFORI+FII_LOJAOR			    
		If FII->(DbSeek(xFilial("FII")+"SE2"+MFI->MFI_PREFIX+MFI->MFI_TITULO+MFI->MFI_PARCEL+MFI->MFI_TIPO+MFI->MFI_FORNEC+MFI->MFI_LJFORN))		    
		              	
			While MFI->(!EOF()) .AND. MFI->MFI_NUMLOT == cMvPar02
			    Aadd(aRecnoMfi,MFI->(Recno()))
				MFI->(DbSkip())    		
			EndDo
		
			DbSelectArea("SE2")  
			DbSetOrder(1)
			If DbSeek(xFilial("SE2")+FII->FII_PREFDE+FII->FII_NUMDES+FII->FII_PARCDE+FII->FII_TIPODE+FII->FII_CFDES+FII->FII_LOJADE) //Exclusão deve ter o registro SE2 posicionado
				                                 
				aArray := { { "E2_PREFIXO" , SE2->E2_PREFIXO , NIL },;
				                { "E2_NUM"     , SE2->E2_NUM     , NIL } }
				 
				MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
				 
				If lMsErroAuto
				    MostraErro()
				    Alert(STR0043) //"Estorno não realizado."
				    oWizard:nPanel:= 5
				Else  
					For nI:= 1 To Len(aRecnoMfi)
						MFI->(DbGoTo(aRecnoMfi[nI]))
						RecLock("MFI",.F.)
						MFI->MFI_PEDIDO:= ''
						MsUnlock()
					Next nI
					MsgInfo(STR0044,STR0036) //#"Estorno realizado com sucesso." ## //"Atenção"
					oWizard:nPanel:= 5	
				Endif  
			Else
				Alert(STR0043)//"Estorno não realizado."
				oWizard:nPanel:= 5		
			EndIf
		EndIf				   	
	EndIf	
EndIf


Return .T.
   
   
   
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870Say
Efetua a escrista na tela de acordo com os parametros acionados 
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------              
Static Function Lj870Say(oSayPar,cSayPar,cSay1,cSay2,cSay3)        

Local cRet  := Alltrim(cSay1)+" "+" "+Alltrim(cSay2)+" "+Alltrim(cSay3)  //strings dos STR

cSayPar:= cRet
oSayPar:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LjMtaHeader
Monta o aHeader para exibir no Wizard
painel corrente.  

@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function LjMtaHeader(cOpc)

Local aHeader:= {}

If cOpc == '1'	

	aHeader := {{ "Filial" , "MFI_FILORI" ,PesqPict("MFI","MFI_FILORI") ,TAMSX3("MFI_FILORI")[1] ,TAMSX3("MFI_FILORI")[2] ,,"AllwaysTrue()","C",, },;//"Filial"
 	            { "Adm.Financ " , "MFI_ADMIN"  ,PesqPict("MFI","MFI_ADMIN" ) ,TAMSX3("MFI_ADMIN" )[1] ,TAMSX3("MFI_ADMIN" )[2] ,,"AllwaysTrue()","C",, },;//
 	            { "Nome Reduz." , "A2_NREDUZ"  ,PesqPict("SA2","A2_NREDUZ" ) ,TAMSX3("A2_NREDUZ" )[1] ,TAMSX3("A2_NREDUZ" )[2] ,,"AllwaysTrue()","C",, },;//"Nome Reduz."
				{ "Prefixo" , "MFI_PREFIX" ,PesqPict("MFI","MFI_PREFIX" ),TAMSX3("MFI_PREFIX" )[1],TAMSX3("MFI_PREFIX" )[2],,"AllwaysTrue()","C",, },;//"Prefixo"
	            { "No.Titulo" , "MFI_TITULO" ,PesqPict("MFI","MFI_TITULO" ),TAMSX3("MFI_TITULO" )[1],TAMSX3("MFI_TITULO" )[2],,"AllwaysTrue()","C",, },;//"No.Titulo"
	            { "Tipo" , "MFI_TIPO"   ,PesqPict("MFI","MFI_TIPO")   ,TAMSX3("MFI_TIPO")[1]   ,TAMSX3("MFI_TIPO")[2]   ,,"AllwaysTrue()","C",, },;//"Tipo"
 	            { "Valor" , "MFI_VLRITE" ,PesqPict("MFI","MFI_VLRITE" ),TAMSX3("MFI_VLRITE" )[1],TAMSX3("MFI_VLRITE" )[2] ,,"AllwaysTrue()","N",, }}//"Valor"
Else  

	aHeader := {{ "Filial" , "C6_FILIAL"  ,PesqPict("SC6","C6_FILIAL")  ,TAMSX3("C6_FILIAL")[1]  ,TAMSX3("C6_FILIAL")[2]  ,,"AllwaysTrue()","C",, },;
 	            { "Num.Pedido" , "C6_NUM"     ,PesqPict("SC6","C6_NUM"    ) ,TAMSX3("C6_NUM"    )[1] ,TAMSX3("C6_NUM"    )[2] ,,"AllwaysTrue()","C",, },;//"Num.Pedido"
	            { "Cod.Produto" , "C6_PRODUTO" ,PesqPict("SC6","C6_PRODUTO" ),TAMSX3("C6_PRODUTO" )[1],TAMSX3("C6_PRODUTO" )[2],,"AllwaysTrue()","C",, },;//"Cod.Produto"
				{ "Descrição" , "B1_DESC"    ,PesqPict("SC6","B1_DESC" )   ,TAMSX3("B1_DESC" )[1]   ,TAMSX3("B1_DESC" )[2]   ,,"AllwaysTrue()","C",, },;//"Descrição"
	            { "Tes" , "C6_TES"     ,PesqPict("SC6","C6_TES" )    ,TAMSX3("C6_TES" )[1]    ,TAMSX3("C6_TES" )[2]    ,,"AllwaysTrue()","C",, },;//"Tes"
				{ "Valor" , "C6_PRCVEN"  ,PesqPict("SC6","C6_PRCVEN" ) ,TAMSX3("C6_PRCVEN" )[1] ,TAMSX3("MFI_PREFIX" )[2],,"AllwaysTrue()","N",, }}//"Valor"

EndIf

Return aHeader
                    
  

//-------------------------------------------------------------------
/*/{Protheus.doc} LjMtaHeader
Valida se o lote e administradora financeira estão devidamente amarrados.  

@author Varejo
@since 28/05/2013
@version P11
/*/
//------------------------------------------------------------------- 
Static Function Lj871DSFnxLot(cMvPar02,cMvPar03)

Local lRet:= .T.
MFI->(DbSetOrder(3))
If MFI->(DbSeek(xFilial("MFI")+cMvPar02))
	MG8->(DbSetOrder(2))
	MG8->(DbSeek(xFilial("MG8")+MFI->MFI_PRODUT))
	
	If MG8->MG8_CODIGO <> cMvPar03	
		MsgInfo(STR0045+MG8->MG8_CODIGO+" - "+Alltrim(MG8->MG8_DESCRI) ,STR0036 )//#"O Serviço Financeiro correto para este lote é " ## //"Atenção" 
		lRet:=.F.
	EndIf     
Else
	MsgInfo(STR0046,STR0036)//#"Lote não preocessado para o Serviço Financeiro." ## // "Atenção"
	lRet:=.F.
EndIf      
Return lRet
 

//-------------------------------------------------------------------
/*/{Protheus.doc} EspacoAt
Pega uma posição (nTam) na string cString, e retorna o    
caractere de espaço anterior.  

@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function EspacoAt(cString, nTam)

Local nRetorno := 0
Local nX       := 0

// Caso a posição (nTam) for maior que o tamanho da string, ou for um valor inválido, retorna 0.
If nTam > Len(cString) .OR. nTam < 1
	nRetorno := 0
	Return nRetorno
EndIf

// Procura pelo caractere de espaço anterior a posição e retorna a posição dele.
nX := nTam
While nX > 1
	If Substr(cString, nX, 1) == " "
		nRetorno := nX
		Return nRetorno
	EndIf
	
	nX--
EndDo

// Caso não encontre nenhum caractere de espaço, é retornado 0.
nRetorno := 0

Return nRetorno



//-------------------------------------------------------------------
/*/{Protheus.doc} EspacoAt
Funcao executada na mudanca da Adm. Financeira

@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function Lj871SFNChg(cMvPar03,oAdmFin,cAdmFin)

Local lRet:= .T.

If ExistCpo("MG8",cMvPar03) 
	cAdmFin:=Posicione("MG8",1,xFilial("MG8")+cMvPar03,"MG8_DESCRI")
	oAdmFin:Refresh()
Else   
	cAdmFin:= ''
	oAdmFin:Refresh()
	lRet:= .F.
EndIf
Return lRet

