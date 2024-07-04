#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA1400.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "HEADERGD.CH"
#INCLUDE 'FWMBROWSE.CH'      
#INCLUDE "FWMVCDEF.CH"
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma    ณ GPEA400 ณAutor  ณNatie          1 Versaoณ Data ณ  01/12/03            ณฑฑ
ฑฑณ            ณ         ณ       ณMauricio T.    2 Versaoณ      ณ  28/06/04            ณฑฑ
ฑฑณ            ณ         ณ       ณNatie          3 Versaoณ      ณ  20/07/07            ณฑฑ 
ฑฑณ            ณ         ณ       ณRaquel Hager   4 Versaoณ      ณ  10/04/13            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao   ณ Rotina de Cadastro do Calendario.                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso         ณ Generico                                                     		   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         	ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                	   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ FNC            ณ  Motivo da Alteracao                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRaquel Hagerณ10/04/13ณM12RH01   RQ2003ณProjeto Unificacao das Folhas de Pagamento.  ณฑฑ
ฑฑณRaquel Hagerณ23/04/13ณM12RH01   RQ2003ณCorrecao na verificacao do compartilhamento  ณฑฑ
ฑฑณ            ณ        ณ                ณentre as tabelas RCJ/RCH. Implementacao da   ณฑฑ
ฑฑณ            ณ        ณ                ณfuncao fCalcDCalc para calculo de dias no    ณฑฑ
ฑฑณ            ณ        ณ                ณcampo RCF_DCALCM.Correcao na captura de ano  ณฑฑ
ฑฑณ            ณ        ณ                ณe mes na funcao fRotPdPeri.Remocao da valid  ณฑฑ
ฑฑณ            ณ        ณ                ณpara dias nao trab. para V.Trans/Ref/Alim.   ณฑฑ
ฑฑณRaquel Hagerณ19/06/13ณM12RH01   RQ2003ณCriacao da funcao fVldRot / Correcao para re ณฑฑ
ฑฑณ            ณ        ณ                ณcalculo de n turnos.						   ณฑฑ 
ฑฑณRaquel Hagerณ24/06/13ณM12RH01   RQ2003ณCalculo automatico para exibicao de feriados.ณฑฑ 
ฑฑณRaquel Hagerณ16/09/13ณM12RH01   RQ2003ณCorrecao nas funcoes VldDtIni/VLdDtFim. Cria ณฑฑ
ฑฑณ            ณ        ณ                ณcao de msg explicativa quanto a exclusao.	   ณฑฑ
ฑฑณRaquel Hagerณ01/04/13ณTPCJHL			 ณCriacao da funcao fChkFolCpl e alteracao na  ณฑฑ
ฑฑณ            ณ        ณ                ณfuncao fVldPersel para tratar Complementar.  ณฑฑ
ฑฑณSidney O.   ณ14/07/14ณTPVFZT			 ณCriacao da funcao fValDtPago para validacao  ณฑฑ
ฑฑณ            ณ        ณ                ณda data de pagamento.                        ณฑฑ 
ฑฑณGustavo M.  ณ04/06/14ณTSMIE6			 ณAjuste no contador de dias nao uteis e uteis ณฑฑ  
ฑฑณFlavio C.   ณ06/07/15ณTSRSJ7			 ณAjuste no valid campo turno 				   ณฑฑ  
ฑฑณAllyson M.  ณ07/08/15ณTSURZN			 ณAjuste p/ nao obrigar cadastro na SPJ 	   ณฑฑ  
ฑฑณRenan Borgesณ19/11/15ณTTRY92			 ณAjuste para montar o menu da rotina de Perio-ณฑฑ  
ฑฑณ            ณ        ณ                ณdos corretamente, sem gerar as op็๕es no menuณฑฑ
ฑฑณ            ณ        ณ                ณdireito da rotina, pois essa rotina possui o ณฑฑ
ฑฑณ            ณ        ณ                ณvinculo entre 2 registros o de processos e o ณฑฑ
ฑฑณ            ณ        ณ                ณde periodos, com isso ้ necessแrio que a aberณฑฑ
ฑฑณ            ณ        ณ                ณtura seja feita pelo Browse.                 ณฑฑ
ฑฑณGustavo M.  ณ04/12/15ณPCDEF-86786	 ณAjuste no posicionamento dos registros 	   ณฑฑ
ฑฑณGsantacruz  ณ09/12/15ณPCDEF2015_2016  ณEn la funcion VLDDTINI se eliminala validacinณฑฑ
ฑฑณ            ณ        ณ-846            ณde Mes de compentencia igual al mes de fecha ณฑฑ
ฑฑณ            ณ        ณ                ณinicial, para que no aplique a Mexico.       ณฑฑ
ฑฑณRaquel Hagerณ11/12/15ณTTZWQZ			 ณRemocao de config Complementar para 132. 	   ณฑฑ
ฑฑณRaquel Hagerณ19/02/16ณTUHJPS          ณAjuste no inicializador padrao quando        ณฑฑ
ฑฑณ            ณ        ณ                ณMV_DIASPER igual a 2 e mes de Fevereiro.     ณฑฑ
ฑฑณRaquel Hagerณ23/02/16ณTUNV61          ณRemocao de tratamento de xFilial para RFQ.   ณฑฑ
ฑฑณRaquel Hagerณ24/02/16ณTUNV61          ณIncluida validacao por linha na Exclusao.    ณฑฑ
ฑฑณRaquel Hagerณ25/02/16ณTUKE03          ณIncluida validacao por linha na Exclusao.    ณฑฑ
ฑฑณRaquel Hagerณ15/03/16ณTUSMIS          ณAjuste na carga da tabela RCG ao trocar de   ณฑฑ
ฑฑณ            ณ        ณ                ณturno padrao para um novo turno. Inclusao de ณฑฑ
ฑฑณ            ณ        ณ                ณtratamento na variavel cFilRFQ.			   ณฑฑ
ฑฑณRenan Borgesณ15/03/16ณTUQZKS          ณAjuste para nใo permitir cadastrar 2 periodosณฑฑ
ฑฑณ            ณ        ณ                ณcom folha ativo.                             ณฑฑ
ฑฑณRaquel Hagerณ16/03/16ณTUSMIS          ณAjuste na validacao da inclusao de ao menos 1ณฑฑ
ฑฑณ            ณ        ณ                ณroteiro de calculo ao confirmar.             ณฑฑ
ฑฑณFlavio C    ณ06/04/16ณTUPANS          ณ Nใo permitir colocar status 5-fechado       ณฑฑ
ฑฑณRaquel Hagerณ12/05/16ณTUWGEI          ณRetirada do uso da fun็ใo SetChgAll e valida-ณฑฑ
ฑฑณ            ณ        ณ                ณref status de periodo aberto na RFQ.         ณฑฑ
ฑฑณRenan Borgesณ20/05/16ณTUZGS1  	     ณAjuste para que em Fevereiro seja proporcio- ณฑฑ
ฑฑณ            ณ        ณ   		  	 ณnalizado pelos dias do periodo quando funcio-ณฑฑ
ฑฑณ            ณ        ณ   		  	 ณnแrio for admitido no mes, demitido possuir  ณฑฑ
ฑฑณ            ณ        ณ   		  	 ณafastamento, ou f้rias.                      ณฑฑ
ฑฑณRaquel Hagerณ30/05/16ณTUVUDP          ณAjuste na fun็ใo fNewsAcols para checar      ณฑฑ
ฑฑณ            ณ        ณ                ณdados da SP3 corretamente.                   ณฑฑ
ฑฑณCํcero Alvesณ04/08/16ณTVSVVW          ณAjuste para verificar o compartilhamento das ณฑฑ
ฑฑณ            ณ        ณ                ณtabelas RCJ, RCF, RCH, RCG e RFQ			   ณฑฑ
ฑฑณFlavio C.   ณ14/09/16ณTWAIL4          ณAlterado o Browse quando  pais nao for Brasilณฑฑ
ฑฑณ            ณ        ณ                ณpara que a tabela principal seja a RCH       ณฑฑ
ฑฑณP.Pompeu    ณ28/09/16ณTVNFD7          ณAjuste p nao validar excl. de regs nao salvosณฑฑ
ฑฑณCํcero Alvesณ18/10/16ณTVXDOL          ณAjuste para permitir incluir perํodos para   ณฑฑ
ฑฑณ            ณ        ณ                ณroteiro complementar dentro do mesmo m๊s do  ณฑฑ
ฑฑณ            ณ        ณ                ณroteiro principal							   ณฑฑ
ฑฑณM.Camargo   ณ22/11/16ณMMI-4222        ณFuncion RCHFIL01() modificada ya que causaba ณฑฑ
ฑฑณ            ณ        ณ                ณerror al buscar en RCH el valor del n๚mero deณฑฑ
ฑฑณ            ณ        ณ                ณpago. Ajustes Localicacion Chile             ณฑฑ
ฑฑณGabriel A.  ณ08/02/17ณMRH-6410        ณAjuste para melhora de performance na op็ใo  ณฑฑ
ฑฑณ            ณ        ณ                ณincluir do cadastro de perํodos.             ณฑฑ
ฑฑณRenan Borgesณ31/03/17ณMRH-9001  	     ณAjuste para que no cadastro de perํodos, as  ณฑฑ
ฑฑณ            ณ        ณ   		  	 ณdatas do calendแrio analํtico sejam demonstraณฑฑ
ฑฑณ            ณ        ณ   		  	 ณdas de forma ordenada.                       ณฑฑ
ฑฑณJ๔natas A.  ณ26/04/17ณDRHPAG-1116     ณApos a substituicao da GhostCol pelo Recno noณฑฑ
ฑฑณ            ณ        ณ   		  	 ณaSort do array aAuxRCF, o array aRCFColsRec  ณฑฑ
ฑฑณ            ณ        ณ   		  	 ณficou com ordenacao incompativel na gravacao,ณฑฑ
ฑฑณ            ณ        ณ   		  	 ณentao retiramos o aSort p/ manter a paridade ณฑฑ
ฑฑณ            ณ        ณ   		  	 ณdos dois arrays.                             ณฑฑ
ฑฑณPaulo O.    ณ18/05/17ณDRHPAG-21  	 ณAjuste para quando verificar se o roteiro    ณฑฑ
ฑฑณInzonha     ณ        ณ   		  	 ณdo periodo editado existe na tabela SRY      ณฑฑ
ฑฑณGabriel A.  ณ29/05/17ณDRHPAG-2097     ณRetirada valida็ใo do compartilhamento da    ณฑฑ
ฑฑณ            ณ        ณ                ณtabela RCJ.                                  ณฑฑ
ฑฑณJ๔natas A.  ณ30/05/17ณDRHPAG-2128     ณInclusใo de compatibilidade de modo de acessoณฑฑ
ฑฑณ            ณ        ณ                ณda tabela RG3xRCJ.                           ณฑฑ
ฑฑณGabriel A.  ณ31/05/17ณDRHPAG-2097     ณ"Rollback" da altera็ใo da valida็ใo de      ณฑฑ
ฑฑณ            ณ        ณ                ณcompartilhamento da tabela RCJ.              ณฑฑ
ฑฑณIsabel N.   ณ20/09/17ณDRHPAG-3224     ณRestringidas as valida็๕es de tipo de roteiroณฑฑ
ฑฑณ            ณ        ณ                ณpor processos ao modelo de folha padrใo.     ณฑฑ
ฑฑณIsabel N.   ณ25/10/17ณDRHPAG-1477     ณAjuste ao validar recแlculo de calendแrio em ณฑฑ
ฑฑณ            ณ        ณ                ณcaso de altera็ใo de sint้tico p/analํtico.  ณฑฑ
ฑฑณ  Marco A.  ณ30/10/17ณ TSSERMI01-228  ณSe localiza campo RCH_COMPL en fVldPerSel,   ณฑฑ
ฑฑณ            ณ        ณ                ณpara paises diferentes de Mexico, ya que     ณฑฑ
ฑฑณ            ณ        ณ                ณse mostraba error array out of  bounds. (MEX)ณฑฑ
ฑฑณOswaldo L   ณ13/11/17ณDRHPAG-812      ณEvitar informar filial distinta do Processo  ณฑฑ
ฑฑณ            ณ        ณ                ณno ato de inserir periodos no sistema.       ณฑฑ
ฑฑณMoskovkina Eณ28/04/18ณDMA3-652		 ณCalculation of Working Days, Non-Working Daysณฑฑ
ฑฑณ			   ณ		ณ				 ณ, Working Hours per week was changed and     ณฑฑ
ฑฑณ			   ณ		ณ				 ณWorking Hours per is filled from connected   ณฑฑ
ฑฑณ			   ณ		ณ				 ณWork Shift		  						   ณฑฑ
ฑฑณWinstonCostaณ02/01/19ณDRHPAG-22991    ณRetirada do trecho que trata o AS/400        ณฑฑ
ฑฑณVer๓nica Floณ23/04/19ณDMINA-6396      ณBifurcaci๓n solo para brasi   en validaci๓n  ณฑฑ
ฑฑณ            ณ        ณ                ณde fecha en la funcion VldDtFim (MEX).       ณฑฑ
ฑฑณAndres S.   ณ09/01/20ณDMINA-7851      ณSe permite registrar periodos consecutivos   ณฑฑ
ฑฑณ            ณ        ณ                ณmodificando las funciones VldDtIni y VldDtFimณฑฑ
ฑฑณ            ณ        ณ                ณ(MEX).  									   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function  GPEA400()

Local aCoors 		:= FWGetDialogSize(oMainWnd)
Local cFTerRCJ		:= ""    
Local cFTerRFQ		:= ""  						
Local oDlg			                                 
Local oFWLayer
Local oPanelUp
Local oPanelDown
Local cFtrModulo	:= If( cModulo $ "GPE*GFP","GPE*GFP",cModulo )

Static lValEnchoice										// Utilizado para o controle da Enchoice
Static lFirstDelOk										// Controle de Delecao de RCF
Static lPerMod2		:=  !( MV_MODFOL == '1' ) .And. SuperGetMv( "MV_PERMOD2" , .F. , .F. ,  )	 // .T. = Usa cadastro de periodos simplificado para folha modelo 2 (valor padrao = .F.)

Private aColsRCHSF		:={}                      		// Vetor aCols sem Filtro
Private aHeaderRCHSF	:={}                                  
Private cCadastro   	:= OemToAnsi(STR0001)			// "Calendario "	
Private lModPadrao 		:= ( MV_MODFOL == '1' )			// Modelo do SIGAGPE   
Private cTpCalend 		:=  SuperGetMv( "MV_TPCALEN" , .F. , "1" ,  )	 // 1 = Usa calendario Analitico , 2 = Usa calendario Sintetico 
Private cQtdeDPer 		:=  SuperGetMv( "MV_DIASPER" , .F. , "1" ,  )	 // 1 = Usa qtde de dias do mes do periodo , 2 = Usa sempre 30 
Private lF3Criter	  	:= .F. 							// Variavel que verifica se a chamada da consulta do criterio foi efetuada a partir do F3	
Private oMBrowseUp
Private oMBrowseDown           
Private aRotina

	//Utilizacao do Cadastro simplificado para paises que utilizam a Folha Modelo 2
	If lPerMod2 .And. FindFunction("GPEA400A") 
		GPEA400A()
		Return( NIL )
	EndIf

	// Limpa variavel n(publica) se existir
    If !( Type( "n" ) == "NIL" )  
    	n := 0
    EndIf 
       
    //Modo de compartilhamento da tabela RCJ            
   	cCpartRCJ := FWModeAccess("RCJ", 1)
   	cCpartRCJ += FWModeAccess("RCJ", 2)
   	cCpartRCJ += FWModeAccess("RCJ", 3)
   	
   	//Modo de compartilhamento da tabela RCH
   	cCpartRCH := FWModeAccess("RCH", 1)
   	cCpartRCH += FWModeAccess("RCH", 2)
   	cCpartRCH += FWModeAccess("RCH", 3)
   	
   	//Modo de compartilhamento da tabela RFQ
   	cCpartRFQ := FWModeAccess("RFQ", 1)
   	cCpartRFQ += FWModeAccess("RFQ", 2)
   	cCpartRFQ += FWModeAccess("RFQ", 3)
   	
   	//Modo de compartilhamento da tabela RCF
   	cCpartRCF := FWModeAccess("RCF", 1)
   	cCpartRCF += FWModeAccess("RCF", 2)
   	cCpartRCF += FWModeAccess("RCF", 3)
   	
   	//Modo de compartilhamento da tabela RCG
   	cCpartRCG := FWModeAccess("RCG", 1)
   	cCpartRCG += FWModeAccess("RCG", 2)
   	cCpartRCG += FWModeAccess("RCG", 3)
   	
   	//Modo de compartilhamento da tabela RG3
   	cCpartRG3 := FWModeAccess("RG3", 1)
   	cCpartRG3 += FWModeAccess("RG3", 2)
   	cCpartRG3 += FWModeAccess("RG3", 3)
   	
   	// Verifica se as tabelas estao com o mesmo modo de compartilhamento 
   	If (cCpartRCJ != cCpartRCH) .OR. (cCpartRCJ != cCpartRFQ) .OR. (cCpartRCJ != cCpartRCF) .OR. (cCpartRCJ != cCpartRCG) .OR. (cCpartRCJ != cCpartRG3)
   		Help( , , 'HELP', , OemToAnsi(STR0143), 1, 0 )  // verifique o compartilhamento entre as tabelas RCJ, RCH, RFQ, RCF e RCG. o compartilhamento dessas tabelas deve ser identico.  		
		Return (.F.)                                          
	EndIf 
   	             
	// Inicializa o filtro utilizando a funcao FilBrowse                      
	cFTerRCJ	:= ChkRh( FunName() , "RCJ" , "1" )
   	cFTerRFQ    := " RFQ->RFQ_MODULO $ '" + cFtrModulo + "'" 
		
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL
	
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlg,.F.,.T.)
		
		//-- Browse RCJ
		oFWLayer:AddLine("UP",35,.F.) 
		oFWLayer:AddCollumn("ALLRCJ", 100, .T., 'UP' )     
		oPanelUp := oFWLayer:GetColPanel("ALLRCJ", 'UP' )
				
		oMBrowseUp := FWMBrowse():New() 
		oMBrowseUp:SetOwner( oPanelUp )  
		oMBrowseUp:SetDescription(STR0105)	// "Cadastro de Processos"  
		oMBrowseUp:SetAlias('RCJ')
	   	oMBrowseUp:SetMenuDef( '' )  
	  	oMBrowseUp:SetCacheView (.F.) 
		oMBrowseUp:SetProfileID( '1' ) 
		oMBrowseUp:SetFilterDefault(cFTerRCJ)
		oMBrowseUp:DisableDetails()    		 		
		oMBrowseUp:Activate()		
		
		If cPaisLoc $ "BRA|RUS" 	
			//-- Browse RFQ   
			oFWLayer:AddLine("DOWN", 65, .F. ) 
			oFWLayer:AddCollumn("ALLRFQ", 100, .T., 'DOWN' )
			oPanelDown := oFWLayer:GetColPanel("ALLRFQ", 'DOWN')
					
			oMBrowseDown := FWMBrowse():New() 
			oMBrowseDown:SetOwner( oPanelDown )
			oMBrowseDown:SetDescription(STR0123)  // "Cadastro de Periodos"  		  
		   	oMBrowseDown:SetMenuDef( 'GPEA400' ) 
			oMBrowseDown:DisableDetails()
			oMBrowseDown:SetAlias('RFQ')                     
		   	oMBrowseDown:SetCacheView (.F.)   
			oMBrowseDown:SetProfileID( '2' ) 			 		  
			oMBrowseDown:ForceQuitButton()   
			oMBrowseDown:AddLegend( "RFQ_STATUS == '1' .Or. RFQ_STATUS == ' ' ","GREEN",	OemToAnsi(STR0127) ) // "Periodo Aberto" 
			oMBrowseDown:AddLegend( "RFQ_STATUS == '2'",	"RED"	,	OemToAnsi(STR0128) ) // "Periodo Fechado" 
			oMBrowseDown:Activate()    
			oRelation := FWBrwRelation():New()
	
			oRelation:AddRelation(oMBrowseUp,oMBrowseDown, {{"RFQ_FILIAL", "RCJ_FILIAL"}, {"RFQ_PROCES", "RCJ_CODIGO"}})
		Else
		//-- Browse RCH 
			oFWLayer:AddLine("DOWN", 65, .F. ) 
			oFWLayer:AddCollumn("ALLRFQ", 100, .T., 'DOWN' )
			oPanelDown := oFWLayer:GetColPanel("ALLRFQ", 'DOWN')
					
			oMBrowseDown := FWMBrowse():New() 
			oMBrowseDown:SetOwner( oPanelDown )
			oMBrowseDown:SetDescription(STR0123)  // "Cadastro de Periodos"  		  
		   	oMBrowseDown:SetMenuDef( 'GPEA400' ) 
			oMBrowseDown:DisableDetails()  
			oMBrowseDown:SetAlias('RCH')                     
		   	oMBrowseDown:SetCacheView (.F.)   
			oMBrowseDown:SetProfileID( '2' ) 			 		  
			oMBrowseDown:ForceQuitButton()   
		
			oMBrowseDown:Activate()    
								
			oRelation := FWBrwRelation():New()
	
			oRelation:AddRelation(oMBrowseUp,oMBrowseDown, {{"RCH_FILIAL", "RCJ_FILIAL"}, {"RCH_PROCES", "RCJ_CODIGO"}})
			cFTerRFQ    := " RCH->RCH_MODULO $ '" + cFtrModulo + "'" 
	
		EndIf
		oRelation:Activate() 
				
		oMBrowseDown:AddFilter(STR0114,cFTerRFQ,.T.,.T.) /// "Filtro por Modulo"
		oMBrowseDown:ExecuteFilter()	
		
	ACTIVATE MSDIALOG oDlg

	lValEnchoice	:= Nil
	lFirstDelOk		:= Nil  
	 
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออออออัออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณ GPA400Manu  ณAutor  ณ Natie Sugahara 1a V ณ Data ณ  01/12/03  บฑฑ 
ฑฑบ          ณ             ณ       ณ Mauricio T.    2a V ณ      ณ  28/06/04  บฑฑ   
ฑฑบ          ณ             ณ       ณ Raquel Hager   3a V ณ      ณ  28/06/04  บฑฑ
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออออออฯออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Manutencao da Rotina de Cadastro de Periodos.                 บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ GPA400Manu( cAlias , nReg , nOpcX )			                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cAlias = Alias do arquivo 					                 บฑฑ
ฑฑบ          ณ nReg   = Numero do registro                                   บฑฑ
ฑฑบ          ณ nOpc   = Numero da opcao selecionada                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Opcoes 2 e 4 MenuDef.                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function GPA400MANU( cAlias , nReg , nOpc )
	// Variaveis de controle
	Local aSavePos			:= GetArea()
	Local nOpcAlt			:= 0.00		// Variavel de controle das alteracoes - utilizada para a gravacao
	Local nX				:= 0.00		// Variavel utilizada em loops
	Local nUsado 			:= 0
	Local nPosRec			:= 0
	Local lFolderOk			:= .T.
	// Variaveis para enchoice da tabela RFQ
	Local bSkip
	Local aRFQFields		:= {}		// Vetor com os campos da tabela
	Local aRFQAltera		:= {}		// Vetor com os campos que permitem alteracao
	Local aRFQNaoAltera		:= {}		// Vetor com os campos que nao permitem alteracao
	Local aRFQVirtChoice	:= {}		// Vetor com os campos virtuais
	Local aRFQVisualChoice 	:= {}		// Vetor com os campos visuais
	Local aRFQNotFields		:= {}		// Vetor com os campos que nao serao visualizados
	Local aColsEnChoice 	:= {}		// Vetor com as colunas da Enchoice RCH
	Local aSvEnchoice		:= {}		// Vetor com a copia de aColsEnchoice para verificar se houve alteracoes
	Local nRFQXs			:= 0.00		// Variavel com a quantidade de campos da tabela
	Local nPosStatus		:= 0
	// Variaveis para getdados da tabela RCH
	Local nOpcNewGd			:= 0
	Local aRCHAltera		:= {}		// Vetor com os campos que permitem alteracao
	Local aRCHNotFields		:= {}		// Vetor com os campos que nao serao visualizados
	Local aColsRCHRec		:= {}		// Vetor contendo os recnos dos registros
	Local bRCHDelOk			:= { || Gp400RCHDelOk() }
	// Variavel para getdados da tabela RCF
	Local aRCFNotFields		:= {}		// Vetor com os campos que nao seria visualizados
	Local aRCFAltera		:= {}		// Vetor com os campos que permitem alteracao
	Local aRCFNaoAltera		:= {}		// Vetor com os campos que nao permitem alteracao
	Local aRCFVirtGd		:= {}		// Vetor com os campos virtuais
	Local aRCFCcpoKey		:= {}		// Vetor com os campos chaves de RCF
	Local bRCFDelOk			:= { || Gp400DelOk() }
	Local nRCFUsado			:= 0.00 	// Variavel que retorna a quantidade de campos da tabela
	Local aRCFVisualGD		:= {} 		// Vetor com os campos visuais
	Local aRCFSvCols		:= {}		// Vetor com a copia da aRCFCols para verificar se houve alteracoes
	// Variavel para getdados da tabela RCG
	Local aRCGVirtGd		:= {}  		// Vetor com os campos virtuais
	Local aRCGVisualGd		:= {} 		// Vetor com os campos visuais
	Local aRCGNotAlter		:= {}		// Campos nao alteraveis
	Local aRCGAltera		:= {}		// Campos que permitem alteracao
	Local aRCGNotFields		:= {}		// Vetor com os campos que nao serao visualizados
	Local nRCGUsado			:= 0.00   	// Variavel que retorna a quantidade de campos da tabela
	// Variaveis da janela
	Local bSet15			:= { || Nil }	// Bloco com as validacoes do botao OK
	Local bSet24			:= { || Nil }	// Bloco com as validacoes do botao Cancelar
	Local bDialogInit		:= { || Nil }	// Inicializacao do Dialog
	// Variaveis do tipo objetos
	Local oDlg				:= Nil
	Local oFont
	Local oGroup
	// Variaveis para controle de coordenadas da janela
	Local aAdvSize			:= {}
	Local aInfoAdvSize		:= {}
	Local aObjSize			:= {}
	Local aObjCoords		:= {}
	Local aAdv1Size			:= {}
	Local aInfo1AdvSize		:= {}
	Local aObj1Size			:= {}
	Local aObj1Coords		:= {}
	Local aAdv2Size			:= {}
	Local aInfo2AdvSize		:= {}
	Local aObj2Size			:= {}
	Local aObj2Coords		:= {}
	Local aFolders			:= Array (02)
	Local aPages			:= Array (02)
	Local aObjFolder		:= Array (02)
	Local aButtons			:= {}
	Local nPosicao := 0
	// Variaveis privadas da Enchoice da tabela RFQ
	Private cFilRFQ			:= ''			// Filial corrente
	Private aEnchoice		:= {}			// Vetor com o cabecalho da Enchoice RFQ (utilizada por chamadas da tabela SX3)
	Private aRFQDados		:= {}			// Vetor com campos chaves de RFQ - Controle para verificar Validacao (EnchoTudOK)
	// Variaveis privadas da Enchoice da tabela RCH
	Private nOpcx1			:= nOpc
	Private dRFQDtIni		:= CtoD("//")	// Data Inicial - flag para controle de alteracao pelo usuario para alimentar a RCG
	Private dRFQDtFim		:= CtoD("//")	// Data Final - flag para controle de alteracao pelo usuario para alimentar a RCG
	// Variaveis privadas da GetDados da tabela RCF
	Private aRCFHeader		:= {}			// Vetor com o cabecalho da GetDados
	Private aRCFCols		:= {}			// Vetor com as colunas da GetDados
	Private aRCFColsRec		:= {}			// Vetor que contem os Recnos da tabela
	Private aSvColsRCH		:= {}			// Vetor auxiliar da GetDados
	Private cGp400VldT		:= ""			// Variavel auxiliar para troca de turno
	// Variaveis privadas da Getdados da tabela RCG
	Private aColsRCGDef		:= {}			// Vetor default para calculo do calendario sintetico
	Private aRCGCols		:= {}			// Vetor contendo os campos
	Private aRCGHeader		:= {}			// Vetor contendo o cabecalho
	Private aRCGColsAll		:= {}			// Matriz com os registros e campos da tabela RCG
	Private aRCGAllHeader	:= {}			// Vetor contendo o cabecalho - todos
	Private aRCGColsRec		:= {}			// Vetor contendo os recnos dos registros
	Private aRCGSvCols		:= {}			// Vetor com a copia da aRCGColsAll para verificar se houve alteracoes
	// Variaveis auxiliares
	Private aHeaderRCH		:= {}
	Private aColsRCH		:= {}
	Private bChange     	:= {|| Nil}
	Private bExeCalc		:= {|| Nil}
	Private cKeySeek		:= ""			// Chave para o Posicionamento no Alias Filho
	Private cQuery			:= ""			// Utilizacao de Query para Selecao de Dados
	Private cProcesso		:= ""
	Private cAno			:= ""
	Private cMes			:= ""
	Private cPeriodo   		:= ""
	Private cNumPag			:= ""
	Private cKeyRCG			:= ""			// Chave para manipulacao do array aRCGColsAll na funcao Gpea400AllTrf
	Private dRFQAno			:= ""			// Variaveis de controle para auxilio na funcao fCodPer()
	Private dRFQMes			:= ""
	Private lTemPadrao		:= .F.			// Indica se tem  padrao de calendario no Roteiros por processo
	Private lParamChRec		:= .F.			// Indica se confirma recalculo de RCH gravado enquanto tipo de calend. sintetico
	Private lGp490 			:= AllTrim(Upper(FunName())) == "GPEA490" // Indica acesso pela rotina GPEA490 (Ger.Per.Padrao)
	Private oEnchoice		:= Nil			// Enchoice
	Private oGetDados		:= Nil			// GetDados da Tabela RCF
	Private oGetDadosRCG	:= Nil			// GetDados da Tabela RCG
	Private oGetRCH			:= Nil
	Private lRecalc			:= .T.			// Confirma se deve realizar o recแlculo indicado por lParamChRec ou se jแ foi feito 
	
	Begin Sequence
		
		lValEnchoice := .F. // Variavel static utilizada para controle da validacao da enchoice (gotfocus e lostfocus da getdados)
		
		If cPaisLoc != "BRA"
			cKeySeek := ( RCH->( RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+DTOS(RCH_DTINI)+DTOS(RCH_DTFIM)+RCH_MODULO ) )
			dbSelectArea("RFQ")
			dbSetOrder(1)
			RFQ->(dbSeek(cKeySeek))
		EndIf
		
		dbSelectArea("RFQ")
		dbSetOrder(1)
		If !(nOpc == 3) // Inclusao
			If Empty(RFQ->RFQ_PROCES) .Or. !(RFQ->RFQ_PROCES == RCJ->RCJ_CODIGO)
				RFQ->(dbSeek(RCJ->RCJ_FILIAL + RCJ->RCJ_CODIGO))
				Return
			EndIf
			cKeySeek := ( RFQ->( RFQ_FILIAL+RFQ_PROCES+RFQ_PERIOD+RFQ_NUMPAG+DTOS(RFQ_DTINI)+DTOS(RFQ_DTFIM)+RFQ_MODULO ) )
		Else
			//Altera็ใo para a FillGetDados nใo passar por todos os registros da RFQ quando for inclusใo
			cKeySeek := Replicate("*", 12)
		EndIf
		
		// Enchoice e montada com a tabela RFQ
		// Dessa forma e necessrio o posicionamento na tabela
		dbSelectArea("RFQ")
		dbSetOrder(1)
		RFQ->(dbSeek(cKeySeek))
		dbSelectArea("RCH")
		if (RFQ->RFQ_STATUS != '2' .Or. !(cvaltochar(nOpc) $ '5/4' )) .Or. (cPaisLoc == "MEX" .And. (RFQ->RFQ_STATUS != '2' .Or. !(cvaltochar(nOpc) $ '5' )))
			aColsEnChoice	:= RFQ->(GdMontaCols(	@aEnchoice	   		,;	//01 -> Array com os Campos do Cabecalho da GetDados
				@nRFQXs				,;	//02 -> Numero de Campos em Uso
				@aRFQVirtChoice		,;	//03 -> [@]Array com os Campos Virtuais
				@aRFQVisualChoice	,;	//04 -> [@]Array com os Campos Visuais
				"RFQ"				,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
				aRFQNotFields		,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
				,,cKeySeek,,     	,;  //09 -> Chave para o Posicionamento no Alias Filho
			,,,,,,,,,,,,,,,,,,,,nOpc,; //32 -> nOpc
			))
			aSvEnchoice		:= aClone( aColsEnchoice )
			// Tratamento para os periodos vindos por importacao
			nPosStatus	:= aScan(aEnChoice,{|x| x[2] = "RFQ_STATUS" })
			If nPosStatus > 0
				If Empty(aColsEnChoice[1][nPosStatus])
					aColsEnChoice[1][nPosStatus] := "1"
				EndIf
			EndIf
			// Cria as Variaveis de Memoria e Carrega os Dados Conforme o Arquivo
			cFilRFQ := xFilial("RFQ", RCJ->RCJ_FILIAL)
			For nX := 1 To nRFQXs
				aAdd( aRFQFields , aEnchoice[ nX , 02 ] )
				Private &( "M->"+aEnchoice[ nX , 02 ] ) := aColsEnchoice[ 01 , nX ]
			Next nX
			aAdd(aRFQDados, aClone(aColsEnChoice[1]))
			
			If ( ( nOpc == 3 ) .Or. ( nOpc == 4 ) )
				// Campos que nao poderao ser alterados
				nRFQXs := Len( aRFQVisualChoice )
				For nX := 1 To nRFQXs
					aAdd( aRFQNaoAltera , aRFQVisualChoice[ nX ] )
				Next nX
				// Campos editaveis na alteracao
				nRFQXs := Len( aRFQFields )
				For nX := 1 To nRFQXs
					If ( aScan( aRFQNaoAltera , { |cNaoA| cNaoA == aRFQFields[ nX ] } ) == 0.00 )
						aAdd( aRFQAltera , aRFQFields[ nX ] )
					EndIf
				Next nX
			EndIf
			// Define o Bloco para a Inicializacao do Dialog
			bDialogInit		:= { ||;
				CursorWait()							,;
				EnchoiceBar( oDlg , bSet15 , bSet24 , Nil ,aButtons)	,;
				RstEnchoVlds()							,;
				CursorArrow()							 ;
			}
			
			aAdvSize		:= MsAdvSize()
			aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 3 , 3}
			aAdd( aObjCoords , { 000 , 000 , .T. , .T., .T.  } )
			aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
			
			aAdvSize		:= MsAdvSize(.F.)
			aAdvSize[4]		-=	43 // Altura
			aAdvSize[3]		-=	4 // Largura
			
			aInfo1AdvSize	:= { aAdvSize[1] , 1 , aAdvSize[3] , aAdvSize[4] , 3 , 3}
			aAdd( aObj1Coords , { 000 , 080 , .T. , .F. } )
			aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
			aObj1Size 		:= MsObjSize( aInfo1AdvSize , aObj1Coords )
			
			aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
			aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
			aObj2Size 		:= MsObjSize( aInfo1AdvSize , aObj2Coords )
			
			
			// Define o Conteudo do aFolders
			aFolders[01] 		:= "&"+STR0107	// "Cadastro de Periodos"
			aFolders[02] 		:= "&"+STR0108	// "Cadastro de Calendario"
			
			// Define o Conteudo do aPages
			aPages[01]   		:= "&"+STR0107	// "Cadastro de Periodos"
			aPages[02]			:= "&"+STR0108	// "Cadastro de Calendario"
			
			// Monta as Dimensoes dos Objetos  - Aba 2
			cProcesso	:= If( nOpc == 3, RCJ->RCJ_CODIGO, RFQ->RFQ_PROCES)
			cAno        := If( nOpc == 3, "", RFQ->RFQ_ANO)
			cMes		:= If( nOpc == 3, "", RFQ->RFQ_MES)
			cPeriodo	:= If( nOpc == 3, "", RFQ->RFQ_PERIOD)
			cNumPag 	:= If( nOpc == 3, "", RFQ->RFQ_NUMPAG)
			dRFQDtIni	:= If( nOpc == 3, CtoD("//"), RFQ->RfQ_DTINI)
			dRFQDtFim	:= If( nOpc == 3, CtoD("//"), RFQ->RFQ_DTFIM)
			// Montagem esta fora da definicao da dialog para correta
			// atribuicao do nOpc nos objetos GetDados mesmo quando lParamChRec
			
			Gpea400AmbPrep(	nOpc,;		// Opcao selecionada pelo usuario
				@aRCFNotFields,;		// Campos que nao serao apresentados RCF
				@aRCFVirtGd,;			// Vetor com os campos virtuais
				@aRCFVisualGD,;			// Vetor com os campos visuais
				@aRCFSvCols,; 			// Vetor com a copia da aRCFCols para verificar se houve alteracoes
				@nRCFUsado,;			// Numero de campos usados RCF
				aRCGSvCols,;			// Clone da Cols do RCG
				aRCGVirtGd,;			// Campos Virtuais
				aRCGVisualGd,;			// Campos visuais
				@aRCGNotFields,;		// Campos que nao serao apresentados
				aRCGColsRec,;			// Recnos dos registros
				aRCGNotAlter,;			// Campos nao alteraveis
				aRCGAltera;				// Campos alteraveis
			)
			aRCFCcpoKey := { "RCF_TNOTRA" }
			// Cria as variaveis de memoria e carrega os dados conforme o arquivo
			For nX := 1 To Len( aRCFHeader )
				Private &( "M->"+aRCFHeader[ nX , 02 ] ) := aRCFCols[ 01 , nX ]
			Next nX
			// Usuario possui registros gravados quando cTpCalen = 2 (Sintetico)
			// e agora quer usar o analitico = exibir msg de aviso e opcao de recalculo
			// para geracao de Turno/Itens Padrao ("@@@")
			If nOpc == 4 .And. lParamChRec
				If !MsgYesNo( OemToAnsi( STR0113 ) , OemToAnsi( STR0021 ) ) //"Aviso"###"O parametro MV_TPCALEN esta configurado como tipo Analitico."
					nOpc := 2 // Altera opcao para visualizacao              // "Os registros a seguir foram gravados enquanto tipo Sintetico. Calendario sera recalculado, confirma?.
					lParamChRec := .F.
					MsgAlert( OemToAnsi( STR0115 ) , OemToAnsi( STR0021 ) ) //"Aviso"###"Os registros a seguir nao poderao ser editados."
				EndIf
			EndIf
			// Opcao disponivel na oGetRCH
			nOpcNewGd := If( nOpc == 2 .Or. nOpc == 5 , 0 , GD_INSERT + GD_UPDATE + GD_DELETE )
			// Monta o Dialogo Principal
			DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
			DEFINE MSDIALOG oDlg TITLE OemToAnsi( cCadastro ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL
			// Carrega o Objeto Folder
			oFolders := TFolder():New(	aObjSize[ 1 , 1 ]		,;
				aObjSize[ 1 , 2 ]		,;
				aFolders				,;
				aPages					,;
				oDlg					,;
				Nil						,;
				Nil						,;
				Nil						,;
				.T.						,;
				.F.						,;
				aObjSize[ 1 , 3 ]		,;
				aObjSize[ 1 , 4 ]		 ;
			)
			oFolders:bSetOption:= { || If( !(nOpc == 2), If( ValidEnch(oEnchoice,nOpc), lFolderOk := .T., lFolderOk := .F.), .T.) }
			oFolders:bChange:= { || If( !(nOpc == 2), If( !lFolderOk, (oFolders:nOption := 1, lFolderOk := .T. ), .T.), .T.) }
			// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			// ณ ABA 1 - CADASTRO DE PERIODOS/ROTEIROS ณ
			// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oEnchoice	:= MsmGet():New( 	"RFQ",;   			// 1  Tabela a consultar
				Nil,;				// 2  Nro do Recno do Registro
				nOpc,;				// 3  Tipo de operacao
				Nil,;				// 4
				Nil,;				// 5
				Nil,; 				// 6
				aRFQFields,;		// 7  Vetor com nome dos campos que serao exibidos
				aObj1Size[1],; 		// 8  Posicao da Enchoice na tela
				aRFQAltera,;		// 9  Campos que permitem alteracao
				Nil,;				// 10
				Nil,;				// 11
				Nil,;				// 12 Funcao para validacao da Enchoice
				Nil,;  				// 13  Objeto
				oFolders:aDialogs[01],;
				.F.						,;
				Nil						,;
				.F.			 			,,,,,oFolders:aDialogs[1],,.F.,, ;
			)
			// Carrega a GetDados
			GP400MontaCols(nOpc,cAlias, cProcesso, cPeriodo ,cNumPag, @aRCHAltera, @aHeaderRCH, @aColsRCH , nOpc, @aColsRCHRec, @aRCHNotFields ,@nUsado, nPosRec , nReg, .F.)
			aSvColsRCH	:= aClone(aColsRCH)
			// Cria as variaveis de memoria e carrega os dados conforme o arquivo
			For nX := 1 To Len( aHeaderRCH )
				Private &( "M->"+aHeaderRCH[ nX , 02 ] ) := aColsRCH[ 01 , nX ]
			Next nX
			oGetRCH := MsNewGetDados():New( aObj1Size[2,1]			,;	// 1 nTop
				aObj1Size[2,2]			,;	// 2 nLelft
				aObj1Size[2,3]			,;	// 3 nBottom
				aObj1Size[2,4]			,;	// 4 nRright
				nOpcNewGd				,;	// 5 Controle do que podera ser realizado na GetDado - nstyle
				"GP400LinOk"			,;	// 6 Funcao para validar a edicao da linha - ulinhaOK
				"GP400TudoOk"			,;	// 7 Funcao para validar todas os registros da GetDados - uTudoOK
				Nil						,;	// 8 cIniCPOS
				aRCHAltera				,;	// 9 aAlter
				0						,;	// 10 nfreeze
				99999					,;	// 11 nMax
				Nil						,;	// 12 cFieldOK
				Nil						,;	// 13 usuperdel
				bRCHDelOk				,;	// 14 udelOK
				@oFolders:aDialogs[01]	,;	// 15 Objeto de dialogo - oWnd
				@aHeaderRCH				,;	// 16 Vetor com Colunas - AparHeader
				@aColsRCH 	    		,;	// 17 Vetor com Header - AparCols
				Nil            			,;	// 18
				"2")						// 19 Tela

			nPosRec			:= GdfieldPos("RCH_REC_WT",oGetRCH:aHeader)
			// Na entrada da GetDados (RCH) validar a enchoice e calcular o calendario
			oGetRCH:oBrowse:bGotFocus := { || 	If(!(nOpc == 2), ValidEnch(oEnchoice, nOpc),.T.),;
				oGetRCH:Goto( 1 ),;
				oGetRCH:Refresh() }
			
			// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			// ณ ABA 2 - CADASTRO DE TURNOS E CALENDARIO ณ
			// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

			If ( cPaisLoc == "RUS" )
				aRCFAltera := {"RCF_TNOTRA"}
			EndIf

			oGetDados	:= MsNewGetDados():New(aObj2Size[1,1],;  		// nTop
				aObj2Size[1,2],;		// nLelft
				aObj2Size[1,3],;		// nBottom
				aObj2Size[1,4],;		// nRright
				If(nOpc==2.Or.nOpc==5,0, GD_INSERT+GD_UPDATE+GD_DELETE	),; // Controle do que podera ser realizado na GetDado - nstyle
				"Gp400RCFLOk",;			// Funcao para validar a edicao da linha - ulinhaOK
				"Gp400RCFTOk",;			// Funcao para validar todos os registros da GetDados - uTudoOK
				Nil,;					// cIniCPOS
				iif(cPaisLoc == "RUS",aRCFAltera,),;			// aAlter
				0,;						// nfreeze
				99999,;					// nMax
				Nil,;					// cFieldOK
				Nil,;					// usuperdel
				bRCFDelOk,;				// Bloco com funcao para validar registros deletados (Gp400DelOk())
				oFolders:aDialogs[02],;	// Objeto de dialogo - oWnd
				aRCFHeader,;			// Vetor com Header - AparHeader
				aRCFCols;				// Vetor com Colunas - AparCols
			)
			If cTpCalend == "1"	  // Somente para Calendario Analitico
				// Evento bChange - Efetuara a troca dos registros da tabela RCG para os turnos selecionados em RCF
				oGetDados:bChange := { || ;
					Gpea400AllTrf(	"RCG" 	,;	// Alias do Arquivo
						oGetDados		    ,;	// Objeto GetDados para o RCF
						@oGetDadosRCG:aCols	,;	// aCols utilizado na GetDados
						aRCGHeader			,;	// Cabecalho
						.F.			    	,;	// Se carrega elemento de Deletado na remontagem do aCols
						.F.			    	,;	// Se transfere do aCols para o aColsAll
						.T.					;	// Se transfere do aColsAll para o aCols
					),;
					oGetDadosRCG:Goto( 1 ),;
					oGetDadosRCG:Refresh();
				}
				oGetDadosRCG := MsNewGetDados():New( aObj2Size[2,1],;		 // nTop
					aObj2Size[2,2],;		 // nLelft
					aObj2Size[2,3],;		 // nBottom
					aObj2Size[2,4],;		 // nRright
					If(nOpc==2.Or.nOpc==5,0, GD_UPDATE ),; // Controle do que podera ser realizado na GetDado - nstyle
					Nil,;					 // Funcao para validar a edicao da linha - ulinhaOK
					Nil,;					 // Funcao para validar todas os registros da GetDados - uTudoOK
					Nil,;					 // cIniCPOS
					Nil,;					 // aAlter
					0,;					 // nfreeze
					99999,;				 // nMax
					Nil,;					 // cFieldOK
					Nil,;					 // usuperdel
					Nil,;					 // udelOK
					oFolders:aDialogs[02],;// Objeto de dialogo - oWnd
					aRCGHeader,;			// Vetor com Header -  AparHeader
					GdRmkaCols(aRCGHeader,.F.); // Vetor com Colunas - AparCols
				)
			Else // Calendario Sintetico
				// Cria tratamento interno para calculo do calendario
				// Monta componentes RCG
				aRCGHeader := GdMontaHeader( 	nRCGUsado 		,;	//01 -> Por Referencia contera o numero de campos em Uso
					aRCGVirtGd		,;	//02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
					aRCGVisualGd	,;	//03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
					"RCG"			,;	//04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
					aRCGNotFields	,;	//05 -> Opcional, Campos que nao Deverao constar no aHeader
					Nil				,;	//06 -> Opcional, Carregar Todos os Campos
					Nil    			,;	//07 -> Nao Carrega os Campos Virtuais
					.T.				,;	//08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
					Nil				,;	//09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
					Nil				,;	//10 -> Verifica se Deve Checar se o campo eh usado
					Nil				,;	//11 -> Verifica se Deve Checar o nivel do usuario
					.F.				,;	//12 -> Utiliza Numeracao na GhostCol
					Nil				,;	//13 -> Carrega os Campos de Usuario
					Nil				 ;  //14 -> Verificar o campo X3_TELA para montagem do Header
				)
			EndIf

				// Botao para recalculo do calendario
			bExeCalc := { || CalcCalendar(	oGetDadosRCG   		,;	// Objeto que esta realizando a chamada
					aRCGNotFields	,;	// Campos nao visuais - RCG
					aRCFCcpoKey		,;	// Campos Chaves de RCF
					@nRCGUsado		,;	// Numero de campos usados - RCG
					nOpc			 ;	// Opcao do Menu
				),;						// Calcular os dias
				If(cTpCalend == "1", oGetDadosRCG:Goto( 1 ),),; // Somente para Calendario Analitico
				If(cTpCalend == "1", oGetDadosRCG:Refresh(),);	// Somente para Calendario Analitico
			}

			bSet15	:= { ||If( !(nOpc == 2), If( 	ValidSet15(nOpc			,;	// Opcao do menu
					aRCGNotFields,;	// Campo nao visiveis de RCG
					aRCFCcpoKey	,;	// Campos chaves
					@nRCGUsado	 ;	// Quantidade de campos editaveis
					),;
				( nOpcAlt := 1.00 , oDlg:End() ),;
				( nOpcAlt := 0.00 , .F. )),;
				( nOpcAlt := 1.00 , oDlg:End()))}
			bSet24	:= { ||oDlg:End() }

			// Usuario possui registros gravados quando cTpCalend = 2 (Sintetico)
			// e agora quer usar o analitico = exibir msg de aviso e opcao de recalculo
			// para geracao de Turno/Itens Padrao ("@@@").
			// Recalcula registros cadastrados enquanto tipo sintetico
			If lParamChRec
				EVal(bExeCalc)
				lRecalc := .F.
			EndIf
			// Exibir msg informando exclusao de roteiro especifico
			// atraves da opcao de 'Alteracao' - apenas quando nOpc = 5
			If (nOpc == 5)
				MsgInfo( OemToAnsi(STR0118) + CRLF + OemToAnsi(STR0119), OemToAnsi(STR0083) )
				// "Essa operacao ira excluir todos os roteiros exibidos a seguir!"
				// "Para excluir apenas 1 roteiro acesse a opcao 'Alterar', posicione sobre o roteiro em questao, pressione a tecla 'Delete' e confirme."
			EndIf

			ACTIVATE MSDIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED

			// Confirmada a Opcao e Nao for Visualizacao Grava
			If nOpcAlt == 1 .And. nOpc != 2
			// Gravando/Incluido ou Excluindo Informacoes do RFQ/RCH/RCF/RCG
				GPA400Grava( 	cAlias,;			// 1-Alias pai - RFQ
								nOpc,;				// 2-Opcao da operacao
								nReg,;				// 3-Registro pai - RFQ
								aColsEnchoice,;		// 4-Cols da Enchoice - RFQ
								aSvEnchoice	,;		// 5-Clone de aEnchoice - RFQ
								aRFQVirtChoice,; 	// 6-Campos virtuais da enchoice - RFQ
								aRCFSvCols,;		// 7-Clone de aRCFCols - RCF
								nRCFUsado,;			// 8-Qtde de Campos usados - RCF
								aSvColsRCH,;		// 9-Clone de ARCHCols
								aColsRCHRec,;		// 10-Vetor com Recnos de RCH
								nPosRec	    ,;      // 11- Pos. Recno
								aRCGSvCols;			// 12- Clone de aRCGColsAll
							)

			EndIf

		Else
			Help( ,, 'HELP',, "Periodo fechado, permitido apenas visualiza็ใo", 1, 0 )  //'Periodo fechado, permitido apenas visualiza็ใo'
		EndIf
		RestArea( aSavePos )
		nPosicao := oMBrowseDown:nAt
		oMBrowseDown:Refresh(.T.)
		oMBrowseDown:Goto( nPosicao )
	End Sequence

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ GPA400Grava ณ Autor ณNatie Sugahara 1a V ณ Data ณ  18/06/2002 บฑฑ 
ฑฑบ          ณ             ณ       ณMauricio T.    2a V ณ      ณ  28/06/2004 บฑฑ 
ฑฑบ          ณ             ณ       ณNatie Sugahara 3a V ณ      ณ  01/09/2007 บฑฑ 
ฑฑบ          ณ             ณ       ณRaquel Hager   4a V ณ      ณ  10/04/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gravacao da Rotina de Cadastro de Periodos.                   บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GPA400Grava(	cAlias,;			// Alias do arquivo principal - RFQ
								nOpc,;				// Opcao de Acordo com aRotina
							 	nReg,;				// Numero do Registro do Arquivo Pai ( RFQ )
							 	aColsEnChoice,;		// Cols da Enchoice - RFQ
							 	aSvEnchoice,;		// Clone do Vetor aEnchoice - para comparacao
							 	aRFQVirtChoice,;	// Campos Virtuais do Arquivo Pai ( RFQ )
							 	aRCFSvCols,;		// Clone de aRCFCols - RCF
								nRCFUsado,;	   		// Qtde de Campos usados - RCF
								aSvCols,;			// Clone de aCols
								aColsRec, ;	   		// Vetor com os Recnos 
								nPosRec,;           // Recno
								aRCGSvCols;			// Clone de aRCGColsAll	
						   )
