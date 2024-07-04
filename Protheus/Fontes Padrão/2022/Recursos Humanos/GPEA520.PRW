#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA520.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "HEADERGD.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   ³GPEA520   ³Autor  ³Valdeci Lira        ³ Data ³  06/12/07       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.      ³Funcao para inserir lancamentos de incidencias, por periodo     º±±
±±º           ³separados por processo, roteiro, periodo e numero de pag        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍ¹±±
±±ºUso        ³ GPEA520                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador³ Data   ³ FNC      		       ³  Motivo da Alteracao          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºLeandro Dr.|29/10/12|M12RH01         |Unificacao da Folha		            º±±
±±º           |        |  RHU210_01_08  |         								  º±±
±±ºSidney O.  |28/03/14|M_RH007 - TPCBNG|Alteracao do leiaute da tela          º±±
±±º           |        |                |da funcao gp520SelItemListBox         º±±
±±³Esther V.  |22/04/14|    M_RH003     |Replica V11 para V12. Tratamento do   ³±±
±±³           |        |                |parâmetro MV_ITMCLVL para aceitar '3',³±±
±±³           |        |                |nao obrigando o preenchimento dos     ³±±
±±³           |        |                |campos.                               ³±±
±±³Esther V.  |26/09/14|    TQPYXX      |Tratameno na funcao RgbSeqClear() para³±±
±±³           |        |                |verificar existencia do objeto antes  ³±±
±±³           |        |                |de modifica-lo.                       ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                      
Function Gpea520(nOpcAuto)       
	Local cFiltraRCH:= "Empty(RCH->RCH_DTFECH)"	//Variavel para filtro
	            
	Private aRotina 	:= MenuDef() 			// ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
	Private cCadastro 	:= OemToAnsi(STR0001)  	//"Cadastro de Incidencias"  
	Private aArray		:= {}					//Usada para filtros na mBrowse
	Private lUseOrg		:= ( SuperGetMv("MV_ORGCFG",NIL,"0") == "1" )
	Private lSetF3		:= .F.		//Variavel para saber se passou no f3 da matricula 
	Private cLancDemi	:= Upper( AllTrim( GetMv("MV_DEMISRC") ) )
	Private lItemClVl   := SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "1*3" // Define se trabalha com item e classe contabil

	//So exibe a tela se o parametro estiver configurado para o trabalho no mexico
	If( MV_MODFOL != "2" )
		Help("",1,"NAO_DISPONIVEL" )
		Return
	EndIf
	
	If ( nOpcAuto <> NIL )
	
		aRotSetOpc( "SRA" , NIL , nOpcAuto , .F. )
		nPos := aScan( aRotina , { |x| x[4] == nOpcAuto } )
		IF ( nPos == 0 )
			Break
		EndIF
		dbSelectArea( "SRA" )
		bBlock := &( "{ |a,b,c,d| " + aRotina[ nPos , 2 ] + "(a,b,c,d) }" )
		Eval( bBlock , "SRA" , SRA->( Recno() ) , nPos )
	Else	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Arquivo Esta Vazio                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !ChkVazio( "RCH" )
			Return
		EndIf    
		
		dbSelectArea( "RGB" )
		dbSelectArea( "RCH" )
		dbSetFilter({|| Empty(RCH->RCH_DTFECH)}, cFiltraRCH) 
		
		aArray := {"SRA", "SRV"}
		fFiltro("GPEA520",aArray,1)//1- Executa os Filtros    
	    	   	                    
		mBrowse( 6, 1,22,75, "RCH" )  
		
		fFiltro("GPEA520",aArray,0)//0- Limpa os Filtros
	EndIf

Return(.T.) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA520   ºAutor  ³Valdeci Lira        º Data ³  06/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta a tela para a insercao dos dados na tabela           º±±
±±º          ³ de incidencias RGB, filtrada pelos campos superiores de    º±±
±±º          ³ cabecalho RCH											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA520                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gpea520mnt( cAlias , nReg , nOpcx)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis Local                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea()	//Area corrente
	Local aAdvSize		:= {}			//Array com as dimensoes da tela
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local nOpcao		:= 0 			//0- BOTAO CANCELAR SELECIONADO, 1- BOTAO OK ACIONADO
	Local aButtons 		:= {} 
	Local lMensagem		:= .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis Privadas de trabalho                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Private aHeader 	    := {}	//-> Array com o cabecalho da getDados
	Private aColsAnt		:= {}	//-> Array com a copia da GetDados antes da alteracao para futura comparacao
	Private aColsRec		:= {}	//-> Array com os recnos dos registros exibidos na GetDados
	Private aVirtual		:= {}	//-> Array com os campos virtuais do Alias iformado
	Private aRGBCols		:= {}	//-> Array com os registros da GetDados
	Private aGdAltera		:= {}	//-> Array com os campos alteraveis da GetDados
	Private aGdGrava		:= {}	//-> Array com os nomes e posicoes dos campos que sera utilizado nas rotinas de gravacao
	Private cAliasRGB		:= "RGB"
	Private cFil			:= XFilial("RGB", SRA->RA_FILIAL)
	Private cFilRCH			:= XFilial("RCH", SRA->RA_FILIAL)
	                    
	//Posicoes dos campos na getDados	
	Private nPosFilial  
	Private nPosMat
	Private nPosNome
	Private nPosSemana
	Private nPosPD
	Private nPosDescPD
	Private nPosQtdSem
	Private nPosHoras
	Private nPosValor
	Private nPosDtRef
	Private nPosCC
	Private nPosParcel
	Private nPosTipo1
	Private nPosTipo2
	Private nPosSeq
	Private nPosNumId
	Private nPosCodFun
	Private nPosPosto
	Private nPosDepto
	Private nPosDum
	Private nPosDDois
	Private nPosDTres
	Private nPosDQuatro
	Private nPosDCinco
	Private nPosDSeis
	Private nPosDSete
	Private nPosDeleted
	Private nPosRegWT
	Private nPosItem
	Private nPosClasse
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos da tela e variaveis de conteudo atreladas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCodProcesso	:= If( Empty( RCH ->RCH_PROCES ), Space( TamSx3( "RCH_PROCES" )[1]), RCH -> RCH_PROCES )
	Private cProcessoAnt
	Private cCodRoteiro		:= If( Empty( RCH ->RCH_ROTEIR ), Space( TamSx3( "RCH_ROTEIR" )[1]), RCH -> RCH_ROTEIR )
	Private cRoteiroAnt
	Private cCodPeriodo	   	:= If( Empty( RCH ->RCH_PER ), Space( TamSx3( "RCH_PER" )[1]), RCH -> RCH_PER )
	Private cPeriodoAnt
	Private cNumPagamento	:= If( Empty( RCH ->RCH_NUMPAG ), Space( TamSx3( "RCH_NUMPAG" )[1]), RCH -> RCH_NUMPAG )
	Private cNumPagAnt
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Variaveis usadas no F3 - NumPg RGB_SEMANA 	  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Private cProcesso := If( Empty( RCH ->RCH_PROCES ), Space( TamSx3( "RCH_PROCES" )[1]), RCH -> RCH_PROCES )
	Private cPeriodo  := If( Empty( RCH ->RCH_PER ), Space( TamSx3( "RCH_PER" )[1]), RCH -> RCH_PER )
	Private cRot	  := If( Empty( RCH ->RCH_ROTEIR ), Space( TamSx3( "RCH_ROTEIR" )[1]), RCH -> RCH_ROTEIR )
	
	Private cDtInicialFinal := If( !Empty( RCH ->RCH_DTINI ) .AND. !Empty( RCH ->RCH_DTFIM ), dToc(RCH ->RCH_DTINI) + " - " + dToc(RCH ->RCH_DTFIM) , "" )
	Private dDtInicial		:= If( !Empty( RCH ->RCH_DTINI 	  ) , RCH ->RCH_DTINI , "" )
	Private dDtFinal		:= If( !Empty( RCH ->RCH_DTFIM ) , RCH ->RCH_DTFIM , "" )
	Private oGet 
	Private bBtGravar		:= {|| Nil}
	Private bBtRefresh		:= {|| Nil}
	Private bBtOk			:= {|| Nil}
	Private bBtSair  		:= {|| Nil}
	Private lStSalvar		:= .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Variaveis usadas para filtro usando FilBrowse³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aIndexSrv 	:= {}		   	//-> Variavel de filtro para FilBrowse, SRV
	Private cFilSrv   			   		//-> Variavel de filtro para FilBrowse, SRV
	Private bFilBrwSrv	:= {|| Nil}		//-> Variavel para Filtro
	Private aIndexSra 	:= {}		   	//-> Variavel de filtro para FilBrowse, SRV
	Private cFilSra   			   		//-> Variavel de filtro para FilBrowse, SRV
	Private bFilBrwSra	:= {|| Nil}		//-> Variavel para Filtro
	
	If cPaisLoc == "DOM"
		lMensagem := .F.
	Endif
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Esta variavel, a nOpcNewGd, informara a instancia da GetDados³
	³ o que podera ser feito na get. So alterar..., ou So inserir..³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	_SetOwnerPrvt( "nOpcNewGd", IF( nOpcX == 3 , GD_INSERT + GD_UPDATE + GD_DELETE, ))
	nOpcx := 4
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/  
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= {aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5}
	aAdd( aObjCoords , {100, 30, .T., .F. } )
	aAdd( aObjCoords , {100, 100, .T., .T.} )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	cCadastro  := OemToAnsi(STR0001)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia a montagem da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN SEQUENCE
	
		DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
		DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7], 0 TO aAdvSize[6], aAdvSize[5] OF GetWndDefault() PIXEL

	 /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   ³ Processo, Roteiro, Periodo, Num. Pag e Data Inicial/Final ³
	   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	   //CRIA OS GROUPS
	   //[POSICAO DE INICIO]                       [POSICAO DE FIM] (ABRE COMO O DESENHO DE UMA CAIXA)[TAMANHO DO OBJETO][CAPTION DO OBJETO, NESTE CASO LABEL]
		@ aObjSize[1,1],aObjSize[1,2] 		GROUP oGroup TO aObjSize[1,1]+30 , aObjSize[1,4]*0.19	LABEL OemToAnsi(STR0002) OF oDlg PIXEL // Matricula:
		oGroup:oFont:= oFont
		
	 	@ aObjSize[1,1],aObjSize[1,4]*0.20	GROUP oGroup TO aObjSize[1,1]+30 , aObjSize[1,4]*0.39	LABEL OemToAnsi(STR0003) OF oDlg PIXEL // Nome:
		oGroup:oFont:= oFont
	   
	   	@ aObjSize[1,1],aObjSize[1,4]*0.40	GROUP oGroup TO aObjSize[1,1]+30 , aObjSize[1,4]*0.59	 LABEL OemToAnsi(STR0004) OF oDlg PIXEL	// Admiss„o:
	   	oGroup:oFont:= oFont
	   	
	   	@ aObjSize[1,1],aObjSize[1,4]*0.60	GROUP oGroup TO aObjSize[1,1]+30 , aObjSize[1,4]*0.79	 LABEL OemToAnsi(STR0005) OF oDlg PIXEL	// Admiss„o:
	   	oGroup:oFont:= oFont
	   	
		@ aObjSize[1,1],aObjSize[1,4]*0.80	GROUP oGroup TO aObjSize[1,1]+30 , aObjSize[1,4] LABEL OemToAnsi(STR0006) OF oDlg PIXEL	// Admiss„o:
	   	oGroup:oFont:= oFont   	
		                     
		//POSICAO X,Y DE INICIO
	   	@ aObjSize[1,1]+10,aObjSize[1,2]+10 ; //DEFINICAO DA POSICAO
	   		MSGET oCodProces Var cCodProcesso PICTURE GetSx3Cache( "RCH_PROCES" , "X3_PICTURE" ) F3 "RCH02" ; //DEFINICAO DO OBJETO PROCESSO COD PROCES
	   		   VALID ExistCpo("RCH", cCodProcesso , 4) ;
		    SIZE 050,10 OF oDlg PIXEL //DEFINICAO DO TAMANHO EM TELA
		                        
		@ aObjSize[1,1]+10,aObjSize[1,4]*0.20+10 ; //DEFINICAO DA POSICAO
	   		MSGET oCodRoteiro Var cCodRoteiro PICTURE GetSx3Cache( "RCH_ROTEIR" , "X3_PICTURE" ) F3 "RCH03" ; //DEFINICAO DO OBJETO COD ROTEIRO  
	   			VALID ExistCpo("RCH", cCodProcesso+cCodRoteiro , 4) ;
		    SIZE 050,10 OF oDlg PIXEL //DEFINICAO DO TAMANHO EM TELA 
		    
		@ aObjSize[1,1]+10,aObjSize[1,4]*0.40+10 ; //DEFINICAO DA POSICAO
	   		MSGET oCodPeriodo Var cCodPeriodo PICTURE GetSx3Cache( "RCH_PER" , "X3_PICTURE" ) F3 "RCH04" ; //DEFINICAO DO OBJETO COD ROTEIRO
	   	  		VALID ExistCpo("RCH", cCodProcesso+cCodRoteiro+cCodPeriodo , 4) ;
		    SIZE 050,10 OF oDlg PIXEL //DEFINICAO DO TAMANHO EM TELA 
					    
		@ aObjSize[1,1]+10,aObjSize[1,4]*0.60+10 ; //DEFINICAO DA POSICAO
	   		MSGET oNumPagamento Var cNumPagamento PICTURE GetSx3Cache( "RCH_NUMPAG" , "X3_PICTURE" ) F3 "RCH05" ; //DEFINICAO DO OBJETO NUM PAGAMENTO
	   			VALID ExistCpo("RCH", cCodProcesso+cCodRoteiro+cCodPeriodo+cNumPagamento , 4)  ;
		    SIZE 050,10 OF oDlg PIXEL //DEFINICAO DO TAMANHO EM TELA
		                       
		@ aObjSize[1,1]+10,aObjSize[1,4]*0.80+10;//DEFINICAO DA POSICAO
			SAY cDtInicialFinal; 
			SIZE 120,10 OF oDlg PIXEL FONT oFont //DEFINICAO DO TAMANHO EM TELA
	           
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Cria os Arrays de Campos para logo abaixo instanciar a       ³
		³ getDados e exibir os campos segundo as variaveis montadas    ³
		³ aCols e aHeader										       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		dbSelectArea(cAliasRGB)
	   	gp520MontaGetDados(cAliasRGB, cFil, @aVirtual, @aColsRec, @aRGBCols, nOpcx)
	
		//INSTANCIA A GETDADOS
	   	oGet := MsNewGetDados():New(aObjSize[2,1]			,;// nTop
									 aObjSize[2,2]			,;// nLeft
									 aObjSize[2,3]			,;// nBottom
		                             aObjSize[2,4]			,;// nright
									 nOpcNewGd    			,;// controle do que podera ser realizado na GetDado - nstyle
									 "gp520LinOk" 			,;// funcao para validar a edicao da linha - ulinhaOK
									 "gp520TudoOk"			,;// funcao para validar todas os registros da GetDados - uTudoOK
		  							 NIL      		    	,;// cIniCPOS
									 aGdAltera    			,;// aAlter
									 0            		 	,;// nfreeze
									 99999					,;// nMax
									 NIL,;//"gp520CampoOk"			,;// cFieldOK
									 NIL					,;// usuperdel
									 .T.					,;// udelOK
									 @oDlg					,;// objeto de dialogo - oWnd
									 @aHeader				,;// Vetor com Colunas - AparHeader
									 @aRGBCols				 ;// Vetor com Header - AparCols
									)
	  	 	
	 	// Verificar se o roteiro foi informado antes de incluir a linha.
	    oGet:oBrowse:bGotFocus	:= { || remontaGetDados(cAliasRGB, cFil, @aVirtual, @aColsRec, @aRGBCols, nOpcx) }
	 	oGet:oBrowse:bLostFocus	:= { || If(!gp520LinOk(), oGet:oBrowse:SetFocus(), .T.) }
	
		 	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define Enchoice Bar³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		bBtSair	:= {|| nOpcao:= 0, lStSalvar:= .F., oDlg:End(), FinalizaFilBrowse() }
		
		If ( nOpcx==3 .or. nOpcx==4 )    
			bBtOk := { || If ( lStSalvar:= Gp520TudoOk(), MsAguarde( { || Gpea520Grava(cAliasRGB, cFil, aColsRec,lMensagem,nOpcx), OemToAnsi(STR0008) } ), .T. ), If( lStSalvar, oDlg:End(), .T. ) }
		Else
			bBtOk	:= bBtSair
		EndIf

		bBtRefresh	:= { || RemontaGetDados(cAliasRGB, cFil, @aVirtual, @aColsRec, @aRGBCols, nOpcx) }

		bBtGravar	:= { || If ( Gp520TudoOk(), MsAguarde( { || Gpea520Grava(cAliasRGB,cFil, aColsRec,lMensagem,nOpcx), OemToAnsi(STR0008) } ) , .F. ) } 

		aAdd(aButtons, {	"TK_REFRESH",;
		   					bBtRefresh,;
		       	   			OemToAnsi(STR0022),;	//"Atualiza a Listagem"
		       	   			OemToAnsi(STR0021);		//"Atualizar"
		        		}	)

		aAdd(aButtons,	{	"SALVAR",;
							bBtGravar,;
	       	   				OemToAnsi(STR0020),;	//"Grava as alterações"
		       	   			OemToAnsi(STR0019);		//"Gravar"
		     			}	)


         
	 	//Exibe a tela
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bBtOk, bBtSair, NIL, aButtons)
	
		//Se o btn pressionado for o ok entao sera direcionado para a rotina de gravao
		If ( (nOpcao == 1 ) .and. lStSalvar )
			If ( Gp520TudoOk(), MsAguarde( { || Gpea520Grava(cAliasRGB,cFil, aColsRec,lMensagem,nOpcx), OemToAnsi(STR0008) } ) , .F. )
		EndIf 
		
	END SEQUENCE
Return

  

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Valdeci Lira     ³ Data ³01/11/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA520                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Static Function MenuDef()
	Local aRotina :=  {	{ STR0028 , "PesqBrw"		, 0 , 1 },		 ;  //"Pesquisar"
						{ STR0011 , "Gpea520mnt"	, 0 , 2 },  	 ;  //"Visualizar"
						{ STR0012 , "Gpea520mnt"	, 0 , 4 }	   	 ;  //"Modificar( Incluir /Alterar / Deletar )
		               }    
	
	 //					{ STR0013 , "Gpea520mnt"	, 0 , 5 }	   	 ;  //"Deletar"