Local aArea			:= GetArea()
// Variaveis auxiliares
Local nChoice		:= 0				// Variavel utilizada para for/while
Local nX			:= 0				// Utilizado em While/For
Local nY			:= 0				// Utilizado em While/For
Local nZ			:= 0				// Utilizado em While/For
Local nPosRot		:= ""
Local nPosPersel	:= ""
Local nPosFolCpl	:= ""   
Local cRotFol		:= fGetRotOrdinar()
Local lTravou		:= .F. 
Local lCompl		:= .T.
// Variaveis de tratamento da Tabela RCF - GetDados 
Local aColsRCF 		:= {}				// Colunas alteradas na getdados da tabela RCF
// Variaveis de tratamento da Tabela RFQ - Enchoice 
Local cKey			:= ""    			// Valor do campo chave
Local nChoices		:= 0.00				// Quantidade de campos da enchoice 
Local nLnAt			:= 0
Local aColsRCH 		:= aClone(oGetRCH:aCols)             
     
DEFAULT nOpc			:= 0.00			// Opcao do menu selecionado   
DEFAULT nReg			:= 0.00
DEFAULT aRFQVirtChoice	:= {}			// Campos virtuais da tabela pai - RCH

	aColsRCF 	:= aClone(oGetDados:aCols)	//Colunas alteradas na getdados da tabela RCF	
	nChoices	:= Len(	aEnchoice )
    cKey 		:= cFilRFQ +GetMemVar("RFQ_PROCES") + GetMemVar("RFQ_PERIOD") + GetMemVar("RFQ_NUMPAG") +;
      				DtoS(GetMemVar("RFQ_DTINI")) + DtoS(GetMemVar("RFQ_DTFIM")) + GetMemVar("RFQ_MODULO")   
      				
 	nPosFolCpl	:= GdFieldPos("RCH_COMPL" ,oGetRCH:aHeader)    
	nPosRot		:= GdFieldPos("RCH_ROTEIR" ,oGetRCH:aHeader) 
	nPosPersel	:= GdFieldPos("RCH_PERSEL" ,oGetRCH:aHeader)
     
	// Se for Exclusao ( nOpc == 5 )								   
	If ( nOpc == 5 ) 
	
		If RFQ->(MsSeek( cKey ))	
			fDeletaItens( cAlias , nReg,  nOpc , cKey) 
		EndIf
	
	// Se for Inclusao/Alteracao 	   
	ElseIf ( nOpc == 3 .Or. nOpc == 4 )
		
		//verifica se o roteiro esta cadastrado na tabela SRY
		For nZ := 1 To len(aColsRCH)
			If ValType(fGetTipoRot(aColsRCH[nZ, nPosRot])) == "U"
				Help(,,STR0021,, STR0144 + aColsRCH[nZ, nPosRot],1,0 ) 
		    	break
		    EndIf		
		Next nZ   
		
		// Gravado em um vetor para verificar se houve alteracao 
		For nChoice := 1 To nChoices
			aColsEnChoice[ 01 , nChoice ] := &( "M->"+aEnchoice[ nChoice , 02 ] )
		Next nChoice                                                                            
	 
		// Compara os arrays na alteracao caso nao houve modificacao nao grava
		If nOpc == 4 .And. fCompArray(aColsEnChoice,aSvEnchoice) .And. (fCompArray(aColsRCH,aSvColsRCH) .And.;
						    fCompArray(aColsRCF,aRCFSvCols) .And.  fCompArray(aRCGColsAll, aRCGSvCols))
			Return
		EndIf 
	
		Begin Transaction
			
			dbSelectArea("RFQ") 
			dbSetOrder(1)				
		
			If RFQ->(MsSeek( cKey ))	
		  		RecLock( "RFQ" , .F. , .F. ) // Alteracao		
			Else
				RecLock( "RFQ" , .T. , .F. ) // Inclusao
			EndIf
			
			// Campo que nao estao em controles 
			RFQ->RFQ_FILIAL := cFilRFQ 

			For nChoice := 1 To nChoices
				If ( aScan( aRFQVirtChoice , { |cCpo| ( cCpo == aEnchoice[ nChoice , 02 ] ) } ) == 0.00 )
					RFQ->( &( aEnchoice[ nChoice , 02 ] ) ) := &( "M->"+aEnchoice[ nChoice , 02 ] )
				EndIf
			Next nChoice     
						
			If Len(aColsRCH) > Len(aSvColsRCH)
				For nX := 1 to Len(aColsRCH)  
					If !aColsRch[nX,Len(aColsRCH[nX])] // Linhas q nao estao deletadas   
						nLnAt++
					EndIf
				Next nX     
				
				If nLnAt > Len(aSvColsRCH)   // Incluiu roteiro
					RFQ->RFQ_STATUS  := "1" // Aberto
				EndIf  
			EndIf
			
	        RFQ->( MsUnLock() ) 	        
	        RFQ->(dbCloseArea())
	        
	        // Gravacao da Tabela RCH   
	        nHeadersRCH	:= Len(oGetRCH:aHeader) 
			nCols		:= Len(oGetRCH:aCols) 
			
			dbSelectArea("RCH")
	
			For nX := 1 To nCols 
				lTravou:=.F.
				
				// Verifica Roteiro Complementar = ao cadastrar complementar, a rotina devera
				// desativar automaticamente  o roteiro de Folha normal que estiver ativo
				// do mesmo periodo   
				If nPosFolCpl > 0 .And. nPosRot	> 0 .And. nPosPersel > 0		       					 			    
					If fGetTipoRot(aColsRCH[nX, nPosRot]) $ "1" // Folha de Pagamento							
						If aColsRCH[nX, nPosFolCpl] == "1" .And. ;	// Complementar
							aColsRCH[nX, nPosPersel] == "1" 		// Selecionado
							// Desativa roteiro de FOLHA do mesmo periodo 								
							fChkFolCpl("2",cRotFol,GetMemVar("RFQ_PERIOD"))   
						ElseIf aColsRCH[nX, nPosFolCpl] <> "1" .And. ;	// Nao e complementar
							aColsRCH[nX, nPosPersel] == "1" 		// Selecionado   
							// Desativa complementar se houver 								
							fChkFolCpl("3",aColsRCH[nX, nPosRot],GetMemVar("RFQ_PERIOD"))   
						EndIf
					EndIf
				EndIf
				
				dbSelectArea("RCH")

				If aColsRCH[nX][nPosRec] > 0 
			    	DBGoto(aColsRCH[nX][nPosRec]) 
					RecLock("RCH", .F.,.T.) 
					lTravou:=.T.  
				Else 
					If !(aColsRCH[nX][Len(aColsRCH[nX])])  
						RecLock("RCH",.T.)  
						lTravou:=.T.  
					EndIf
				EndIf    
					
				If lTravou
					If aColsRCH[nX][Len(aColsRCH[nX])] 
						dbDelete()
					Else 
						RCH->RCH_FILIAL := xFilial("RCH",cFilRFQ)
						RCH->RCH_PROCES := cProcesso  
						RCH->RCH_MES 	:= GetMemVar("RFQ_MES") 
						RCH->RCH_ANO 	:= GetMemVar("RFQ_ANO")
						RCH->RCH_DTINI 	:= GetMemVar("RFQ_DTINI")  
						RCH->RCH_DTFIM 	:= GetMemVar("RFQ_DTFIM") 
						RCH->RCH_PER 	:= GetMemVar("RFQ_PERIOD")
						RCH->RCH_NUMPAG := GetMemVar("RFQ_NUMPAG")  		
	 
						For nY := 1 To nHeadersRCH
							cCampo    := Trim(oGetRCH:aHeader[nY][2]) 
							xConteudo := aColsRCH[nX,nY]
							If cCampo == "RCH_REC_WT" .And. xConteudo = 0 
								nPosRecWt	:= GdfieldPos("RCH_REC_WT" , oGetRCH:aHeader) 
								xConteudo 	:= RCH->(Recno())  
							Else  
								If cCampo == "RCH_MODULO"
									xConteudo := cModulo							
								Else 	 
									xConteudo := aColsRCH[nX,nY] 
								EndIf 
							EndIf						 	 
							&cCampo 	:= xConteudo 
						Next nY   
					EndIf
				EndIf 	
				RCH->( MsUnlock() )
			Next nX
	
			// Gravacao da Tabela RCF ao incluir/alterar 
			If nOpc == 3 .Or. ( !fCompArray(aColsRCF,aRCFSvCols) .And. nOpc == 4 ) 	  
				fGravaRCF(aColsRCF, aRCFSvCols,nRCFUsado, )
			EndIf   
			
			If cTpCalend == "1" // Somente para Calendario Analitico
				// Gravacao dos dados de RCG ao incluir/alterar
				
				If nOpc == 3 .Or.( !fCompArray(aRCGColsAll, aRCGSvCols) .And. nOpc == 4)
					fGravaRCG()
				EndIf
			EndIf
		
		End Transaction  
		
		RCH->(dbCloseArea()) 

	EndIf
	
	If 	lParamChRec
		lParamChRec := .F.
	EndIf  
	
	RestArea(aArea)

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fGravaRCF   ณ Autor ณ Equipe RH          ณ Data ณ  19/11/07   บฑฑ 
ฑฑฬออออออออออุอออออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Efetua gravacao dos dados da RCF.   			                 บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 / GPEA490                                             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function  fGravaRCF(aColsRCF,aRCFSvCols,nRCFUsado) 
Local aArea			:= GetArea()             
Local aAuxRCF		:= {}
Local cKey 			:= '' 
Local cCampo 		:= '' 
Local nX 			:= 0  
Local nY			:= 0 
Local xConteudo 
Local nPosRec	:=  GdfieldPos("RCF_REC_WT",aRCFHeader)
// Variaveis de tratamento da Tabela RCF - GetDados /
Local nPosTnoTra	:= 0.00					// Posicao do campo Turno de Trabalho 
Local nPosSemana	:= 0.00					// Posicao do campo Semana
Local nPosDia		:= 0
Local nHeaders		:= Len(	aRCFHeader )
Local nColsRCF		:= 0			 		// Numero de colunas de RCF
Local nAcolsRCF 	:= Len( aRCFColsRec )	// Posicao do registro
	
	// OBSERVACAO IMPORTANTE
	// Essa funcao tambem e utilizada para gravacao do calendario
	// na rotina GPEA490 (Ger. Per. Padrao), entretanto nela
	// nao existem as GetDados ref. a RCF e RCG, dessa forma e necessario
	// utilizar um array auxilar para nao prejudicar o funcionamento
	// da funcao.
	If(!lGp490, aAuxRCF := aClone(aColsRCF), AADD(aAuxRCF,aColsRCF))	
	nColsRCF := Len(	aAuxRCF )       

	// Posicionar no primeiro registro de RCF 
	For nX = 1 To nColsRCF 
		dbSelectArea("RCF")		
		// Quando recalculo (lParamChRec), nao considerar Recnos  
		// Sempre sera uma inclusao
		If aAuxRCF[nX,nPosRec] > 0  .And. If(!lGp490, !lParamChRec,)	// Registro de Alteracao 
			dbGoto(aAuxRCF[nX,nPosRec]) 
			RecLock("RCF",.F.,.T.) 
			If aAuxRCF[nX,nRCFUsado+1] 	// Registro excluido na RCF 
				// Deletar os registros na tabela RCG  
				cKey := RCF->(RCF_FILIAL+RCF_PER+RCF_SEMANA+RCF_ANO+RCF_MES+RCF_PROCES+RCF_TNOTRA+DTOS(RCF_DTINI)+DTOS(RCF_DTFIM)+RCF_MODULO)
	        	fDelItensRCG(cKey)
	       		RCF->( dbDelete() )
				Loop
			EndIf
		Else  // Registro de Inclusao
			// Verifica se nao esta Deletado no aCols 
			If aAuxRCF[nX,nRCFUsado+1]  == .F.
				If Empty(GdFieldGet( "RCF_TNOTRA" , nX , Nil, aRCFHeader, aAuxRCF ))
					Loop 
				EndIf 
				RecLock("RCF",.T.,.F.) 
				RCF->RCF_FILIAL	:= xFilial("RCF",cFilRFQ)
				RCF->RCF_PER	:= If(!lGp490, GetMemVar("RFQ_PERIOD"),cGp490Per)
			Else
				Loop
			EndIf
		EndIf
		// Gravacao dos campos comuns em RCF  
		For nY := 1 To nHeaders
			cCampo    := Trim(aRCFHeader[nY][2])
			xConteudo := aAuxRCF[nX,nY]
			&cCampo := xConteudo
		Next nY

		RCF_PROCES 	:= If(!lGp490, GetMemVar("RFQ_PROCES"),cProcesso) 
		RCF_ROTEIR	:= ""
		RCF_MES		:= If(!lGp490,GetMemVar("RFQ_MES"),cGp490Mes)
		RCF_ANO		:= If(!lGp490,GetMemVar("RFQ_ANO"),cGp490Ano)
		RCF_SEMANA  := If(!lGp490,GetMemVar("RFQ_NUMPAG"),cGp490NPg) 
		RCF_DTINI 	:= If(!lGp490,GetMemVar("RFQ_DTINI"),cGp490DIn) 
		RCF_DTFIM 	:= If(!lGp490,GetMemVar("RFQ_DTFIM"),cGp490DFi)
		RCF_MODULO 	:= If(!lGp490,GetMemVar("RFQ_MODULO"),cModulo) 

		RCF->( MsUnlock() )
	Next nX
	
	RestArea(aArea)

Return( Nil ) 
                             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fGravaRCG   ณ Autor ณ Equipe RH          ณ Data ณ  19/11/07   บฑฑ 
ฑฑฬออออออออออุอออออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Efetua gravacao dos dados da RCG.   			                 บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400/GPEA490                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function fGravaRCG() 
Local aArea			:= GetArea()
Local aColsRCG		:= aClone(aRCGColsAll)							// Dados de RCG
Local nX 			:= 0  
Local nY			:= 0 
Local nPosRec		:= GdfieldPos("RCG_REC_WT",aRCGAllHeader)
Local nPos 			:= 0
Local nPosCampo		:= 0											// Posicao do campo para gravacao
Local nPosPer       := 0
Local nColsRCG		:= Len(	aColsRCG )								// Numero de colunas de RCG
Local nHeaders		:= Len(	If(!lGp490, aRCGHeader, aRCGAllHeader) )			
Local lDeleted		:= .F. 
Local cSortKey		:= ''											// String com filtro 
Local cKey 			:= '' 
Local cCampo 		:= '' 
Local xConteudo 
	
	 // OBSERVACAO IMPORTANTE
	// Essa funcao tambem e utilizada para gravacao do calendario
	// na rotina GPEA490 (Ger. Per. Padrao), entretanto nela
	// nao existem as GetDados ref. a RCF e RCG, sendo somente utilizado 
	// o array e acols aRCGAllHeader /aRCGColsAll respectivamente.
	
	dbSelectArea("RCG")
	DbSetOrder(2) //RCG_FILIAL+RCG_PROCES+RCG_PER+RCG_SEMANA+RCG_ROTEIR+RCG_TNOTRA+DTOS(RCG_DIAMES)
			
	For nX := 1 To nColsRCG 
	
		If ((aColsRCG[nX, nPosRec] == 0) .And. aColsRCG[nX, Len(aRCGAllHeader)+1]) .Or.;
			Empty(GdFieldGet( "RCG_DIAMES" , nX , Nil , aRCGAllHeader, aRCGColsAll ))
			Loop
		EndIf
	    
		If ValType(aColsRCG[nX, nPosRec]) <> "U" .and. aColsRCG[nX, nPosRec] > 0   // Alteracao
			nPos := ascan(aRCGSvCols,{|x,y| x[nPosRec] == aColsRCG[nX, nPosRec]})
			If nPos >0 .And. fCompArray(aRCGColsAll[nX], aRCGSvCols[nPos]) .and. !aColsRCG[nX,Len(aRCGAllHeader)+1]
				Loop
			EndIf
			dbGoto(aRCGColsAll[nX, nPosRec])
			RecLock("RCG",.F.,.T.)
			lDeleted := aColsRCG[nX,Len(aRCGAllHeader)+1]
			If lDeleted		//Registro excluido na RCF
				// Deletar os registros na tabela RCG
				RCG->( dbDelete() ) 
				Loop 
			EndIf   
		Else  		// Novo registro
			nPosTnoTra := GdFieldPos( "RCG_TNOTRA"	, aRCGAllHeader )
			nPosDia    := GdFieldPos( "RCG_DIAMES"	, aRCGAllHeader )
			nPosPer    := GdFieldPos( "RCG_PER"	, aRCGAllHeader )
			If lGp490
				//Se jแ existir...pula.
				If RCG->(DbSeek(xFilial("RCG")+cProcesso+aRCGColsAll[nX,nPosPer]+cGp490NPg+"   "+If( nPosTnoTra > 0, aRCGColsAll[nX, nPosTnoTra ], "" )+If( nPosDia > 0, dtos(aRCGColsAll[nX, nPosDia ]), "" )))
					Loop
				EndIf
			EndIf
			RecLock( "RCG" , .T. , .F. )  // Incluir novo registro no banco
			// Campos comuns ao registro 
			RCG->RCG_FILIAL	:= xFilial("RCG",cFilRFQ)  
			RCG->RCG_PROCES	:= cProcesso
			RCG->RCG_ROTEIR := ""
			RCG->RCG_TNOTRA := If( nPosTnoTra > 0, aRCGColsAll[nX, nPosTnoTra ], "" ) 
			RCG->RCG_MODULO	:= cModulo    
			If !(lGp490)  
				// Para a rotina de Ger.Per. Padrao os campos chaves ja estarao
				// gravados no array aRCGColsAll
				RCG->RCG_PER	:= GetMemVar("RFQ_PERIOD")
				RCG->RCG_ANO	:= GetMemVar("RFQ_ANO") 
				RCG->RCG_MES	:= GetMemVar("RFQ_MES")
				RCG->RCG_SEMANA := GetMemVar("RFQ_NUMPAG")
				RCG->RCG_DTINI	:= GetMemVar("RFQ_DTINI")  
				RCG->RCG_DTFIM	:= GetMemVar("RFQ_DTFIM")   
			EndIf		 
		EndIf
		
		xConteudo	:= ""
		
		// Campos da GetDados 
		For nY := 1 To nHeaders
			cCampo := Trim(	If(!lGp490, aRCGHeader, aRCGAllHeader)[nY][2])
			If cCampo == "GHOSTCOL"  .Or. cCampo == "RCG_DESDIA"
				Loop
			EndIf 
			nPosCampo := GdFieldPos( cCampo, aRCGAllHeader )
			If nPosCampo > 0
				xConteudo	:= aRCGColsAll[nX,nPosCampo]
				&cCampo 	:= xConteudo
			EndIf
		Next nY 
		
		RCG->( MsUnlock() )
		
	Next nX 
	
	RestArea(aArea)