Return aRotina   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³gp520MontaGetDados   ºAutor  ³Valdeci Lira º Data ³  06/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Function responsavel pela montagem do cabecalho e itens da  	  º±±
±±º          ³GetDados preparando a para o uso do usuario e do fonte          º±±
±±º          ³cAliasRGB -> Alias que montara a GetDados						  º±±
±±º          ³cFil		-> Filial a qual pertence o alias 					  º±±
±±º          ³aVirtual	-> Array com os campos virtuais da tabela indicada no º±±
±±º          ³cAliasRGB														  º±±
±±º          ³aColsRec	-> Array com os recnos dos registros que estao na Get º±±
±±º          ³aRGBCols	-> Array com os registros exibidos na GetDados   	  º±±
±±º          ³nOpcx		-> Menu selecionado no inicio do programa			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEA520                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function gp520MontaGetDados(cAliasRGB, cFil, aVirtual, aColsRec, aRGBCols, nOpcx)
	Local cQueryCond	:= ""							//Condicao de filtro executada caso seja banco SQL
	Local cKeySeek		:= ""							//Chave para procura, usada em gdmontacols
	Local aGdNaoAltera	:= {}
	Local aGpa520Field	:= {}							//Array de campos que nao serao executados
	Local aVisual		:= {}							//Array de campos visuais montado pela gdmontacols
	Local nX			:= 0
	Local nI 			:= 0
	Local nTamRGBCols	:= 0
	Local nUsado  		:= 0 
	Local aTemp
		     
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta Query para a Selecao das Informacoes em GdMontaCols    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	If Len(AllTrim(cFil)) > 0
		//	cQueryCond	:= " RGB_FILIAL='"+ cFil +"'"
	EndIf
		
	If !Empty(cCodProcesso)
		If !Empty(cQueryCond)
			cQueryCond	+= " AND " 
		EndIf
		cQueryCond += " RGB_PROCES='"+ strTran(cCodProcesso, "'", "''") +"'"
	EndIf

	If !Empty(cCodRoteiro)			                                             
		If !Empty(cQueryCond)
			cQueryCond	+= " AND " 
		EndIf
		cQueryCond	+= " RGB_ROTEIR='"+ strTran(cCodRoteiro, "'", "''") +"'"
	EndIf

	If !Empty(cCodPeriodo)
		If !Empty(cQueryCond)
			cQueryCond	+= " AND " 
		EndIf
		cQueryCond	+= " RGB_PERIOD='"+ strTran(cCodPeriodo, "'", "''") +"'"
	EndIf

	If !Empty(cNumPagamento)
		If !Empty(cQueryCond)
			cQueryCond	+= " AND " 
		EndIf
		cQueryCond	+= " RGB_SEMANA='"+ strTran(cNumPagamento, "'", "''") +"'"
	EndIf
	
	cQueryCond	+= " AND D_E_L_E_T_<>'*' "

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define os Campos que nao serao Mostrados                     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	If !lItemClVl
		aGpa520Field := {;
					"RGB_PROCES" ,;
					"RGB_PERIOD" ,;
					"RGB_ROTEIR" ,;
					"RGB_ITEM" ,;
					"RGB_CLVL" ;
				}
	Else
		aGpa520Field := {;
				"RGB_PROCES" ,;
				"RGB_PERIOD" ,;
				"RGB_ROTEIR" ;
				}
	EndIf
	
    
    //Tabelas usadas para o lancamento
   	dbSelectArea( "CTT" )
	dbSelectArea( "RCL" )
	dbSelectArea( "SRJ" )   	
	dbSelectArea( "SQB" )   	
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿//
	//³Troca a posição do campo SEMANA         ³//
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ//
	aHeader		:= GdMontaHeader(NIL, NIL, NIL, cAliasRGB, aGpa520Field )
	nPosSemana	:= AScan(aHeader, { |aColumn| aColumn[__AHEADER_FIELD__] == "RGB_SEMANA"} )
	nPosNome	:= AScan(aHeader, { |aColumn| aColumn[__AHEADER_FIELD__] == "RGB_NOME"} )

	If nPosSemana > 0 .AND. nPosNome > 0
		aTemp:= aHeader[nPosSemana]
		ADel(aHeader, nPosSemana)
		AIns(aHeader, nPosNome)
		aHeader[nPosNome]:= aTemp
		aGpa520Field	:= NIL
	Else
		aHeader	:= {}
	EndIf
	
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta a chave para Pesquisa em GdMontaCols                   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cKeySeek := ( cFil + cCodProcesso + cCodPeriodo + cNumPagamento + cCodRoteiro )
		
	RGB->(dbSetOrder( RetOrder( "RGB" , "RGB_FILIAL+RGB_PROCES+RGB_PERIOD+RGB_SEMANA+RGB_ROTEIR+RGB_MAT+RGB_PD+RGB_SEQ")))
	aRGBCols := GdMontaCols(	@aHeader,;
								@nUsado,;
								@aVirtual,;
								@aVisual,;
								cAliasRGB,;
								aGpa520Field,;
								@aColsRec,;
								cAliasRGB,;
								cKeySeek,;
								NIL,;
								NIL,;
								NIL,;
								NIL,;
								NIL,;
								NIL,;
								NIL,;
								NIL,;
								cQueryCond,;
								.F.,;
								.F.,;
								.T.,;
								NIL,;
								NIL,;
								NIL,;																
								NIL,;
								NIL,;
								NIL,;
								NIL,;
								NIL,;
								NIL,;
								NIL,;
								nOpcx;																																																																
								)
	RGB->( dbSetOrder(1) )
	
    
	//RESGATA A POSICAO DOS CAMPOS 
	nPosFilial      := GdFieldPos( "RGB_FILIAL"	    , aHeader )
	nPosMat 		:= GdFieldPos( "RGB_MAT"	    , aHeader )
	nPosNome		:= GdFieldPos( "RGB_NOME" 	    , aHeader )
	nPosSemana		:= GdFieldPos( "RGB_SEMANA"		, aHeader )
	nPosPD			:= GdFieldPos( "RGB_PD" 	    , aHeader )
	nPosDescPD		:= GdFieldPos( "RGB_DESCPD"	    , aHeader )
	nPosQtdSem		:= GdFieldPos( "RGB_QTDSEM"		, aHeader )
	nPosHoras		:= GdFieldPos( "RGB_HORAS"  	, aHeader )
	nPosValor		:= GdFieldPos( "RGB_VALOR"	    , aHeader )
	nPosDtRef		:= GdFieldPos( "RGB_DTREF"  	, aHeader )
	nPosCC			:= GdFieldPos( "RGB_CC"  	    , aHeader )
	nPosParcel		:= GdFieldPos( "RGB_PARCEL"	    , aHeader )
	nPosTipo1		:= GdFieldPos( "RGB_TIPO1" 		, aHeader )
	nPosTipo2		:= GdFieldPos( "RGB_TIPO2"		, aHeader )
	nPosSeq			:= GdFieldPos( "RGB_SEQ"    	, aHeader )
	nPosNumId		:= GdFieldPos( "RGB_NUMID"  	, aHeader )
	nPosCodFun		:= GdFieldPos( "RGB_CODFUN" 	, aHeader )
	nPosPosto		:= GdFieldPos( "RGB_POSTO"		, aHeader )
	nPosDepto		:= GdFieldPos( "RGB_DEPTO"		, aHeader )
	nPosDum			:= GdFieldPos( "RGB_DUM"    	, aHeader )
	nPosDDois		:= GdFieldPos( "RGB_DDOIS"   	, aHeader )
	nPosDTres		:= GdFieldPos( "RGB_DTRES"  	, aHeader )
	nPosDQuatro		:= GdFieldPos( "RGB_DQUATR"		, aHeader )
	nPosDCinco		:= GdFieldPos( "RGB_DCINCO" 	, aHeader )
	nPosDSeis		:= GdFieldPos( "RGB_DSEIS"  	, aHeader )
	nPosDSete		:= GdFieldPos( "RGB_DSETE"  	, aHeader )
	nPosItem        := GdFieldPos( "RGB_ITEM"  	    , aHeader )
	nPosClasse      := GdFieldPos( "RGB_CLVL"  	    , aHeader )	
	nPosDeleted		:= GdFieldPos( "GDDELETED" )
	nPosRegWT       := GdFieldPos( "RGB_REC_WT"  	, aHeader )
    
    /*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Transforma os campos Filial/Pagto em Visuais   			   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdd( aVisual, "RGB_FILIAL" )
	aHeader[ nPosFilial, __AHEADER_VISUAL__ ] := "V"
                              
	If nPosSemana > 0	
		aAdd(aVisual, "RGB_SEMANA")
		aHeader[nPosSemana, __AHEADER_VISUAL__] := "V"
		aHeader[nPosSemana, __AHEADER_INITPAD__] := "cNumPagamento"
	
		For nX:= 1 To Len(aRGBCols)
			If Empty(aRGBCols[nX, nPosSemana])
				aRGBCols[nX, nPosSemana] := cNumPagamento
			EndIf
		Next
	EndIf	
    
    /*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega, apenas, os Campos Editaveis            			   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aGdAltera	:= {}  
	aGdGrava	:= {}
	For nX := 1	To nUsado
		If (;
				( aScan( aVirtual 		, aHeader[ nX , 02 ] ) == 0 );
				.and.;
		   		( aScan( aVisual  		, aHeader[ nX , 02 ] ) == 0 );
		   		.and.;
		   		( aScan( aGpa520Field	, aHeader[ nX , 02 ] ) == 0 );
		   		.and.;
		   		( aScan( aGdNaoAltera	, aHeader[ nX , 02 ] ) == 0 );
		  	)
			aAdd( aGdAltera , aHeader[ nX , 02 ])												//-> aAlter da getDados
			aAdd( aGdGrava , {aHeader[ nX , 02 ],GdFieldPos( aHeader[ nX , 02 ], aHeader )} )	//-> array utilizado na rotina de gravacao
		EndIF
	Next nX 
    
    //INSERE O REGISTRO INFORMANDO A SEQUENCIA DA VERBA, E O TIPO
    aAdd( aGdGrava , {"RGB_SEQ", nPosSeq})
    aAdd( aGdGrava , {"RGB_TIPO2", nPosTipo2})
    
	//CARREGA AS DESCRICOES DE VERBAS E NOMES DE FUNCIONARIOS
	FinalizaFilBrowse()
	nTamRGBCols := Len(aRGBCols)
   	For nI := 1 To nTamRGBCols
		gp520PreencheDesc( "DESC_VERBA"      	, aRGBCols[ nI, nPosPD  ], nI, cFil, @aRGBCols, "FONTE")
		gp520PreencheDesc( "FUNC_COMPLETO"		, aRGBCols[ nI, nPosMat ], nI, cFil, @aRGBCols, "FONTE")
		
		If (Empty(aRGBCols[ nI, nPosTipo2]), aRGBCols[ nI, nPosTipo2] := "I", .F.)
	Next

	//Variaveis para o controle da alteracao do cabecalho
	cRoteiroAnt := cCodRoteiro
	cPeriodoAnt := cCodPeriodo
	cProcessoAnt:= cCodProcesso 
	cNumPagAnt  := cNumPagamento
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Elimina do acols as matriculas filtradas do SRA              |
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fAcolsSPF(@aRGBCols)	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ salva o acols antes da alteracao 	 			  			   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aColsAnt	:= aClone( aRGBCols )
	
	// atualiza a getdados
	If !(oGet == Nil)
		oGet:aCols := aClone(aRGBCols)
		oGet:Refresh()
	EndIf
	               		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRV" )	
	dbSelectArea( "SRM" )		
	dbSelectArea( "SRA" )
	
	aIndexSRV := {} 
	aSize(aIndexSrv, 0)
   	MontaF3SRV(.T., cCodRoteiro, cCodProcesso, @aIndexSrv, .T.) 
   	
   	//Filtra SRA
  	EndFilBrw("SRA",aIndexSRA)	
	//cFilSra     := "(RA_PROCES='"+ cCodProcesso +"')"
	//bFilBrwSra	:= {|| FilBrowse("SRA",@aIndexSRA,@cFilSRA) }
   	Eval(bFilBrwSra) 
           	
Return (.T.)   

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³remontaGetDados()		 ³ Autor ³ Valdeci Lira        ³ Data ³13/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza a listag da getDados com base na alter do cabecalho de tela	 ³±±
±±º          ³cAliasRGB -> Alias que montara a GetDados						  		 º±±
±±º          ³cFil		-> Filial a qual pertence o alias 					  		 º±±
±±º          ³aVirtual	-> Array com os campos virtuais da tabela indicada no 		 º±±
±±º          ³cAliasRGB														  		 º±±
±±º          ³aColsRec	-> Array com os recnos dos registros que estao na Get 		 º±±
±±º          ³aRGBCols	-> Array com os registros exibidos na GetDados   	  		 º±±
±±º          ³nOpcx		-> Menu selecionado no inicio do programa			 		 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA520                                                    			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function remontaGetDados(cAliasRGB, cFil, aVirtual, aColsRec, aRGBCols, nOpcx )
   	If cabecalhoAlterado()
    	MsAguarde( { || gp520MontaGetDados(cAliasRGB, cFil, @aVirtual, @aColsRec, @aRGBCols, nOpcx ) , OemToAnsi(STR0008) } )
       
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Variaveis alteradas para serem utilizadas no ³
		//³F3 - NumPg RGB_SEMANA						³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	cProcesso := cCodProcesso
		cPeriodo  := cCodPeriodo
		cRot	  := cCodRoteiro		
	EndIf    	
Return (.T.)

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³cabecalhoAlterado()	 ³ Autor ³ Valdeci Lira        ³ Data ³13/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o cabecalho de tela foi alterado, ou seja processo, roteiro³±±
±±³			 ³Periodo e numero de pagamento											 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA520                                                    			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function cabecalhoAlterado()
	Local lAlterado

	lAlterado :=	(cCodRoteiro	<> cRoteiroAnt)		;
		        	.Or.						  		;
        			(cCodPeriodo	<> cPeriodoAnt)		;
		        	.Or.								;
        			(cCodProcesso	<> cProcessoAnt)	;   
		           	.Or.								;
		        	(cNumPagamento	<> cNumPagAnt)		;
        
Return (lAlterado)

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AtualizaDtInicialFinal ³ Autor ³ Valdeci Lira        ³ Data ³13/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o Say do cabecalho de tela com a data de um periodo selecionad³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA520                                                    			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AtualizaDtInicialFinal()    
	Local aArea := getArea()

	cDtInicialFinal := If( !Empty( RCH ->RCH_DTINI ) .AND. !Empty( RCH ->RCH_DTFIM ), dToc(RCH ->RCH_DTINI) + " - " + dToc(RCH ->RCH_DTFIM) , "" )		
	dDtInicial 		:= If( !Empty( RCH ->RCH_DTINI ) , RCH ->RCH_DTINI , "  /  /  " )
	dDtFinal		:= If( !Empty( RCH ->RCH_DTFIM ) , RCH ->RCH_DTFIM , "  /  /  " )	  
	cCodPerAnt 		:= cCodPeriodo
	
	restArea(aArea)
Return ( .T. )
/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp520PreencheDesc(cTipo, cChave)  ³ Autor ³ Valdeci Lira        ³ Data ³13/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a descricao do campo conforme o tipo e o parametro fornecido				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTipo	-> Indica qual a descricao deve ser passada. Ex. FUNC_COMPLETO retornara	³±±
±±³			 ³ os dados necessarios para preencher a tabela RGB, com base na tabela SRA			³±±
±±³			 ³cChave-> Indica a chave de pesquisa que para encontrar a descricao pesquisada		³±±
±±³			 ³nLinha-> Indica em qual linha devera ser colocada as descricoes pesquisadas		³±±
±±³			 ³cFil	-> Indica a filial de trabalho, Default xFilial(tabela)						³±±
±±³			 ³aRGBCols-> Referencia para o retorno dos dados pesquisados						³±±
±±³			 ³cOrigem-> Informa a origem da chamada, se F3 ou fonte								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA520                                                    						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function gp520PreencheDesc(cTipo, cChave, nLinha, cFil, aRGBCols, cOrigem)
	Local 	lRetorno	:= .F.
	Local   aArea		:= GetArea()
	Local	nPosSem
	Local aLinha := {}
	Default cOrigem   := "F3"
	Default cChave    := M->RGB_PD
	Default cTipo     := ""
    Default nLinha 	  := Nil
    
	lGp580Auto := If (Type("lGp580Auto") == "U",.F.,lGp580Auto)    
	
	If nLinha == Nil
		nLinha	:=	n
	EndIf
                        
    If Empty(cTipo) .Or. Empty(cChave)
  		Return ( .F. )
    EndIf
  
	Do Case		
		Case cTipo == "FUNC_COMPLETO"
			Default cFil := XFilial("SRA",SRA->RA_FILIAL)                                                                                  
			dbSelectArea( "SRA" )
			SRA->( dbSetOrder(1))    
			If ( cOrigem == "F3" )
		   		SRA->( dbSeek(cFil+cChave) )
		 	ElseIf ( cOrigem == "FONTE" )
		 		SRA->( dbSeek( aRGBCols[ nLinha, nPosFilial ]+aRGBCols[ nLinha, nPosMat ] ) )
		 	EndIf
		   	
			nPosNome := GdFieldPos( "RGB_NOME" 	    , aHeader )
			If cOrigem == "F3"			   	                         

				nPosFilial      := GdFieldPos( "RGB_FILIAL"	    , aHeader )
				nPosCC			:= GdFieldPos( "RGB_CC"  	    , aHeader )
				nPosCodFun		:= GdFieldPos( "RGB_CODFUN" 	, aHeader )
				nPosPosto		:= GdFieldPos( "RGB_POSTO"		, aHeader )
				nPosDepto		:= GdFieldPos( "RGB_DEPTO"		, aHeader )
				nPosItem		:= GdFieldPos( "RGB_ITEM"		, aHeader )
				nPosClasse		:= GdFieldPos( "RGB_CLVL"		, aHeader )
				nPosSem			:= GdFieldPos( "RGB_SEMANA"		, aHeader )

				If nPosSem > 0 .AND. !Type("cNumpagto") == "U"
					If lGp580Auto
						aCols[ n, nPosSem	] := cNumpagto
					Else
						oGet:aCols[ oGet:nAt, nPosSem	] := cNumpagto
					EndIf
				EndIf

				If nPosFilial > 0
					If lGp580Auto
						aCols[ n, nPosFilial	] := SRA->RA_FILIAL
					Else
						oGet:aCols[ oGet:nAt, nPosFilial	] := SRA->RA_FILIAL
					EndIf
				EndIf
				If nPosNome > 0
					If lGp580Auto
						aCols[ n, nPosNome	] := SRA->RA_NOME					
					Else				
						oGet:aCols[ oGet:nAt, nPosNome		] := SRA->RA_NOME
					EndIf
				EndIf
				If nPosCodFun > 0
					If lGp580Auto
						aCols[ n, nPosCodFun	] := SRA->RA_CODFUNC
					Else				
						oGet:aCols[ oGet:nAt, nPosCodFun	] := SRA->RA_CODFUNC
					EndIf
				EndIf
				If nPosCC > 0
					If lGp580Auto
						aCols[ n, nPosCC	] := SRA->RA_CC
					Else				
						oGet:aCols[ oGet:nAt, nPosCC	] := SRA->RA_CC
					EndIf
				EndIf
				If nPosDepto > 0 
					If lGp580Auto
						aCols[ n, nPosDepto	] := SRA->RA_DEPTO
					Else				
						oGet:aCols[ oGet:nAt, nPosDepto	] := SRA->RA_DEPTO
					EndIf
				EndIf
				If nPosPosto > 0
					If lGp580Auto
						aCols[ n, nPosPosto	    ] := SRA->RA_POSTO
					Else				
						oGet:aCols[ oGet:nAt, nPosPosto	    ] := SRA->RA_POSTO
					EndIf
				EndIf
				If nPosItem > 0
					If lGp580Auto
						aCols[ n, nPosItem ] := SRA->RA_ITEM
					Else
						oGet:aCols[ oGet:nAt, nPosItem ] := SRA->RA_ITEM
					EndIf
				EndIf
				If nPosClasse > 0
					If lGp580Auto
						aCols[ n, nPosClasse ] := SRA->RA_CLVL
					Else
						oGet:aCols[ oGet:nAt, nPosClasse ] := SRA->RA_CLVL				
					Endif
				Endif
			   	
			   	If (FunName() == "GPEA590")
			   		gp520MoveFocoCol( SRV->RV_TIPO )
			   	Else
				   	gp520MoveFocoCol("MAT")		
				EndIf
			Else
				aRGBCols[ nLinha, nPosNome		] := SRA->RA_NOME
				
			EndIf				
			lRetorno := .T.
			
		Case cTipo == "DESC_VERBA" 			
			Default cFil := XFilial("SRV")        			
			
			nPosPD		:= GdFieldPos( "RGB_PD" 	, aHeader )			
			nPosTipo1	:= GdFieldPos( "RGB_TIPO1" 	, aHeader )
			PosSRV( cChave, XFilial("SRV") , "RV_COD" )
			
			If (cOrigem == "F3") .And. ((cPaisLoc != "RUS" .Or. SRV->RV_LEEINC == "1"))				
				If lGp580Auto
					aLinha := aCols[n]
				Else
					aLinha := oGet:aCols[n]
				EndIf
				If nPosPd > 0
					aLinha[nPosPd] := SRV->RV_COD
				EndIf				
				
				If nPosTipo1 > 0 
					If IsInCallStack( "GPEA640" )
						oGet:aCols[ oGet:nAt, nPosTipo1 	] := "H" 
						gp520MoveFocoCol( "DUM" )					
					Else
						aLinha[nPosTipo1] := SRV->RV_TIPO						
						If(!Empty(SRV->RV_TIPO), gp520MoveFocoCol( SRV->RV_TIPO ), gp520MoveFocoCol( "PD" ))
					EndIf                                                    
				EndIf
			ElseIf cPaisLoc != "RUS" .Or. SRV->RV_LEEINC == "1"
				aLinha := aRGBCols[nLinha]
			EndIf
			/*<aLinha> guarda uma referência ao registro que está em oGet:aCols, aCols ou aRGBCols*/			
			PutRVCpos(aHeader,aLinha,nLinha)

			lRetorno := .T.			
	End Case

	RestArea( aArea )		
Return ( lRetorno )

/*/{Protheus.doc} PutRVCpos
	Preenche os campos de aLinha que sejam da SRV.
@author PHILIPE.POMPEU
@since 07/02/2017
@version P12
@param aHeader, array, (Descrição do parâmetro)
@param aLinha, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function PutRVCpos(aHeader,aLinha,nLinha)
	Local aCampos := {'RV_INSS','RV_FGTS','RV_IR','RV_INCORP','RV_DESC'}
	Local nI := 0
	Local cCpNome := ''
	Local nPos := 0
	DEFAULT nLinha 	:= n
	
	for nI:= 1 to Len(aCampos)
		cCpNome := "RGB_" + SubStr( aCampos[nI], At('_',aCampos[nI])+ 1)
		if(aCampos[nI] == 'RV_DESC')
			cCpNome += 'PD'
		endIf			
		nPos := GdFieldPos( cCpNome, aHeader ) 
		if(nPos > 0)
			If (Empty(SRV->(&(aCampos[nI]))))
				aLinha[nPos] := "N"
			Else
				aLinha[nPos] := SRV->(&(aCampos[nI]))
				if(aCampos[nI] == 'RV_DESC')
					aCols[nLinha][nPos] := aLinha[nPos]
				EndIf 
			EndIf
		endIf
	next nI
Return nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA520   ºAutor  ³Microsiga           º Data ³  07/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Move o foco da coluna na getDados conforme o tipo informado º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA520                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function gp520MoveFocoCol(cTipo)

	lGp580Auto := If (Type("lGp580Auto") == "U",.F.,lGp580Auto)    
	
	If lGp580Auto
		Return .T.
	EndIf        
	
	Do Case
		Case cTipo == "H" .Or. cTipo == "D"	
			nPosHoras	      	 := GdFieldPos( "RGB_HORAS"  	, aHeader )
			oGet:oBrowse:nColPos := nPosHoras - 1
		
		Case cTipo == "V"
			nPosValor		     := GdFieldPos( "RGB_VALOR"	    , aHeader )
			oGet:oBrowse:nColPos := nPosValor - 1
		
		Case cTipo == "MAT"
			nPosPD			     := GdFieldPos( "RGB_PD" 	    , aHeader )
			oGet:oBrowse:nColPos := nPosPD - 1 
		
		Case cTipo == "PD"
			nPosTipo1		     := GdFieldPos( "RGB_TIPO1" 	, aHeader )
			oGet:oBrowse:nColPos := nPosTipo1 - 1	
		
		Case cTipo == "DTREF"
			nPosDtRef		     := GdFieldPos( "RGB_DTREF"  	, aHeader )
			oGet:oBrowse:nColPos := nPosDtRef - 1	
		Case cTipo == "DUM"                      
			oGet:oBrowse:nColPos := GdFieldPos( "RGB_DUM"  		, aHeader ) - 1
	EndCase 
		
Return .T.


/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³gp520VldListPd	³Autor³				       ³ Data ³20/06/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³							               					 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³TRUE                            							 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³															 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
//Function gp520CampoOk()
	//oBtSalvar:lActive := .T.
//Return .T.

/*ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp520LinOk  ³ Autor ³ Valdeci Lira        ³ Data ³13/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao linha a linha da getDados      	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA520                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp520LinOk()
	Local lValidaGetDados	:= .F.	
	Local nNumLinha			:= oGet:oBrowse:nAt
     
    If ArrayCompare(oGet:aCols, aColsAnt)
       Return .T.
    EndIf       
    			
	If !(oGet:aCols[ nNumLinha, nPosDeleted])
		If !oGet:aCols[nNumLinha, nPosDeleted] .AND. (Empty(oGet:aCols[nNumLinha, nPosMat]) .Or. Empty( oGet:aCols[nNumLinha, nPosPd]) .Or. Empty( oGet:aCols[ nNumLinha, nPosFilial]))
			MsgInfo( OemToAnsi( STR0034 ) , OemToAnsi( STR0009 ) ) //"Os campos Filial, Matricula ou Verba estao vazios!" ### "Atencao"
			Return( lValidaGetDados )
		Else
			lValidaGetDados	:= .T.
		EndIf
	
		If lValidaGetDados
			cMsg := ""
			If Empty( oGet:aCols[ nNumLinha, nPosMat ])
				cMsg := OemToAnsi(STR0037) + " " + oGet:aHeader[ nPosMat, 1 ] + " " + OemToAnsi(STR0038) //"O campo " ### " e obrigatorio e nao foi preenchido!"
			ElseIf Empty( oGet:aCols[ nNumLinha, nPosPd ])
				cMsg := OemToAnsi(STR0037) + " " + oGet:aHeader[ nPosPd, 1 ] + " " + OemToAnsi(STR0038) //"O campo " ### " e obrigatorio e nao foi preenchido!"
			ElseIf Empty( oGet:aCols[ nNumLinha, nPosDtRef ] )
				cMsg := OemToAnsi(STR0037) + " " + oGet:aHeader[ nPosDtRef, 1 ] + " " + OemToAnsi(STR0038) //"O campo " ### " e obrigatorio e nao foi preenchido!"
			ElseIf Empty( oGet:aCols[ nNumLinha, nPosCC ])
				cMsg := OemToAnsi(STR0037) + " " + oGet:aHeader[ nPosCC, 1 ] + " " + OemToAnsi(STR0038) //"O campo " ### " e obrigatorio e nao foi preenchido!"
			ElseIf Empty( oGet:aCols[ nNumLinha, nPosTipo1 ])
				cMsg := OemToAnsi(STR0037) + " " + oGet:aHeader[ nPosTipo1, 1 ] + " " + OemToAnsi(STR0038) //"O campo " ### " e obrigatorio e nao foi preenchido!"						
			ElseIf Empty( oGet:aCols[ nNumLinha, nPosTipo1 ])
				cMsg := OemToAnsi(STR0037) + " " + oGet:aHeader[ nPosTipo1, 1 ] + " " + OemToAnsi(STR0038) //"O campo " ### " e obrigatorio e nao foi preenchido!"
			ElseIf Empty( oGet:aCols[ nNumLinha, nPosCodFun ])
				cMsg := OemToAnsi(STR0037) + " " + oGet:aHeader[ nPosCodFun, 1 ] + " " + OemToAnsi(STR0038) //"O campo " ### " e obrigatorio e nao foi preenchido!"
			ElseIf Empty( oGet:aCols[ nNumLinha, nPosPosto ])
				If lUseOrg
					cMsg := OemToAnsi(STR0037) + " " + oGet:aHeader[ nPosPosto, 1 ] + " " + OemToAnsi(STR0038) //"O campo " ### " e obrigatorio e nao foi preenchido!"
				EndIf
			ElseIf Empty( oGet:aCols[ nNumLinha, nPosDepto ])
				cMsg := OemToAnsi(STR0037) + " " + oGet:aHeader[ nPosDepto, 1 ] + " " + OemToAnsi(STR0038) //"O campo " ### " e obrigatorio e nao foi preenchido!"
			EndIf 
			If !Empty(cMsg)
				MsgInfo( cMsg , OemToAnsi( STR0009 ) ) //" " ### "Atencao"
				lValidaGetDados := .F.
			EndIf
		EndIf
		
		//Se os campos minimos ja foram validados verifica
		//a consistencia
		If lValidaGetDados 
			//Verifica o campo horas ou valor
			Do Case					
				Case oGet:aCols[ nNumLinha, nPosTipo1	] == "V" .And. Empty( oGet:aCols[ nNumLinha, nPosValor ])
					Help(" ",1,"A040SVAHOR")
					lValidaGetDados := .F.
				Case (oGet:aCols[ nNumLinha, nPosTipo1	] == "H"	;
						.Or.										;
					 oGet:aCols[ nNumLinha, nPosTipo1	] == "D")	;
						.And. 									 	;					 	
					(Empty( oGet:aCols[ nNumLinha, nPosHoras	])	;
						.And.										;
					 Empty( oGet:aCols[ nNumLinha, nPosDUm		])  ;		
 						.And.										;
					 Empty( oGet:aCols[ nNumLinha, nPosDDois	])  ;
 						.And.										;
					 Empty( oGet:aCols[ nNumLinha, nPosDTres	])  ;
 						.And.										;
					 Empty( oGet:aCols[ nNumLinha, nPosDQuatr	])  ;
 						.And.										;
					 Empty( oGet:aCols[ nNumLinha, nPosDCinco	])  ;
					 	.And.										;
					 Empty( oGet:aCols[ nNumLinha, nPosDSeis	])  ;
					 	.And.										;
					 Empty( oGet:aCols[ nNumLinha, nPosDSete	])  )
						Help(" ",1,"A040SHORAS")
						lValidaGetDados := .F. 
				Case (!Empty(dDtInicial) .AND. !Empty(dDtFinal))          	;
						.And.												;
					 (oGet:aCols[ nNumLinha, nPosDtRef	] < dDtInicial) 	;
				        .Or. 												;
				     (oGet:aCols[ nNumLinha, nPosDtRef] > dDtFinal)
					     MsgInfo( OemToAnsi( STR0035 ) + CRLF + OemToAnsi( STR0036 ), OemToAnsi( STR0009 ) )//"Data de Referencia Invalida! " ### "Verifique se esta entre os Intervalos de Data do Periodo!" ### "Atencao"
						lValidaGetDados := .F. 				     
	    	EndCase
	    	
	    	If ( lValidaGetDados  )
	    		If Empty( oGet:aCols[ nNumLinha, nPosSeq ] )
	    			lValidaGetDados := fMontaSeq( "RGB_PD", oGet:aCols[nNumLinha, nPosPd] )
	    		EndIf
	    	EndIf
		EndIf			                  
	Else
		lValidaGetDados := .T.
	EndIf 
	
	If !lItemClVl
		nPos := ASCAN(aColsAnt, { |X| X[nPosFilial]+cCodProcesso+X[nPosMat]+cCodPeriodo+;
																X[nPosSemana]+cCodRoteiro+X[nPosPD]+X[nPoscc]+X[nPosSeq]+;
																DTOS(X[nPosDtRef]) = oGet:aCols[ nNumLinha, nPosFilial ]+;
																cCodProcesso+oGet:aCols[ nNumLinha, nPosMat ]+cCodPeriodo+;
					  											oGet:aCols[ nNumLinha, nPosSemana ]+cCodRoteiro+oGet:aCols[ nNumLinha, nPosPD ]+;
																oGet:aCols[ nNumLinha, nPosCC ]+oGet:aCols[ nNumLinha, nPosSeq ]+;
																Dtos(oGet:aCols[ nNumLinha, nPosDtRef ]) } )
	Else       
		nPos := ASCAN(aColsAnt, { |X| X[nPosFilial]+cCodProcesso+X[nPosMat]+cCodPeriodo+;
																X[nPosSemana]+cCodRoteiro+X[nPosPD]+X[nPosCC]+X[nPosItem]+X[nPosClasse]+;
																X[nPosSeq]+DTOS(X[nPosDtRef]) = oGet:aCols[ nNumLinha, nPosFilial ]+;
																cCodProcesso+oGet:aCols[ nNumLinha, nPosMat ]+cCodPeriodo+;
					  											oGet:aCols[ nNumLinha, nPosSemana ]+cCodRoteiro+oGet:aCols[ nNumLinha, nPosPD ]+;
																oGet:aCols[ nNumLinha, nPosCC ]+oGet:aCols[ nNumLinha, nPosItem ]+;
																oGet:aCols[ nNumLinha, nPosClasse ]+oGet:aCols[ nNumLinha, nPosSeq ]+;
																Dtos(oGet:aCols[ nNumLinha, nPosDtRef ]) } )
	Endif
															
	If (!(oGet:aCols[ nNumLinha, nPosDeleted ]) .and. !ArrayCompare( oGet:aCols, aRGBCols ) .and. lValidaGetDados .and. nPos <> nNumLinha)
        
		SPFilTerOff( { "SRA", "RGB" } )
		
		If !lItemClVl
			RGB->(dbSetOrder( RetOrdem( "RGB", "RGB_FILIAL+RGB_PROCES+RGB_MAT+RGB_PERIOD+RGB_SEMANA+RGB_ROTEIR+RGB_PD+RGB_CC+RGB_SEQ+DTOS(RGB_DTREF)" ) ))

			cKeyPes	:= oGet:aCols[ nNumLinha, nPosFilial ]+cCodProcesso+oGet:aCols[ nNumLinha, nPosMat ]+;
						cCodPeriodo+oGet:aCols[ nNumLinha, nPosSemana ]+cCodRoteiro+oGet:aCols[ nNumLinha, nPosPD ]+;
						oGet:aCols[ nNumLinha, nPosCC ]+oGet:aCols[ nNumLinha, nPosSeq ]+Dtos(oGet:aCols[ nNumLinha, nPosDtRef ])			
		Else 
			RGB->(dbSetOrder( RetOrdem( "RGB", "RGB_FILIAL+RGB_PROCES+RGB_MAT+RGB_PERIOD+RGB_SEMANA+RGB_ROTEIR+RGB_PD+RGB_CC+RGB_ITEM+RGB_CLVL+RGB_SEQ+DTOS(RGB_DTREF)" ) ))		

			cKeyPes	:= oGet:aCols[ nNumLinha, nPosFilial ]+cCodProcesso+oGet:aCols[ nNumLinha, nPosMat ]+;
						cCodPeriodo+oGet:aCols[ nNumLinha, nPosSemana ]+cCodRoteiro+oGet:aCols[ nNumLinha, nPosPD ]+;
						oGet:aCols[ nNumLinha, nPosCC ]+oGet:aCols[ nNumLinha, nPosItem ]+oGet:aCols[ nNumLinha, nPosClasse ]+;
						oGet:aCols[ nNumLinha, nPosSeq ]+Dtos(oGet:aCols[ nNumLinha, nPosDtRef ])					
		Endif
				
	
		If RGB->(dbSeek(cKeyPes)) 
															
			MsgAlert( OemToAnsi(STR0039), OemToAnsi(STR0033) ) //Chave duplicada! - Atencao!
			lValidaGetDados := .F.
			
		EndIf
		
		SPFilTerOff( { "SRA", "RGB" }, .F. )
	
	EndIf							                    
Return ( lValidaGetDados )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp520TudoOk ³ Autor ³ Valdeci Lira        ³ Data ³13/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao de todas linhas da getDados    	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA520                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp520TudoOk()
Local lValidaCabecalho 	:= .F.				//->Variavel de controle a validacao do cabecalho
Local lRet				:= .T.				//Controle da insercao
	
//FAZ A VALIDACAO DO CABECALHO DA TELA
lValidaCabecalho := !Empty( cCodRoteiro )	.and. !Empty( cCodProcesso ) .and. !Empty( cCodPeriodo )
	
	If lValidaCabecalho 
		If ArrayCompare(oGet:Acols, aColsAnt, oGet:oBrowse:nAt) 
			lRet := .T.
		EndIf
		If !( oGet:aCols[ oGet:oBrowse:nRowPos, nPosDeleted ] )
			If !gp520LinOk()
				lRet := .F.
			EndIf
		EndIf
	Else	
		msgAlert( OemToAnsi( STR0009 ) )
	EndIf
	
Return ( lRet ) 

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gpea520Grava³ Autor ³ Valdeci Lira        ³ Data ³13/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava na tabela de incidencias        	                  ³±±
±±³ 		 ³cAlias 		-> Alias de trabalho 	        	          ³±±
±±³ 		 ³cFil   		-> Filial de Trabalho 	        	          ³±±
±±³ 		 ³aRegAltera 	-> Array com os recnos dos registros da acols ³±±
±±³ 		 ³lPerg			-> Faz a pergunta antes de gravar a alteracao ³±±
±±³ 		 ³nOpc			-> Identifica a opcao selecionada no menu inic³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA520                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Gpea520Grava( cAlias, cFil, aRegAltera , lPerg, nOpc)
	Local aRGBCols			:= ( oGet:aCols )						//-> MATRIZ QUE REPRESENTA A GETDADOS
	Local lTudoIgual		:= .F.									//-> INDICA SE A LINHA ESTA IGUAL A ANTERIOR
	Local lPrimeiroReg		:= Empty( aColsAnt[1,nPosMat] )			//-> INDICA SE A TELA FOI ABERTA VAZIA
	Local nX 				:= 0    								//-> CONTADOR
	Local nLenCols			:= Len( oGet:aCols 	)					//-> QUANTIDADE DE LINHAS NA GETDADOS
	Local nLenCAnt			:= Len( aColsAnt	)					//-> MATRIZ DA GETDADOS ANTES DA ALTERACAO

	//Remonta a getDados se Houver Necessidade
	remontaGetDados(cAlias, cFil, @aVirtual, @aColsRec, @aRGBCols, nOpc )	   				 
					 		 
	//VERIFICA SE HOUVE ALTERACOES NOS CAMPOS DA GETDADOS
	If !ArrayCompare( aRGBCols , aColsAnt ) 
		                
		//Sai da Funcao, e o primeiro registro e esta deletado
		If (aRGBCols[1,nPosDeleted] .AND. lPrimeiroReg)	
			Return (.T.)                                     
		EndIf                                                
		
		If lPerg //Se deve fazer a pergunta ...
			If !(MsgYesNo( OemToAnsi( STR0007 ) ) )	//"Deseja salvar as alteracoes?" 
				Return (.T.)
			EndIf
		EndIf

		Begin Transaction 						
			For nX := 1 To nLenCols 
				
				If !Empty( oGet:aCols[ nX, nPosMat ])	;
					.And.		        				; 						
					!Empty( oGet:aCols[ nX, nPosPd	])	;
					.And.  				   				; 						
					!Empty( oGet:aCols[ nX, nPosFilial])                       
					
					
					//Verifica se a linha corrente foi alterada
					If ( nX > nLenCols .or. nX > nLenCAnt )
						lTudoIgual := .F.
					Else
						lTudoIgual := ArrayCompare( aRGBCols[ nX ] , aColsAnt[nX] )	
					EndIf   
				  
					//Altera, deleta ou insere o 1 registro, considerando a informacao de 
					//aRGBCols[nX,nPosDeleted] e Empty( aColsAnt[1,1] ) que indica q a tela foi montada vazia
					Do Case
						Case ( aRGBCols[nX,nPosDeleted] )
							If !Empty(aRGBCols[Nx,nPosRegWT])
								Gp520Tabela( cAlias , cFil , nX, "DELETE", aRegAltera[nX] )
							Endif
						Case ( nX > nLenCAnt ) .Or. lPrimeiroReg
							Gp520Tabela( cAlias , cFil, nX, "INSERT" )                                                             
	
						Case !(lTudoIgual)
							Gp520Tabela( cAlias , cFil , nX, "UPDATE", aRegAltera[nX] )						
					End Case
				EndIf
			Next nX

			( cAlias )->( EvalTrigger() )
			
			aColsAnt := aClone(oGet:aCols)		
			If oDlg!=Nil	
				oGet:lModified 		:= .F.
				//oBtAtualizar:lActive:= .F.
				//oBtSalvar:lActive 	:= .F.
			EndIf
		End Transaction
	EndIf	
return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gpea520Tabela ³ Autor ³Valdeci Lira		  ³ Data ³ 13.11.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a interface de comunicacao com o banco inserindo, alterand³±±
±±³			 ³ou deletando registros										³±±
±±³			 ³cAlias-> Alias da tabela										³±±
±±³			 ³cFil	-> Filial da tabela										³±±
±±³			 ³nLinha-> Linha do oGet:aCols onde deve ser iniciado o proces	³±±
±±³			 ³cTipo	-> Tipo de operacao que se deve fazer, EX: INSERT		³±±
±±³			 ³cRecno-> Recno do registro para o caso de deletar ou update	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Gpea520Grava	                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function gp520Tabela( cAlias , cFil , nLinha, cTipo, cRecno )
	Local aRGBCols		:= aClone( oGet:aCols )
	Local nLenColuna	:=    Len( aGdGrava   )
	Local nX				 	
	Default cTipo		:= "UPDATE"                      
	
	If (valtype(cRecno)!="N" .AND. cRecno == .T.)
		cRecno:= ""
	EndIf
	
	Do Case
		Case cTipo == "INSERT" 
			lInsert := .T.	
		
		Case cTipo == "UPDATE"
			lInsert := .F.
			If !Empty( cRecno )
				( cAlias )->( dbGoto( cRecno ) )
		 	EndIf
		 	
		Case cTipo == "DELETE"
			If !Empty( cRecno )
				( cAlias )->( dbGoto( cRecno ) )
				( cAlias )->( RecLock( cAlias , .F. , .T. ) )
					( cAlias )->( dbDelete()) 
				( cAlias )->( MsUnLock() )
			EndIf
			Return
	End Case     
	
	If !( aRGBCols[nLinha,nPosDeleted] )
		(cAlias)->( RecLock(cAlias,lInsert) )
		
		//CAMPOS DO CABECALHO DA TELA
		(cAlias)->(&(cAlias+"_FILIAL"     ))  := aRGBCols[ nLinha, nPosFilial ]
		(cAlias)->(&(cAlias+"_PROCES" )) 	:= cCodProcesso
		(cAlias)->(&(cAlias+"_PERIOD" )) 	:= cCodPeriodo
		(cAlias)->(&(cAlias+"_ROTEIR" )) 	:= cCodRoteiro
		(cAlias)->(&(cAlias+"_SEMANA" )) 	:= cNumPagamento
		
		For nX := 1 To nLenColuna
			Do Case
				Case aGdGrava[ nX, 01 ] == "RGB_TIPO2"  	
					(cAlias)->&( aGdGrava[ nX, 01 ] ) := "I"	 
				Case !Empty(aGdGrava[ nX, 01 ])
					(cAlias)->&( aGdGrava[ nX, 01 ] ) :=  aRGBCols[ nLinha, aGdGrava[ nX, 02 ] ]
			EndCase   
		Next nX 
		
		( cAlias )->( MsUnLock() )
	EndIf
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA520   ºAutor  ³Valdeci Lira        º Data ³  07/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtra os campos do F3 considerando somente periodos abertosº±±
±±º          ³e tambem o campo de foco para filtrar mais ou menos dados   º±±
±±º          ³com conveniencia											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ F3                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp520Filtro(cTipo)
	Local cFiltro
	//Lista somente periodos abertos
	
	cFiltro := "(RCH->RCH_FILIAL == '" + XFilial("RCH",SRA->RA_FILIAL) + "')" 
	cFiltro += " .AND. (EMPTY(RCH->RCH_DTFECH))"
	
	If cTipo == "ROTEIRO" .OR. cTipo=="PERIODO" .OR. cTipo=="NUMPAG"
		if !Empty(cCodProcesso)
			cFiltro += " .AND. (RCH->RCH_PROCES == '" + cCodProcesso + "')"
		Endif	
	EndIf
	
	If cTipo == "PERIODO" .OR. cTipo=="NUMPAG"
		if !Empty(cCodRoteiro)
			cFiltro += " .AND. (RCH->RCH_ROTEIR == '" + cCodRoteiro + "')"
		Endif	
	EndIf 
	
	If cTipo=="NUMPAG"	
		If !Empty(cCodPeriodo)
			cFiltro += " .AND. (RCH->RCH_PER == '" + cCodPeriodo + "')"
		Endif
	EndIf
	
	cFiltro := "@#" + cFiltro + "@#"
Return ( cFiltro )     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA520   ºAutor  ³Valdeci Lira        º Data ³  07/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza o retorno dos dados inseridos nos cabecalhos       º±±
±±º          ³ da tela, alterando nao somente o campo mais tambem os      º±±
±±º          ³ campos complementares                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ F3                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp520Retorno(cTipo) 
	Local 	lAlterado  := .F.	
	Local   cCampo     := ""
	Default cTipo      := ""    
		
	lAlterado	:= 	cCodProcesso 	<>	RCH->RCH_PROCES		;
						.Or.								;
					cCodRoteiro		<>	RCH->RCH_ROTEIR		;
						.Or.                               	;
					cCodPeriodo		<>	RCH->RCH_PER		;
						.Or.								;
					cNumPagamento	<>	RCH->RCH_NUMPAG		;
						.Or.								;
					cabecalhoAlterado()
						
	If lAlterado
		/*If Type("oBtSalvar") != "U"
			oBtSalvar:lActive := .F.
		EndIf
		oBtAtualizarGet:lActive := .T.		
		*/
		Do case
			Case cTipo == "PROCESSO"
					cCampo          := "RCH->RCH_PROCES"
			   		cCodRoteiro		:= RCH->RCH_ROTEIR
			   		cCodPeriodo		:= RCH->RCH_PER
					cNumPagamento	:= RCH->RCH_NUMPAG
			Case cTipo == "ROTEIRO" 
					cCampo          := "RCH->RCH_ROTEIR"
					cCodRoteiro		:= RCH->RCH_ROTEIR                
			   		cCodPeriodo		:= RCH->RCH_PER
					cNumPagamento	:= RCH->RCH_NUMPAG  
			Case cTipo == "PERIODO"
					cCampo          := "RCH->RCH_PER"
					cCodPeriodo		:= RCH->RCH_PER                              
					cNumPagamento	:= RCH->RCH_NUMPAG  
			   		AtualizaDtInicialFinal()   
		EndCase         
	EndIf  

	cCampo := If ( Empty(&(cCampo)), "",  &(cCampo) )

	oCodProcesso:Refresh()    		
	oCodRoteiro:Refresh()    
	oCodPeriodo:Refresh()    