Return( Nil ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออัอออออออัอออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fDelItensRCG ณ Autor ณ Equipe RH         ณ Data ณ  08/07/07   บฑฑ 
ฑฑฬออออออออออุออออออออออออออฯอออออออฯอออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Efetua exclusao dos itens da Tabela RCG.		                 บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fDelItensRCG(cKey) 
Local aArea := GetArea()

	dbSelectArea("RCG")  
	dbSetOrder(RetOrder("RCG","RCG_FILIAL+RCG_PER+RCG_SEMANA+RCG_ANO+RCG_MES+RCG_PROCES+RCG_TNOTRA+DTOS(RCG_DTINI)+DTOS(RCG_DTFIM)+RCG_MODULO"))
	RCG->(MsSeek( cKey ))
	While !RCG->(Eof()) .And. RCG->(RCG_FILIAL+RCG_PER+RCG_SEMANA+RCG_ANO+RCG_MES+RCG_PROCES+RCG_TNOTRA+DTOS(RCG_DTINI)+DTOS(RCG_DTFIM)+RCG_MODULO) ==  cKey
		RecLock( "RCG" , .F. , .F. )
		RCG->( dbDelete() )
		RCG->( MsUnLock() )
		RCG->( dbSkip())
	Enddo

	RestArea(aArea)
	
Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออัอออออออัอออออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fDeletaItens ณ Autor ณ Natie Sugahara    1aV ณ Data ณ  01/12/03   บฑฑ    
ฑฑบ          ณ              ณ       ณ Mauricio Takakura 2aV ณ Data ณ  28/06/04   บฑฑ 
ฑฑฬออออออออออุออออออออออออออฯอออออออฯอออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Efetua exclusao dos itens da Tabela RCG.		                     บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400                                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function  fDeletaItens(cAlias,nReg,nOpc,cKeyDel)  
Local aArea			:= GetArea() 					
Local lRegOK 	:= .T. 	
Local aNotRelac	:= { "RCF", "SJQ" }
Local cRCHFil	:= ""
Local cRCFFil	:= ""
Local cRCGFil   := ""
Local aLog := {}
Local aTitLog := {}
Local cTitLog := OemToAnsi( STR0140 )

Private lLog := .F.

DEFAULT nReg := 0.0

	Begin Sequence    
	
		dbSelectArea(cAlias) 
		dbSetOrder(1)
	
		// Verificar se a tabela nao possui registros relacionados 
		lRegOk  := ChkDelRegs(	cAlias				,;	// Alias do Arquivo Principal
								nReg				,;	// Registro do Arquivo Principal
								nOpc				,;	// Opcao para a AxDeleta
								xFilial( cAlias )	,;	// Filial do Arquivo principal para Delecao
								cKeyDel				,;	// Chave do Arquivo Principal para Delecao
								Nil 				,;	// Array contendo informacoes dos arquivos a serem pesquisados
								Nil					,;	// Mensagem para MsgYesNo
								Nil					,;	// Titulo do Log de Delecao
								Nil					,;	// Mensagem para o corpo do Log
								.F.				 	,;	// Se executa AxDeleta
								.T.     			,;	// Se deve Mostrar o Log
								@aLog				,;	// Array com o Log de Exclusao
								@aTitLog		 	,;	// Array com o Titulo do Log
								Nil					,;	// Bloco para Posicionamento no Arquivo
								Nil					,;	// Bloco para a Condicao While
								Nil					,;	// Bloco para Skip/Loop no While
								.T.					,;	// Verifica os Relacionamentos no SX9
								aNotRelac			,;	// Alias que nao deverao ser Verificados no SX9
								Nil				 	 ;	// Se faz uma checagem soft
							 )
							 
		If lLog .And. Len(aLog) == 0
			aAdd(aLog, {})
			aAdd(aLog[1] , STR0068 + RFQ_PERIOD + STR0139 )
			fMakeLog(aLog,aTitLog, Nil,Nil,FunName(),cTitLog)
		EndIf

		If !lRegOK
			Break
		EndIf
	    
		DbSelectArea( "RFQ" )
		DbSetOrder(1) 
	
		// Confirmado exclusao dos registros 
		Begin Transaction
		        
				cRCHFil := xFilial("RCH", cFilRFQ)
				cKey := cRCHFil + RFQ->( RFQ_PERIOD + RFQ_NUMPAG + RFQ_PROCES + DTOS(RFQ_DTINI) + DTOS(RFQ_DTFIM) + RFQ_MODULO)
				// Exclusao dos registros RCH                                   
   				DbSelectArea( "RCH" )    
   				DbSetOrder(RetOrder("RCH","RCH_FILIAL+RCH_PER+RCH_NUMPAG+RCH_PROCES+DTOS(RCH_DTINI)+DTOS(RCH_DTFIM)+RCH_MODULO"))
				RCH->( MsSeek( cKey , .F. ) ) 
				While RCH->( !EOF() ) .And. RCH->( RCH_FILIAL + RCH_PER + RCH_NUMPAG + RCH_PROCES + DTOS(RCH_DTINI) + DTOS(RCH_DTFIM)+ RCH_MODULO) == cKey
					RecLock("RCH",.F.,.T.)
					dbDelete()
					MsUnlock()
					RCH->( DbSkip() )
				Enddo
				cKey := ""
				
				
				cRCFFil := xFilial("RCF", cFilRFQ)
				cKey 	:= cRCFFil + RFQ->( RFQ_PERIOD + RFQ_NUMPAG + RFQ_ANO + RFQ_MES + RFQ_PROCES + DTOS(RFQ_DTINI) + DTOS(RFQ_DTFIM) + RFQ_MODULO)
				// Exclusao dos registros RCF                                   
				DbSelectArea( "RCF" )
				DbSetOrder(RetOrdem("RCF","RCF_FILIAL+RCF_PER+RCF_SEMANA+RCF_ANO+RCF_MES+RCF_PROCES+DTOS(RCF_DTINI)+DTOS(RCF_DTFIM)+RCF_MODULO")) 
				RCF->( MsSeek( cKey , .F. ) )
				While RCF->( !EOF() ) .And. RCF->(RCF_FILIAL + RCF_PER + RCF_SEMANA + RCF_ANO + RCF_MES + RCF_PROCES + DTOS(RCF_DTINI) + DTOS(RCF_DTFIM) + RCF_MODULO) == cKey
					RecLock("RCF",.F.,.T.)
					dbDelete()
					MsUnlock()
					RCF->( DbSkip() )
				Enddo 
				cKey := ""				
				
				cRCGFil := xFilial("RCG", cFilRFQ)    
				cKey 	:= cRCGFil + RFQ->( RFQ_PERIOD + RFQ_NUMPAG + RFQ_ANO + RFQ_MES + RFQ_PROCES + DTOS(RFQ_DTINI) + DTOS(RFQ_DTFIM) + RFQ_MODULO)
				// Exclusao dos registros RCG                                   
				DbSelectArea( "RCG" )
				DbSetOrder( RetOrdem("RCG","RCG_FILIAL+RCG_PER+RCG_SEMANA+RCG_ANO+RCG_MES+RCG_PROCES+DTOS(RCG_DTINI)+DTOS(RCG_DTFIM)+RCG_MODULO" ))
				RCG->( MsSeek( cKey , .F. ) )
				While RCG->( !EOF() ) .And. RCG->( RCG_FILIAL + RCG_PER + RCG_SEMANA + RCG_ANO + RCG_MES + RCG_PROCES + DTOS(RCG_DTINI) + DTOS(RCG_DTFIM) + RCG_MODULO) == cKey
					RecLock("RCG",.F.,.T.)
					dbDelete()
					MsUnlock()
					RCG->( DbSkip() )
				Enddo
				cKey := ""	   
					
				// Exclusao dos registros RFQ                                   
				dbSelectArea( "RFQ" )
				RecLock("RFQ",.F.,.T.)
				dbDelete()
				MsUnlock()
				WRITESX2("RFQ", 1)  
				WRITESX2("RCH", 1)
				WRITESX2("RCF", 1)
				WRITESX2("RCG", 1)
				DbSkip ()
			
		End Transaction   
		
	End Sequence  
	
	RestArea(aArea)

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fNewAcols   ณ Autor ณ Natie S.     1a V ณ Data ณ  01/12/03   บฑฑ  
ฑฑบ          ณ 			   ณ	   ณ Mauricio T.  2a V ณ      ณ  28/06/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna Dia da Semana.									    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Usada na funcao MontaPeriodo.				        บฑฑ 
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function  fNewAcols(	cTipo	   		,;		// Tipo do acols 
					   		aNotFields 		,;		// Campos nao visuais de RCG
							nUsado			,;		// Numero de campos usados - RCG
							dDataIni		,;		// Data inicial para cadastro de dias
							dDataFim		,;		// Data final para cadastro de dias
					   		nHrsDia		 	;		// Numero de horas          
								)
Local aArea			:= GetArea()
Local aColsAux		:= {}
Local aRelacaoNew	:= {}
Local aAreaRCF		:= {}
Local cAliasAtu 	:= ""									
Local dData			:= CtoD("//") 							
Local nCnt			:= 0									
Local nTam			:= 0 
Local nDias 		:= 0	
Local nPosDiaMes	:= 0                                  
Local nPosDesdia	:= 0
Local nPosTipdia	:= 0
Local nPosVTrans	:= 0
Local nPosDifTra	:= 0
Local nPosvRefei	:= 0   
Local nPosvAlime	:= 0
Local nPosHrsTra	:= 0
Local nPosHrsDsr	:= 0
Local nPosPer		:= 0 
Local nPosNPag		:= 0
Local nPosPro		:= 0
Local nPosRot		:= 0
Local nPosMes		:= 0
Local nPosAno		:= 0
Local nPosDtIni		:= 0
Local nPosDtFim		:= 0
Local nPosDtPag 	:= 0
Local nPosDtCort 	:= 0
Local nPosPdPeri 	:= 0 
Local nPosMod		:= 0 
Local nPosCrit  	:= 0
Local nPosSequ   	:= 0
Local nPosAli		:= 0
Local nPosRecWt		:= 0
Local nX			:= 0 
Local nPer			:= 0 
Local _aColsRCh   	:= {} 


	// GPEA400  - Tela com  Turnos e Calendarios do periodo
	If 	cTipo == "1" 
		cAliasAtu 	:= "RCG"									// Alias da tabela
		nDias 		:= Max( (dDataFim  - dDataIni )+1 , 0 ) 	// Numero de dias a contabilizar
		aAreaRCF	:= RCF->(GetArea())						// Area de RCF	
		
		nPosDiaMes	:=  GdFieldPos( "RCG_DIAMES" , If(!lGp490, aRCGHeader, aRCGAllHeader) )
		nPosDesdia	:=  GdFieldPos( "RCG_DESDIA" , If(!lGp490, aRCGHeader, aRCGAllHeader) )
		nPosTipdia	:=  GdFieldPos( "RCG_TIPDIA" , If(!lGp490, aRCGHeader, aRCGAllHeader) )
		nPosVTrans	:=  GdFieldPos( "RCG_VTRANS" , If(!lGp490, aRCGHeader, aRCGAllHeader) )
		nPosDifTra	:=  GdFieldPos( "RCG_DIFTRA" , If(!lGp490, aRCGHeader, aRCGAllHeader) )
		nPosvRefei	:=  GdFieldPos( "RCG_VREFEI" , If(!lGp490, aRCGHeader, aRCGAllHeader) )
		nPosvAlime	:=  GdFieldPos( "RCG_VALIM"  , If(!lGp490, aRCGHeader, aRCGAllHeader) )		
		nPosHrsTra	:=  GdFieldPos( "RCG_HRSTRA" , If(!lGp490, aRCGHeader, aRCGAllHeader) )
		nPosHrsDsr	:=  GdFieldPos( "RCG_HRSDSR" , If(!lGp490, aRCGHeader, aRCGAllHeader) )	
	
		nTam		:= Len(If(!lGp490, aRCGHeader, aRCGAllHeader))+1	// Qtde de campos
		aColsAux 	:= Array(nDias, nTam)                                		
		For nCnt := 1 To nDias
			nUsado	:= 0   					// Numero de campos usados em RCG - variavel local de GPA400MANU
			If nCnt == 1
				dData		:= dDataIni
			Else
				dData		:= dData + 1
			EndIf
			
			dbSelectArea("SX3")
			dbSetOrder(1)
			SX3->(MsSeek("RCG"))
			While !Eof() .And. X3_ARQUIVO == cAliasAtu
				If x3uso(X3_USADO) .And. cNivel >= X3_NIVEL  .And. !aScan(aNotFields,AllTrim(X3_CAMPO)) > 0
					nUsado++
					If X3_CAMPO == "RCG_DIAMES" .And. nPosDiaMes > 0
						aColsAux[nCnt,nPosDiaMes] := dData							// Dia do Mes 
					ElseIf X3_CAMPO == "RCG_DESDIA" .And. nPosDesDia > 0
						cRet	:=	GPEDiaSem(dData)     				 			// Descricao do dia da Semana
						aColsAux[nCnt,nPosDesDia] := cRet
					ElseIf X3_CAMPO == "RCG_TIPDIA" .And. nPosTipdia > 0
						cRet	:= RetTipoDia(dData )   							// Trabalhado/Nao Trabaalhado/Dsr/Feriado	
						aColsAux[nCnt,nPosTipDia] := cRet
						
						If cRet == "4"
							If nPosHrsTra > 0
								aColsAux[nCnt,nPosHrsTra] := 0
							EndIf
							If	nPosHrsDsr > 0
								aColsAux[nCnt,nPosHrsDsr] := nHrsDia
							EndIf
						EndIf
													
					ElseIf X3_CAMPO == "RCG_VTRANS"	.And. nPosVTrans > 0 			// Utiliza Vale Transporte  (1=Sim; 2=Nao)
							If( Alltrim( Upper( Cdow( dData  ))) == "SATURDAY" .Or.;
							    Alltrim( Upper( Cdow( dData  ))) == "SUNDAY";
							    .Or. ( RetTipoDia(dData) == "4")) // Feriado tamb้m nใo deverแ gerar vale transporte!
								aColsAux[nCnt,nPosVTrans] := "2"  
							Else
								aColsAux[nCnt,nPosVTrans] := "1" 
							EndIf	
					ElseIf X3_CAMPO == "RCG_DIFTRA" .And. nPosDifTra > 0 			// Dif. de Vale Transporte  (1=Sim; 2=Nao) 
						aColsAux[nCnt,nPosDifTra] := "2" 
					ElseIf X3_CAMPO == "RCG_VREFEI"	 .And. nPosvRefei > 0			// Utiliza Vale Refeicao    (1=Sim; 2=Nao)
						If( Alltrim( Upper( Cdow( dData   ))) == "SATURDAY" .Or. ;
						    Alltrim( Upper( Cdow( dData   ))) == "SUNDAY";
						    .Or. ( RetTipoDia(dData) == "4")) // Feriado tamb้m nใo deverแ gerar vale refei็ใo!
							aColsAux[nCnt,nPosvRefei] := "2" 
						Else
							aColsAux[nCnt,nPosvRefei] := "1"  
						EndIf
					Elseif X3_CAMPO = "RCG_VALIM"			                		// Utiliza Vale Refeicao    (1=sim; 2=Nao)
						If( Alltrim( Upper( Cdow( dData   ))) == "SATURDAY" .Or. ;
						    Alltrim( Upper( Cdow( dData   ))) == "SUNDAY";
						    .Or. ( RetTipoDia(dData) == "4")) // Feriado tamb้m nใo deverแ gerar vale alimenta็ใo!
					    	If (nPosvAlime > 0 )   
								aColsAux[nCnt,nPosvAlime] := "2" 
							EndIf	
						Else     
							If (nPosvAlime > 0 ) 
								aColsAux[nCnt,nPosvAlime] := "1"  
							EndIf	
						EndIf								
					ElseIf 	X3_CAMPO == "RCG_HRSTRA" .And. nPosHrsTra > 0
						If cRet != "4"
							If( Alltrim( Upper( Cdow( dData  ))) == "SATURDAY" .Or. ;
							Alltrim( Upper( Cdow( dData  ))) == "SUNDAY"   )
							aColsAux[nCnt,nPosHrsTra] := 0 
							Else
								aColsAux[nCnt,nPosHrsTra] := nHrsDia
							EndIf
						EndIf
					ElseIf 	X3_CAMPO == "RCG_HRSDSR" .And. nPosHrsDsr > 0
						If cRet != "4"
							If ( Alltrim( Upper( Cdow( dData  ))) == "SUNDAY"   ) .And. ;
							cPaisLoc <> "ARG"
							aColsAux[nCnt,nPosHrsDsr] := nHrsDia
							Else
								aColsAux[nCnt,nPosHrsDsr] := 0
							EndIf
						Endif
					Else
						aColsAux[nCnt,nUsado] := &(cAliasAtu+"->"+X3_CAMPO)
					EndIf
				EndIf
				SX3->(dbSkip())
			EndDo
		
			aColsAux[nCnt,nTam]     	:= .F. 		// Se Linha Deletada
		Next nCnt   
		
		RestArea(aAreaRCF)
			
	// GPEA490 - Utiliza modelo para exibicao dos registros gerados 
	ElseIf cTipo ="2" 
	
		cAliasAtu 	:= "RCH"									// Alias da tabela	
		nTam		:= Len(oGetRCH:aHeader)+1
		nPosPer		:= GdFieldPos("RCH_PER"    , oGetRCH:aHeader)
		nPosNPag	:= GdFieldPos("RCH_NUMPAG" , oGetRCH:aHeader)
		nPosMes		:= GdFieldPos("RCH_MES"    , oGetRCH:aHeader)
		nPosAno		:= GdFieldPos("RCH_ANO"    , oGetRCH:aHeader)
		nPosDtIni	:= GdFieldPos("RFQ_DTINI"  , oGetRCH:aHeader)
		nPosDtFim	:= GdFieldPos("RCH_DTFIM"  , oGetRCH:aHeader)
		nPosDtPag 	:= GdFieldPos("RCH_DTPAGO" , oGetRCH:aHeader) 
		nPosDtCort	:= GdFieldPos("RCH_DTCORT" , oGetRCH:aHeader)
		nPosMod   	:= GdFieldPos("RCH_MODULO" , oGetRCH:aHeader)
		nPosPdPeri	:= GdFieldPos("RCH_PDPERI" , oGetRCH:aHeader)
		nPosCrit  	:= GdFieldPos("RCH_CRITER" , oGetRCH:aHeader)
		nPosSequ	:= GdFieldPos("RCH_SEQUE"  , oGetRCH:aHeader)
		nPosAli		:= GdfieldPos("RCH_ALI_WT" , oGetRCH:aHeader)
		nPosRecWt	:= GdfieldPos("RCH_REC_WT" , oGetRCH:aHeader)
	     
		nPer		:= Len(aRG6) 
		aColsAux	:= Array(nPer, nTam )
		
		aRelacaoNew := GdRmkaCols(	oGetRCH:aHeader, .F.,	.T., .T. )
		
		For nX := 1 to nPer
		
			nUsado 	:= 0 
			dbSelectArea("SX3")
			dbSetOrder(1)
			SX3->(MsSeek("RCH")) 
			While !Eof() .and. X3_ARQUIVO == cAliasAtu 
				If x3uso(X3_USADO) .And. cNivel >= X3_NIVEL  .And. !aScan(aNotFields,AllTrim(X3_CAMPO)) > 0 
					If 	alltrim(X3_CAMPO) == "RCH_PDPERI" .And. nPosPdPeri > 0 
						aColsAux[nX, nPosPdPeri]	:= aRG6[nX, 1]                                   		//-- Pad.Periodo 
					ElseIf alltrim(X3_CAMPO) == "RCH_PER" .And. nPosPer > 0
						aColsAux[nX, nPosPer]		:= aRG6[nX, 2]											//-- Ex.: 200701 
					ElseIF alltrim(X3_CAMPO) == "RCH_NUMPAG" .And. nPosNPag > 0
						aColsAux[nX, nPosNPag]		:= aRG6[nX, 3]                       					//-- No Pagto
					Elseif alltrim(X3_CAMPO) == "RCH_MES"	.And. nPosMes > 0
						aColsAux[nX, nPosMes]		:= aRG6[nX, 4] 					 						//-- Mes
					Elseif alltrim(X3_CAMPO) == "RCH_ANO" .And. nPosAno > 0 	
						aColsAux[nX, nPosAno]		:= aRG6[nX, 5]											//-- Ano 		
					Elseif alltrim(X3_CAMPO) == "RFQ_DTINI"	 .And. nPosDtIni > 0 
						aColsAux[nX, nPosDtIni]		:= aRG6[nX, 6]											//-- Dt Inicio Periodo
					Elseif alltrim(X3_CAMPO) == "RCH_DTFIM"	 .And. nPosDtFim > 0 
						aColsAux[nX, nPosDtFim]		:= aRG6[nX, 7]											//-- Dt Fim  Periodo
					ElseIf 	alltrim(X3_CAMPO) == "RCH_DTPAGO" .And. nPosDtFim > 0	
						aColsAux[nX, nPosDtPag]		:= aRG6[nX, 8]											//-- Data de Pagto
					ElseIf 	alltrim(X3_CAMPO) == "RCH_DTCORT" .And. nPosDtCort > 0 
						aColsAux[nX, nPosDtCort]	:= aRG6[nX, 9]								  			//-- Data de Corte 
					ElseIf 	alltrim(X3_CAMPO) == "RCH_CRITER" .And. nPosCrit> 0  
						aColsAux[nX, nPosCrit]		:= aRG6[nX, 10]                                   		//-- Criterio 
					ElseIf 	alltrim(X3_CAMPO) == "RCH_SEQUE" .And. nPosSequ > 0  
						aColsAux[nX, nPosSequ]		:= aRG6[nX, 11]                                   		//-- Sequencia 
					ElseIf 	alltrim(X3_CAMPO) == "RCH_MODULO" .And. nPosMod > 0  
						aColsAux[nX, nPosMod]		:= aRG6[nX, 12]                                   		//-- Modulo 
					Else
						nUsado := GdfieldPos(X3_CAMPO , oGetRCH:aHeader)
						If nUsado > 0  
							aColsAux[nX,nUsado] := aRelacaoNew[1,nUsado]
						EndIf
					EndIf
					
				EndIf
				SX3->(dbSkip())
			EndDo
			If nPosAli > 0
				aColsAux[nX,nPosAli] := cAliasAtu
			EndIf
			If nPosRecWt > 0 
				aColsAux[nX,nPosRecWt] := 0
			EndIf 
			aColsAux[nX,nTam       ] := .F.	
		Next nX
	EndIf 
         
	RestArea(aArea)

Return( aClone(aColsAux) ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออัอออออออัอออออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ GPEDiaSem    ณ Autor ณ Natie Sugahara        ณ Data ณ  01/12/03   บฑฑ    
ฑฑฬออออออออออุออออออออออออออฯอออออออฯอออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna Dia da Semana.						                     บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400                                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function GPEDiaSem(dData) 
Local aArea			:= GetArea()
Local aDias := {oemToAnsi(STR0013),oemToAnsi(STR0014),oemToAnsi(STR0015),oemToAnsi(STR0016),oemToAnsi(STR0017),oemToAnsi(STR0018),oemToAnsi(STR0019) }
	
	RestArea(aArea)

Return(aDias[Dow(dData)])   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ RetTipoDia  ณ Autor ณ Natie S.          ณ Data ณ  01/12/03   บฑฑ  
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica Turno de Trabalho.								    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 												        บฑฑ 
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function RetTipoDia( dDataRef )   
Local aArea		:= GetArea()
Local cRet		:= "1"    //-Tipo do Dia (1=Trabalhado;2=Nao Trabalhado;3=DSR;4=Feriado
	
	If Alltrim(Upper(Cdow(dDataRef))) == "SUNDAY"
		cRet	:= If(cPaisLoc == "ARG","2","3" )
	ElseIf  Alltrim(Upper(Cdow(dDataRef))) == "SATURDAY" 
		cRet	:= "2"
	EndIf 
	
	// Verifica se e feriado
	If fFeriado( xFilial("SP3") ,dDataRef,,,) 
		cRet := "4"
	EndIf
	
	RestArea(aArea)

Return( cRet ) 

                                             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fVldSemana  ณ Autor ณNatie Sugahara      ณ Data ณ  01/12/03   บฑฑ 
ฑฑฬออออออออออุอออออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Efetua Validacao da semana.								     บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ X3_VALID - RCF_SEMANA                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/                                             
Function fVldSemana(cRCFNumPag) 
Local aArea			:= GetArea()

	// Valida a Semana que podera ser bb ( valida p/todas as semanas ou ate "52" )         
	If !Empty(cRCFNumPag) .and. !Entre("01","52", cRCFNumPag )
		Return(.F.) 
	EndIf 
	
	RestArea(aArea)

Return( .T. ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ Gp400NumPg  ณ Autor ณ Equipe RH          ณ Data ณ  05/03/13   บฑฑ 
ฑฑฬออออออออออุอออออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Efetua preenchimento do campo RFQ_NUMPAG. 				     บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400				                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/                                             
Function Gp400NumPg()     
Local aArea		:= GetArea()   
Local cNrPag	:= "1" 
Local nNumPag 	:= 0

	dbSelectArea("RFQ")
	dbSetOrder(1)
	RFQ->(MsSeek(cFilRFQ + M->RFQ_PROCES + M->RFQ_PERIOD ))
	While !RFQ->(Eof()) .And. RFQ->RFQ_FILIAL == cFilRFQ .And. RFQ->RFQ_PROCES == M->RFQ_PROCES .And. RFQ->RFQ_PERIOD == M->RFQ_PERIOD 
		If RFQ->RFQ_NUMPAG <> M->RFQ_NUMPAG
			cNrPag	:= RFQ->RFQ_NUMPAG
		EndIf
   		RFQ->( dbSkip())
  	End
	
	If !Empty(cNrPag) .And. Empty(GetMemVar("RFQ_NUMPAG"))
		nNumPag := Val(cNrPag)
		nNumPag++
		M->RFQ_NUMPAG := StrZero(nNumPag,TamSx3("RFQ_NUMPAG")[1],0)		
	EndIf 
	
	RestArea(aArea)

Return( .T. )   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ VldDtIni    ณ Autor ณ Natie Sugahara     ณ Data ณ  01/12/03   บฑฑ 
ฑฑฬออออออออออุอออออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica Data inical e compativel com Competencia.		     บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ X3_VALID - RFQ_DTINI / RFQ_DTFIM.			                 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function VldDtIni(dDtIni,dDtFim,cMes,cAno)  
Local aArea 	:= GetArea()     
Local cAnoMesI	:= MesAno(dDtIni)
Local cAnoMesX	:= cAno+cMes
Local lRetorno := .T.
   If !Empty(dDtIni)  .And.  cAnoMesX # cAnoMesI
	 	If cPaisLoc == "BRA"
			Help(" ",1,"PERIMCOMPA")  	//"Periodo digitado esta imcompativel com  a Competencia (Mes/Ano) informado."
			Return(.F.)
		Else
			If !MsgYesNo( OemToAnsi(STR0149) + CRLF + CRLF + OemToAnsi(STR0150) , OemToAnsi( STR0083  ) ) //"A data digitada estแ incompatํvel com a Compet๊ncia (Mes/Ano) informada."##"Deseja continuar o cadastro?"## "Aten็ใo"
				Return(.F.)
			EndIf
		EndIf
	EndIf 
	If cPaisLoc != "BRA"
		lRetorno := X_VLDDTINI(dDtIni, dDtFim, cMes, cAno)
		Return(lRetorno)	      
	// Validacao do Campo Data Inicial 	
	ElseIf !Empty(dDtIni) .And. !Empty(dDtFim)    
		
		If !Empty(dDtFim) .And. dDtIni > dDtFim 
			Help(" ",1,"DATA2INVAL")    	// "A Data de Fim nao pode ser menor do que a Data de Inicio."
			Return(.F.)
   		EndIf
			
		// Ao selecionar 'Incluir' as variaveis dRFQDtIni e dRFQDtFim estarao vazias
		// Somente serao agregados valores a elas apos o calculo do calendario	 
		If Empty(dRFQDtIni) .And. Empty(dRFQDtFim) 	 // Execucao do calculo pela PRIMEIRA vez		   	
			fFeriado( xFilial("SP3"),,,dDtIni, dDtFim) 		// Carrega __aFeriadoStatic
			If(cTpCalend == "1", Eval(bExeCalc), fCalcSint()) 	// Calc. inicial			  							
		ElseIf !Empty(dRFQDtIni) .And. !Empty(dRFQDtFim) 
				// Verifica se houve alteracao das Datas para recalcular o Calendarios dos Turnos com lancamentos em RCG
			   If (dDtIni <> dRFQDtIni .Or. dDtFim <> dRFQDtFim) 
			   		If MsgYesNo( OemToAnsi(STR0111)  +  OemToAnsi(STR0075)  )	//"Houveram alteracoes ref. as datas do periodo, o calendario sera recalculado. Confirma? "
				   		fFeriado( xFilial("SP3"),,,dDtIni, dDtFim) 			// Carrega __aFeriadoStatic
				   		If(cTpCalend == "1", Eval(bExeCalc), fCalcSint())         
			   		Else
			   			M->RFQ_DTINI := dRFQDtIni
			   			M->RFQ_DTFIM := dRFQDtFim
			   		EndIf 
			   EndIf 
		EndIf   		
	EndIf     
	                         
	RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ VldDtFim    ณ Autor ณ Natie Sugahara     ณ Data ณ  01/12/03   บฑฑ 
ฑฑฬออออออออออุอออออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica se Dt Final e maior que a Dt Inicial e se a Dt Final บฑฑ  
ฑฑบ          ณ e compativel com  a competencia.				           	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ X3_VALID - RFQ_DTFIM / RFQ_DTFIM 			                 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function VldDtFim(dDtIni, dDtFim, cMes, cAno)  
Local aArea 		:= GetArea()
Local lRetorno := .T.
	If !(cPaisLoc $ "BRA/BOL")
		lRetorno := X_VLDDTFIM(dDtIni, dDtFim, cMes, cAno)	
		Return(lRetorno)

     // Validacao do Campo Data Final     
  	ElseIf !Empty(dDtIni) .And. !Empty(dDtFim)  
	  	If !Empty(dDtIni) .And. dDtFim < dDtIni
			Help(" ",1,"DATA2INVAL")    	// "A Data de Fim nao pode ser menor do que a Data de Inicio"
			Return(.F.) 
		EndIf  
		
		If anomes(dDtFim) <> cAno+cMes .And. cPaisLoc == "BRA"
			Help(,,STR0021,, STR0149,1,0 ) //A data digitada estแ incompatํvel com a Compet๊ncia (Mes/Ano) informada."
			Return(.F.) 
		EndIf  
		
		If !lPerMod2 //Validacao nao aplicavel para o cadastro modelo 2 simplificado
			// Ao selecionar 'Incluir' as variaveis dRFQDtIni e dRFQDtFim estarao vazias
			// Somente serao agregados valores a elas apos o calculo do calendario	 
			If Empty(dRFQDtIni) .And. Empty(dRFQDtFim) 	 // Execucao do calculo pela PRIMEIRA vez 
				fFeriado( xFilial("SP3") ,,,dDtIni, dDtFim) 		// Carrega __aFeriadoStatic			   	
				If(cTpCalend == "1", Eval(bExeCalc), fCalcSint()) 	// Calc. inicial  											  
			ElseIf !Empty(dRFQDtIni) .And. !Empty(dRFQDtFim) 
					// Verifica se houve alteracao das Datas para recalcular o Calendarios dos Turnos com lancamentos em RCG
				   If (dDtIni <> dRFQDtIni .Or. dDtFim <> dRFQDtFim)  
				   		If MsgYesNo( OemToAnsi(STR0111)  +  OemToAnsi(STR0075)  )	//"Houveram alteracoes ref. as datas do periodo, o calendario sera recalculado. Confirma? "
					   		fFeriado( xFilial("SP3") ,,,dDtIni, dDtFim) 			// Carrega __aFeriadoStatic	com novo periodo
					   		If(cTpCalend == "1", Eval(bExeCalc), fCalcSint())  
				   		Else
				   			M->RFQ_DTINI := dRFQDtIni
				   			M->RFQ_DTFIM := dRFQDtFim
				   		EndIf 
				   EndIf
			EndIf
		EndIf    
	EndIf        

	RestArea(aArea)

Return( .T. )    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ VldHrsDia   ณ Autor ณ Natie S.          ณ Data ณ  01/12/03   บฑฑ  
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida qtde de horas trabalhadas p/dia.					    บฑฑ
ฑฑบ          ณ Alimenta os campos da aCols onde sao informadas as qtde de   บฑฑ
ฑฑบ          ณ horas trabalhadas por dia.									บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400  - Usada na funcao fNewAcols Tipo 1.	        		บฑฑ  
ฑฑบ          ณ X3_VALID - RCF_HRSDIA	        							บฑฑ 
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function VldHrsDia(nValor)
Local aArea			:= GetArea()   
Local cCampo		:= ""
Local cValor  		:= ""
Local nPosHrsTra	:= 0			// Posicao do campo HrsTra em RCG
Local nPosHrsDsr	:= 0			// Posicao do campo HrsDsr em RCG
Local nPosTipdia	:= 0			// Posicao do Campo TipDia em RCG          
Local nPosHrsDia    := 0			// Posicao do campo RCF_HrsDia no Cabecalho
Local nRCFDiaTr		:= 0			// Posicao do campo RCF_DiaTra no Cabecalho
Local nRCFHrsTr		:= 0			// Posicao do campo RCF_HrsTra no Cabecalho 
Local nRCFDiaDSR	:= 0			// Posicao do campo RCF_DiaDsr no Cabecalho 
Local nRCFHrsDSR	:= 0			// Posicao do campo RCF_HrsDsr no Cabecalho 
Local nPos			:= 0			// Posicao do campo RCF_HrsDia no Cabecalho
Local nAtRCF		:= 0			// Posicao do Registro atual          
Local nVlrDSR		:= 0
Local nVlrTr		:= 0
			
	nAtRCF	:= oGetDados:nAt  
    cCampo	:= ReadVar()        
    
    Do Case    
    	Case cCampo == "M->RCF_HRSDIA"
    		nPos 	:= Ascan(aRCFHeader,{|z| z[2] = "RCF_HRSDIA" } )  
    		nHrsDia	:= nValor          		
    	Case cCampo == "M->RCF_DIADSR" 
    		nPos 		:= Ascan(aRCFHeader,{|z| z[2] = "RCF_DIADSR" } ) 
    		nPosHrsDia	:= Ascan(aRCFHeader,{|z| z[2] = "RCF_HRSDIA" } ) 
    		nHrsDia		:= oGetDados:aCols[oGetDados:nAt,nPosHrsDia] 
    	Case cCampo == "M->RCF_DIATRA"   
    		nPos 		:= Ascan(aRCFHeader,{|z| z[2] = "RCF_DIATRA" } ) 	        
    		nPosHrsDia	:= Ascan(aRCFHeader,{|z| z[2] = "RCF_HRSDIA" } ) 
    		nHrsDia		:= oGetDados:aCols[oGetDados:nAt,nPosHrsDia]  
    EndCase
	
	If nPos > 0 
		// Somente para Calendario Analitico
		If cTpCalend == "1"
			nPosHrsTra	:= GdFieldPos( "RCG_HRSTRA" ,aRCGHeader ) 
			nPosHrsDsr	:= GdFieldPos( "RCG_HRSDSR" ,aRCGHeader ) 
			nPosTipdia	:= GdFieldPos( "RCG_TIPDIA" ,aRCGHeader ) 
		EndIf  
		// Horas Trabalhadas
		nRCFHrsTr	:= Ascan(aRCFHeader,{|z| z[2] = "RCF_HRSTRA" } )  
		nRCFDiaTr	:= Ascan(aRCFHeader,{|z| z[2] = "RCF_DIATRA" } )
		// Horas DSR
		nRCFHrsDSR	:= Ascan(aRCFHeader,{|z| z[2] = "RCF_HRSDSR" } )   
		nRCFDiaDSR  := Ascan(aRCFHeader,{|z| z[2] = "RCF_DIADSR" } ) 		
		If nValor <> oGetDados:aCols[nAtRCF,nPos] 
		   	// Somente para Calendario Analitico
		   If cTpCalend == "1" .And. nPosTipDia > 0  // Horas por Dia 
				If nPosHrsTra > 0
					Aeval(oGetDadosRCG:aCols,{|x,y|If( oGetDadosRCG:aCols[y,nPosTipdia] == "1",oGetDadosRCG:aCols[y,nPosHrsTra ]:= nHrsDia , 0)  } ) 			// Horas Trabalhadas
				EndIf
				If nPosHrsDsr > 0
					Aeval(oGetDadosRCG:aCols,{|x,y|If( oGetDadosRCG:aCols[y,nPosTipdia] == "3",oGetDadosRCG:aCols[y,nPosHrsDsr ]:= nHrsDia , 0)  } ) 			// Horas de DSR
				EndIf   
			EndIf
			If nRCFHrsTr > 0 .And. nRCFDiaTr > 0 
				nVlrTr := If(cCampo == "M->RCF_DIATRA", nValor, oGetDados:aCols[oGetDados:nAt,nRCFDiaTr]) 
				oGetDados:aCols[oGetDados:nAt,nRCFHrsTr] := nHrsDia * nVlrTr
			EndIf
			If nRCFHrsDsr > 0 .And. nRCFDiaDSR > 0    
				nVlrDSR := If(cCampo == "M->RCF_DIADSR", nValor, oGetDados:aCols[oGetDados:nAt,nRCFDiaDSR]) 
				oGetDados:aCols[oGetDados:nAt,nRCFHrsDsr] := nHrsDia * nVlrDSR
			EndIf
		EndIf
	EndIf
	If cTpCalend == "1"
		// Gravar no vetor principal 
		Gpea400AllTrf(	"RCG"   			,;	//01 -> Alias do Arquivo
						oGetDados			,;	//02 -> Objeto GetDados para o RCF
						@oGetDadosRCG:aCols	,;	//03 -> aCols utilizado na GetDados
						aRCGHeader			,;	//04 -> Aheader
						.F.			    	,;	//07 -> Se carrega elemento de Deletacao na remontagem do aCols
						.T.		    		,;	//08 -> Se transfere do aCols para o aColsAll
						.T.			     	;	//09 -> Se transfere do aColsAll para o aCols
					  )							//Funcao local		  			  			  
		oGetDadosRCG:oBrowse:Refresh()  
	EndIf        
	
	oGetDados:oBrowse:Refresh()  
    
    RestArea(aArea)
    
Return( .T. ) 
               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fVldPer     ณ Autor ณNatie Sugahara      ณ Data ณ  09/11/07   บฑฑ 
ฑฑฬออออออออออุอออออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida o Periodo e o Numero de Pagto.						 บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ X3_VALID -  RFQ_PER / RFQ_NUMPAG                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function fVldPer() 
Local aArea	:= GetArea()
Local cPer	:= ""
Local nAno	:= 0
Local nMes	:= 0	

If lPerMod2
	If ( Type("oGetRCH") == "O" ) 
		nPosDtFech	:= GdFieldPos("RCH_DTFECH",oGetRCh:aHeader) 
		nPosPdPeri 	:= GdFieldPos("RCH_PDPERI",oGetRCh:aHeader) 
		nPosStatus 	:= GdFieldPos("RCH_STATUS",oGetRCh:aHeader) 
			
		/* 
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณValidacao do Campo Data de fechamento                                              |
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
		If nPosDTFech > 0  .and. !Empty( oGetRCh:aCols[oGetRCh:nAt, nPosDTFech]) 
			MsgAlert( OemToAnsi( STR0047 ) , OemToAnsi( STR0021 ) ) 				//--"Este periodo ja foi encerrado e nao sera possivel a manutencao deste campo" 
			Return(.F.)
		Endif 
	
		/*
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณValidacao do Campo de Status                                                       |
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
		If (nPosStatus > 0 .and. ; 
			 (!Empty( oGetRCh:aCols[oGetRCh:nAt, nPosStatus ] )  .and. oGetRCh:aCols[oGetRCh:nAt, nPosStatus ] <> "0" );
		    )
			MsgAlert( OemToAnsi( STR0033 ) , OemToAnsi( STR0021 ) ) 				//--"Nao e possivel efetuar a alteracao ou exclusao deste periodo. Verifique o campo de Status " 
			Return(.F.) 
		Endif 
	Endif 
	
	//Forca o cadastro ser com dois digitos                                                                                        
	If Type("M->RCH_NUMPAG") != "U"                                                                                
		If Len(AllTrim(M->RCH_NUMPAG)) == 1
			M->RCH_NUMPAG := strZero(Val(M->RCH_NUMPAG),2) 
		EndIf
	EndIf
Else
	
	// Forca nomenclatura de codigo de periodo formato AAAA/MM
	If Type("M->RFQ_PERIOD") != "U"   
		cPer := GetMemVar("RFQ_PERIOD")
		nAno := Val(SubStr(cPer, 0, 4))
		nMes := Val(SubStr(cPer, 5, 2))
		
		If (nAno < 1900 .Or. nAno > 3000 ) .Or. (nMes < 1 .Or. nMes > 12 )
			MsgAlert( OemToAnsi( STR0106 ) , OemToAnsi( STR0021 ) ) //"Aviso"###"Data Invalida! Verifique formato (AAAAMM)." 
			Return(.F.)
		EndIf
	EndIf  	
	
	//Forca o cadastro ser com dois digitos                                                                                        
	If Type("M->RFQ_NUMPAG") != "U"                                                                                
		If Len(AllTrim(M->RFQ_NUMPAG)) == 1
			M->RFQ_NUMPAG := StrZero(Val(M->RFQ_NUMPAG),2) 
		EndIf
	EndIf    
	
	RestArea(aArea)
EndIf	 

Return( .T. ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fVldPersel  ณ Autor ณNatie Sugahara      ณ Data ณ  11/20/07   บฑฑ 
ฑฑฬออออออออออุอออออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Nao permite selecionar periodo sem que o  periodo anterior    บฑฑ 
ฑฑบ          ณ esteja fechado.                                               บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ X3_VALID - RCH_PERSEL				                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Function fVldPerSel()    
Local aArea			:= GetArea()
Local aAcolsRCH		:= {}
Local lRet			:= .T. 
Local lChTudOk		:= .F. // Indica chamada pela funcao Gp400TudoOk
Local cConteudo	  	:= ""
Local nPos			:= 0 
Local nPosDtFech	:= 0 
Local nPosPerSel 	:= 0  
Local nPosAtu       := 0       
Local nPosFolCpl	:= 0
Local cRotFol		:= fGetRotOrdinar()
Local nPosRecno		:= 0
Local nAtualRecno   := 0

If ( Type("oGetRCH") == "O" ) .And. SuperGetMv( "MV_SIGAGFP",.F.,"1" ) <> "2"
	cConteudo	:= &(ReadVar()) 
	aAcolsRCH	:= oGetRCH:aCols	  
	
	If cConteudo  == "1" // 1= Periodo selecionado
	
		nPosDtFech	:= GdFieldPos("RCH_DTFECH" ,oGetRCH:aHeader) 
		nPosRoteir	:= GdFieldPos("RCH_ROTEIR" ,oGetRCH:aHeader)
		nPosRecno	:= GdFieldPos("RCH_REC_WT" ,oGetRCH:aHeader)
		nPosNumPag	:= GdFieldPos("RCH_NUMPAG" ,oGetRCh:aHeader)
		nPosAtu		:= oGetRCh:nAt

		If cPaisLoc $ "MEX|RUS"
			nPosPerSel	:= GdFieldPos("RCH_PERSEL" ,oGetRCh:aHeader)
		EndIf
		
		If !(cPaisLoc $ "MEX|RUS")
			nPosFolCpl	:= GdFieldPos("RCH_COMPL" ,oGetRCH:aHeader)
		EndIf

		If lPerMod2 //Validacao para o cadastro modelo 2 simplificado
			nPosPerSel	:= GdFieldPos("RCH_PERSEL" ,oGetRCh:aHeader)
			If !Empty(aAcolsRCH[nPosAtu, nPosDTFech] ) 
				MsgAlert( OemToAnsi( STR0047 ) , OemToAnsi( STR0021 ) ) 				//--"Este periodo ja foi encerrado e nao sera possivel a manutencao deste campo" 
				lRet:= .F. 
			ElseIf (nPos:= ( ascan( aAcolsRCH,{|x| x[nPosPerSel] = "1" } ) ) ) > 0 .and.  ; 
					nPos <> nPosAtu 
				MsgAlert( OemToAnsi( STR0050 ) , OemToAnsi( STR0021 ) ) 				//--"Ja existe um periodo selecionado. Favor efetuar o seu fechamento antes de selecionar outro periodo" 
				lRet:= .F. 
			Endif 

		Else
			cRoteiro	:= If(!lGp490, aAcolsRCH[nPosAtu, nPosRoteir], cRoteiro)
			nAtualRecno :=  aAcolsRCH[nPosAtu, nPosRecno]
	
			// VALIDACAO FASE 1 - Verifica se existe outro roteiro selecionado			
			dbSelectArea("RCH")
			RCH->(dbSetOrder(RetOrdem("RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PERSEL")))
			cConteudo := xFilial("RCH",cFilRFQ)+cProcesso+cRoteiro+"1"
			If RCH->(MsSeek(cConteudo)) .and. RCH->(RECNO()) <> nAtualRecno
				lRet := .T.                                                
				// Se o periodo ja estiver fechado, nao sera permitido selecionalo
				If !(RCH->(EoF())) .And. !Empty(aAcolsRCH[nPosAtu, nPosDTFech] )  
					MsgAlert( OemToAnsi( STR0047 ) , OemToAnsi( STR0021 ) )	// "Aviso"###"Este periodo ja foi encerrado e nao sera possivel a manutencao deste campo." 
					lRet:= .F.                                                                              
				Else
					If cPaisLoc $ "MEX|RUS"
						If ( nPos := ( aScan( aAcolsRCH,{|x| x[nPosPerSel] == "1" } ) ) ) > 0 .AND. nPos <> nPosAtu
							MsgAlert( OemToAnsi( STR0050 ) , OemToAnsi( STR0021 ) ) // "Aviso"###"Ja existe um periodo selecionado. Favor efetuar o seu fechamento antes de selecionar outro periodo."  				//--"Ja existe um periodo selecionado. Favor efetuar o seu fechamento antes de selecionar outro periodo" 
							lRet:= .F.
						EndIf
					Else
						If !(aAcolsRCH[nPosAtu, nPosFolCpl] == "1")  // Nao for complementar                           
							// Caso ja exista um outro periodo selecionado no mesmo 
							// (Processo + Roteiro), exibe a mensagem e nega a validacao
							If AllTrim(cRoteiro) == AllTrim(cRotFol)
								lRet := fChkFolCpl("1","","",nAtualRecno)
							Else						
								MsgAlert( OemToAnsi( STR0050 ) , OemToAnsi( STR0021 ) )// "Aviso"###"Ja existe um periodo selecionado. Favor efetuar o seu fechamento antes de selecionar outro periodo." 
						        lRet := .F.
							EndIf						
						EndIf
					EndIf								
				EndIf
			Else
				// VALIDACAO FASE 2 - Nao permite ativacao da Folha quando Folha Complementar for calculada
				lRet	:= If( AllTrim(cRoteiro) == AllTrim(cRotFol), fChkFolCpl("1","","", nAtualRecno), .T.) 
			EndIf
		EndIf 			 
	Else
		lRet := .T.
	EndIf 
	
EndIf     

RestArea(aArea)

Return( lRet )    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fChkFolCpl  ณ Autor ณRaquel Hager        ณ Data ณ  31/03/14   บฑฑ 
ฑฑฬออออออออออุอออออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica se e permitido ativar roteiro de Folha = somente se  บฑฑ 
ฑฑบ          ณ complementar nao tiver sido calculada.                        บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400								                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Static Function fChkFolCpl(cTipo,cRotCpl,cPerCpl, nAtualRecno)  
Local aArea		:= GetArea()   
Local cConteudo	:= ""  
Local cRotFol	:= fGetRotOrdinar()
Local lRet		:= .T.
    
  
    // Verifica se existe calculo de complementar
	If cTipo == "1"
		dbSelectArea("RCH")
		RCH->(dbSetOrder(RetOrdem("RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PERSEL")))	
		If RCH->(dbSeek(xFilial("RCH",cFilRFQ)+cProcesso+cRotFol+"1"))   
			If RCH->RCH_COMPL == "1" // Complementar e Selecionado   
				// Busca se foi realizado calculo 
				dbSelectArea("SRC")     
				SRC->(dbSetOrder(RetORdem("SRC", "RC_FILIAL+RC_PROCES+RC_PERIODO+RC_SEMANA+RC_ROTEIR+RC_CC+RC_MAT")))
				If SRC->(dbSeek(xFilial("SRC")+cProcesso+RCH->RCH_PER+RCH->RCH_NUMPAG+cRotFol))
					// Encontrou calculo
					lRet	:= .F. 
					MsgAlert( OemToAnsi( STR0126 ) , OemToAnsi( STR0021 ) )// "Aviso"###"Nao e permitido Ativar(re) o roteiro de Folha de Pagamento uma vez que a complementar tenha sido calculada! Exclua o calculo para Ativar(re)."
				EndIf 
				SRC->(dbCloseArea())	
			ElseIf RCH->(RECNO()) <> nAtualRecno
				lRet	:= .F.
				MsgAlert( OemToAnsi( STR0050 ) , OemToAnsi( STR0021 ) )// "Aviso	Ja existe um periodo selecionado. Favor efetuar o seu fechamento antes de selecionar outro periodo."		 						
			EndIf	 
		EndIf 
		RCH->(dbCloseArea()) 
	// Desativa roteiro de Folha ao ativar complementar de folha 
	ElseIf cTipo == "2"   
		cConteudo	:= xFilial("RCH",cFilRFQ)+cProcesso+cRotCpl+cPerCpl
		dbSelectArea("RCH")
		RCH->(dbSetOrder(RetOrdem("RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG")))	
		If RCH->(dbSeek(xFilial("RCH",cFilRFQ)+cProcesso+cRotCpl+cPerCpl))  				
			While (cConteudo == xFilial("RCH",cFilRFQ)+RCH->RCH_PROCES+RCH->RCH_ROTEIR+RCH->RCH_PER) .And. !(RCH->(Eof())) 
				If RCH->RCH_PERSEL == "1" .And. ( RCH->RCH_COMPL == "2" .Or. RCH->RCH_COMPL == " ")                               
					RecLock("RCH",.F.,.T.)
					RCH->RCH_PERSEL := "2"
					RCH->( MsUnlock() )
					Exit	 			
				EndIf  					
				RCH->(dbSkip())
			End While
		EndIf 
		RCH->(dbCloseArea())	 
	// Desativa roteiro complementar ao ativar Folha/2 Parcela 13 Salario 
	ElseIf cTipo == "3"      	
		cConteudo	:= xFilial("RCH",cFilRFQ)+cProcesso+cRotCpl+cPerCpl
		dbSelectArea("RCH")
		RCH->(dbSetOrder(RetOrdem("RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG")))	
		If RCH->(dbSeek(xFilial("RCH",cFilRFQ)+cProcesso+cRotCpl+cPerCpl))  				
			While (cConteudo == xFilial("RCH",cFilRFQ)+RCH->RCH_PROCES+RCH->RCH_ROTEIR+RCH->RCH_PER) .And. !(RCH->(Eof())) 
				If RCH->RCH_PERSEL == "1" .And. RCH->RCH_COMPL == "1"                           
					RecLock("RCH",.F.,.T.)
					RCH->RCH_PERSEL := "2"
					RCH->( MsUnlock() ) 
					Exit	 			
				EndIf  					
				RCH->(dbSkip())
			End While
		EndIf  
		RCH->(dbCloseArea()) 	  	
	EndIf
	
	RestArea(aArea)

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออัอออออออัออออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ Gpea400AllTrf  ณ Autor ณ Mauricio T. Takakura ณ Data ณ  13/07/07   บฑฑ  
ฑฑบCopia de  ณ Gpea250AllTrf  ณ Autor ณ Marinaldo de Jesus   ณ Data ณ  06/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออฯอออออออฯออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Transfere Informacoes do aColsRCG para o aRCGColsAll.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Usada na funcao GPA400MANU.                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Function Gpea400AllTrf(	cAlias			,;	//01 -> Alias do Arquivo
						oGetRCF 		,;	//02 -> Objeto GetDados para o RCF
						aCols			,;	//03 -> aCols utilizado na GetDados
						aHeader 		,;	//04 -> aHeader utilizado na GetDados
						lDeleted		,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
						lTransf2All		,;	//08 -> Se transfere do aCols para o aColsAll
						lTransf2Cols     ;	//09 -> Se transfere do aColsAll para o aCols
					  )  
Local aArea				:= GetArea()
Local aPosSortAll		:= {}				// Array com a posicao do filtro 
Local aPosKeyAll		:= {}				// Array com as chaves de busca
Local aRCGAux			:= {}				// Array auxiliar para separar registros deletados
Local cSeq  			:= ""				// Sequencia
Local cTnoTra			:= ""				// Turno de Trabalho
Local dRCG_DiaMes		:= CtoD('//')		// Data de RCG
Local nPosFilial		:= 0 				// Posicao da filial no aHeader
Local nPosProces		:= 0				// Posicao do processo
Local nPosSeq			:= 0				// Posicao da sequencia
Local nPosTnoTra		:= 0				// Posicao do turno de trabalho
Local nPosDiaMes		:= 0				// Posicao do dia/mes
Local nPosDeleted		:= 0				// Posicao do campo deletado no aCols
Local nContVetor 		:= 0				// Contador para novo vetor do RCG
Local nX				:= 0				// Variavel utilizada para while/for
Local nPosDesDia		:= 0

DEFAULT lTransf2All		:= .T.
DEFAULT lTransf2Cols	:= .T.

	nPosFilial	:= GdFieldPos( "RCG_FILIAL"	, aRCGAllHeader )
	nPosProces  := GdFieldPos( "RCG_PROCES"	, aRCGAllHeader )
	nPosSeq		:= GdFieldPos( "RCG_SEQ"	, aRCGAllHeader )
	nPosTnoTra  := GdFieldPos( "RCG_TNOTRA" , aRCGAllHeader )
	nPosDiaMes  := GdFieldPos( "RCG_DIAMES" , aRCGAllHeader )
	nPosDesDia  := GdFieldPos( "RCG_DESDIA" , aRCGHeader )
	
	// Carrega Array a Posicao dos Campos para o "Sort"			  
	/*
	aAdd( aPosSortAll	, nPosFilial )
	aAdd( aPosSortAll	, nPosProces )
	
	If ( nPosSeq ) > 0
		aAdd( aPosSortAll , nPosSeq  )
	EndIf
	aAdd( aPosSortAll	, nPosTnoTra )
	aAdd( aPosSortAll   , nPosDiaMes )
	*/
	// Carrega Array com a Posicao dos Campos e as Chaves correspondentes
	aAdd( aPosKeyAll  	, { nPosFilial	, cFilRFQ 	    } )
	aAdd( aPosKeyAll  	, { nPosProces	, cProcesso	} )
	If ( nPosSeq > 0 )
		cSeq	:= GdFieldGet( "RCF_SEQ" , oGetRCF:nAt , .F. , oGetRCF:aHeader , oGetDados:aCols )
		aAdd( aPosKeyAll , { nPosSeq , cSeq } )
	EndIf
   	
   	cTnoTra := GdFieldGet( "RCF_TNOTRA" , oGetRCF:nAt , .F. , oGetRCF:aHeader , oGetRCF:aCols )  
    cTnoTra := If( Empty(cTnoTra) ,cGp400VldT, cTnoTra) 

	aAdd( aPosKeyAll  	, { nPosTnoTra	, cTnoTra } )	
	
	// Monta a chave para busca no aColsAll e Transferencia para o respectivo aCols
	If ( nPosSeq > 0 ) 
		cKeyRCG := ( cFilRFQ + cProcesso + cSeq + cTnoTra ) 
	Else 
		cKeyRCG := ( cFilRFQ + cProcesso + cTnoTra ) 
	EndIf 
		
	// Transfere os Dados Entre aCols, inclusive deletados 	  	  
	GdTransfaCols(	@aRCGColsAll   	,;	//01 -> Array com a Estrutura do aCols Contendo todos os Dados
					@aCols			,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
					aHeader			,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
					Nil				,;	//04 -> Array com as Posicoes dos Campos para Pesquisa
					cKeyRCG			,;	//05 -> Chave para Busca
					aPosSortAll		,;	//06 -> Array com as Posicoes dos Campos para Ordenacao
					aPosKeyAll		,;	//07 -> Array com as Posicoes dos Campos e Chaves para Pesquisa
					aRCGAllHeader	,;	//08 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
					lDeleted		,;	//09 -> Se Carrega o Elemento como Deletado na Remontagem do aCols
					lTransf2All		,;	//10 -> Se deve Transferir do aCols para o aColsAll
					lTransf2Cols    ,;	//11 -> Se deve Transferir do aColsAll para o aCols
					.T.				,;	//12 -> Se Existe o Elemento de Delecao no aCols
					.T.				,;	//13 -> Se deve Carregar os Inicializadores padroes
					Nil				,;	//14 -> Lado para o Inicializador padrao
					.F.				 ;	//15 -> Se deve criar variais Publicas
	 			  )						//funcao em PONXFUN.PRX
	
	// Excluir os registros deletados do aCols - nao visualizados pelo usuario (apenas gravacao) 
	nPosDeleted  := Len(aHeader)+1  		// Posicao do campo deletado
	nContVetor	 := 1						// Contador para inclusao de novo vetor
	For nX := 1 To Len(aCols)
		dRCG_DiaMes := GdFieldGet( "RCG_DIAMES" , nX , .F. , aRCGHeader , aCols )
		If 	(!(aCols[nX, nPosDeleted])) .Or.;
			(aCols[nX, nPosDeleted] .And. (dRCG_DiaMes >= dRFQDtIni .And. dRCG_DiaMes <= dRFQDtFim ))
			If nPosDesDia > 0
				aCols[nX,nPosDesDia] := If( Empty(dRCG_DiaMes),dRCG_DiaMes,GPEDiaSem(dRCG_DiaMes) )
			EndIf
			aAdd(aRCGAux)
			aRCGAux[nContVetor] := aClone(aCols[nX])
			nContVetor+=1
		EndIf
	Next nX
	If Empty(aRCGAux) 
		aRCGAux := GdRmkaCols( aHeader , lDeleted , .T., .T. , Nil , .F. )  
	EndIf
	aCols := aClone(aRCGAux)  

	RestArea(aArea)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออัอออออออัออออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ Gpea400AmbPrep ณ Autor ณ Mauricio T. Takakura ณ Data ณ  11/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออออฯอออออออฯออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta aCols e aHeader de RCF e RCG.		                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Usada na funcao GPA400MANU.                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Function Gpea400AmbPrep(	nOpc,;			// Opcao selecionada pelo usuario
							aRCFNotFields,;	// Campos que nao serao apresentados RCF
							aRCFVirtGd,;	// Vetor com os campos virtuais
							aRCFVisualGD,;	// Vetor com os campos visuais
							aRCFSvCols,; 	// Vetor com a copia da aRCFCols para verificar se houve alteracoes
							nRCFUsado,;		// Numero de campos usados RCF
							aRCGSvCols,;	// Clone da Cols do RCG
							aRCGVirtGd,;	// Campos Virtuais
							aRCGVisualGd,;	// Campos visuais
							aRCGNotFields,;	// Campos que nao serao apresentados
							aRCGColsRec,;	// Recnos dos registros 
							aRCGNotAlter,;	// Campos nao alteraveis
							aRCGAltera;		// Campos alteraveis	
							)
							
Local aArea			:= GetArea()
Local aQueryRCFCond	:= {}		 	// Vetor com as condicoes para o TOP
Local aQueryRCGCond	:= {}			// Vetor com as condicoes para o TOP
Local bSortRCF		:= { ||Nil } 	// Bloco para ordenar a RCF
Local cKey			:= ''		 	// Chave principal para localizacao nas tabelas filhas - ( RFQ_FILIAL + RFQ_PROCES + RFQ_PERIOD )
Local cSortKey		:= ''		 	// Chave para filtrar a GetDados RCF 
Local cKeySeek		:= ''		 	// Chave de busca em RCF
Local dData			:= CtoD('//') 	// Data para localizacao da descricao 
Local nRCGUsa		:= 0.00   	 	// Variavel que retorna a quantidade de campos da tabela
Local nX			:= 0			// Variavel utilizado para while/for
Local nCpo			:= 0			// Variavel utilizado para while/for
Local nPosDiaMes	:= 0			// Posicao do dia/Mes no vetor
Local nPosDesDia	:= 0			// Posicao da descricao no vetor
Local nPosRCF_TnoTra:= 0			// Posicao do turno de trabalho em RCF 
Local nPosRCFEd		:= 0			// Posicao do campo a ser editado na RCF
Local cModuloPer	:= If( cModulo $ "GPE*GFP"," IN ('GPE','GFP')","='"+cModulo+"'" ) 
	
	// Monta os Dados para a GetDados do RCF						   
	// Campos que nao serao visualizados - private em GPA400MANU (local) 
	aAdd( aRCFNotFields , "RCF_FILIAL"  )
	aAdd( aRCFNotFields , "RCF_PER"     )
	aAdd( aRCFNotFields , "RCF_PROCES"  )
	aAdd( aRCFNotFields , "RCF_ROTEIR"  )
	aAdd( aRCFNotFields , "RCF_SEMANA"  )
	aAdd( aRCFNotFields , "RCF_DTINI"  )
	aAdd( aRCFNotFields , "RCF_DTFIM"  )
	aAdd( aRCFNotFields , "RCF_MODULO"  )
	
	// Monta Query para a Selecao das Informacoes em GdMontaCols   
	aQueryRCFCond	:= Array( 19 )
	aQueryRCFCond[01] := "RCF_FILIAL='"+cFilRFQ+"'"
	aQueryRCFCond[02] := " AND "
	aQueryRCFCond[03] := "RCF_PROCES='"+cProcesso+"'"
	aQueryRCFCond[04] := " AND "
	aQueryRCFCond[05] := "RCF_PER='"+cPeriodo+"'"
	aQueryRCFCond[06] := " AND "
	aQueryRCFCond[07] := "RCF_SEMANA='"+cNumPag+"'"
	aQueryRCFCond[08] := " AND "    
	aQueryRCFCond[09] := "RCF_ANO='"+cAno+"'"    
	aQueryRCFCond[10] := " AND "     
	aQueryRCFCond[11] := "RCF_MES='"+cMes+"'" 
	aQueryRCFCond[12] := " AND "
	aQueryRCFCond[13] := "RCF_DTINI='"+DtoS(dRFQDtIni)+"'"
	aQueryRCFCond[14] := " AND "
	aQueryRCFCond[15] := "RCF_DTFIM='"+DtoS(dRFQDtFim)+"'"
	aQueryRCFCond[16] := " AND "
	aQueryRCFCond[17] := "RCF_MODULO" + cModuloPer
	aQueryRCFCond[18] := " AND "
	aQueryRCFCond[19] := "D_E_L_E_T_=' ' " 
	
	// Chave a ser utilizada tanto no carregamento da RCF e da RCG
	cKey	 := cFilRFQ + cPeriodo + cNumPag + cAno + cMes + cProcesso + DtoS(dRFQDtIni) +  DtoS(dRFQDtFim) + cModulo
	DbSelectArea( "RCF" ) 
	DbSetOrder( RetOrder( "RCF", "RCF_FILIAL+RCF_PER+RCF_SEMANA+RCF_ANO+RCF_MES+RCF_PROCES+DTOS(RCF_DTINI)+DTOS(RCF_DTFIM)+RCF_MODULO" ) ) 
	aRCFCols := RCF->( GdMontaCols(@aRCFHeader,;  		// 01 -> Array com os Campos do Cabecalho da GetDados 
									@nRCFUsado,;		// 02 -> Numero de Campos em Uso 
									@aRCFVirtGd,;		// 03 -> [@]Array com os Campos Virtuais 
									@aRCFVisualGd,;		// 04 -> [@]Array com os Campos Visuais 
									"RCF",;				// 05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols 
									@aRCFNotFields,;	// 06 -> Opcional, Campos que nao Deverao constar no aHeader 
									@aRCFColsRec,;		// 07 -> [@]Array unidimensional contendo os Recnos 
									"RCH",;				// 08 -> Alias do Arquivo Pai 
									cKey,;				// 09 -> Chave para o Posicionamento no Alias Filho 
									Nil,;				// 10 -> Bloco para condicao de Loop While 
									Nil,;				// 11 -> Bloco para Skip no Loop While 
									Nil,;				// 12 -> Se Havera o Elemento de Delecao no aCols  
									Nil,;				// 13 -> Se cria variaveis Publicas 
									Nil,;				// 14 -> Se Sera considerado o Inicializador Padrao 
									Nil,;				// 15 -> Lado para o inicializador padrao 
									Nil,;				// 16 -> Opcional, Carregar Todos os Campos 
									Nil,;				// 17 -> Opcional, Nao Carregar os Campos Virtuais 
									aQueryRCFCond,;		// 18 -> Opcional, Utilizacao de Query para Selecao de Dados 
									.F.,;				// 19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP ) - utilizado com o parametro 10 
									.F.,;				// 20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP ) - utilizado com o parametro 11
									.F.,;				// 21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
									Nil,;				// 22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
									Nil,;				// 23 -> Verifica se Deve Checar se o campo eh usado
									Nil,;				// 24 -> Verifica se Deve Checar o nivel do usuario
									Nil,;				// 25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
									Nil,;				// 26 -> [@]Array que contera as chaves conforme recnos
									Nil,;				// 27 -> [@]Se devera efetuar o Lock dos Registros
									Nil,;				// 28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
							        Nil,;				// 29 -> Numero maximo de Locks a ser efetuado
									.F.;				// 30 -> Utiliza Numeracao na GhostCol
								);
					   )							
	
	// Somente para Calendario Sintetico
	If cTpCalend == "2"  
		aRCFEdit := {"RCF_DIATRA", "RCF_HRSTRA", "RCF_DIADSR", "RCF_HRSDSR", "RCF_DNTRAB" , "RCF_DUTILT" ,;
		                  "RCF_DNUTIL", "RCF_DDIFVT", "RCF_DREFEI" , "RCF_DALIM" , "RCF_DUTEIS" }
		For nX := 1 to Len(aRCFEdit) 
			nPosRCFEd := aScan(aRCFHeader, {|x| x[2] == aRCFEdit[nX] })
			If nPosRCFEd > 0
				aRCFHeader[nPosRCFEd][__AHEADER_VISUAL__] := "A"
			EndIf			
		Next nX 
	EndIf  
	
	If cQtdeDPer == "2"  
		aRCFEdit := { "RCF_DCALCM" }
		For nX := 1 to Len(aRCFEdit) 
			nPosRCFEd := aScan(aRCFHeader, {|x| x[2] == aRCFEdit[nX] })
			If nPosRCFEd > 0
				aRCFHeader[nPosRCFEd][__AHEADER_VISUAL__] := "A"
			EndIf			
		Next nX 
	EndIf  
	
	nPosRCF_Tnotra := GdFieldPos( "RCF_TNOTRA", aRCFHeader )
	// Qdo for inclusao, o primeiro item devera conter o valor @@@ no Turno de Trabalho 
	If ( nOpc == 3 ) .Or. ( Empty( aRCFCols[1, nPosRCF_Tnotra] ) ) 
		If cPaisLoc == "RUS"
			aRCFCols[1, GdFieldPos( "RCF_HRSDIA", aRCFHeader )] := 8
		EndIf
		aRCFCols[1, nPosRCF_Tnotra] := "@@@"	// codigo generico para todos os turnos.
	EndIf   
		
	// Filtrar os lancamentos de RCF por Turno de Trabalho e Semana 
	cSortKey := 'X['+Str(nPosRCF_TnoTra)+'] < Y[' +Str(nPosRCF_TnoTra)+']'
	bSortRCF := &("{|X,Y|" + cSortKey + "}")	
	aSort( aRCFCols , Nil , Nil , bSortRCF )
	aRCFSvCols	:= aClone( aRCFCols )	// Copia para verificar se houve alteracao
	// Monta a GetDados do RCG						   			   
	// Campos que nao serao visualizados na getdados 
	aAdd( aRCGNotFields , "RCG_FILIAL"  )
	aAdd( aRCGNotFields , "RCG_TNOTRA"  )
	aAdd( aRCGNotFields , "RCG_PER"     )
	aAdd( aRCGNotFields , "RCG_SEMANA"  )	
	aAdd( aRCGNotFields , "RCG_PROCES"  )
	aAdd( aRCGNotFields , "RCG_ROTEIR"  )
	aAdd( aRCGNotFields , "RCG_MES"     )
	aAdd( aRCGNotFields , "RCG_ANO"     )   
	aAdd( aRCFNotFields , "RCG_DTINI"  )
	aAdd( aRCFNotFields , "RCG_DTFIM"  )
   	aAdd( aRCFNotFields , "RCG_MODULO"  )
	
	// Monta Query para a Selecao das Informacoes em GdMontaCols    
	aQueryRCGCond	:= Array( 19 )
	aQueryRCGCond[01] := "RCG_FILIAL='"+cFilRFQ+"'"
	aQueryRCGCond[02] := " AND "
	aQueryRCGCond[03] := "RCG_PROCES='"+cProcesso+"'"
	aQueryRCGCond[04] := " AND "
	aQueryRCGCond[05] := "RCG_PER='"+cPeriodo+"'"
	aQueryRCGCond[06] := " AND "
	aQueryRCGCond[07] := "RCG_SEMANA='"+cNumPag+"'"  
	aQueryRCGCond[08] := " AND "    
	aQueryRCGCond[09] := "RCG_ANO='"+cAno+"'"    
	aQueryRCGCond[10] := " AND "     
	aQueryRCGCond[11] := "RCG_MES='"+cMes+"'" 
	aQueryRCGCond[12] := " AND "      
	aQueryRCGCond[13] := "RCG_DTINI='"+DtoS(dRFQDtIni)+"'"
	aQueryRCGCond[14] := " AND "
	aQueryRCGCond[15] := "RCG_DTFIM='"+DtoS(dRFQDtFim)+"'"
	aQueryRCGCond[16] := " AND "
	aQueryRCGCond[17] := "RCG_MODULO" + cModuloPer
	aQueryRCGCond[18] := " AND "
	aQueryRCGCond[19] := "D_E_L_E_T_=' ' "
				
	// Seleciona a Ordem para a Obtencao dos Dados                  
	DbSelectArea( "RCG" )
	RCG->( dbSetOrder( RetOrdem( "RCG" , "RCG_FILIAL+RCG_PER+RCG_ANO+RCG_MES+RCG_SEMANA+RCG_PROCES+RCG_ROTEIR+RCG_TNOTRA+DTOS(RCG_DIAMES)+DTOS(RCG_DTINI)+DTOS(RCG_DTFIM)+RCG_MODULO" ) ) )
	RCG->(dbSeek(cFilRFQ + cPeriodo + cAno + cMes + cNumPag + cProcesso + Space( Len( RCH->RCH_ROTEIR ))))
	cKey := cFilRFQ + cPeriodo + cAno + cMes + cNumPag + cProcesso + Space( Len( RCH->RCH_ROTEIR ) ) 

	aRCGColsAll := GdMontaCols( ;
									@aRCGAllHeader,;	//01 -> Array com os Campos do Cabecalho da GetDados
					   	 			@nRCGUsa,;			//02 -> Numero de Campos em Uso
					 				@aRCGVirtGd,;		//03 -> [@]Array com os Campos Virtuais
					 				@aRCGVisualGd,;		//04 -> [@]Array com os Campos Visuais
					 				"RCG",;				//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
					 				Nil,;				//06 -> Opcional, Campos que nao Deverao constar no aHeader
					 				@aRCGColsRec,;		//07 -> [@]Array unidimensional contendo os Recnos
	  								"RCG",;				//08 -> Alias do Arquivo Pai
	  				 				cKey,;				//09 -> Chave para o Posicionamento no Alias Filho
	  				 				Nil,;				//10 -> Bloco para condicao de Loop While
		  			 				Nil,;				//11 -> Bloco para Skip no Loop While
		  			 				.T.,;				//12 -> Se Havera o Elemento de Delecao no aCols
		  			 				Nil,;				//13 -> Se cria variaveis Publicas
		  			 				nOpc==3,;			//14 -> Se Sera considerado o Inicializador Padrao
		  			 				Nil,;				//15 -> Lado para o inicializador padrao
		  			 				.T.,;				//16 -> Opcional, Carregar Todos os Campos
		  			 				Nil,;				//17 -> Opcional, Nao Carregar os Campos Virtuais
					 				aQueryRCGCond,;		//18 -> Opcional, Utilizacao de Query para Selecao de Dados
					 				.F.,;				//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
					 				.F.,;				//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
					 				.F.,;				//21 -> Carregar Coluna Fantasma
									Nil,;				//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
									Nil,;				//23 -> Verifica se Deve Checar se o campo eh usado
									Nil,;				//24 -> Verifica se Deve Checar o nivel do usuario
									Nil,;				//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
									Nil,;				//26 -> [@]Array que contera as chaves conforme recnos
									Nil,;				//27 -> [@]Se devera efetuar o Lock dos Registros
									Nil,;				//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
							        Nil,;				//29 -> Numero maximo de Locks a ser efetuado
									.F.;				//30 -> Utiliza Numeracao na GhostCol
					 			)					
	
	If nOpc <> 3 
		nPosDiaMes	:=	GdFieldPos( "RCG_DIAMES" ,aRCGAllHeader )
		nPosDesDia	:=	GdFieldPos( "RCG_DESDIA" ,aRCGAllHeader )
		If nPosDiaMes > 0 .And. nPosDesDia > 0
			For nX := 1 To Len( aRCGColsAll )
				dData	:= aRCGColsAll[nX,nPosDiaMes]    
				If !Empty(dData)
					aRCGColsAll[ nX , nPosDesDia] := GPEDiaSem(dData) 
				EndIf
			Next nX 
		EndIf
	EndIf
	// Montar o aHeader para Uso e Definir os Campos Editaveis 	
	If Empty(aRCGHeader)  
		For nCpo := 1 To nRCGUsa 
			If (;
					( aScan( aRCGVirtGd		, aRCGAllHeader[ nCpo , 02 ] ) == 0 ) .And. ;
			   		( aScan( aRCGVisualGd	, aRCGAllHeader[ nCpo , 02 ] ) == 0 ) .And. ;
					( aScan( aRCGNotAlter	, aRCGAllHeader[ nCpo , 02 ] ) == 0 ) .And. ;
					( X3Uso(aRCGAllHeader[ nCpo, 7] ) )									; // Verifica se o campo e usado ou nao
			  	)
				aAdd( aRCGAltera , aRCGAllHeader[ nCpo , 02 ] )
			EndIf
			
			If ( aScan( aRCGNotFields , aRCGAllHeader[ nCpo , 02 ] ) == 0 ) .And. ( If ( aRCGAllHeader[ nCpo , 02 ] $ "GHOSTCOL_COLBMP*RCG_REC_WT", .T., X3Uso(aRCGAllHeader[ nCpo, 7] ) ) ) 
		       	aAdd( aRCGHeader , aClone( aRCGAllHeader[ nCpo ] ) )
			EndIf	
		Next nCpo 
	EndIf
	aRCGSvCols	:= aClone( aRCGColsAll )	// Copia para verificar se houve alteracao 	
	
	// Usuario possui registros gravados quando cTpCalend = 2 (Sintetico)
	// e agora quer usar o analitico = calcular calendario com base
	// na tabela RCF        
   	nPosDiaMes	:=	GdFieldPos( "RCG_DIAMES" ,aRCGAllHeader )
	If nPosDiaMes > 0 .And. nOpc == 4 .And. cTpCalend == "1"
		If Empty(aRCGColsAll[1][nPosDiaMes])
			lParamChRec := .T.
		EndIf
	EndIf    
	RestArea(aArea)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออัอออออออัออออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ CalcCalendar   ณ Autor ณ Mauricio T. Takakura ณ Data ณ  22/07/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออออฯอออออออฯออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Calculo para a geracao do calendario.              				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Usada na funcao GPA400MANU.                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Function CalcCalendar(	oObject			,;	// Objeto que realizou a chamada 
						aRCGNotFields	,;	// Campos nao visuais - RCG
						aRCFCcpoKey		,;	// Campos Chaves de RCF
	   					nRCGUsado		,;	// Numero de campos usados - RCG
						nOpc			 ;	// Opcao selecionado no menu
						)       
Local aArea			:= GetArea()
Local aCposKey		:= { "RCG_DIAMES" }	// Array com campos chaves para verificar se esta vazio a GetDados
Local lNaoVazio		:= .T.				// Getdados nao esta vazio
Local lRCFNaoVazio	:= .T.				// Getdados nao esta vazio
Local lRet			:= .T.				// Controle de Retorno
Local lProcAll		:= .F.				// Processa todos os registros  
Local lFocusRCG		:= .F.				// Foco pertence ao RCG
Local nAt			:= 0				// Posicao do registro no banco 
Local nX 			:= 0
Local nY			:= 0

	Begin Sequence
	
		// Recalculo de registros gravados em tipo Sintetico
		// Apaga registros gravados para apenas gravacao de Turno Padrao - "@@@"
		If lParamChRec .And. lRecalc
			// Utiliza aColsRCF gerado em branco
		   fAlterRCF(1,nOpc)		
		ElseIf Len(oGetDados:aCols) <= 1 // Caso RCF nao tenha registros, abortar carga do Calendario
			lRCFNaoVazio := GdNoEmpty( aRCFCcpoKey, 1, aRCFHeader, oGetDados:aCols, Nil, Nil, .F. )
			If !lRCFNaoVazio
			 	Break
			EndIf
		EndIf
	   
		// Chamada realizada pelo GetDados do RCG
		If fCompArray(aRCGHeader, oObject:aHeader)
			// Para gerar o calendario no cadastro individual do registro
			// Se o RCG estiver vazio continua o processo 
		   	lNaoVazio := GdNoEmpty( aCposKey, 1, aRCGHeader, oGetDadosRCG:aCols, Nil, Nil, .F. )
	    EndIf    
	    
		// Ao selecionar 'Incluir' as variaveis dRFQDtIni e dRFQDtFim estarao vazias			
		// Somente serao agregados valores a elas apos o calculo do calendario	
		If (dRFQDtIni == M->RFQ_DTINI .And. dRFQDtFim == M->RFQ_DTFIM) .Or.;
			(Empty(dRFQDtIni) .And. Empty(dRFQDtFim))  
	        If lNaoVazio 	// Quando o RCG estiver vazio, devera continuar a carga do calendario
		     	lRet := .F.
		   	EndIf 
	        If !lRet
				//Break
			EndIf
		Else
		   	lProcAll := .T.			
		EndIf   			
         
		// Validacao para recalculo de todos os registros 
		If lProcAll 	 
		 	MsAguarde({||CalendAll(	aRCGNotFields	,;	// Campos nao visuais - RCG		 	
								 	aRCFCcpoKey		,;	// Campos Chaves de RCF
								 	@nRCGUsado		 ;	// Numero de campos usados - RCG
						   		 )},;					
						OemToAnsi(STR0024),;			// "Montando Calendario"
						OemToAnsi(STR0026),;			// "Aguarde"
					)
		Else
		 	MsAguarde({||MontaCalend(aRCGNotFields	,;	// Campos nao visuais - RCG
									 aRCFCcpoKey	,;  // Campos Chaves de RCF
									 @nRCGUsado		 ;	// Numero de campos usados - RCG
						   			)},;				
							OemToAnsi(STR0024),;		// "Montando Calendario"
							OemToAnsi(STR0026),;		// "Aguarde"
					)
		EndIf
	 		
	End Sequence 
	
   	If !(lProcAll)
		// Calcula os valores de Dias Trab/DSR/V.T./V.F                
		fCalCDias()
   	EndIf   
   	
   	RestArea(aArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออัอออออออัออออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fAlterRCF      ณ Autor ณ Equipe RH		     ณ Data ณ  04/04/13   บฑฑ  
ฑฑฬออออออออออุออออออออออออออออฯอออออออฯออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera turno padrao e deleta registros.							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Usada na funcao CalcCalendar.                            บฑฑ
ฑฑบ          ณ GPEA490 - Usada na funcao GP490Grava.		                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Function fAlterRCF(nEtapa,nOpc) 
Local aArea 			:= GetArea()
Local cRCFFil			:= ""    
Local cRCGFil  			:= ""   
Local nPosRCF_Tnotra	:= 0  
Local nRCFUsado			:= 0   
Local aRCFVirtGd		:= {}   
Local aRCFVisualGd		:= {}
Local aRCFColsRec		:= {}
Local aRCFNotFields		:= {}
	
	// Criacao do Turno Padrao 
	// Chamada especifica do GPEA400   
	If nEtapa == 1  	 
		cKey := xFilial("RCF",cFilRFQ) + Space(Len(cPeriodo + cNumPag + cAno + cMes + cProcesso + DtoS(dRFQDtIni) + DtoS(dRFQDtFim))) + cModulo
		aRCFCols := RCF->( GdMontaCols(aRCFHeader,;  	// 01 -> Array com os Campos do Cabecalho da GetDados 
									nRCFUsado,;			// 02 -> Numero de Campos em Uso 
									aRCFVirtGd,;		// 03 -> [@]Array com os Campos Virtuais 
									aRCFVisualGd,;		// 04 -> [@]Array com os Campos Visuais 
									"RCF",;				// 05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols 
									aRCFNotFields,;		// 06 -> Opcional, Campos que nao Deverao constar no aHeader 
									aRCFColsRec,;		// 07 -> [@]Array unidimensional contendo os Recnos 
									"RCH",;				// 08 -> Alias do Arquivo Pai 
									cKey,;				// 09 -> Chave para o Posicionamento no Alias Filho 
									Nil,;				// 10 -> Bloco para condicao de Loop While 
									Nil,;				// 11 -> Bloco para Skip no Loop While 
									Nil,;				// 12 -> Se Havera o Elemento de Delecao no aCols  
									Nil,;				// 13 -> Se cria variaveis Publicas 
									Nil,;				// 14 -> Se Sera considerado o Inicializador Padrao 
									Nil,;				// 15 -> Lado para o inicializador padrao 
									Nil,;				// 16 -> Opcional, Carregar Todos os Campos 
									Nil,;				// 17 -> Opcional, Nao Carregar os Campos Virtuais 
									Nil,;				// 18 -> Opcional, Utilizacao de Query para Selecao de Dados 
									.F.,;				// 19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP ) - utilizado com o parametro 10 
									.F.,;				// 20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP ) - utilizado com o parametro 11
									.F.,;				// 21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
									Nil,;				// 22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
									Nil,;				// 23 -> Verifica se Deve Checar se o campo eh usado
									Nil,;				// 24 -> Verifica se Deve Checar o nivel do usuario
									Nil,;				// 25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
									Nil,;				// 26 -> [@]Array que contera as chaves conforme recnos
									Nil,;				// 27 -> [@]Se devera efetuar o Lock dos Registros
									Nil,;				// 28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
							        Nil,;				// 29 -> Numero maximo de Locks a ser efetuado
									.F.;				// 30 -> Utiliza Numeracao na GhostCol
								);
					   )
	
		// Conter o valor @@@ no Turno de Trabalho
		nPosRCF_Tnotra := GdFieldPos( "RCF_TNOTRA"	, aRCFHeader ) 
		aRCFCols[1, nPosRCF_Tnotra] := "@@@"	// Codigo generico para todos os turnos	
		
		oGetDados:aCols:= AClone(aRCFCols)	
		oGetDados:nAt:=Len(aRCFCols)      
		
	EndIf

	If nEtapa == 2
		// Excluir registros gravados
		Begin Sequence 
			Begin Transaction
		
				cRCFFil := xFilial("RCF", cFilRFQ)  
				If lGp490    
					cKey 	:= cRCFFil + cGp490Per + cGp490NPg + cGp490Ano + cGp490Mes + cProcesso + DtoS(cGp490DIn) + DtoS(cGp490DFi) + cModulo
				Else
					cKey 	:= cRCFFil + cPeriodo + cNumPag + cAno + cMes + cProcesso + DtoS(dRFQDtIni) + DtoS(dRFQDtFim) + cModulo
				EndIf
				// Exclusao dos registros RCF                                   
				DbSelectArea( "RCF" )
				DbSetOrder(RetOrdem("RCF","RCF_FILIAL+RCF_PER+RCF_SEMANA+RCF_ANO+RCF_MES+RCF_PROCES+DTOS(RCF_DTINI)+DTOS(RCF_DTFIM)+RCF_MODULO")) 
				RCF->( MsSeek( cKey , .F. ) )
				While RCF->( !EOF() ) .And. RCF->(RCF_FILIAL + RCF_PER + RCF_SEMANA + RCF_ANO + RCF_MES + RCF_PROCES + DTOS(RCF_DTINI) + DTOS(RCF_DTFIM) + RCF_MODULO) == cKey
					RecLock("RCF",.F.,.T.)
					dbDelete()
					MsUnlock()
					RCF->( DbSkip() )
				Enddo   
				cKey := ""			
							
				cRCGFil := xFilial("RCG", cFilRFQ)   
				If lGp490    
					cKey 	:= cRCGFil + cGp490Per + cGp490NPg + cGp490Ano + cGp490Mes + cProcesso + DtoS(cGp490DIn) + DtoS(cGp490DFi) + cModulo
				Else
					cKey 	:= cRCGFil + cPeriodo + cNumPag + cAno + cMes + cProcesso + DtoS(dRFQDtIni) + DtoS(dRFQDtFim) + cModulo
				EndIf
				// Exclusao dos registros RCG                                   
				DbSelectArea( "RCG" )
				DbSetOrder( RetOrdem("RCG","RCG_FILIAL+RCG_PER+RCG_SEMANA+RCG_ANO+RCG_MES+RCG_PROCES+DTOS(RCG_DTINI)+DTOS(RCG_DTFIM)+RCG_MODULO" ) )
				RCG->( MsSeek( cKey , .F. ) )
				While RCG->( !EOF() ) .And. RCG->( RCG_FILIAL + RCG_PER + RCG_SEMANA + RCG_ANO + RCG_MES + RCG_PROCES + DTOS(RCG_DTINI) + DTOS(RCG_DTFIM) + RCG_MODULO) == cKey
					RecLock("RCG",.F.,.T.)
					dbDelete()
					MsUnlock()
					RCG->( DbSkip() )
				Enddo
		         
			End Transaction  		
		End Sequence     
	EndIf
	
	RestArea(aArea)
							
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออัอออออออัออออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ MontaCalend    ณ Autor ณ Mauricio T. Takakura ณ Data ณ  01/08/04   บฑฑ  
ฑฑฬออออออออออุออออออออออออออออฯอออออออฯออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta o Calendario de acordo com as datas informadas na tabela RFQ.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Usada na funcao CalcCalendar.                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Static Function MontaCalend(	aRCGNotFields	,;	// Campos nao visuais - RCG
								aRCFCcpoKey		,;  // Contem os chaves de RCF
								nRCGUsado		 ;	// Numero de campos usados - RCG
							)
Local aArea			:= GetArea()
Local aRegAtual		:= {}						// Vetor do registro atual da RCF
Local aAuxRCG		:= {}						// Vetor utilizado para o controle de registros deletados
Local cKeySeek		:= ''						// Variavel com os campos chaves
Local cChave		:= ''						// Variavel com os valores dos campos chaves
Local cSeq			:= ''						// Valor do campo sequencial
Local cTnoTra		:= ''						// Valor do campo Turno de Trabalho
Local lRet			:= .T.						// Variavel de retorno
Local lNaoVazio		:= .T.						// Verifica se o registro esta vazio
Local nX		 	:= 0						// Variavel de controle for/while
Local nY		 	:= 0						// Variavel de controle for/while
Local nNaCols		:= 0						// Numero de aCols que esta sendo implementado
Local nNGetDadosRCG	:= 0						// Numero de registros no GetDados RCG
Local nPosAt		:= oGetDados:nAt			// Posicao do registro no vetor
Local nPosFilial	:= 0 						// Posicao da filial no aHeader
Local nPosProces	:= 0						// Posicao do processo
Local nPosPer 		:= 0						// Posicao do Periodo
Local nPosSeq		:= 0						// Posicao da sequencia
Local nPosSemana	:= 0						// Posicao da semana
Local nPosRoteiro	:= 0						// Posicao do roteiro
Local nPosTnoTra	:= 0						// Posicao do turno de trabalho
Local nPosData		:= 0						// Posicao do campo Dia/Mes RCG 
Local nValRec		:= 0
Local nPosRec		:= 0
Local nPosRCF_Ano	:= 0						// Posicao do ano em RCF

	nPosTnoTra  := GdFieldPos( "RCG_TNOTRA" , aRCGAllHeader )
	cTnoTra := GdFieldGet( "RCF_TNOTRA" , oGetDados:nAt , .F. , oGetDados:aHeader , oGetDados:aCols )

	Begin Sequence
	
		// Se existe a necessidade de recalcular os registros 
		aAdd(aRegAtuaL, oGetDados:aCols[oGetDados:nAt])
	   	lNaoVazio := GdNoEmpty( aRCFCcpoKey, 1, aRCFHeader, aRegAtual, Nil, Nil, .F. )
	   	If !lNaoVazio .And. Empty(GetMemVar("RCF_TNOTRA")) .Or. GdDeleted( oGetDados:nAt, aRCFHeader, oGetDados:aCols )
	   	  Break
	   	EndIf
	
		// Obrigatorio - verifica se todos os campos obrigatorios foram preenchidos
		If !( lRet := Obrigatorio( oEnchoice:aGets , oEnchoice:aTela ) )
			Break
		EndIf
	
		dRFQDtIni := GetMemVar("RFQ_DTINI") 
		dRFQDtFim := GetMemVar("RFQ_DTFIM")	

		nPosRCF_Ano := GdFieldPos( "RCF_ANO", oGetDados:aHeader ) // Hแ clientes que exibem este campo em tela para visualiza็ใo

		// Monta aCols com as informacoes do calendario
		If cTnoTra == "@@@" .Or. GetMemVar("RCF_TNOTRA") == "@@@"

			If nPosRCF_Ano > 0
				oGetDados:aCols[oGetDados:nAt, nPosRCF_Ano] := GetMemVar("RFQ_ANO")	// Preenchimento do Ano, pois hแ clientes que exibem este campo em tela para visualiza็ใo
			EndIf 
			
			aRCGCols	:= 	fNewAcols( 	"1"			 ,;				// Tipo da Geracao 
									aRCGNotFields,;				// Campos Visuais 
									@nRCGUsado,;				// Numero de campos usados - RCG
	 								dRFQDtIni,;					// Data inicial para preenchimento do RCG
	 								dRFQDtFim,;					// Data final para preenchimento do RCG
			 						GdFieldGet( "RCF_HRSDIA" , nPosAt , .F. , aRCFHeader , oGetDados:aCols ) ) // Horas dia
			 oGetDadosRCG:aCols := {}
	    Else
			
			aRCGCols	:= A491Turno(dRFQDtIni,dRFQDtFim,cGp400VldT,aRCGNotFields)
			
			oGetDados:aCols[oGetDados:nAt][1] := cGp400VldT
			oGetDadosRCG:aCols := {}	
		EndIf
		
   
		
		// Monta aCols com os dados de acordo com a competencia e periodo Desejado           
		nNGetDadosRCG	:= Len(oGetDadosRCG:aCols)
		nNaCols			:= Len(aRCGCols)
	
		// Excluir os registros que nao fazem mais parte do intervalo de datas 						 				
	 	For nX := 1 To nNGetDadosRCG
			oGetDadosRCG:aCols[nX,Len(oGetDadosRCG:aHeader)+1] := .T.
	 	Next nX
	 	
	 	// Atualizar os registros da GetDados RCG 
	 	For nX := 1 To nNaCols 	
		  aAdd(oGetDadosRCG:aCols, aRCGCols[nX])
	 	Next nX 	
		
		// Trocar a Chave dos registros excluidos e/ou retornar o Ghost para aCols           
		// Posicao dos campos chaves na matriz principal 
		nPosFilial	:= GdFieldPos( "RCG_FILIAL"	, aRCGAllHeader )	
		nPosProces  := GdFieldPos( "RCG_PROCES"	, aRCGAllHeader )
		nPosPer 	:= GdFieldPos( "RCG_PER"	, aRCGAllHeader )
		nPosSeq		:= GdFieldPos( "RCG_SEQ"	, aRCGAllHeader )
		nPosSemana	:= GdFieldPos( "RCG_SEMANA"	, aRCGAllHeader )
		nPosRoteiro := GdFieldPos( "RCG_ROTEIR" , aRCGAllHeader )
		nPosDiaMes  := GdFieldPos( "RCG_DIAMES" , aRCGAllHeader )
		nPosData	:= GdFieldPos( "RCG_DIAMES"	, aRCGHeader ) 	
		
		cKeySeek 	:= 'X['+Alltrim(str(nPosFilial,2,0))+']+X['+Alltrim(str(nPosProces,2,0))+;
						']+X['+Alltrim(str(nPosPer,2,0))+']'
		If (nPosSeq) > 0
			cKeySeek += '+X['+Alltrim(str(nPosSeq,2,0))+']'
		EndIf
		cKeySeek += '+X['+Alltrim(str(nPosSemana,2,0)) + ']+X['+Alltrim(str(nPosRoteiro,2,0))+;
					']+X['+Alltrim(str(nPosTnoTra,2,0)) + ']+dtos(X['+Alltrim(str(nPosDiaMes,2,0))+'])=='
					
		If ( nPosSeq > 0 )
			cSeq	:= GdFieldGet( "RCG_SEQ" , oGetDadosRCG:nAt , .F. , oGetDadosRCG:aHeader , oGetDadosRCG:aCols )
		EndIf
		
		
		// O caracter * foi utilizado como diferenciador da chave para os registros deletados
		If ( nPosSeq > 0 )
			cChave := ( cFilRFQ + GetMemVar("RFQ_PROCES") + GetMemVar("RFQ_PERIOD") + cSeq + GetMemVar("RFQ_NUMPAG") + '*' +cTnoTra )
		Else
			cChave := ( cFilRFQ + GetMemVar("RFQ_PROCES") + GetMemVar("RFQ_PERIOD") + GetMemVar("RFQ_NUMPAG") + '*' + cTnoTra )
		EndIf					
			
	 	For nX := 1 To Len(oGetDadosRCG:aCols)		

	 		If GdDeleted( nX, aRCGHeader, oGetDadosRCG:aCols ) .And. !Empty(GdFieldGet( "RCG_DIAMES" , nX , Nil , aRCGHeader, oGetDadosRCG:aCols ))
				bKeySearch	:= &("{|x|" + cKeySeek + '"' + StrTran(cChave, "*", "") + dtos(oGetDadosRCG:aCols[nX,nPosData]) + '"'+ "}")
				nKey := 0
		 		nPosAlt := aScan(aRCGColsAll, bKeySearch, ++nKey )
				aRCGColsAll[nPosAlt, Len(aRCGAllHeader)+1] := .T.
				aRCGColsAll[nPosAlt, nPosTnoTra] := '*'+aRCGColsAll[nPosAlt, nPosTnoTra]
			Else			
				bKeySearch	:= &("{|x|" + cKeySeek + '"' + cChave + dtos(oGetDadosRCG:aCols[nX,nPosData]) + '"'+ "}")
				nKey := 0
				nValRec := 0
				If ((nPosAlt := aScan(aRCGColsAll, bKeySearch, ++nKey )) > 0)
					nPosRec	:= GdFieldPos( "RCG_REC_WT"	, aRCGAllHeader )			
					nValRec := aRCGColsAll[nPosAlt, nPosRec]
				EndIf
			    aAdd(aAuxRCG, aClone(oGetDadosRCG:aCols[nX]))
				nPosRec 	:= GdFieldPos( "RCG_REC_WT"	, aRCGHeader )
				aAuxRCG[nX, nPosRec] := 0
			    If nValRec > 0
			    	aAuxRCG[nX, nPosRec] := nValRec
					aRCGColsAll[nPosAlt, nPosTnoTra] := Substr(aRCGColsAll[nPosAlt, nPosTnoTra],2,Len(aRCGColsAll[nPosAlt, nPosTnoTra])-1)  // Retirar o caracter * direnciador do registro deletado
			    EndIf
	 		EndIf
	 	Next nX 	
	 	oGetDadosRCG:aCols := aClone(aAuxRCG)
	
		// Atualizar o Getdados	
		Gpea400AllTrf(	"RCG" 			    ,;	// Alias do Arquivo
						oGetDados		    ,;	// Objeto GetDados para o RCF
						@oGetDadosRCG:aCols	,;	// aCols utilizado na GetDados
						aRCGHeader			,;	// aHeader
						.F.			    	,;	// Se carrega elemento de Deletado na remontagem do aCols
						.T.			    	,;	// Se transfere do aCols para o aColsAll	
						.T.				     ;	// Se transfere do aColsAll para o aCols
				      )							      
	
		oGetDadosRCG:oBrowse:nAt
		oGetDadosRCG:oBrowse:Refresh(.T.)
			   
	End Sequence 
	
	RestArea(aArea)
	
Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออัอออออออัออออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ CalendAll      ณ Autor ณ Mauricio T. Takakura ณ Data ณ  28/07/04   บฑฑ  
ฑฑฬออออออออออุออออออออออออออออฯอออออออฯออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Montar o calendario Dia-a-Dia.        	        				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 								                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Static Function CalendAll(	aRCGNotFields	,;	// Campos nao visuais - RCG		 	
							aRCFCcpoKey 	,;	// Campos Chaves de RCF
							nRCGUsado		 ;	// Numero de campos usados - RCG								 	
						 )						// Montar o Calendario Dia-a-Dia
Local aArea		:= GetArea()
Local aCposKey	:= {}			// Array com campos chaves para verificar se esta vazio a GetDados
Local dSvRCHIni	:= CtoD('//')	// Backup da variavel para processar os varios dias
Local dSvRCHFim	:= CtoD('//')	// Backup da variavel para processar os varios dias
Local nPosInicio:= 0			// Gravar a posicao inicial do cursor na GetDados RCF
Local nW		:= 0			// Variavel utilizada em while/for
Local nCountRCF := 0			// Numero de registros na RCF
Local lNaoVazio	:= .T.			// Getdados nao esta vazio

	// Retornar o valor da variavel antiga 
	dSvRCHIni	:= dRFQDtIni
	dSvRCHFim	:= dRFQDtFim
	nPosInicio	:= oGetDados:nAt
	// Posicionar no primeiro registro da RCF 
	oGetDados:Goto( 1 )
	oGetDados:Refresh()
	nCountRCF := Len(oGetDados:aCols)	
	
	For nW := 1 to nCountRCF
		oGetDados:Goto( nW ) 
		If  GdDeleted( oGetDados:nAt, aRCFHeader, oGetDados:aCols )   
			Loop
		EndIf		
		oGetDados:Refresh()		
	   	
		dRFQDtIni := dSvRCHIni				// Retornar o valor inicial da variavel para que processe em MontaCalend
		dRFQDtFim := dSvRCHFim
	
		// Transferir as informacoes do vetor principal para o aCols 
		Gpea400AllTrf(	"RCG" 			    ,;	// Alias do Arquivo
						oGetDados		    ,;	// Objeto GetDados para o RCF													
						@oGetDadosRCG:aCols	,;	// aCols utilizado na GetDados
						aRCGHeader			,;	// Cabecalho
						.F.			    	,;	// Se carrega elemento de Deletado na remontagem do aCols
						.F.			    	,;	// Se transfere do aCols para o aColsAll
						.T.				     ;	// Se transfere do aColsAll para o aCols
					 )
	
		lNaoVazio := .T.
		If Len(oGetDadosRCG:aCols) <= 1
			aCposKey := { "RCG_DIAMES" }
			lNaoVazio := GdNoEmpty( aCposKey, 1, aRCGHeader, oGetDadosRCG:aCols, Nil, Nil, .F. )
		EndIf  
	
		// Verificar se existe registro em RCG para atualizar 
		If lNaoVazio 
			MontaCalend(	aRCGNotFields	,;	// Campos nao visuais - RCG
							aRCFCcpoKey		,;	// Campo Chave de RCF
							@nRCGUsado		 ;	// Numero de campos usados - RCG
					   	)						// Clone de aRCFCols - RCF ) }
		EndIf  
		
		// Calcular os dias - Atualizar a RCF
		fCalCDias()
				
	Next nW 

	dRFQDtIni := GetMemVar("RFQ_DTINI")
	dRFQDtFim := GetMemVar("RFQ_DTFIM")

	// Retornar ao registro em que estava posicionado 		
	oGetDados:Goto( nPosInicio )
	oGetDados:Refresh()
                     
	// Reposicionar o RCG para o registro de RCF 
	Gpea400AllTrf(	"RCG" 			    ,;	// Alias do Arquivo
					oGetDados		    ,;	// Objeto GetDados para o RCF													
					@oGetDadosRCG:aCols	,;	// aCols utilizado na GetDados
					aRCGHeader			,;	// Cabecalho
					.F.			    	,;	// Se carrega elemento de Deletado na remontagem do aCols
					.F.			    	,;	// Se transfere do aCols para o aColsAll
					.T.				     ;	// Se transfere do aColsAll para o aCols
				 )
	oGetDadosRCG:Refresh()      
	
	RestArea(aArea)

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fCalCDias   ณ Autor ณ Natie S.          ณ Data ณ  01/12/03   บฑฑ  
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula os valores de Dias Trab/DSR/V.T./V.F.			    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400												        บฑฑ 
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function fCalCDias( cCampo , cValor )
	Local aArea			:= GetArea()        
	Local dData			:= CtoD("//")  
	Local cVTrans		:= ''				// Valor de Vale Transporte - 1-Sim ou 2-Nao
	Local cVRefei		:= ''				// Valor do Vale Refeicao - 1-Sim ou 2-Nao    
	Local cVAlim		:= ''				// Valor do Vale Alimentacao - 1-Sim ou 2-Nao    
	Local nX			:= 0				// Variavel utilizada em for/next
	Local nY			:= 0				// Variavel utilizada em for/next
	Local nPosRCG		:= 0				// Posicao no aCols da RCG
	Local nPosRCF		:= 0				// Posicao do registro em RCF 
	Local nPosDiaMes	:= 0				// Posicao do campo RCG_DIAMES
	Local nPosTipdia	:= 0				// Posicao do campo RCG_TIPDIA
	Local nPosVTrans	:= 0				// Posicao do vale transporte
	Local nPosDifTra	:= 0				// Posicao da Dif. de VT
	Local nPosVRefei	:= 0				// Posicao de Vale Refeicao
	Local nPosvAlime	:= 0				// Posicao de Vale Alimentacao
	Local nPosHrstra	:= 0				// Posicao de Horas Trabalhadas
	Local nPosHrsDsr	:= 0				// Posicao de Horas DSR
	Local nDiasTrab		:= 0				// Numero de dias trabalhados
	Local nDiasNTrab	:= 0				// Numero de dias nao trabalhados
	Local nDiasDSR		:= 0 				// Numero de dias Descanso Semanal Remunerado
	Local nDiasVT		:= 0 				// Numero de dias para Vale Transporte
	Local nDiasDif		:= 0				// Numero de dias dif.
	Local nDiasRef		:= 0 				// Numero de dias ref.  
	Local nDiasAli		:= 0				// Numero de dias alim.
	Local nDiasNUtil	:= 0				// Numero de dias nao uteis
	Local nHrsTrab		:= 0				// Numero de horas trabalhadas
	Local nHrsDSR		:= 0				// Numero de horas DSR 
	Local nDiasPeriod	:= 0				// Numero de dias do periodo
	Local nDiasCalcm	:= 0				// Numero de dias do calculo 
	Local nDiasUteis	:= 0				// Numero de dias uteis
	Local nRCF_DiaTra	:= 0				// Posicao em RCF
	Local nRCF_DiaDSR	:= 0				// Posicao em RCF
	Local nRCF_DnTrab	:= 0				// Posicao em RCF
	Local nRCF_DUtilT	:= 0				// Posicao em RCF       
	Local nRCF_DnUtil	:= 0				// Posicao em RCF
	Local nRCF_dDifVt	:= 0				// Posicao em RCF
	Local nRCF_DRefei	:= 0				// Posicao em RCF 
	Local nRCF_DAlim	:= 0 				// Posicao em RCF 
	Local nRCF_HRSDIA 	:= 0				// Working hours per day
	Local nRCF_HrsTra 	:= 0 				// Qtde de horas trabalhadas
	Local nRCF_HrsDSR 	:= 0				// Qtde de horas DSR 
	Local nRCF_DUteis	:= 0                // Qtde de dias uteis
	Local nRCF_dPerio   := 0				// Qtde de dias do periodo
	Local nRCF_dCalcm   := 0					// Qtde de dias de calculo
	Local nHoras		:= 0				// Valor de horas do Dia   
	// Variaveis para gravacao dos campos chaves  - Rotina GPEA490
	Local nPosProc		:= 0               	// Processo gerado
	Local nPosMes		:= 0               	// Mes gerado
	Local nPosAno		:= 0               	// Ano gerado
	Local nPosPer		:= 0               	// Periodo gerado
	Local nPosNPg		:= 0               	// Numero de Pagamento gerado 
	Local nPosDtIn		:= 0               	// Data Inicial
	Local nPosDtFi		:= 0              	// Data Final
	Local nPosMod		:= 0  				// Modulo  
	Local nPosTurn		:= 0  				// Turno
    
    // OBSERVACAO IMPORTANTE
	// Essa funcao tambem e utilizada para geracao do calendario
	// na rotina GPEA490 (Ger. Per. Padrao), entretanto nela
	// nao existem as GetDados ref. a RCF e RCG, entao o calculo
	// deve ser encarado como Sintetico, independente do parametro
	// MV_TPCALEN que sera tratado na gravacao do GPEA490.
	If cTpCalend == "1" .And. !(lGp490) 
		nPosRCG 	:= oGetDadosRCG:oBrowse:nAt		
		aAuxRCF		:= aClone(oGetDados:aCols) 
		aAuxRCG		:= aClone(oGetDadoSRCG:aCols) 
	Else // Calendario Sintetico
		nPosRCG := 1      
		aAuxRCG := aClone(aColsRCGDef)
		aAuxRCF := aClone(aRCFCols)
	EndIf	
	nPosRCF     := If( !lGp490,oGetDados:oBrowse:nAt, 1 )
	
	// Posicoes para gravacao de chave - Gpea490
	If lGp490 
		// Durante a geracao, precisa gravar os campos chave no array principal
		nPosProc	:=  GdFieldPos( "RCG_PROCES"	,  aRCGAllHeader )		// Processo 
		nPosTurn	:=  GdFieldPos( "RCG_TNOTRA"	,  aRCGAllHeader )		// Turno
		nPosAno		:=  GdFieldPos( "RCG_ANO"		,  aRCGAllHeader )		// Ano
		nPosMes		:=  GdFieldPos( "RCG_MES"		,  aRCGAllHeader )		// Mes
		nPosPer		:=  GdFieldPos( "RCG_PER"		,  aRCGAllHeader )		// Periodo
		nPosNPg		:=  GdFieldPos( "RCG_SEMANA"	,  aRCGAllHeader )		// Num Pag.
		nPosDtIn	:=  GdFieldPos( "RCG_DTINI"		,  aRCGAllHeader )		// Dt Inicial
		nPosDtFi	:=  GdFieldPos( "RCG_DTFIM"		,  aRCGAllHeader )		// Dt Final 
		nPosMod		:=  GdFieldPos( "RCG_MODULO"	,  aRCGAllHeader )		// Modulo
	EndIf
	  
	nPosDiaMes	:=  GdFieldPos( "RCG_DIAMES" , If(!lGp490, aRCGHeader, aRCGAllHeader) )		// Data a calcular
	nPosTipdia	:=  GdFieldPos( "RCG_TIPDIA" , If(!lGp490, aRCGHeader, aRCGAllHeader) )		// Trabalhado / Nao Trabalhado 
	nPosVTrans	:=  GdFieldPos( "RCG_VTRANS" , If(!lGp490, aRCGHeader, aRCGAllHeader) )		// Dia de Utilizacao de V.T.
	nPosDifTra	:=  GdFieldPos( "RCG_DIFTRA" , If(!lGp490, aRCGHeader, aRCGAllHeader) )		// Dias de Dif. de Vale Transp.
	nPosvRefei	:=  GdFieldPos( "RCG_VREFEI" , If(!lGp490, aRCGHeader, aRCGAllHeader) )		// Dias de Vale Refeicao  
	nPosvAlime	:=  GdFieldPos( "RCG_VALIM"  , If(!lGp490, aRCGHeader, aRCGAllHeader) )		// Dias de Vale Alimentacao
	nPosHrsTra	:=  GdFieldPos( "RCG_HRSTRA" , If(!lGp490, aRCGHeader, aRCGAllHeader) )		// Horas Trabalhadas
	nPosHrsDsr	:=  GdFieldPos( "RCG_HRSDSR" , If(!lGp490, aRCGHeader, aRCGAllHeader) )		// DSR

	// Atualiza aCols com  novos Valores p/ calcular               
	If cCampo == "RCG_TIPDIA" .And. nPosTipdia > 0 
		If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosTipdia],aAuxRCG[nPosRCG,nPosTipdia]) := cValor 	
		cVTrans := cValor
		cVRefei := cValor 
		cVAlim  := cValor
		If cValor == '2' .Or. cValor == '3' .Or. cValor == '4'
			cVTrans := '2'
			cVRefei := '2'
			cVAlim := '2'
		EndIf   
		
		// Atualiza o Valor do Vale Transporte	
		If nPosVTrans > 0 
			If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosVTrans],aAuxRCG[nPosRCG,nPosVTrans]) := cVTrans
		EndIf
		 	
		// Atualiza o Vale Refeicao 
		If nPosVRefei > 0 
			If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosVRefei],aAuxRCG[nPosRCG,nPosVRefei]) := cVRefei
		EndIf  
		
		// Atualiza o Vale Alimentacao 
		If nPosvAlime > 0 
			If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosvAlime],aAuxRCG[nPosRCG,nPosvAlime]) := cVAlim
		EndIf 		
		
		   
		// Horas Trabalhadas e DSR 
		nHoras := GdFieldGet("RCF_HRSDIA", nPosRCF, .F., aRCFHeader , aAuxRCF )
		If cValor == '1' 	// Trabalhado  		
			// Atualiza o Valor do Vale Transporte	
			If nPosHrsTra > 0 
				If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosHrsTra],aAuxRCG[nPosRCG,nPosHrsTra]) := nHoras
			EndIf		    
			// Atualiza o Valor do Vale Transporte	
			If nPosHrsDsr > 0 
				If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosHrsDsr],aAuxRCG[nPosRCG,nPosHrsDsr]) := 0
			EndIf		  
		ElseIf cValor == '2'	// Nao Trabalhado     
			// Atualiza o Valor do Vale Transporte	
			If nPosHrsTra > 0 
				If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosHrsTra],aAuxRCG[nPosRCG,nPosHrsTra]) := 0
			EndIf		    
			// Atualiza o Valor do Vale Transporte	
			If nPosHrsDsr > 0 
				If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosHrsDsr],aAuxRCG[nPosRCG,nPosHrsDsr]) := 0
			EndIf
		Else  // 3 - DSR e 4 - Feriado    
			// Atualiza o Valor do Vale Transporte	
			If nPosHrsTra > 0 
				If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosHrsTra],aAuxRCG[nPosRCG,nPosHrsTra]) := 0
			EndIf		    
			// Atualiza o Valor do Vale Transporte	
			If nPosHrsDsr > 0 
				If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosHrsDsr],aAuxRCG[nPosRCG,nPosHrsDsr]) := nHoras
			EndIf
		EndIf
	ElseIf cCampo == "RCG_VTRANS" .And. nPosTipdia > 0 .And. nPosVTrans > 0
		If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosVTrans],aAuxRCG[nPosRCG,nPosVTrans]) := cValor
	ElseIf cCampo == "RCG_DIFTRA" .And. nPosDifTra > 0 
		If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosDifTra],aAuxRCG[nPosRCG,nPosDifTra]) := cValor
	ElseIf cCampo == "RCG_HRSTRA" .And. nPosHrsTra > 0 
		If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosHrsTra],aAuxRCG[nPosRCG,nPosHrsTra]) := cValor
	ElseIf cCampo == "RCG_HRSDSR" .And. nPosHrsDSR > 0 
		If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosHrsDSR],aAuxRCG[nPosRCG,nPosHrsDSR]) := cValor
	ElseIf cCampo == "RCG_VREFEI" .And. nPosTipdia > 0 .And. nPosvRefei > 0 
		If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosvRefei],aAuxRCG[nPosRCG,nPosvRefei]) := cValor	 
	ElseIf cCampo =="RCG_VALIM" .And. nPosTipdia > 0.And. nPosvAlime > 0        
		If(!(lGp490),oGetDadosRCG:aCols[nPosRCG,nPosvAlime],aAuxRCG[nPosRCG,nPosvAlime]) := cValor
  	EndIf 
   
  	If cTpCalend == "1" .And. !(lGp490)     
  	 	// Copia novamente devido as alteracoes anteriores 
  	 	// Para realizar a contagem corretamente
  		aAuxRCG := aClone(oGetDadosRCG:aCols) 
  	EndIf		
  	
	If cPaisLoc == "RUS"
		nDiasTrab	:= GPEA40001( 1, dRFQDtIni, dRFQDtFim )
		nDiasNTrab 	:= GPEA40001( 0, dRFQDtIni, dRFQDtFim )
	
		nHoras 		:= fRusWHrs( M->RCF_TNOTRA )
		nHrsTrab 	:= ( nDiasTrab * nHoras )
	Else
		// Efetua a Somatoria                                           
		For nX := 1 To Len( aAuxRCG )
			If nPosTipDia > 0
				nDiasTrab += If( aAuxRCG[nX,nPosTipDia] == "1" ,1 ,0 )
				nDiasNTrab+= If( aAuxRCG[nX,nPosTipDia] == "2" ,1 ,0 )
				nDiasDSR  += If( aAuxRCG[nX,nPosTipDia] != "1" .And. aAuxRCG[nX,nPosTipDia] != "2" ,1 ,0 )
				If nPosVTrans > 0
					nDiasVt	  += If( aAuxRCG[nX,nPosTipdia] == "1" .And. ;
									aAuxRCG[nX,nPosVTrans ] == "1" ,1 ,0 )
					nDiasNUtil+= If( aAuxRCG[nX,nPosTipdia]  <> "1" .And. ;
									aAuxRCG[nX,nPosVTrans ] == "1" ,1 ,0 ) 
					nDiasAli  += If(( (nPosvAlime > 0) .And. aAuxRCG[nX,nPosvAlime ] == "1" )    ,1 ,0 )  
				EndIf
			EndIf
			If nPosHrstra > 0
				nHrsTrab  += aAuxRCG[nX,nPosHrstra]
			EndIf
			If nPosDifTra > 0
				nDiasDif  += If( aAuxRCG[nX,nPosDifTra] == "1" ,1 ,0 )
			EndIf
			If nPosVRefei > 0
				nDiasRef  += If( aAuxRCG[nX,nPosVRefei] == "1" ,1 ,0 )
			EndIf
			If nPosHrsDsr > 0
				nHrsDSR	  += aAuxRCG[nX,nPosHrsDsr]
			EndIf	
		Next nX
	EndIf
	
	nDiasPeriod		:= dRFQDtFim - dRFQDtIni + 1
	dData			:= If( lGp490, cGp490DIn, GetMemVar("RFQ_DTINI"))
	
	If cQtdeDPer == "1" // Dias do mes			
		If cPaisLoc == "RUS"
			nDiasCalcm := nDiasTrab
		Else
			nDiasCalcm := F_ULTDIA(dData) 
		EndIf
	Else // Sempre 30
		nDiasCalcm := 30
	EndIf
 
	nDiasUteis		:= nDiasPeriod - nDiasDsr 		                                
		
	// Posicao dos campos no Vetor 
	nRCF_DiaTra	:= GdFieldPos( "RCF_DIATRA" ,aRCFHeader )
	nRCF_DiaDSR	:= GdFieldPos( "RCF_DIADSR" ,aRCFHeader )
	nRCF_DnTrab	:= GdFieldPos( "RCF_DNTRAB" ,aRCFHeader )
	nRCF_DUtilT	:= GdFieldPos( "RCF_DUTILT" ,aRCFHeader )
	nRCF_DnUtil	:= GdFieldPos( "RCF_DNUTIL" ,aRCFHeader )
	nRCF_dDifVt	:= GdFieldPos( "RCF_DDIFVT" ,aRCFHeader )
	nRCF_DRefei	:= GdFieldPos( "RCF_DREFEI" ,aRCFHeader )
	nRCF_DnTrab	:= GdFieldPos( "RCF_DNTRAB" ,aRCFHeader )
	nRCF_HrsTra := GdFieldPos( "RCF_HRSTRA" ,aRCFHeader )
	nRCF_HRSDIA := GdFieldPos( "RCF_HRSDIA" ,aRCFHeader )
	nRCF_HrsDSR := GdFieldPos( "RCF_HRSDSR" ,aRCFHeader ) 
	nRCF_DAlim  := GdFieldPos( "RCF_DALIM" , aRCFHeader )      
	nRCF_dPerio := GdFieldPos( "RCF_DPERIO" ,aRCFHeader )
	nRCF_dCalcm := GdFieldPos( "RCF_DCALCM" ,aRCFHeader )
	nRCF_DUteis := GdFieldPos( "RCF_DUTEIS" ,aRCFHeader )   

	If( nRCF_DIATRA > 0, If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_DIATRA],aAuxRCF[1, nRCF_DIATRA]) := nDiasTrab	, 0 )	// Dias Trabalhados
	If( nRCF_DIADSR > 0, If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_DIADSR],aAuxRCF[1, nRCF_DIADSR]) := nDiasDsr	, 0 )	// Dias de DSR 
	If( nRCF_DNTRAB > 0, If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_DNTRAB],aAuxRCF[1, nRCF_DNTRAB]) := nDiasNTrab	, 0 )	// Dias Nao trabalhados
	If( nRCF_DUTILT > 0, If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_DUTILT],aAuxRCF[1, nRCF_DUTILT]) := nDiasVT	, 0 ) 		// Dias Uteis V.T. 
	If( nRCF_DNUTIL > 0, If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_DNUTIL],aAuxRCF[1, nRCF_DNUTIL]) := nDiasNUtil	, 0 ) 	// Dias Nao Uteis de V.T.
	If( nRCF_DDIFVT > 0, If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_DDIFVT],aAuxRCF[1, nRCF_DDIFVT]) := nDiasDif	, 0 ) 	// Dias de Dif. Vale Transporte 
	If( nRCF_DREFEI > 0, If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_DREFEI],aAuxRCF[1, nRCF_DREFEI]) := nDiasRef	, 0 )	// Dias de V.Refeicao 
	If( nRCF_DALIM  > 0, If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_DALIM] ,aAuxRCF[1, nRCF_DALIM])  := nDiasAli	, 0 )	// Dias de V.Alimentacao
	If( nRCF_HRSTRA > 0, If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_HRSTRA],aAuxRCF[1, nRCF_HRSTRA]) := nHrsTrab	, 0 )	// Horas Trabalhadas
	If( ( nRCF_HRSDIA > 0 .AND. cPaisLoc == "RUS" ), If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_HRSDIA],aAuxRCF[1, nRCF_HRSDIA]) := 	nHoras, 0 )	// Working Hours per Day
	If( nRCF_HRSDSR > 0, If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_HRSDSR],aAuxRCF[1, nRCF_HRSDSR]) := nHrsDSR	, 0 )		// Horas DSR   		
	If( nRCF_DPERIO > 0, If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_dPERIO],aAuxRCF[1, nRCF_DPERIO]) := nDiasPeriod, 0 )	// Dias do Periodo     
	If( nRCF_DCALCM > 0, If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_DCALCM],aAuxRCF[1, nRCF_DCALCM]) := nDiasCalcm, 0 )		// Dias de Calculo
	If( nRCF_DUTEIS	> 0, If (!lGp490, oGetDados:aCols[nPosRCF,nRCF_DUTEIS],aAuxRCF[1, nRCF_DUteis]) := nDiasUteis , 0 )  	// Dias Uteis 	
	
	
	If(!lGp490)    
		If cTpCalend == "1"     
   			// Gravar no vetor principal 
			Gpea400AllTrf(	"RCG"   			,;	//01 -> Alias do Arquivo
							oGetDados			,;	//02 -> Objeto GetDados para o RCF
							@oGetDadosRCG:aCols	,;	//03 -> aCols utilizado na GetDados
							aRCGHeader			,;	//04 -> Aheader
							.F.			    	,;	//07 -> Se carrega elemento de Deletacao na remontagem do aCols
							.T.		    		,;	//08 -> Se transfere do aCols para o aColsAll
							.T.			     	;	//09 -> Se transfere do aColsAll para o aCols
						  )							//Funcao local 			  		 				  			  
			oGetDadosRCG:oBrowse:Refresh()  
		EndIf    
		oGetDados:oBrowse:Refresh(.T.)   		
	Else // Chamada pela rotina GPEA490 - Ger. Per. Padrao    
		// Grava conteudo calculado - independente do parametro		
		For nX := 1 to Len(aAuxRCF)    
			AADD(aRCFMaster,aAuxRCF[nX])
		Next nX
		
		For nY := 1 to Len(aAuxRCG)
			If(nPosProc > 0 , aAuxRCG[nY,nPosProc] :=  cProcesso, 0)
			If(nPosTurn > 0 , aAuxRCG[nY,nPosTurn] :=  "@@@", 0)
			If(nPosMes  > 0 , aAuxRCG[nY,nPosMes]  :=  cGp490Mes, 0)
			If(nPosAno  > 0 , aAuxRCG[nY,nPosAno]  :=  cGp490Ano, 0)
			If(nPosPer  > 0 , aAuxRCG[nY,nPosPer]  :=  cGp490Per, 0)
			If(nPosNPg  > 0 , aAuxRCG[nY,nPosNPg]  :=  cGp490Npg, 0)
			If(nPosDtIn > 0 , aAuxRCG[nY,nPosDtIn] :=  cGp490DIn, 0)
			If(nPosDtFi > 0 , aAuxRCG[nY,nPosDtFi] :=  cGp490DFi, 0)
			If(nPosMod  > 0 , aAuxRCG[nY,nPosMod]  :=  cModulo	 , 0)
			AADD(aRCGMaster,aAuxRCG[nY])
		Next nY      
		
	EndIf	 
	
	RestArea(aArea)