Return cCampo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA520   ºAutor  ³Valdeci Lira        º Data ³  07/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pela finalizacao dos fillbrowse aplicadosº±±
±±º          ³no SRA e SRV                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA520                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FinalizaFilBrowse()
	EndFilBrw("SRA",aIndexSRA)
Return (.T.)   
            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp520SelItemListBox( aArrayList )³ Autor ³ Valdeci Lira ³ Data ³ 14/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta uma ListBox de duas colunas com base no array passado  		    ³±±
±±³          ³ aArrayList->Array com a lista de dados a serem exibidos na listBox       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ F3 do RGB_PD [Verbas], dentro da getDados                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp520SelItemListBox( cRoteiro, cProcesso, aIndexSrv )
	Local 	bOk 		:= {|| Nil}	
	Local	bCancel		:= {|| Nil}	 
	Local	nPos		:= 0
	
	Local	cVerba		:= ""
	
	Private nTamLista	:= 0
	Private cPesq  		:= Space( 20 )
	Private cCombo 		:= OemToAnsi(STR0029)
	Private aCombo 		:= {}
	Private oLstBox   
	Private oPesq    
	Private oCombo    
	Private oDlgConsult
	Private nProcura   
	Private lOk         := .T.

	MontaF3Srv(.T., cRoteiro, cProcesso, @aIndexSrv, .T.)
	nTamLista	:= Len(aIndexSrv)
	
	bOk     := {|| lOk := .T.,;
	               If(nTamLista > 0, PosSRV( oLstBox:aArray[oLstBox:nAt,1], XFilial("SRV") , "RV_COD" ), NIL),;
				   oDlgConsult:End() }
	bCancel := {|| lOk := .F., oDlgConsult:End()}   		
    aAdd(aCombo, OemToAnsi(STR0029))
    aAdd(aCombo, OemToAnsi(STR0030))
    
	DEFINE MSDIALOG oDlgConsult FROM 150,005 TO 500,855  TITLE OemToAnsi(STR0026) PIXEL		// "Selecione o Arquivo"
	
		@ 001,001 LISTBOX oLstBox FIELDS HEADER OemToAnsi(STR0040) , OemToAnsi(STR0025) SIZE 426,137 ;	// "Bases de Dados"
		      OF oDlgConsult PIXEL ON DBLCLICK Eval( bOk )
		      
		If !Empty( ( &(ReadVar()) ) )
			cVerba := &(ReadVar())
			If ( ( nPos := aScan( aIndexSrv, { |x| x[01] == cVerba } ) ) > 0 )
				oLstBox:nAt := nPos
			EndIf
		EndIf
		
		oLstBox:SetArray(aIndexSrv) 
		If nTamLista > 0
			oLstBox:bLine := { || {oLstBox:aArray[oLstBox:nAt,1],oLstBox:aArray[oLstBox:nAt,2]}}
		EndIf
		                                                                               
		@ 145,005 SAY OemToAnsi(STR0031) SIZE 25, 7 OF oDlgConsult PIXEL //"Tipo de Pesquisa:"
		@ 145,045 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 080, 10 OF oDlgConsult PIXEL
		@ 160,005 SAY OemToAnsi(STR0028) SIZE 25, 7 OF oDlgConsult PIXEL //"Pesquisar:"
		@ 160,045 MSGET oPesq VAR cPesq  SIZE 80,10 OF oDlgConsult PIXEL PICTURE "@!"
		DEFINE SBUTTON FROM 160, 130 TYPE 1 ENABLE OF oDlgConsult ACTION Eval( bOk )                                                               
		DEFINE SBUTTON FROM 160, 160 TYPE 2 ENABLE OF oDlgConsult ACTION Eval( bCancel )
		
		//Pesquisa o item e posiciona na ListBox
		If nTamLista > 0
			oPesq:bLostFocus := {|| If(oCombo:nAt==1, nProcura:=aScan(oLstBox:aArray, { |x| x[1] $ AllTrim(cPesq) } ), nProcura:=aScan(oLstBox:aArray, { |x| AllTrim(cPesq) $ x[2]} )), If(nProcura > 0, oLstBox:nAt:= nProcura, .T.), oLstBox:Refresh(), If(oPesq:lModified, oPesq:SetFocus(), Nil), oPesq:lModified:=.F.   } 
		EndIf
	ACTIVATE MSDIALOG oDlgConsult CENTERED

Return( lOk )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³RcTipo1Init		³Autor³Marinaldo de jesus  ³ Data ³22/12/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Inicializador Padrao para o Campo RC_TIPO1					 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³Codigo da Filial para o RC_TIPO1							 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³X3_RELACAO do campo RC_TIPO1	                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function RgbTipo1Init()
Return (If(FunName() == "GPEA640","H",SRV->RV_TIPO))



/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³RGBSeqClear		³Autor³Valdeci Lira        ³ Data ³20/06/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Limpa a sequencia de verbas               					 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³TRUE                            							 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³X3_RELACAO RGB_SEQ E VALID CAMPOS CHAVE PARA CALCULO DA SEQ. ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function RgbSeqClear()
	Local nPosSeq := GdFieldPos("RGB_SEQ")
	
	If nPosSeq > 0 .AND. !(oGet == nil)
		oGet:aCols[oGet:oBrowse:nAt, nPosSeq] := ""	      
	EndIf
Return(.T.)




/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³gp520VldListPd	³Autor³				       ³ Data ³20/06/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³							               					 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³TRUE                            							 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³															 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function gp520VldListPd()
Return .T.   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA520   ºAutor  ³Valdeci Lira	     º Data ³  09/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta funcao valida a consulta padrao SRARCJ para que sejam º±±
±±º          ³ listados somente os funcionarios do processo selecionado   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp520ValidSxbFunc()                                                                                                                                                                                                                                       
	Local lRet

	lRet := SRA->RA_PROCES == RCH->RCH_PROCES	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fAcolsSPF ºAutor  ³Marcio Barretos     º Data ³  04/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o usuario tem alguma restricao no SRA ref a    º±±