Return( .T. ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออัอออออออัออออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ ValidEnch      ณ Autor ณ Mauricio T. Takakura ณ Data ณ  27/07/04   บฑฑ  
ฑฑฬออออออออออุออออออออออออออออฯอออออออฯออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao da Enchoice.        	        				  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400									                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ValidEnch(oEnchoice,nOpc)   
Local aArea			:= GetArea()	
Local cKey			:= ""  // Chave de busca na tabela RFQ     
Local lExistChav	:= .F.
	
	If nOpc == 3     
		cKey := cFilRFQ + GetMemVar("RFQ_PROCES") + GetMemVar("RFQ_PERIOD") + GetMemVar("RFQ_NUMPAG") + ;
					    DtoS(GetMemVar("RFQ_DTINI")) + DtoS(GetMemVar("RFQ_DTFIM")) + GetMemVar("RFQ_MODULO")	
		dbSelectArea("RFQ")
		DbSetOrder( RetOrder( "RFQ", "RFQ_FILIAL+RFQ_PROCES+RFQ_PERIOD+RFQ_NUMPAG+DTOS(RFQ_DTINI)+DTOS(RFQ_DTFIM)+RFQ_MODULO" ) ) 
		RFQ->( MsSeek(cKey) ) 
		If !( RFQ->(Eof()))
			Help("",1,"EXISTCHAV")		// Chave ja Existente  
			lExistChav := .T.		 		
		EndIf
	EndIf    
	
	// Obrigatorio - verifica se todos os campos obrigatorios foram preenchidos
	lValEnchoice := ( Obrigatorio( oEnchoice:aGets , oEnchoice:aTela ) ) .And. !lExistChav   
	
	If !lValEnchoice   
		oEnchoice:aEntryCtrls[ 2 ]:SetFocus()
	EndIf
		                                     
	RestArea(aArea)

Return( lValEnchoice )

/*/{Protheus.doc} Gp400RCFLOk
Critica linha digitada.
@author Mauricio Takakura 
@since 29/07/2004
@return lLinOk, .T. casp a linha seja vแlida
@param oBrowse, object, descricao
/*/
Function Gp400RCFLOk( oBrowse )
 	
//Permitido cadastro de perํodo sem DSR conforme legisla็ใo -- DRHPAG-18068
	
Return( .T. )  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออออัออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณ Gp400RCFTOk ณ Autor ณ Mauricio Takakura ณ Data ณ 09/08/04  บฑฑ  
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออออฯออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Critica todas as linhas digitadas.						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400								    				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Gp400RCFTOk( oBrowse ) 
Local aArea		:= GetArea()
Local lTudoOk	:= .T.		// Variavel para controle de Retorno
Local nX 		:= 0		// Variavel while/for
	For nX := 1 To Len(oGetDados:aCols)
		If !Empty(GdFieldGet( "RCF_TNOTRA" , nX , Nil , aRCFHeader, oGetDados:aCols ))
			n := nX
		 	If !(lTudoOk := Gp400RCFLOk( oBrowse ))
		 	    Exit
		 	EndIf
	    EndIf
	Next nX
	If !lTudoOK
		oGetDados:Goto( n )	
		Eval( oGetDados:bChange )
	EndIf   
	RestArea(aArea)

Return( lTudoOk )  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออัอออออออัออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ Gp400DelOk ณ Autor ณMauricio Takakura ณ Data ณ  21/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออออฯอออออออฯออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Controle dos Registros Deletados.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Usada no botao bRCFDelOk.                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Gp400DelOk(cTipo)    
Local aArea			:= GetArea()
Local lDelOk 		:= .T.		// Controle de Retorno
Local nPosDel		:= 0		// Posicao do campo deletado
Local nX			:= 0 
Local lRecover
			
	DEFAULT lFirstDelOk := .T. 
	lRecover	:= !(lFirstDelOk) 
	
	Begin Sequence  
	    		
		If lRecover
			lFirstDelOk := .T. 			
		EndIf  
		
		// Somente para Calendario Analitico
		If cTpCalend == "1"	 // Somente para Calendario Analitico
			// Exclusao/Recupercao os registros de RCG 
			nPosDel := Len(oGetDadosRCG:aCols[1])
			For nX := 1 To Len(oGetDadosRCG:aCols)
				oGetDadosRCG:aCols[nX, nPosDel] := !(oGetDadosRCG:aCols[nX, nPosDel])
			Next
			Gpea400AllTrf(	"RCG"   			,;	//01 -> Alias do Arquivo
							oGetDados			,;	//02 -> Objeto GetDados para o RCF
							@oGetDadosRCG:aCols	,;	//03 -> aCols utilizado na GetDados
							aRCGHeader			,;	//04 -> Aheader
							.F.			    	,;	//07 -> Se carrega elemento de Deletado na remontagem do aCols
							.T.		    		,;	//08 -> Se transfere do aCols para o aColsAll	
							.T.			     	;	//09 -> Se transfere do aColsAll para o aCols
						  )							//funcao local
			oGetDadosRCF:Refresh()
		EndIf
		
		lFirstDelOk := .F.
		
	End Sequence 
	
	RestArea(aArea)

Return( lDelOK )    

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออัอออออออัอออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ Gp400RCHDelOk ณ Autor ณ Equipe RH     ณ Data ณ  11/21/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออฯอออออออฯอออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Controle dos Registros Deletados RCH.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Botao bRCHDelOk                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Static Function Gp400RCHDelOk()  
Local aArea			:= GetArea()
Local cKey 			:= ""
Local cAliasAux		:= ""
Local lDelOk 		:= .T.		// Controle de Retorno
Local nPosRot		:= GdFieldPos("RCH_ROTEIR"  ,oGetRCH:aHeader) 
Local nPosDtFech 	:= GdFieldPos("RCH_DTFECH" ,oGetRCH:aHeader)
Local nPosRec		:= GdfieldPos("RCH_REC_WT" ,oGetRCH:aHeader)
Local nPosSX9		:= 0
Local nX			:= 0
Local lDelRCH		:=.T.

Static aSx9			:= {}

	If (oGetRCH:aCols[ oGetRch:oBrowse:nAt, Len(aHeaderRCHSF)+1] ==.T. )  
		lDelRCH:=.F.     // Atualiza o sColsRCHSF com deletado
	EndIf	

	Begin Sequence 
		/*S๓ confere se hแ registros relacionados caso o roteiro jแ tenha sido efetivado
		no banco, caso contrแrio nใo hแ necessidade de efetuar essa busca.*/ 	
		If !(oGetRCH:Acols[oGetRCH:nAt,nPosRec] > 0)
			lDelOk := .T.
		ElseIf !Empty( oGetRCH:aCols[oGetRCH:nAt,nPosDtFech])
			MsgAlert( OemToAnsi( STR0037 ) , OemToAnsi( STR0021 ) ) //"Aviso"###"Periodo ja possui data de fechamento. Nao sera possivel efetuar a delecao/alteracao." 
			lDelOK:= .F. 
		ElseIf !Empty(oGetRCH:aCols[oGetRCH:nAt, nPosRot])			
			// Verifica se e possivel deletar o periodo                       
			cKey := cProcesso  +  GetMemVar("RFQ_PERIOD") + GetMemVar("RFQ_NUMPAG") + oGetRCH:aCols[oGetRCH:nAt, nPosRot]
			If Empty(aSx9)
				CheckSx9( "RCH" , @aSx9 ,  , {"RCI","RG8","SP5","SPB","SP8","SPN","SPL","SPI","RI8","RIA","SR0","RG2","SRK","RCK","SR8","SP7"} )
				//Ajusta chave do relacionamento,deve ser retirado na versใo em que o SX9 estiver correto (Superior 12.1.14).
				nPosSX9 := aScan(aSX9, {|x| x[1][1] == "SRC"})
				For nX := 1 to Len(aSx9)
					cAliasAux := aSx9[nX,1,1]
					If cAliasAux == "SRD" .AND. aSx9[nX,5] <> "RCH_PROCES+RCH_PER+RCH_ROTEIR+RCH_NUMPAG"
						aSx9[nX,5] := "RCH_PROCES+RCH_PER+RCH_ROTEIR+RCH_NUMPAG"
						aSx9[nX,2] := {}
						aAdd(aSx9[nX,2],PrefixoCpo(cAliasAux)+ "_FILIAL")
						aAdd(aSx9[nX,2],PrefixoCpo(cAliasAux)+ "_PROCES")
						aAdd(aSx9[nX,2],PrefixoCpo(cAliasAux)+ "_PERIODO")
						aAdd(aSx9[nX,2],PrefixoCpo(cAliasAux)+ "_ROTEIR")
						aAdd(aSx9[nX,2],PrefixoCpo(cAliasAux)+ "_SEMANA")

						If nPosSX9 == 0
							//Inclui verifica็ใo na SRC e RGB, que nใo estavam relacionadas via SX9
							aAdd(aSx9,aClone(aSx9[nX]))
							aSx9[Len(aSx9),1,1] := "SRC"
							aSx9[Len(aSx9),2,1] := PrefixoCpo("SRC")+ "_FILIAL"
							aSx9[Len(aSx9),2,2] := PrefixoCpo("SRC")+ "_PROCES"
							aSx9[Len(aSx9),2,3] := PrefixoCpo("SRC")+ "_PERIODO"
							aSx9[Len(aSx9),2,4] := PrefixoCpo("SRC")+ "_ROTEIR"
							aSx9[Len(aSx9),2,5] := PrefixoCpo("SRC")+ "_SEMANA"
							
							aAdd(aSx9,aClone(aSx9[nX]))
							aSx9[Len(aSx9),1,1] := "RGB"
							aSx9[Len(aSx9),2,1] := PrefixoCpo("RGB")+ "_FILIAL"
							aSx9[Len(aSx9),2,2] := PrefixoCpo("RGB")+ "_PROCES"
							aSx9[Len(aSx9),2,3] := PrefixoCpo("RGB")+ "_PERIOD"
							aSx9[Len(aSx9),2,4] := PrefixoCpo("RGB")+ "_ROTEIR"
							aSx9[Len(aSx9),2,5] := PrefixoCpo("RGB")+ "_SEMANA"
							
							aAdd(aSx9,aClone(aSx9[nX]))
							aSx9[Len(aSx9),1,1] := "SRR"
							aSx9[Len(aSx9),2,1] := PrefixoCpo("SRR")+ "_FILIAL"
							aSx9[Len(aSx9),2,2] := PrefixoCpo("SRR")+ "_PROCES"
							aSx9[Len(aSx9),2,3] := PrefixoCpo("SRR")+ "_PERIODO"
							aSx9[Len(aSx9),2,4] := PrefixoCpo("SRR")+ "_ROTEIR"
							aSx9[Len(aSx9),2,5] := PrefixoCpo("SRR")+ "_SEMANA"
						EndIf
					EndIf
					
				Next nX
			EndIf
			                                                         
			// Verificar se a tabela nao possui registros relacionados 
			lDelOK  := ChkDelRegs(	'RCH'				,;					// 1-Alias do Arquivo Principal
									oGetRCH:Acols[oGetRCH:nAt,nPosRec],;	// 2-Registro do Arquivo Principal
									3					,;					// 3-Opcao para a AxDeleta
									xFilial( "RCH", cFilRFQ )	,;			// 4-Filial do Arquivo principal para Delecao
									cKey				,;					// 5-Chave do Arquivo Principal para Delecao
									aSx9 				,;					// 6-Array contendo informacoes dos arquivos a serem pesquisados
									Nil					,;					// 7-Mensagem para MsgYesNo
									Nil					,;					// 8-Titulo do Log de Delecao
									Nil					,;					// 9-Mensagem para o corpo do Log
									.F.				 	,;					// 10-Se executa AxDeleta
									.F.     			,;					// 11-Se deve Mostrar o Log
									Nil					,;					// 12-Array com o Log de Exclusao
									Nil				 	,; 					// 13-Array com o Titulo do Log
									Nil					,;					// 14-Bloco para Posicionamento no Arquivo
									Nil					,;					// 15-Bloco para a Condicao While
									Nil					,;					// 16-Bloco para Skip/Loop no While
									.F.					,;					// 17-Verifica os Relacionamentos no SX9
									{"RCI"}				,;	    			// 18-Alias que nao deverao ser Verificados no SX9
									Nil				 	 ;					// 19-Se faz uma checagem soft
								 )
								 
			If !lDelOK 
				MsgAlert( OemToAnsi( STR0039 ) , OemToAnsi( STR0021 ) ) 	// "O periodo nao pode ser excluido. Verifique as tabelas relacionadas. "
			EndIf
		EndIf 
	End Sequence  

 	AtualDelColsRCHSF(lDelRCH)	
 	
 	RestArea(aArea)
Return( lDelOK )  

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao	 ณ Gp400Alter  ณ Autor ณ Mauricio T.     ณ Data ณ  21/11/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Se e permitido alterar os campos Turno e Semana.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ X3_WHEN - Campo RCF_TNOTRA                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Function Gp400Alter() 
Local aArea			:= GetArea()
Local lRet		:= .T. 
Local nRCFAt	:= 0 
Local nNroReg 	:= 0 

	If lModPadrao 	
		nRCFAt 	:= oGetDados:nAt 
		If Len(aRCFColsRec) > 1 
			nNroReg := Len(aRCFColsRec) 
		Else 
			If !Empty(GdFieldGet( "RCF_TNOTRA" , 1 , Nil , aRCFHeader, aRCFCols )) 
				nNroReg := 1 
			EndIf 
		EndIf
		
		If nRCFAt <= nNroReg 
			lRet := .F. 
		EndIf 
	EndIf    
	
	RestArea(aArea)
	
Return( lRet )    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ Gp400Valid  ณ Autor ณ Mauricio Takakura ณ Data ณ  04/08/04   บฑฑ  
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Caso altere os campos chaves, excluir os registros de RCG.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ X3_VALID - Campo RCF_TNOTRA							        บฑฑ 
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function GP400Valid(cCampo, cValor)  
Local aArea			:= GetArea() 
Local cValorAnt 	:= ''	// Segundo campo da chave
Local lRet			:= .T.	// Variavel de retorno
Local nPosAt		:= 0	// Posicao do registro no Acols
Local nY			:= 0	// Variavel utilizada para while/for
Local nPosCampo 	:= 0	// Posicao do campo na Matriz Principal
Local nPosTnoTra  := GdFieldPos( "RCG_TNOTRA" , aRCGAllHeader )
	
	Begin Sequence 
	
		nPosAt  := oGetDados:nAt 
		
		If cCampo == 'RCF_TNOTRA'
			cValorAnt 	:= GdFieldGet( "RCF_TNOTRA")
		EndIf
		
		// Verificar se nao esta sendo duplicado a chave 
		lRet := fChecChav(cCampo, cValor)  // Nao foi utilizado a funcao GDCheckKey (MatxFunc) porque o campos ja deve estar preenchido
	  	If !lRet  	
			Break
		EndIf	
	
		// Validacao para troca do codigo alterado na matriz principal 	
			If cTpCalend == "1"  // Calendario Analitico
				// Calcula calendario apos preenchimento de novo turno
				cGp400VldT := GetMemVar("RCF_TNOTRA")
				If cValor != cValorAnt	
					For nY := 1 To Len(aRCGColsAll) 
						If aRCGColsAll[nY][nPosTnoTra] == cValor .Or.  aRCGColsAll[nY][nPosTnoTra] == cValorAnt
							aRCGColsAll[nY][Len(aRCGAllHeader)+1] := .T.
						EndIf
					Next nY
				EndIf
			   	Eval(bExeCalc) 
			   	cGp400VldT := ""   
		   	Else // Calendario Sintetico 
		   		fCalcSint(oGetDados:oBrowse:nAt)  // Calcular somente a linha q ele ta posicionado  
		   	EndIf
		   	
	End Sequence   
	
	RestArea(aArea)

Return( lRet )  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fChecChav   ณ Autor ณ Mauricio Takakura ณ Data ณ  04/08/04   บฑฑ  
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida chave.											    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Usada na funcao GP400Valid.				        บฑฑ 
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function fChecChav(cCampo, cValor) 
Local aArea			:= GetArea()
Local aRCFAux	:= {} 					// Vetor auxiliar
Local cMsgLinha := ''					// Linhas com chaves duplicadas
Local cMensagem	:= ''					// Mensagem Completa
Local cCrLf    	:= Chr(13) + Chr(10)	// Enter para mensagem 
Local lRet		:= .T.					// Variavel de retorno
Local nPosTnoTra:= 0					// Posicao do campo Turno de Trabalho na Matriz Principal
Local nY		:= 0					// Variavel utilizada para while/for
	
	aRCFAux := aClone(oGetDados:aCols)
	nPosTnoTra := GdFieldPos( "RCF_TNOTRA", aRCFHeader )
	
	For nY := 1 To Len(aRCFAux)
		If (cCampo == 'RCF_TNOTRA') .And. (aRCFAux[nY, nPosTnoTra] == cValor)
	  		cMsgLinha += IIf(Len(cMsgLinha)>0,','+Str(nY,2),Str(nY))
	  		lRet := .F.
	   	EndIf
	Next nY 
	
	If !lRet
		cMensagem := "A linha atual possui chave duplicada no browse."	// "A linha atual possui uma chave duplicada no browse."
		cMensagem += cCrLf + ("Campo(s): " + aRCFHeader[nPosTnoTra,1])	// "Campo(s): " 
		cMensagem += cCrLf + ("Linha(s): " + cMsgLinha)	 				// "Linha(s): "
		Aviso( "Atencao", OemToAnsi( cMensagem ) , { "&"+"Ok" }, 2 )	// "Atencao!" , "Ok"
	EndIf    
	
	RestArea(aArea)

Return( lRet ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ ValidSet15  ณ Autor ณ Mauricio Takakura ณ Data ณ  12/08/04   บฑฑ  
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao do Botao OK - bSet15 .							    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400.				        								บฑฑ 
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ValidSet15(	nOpc			,;	// Opcao do menu 
						aRCGNotFields	,;  // Campos nao editaveis em RCG
						aRCFCcpoKey		,;  // Campos chaves de RCF
						nRCGUsado		 ;  // Quantidade de campos utilizados em RCG
							)
Local aArea			:= GetArea()
Local bAllDelRCF:=	{ || Nil }  // Verifica se todos os registros sao deletados em RCF
Local lRet 		:= .F.			// Variavel de controle de retorno
Local lDel		:= .T.
Local lNoEmpty	:= .T.
Local lValidGet := .T.	   		// Retorno da validacao da getdados
Local nDeleted	:= 0			// Posicao do campo deletado
Local nX			:= 0
	Begin Sequence 
	
		nDeleted := Len(aRCFHeader)+1	
		bAllDelRCF := { |x, y|  If(lDel, lDel := x[nDeleted], lDel) }
		aEval(oGetDados:aCols, bAllDelRCF)
		lNoEmpty := GdNoEmpty( aRCFCcpoKey, 1, aRCFHeader, oGetDados:aCols, Nil, Nil, .F. )
		If lDel .Or. !lNoEmpty
			MsgInfo( OemToAnsi(STR0031)  ) // "E necessario a inclusao de pelo menos 1 Turno de Trabalho"
		   Break
		EndIf
		
		// Validacao da enchoice e da GetDados Principal - RCF 
		If lNoEmpty
			lValidGet := oGetDados:TudoOk()
		EndIf
	
		lRet := ValidEnch(oEnchoice, nOpc) .And. lValidGet .And. oGetRCH:TudoOk()
		If lParamChRec 
			// Excluo os registros do banco para gravacao dos novos registros
			fAlterRCF(2) 
		EndIf

		If (nOpc == 5)
			For nX := 1 To Len(oGetRCH:aCols)
				If !Empty(GetMemVar("RFQ_PERIOD"))    
					oGetRCH:nAt := nX
				 	If !(lTudoOk := Gp400RCHDelOk())
						lRet := .F.
						Exit
				 	EndIf
			    EndIf
			Next nX
		EndIf
	End Sequence
	
	RestArea(aArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ gp400LinOk   ณ Autor ณ Natie Sugahara     ณ Data ณ  11/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Critica linha digitada.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Usada na funcao GPA400MANU.                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Function gp400LinOk(oBrowse)  
Local aArea			:= GetArea()
Local aCposKey		:= {}												// Vetor com as chaves de busca
Local aCols_Aux		:= oGetRCH:aCols
Local lLinOk		:= .T.												// Variavel para controle de Retorno
Local nHeaders		:= Len(oGetRCH:aHeader)+1    
Local nPosCrit		:= GdFieldPos("RCH_CRITER" , oGetRCH:aHeader)
Local nPosSeque		:= GdFieldPos("RCH_SEQUE"  , oGetRCH:aHeader)
Local nPosCompl		:= GdFieldPos("RCH_COMPL"  , oGetRCH:aHeader)
Local nPosDtFec		:= GdFieldPos("RCH_DTFECH"  , oGetRCH:aHeader)
Local nPosStatus	:= GdFieldPos("RCH_STATUS"  , oGetRCH:aHeader)
Local nPosRot		:= GdFieldPos("RCH_ROTEIR"  , oGetRCH:aHeader)
Local cAliasQry		:= GetNextAlias()

	Begin Sequence 
	
		// Verifica Itens nao deletados                      			   
		If !aCols_Aux[ oGetRCH:nAT,nHeaders ] 
		
			// Verifica Se o Campos Estao Devidamente Preenchidos		   
			aAdd(aCposKey, "RCH_ROTEIR")
			aAdd(aCposKey, "RCH_DTPAGO")			
			If !( lLinOk := GdNoEmpty( aCposKey, oGetRCH:nAT, oGetRCH:aHeader, oGetRCH:aCols,  ) )	
				Break 
			EndIf 
			
			// Verifica Itens Duplicados na GetDados						   
			aCposKey := {} 
			aAdd(aCposKey, "RCH_ROTEIR")
			If !( lLinOk := GdCheckKey( aCposKey , 4 ) )
				Break
			EndIf			    
			
			//Verifica se existe sequencia informada e criterio em branco
			If nPosSeque > 0 .And. nPosCrit < 0
				If !Empty( oGetRCH:aCols[oBrowse:nAT,nPosSeque] ) .And. Empty( oGetRCH:aCols[oBrowse:nAT,nPosCrit] )                 
					MsgAlert(OemToansi(STR0103),  OemToAnsi( STR0021 ) ) 		// "Consulte Administrador do sistema." 				
					lLinOk := .F.
					Break
				EndIf				
				If lLinOk .And. !lModPadrao	
					M->RCH_SEQUE  := ""
					M->RCH_CRITER := ""     
					lF3Criter	  := .F. 
				EndIf		
			EndIf
			
			//Se for calculo complementar, valida data de pagamento que deve ser igual a do calculo principal
			If nPosCompl > 0 .and. oGetRCH:aCols[oBrowse:nAT,nPosCompl] == "1"
				If !(lLinOK := fVldCompl(oBrowse))
					Break
				EndIf
			EndIf

		// Verifica a data de pagamento
			lLinOk := fValDtPago(oGetRCH)
		
			If(!lLinOk)
				Break
			EndIf
			
			If oGetRCH:aCols[oBrowse:nAT,nPosStatus] == "5" .And. Empty(oGetRCH:aCols[oBrowse:nAT,nPosDtFec]) .And. !(cPaisLoc == "MEX")
				MsgAlert(OemToansi(STR0141),  OemToAnsi( STR0021 ) ) 	//'Status "Fechado" nใo permitido, ้ alterado automaticamento no fechamento do perํodo'
				lLinOk := .F.
				Break
			EndIf
						
			If lLinOk .AND. oGetRCH:aCols[oBrowse:nAT,nPosRot] <> fGetCalcRot('N')
				
				BeginSql alias cAliasQry
				SELECT COUNT(*) NROREG 
				FROM 		%table:RFQ% RFQ				
				WHERE 		RFQ.RFQ_FILIAL = %exp:cFilRFQ%
						AND	RFQ.RFQ_PROCES = %exp:GetMemVar("RFQ_PROCES")%
						AND	RFQ.RFQ_PERIOD > %exp:GetMemVar("RFQ_PERIOD")%
						AND RFQ.RFQ_STATUS = '2'
						AND RFQ.%NotDel%
				EndSql
				
				If (cAliasQry)->(NROREG) > 0
					MsgAlert(OemToansi(STR0155),  OemToAnsi( STR0021 ) )
					lLinOk := .F.
				EndIf
				
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf
		
	End Sequence 
	
	RestArea(aArea)

Return( lLinOk )
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ gp400TudoOk  ณ Autor ณ Equipe RH          ณ Data ณ  11/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Critica todas as linhas digitadas.					          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Usada na funcao GPA400MANU.                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function gp400TudoOk(oBrowse) 
Local aArea			:= GetArea()    
Local lTudoOk		:= .T.		// Variavel para controle de Retorno   
Local nX 			:= 0		// Variavel while/for  

	For nX := 1 To Len(oGetRCH:aCols)
		If !Empty(GetMemVar("RFQ_PERIOD"))    
			oGetRCH:nAt := nX
		 	If !(lTudoOk := gp400LinOk(oBrowse))
				Exit
		 	EndIf
	    EndIf
	Next nX      
	
	// aCols com somente 1 linha e essa linha esta deletada
	If Len(oGetRCH:aCols) < 2 .And. oGetRCH:aCols[ oGetRCH:nAt, Len(aHeaderRCHSF)+1]==.T.  
		MsgAlert(OemToansi(STR0110),  OemToAnsi( STR0021 ) ) 	//"Aviso"###"E necessario cadastrar ao menos 1 roteiro." 
		lTudoOk := .F.
	EndIf

	RestArea(aArea)                

Return( lTudoOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออัอออออออัออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ Gp400MontaCols ณ Autor ณ Equipe RH        ณ Data ณ  11/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออออฯอออออออฯออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta aCols do RCH.									          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Usada na funcao GPA400MANU.                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Static Function Gp400MontaCols(nOpc,cAlias,cProcesso, cPeriodo, cNumPag, aRCHAltera , aHeaderRCH, aColsRCH  ,nOpc ,aColsRCHRec  , aRCHNotFields , nUsado, nPosRec, lGrava )  
Local aArea			:= GetArea()
Local aCols				:= {} 	
Local aRCHVirtGd		:= {} 	
Local aRCHVisualGd		:= {} 	
Local bKey				:= {||Nil}  
Local cCampo    		:= "" 
Local cKeySeek_	 		:= ""
Local lRetOK 			:= .T.  
Local cQuery 			:= 0  
Local nRCHUsado			:= 0 	
Local nX				:= 0
Local nY 				:= 0 
Local nPos				:= 0 
Local nTam				:= 0 
Local nPosPer			:= 0
Local nPosProc			:= 0
Local nPosRoteiro		:= 0
Local nPosDtIni			:= 0
Local nPosPdPeri 		:= 0
Local nPosPerSel		:= 0
Local nPosSem			:= 0
Local xConteudo 	

Default lGrava 			:= .F. 

    cQuery := " RCH_FILIAL 	= '" + xFilial("RCH",cFilRFQ) + "' AND "  
	cQuery += " RCH_PER 	= '" + cPeriodo + "' AND " 
	cQuery += " RCH_NUMPAG 	= '" + cNumPag + "' AND " 
	cQuery += " RCH_PROCES 	= '" + cProcesso + "' AND " 				                              
	cQuery += " RCH_DTINI 	= '" + DtoS(dRFQDtIni) + "' AND " 
	cQuery += " RCH_DTFIM 	= '" + DtoS(dRFQDtFim) + "' AND " 
	cQuery += " RCH_MODULO" + If( cModulo $ "GPE*GFP"," IN ('GPE','GFP')","='"+cModulo+"'" ) + " AND " 
	cQuery += " D_E_L_E_T_ = ' ' "
	  		
	DbSelectArea( "RCH" )
	DbSetOrder( RetOrder("RCH", "RCH_FILIAL+RCH_PER+RCH_NUMPAG+RCH_PROCES+DTOS(RCH_DTINI)+DTOS(RCH_DTFIM)+RCH_MODULO") ) 
	
	cKeySeek_ 	 	:= ( xFilial("RCH",cFilRFQ) + cPeriodo + cNumPag + cProcesso + DtoS(dRFQDtIni) + DtoS(dRFQDtFim) + cModulo )
	bKey			:= { |cKey| RCH->(RCH_FILIAL+ RCH_PER + RCH_NUMPAG + RCH_PROCES + RCH_DTINI + RCH_DTFIM + RCH_MODULO )   == cKeySeek_  } 
	
	// Monta aCols RCH   
	// Nao exibe campos compatibilizados com a enchoice (RFQ)                                       	   
	aAdd( aRCHNotFields,"RCH_PROCES" ) 
	aAdd( aRCHNotFields,"RCH_PER" ) 
	aAdd( aRCHNotFields,"RCH_NUMPAG") 
	aAdd( aRCHNotFields,"RCH_MES" ) 
	aAdd( aRCHNotFields,"RCH_ANO" ) 
	aAdd( aRCHNotFields,"RCH_DTINI" ) 
	aAdd( aRCHNotFields,"RCH_DTFIM" ) 	
	If cPaisLoc == "ARG"
		aAdd( aRCHNotFields , "RCH_NUMREC"  )
	EndIf	
	
	aColsRCH := RCH->( GdMontaCols(	@aHeaderRCH		,;  //01 -> Array com os Campos do Cabecalho da GetDados
									@nRCHUsado		,;	//02 -> Numero de Campos em Uso
								 	@aRCHVirtGd		,;	//03 -> [@]Array com os Campos Virtuais
								  	@aRCHVisualGd	,;	//04 -> [@]Array com os Campos Visuais
		                          	"RCH"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
								  	aRCHNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
								  	@aColsRCHRec	,;	//07 -> [@]Array unidimensional contendo os Recnos
								  	"RCJ"			,;	//08 -> Alias do Arquivo Pai
								  	cKeySeek_		,;	//09 -> Chave para o Posicionamento no Alias Filho
								    bKey			,;	//10 -> Bloco para condicao de Loop While
								    Nil				,;	//11 -> Bloco para Skip no Loop While
	  							    Nil				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
				  				    Nil			  	,;	//13 -> Se cria variaveis Publicas
						  		    Nil				,;	//14 -> Se Sera considerado o Inicializador Padrao
	  							    Nil				,;	//15 -> Lado para o inicializador padrao
			  					    Nil				,;	//16 -> Opcional, Carregar Todos os Campos
					  			    Nil 			,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
		  						    cQuery			,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
		  						    .T.				,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
		  						    .F.		        ,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
									.F.             ,;	//21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
									Nil             ,;	//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
									Nil             ,;	//23 -> Verifica se Deve Checar se o campo eh usado
									Nil				,;	//24 -> Verifica se Deve Checar o nivel do usuario
									.T.				,;	//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
									Nil				,;	//26 -> [@]Array que contera as chaves conforme recnos
									Nil				,;	//27 -> [@]Se devera efetuar o Lock dos Registros
									Nil				,;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
							        Nil				,;	//29 -> Numero maximo de Locks a ser efetuado
									.F.				);	//30 -> Utiliza Numeracao na GhostCol
							   )					
	
	                                                                                      
	aSvColsRCH	:= aClone(aColsRCH)	
	MontaColsRCHSF(cKeySeek_,bKey,cQuery) // Monta o aCols sem SuperFiltro
	
	// Carrega, apenas, os Campos Editaveis            			   
	aRCHAltera := {} 
	For nX := 1	To nRCHUsado 
		IF (;
				( aScan( aRCHVirtGd 		, aHeaderRCH[ nX , 02 ] ) == 0.00 ) .And. ;
		   		( aScan( aRCHVisualGd 		, aHeaderRCH[ nX , 02 ] ) == 0.00 ) .And. ;
		   		( aScan( aRCHNotFields  	, aHeaderRCH[ nX , 02 ] ) == 0.00 ) ;		   
		  	) 
			aAdd( aRCHAltera , aHeaderRCH[ nX , 02 ] )  
		EndIf  
		If aHeaderRCH[ nX, __AHEADER_FIELD__] == "RCH_DTINTE"
			aHeaderRCH[ nX, __AHEADER_VALID__] := If(Empty(aHeaderRCH[ nX, __AHEADER_VALID__]),'Gp400VldDtInt()',aHeaderRCH[ nX, __AHEADER_VALID__] + '.and. Gp400VldDtInt()')
		EndIf
	Next nX         
	
	
	RestArea(aArea) 	

Return( lRetOK )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออัอออออออัออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ MontaColsRCHSF ณ Autor ณ Equipe RH        ณ Data ณ  16/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออฯอออออออฯออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cria um aColsRCHSF Sem SuperFiltro.							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Usada na funcao Gp400MontaCols.  					  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Static Function MontaColsRCHSF(cKeySeek_,bKey,cQuery) 
Local nRCHUsadoSF			:= 0 
Local aRCHVirtGdSF			:= {} 
Local aRCHVisualGdSF		:= {} 

	If FindFunction("FwOnSpFilter") // Verifica se existe a funcao do superfiltro.
   		If (FwOnSpFilter("RCH")  )	// Verifica se existe filtro para "RCH"
   	       		
   	       		 SPFilterOff( { "RCH" } )  //Desativa o SUPERFILTRO   
 
	   						aColsRCHSF := RCH->( GdMontaCols(		@aHeaderRCHSF	,;  //01 -> Array com os Campos do Cabecalho da GetDados
																	@nRCHUsadoSF		,;	//02 -> Numero de Campos em Uso
																 	@aRCHVirtGdSF		,;	//03 -> [@]Array com os Campos Virtuais
																  	@aRCHVisualGdSF	,;	//04 -> [@]Array com os Campos Visuais
            														"RCH"	   			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
				  												   	Nil					,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader 
				  													Nil					,; 	//07 -> [@]Array unidimensional contendo os Recnos
																  	"RCJ"				,;	//08 -> Alias do Arquivo Pai
				 												 	cKeySeek_			,;	//09 -> Chave para o Posicionamento no Alias Filho
				   													bKey				,;	//10 -> Bloco para condicao de Loop While
				   													Nil					,;	//11 -> Bloco para Skip no Loop While
  							   										Nil			   		,;	//12 -> Se Havera o Elemento de Delecao no aCols 
									 			  				    Nil			  	,;	//13 -> Se cria variaveis Publicas
		  		   													Nil					,;	//14 -> Se Sera considerado o Inicializador Padrao
  							  										Nil					,;	//15 -> Lado para o inicializador padrao
  					 												Nil					,;	//16 -> Opcional, Carregar Todos os Campos
	  			  													Nil 				,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
  						    										cQuery				,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
  						    										.T.					,;	//19 -> Opcional, Se deve Executar bKeySF  ( Apenas Quando TOP )
  						    										.F.		        	,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																	.F.             ,;	//21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
																	Nil             ,;	//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																	Nil             ,;	//23 -> Verifica se Deve Checar se o campo eh usado
																	Nil					,;	//24 -> Verifica se Deve Checar o nivel do usuario
																	.T.					,;	//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																	Nil			   		,;	//26 -> [@]Array que contera as chaves conforme recnos
																	Nil					,;	//27 -> [@]Se devera efetuar o Lock dos Registros
																	Nil					,;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
			        												Nil					,;	//29 -> Numero maximo de Locks a ser efetuado
																	.F.			   		);	//30 -> Utiliza Numeracao na GhostCol
						  														 )					
					SPFilterOff( { "RCH" }, .F. )  //Reativa SUPERFILTRO
	
	    EndIf
	EndIf   
		
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออัอออออออัออออออออออออัออออออัออออออออออออปฑฑ
ฑฑบFuncao	 ณ AtualDelColsRCHSF ณ Autor ณReginaldo G ณ Data ณ  23/09/09  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออฯอออออออฯออออออออออออฯออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ  Atualiza o  aColsRCHSF com deletado.        		      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Usada na funcao Gp400RCHDelOk.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Static Function AtualDelColsRCHSF(lDelRCH)
 Local nPos		:= 0
Local nPosRecno	:= GdfieldPos("RCH_REC_WT",oGetRCH:aHeader)	
Local nPosRec   := GdfieldPos("RCH_REC_WT"	,aHeaderRCHSF)

	If !Empty(oGetRCH:aCols[ oGetRch:oBrowse:nAt, nPosRecno ])
			nPos := Ascan( aColsRCHSF, { |x| x[nPosRec]  == oGetRCH:aCols[ oGetRch:oBrowse:nAt, nPosRecno ] } )   
			If nPos > 0  
					aFill(aColsRCHSF[nPos],lDelRCH,Len(aHeaderRCHSF)+1)
			EndIf             
	EndIf 
	
Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fCodPer     ณ Autor ณ Raquel Hager       ณ Data ณ  09/10/12   บฑฑ 
ฑฑฬออออออออออุอออออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Forma conteudo do campo RFQ_PER.						         บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ X3_VALID -  RFQ_MES / RFQ_ANO                                 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function fCodPer()     
Local aArea		:= GetArea()
Local cCampo	:= ""
Local cVar      := ReadVar()
Local cVarAux   := &(ReadVar())
Local cNrPag	:= "" 
Local lDifer	:= .F.  
Local nNumPag	:= 1
Local nPosAux	:= 0 
Local nAno		:= 0
	
	If cVar == "M->RFQ_ANO"      
		nAno  	:= Val(cVarAux)
		If ( nAno < 1900 .Or. nAno > 3000 ) 
			Help(" ",1,"RFQ_ANO")  	// "Digite um ano de competencia valido para o periodo"
			Return(.F.)			
		EndIf
		cCampo := GetMemVar("RFQ_MES")
	Else
		cCampo 	:= GetMemVar("RFQ_ANO") 			
	EndIf	 
		
	If !Empty(GetMemVar("RFQ_MES")) .And. !Empty(GetMemVar("RFQ_ANO")) 			
		If !Empty(cVarAux) .And. !Empty(cCampo)			
			If cVar == "M->RFQ_ANO"
				If dRFQAno <> AllTrim(cVarAux) 
					lDifer 	:= .T.
					dRFQAno	:= AllTrim(cVarAux)  
				EndIf
				M->RFQ_PERIOD := AllTrim(cVarAux)+AllTrim(cCampo) 
			Else  
				If dRFQMes <> AllTrim(cVarAux)
					lDifer := .T. 
					dRFQMes	:= AllTrim(cVarAux)  
				EndIf
				M->RFQ_PERIOD := AllTrim(cCampo)+AllTrim(cVarAux)
			EndIf 
			cPeriodo :=  GetMemVar("RFQ_PERIOD") 
			// Preencho numero de pagamento					
			If lDifer		
				dbSelectArea("RFQ")
				dbSetOrder(1)
				RFQ->(MsSeek(cFilRFQ + M->RFQ_PROCES + M->RFQ_PERIOD ))
				While !RFQ->(Eof()) .And. RFQ->RFQ_FILIAL == cFilRFQ .And. RFQ->RFQ_PROCES == M->RFQ_PROCES .And. RFQ->RFQ_PERIOD == M->RFQ_PERIOD 
					If RFQ->RFQ_NUMPAG <> M->RFQ_NUMPAG
						cNrPag	:= RFQ->RFQ_NUMPAG
					EndIf
				   		RFQ->( dbSkip())
				  	End				
				If !Empty(cNrPag) 
					nNumPag := Val(cNrPag) 
					nNumPag++
					M->RFQ_NUMPAG := StrZero(nNumPag,TamSx3("RFQ_NUMPAG")[1],0)  	
				Else
					M->RFQ_NUMPAG := StrZero(nNumPag,TamSx3("RFQ_NUMPAG")[1],0)  
				EndIf  
			EndIf						   		
		EndIf  		
	EndIf 
	
	RestArea(aArea)					

Return( .T. )   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao	 ณ fRotPdPeri ณ Autor ณ Equipe RH      	    ณ Data ณ 01/03/13 |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Verifica se existe um  P.Padrao cadastrado.			 	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ X3_VALID - RCH_ROTEIR/RCH_DTPAGO							  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function fRotPdPeri()
Local aArea			:= GetArea()   
Local cCampo		:= ReadVar()
Local cPdPeriodo	:= ""       
Local cTipoRot 		:= ""
Local cAno			:= ""
Local cMes			:= ""
Local cAnoMesI		:= ""
Local cAnoMesC1		:= ""
Local cAnoMesC2		:= ""  
Local cRotGet		:= ""
Local lRet			:= .T.
Local nPosPdPeri	:= GdfieldPos("RCH_PDPERI",oGetRCH:aHeader)      
Local nPosRoteir	:= GdfieldPos("RCH_ROTEIR",oGetRCH:aHeader)
Local nPosMes		:= GdfieldPos("RCH_MES",oGetRCH:aHeader)
Local nPosAno		:= GdfieldPos("RCH_ANO",oGetRCH:aHeader)
    
	If Type("oGetRCH") == "O"   
		If cCampo == "M->RCH_ROTEIR"
			dbSelectArea("RGA")
			If RGA->(MsSeek( xFilial("RGA",cFilRFQ) + cProcesso + &(cCampo)  ) ) 
				cPdPeriodo	:= RGA->RGA_PDPERI		
				If !Empty(cPdPeriodo) 
					oGetRCH:aCols[ oGetRCH:oBrowse:nAt, nPosPdPeri ] := cPdPeriodo
				EndIf 	
			EndIf   
		ElseIf cCampo == "M->RCH_DTPAGO" 
			// Verifica a data de pagamento
			lRet := fValDtPago(oGetRCH) 
		EndIf
	EndIf

	RestArea(aArea)        

Return ( lRet )   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออัอออออออัออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fCalcDPerio   ณ Autor ณ Equipe RH        ณ Data ณ  08/03/13   บฑฑ 
ฑฑฬออออออออออุอออออออออออออออฯอออออออฯออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Calcula quantidade de dias do periodo.				         บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ X3_RELACAO -  RCF_DPERIO                          			 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function fCalcDPerio() 
Local nPosDPerio	:= GdfieldPos("RCF_DPERIO",oGetDaDos:aHeader) 
Local nDiasPerio	:= GetMemVar("RFQ_DTFIM") - GetMemVar("RFQ_DTINI") + 1  	  			

Return( If(nPosDPerio>0, oGetDados:aCols[ oGetDados:nAt, nPosDPerio ] := nDiasPerio,0) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออัอออออออัออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fCalcDCalc()   ณ Autor ณ Equipe RH        ณ Data ณ  08/03/13  บฑฑ 
ฑฑฬออออออออออุอออออออออออออออฯอออออออฯออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Calcula quantidade de dias de calculo.				         บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ X3_RELACAO -  RCF_DCALCM                          			 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function fCalcDCalc() 
Local dData		:= GetMemVar("RFQ_DTINI")
Local nPosDCalc	:= GdfieldPos("RCF_DCALCM",oGetDaDos:aHeader)
Local nQtde		:= 0

	If cQtdeDPer == "1" // Dias do mes	
		nQtde := F_ULTDIA(dData) 
	Else // Sempre 30
		nQtde := 30
	EndIf	  			

Return( If(nPosDCalc>0, oGetDados:aCols[ oGetDados:nAt, nPosDCalc ] := nQtde,0) )
 		
						
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออัอออออออัออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fCalcSint     ณ Autor ณ Equipe RH        ณ Data ณ  19/03/13   บฑฑ 
ฑฑฬออออออออออุอออออออออออออออฯอออออออฯออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Calcula quantidade de dias do periodo.				         บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 / GPEA490		                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function fCalcSint(nLin)
Local aArea			:= GetArea()   
Local aRCGNotFields	:= {}	       
Local nX			:= 0 

DEFAULT nLin := 0

	// Campos que nao serao visualizados na getdados 
	aAdd( aRCGNotFields , "RCG_FILIAL"  )
	aAdd( aRCGNotFields , "RCG_TNOTRA"  )
	aAdd( aRCGNotFields , "RCG_PER"     )
	aAdd( aRCGNotFields , "RCG_SEMANA"  )	
	aAdd( aRCGNotFields , "RCG_PROCES"  )
	aAdd( aRCGNotFields , "RCG_ROTEIR"  )
	aAdd( aRCGNotFields , "RCG_MES"     )
	aAdd( aRCGNotFields , "RCG_ANO"     )   
	aAdd( aRCGNotFields , "RCG_DTINI"   )
	aAdd( aRCGNotFields , "RCG_DTFIM"   )
   	aAdd( aRCGNotFields , "RCG_MODULO"  )
    
    // Essa funcao e utilizada para load de conteudo no array
    // aRCGColsAll para a rotina 490, valor default para as
    // horas sera sempre 8   
    If lGp490
   		nHoras 		:=  8
    Else         
    	dRFQDtIni	:= GetMemVar("RFQ_DTINI")
    	dRFQDtFim 	:= GetMemVar("RFQ_DTFIM")
   		nHoras 		:= GdFieldGet( "RCF_HRSDIA" , oGetDados:nAt , .F. , aRCFHeader , oGetDados:aCols )
    EndIf
	// Monta aCols com as informacoes do calendario
	aColsRCGDef	:= 	fNewAcols( 	"1"			 ,;				// Tipo da Geracao 
								aRCGNotFields,;				// Campos Visuais 
								0,;							// Numero de campos usados - RCG
 								dRFQDtIni,;					// Data inicial para preenchimento do RCG
 							   	dRFQDtFim,;					// Data final para preenchimento do RCG
  								nHoras )			// Horas dia

   // Calcula calendario - primeira linha e ao recalcular  
   	If nLin > 0  // Calendario Sintetico - Novo turno
 		oGetDados:Goto(nX)
 		fCalcDias()
   	Else 
		nTam := If(lGp490,Len(aRCFCols),Len(oGetDados:aCols)) 
		For nX := 1 to nTam 
	        If !lGp490 
	        	oGetDados:Goto(nX)
	        EndIf
	     	fCalcDias()
	 	Next nX  
    EndIf		
						
RestArea(aArea)

Return( .T. )  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออัอออออออัออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fLoadChav     ณ Autor ณ Equipe RH        ณ Data ณ  03/04/13   บฑฑ 
ฑฑฬออออออออออุอออออออออออออออฯอออออออฯออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Carrega campos chaves utilizados para gravacao nas tabelas    บฑฑ
ฑฑบ          ณ RCF e RCG tanto no cad. de Periodos quanto na Ger.Per.Padrao  บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ   
ฑฑบUso       ณ GPA400Grava() - Gpea400                                       บฑฑ
ฑฑบ          ณ fGerCalen() - Gpea490                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function fLoadChav(aColsRCH) 
Local nPosPer		:= GdfieldPos("RCH_PER",aHeaderRCH)	   
Local nPosNumPg		:= GdfieldPos("RCH_NUMPAG",aHeaderRCH)	 
Local nPosMes		:= GdfieldPos("RCH_MES",aHeaderRCH)	  
Local nPosAno		:= GdfieldPos("RCH_ANO",aHeaderRCH)	  
Local nPosDtIni		:= GdfieldPos("RCH_DTINI",aHeaderRCH) 
Local nPosDtFim		:= GdfieldPos("RCH_DTFIM",aHeaderRCH) 

	cGp490Per 	:= If(nPosPer 	> 0 , aColsRCH[nPosPer], ) 
	cGp490Mes	:= If(nPosMes 	> 0 , aColsRCH[nPosMes], )
	cGp490Ano 	:= If(nPosAno 	> 0 , aColsRCH[nPosAno], )		 
	cGp490NPg 	:= If(nPosNumPg > 0 , aColsRCH[nPosNumPg], )
	cGp490DIn 	:= If(nPosDtIni > 0 , aColsRCH[nPosDtIni], )
	cGp490DFi 	:= If(nPosDtFim > 0 , aColsRCH[nPosDtFim], ) 	  			

Return(.T.)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออัอออออออัออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ fVldRot       ณ Autor ณ Equipe RH        ณ Data ณ  29/05/13   บฑฑ 
ฑฑฬออออออออออุอออออออออออออออฯอออออออฯออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida roteiro dentro de outras chaves.				         บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ X3_VALID -  RCH_ROTEIR                            			 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function fVldRot()     
Local aArea		:= GetArea()
Local aColsRCH 	:= {}
Local cVar		:= &(ReadVar())   
Local cRotBop	:= fGetCalcRot('O') // Roteiro de beneficios de orgaos publicos
Local cRotInc	:= fGetCalcRot('G') // Roteiro de salario incorporado
Local cRotMuv	:= fGetCalcRot('J') // Roteiro Multiplos vinculos
Local cTipoRot	:= fGetTipoRot( cVar )
Local cTipoAux	:= ""
Local nPosRot	:= GdFieldPos("RCH_ROTEIR" ,oGetRCH:aHeader)
Local nPosRecno	:= GdFieldPos("RCH_REC_WT" ,oGetRCH:aHeader)
Local nPosDel	:= Len(oGetRCH:aHeader)+1
Local nX		:= 0
Local lRet		:= .T.
Local lSRYModulo:= SRY->(ColumnPos("RY_MODULO")) > 0
Local lRCYModulo:= RCJ->(ColumnPos("RCJ_MODULO")) > 0
Local lOpeSoc	:= SuperGetMv("MV_OPESOC", NIL, .F.)
    
	If !Empty(cVar)
		DbSelectArea( "SRY" )
		SRY->(dbSetOrder(1))
		SRY->(dbSeek(xFilial("SRY") + cVar))
		dbSelectArea("RCH")  
		dbSetOrder(4) //RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG
		If RCH->(dbSeek(cFilRFQ +GetMemVar("RFQ_PROCES") + cVar + GetMemVar("RFQ_PERIOD") + GetMemVar("RFQ_NUMPAG"))) .And. RCH->(Recno()) != oGetRCH:aCols[n,nPosRecno]
			MsgAlert(OemToansi(STR0117),  OemToAnsi( STR0021 ) ) 	//"Aviso"###"Roteiro ja cadastrado para outro Processo / Periodo / Numero de Pagamento." 
			lRet := .F. 	
		EndIf
	EndIf    
	
	If Upper(AllTrim(cVar)) == cRotInc
		MsgAlert(OemToansi(STR0124),  OemToAnsi( STR0021 ) ) 	//"Aviso"###"Nao e permitida a inclusao do roteiro de Salario Incorporado." 
		lRet := .F.
	ElseIf Upper(AllTrim(cVar)) == cRotMuv
		MsgAlert(OemToansi(STR0125),  OemToAnsi( STR0021 ) ) 	//"Aviso"###"Nao e permitida a inclusao do roteiro de Multiplos Vinculos."
		lRet := .F.
	ElseIf cPaisLoc == "BRA" .And. !lOpeSoc .And. Upper(AllTrim(cVar)) == cRotBop
		MsgAlert(OemToansi(STR0160),  OemToAnsi( STR0021 ) ) 	//"Aviso"###"Nใo ้ permitida a inclusใo do roteiro de Benefํcios de ำrgใos P๚blicos."
		lRet := .F.
	EndIf
	
	If lRet
		If lModPadrao .And. GetMemVar("RFQ_PROCES") $ "00001*00002" .and. cTipoRot == "9" //Processo Celetista + Roteiro Autonomo
			MsgAlert(OemToansi(STR0134),  OemToAnsi( STR0021 ) ) 	//"Aviso"###"Nใo ้ permitido a inclusใo do roteiro 'Aut๔nomo' neste processo." 
			lRet := .F.			
		ElseIf lModPadrao .And. !(cPaisLoc $ "BOL") .And. GetMemVar("RFQ_PROCES") $ "00003*00004" .and. cTipoRot == "1" //Processo Autonomo + Roteiro Folha
			MsgAlert(OemToansi(STR0135),  OemToAnsi( STR0021 ) ) 	//"Aviso"###"Nใo ้ permitido a inclusใo do roteiro 'Folha' neste processo." 
			lRet := .F.
		ElseIf lModPadrao .And. lSRYModulo .And. lRCYModulo .And. RCJ->RCJ_MODULO == "GFP" .AND. SRY->RY_MODULO $ " |1"
			MsgAlert(OemToansi(STR0147),  OemToAnsi( STR0021 ) ) 	//"Aviso"###"Nใo ้ permitido a inclusใo de roteiros de Folha Privada neste processo."
			lRet := .F.
		ElseIf lModPadrao .And. lSRYModulo .And. lRCYModulo .And. RCJ->RCJ_MODULO != "GFP" .AND. SRY->RY_MODULO == "2"
			MsgAlert(OemToansi(STR0148),  OemToAnsi( STR0021 ) ) 	//"Aviso"###"Nใo ้ permitido a inclusใo de roteiros de Folha P๚blica neste processo."
			lRet := .F.
		ElseIf cTipoRot $ "1*9"
			aColsRCH := aClone(oGetRCH:aCols)
			For nX := 1 to Len(aColsRCH)
				If nX <> n .and. !aColsRCH[nX,nPosDel]
					cTipoAux := fGetTipoRot( aColsRCH[nX,nPosRot])
					If cTipoAux $ "1*9*N" .and. cTipoAux <> cTipoRot
						lRet := .F.
						If cTipoAux $ "N"
							MsgAlert(OemToansi(STR0151) + CRLF + OemToansi(STR0152),  OemToAnsi( STR0021 ) ) 	//"Aviso"###"Nใo ้ permitido a inclusใo do roteiro 'Retificadora' junto com os roteiros 'Folha' ou 'Aut๔nomo'."###"Somente ้ possํvel a inclusใo do roteiro 'Retificadora' em perํodo separado."
						Else
							MsgAlert(OemToansi(STR0136),  OemToAnsi( STR0021 ) ) 	//"Aviso"###"Nใo ้ permitido a inclusใo dos roteiros 'Folha' e 'Aut๔nomo' no mesmo processo."
						EndIf
						Exit						
					EndIf				 
				EndIf
			Next nX
		ElseIf cTipoRot $ "N"//Complementar
			If !fVldPerRtf()
				lRet := .F.
			EndIf
			If lRet
				aColsRCH := aClone(oGetRCH:aCols)
				For nX := 1 to Len(aColsRCH)
					If nX <> n .and. !aColsRCH[nX,nPosDel]
						cTipoAux := fGetTipoRot( aColsRCH[nX,nPosRot])
						If cTipoAux $ "1*9"
							lRet := .F.
							MsgAlert(OemToansi(STR0151) + CRLF + OemToansi(STR0152),  OemToAnsi( STR0021 ) ) 	//"Aviso"###"Nใo ้ permitido a inclusใo do roteiro 'Retificadora' junto com os roteiros 'Folha' ou 'Aut๔nomo'."###"Somente ้ possํvel a inclusใo do roteiro 'Retificadora' em perํodo separado."
							Exit						
						EndIf				 
					EndIf
				Next nX
			EndIf
		EndIf
	EndIf	
  	  			
RestArea(aArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunctionณRchTarVld      บAutor  ณLeandro Drumond  บ Data ณ 23/09/2013  บฑฑ
ฑฑฬออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณValid do campo RCH_TARINI e RCH_TARFIM					      บฑฑ
ฑฑบ        ณ                                                              บฑฑ
ฑฑฬออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณCadastro de Periodos			                              บฑฑ
ฑฑศออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function RchTarVld()
Local lRet 		:= .T.
Local cCampo	:= ReadVar()
Local nPosRot	:= GdfieldPos("RCH_ROTEIR",oGetRCH:aHeader)
Local cRotAux   := oGetRCH:aCols[ oGetRCH:oBrowse:nAt, nPosRot ]
Local cTipoRot 	:= PosAlias("SRY", cRotAux, xFilial("RCH",cFilRFQ), "RY_TIPO")
Local dDataIni	:= GetMemVar("RFQ_DTINI")
Local dDataFim	:= GetMemVar("RFQ_DTFIM")
Local dTarIni	:= oGetRCH:aCols[ oGetRCH:oBrowse:nAt, GdfieldPos("RCH_TARINI",oGetRCH:aHeader) ]
Local dTarFim	:= oGetRCH:aCols[ oGetRCH:oBrowse:nAt, GdfieldPos("RCH_TARFIM",oGetRCH:aHeader) ]
Local dDataAux  := &(ReadVar())

If ( dDataAux < dDataIni .or. dDataAux > dDataFim ) .and. cTipoRot <> "F" //Paara PLR as tarefas podem estar fora do periodo
	MsgAlert(OemToansi(STR0120),  OemToAnsi( STR0021 ) )		//"Aviso"###"Data das tarefas devem estar dentro do periodo de cแlculo."
	lRet := .F.
Else
	If cCampo == "M->RCH_TARINI"
		dTarIni := dDataAux
	Else
		dTarFim := dDataAux
	EndIf
	
	If !Empty(dTarIni) .and. !Empty(dTarFim)
		If dTarIni > dTarFim
			MsgAlert(OemToansi(STR0121),  OemToAnsi( STR0021 ) )		//"Aviso"###"Data Final da tarefa nใo pode ser menor que a Data Inicial"
			lRet := .F.
		EndIf
	EndIf
EndIf 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunctionณRchTarWhen     บAutor  ณLeandro Drumond  บ Data ณ 23/09/2013  บฑฑ
ฑฑฬออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณWhen dos campos RCH_TARINI e RCH_TARFIM					      บฑฑ
ฑฑบ        ณ                                                              บฑฑ
ฑฑฬออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ Cadastro de Periodos			                              บฑฑ
ฑฑศออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function RchTarWhen()
Local lRet 		:= .T.
Local nPosRot	:= GdfieldPos("RCH_ROTEIR",oGetRCH:aHeader)
Local cRotAux   := oGetRCH:aCols[ oGetRCH:oBrowse:nAt, nPosRot ]
Local cTipoRot 	:= PosAlias("SRY", cRotAux, xFilial("RCH",cFilRFQ), "RY_TIPO")

If cTipoRot $ "3*5*6" //Ferias, 13. Salario
	lRet := .F.
EndIf
    
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunctionณGp400ComplWhen บAutor  ณLeandro Drumond  บ Data ณ 11/02/2014  บฑฑ
ฑฑฬออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณWhen do campo RCH_COMPL									      บฑฑ
ฑฑบ        ณ                                                              บฑฑ
ฑฑฬออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ Cadastro de Periodos			                              บฑฑ
ฑฑศออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Gp400ComplWhen()
Local lRet 		:= .F.
Local nPosRot	:= GdfieldPos("RCH_ROTEIR",oGetRCH:aHeader)
Local cRotAux   := oGetRCH:aCols[ oGetRCH:oBrowse:nAt, nPosRot ]
Local cTipoRot 	:= PosAlias("SRY", cRotAux, xFilial("SRY"), "RY_TIPO")

If cTipoRot $ "1" // Somente Folha
	lRet := .T.
EndIf

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ Gp400Leg    ณ Autor ณ Raquel Hager       ณ Data ณ 03/04/13 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Legenda de status do periodo.		                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ GPEA400                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Gp400Leg() 
Local aArea := GetArea()
           //"Cadastro de periodo" //"Definicao do Status do Periodo:"
BrwLegenda(STR0123,STR0129, {	{"BR_VERDE"		, OemToAnsi(STR0127)},; //"Periodo Aberto"
								{"BR_VERMELHO"	, OemToAnsi(STR0128)}}) //"Periodo Fechado"
									
RestArea(aArea)
									
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ MenuDef     ณAutor  ณ Equipe RH         ณ Data ณ  05/01/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Isola opcoes de menu para que as opcoes da rotina possam     บฑฑ
ฑฑบ          ณ ser lidas pelas bibliotecas Framework da Versao 9.12 .       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400                                                      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aRotina                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MenuDef()
	Private lModPadrao     := ( MV_MODFOL == '1' )

	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Define Array contendo as Rotinas a executar do programa      ณ
	ณ ----------- Elementos contidos por dimensao ------------     ณ
	ณ 1. Nome a aparecer no cabecalho                              ณ
	ณ 2. Nome da Rotina associada                                  ณ
	ณ 3. Usado pela rotina                                         ณ
	ณ 4. Tipo de Transao a ser efetuada                          ณ
	ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
	ณ    2 - Simplesmente Mostra os Campos                         ณ
	ณ    3 - Inclui registros no Bancos de Dados                   ณ
	ณ    4 - Altera o registro corrente                            ณ
	ณ    5 - Remove o registro corrente do Banco de Dados          ณ
	ณ    6 - Copiar                                                ณ
	ณ    7 - Legenda                                               ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
    If cPaisLoc == "BRA" 
    	
    	aRotina := {	{ STR0002 , "PesqBrw"	 , 0 , 1 ,, .F.} ,; 	// "Pesquisar"
						{ STR0003 , "GPA400Manu" , 0 , 2 ,, .F.} ,; 	// "Visualizar"  
						{ STR0004 , "GPA400Mdf"  , 0 , 3,, .F.} ,;		// "Incluir"
						{ STR0005 , "GPA400Manu" , 0 , 4 ,, .F.} ,; 	// "Alterar"
						{ STR0006 , "GPA400Manu" , 0 , 5 ,, .F.} ,; 	// "Excluir"
						{ STR0122 , "GPEA710"    , 0 , 6 ,, .F.} ,; 	// "Bloq. de Periodos"   
						{ STR0159 , "GPA400MDT"  , 0 , 4 ,, .F.} ,; 	// "Bloqueio MDT" 
						{ STR0130 , "Gp400Leg"   , 0 , 7 ,, .F.};		// "Legenda"
					}
	Else
		aRotina := {	{ STR0002 , "PesqBrw"	 , 0 , 1 ,, .F.} ,; 	// "Pesquisar"
					{ STR0003 , "GPA400Manu" , 0 , 2 ,, .F.} ,; 	// "Visualizar"  
					{ STR0004 , "GPA400Mdf"  , 0 , 3 ,, .F.} ,; 	// "Incluir"
					{ STR0005 , "GPA400Manu" , 0 , 4 ,, .F.} ,; 	// "Alterar"
					{ STR0006 , "GPA400Manu" , 0 , 5 ,, .F.} ,; 	// "Excluir"
					{ STR0122 , "GPEA710"    , 0 , 6 ,, .F.} ; 	// "Bloq. de Periodos"   
				}
	
	EndIf
Return( aRotina )

Function fValDtPago(oGetRCH)
	Local nPosRoteir		:= GdfieldPos("RCH_ROTEIR",oGetRCH:aHeader)
	Local nPosMes			:= GdfieldPos("RCH_MES",oGetRCH:aHeader)
	Local nPosAno			:= GdfieldPos("RCH_ANO",oGetRCH:aHeader)
	Local nPosDtPgto		:= GdfieldPos("RCH_DTPAGO",oGetRCH:aHeader)
	Local dDtPgto 			:= cToD("//")
	Local dDtIniPer 		:= cToD("//")
	Local dDtMesSeguinte	:= cToD("//")
	Local cMesAnoDtPagto	:= ""

	Local lRetorno := .T.  

	If !lPerMod2 //Validacao nao aplicavel para o cadastro modelo 2 simplificado
		
		cRotGet		:= If(lGp490, cRoteiro, oGetRCH:aCols[ oGetRCH:oBrowse:nAt, nPosRoteir ])
		cAno		:= If(lGp490, oGetRCH:aCols[ oGetRCH:oBrowse:nAt, nPosAno ], GetMemVar("RFQ_ANO"))
		cMes		:= If(lGp490, oGetRCH:aCols[ oGetRCH:oBrowse:nAt, nPosMes ], GetMemVar("RFQ_MES"))
	
		If ReadVar() == "M->RCH_DTPAGO"
			dDtPgto	:= &(ReadVar()) 
		Else
			dDtPgto	:= If(lGp490, , oGetRCH:aCols[ oGetRCH:oBrowse:nAt, nPosDtPgto ])
		EndIf
	
		cTipoRot 	:= PosAlias("SRY", cRotGet, xFilial("RCH",cFilRFQ), "RY_TIPO") 
		dDtIniPer	:= cAno+cMes
		dDtMesSeguinte	:= MesAno(MonthSum(CtoD("01/"+cMes+"/"+cAno), 1))
		If cTipoRot == "1" .And. cAno != "" .And. cMes != "" // Validacao apenas pra roteiro FOLHA
		    cMesAnoDtPagto := MesAno(dDtPgto)
		    // Data de fechamento tem que estar dentro do mes competencia
		    // ou para o mes seguinte ao da competencia
			If !(cMesAnoDtPagto $ dDtIniPer) 
				If !(cMesAnoDtPagto $ dDtMesSeguinte)   
					MsgAlert(OemToansi(STR0112),  OemToAnsi( STR0021 ) ) 	//"Aviso"###"Para o roteiro da Folha, a data de pagamento devera estar contida no mes da competencia ou no seguinte."
					lRetorno := .F.
				EndIf   
			EndIf
		ElseIf dDtPgto < CtoD("01/"+cMes+"/"+cAno)
			MsgAlert(OemToansi(STR0131))
			lRetorno := .F.
		ElseIf dDtPgto <> oGetRCH:aCols[ oGetRCH:oBrowse:nAt, nPosDtPgto ]		
			If  fDtPgCalc(GetMemVar("RFQ_PROCES"), if(lGp490, cRoteiro, oGetRCH:aCols[ oGetRCH:oBrowse:nAt, nPosRoteir ]) , GetMemVar("RFQ_PERIOD") ,GetMemVar("RFQ_NUMPAG"))
				MsgAlert(OemToansi(STR0157),  OemToAnsi( STR0156 ) )	
				//"Para evitar inconsist๊ncias na gera็ใo do evento S1210 do eEsocial, realize o cancelamento para altera็ใo da Data de Pagamento."
				//"Cแlculo jแ efetuado para este roteiro!"
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunctionณfVldCompl      บAutor  ณLeandro Drumond  บ Data ณ 06/10/2014  บฑฑ
ฑฑฬออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณValida data de pagamento de calculo complementar			  บฑฑ
ฑฑบ        ณ                                                              บฑฑ
ฑฑฬออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ Cadastro de Periodos			                              บฑฑ
ฑฑศออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fVldCompl(oBrowse)
Local aArea		:= GetArea()
Local cSemAux	:= StrZero(Val(M->RFQ_NUMPAG)-1,2)
Local nPosRot	:= GdFieldPos("RCH_ROTEIR" , oGetRCH:aHeader)
Local nPosData	:= GdFieldPos("RCH_DTPAGO" , oGetRCH:aHeader)
Local lRet		:= .T.

DbSelectArea("RCH")
DbSetOrder(1)//RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR

If DbSeek(xFilial('RCH') + cProcesso + cPeriodo + cSemAux + oGetRCH:aCols[oBrowse:nAT, nPosRot])
	If ! oGetRCH:aCols[oBrowse:nAT, nPosData] == RCH->RCH_DTPAGO
		Help(,,STR0021,, STR0132,1,0 ) //"Aviso","A data de pagamento do cแlculo complementar deve ser igual a data de pagamento do cแlculo principal."
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunctionณVldTNOTRA     บAutor  ณLeandro Drumond  บ Data ณ 06/10/2014  บฑฑ
ฑฑฬออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณValida campo turno											  บฑฑ
ฑฑบ        ณ                                                              บฑฑ
ฑฑฬออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ Cadastro de Periodos			                              บฑฑ
ฑฑศออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function VldTNOTRA()
	Local lRet := .T.

	If M->RCF_TNOTRA != "@@@"
		lRet := NaoVazio() .And. ExistCpo( "SR6" ) .and. Gp400Valid("RCF_TNOTRA", M->RCF_TNOTRA)                 
	Else
		lRet := NaoVazio() .and. Gp400Valid("RCF_TNOTRA", M->RCF_TNOTRA)                 
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFunctionณGp400VldDtInt บAutor  ณLeandro Drumond  บ Data ณ 16/11/2015  บฑฑ
ฑฑฬออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณValida campo data de integra็ใo								  บฑฑ
ฑฑบ        ณ                                                              บฑฑ
ฑฑฬออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ Cadastro de Periodos			                              บฑฑ
ฑฑศออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Gp400VldDtInt()
Local cVar 		:= &(ReadVar())
Local nPosDtInt	:= GdfieldPos("RCH_DTINTE",oGetRCH:aHeader) 

//Incluido mensagem informatica sobre altera็ใo do campo RCH_DTINTE
If aCols[n,nPosDtINt] <> cVar
	MsgInfo( OemToAnsi(STR0137) + CRLF + OemToAnsi(STR0138), OemToAnsi(STR0083))
	//"A data de integra็ใo ้ preenchida ap๓s a execu็ใo da integra็ใo do roteiro com a folha de pagamento"
	//"A altera็ใo manual deste campo nใo ้ recomenda pois poderแ causar diverg๊ncias no cแlculo da Folha."
EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณRCHFIL01    ณ Autor ณ Alfredo Medrano     ณ Data ณ11/02/2015ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Filtra los periodos donde su procedimiento de calculo = 'T'ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ RCHFIL01()                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ cFiltro	                                           	    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Filtro en consulta RCHRY                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum						                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function RCHFIL01() 

	Local		aArea 		:= getArea() 
	Local		cAliasRY	:= criatrab( nil, .f. )
	Local		cQuery 	:= ""
	Local 		cFiltro	:= ""
	Local 		cRoteirs	:= ""
	Local 		cNoPag		:= ""
	Local 		nPosSem := 0
	Local 		nSavRec := 0
	
	// carga SRY, donde RY_TIPO='T'
	cQuery := "SELECT RY_CALCULO  FROM " + RetSqlName("SRY")
	cQuery += " WHERE RY_TIPO = 'T' "
	cQuery += " AND RY_FILIAL	= '" + XFILIAL('SRY') + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)   	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRY,.T.,.T.)
	(cAliasRY)->(dbgotop())
		While  (cAliasRY)->(!EOF())	
		
			cRoteirs += (cAliasRY)->RY_CALCULO + '|'
			( cAliasRY )-> (dbskip())
			
		EndDo	
		( cAliasRY )->(dbCloseArea())

	cNoPag 	:= M->RFQ_NUMPAG// N๚mero pago posicionado
	//filtro a retornar		
	cFiltro := "(RCH->RCH_PROCES == '" + cProcesso +"') .AND. ( RCH->RCH_NUMPAG == '" + cNoPag +"') .AND. (RCH->RCH_ROTEIR $ ('" + cRoteirs + "'))" 
	cFiltro := "@#" + cFiltro + "@#"
	restArea(aArea)
return ( cFiltro )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณGP400fVldPerr  ณ Autor ณ Axel Hdez        ณ Data ณ27/11/2015ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Solo permite pasar valores vแlidos para RCH_PER y Proceso  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ GP400fVldPerr()                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ cFiltro                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Filtro en consulta GPEA400                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function GP400fVldPerr() 
 
      Local aArea     := getArea() 
      Local cAliasRFQ := criatrab( nil, .f. )
      Local cQuery        := ""
      Local lRet      := .F.
      Local cQuery    := ""
                        
      cQuery := "SELECT  RCH_PER  FROM " + RetSqlName("RCH")  + " RCH"
      cQuery += " INNER JOIN " + RetSqlName("SRY")  + " RY" + " ON RY_CALCULO = RCH_ROTEIR "
      cQuery += " WHERE RCH_PROCES = '" + cProcesso + "' "
      cQuery += " AND RCH_PER = '" + &(READVAR()) + "' " 
      cQuery += " AND RCH_NUMPAG = '" + RCH->RCH_NUMPAG + "' "
      cQuery += " AND RCH_ROTEIR = '" + RRCH->RCH_ROTEIR + "' "  
      cQuery += " AND RY_TIPO = 'T' " 
      cQuery += " AND RCH_FILIAL   = '" + XFILIAL('RCH') + "' "
      cQuery += " AND RY_FILIAL    = '" + XFILIAL('SRY') + "' "
      cQuery += " AND RY.D_E_L_E_T_ = ' ' AND RCH.D_E_L_E_T_= ' '"
      cQuery := ChangeQuery(cQuery)   
            
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRFQ,.T.,.T.)
      (cAliasRFQ)->(dbgotop())
            While  (cAliasRFQ)->(!EOF()) 
                  lRet := .T.
                  (cAliasRFQ)-> (dbskip())
            EndDo 
            
      (cAliasRFQ)->(dbCloseArea())
      
      restArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออออออัออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณ GPA400Mdf  ณAutor  ณ  Oswaldo L V ณ Data ณ  16/11/17          บฑฑ 
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออออออฯออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para criticar filial distinta do browse de processos   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ GPA400Mdf( cAlias , nReg , nOpcX )			                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cAlias = Alias do arquivo 					                 บฑฑ
ฑฑบ          ณ nReg   = Numero do registro                                   บฑฑ
ฑฑบ          ณ nOpc   = Numero da opcao selecionada                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA400 - Opcoes 2 e 4 MenuDef.                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function GPA400Mdf( cAlias , nReg , nOpc )
	
If RCJ->RCJ_FILIAL != xFilial("RFQ" )
	MsgInfo( OemToAnsi(STR0145) + " (" + Alltrim(RCJ->RCJ_FILIAL) + ")" )
	return
	/*
	Inicialmente conseguimos remover a exibi็ใo da janela do frame atrav้s desta fun็ใo paliativa GPA400Mdf(passando nOpc 4 e depois modificando para 3). No entanto, no caso
	em que somente havia o registro pai(browse de processos) e o browse de perํodos se encontrava vazio, ao clicar em incluir o frame exibia critica de tentativa de altera็ใo 
	em arquivo vazio(situa็ใo esta nใo contornada). Por esta razใo, inserimos apenas mensagem de alerta.
	*/
EndIf
	
return ( GPA400MANU( cAlias , nReg , nOpc ) )

/*/{Protheus.doc} GPA400MDT
Abre a trla para inclusใo de restri็ใo especifica para o MDT
@type  		Function
@author		Leandro Drumond
@since		26.01.2022
@version	001
@return 	Nil
/*/
Function GPA400MDT( cAlias, nReg, nOpc)

	FWExecView(STR0159,'GPEA760', MODEL_OPERATION_UPDATE,, { || .T. } ) //"Bloqueio MDT"

Return Nil

/*/{Protheus.doc} GPEA40001
Function returns number of Working or Non-Working days in period
@type  		Function
@author		Ekaterina.Moskovkira
@since		23.04.2018
@version	001
@param 		nCalcType	Numeric	Indicates if we need to calc Working days (=1) or Non-Working days (=0)
			dBegDate 	Date	Beginning of period
			dEndDate 	Date	End of period
@return 	nDaysCalc	Numeric Count of days
/*/
Function GPEA40001 (nCalcType, dBegDate, dEndDate)
Local	aArea		:= getArea()
Local	cMyAlias	:= GetNextAlias()
Local	cQuery		:= ""

Local	nDaysCalc	as Numeric
// Workdays will be calculated by default
Default nCalcType := 1

	cQuery := "SELECT COUNT(1) AS DAYS_COUNT"
	cQuery += " FROM"
	cQuery += " (SELECT	CLNDR.GENERATE_SERIES, "
	cQuery += " 	CASE	WHEN	( EXTRACT( DOW FROM CLNDR.GENERATE_SERIES ) NOT IN (0, 6) "
	cQuery += " 				AND P3.R_E_C_N_O_ IS NULL ) "
	cQuery += " 			OR ( P3.R_E_C_N_O_ IS NOT NULL AND P3.P3_TPDAY = '2' ) "
	cQuery += " 		THEN 	1 "
	cQuery += " 		ELSE 	0 "
	cQuery += " 	END AS WDTYPE "
	cQuery += " FROM "
	cQuery += " (SELECT * FROM GENERATE_SERIES('" + DTOS(dBegDate) + "', '" + DTOS(dEndDate) + "', '1 DAY'::INTERVAL) )	CLNDR "
	cQuery += " LEFT JOIN "  + RetSqlName("SP3")  + " P3 "
	cQuery += " 	ON CLNDR.GENERATE_SERIES = P3.P3_DATA::date AND P3.D_E_L_E_T_ = '' "
	cQuery += " ) C_DAYS"
	cQuery += " WHERE C_DAYS.WDTYPE = " + STR( nCalcType )
	//cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cMyAlias, .T., .T. )
	( cMyAlias ) -> ( DBGoTop() )
    While  ( cMyAlias ) -> ( !EOF() ) 
        nDaysCalc := ( cMyAlias ) -> DAYS_COUNT
        ( cMyAlias ) -> ( DbSkip() )
    EndDo 
            
    ( cMyAlias ) -> ( dbCloseArea() )

	RestArea( aArea )
Return nDaysCalc

/*/{Protheus.doc} fRusWHrs
Function returns number of Working Hours according to selected Work Shift
@type  		Function
@author		Ekaterina.Moskovkira
@since		26.04.2018
@version	001
@param 		cWShift		Character	Indicates code of selected Work Shift
@return 	nWSHours	Numeric 	Count of working hours
/*/
Function fRusWHrs (cWShift as Character)
Local	nWSHours	:= 0.00
// Working hours from selected WorkShift
Default	cWShift 	:= "@@@"

	If cWShift != "@@@"
		nWSHours := Posicione("SR6", 1, xFilial( "SR6" ) + cWShift, "R6_HRDIA")
	Else
		nWSHours	:= 8.00
	EndIf
Return nWSHours

/*/{Protheus.doc} FRotPrcFlt
Filtra a consulta padrใo da tabela SRY considerando o campo RCJ_MODULO
@type  		Function
@author		Paulo.inzonha
@since		02.10.2018
@version	001
@param 		
@return 	String com Filtro a ser realizado
/*/
Function FRotPrcFlt()
Local cFiltro 	:= ""
Local lSRYModulo:= SRY->(ColumnPos("RY_MODULO")) > 0
Local lGestPubl	:= IIF(ExistFunc("fUsaGFP"), fUsaGFP(), .F.)
Local lRCYModulo:= RCJ->(ColumnPos("RCJ_MODULO")) > 0                                                    
Local lOpeSoc	:= SuperGetMv("MV_OPESOC", NIL, .F.) 
 
If lSRYModulo .AND. lGestPubl .And. lRCYModulo
	If RCJ->RCJ_MODULO == "GFP"
		cFiltro := 'SRY->RY_MODULO $ "2|3"'
	Else
		cFiltro := 'SRY->RY_MODULO $ " |1|3"'
	EndIf
EndIf 
If cPaisLoc == "BRA" .And. !lOpeSoc
	If !Empty(cFiltro)
		cFiltro	+= " .And. "
	EndIf
	cFiltro += "SRY->RY_TIPO != 'O'"
EndIf

cFiltro := "@#" + cFiltro + "@#"
Return ( cFiltro ) 

/*/{Protheus.doc} fVldPerRtf
Verifica se o roteiro RTF pode ser cadastrado no perํodo
@type  		Static Function
@author		allyson.mesashi
@since		10.01.2019
@version	001
@return 	lRet - Indica se ้ permitido a inclusใo do roteiro RTF
/*/
Static Function fVldPerRtf()    
Local aArea			:= GetArea()
Local aAcolsRCH		:= {}
Local lRet			:= .T. 
Local cConteudo	  	:= ""
Local cContAut	  	:= ""
Local nPos			:= 0 
Local nPosDtFech	:= 0 
Local nPosAtu       := 0       
Local cRotFol		:= fGetRotOrdinar()
Local cRotAut		:= fGetCalcRot("9")
Local nPosRecno		:= 0
Local nAtualRecno   := 0

If ( Type("oGetRCH") == "O" ) 
	aAcolsRCH	:= oGetRCH:aCols
	nPosDtFech	:= GdFieldPos("RCH_DTFECH" ,oGetRCH:aHeader)
	nPosRoteir	:= GdFieldPos("RCH_ROTEIR" ,oGetRCH:aHeader)
	nPosRecno	:= GdFieldPos("RCH_REC_WT" ,oGetRCH:aHeader)
	nPosAtu		:= oGetRCh:nAt

	cRoteiro	:= If(!lGp490, aAcolsRCH[nPosAtu, nPosRoteir], cRoteiro)
	nAtualRecno :=  aAcolsRCH[nPosAtu, nPosRecno]

	// Verifica qual o perํodo aberto do roteiro FOL/AUT
	RCH->(dbSetOrder(RetOrdem("RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PERSEL")))
	cConteudo := xFilial("RCH",cFilRFQ)+cProcesso+cRotFol+"1"
	cContAut  := xFilial("RCH",cFilRFQ)+cProcesso+cRotAut+"1"
	If ( RCH->(MsSeek(cConteudo)) .and. RCH->(RECNO()) <> nAtualRecno ) .Or. ( RCH->(MsSeek(cContAut)) .and. RCH->(RECNO()) <> nAtualRecno ) 
		lRet := .T.                                                
		// Se o periodo ja estiver fechado, nao sera permitido selecionalo
		If !(RCH->(EoF())) .And. !Empty(aAcolsRCH[nPosAtu, nPosDTFech] )  
			MsgAlert( OemToAnsi( STR0047 ) , OemToAnsi( STR0021 ) )	// "Aviso"###"Este periodo ja foi encerrado e nao sera possivel a manutencao deste campo." 
			lRet:= .F.                                                                              
		Else
			// Caso ja exista um outro periodo selecionado no mesmo 
			If cPeriodo >= RCH->RCH_PER			
				MsgAlert( OemToAnsi( STR0153 ) + CRLF + OemToAnsi( STR0154 ) , OemToAnsi( STR0021 ) )// "Aviso"###"Nใo ้ permitido a inclusใo do roteiro 'Retificadora' em perํodo igual ou superior ao que estแ em aberto."##"Somente ้ possํvel a inclusใo do roteiro 'Retificadora' em perํodo que jแ foi fechado."
				lRet := .F.
			EndIf						
		EndIf
	EndIf	
EndIf     

RestArea(aArea)

Return( lRet )

/*/{Protheus.doc} fDtPgCalc
Verifica se o roteiro jแ foi calculado.
@type  		Static Function
@author		raquel.andrade
@since		03.12.2019
@version	001
@return 	lCalc - Indica que existe cแlculo realizado.
/*/
Function fDtPgCalc(cProcCalc, cRotCalc , cPerCalc, cSemCalc)    
Local aArea			:= GetArea()
Local cAliasSRC		:= GetNextAlias()
Local lCalc			:= .F. 
Local cPesqFil		:= AllTrim(cFilRFQ)+'%'
Local cWhere		:= ""	

DEFAULT cProcCalc 	:= ""
DEFAULT cRotCalc  	:= ""
DEFAULT cPerCalc	:= ""
DEFAULT cSemCalc	:= ""

If !Empty(cFilRFQ)
	cWhere += "SRC.RC_FILIAL LIKE '" + cPesqFil + "' AND "
EndIf

cWhere += "SRC.RC_PROCES = '"  + cProcCalc + "' AND "
cWhere += "SRC.RC_ROTEIR = '" + cRotCalc + "' AND "
cWhere += "SRC.RC_PERIODO = '" + cPerCalc + "' AND "
cWhere += "SRC.RC_SEMANA = '" + cSemCalc + "' "

cWhere := "%"+cWhere+"%"

BeginSql alias cAliasSRC
	SELECT COUNT(*) AS CONTADOR
	FROM %table:SRC% SRC 
	WHERE %exp:cWhere% AND 	
	SRC.%notDel%
EndSql

If ( cAliasSRC )->( !Eof() )
	If ( cAliasSRC )->CONTADOR > 0
		lCalc := .T.
	EndIf
EndIf

(cAliasSRC)->( dbCloseArea() )   

RestArea(aArea)

Return( lCalc )