±±º          ³a matricula que sera apresentada no ACOLS (RGB)             º±±
±±º          ³se tiver tira a matricula do ACOLS                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ gpea520    	                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fAcolsSPF(aRGBCols)

Local aArea    := GetArea() 
Local aAreaSRA := SRA->(GetArea())
Local Nx       := 0 
Local Nx1      := 1 
Local lDel     := .F.
Local nPos     := 0

Local nPosFil	:= GdFieldPos( "RGB_FILIAL"		, aHeader )
Local nPosMat	:= GdFieldPos( "RGB_MAT"		, aHeader )

Nx := Len(aRGBCols)
Do While Nx1 <= Nx
    
    SRA->(dbSetOrder(1))
    If ( !Empty(aRGBCols[Nx1,nPosFil]) .and. !Empty(aRGBCols[Nx1,nPosMat]) )

		If !SRA->(dbSeek(aRGBCols[Nx1,nPosFil]+aRGBCols[Nx1,nPosMat])) 
			
			nPos := ASCAN(aColsRec, { |X| X == aRGBCols[Nx1][nPosRegWT] } ) 	
			If nPos > 0 
				Adel(aColsRec,nPos)
				aSize(aColsRec,Nx-1)
			Endif 
			                  
			Adel(aRGBCols,Nx1)
			ASize(aRGBCols,Nx-1)
			lDel := .T. 
			Nx := Len(aRGBCols)		
			
		Endif
	
	EndIf
	
	Iif(!lDel,++Nx1,Nx1 := Nx1) 
    lDel := .F.

Enddo	

RestArea(aAreaSRA)
RestArea(aArea)

Return
